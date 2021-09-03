 <%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>

<script runat="server">
    protected string difference = "";
    public static string connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" + "Data Source=" + System.Web.HttpContext.Current.Server.MapPath("assets/Database.accdb") + ";";
    public static DataSet catDataSet = new DataSet();
    public static DataSet gamesDataSet = new DataSet();
    public HtmlTableCell[] display;
    public RadioButton[] btn_Radio;
    public string targetTime;


    protected void Page_Load(object sender, EventArgs e)
    {
        difference = Request.Form["saveTime"];
        display = new HtmlTableCell[] { diamondTime, goldTime, silverTime, bronzeTime };
        btn_Radio = new RadioButton[] { diamondSelected, goldSelected, silverSelected, bronzeSelected };

        if (Session["targetTime"] != null)
        {
            targetTime = Session["targetTime"].ToString();
        }

        if (this.Page.User.Identity.IsAuthenticated)
        {
            //Commented out to avoid having to authenticate for every minor change lol
            loggedIn.InnerText = "Logged in as: " + User.Identity.Name;
            if (Session["isAdmin"].ToString() == "True")
            {
                isAdmin.Visible = true;
                isAdmin.InnerText = "Admin";
                isAdmin.HRef = "admin.aspx";
            }
            else
            {
                isAdmin.Visible = false;
            }
        }
        else
        {
            Response.Redirect("login.aspx");
        }
        if (!IsPostBack)
        {
            //initialising the target time array if it's the first time the page has been loaded
            int[] intTargetTime = new int[4];
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
        if (origin.SelectedValue == "0")
        {
            //disabling and unchecking the radio buttons since a category has been deselected
            resetSelected.Enabled = false;
            for (int i = 0; i < 4; i++)
            {
                btn_Radio[i].Enabled = false;
                btn_Radio[i].Checked = false;
            }

            targetHours.InnerText = "00";
            targetMinutes.InnerText = "00";
            targetSeconds.InnerText = "00";
        }

        //empty the target times in case they've been filled
        diamondTime.InnerText = " ";
        goldTime.InnerText = " ";
        silverTime.InnerText = " ";
        bronzeTime.InnerText = " ";


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
        resetSelected.Enabled = false;
        for (int i = 0; i < 4; i++)
        {
            // removing any previously-made selection on the target radio
            // also disabling them in case there are no available times to select
            btn_Radio[i].Checked = false;
            btn_Radio[i].Enabled = false;
        }
        DropDownList origin = sender as DropDownList;
        using (OleDbConnection con = new OleDbConnection(connectionString))
        {
            int fastestTime;
            // command to find the fastest time in a given category
            OleDbCommand cmd = new OleDbCommand("SELECT TOP 1 Speedruns.Time FROM Speedruns WHERE Category = ? AND isVerified = True ORDER BY Speedruns.Time;");
            OleDbDataReader r;

            // adding the requested category to the command
            cmd.Parameters.Add("@Category", OleDbType.VarChar).Value = origin.SelectedValue;
            cmd.Connection = con;
            con.Open();
            r = cmd.ExecuteReader();

            // used to check whether r.Read() was successful later
            bool isEmpty = true;

            while (r.Read())
            {
                //the target times in order from fastest to slowest (diamond to bronze)
                //calculated as 110%, 125%, 150% and 200% of the fastest time
                double[] ratios = { 1.1, 1.25, 1.5, 2 };
                fastestTime = Convert.ToInt32(r["Time"]);
                int[] intTargetTime = new int[4];

                resetSelected.Enabled = true;
                for (int rank = 0; rank < 4; rank ++ )
                {
                    // enable the radio buttons once a target time can be displayed
                    btn_Radio[rank].Enabled = true;

                    isEmpty = false;
                    double msTime = fastestTime * ratios[rank];

                    int target = Convert.ToInt32(Math.Ceiling(msTime));

                    intTargetTime[rank] = target;

                    string displayTime = "";
                    Session["targetTimesArray"] = intTargetTime;

                    //calculations to figure out the time to display
                    int hours = intTargetTime[rank] / (1000 * 60 * 60) % 24;
                    int minutes = intTargetTime[rank] / (1000 * 60) % 60;
                    int seconds = intTargetTime[rank] / 1000 % 60;
                    int milliseconds = intTargetTime[rank] % 1000;


                    bool overAnHour = false;
                    if (hours >= 1)
                    {
                        overAnHour = true;
                    }

                    //putting those integers into an array that can be called iteratively in a for loop later
                    int[] times = { hours, minutes, seconds, milliseconds };
                    string zeros = "00";

                    for (int i = 0; i < 4; i++)
                    {
                        string res = String.Concat(zeros, (times[i].ToString()));
                        if ((overAnHour) & (i != 3))
                        {
                        displayTime += res.Substring(res.Length - 2) 
                            + (i <= 1 ? ":" : "");
                        } else if ((!overAnHour) & (i != 0))
                        {
                        displayTime += res.Substring(res.Length - (i <= 2 ? 2 : 3)) 
                            + (i <= 1 ? ":" : (i == 2 ? "." : ""));
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

    private void selectRadio_OnCheckedChanged(object sender, EventArgs e)
    {
        int targetTimeInt = 0;
        string zeroes = "0000";

        // if the reset button is checked, uncheck everything and set target time to zero
        if (resetSelected.Checked == true)
        {
            resetSelected.Checked = false;
            Session["targetTime"] = 0;
            targetTime = "";
            targetHours.InnerText = "00";
            targetMinutes.InnerText = "00";
            targetSeconds.InnerText = "00";
            targetMilliseconds.InnerText = "000";

            for (int i = 0; i > 4; i++)
            {
                display[i].InnerText = "";
            }
        }
        else
        {
            for (int i = 0; i < 4; i++)
            {
                // finding which button is checked and then setting the hidden field targetTime to that
                if (btn_Radio[i].Checked == true)
                {
                    int[] targetArray = Session["targetTimesArray"] as int[];
                    targetTimeInt = Convert.ToInt32(targetArray[i]);
                    Session["targetTime"] = targetTimeInt;
                    targetTime = targetTimeInt.ToString();

                }
            }

            int target = (targetTimeInt / (1000 * 60 * 60) % 24);
            string stringTarget = target.ToString();
            string zeroedTarget = String.Concat(zeroes, stringTarget);
            targetHours.InnerText = zeroedTarget.Substring(zeroedTarget.Length - 2);

            target = ((targetTimeInt / (1000 * 60)) % 60);
            stringTarget = target.ToString();
            zeroedTarget = String.Concat(zeroes, stringTarget);
            targetMinutes.InnerText = zeroedTarget.Substring(zeroedTarget.Length - 2);

            target = (targetTimeInt / 1000 % 60);
            stringTarget = target.ToString();
            zeroedTarget = String.Concat(zeroes, stringTarget);
            targetSeconds.InnerText = zeroedTarget.Substring(zeroedTarget.Length - 2);

            target = (targetTimeInt % 1000);
            stringTarget = target.ToString();
            zeroedTarget = String.Concat(zeroes, stringTarget);
            targetMilliseconds.InnerText = zeroedTarget.Substring(zeroedTarget.Length - 3);
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
<body onload="window_onLoad()" style="width:75%; margin:auto">
    <h1 style="text-align: center;">Speedrunning</h1>
    <nav>
        <a href="leaderboard.aspx">Leaderboards</a>
        <a id="isAdmin" runat="server"></a>
        <br />
        <a id="loggedIn" runat="server"></a>
    </nav>
    <div>
        <p id="message" runat="server"></p>
        <form runat="server">
            <div>
                <h3 style="text-align:center">Your time:</h3>
                <p style="font-size:x-large;  text-align: center;" id="timer">
                    <a id="hours">00</a>
                    <a>:</a>
                    <a id="minutes">00</a>
                    <a>:</a>
                    <a id="seconds">00</a>
                    <a>.</a>
                    <a id="milliseconds">000</a>
                </p>
                <h3 style="text-align:center">Target time:</h3>
                <p id="targetComparison" style="font-size:larger; text-align: center;">
                    <a id="targetPlusMinus">-</a>
                    <a id="targetHours" runat="server">00</a>
                    <a>:</a>
                    <a id="targetMinutes" runat="server">00</a>
                    <a>:</a>
                    <a id="targetSeconds" runat="server">00</a>
                    <a>.</a>
                    <a id="targetMilliseconds" runat="server">000</a>
                </p>
                <div style="text-align: center;">
                    <h4>Keyboard shortcuts:</h4>
                    <p>
                        <b>Spacebar:</b> Start/Stop 
                        <br />
                        <b>Esc:</b> Reset
                    </p>
                    <button id="btnStart" onclick="btnStart_onClick()" type="button" style="min-width:65px; width:25%" class="button">Start </button>
                    <button id="btnResume" onclick="btnResume_onClick()" type="button" hidden style="min-width:65px; width:25%" class="button">Resume</button>
                    <button id="btnStop" onclick="btnStop_onClick()" type="button" disabled style="min-width:65px; width:25%" class="button">Stop</button>
                    <br />
                    <button id="btnReset" onclick="btnReset_onClick()" type="button" disabled style="min-width:65px; width:25%" class="button">Reset</button>
                    <button id="btnSave" onserverclick="btnSave_onClick" runat="server" disabled style="min-width:65px; width:25%" class="button">Save</button>
                </div>
                <input type="hidden" id="saveTime" name="saveTime" value="<%=this.difference %>" />
                <input type="hidden" id="targetTime" name="targetTime" value="<%=this.targetTime %>" />
            </div>
            <div style="background-color:lightgrey">
                <h3>Advanced</h3>
                <p>
                    Select a category to view target times.
                    <br />
                    <i>Note: Once the timer is started, these options become unavailable.</i>
                </p>
                <asp:DropDownList ID="gameSelect" autopostback="true" runat="server" OnSelectedIndexChanged="gameSelect_SelectedIndexChanged"></asp:DropDownList>
                <asp:DropDownList ID="catSelect" AutoPostBack="true" runat="server" OnSelectedIndexChanged="catSelect_SelectedIndexChanged"></asp:DropDownList>
                <table>
                <tbody>
                    <tr>
                        <td><asp:RadioButton AutoPostBack="true" id="diamondSelected" runat="server" GroupName="selectRadio" enabled="false" OnCheckedChanged="selectRadio_OnCheckedChanged" /></td>
                        <td><img src="/assets/diamond-trophy.png" /></td>
                        <td id="diamondTime" runat="server"></td>
                    </tr>
                    <tr>
                        <td><asp:RadioButton AutoPostBack="true" id="goldSelected" runat="server" GroupName="selectRadio" enabled="false" OnCheckedChanged="selectRadio_OnCheckedChanged" /></td>
                        <td><img src="/assets/gold-trophy.png" /></td>
                        <td id="goldTime" runat="server"></td>
                    </tr>
                    <tr>
                        <td><asp:RadioButton AutoPostBack="true" id="silverSelected" runat="server" GroupName="selectRadio" enabled="false" OnCheckedChanged="selectRadio_OnCheckedChanged" /></td>
                        <td><img src="/assets/silver-trophy.png" /></td>
                        <td id="silverTime" runat="server"></td>
                    </tr>
                    <tr>
                        <td><asp:RadioButton AutoPostBack="true" id="bronzeSelected" runat="server" GroupName="selectRadio" enabled="false" OnCheckedChanged="selectRadio_OnCheckedChanged" /></td>
                        <td><img src="/assets/bronze-trophy.png" /></td>
                        <td id="bronzeTime" runat="server"></td>
                    </tr>
                    <tr>
                        <td><asp:RadioButton AutoPostBack="true" id="resetSelected" runat="server" GroupName="selectRadio" enabled="false" OnCheckedChanged="selectRadio_OnCheckedChanged" /></td>
                        <td colspan="2">Clear selection</td>
                    </tr>
                </tbody>
                </table>  
            </div>
        </form>
    </div>
</body>
</html>

<script>
    var timeElapsed;
    var targetTimeLeft;
    var len_req = [-3, -2, -2, -2]; // Used for calculating decimal places of time display
    var refresh = 1; // How often timeElapsed refreshes
    var running = false; // Used to determine if timeElapsed should be calculated
    var target = false; // Used to determine if targetTimeLeft should be calculated
    var timeStart; // When the current timing segment was started (since Unix Epoch)
    var timePaused = 0; // How much time has elapsed in previous timing segments
    var timeCheckpoint = 0;
    var timeIntervals = {
        hours: 0,
        minutes: 0,
        seconds: 0,
        milliseconds: 0
    };
    var targetTiming = {
        targetHours: 0,
        targetMinutes: 0,
        targetSeconds: 0,
        targetMilliseconds: 0
    };
    var msEnabled = true;
    var units = ["hours", "minutes", "seconds", "milliseconds"];
    var targetunits = ["targetHours", "targetMinutes", "targetSeconds", "targetMilliseconds"];
    var zeros = "0000";
    var timeLoss = false;

    document.addEventListener("keydown", function (event) {
        if (event.defaultPrevented) {
            return;
        }

        switch (event.key) {
            case " ":
                if (running == true) {
                    btnStop_onClick();
                    break;

                } else if (timePaused != 0) {
                    btnResume_onClick();
                    break;

                } else {
                    btnStart_onClick();
                    break;
                }
                break;
            case "Esc":
            case "Escape":
                if (running == true) {
                    btnStop_onClick()
                } else {
                    btnReset_onClick();
                }
                break;
            default:
                return;
        }
        event.preventDefault();
    }, true);

    function window_onLoad() {
        window.setInterval("stopwatch()", refresh);
    }

    function toggleRadios(boolean) {
        if (document.getElementById("diamondTime") != " ") {
            document.getElementById("diamondSelected").disabled = boolean;
            document.getElementById("goldSelected").disabled = boolean;
            document.getElementById("silverSelected").disabled = boolean;
            document.getElementById("bronzeSelected").disabled = boolean;
            document.getElementById("resetSelected").disabled = boolean;
        }
        document.getElementById("gameSelect").disabled = boolean;
        if (document.getElementById("gameSelect").value != 0) {
            document.getElementById("catSelect").disabled = boolean;
        }
    }

    function btnStart_onClick() {
        if (document.getElementById("targetTime").value != "") {
            target = true;
        } else {
            document.getElementById("targetComparison").style.color = "gray";
            target = false;
        }
        timeStart = new Date().getTime();
        document.getElementById("btnStop").disabled = false;
        document.getElementById("btnStart").disabled = true;
        toggleRadios(true);
        running = true;
    }

    function btnResume_onClick() {
        running = true;
        timeStart = new Date().getTime();

        document.getElementById("btnStart").disabled = true;
        document.getElementById("btnResume").disabled = true;
        document.getElementById("btnStop").disabled = false;
        document.getElementById("btnReset").disabled = true;
        document.getElementById("btnSave").disabled = true;
    }

    function btnStop_onClick() {
        running = false;
        timePaused = + timeElapsed;
        calculateTimes();
        document.getElementById("btnStart").hidden = true;
        document.getElementById("btnResume").disabled = false;
        document.getElementById("btnResume").hidden = false;
        document.getElementById("btnStop").disabled = true;
        document.getElementById("btnReset").disabled = false;
        document.getElementById("btnSave").disabled = false;

        document.getElementById("saveTime").value = timeElapsed;
    }

    function btnReset_onClick() {
        document.getElementById("btnStart").disabled = false;
        document.getElementById("btnStart").hidden = false;
        document.getElementById("btnResume").hidden = true;
        document.getElementById("btnReset").disabled = true;
        document.getElementById("btnSave").disabled = true;
        toggleRadios(false);
        timeElapsed = 0;
        timePaused = 0;
        targetTimeLeft = document.getElementById("targetTime").value;
        calculateTimes();
    }

    function stopwatch() {
        if (running == true) {
            var timeNow = new Date().getTime();
            timeElapsed = (timeNow - timeStart) + timePaused;
            if (target == true) {
                targetTimeLeft = document.getElementById("targetTime").value - timeElapsed;
            }
            calculateTimes();
        }
    }

    function calculateTimes() {

        timeIntervals = {
            hours: Math.floor(timeElapsed / (1000 * 60 * 60) % 24),
            minutes: Math.floor(timeElapsed / (1000 * 60) % 60),
            seconds: Math.floor((timeElapsed / 1000) % 60),
            milliseconds: Math.floor(timeElapsed % 1000)
        }

        if (target == true) {
            if (timeElapsed < (document.getElementById("targetTime").value * 0.5)) {
                document.getElementById("targetPlusMinus").innerText = "-";
                document.getElementById("targetComparison").style.color = "goldenRod";

            } else if (timeElapsed < document.getElementById("targetTime").value) {
                document.getElementById("targetPlusMinus").innerText = "-";
                document.getElementById("targetComparison").style.color = "green";
            } else {
                targetTimeLeft = Math.abs(targetTimeLeft);
                document.getElementById("targetPlusMinus").innerText = "+";
                document.getElementById("targetComparison").style.color = "red";
            }
            targetTiming = {
                targetHours: Math.floor(targetTimeLeft / (1000 * 60 * 60) % 24),
                targetMinutes: Math.floor(targetTimeLeft / (1000 * 60) % 60),
                targetSeconds: Math.floor((targetTimeLeft / 1000) % 60),
                targetMilliseconds: Math.floor(targetTimeLeft % 1000)
            }
        }

        for (var i = 0; i < 4; i++) {
            var res = zeros.concat(timeIntervals[units[i]]);
            var correct = res.slice((i >= 3) ? -3 : -2);
            document.getElementById(units[i]).innerText = correct;

            if (target == true) {
                targetTiming = {
                    targetHours: Math.floor(targetTimeLeft / (1000 * 60 * 60) % 24),
                    targetMinutes: Math.floor(targetTimeLeft / (1000 * 60) % 60),
                    targetSeconds: Math.floor((targetTimeLeft / 1000) % 60),
                    targetMilliseconds: Math.floor(targetTimeLeft % 1000)
                }
                var targetres = zeros.concat(targetTiming[targetunits[i]]);
                var targetslice = targetres.slice((i >= 3) ? -3 : -2);
                document.getElementById(targetunits[i]).innerText = targetslice;
            }
        }
    }

</script>
