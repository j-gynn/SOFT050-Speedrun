﻿ <%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>

<script runat="server">
    protected string difference = "";
    public static string connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" + "Data Source=" + System.Web.HttpContext.Current.Server.MapPath("Database.accdb") + ";";
    public static bool firstRun = true;
    public static DataSet catDataSet = new DataSet();
    public static DataSet gamesDataSet = new DataSet();

    protected void Page_Load(object sender, EventArgs e)
    {
        this.difference = Request.Form["saveTime"];

        //if (this.Page.User.Identity.IsAuthenticated)
        //{
        //    //Commented out to avoid having to authenticate for every minor change lol


        //    loggedIn.InnerText = "Logged in as: " + User.Identity.Name;
        //    if (Session["isAdmin"].ToString() == "True")
        //    {
        //        isAdmin.Visible = true;
        //        isAdmin.InnerText = "Admin";
        //        isAdmin.HRef = "admin.aspx";
        //    }
        //    else
        //    {
        //        isAdmin.Visible = false;
        //    }
        //}
        //else
        //{
        //    //Commented out to avoid having to authenticate for every minor change lol
        //    Response.Redirect("login.aspx");
        //}
        if (!IsPostBack)
        {
            using (OleDbConnection con = new OleDbConnection(connectionString))
            {
                OleDbDataAdapter da = new OleDbDataAdapter("SELECT * FROM Games ORDER BY Game", con);

                gamesDataSet.Reset();
                da.Fill(gamesDataSet);
                gameSelect.DataSource = gamesDataSet.Tables[0];
                gameSelect.DataValueField = "ID";
                gameSelect.DataTextField = "Game";
                gameSelect.DataBind();

                gameSelect.Items.Insert(0, new ListItem() { Text = "Select a game", Value = "0" });
                catSelect.Items.Insert(0, new ListItem() { Text = "Select a category", Value = "0" });
                catSelect.Enabled = false;
            }
        }
    }

    private void gameSelect_SelectedIndexChanged(object sender, EventArgs e)
    {
        DropDownList origin = sender as DropDownList;
        catDataSet.Reset();
        using (OleDbConnection con = new OleDbConnection(connectionString))
        {
            OleDbCommand cmd = new OleDbCommand("SELECT * FROM Categories WHERE Game = ?");
            cmd.Parameters.Add(
                "@Game", OleDbType.VarChar).Value = origin.SelectedValue;
            OleDbDataAdapter da = new OleDbDataAdapter();
            da.SelectCommand = cmd;
            da.SelectCommand.Connection = con;
            da.Fill(catDataSet);

            catSelect.DataSource = catDataSet.Tables[0];
            catSelect.DataValueField = "ID";
            catSelect.DataTextField = "Category";
            catSelect.DataBind();
            catSelect.Items.Insert(0, new ListItem() { Text = "Select a category", Value = "0" });
            catSelect.Enabled = origin.SelectedValue != "0" ? true : false;
        }
    }

    private void catSelect_SelectedIndexChanged(object sender, EventArgs e)
    {
        DropDownList origin = sender as DropDownList;
        using (OleDbConnection con = new OleDbConnection(connectionString))
        {
            int fastestTime;
            OleDbCommand cmd = new OleDbCommand("SELECT TOP 1 Speedruns.Time FROM Speedruns WHERE Category = ? AND isVerified = True ORDER BY Speedruns.Time;");
            OleDbDataReader r;
            cmd.Parameters.Add("@Category", OleDbType.VarChar).Value = origin.SelectedValue;
            cmd.Connection = con;
            con.Open();
            r = cmd.ExecuteReader();
            bool isEmpty = true;
            while (r.Read())
            {
                double[] ratios = { 1.1, 1.25, 1.5, 2 };
                HtmlTableCell[] display = { diamondTime, goldTime, silverTime, bronzeTime };
                fastestTime = Convert.ToInt32(r["Time"]);

                
                int rank;
                for (rank = 0; rank < 4; rank ++ )
                {
                    isEmpty = false;
                    double msTime = fastestTime * ratios[rank];
                    int displayInt = Convert.ToInt32(Math.Ceiling(msTime));
                    string displayTime = "";

                    //calculations to figure out the time to display
                    int hours = displayInt / (1000 * 60 * 60) % 24;
                    int minutes = displayInt / (1000 * 60) % 60;
                    int seconds = displayInt / 1000 % 60;

                    //putting those integers into an array that can be called iteratively in a for loop later
                    int[] times = {hours, minutes, seconds};
                    string zeros = "00";
                    int i;
                    for (i=0; i<3; i++)
                    {
                        string res = String.Concat(zeros, (times[i].ToString()));
                        displayTime = displayTime + res.Substring(res.Length - 2);
                        if (i != 2)
                        {
                            displayTime = displayTime + ":";
                        }
                    }
                    display[rank].InnerText = displayTime;
                }  
            }
            con.Close();
            if (isEmpty)
                {
                    diamondTime.InnerText = "No times recorded for this category. Be the first!";
                    goldTime.InnerText = "";
                    silverTime.InnerText = "";
                    bronzeTime.InnerText = "";
                }
        }
    }

    private void btnSave_onClick(object sender, EventArgs e)
    {
        String timeToSave = this.difference;
        Session["saveTime"] = timeToSave;
        Response.Redirect("/saveTime.aspx");
    }

</script>


<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <title>Speedrun Timer</title>
    <link rel="stylesheet" type="text/css" href="home.css" />
</head>
<body onload="window_onLoad()">
    <nav>
        <a href="leaderboard.aspx">Leaderboards</a>
        <a id="isAdmin" runat="server"></a>
        <p id="loggedIn" runat="server"></p>
    </nav>
    <div>
        <h1>Speedrunning</h1>
        <p id="message" runat="server"></p>
        <form runat="server">
            <div>
                <p id="test" runat="server"></p>
                <p>
                    <a id="hours">00</a>
                    <a>:</a>
                    <a id="minutes">00</a>
                    <a>:</a>
                    <a id="seconds">00</a>
                    <a>.</a>
                    <a id="milliseconds">000</a>
                </p>
                <button id="btnStart" onclick="btnStart_onClick()" type="button">Start timer</button> 
                <button id="btnStop" onclick="btnStop_onClick()" type="button" disabled>Stop timer</button>
                <a></a>
                <button id="btnReset" onclick="btnReset_onClick()" type="button" disabled>Reset</button>
                <button id="btnSave" onserverclick="btnSave_onClick" runat="server" disabled>Save</button>
                <input type="hidden" id="saveTime" name="saveTime" value="<%=this.difference %>" />
            </div>
            <div style="background-color:lightgrey">
                <h3>Advanced</h3>
                <p>Select a category to view target times</p>
                <asp:DropDownList ID="gameSelect" autopostback="true" runat="server" OnSelectedIndexChanged="gameSelect_SelectedIndexChanged"></asp:DropDownList>
                <asp:DropDownList ID="catSelect" AutoPostBack="true" runat="server" OnSelectedIndexChanged="catSelect_SelectedIndexChanged"></asp:DropDownList>
                <table>
                <tbody>
                    <tr>
                        <td><img src="/diamond-trophy.png" /></td>
                        <td runat="server" id="diamondTime">Lorem ipsum dolor sit amet</td>
                    </tr>
                    <tr>
                        <td><img src="/gold-trophy.png" /></td>
                        <td id="goldTime" runat="server"></td>
                    </tr>
                    <tr>
                        <td><img src="/silver-trophy.png" /></td>
                        <td id="silverTime" runat="server"></td>
                    </tr>
                    <tr>
                        <td><img src="/bronze-trophy.png" /></td>
                        <td id="bronzeTime" runat="server"></td>
                    </tr>
                </tbody>
                </table>  
            </div>
        </form>
    </div>
</body>
</html>

<script>
    var difference;
    var len_req = [-3, -2, -2, -2]; //Used for calculating decimal places of time display
    var refresh = 1; // How often the timer refreshes
    var running = false;
    var timeNow;
    var timeStart;
    var timeEnd;
    var timing = {
        hours: 0,
        minutes: 0,
        seconds: 0,
        milliseconds: 0
    };
    var units = ["hours", "minutes", "seconds", "milliseconds"];
    var zeros = "0000";


    function window_onLoad() {
        window.setInterval("stopwatch()", refresh);

    }
    
    function btnStart_onClick() {
        timeStart = new Date().getTime();
        document.getElementById("btnStop").disabled = false;
        document.getElementById("btnStart").disabled = true;
        document.getElementById("gameSelect").disabled = true;
        document.getElementById("catSelect").disabled = true;
        running = true;
    }

    function btnStop_onClick() {
        document.getElementById("btnStop").disabled = true;
        document.getElementById("btnReset").disabled = false;
        document.getElementById("btnSave").disabled = false;
        running = false;
        sessionStorage.setItem("saveTime", difference);
        document.getElementById("saveTime").value = difference;
    }

    function btnReset_onClick() {
        document.getElementById("btnStart").disabled = false;
        document.getElementById("btnReset").disabled = true;
        document.getElementById("btnSave").disabled = true;
        document.getElementById("gameSelect").disabled = false;
        document.getElementById("catSelect").disabled = false;
        difference = 0;
        calculateTimes();
    }

    function stopwatch() {
        if (running == true) {
            timeNow = new Date().getTime();
            difference = timeNow - timeStart;
            calculateTimes();
        }
    }

    function calculateTimes() {
        //difference = 3661001; // FOR TESTING - One hour, one minute, one second and one millisecond (in milliseconds)
        timing = {
            hours: Math.floor(difference / (1000 * 60 * 60) % 24),
            minutes: Math.floor(difference / (1000 * 60) % 60),
            seconds: Math.floor((difference / 1000) % 60),
            milliseconds: Math.floor(difference % 1000)
        }
        var i;
        for (i = 0; i < 4; i++) {
            var res = zeros.concat(timing[units[i]]);
            var correct = res.slice((i >= 3) ? -3 : -2);
            document.getElementById(units[i]).innerText = correct;
        }    
    }
</script>
