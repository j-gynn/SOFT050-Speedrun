<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>

<script runat="server">
    protected string uiTime = "";

    public static string connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" + "Data Source=" + System.Web.HttpContext.Current.Server.MapPath("assets/Database.accdb") + ";";
    public static bool firstRun = true;
    public static DataSet catDataSet = new DataSet();
    public static DataSet gamesDataSet = new DataSet();



    private void Page_Load() {
        
        if (!this.Page.User.Identity.IsAuthenticated)
        {
            FormsAuthentication.RedirectToLoginPage();
        }

        if (Session["saveTime"] == null)
        {
            Response.Redirect("/home.aspx");
        }

        else if (!IsPostBack)
        {
            using (OleDbConnection con = new OleDbConnection(connectionString))
            {
                OleDbDataAdapter da = new OleDbDataAdapter("SELECT * FROM Games", con);

                da.Fill(gamesDataSet);

                DataView view = gamesDataSet.Tables[0].DefaultView;
                view.Sort = "Game ASC";
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
        if (firstRun == true)
        {
            
            using (OleDbConnection con = new OleDbConnection(connectionString))
            {
                String cmdString = ("SELECT * FROM Categories");
                OleDbDataAdapter da = new OleDbDataAdapter(cmdString, con);
                da.Fill(catDataSet);
                firstRun = false;
            }
        }
        DataView view = catDataSet.Tables[0].DefaultView;
        view.Sort = "Category ASC";
        view.RowFilter = "Game = '" + origin.SelectedItem.Value + "'";
        catSelect.DataSource = catDataSet.Tables[0];
        catSelect.DataValueField = "ID";
        catSelect.DataTextField = "Category";
        catSelect.DataBind();
        catSelect.Items.Insert(0, new ListItem() { Text = "Select a category", Value = "0" });
        catSelect.Enabled = origin.SelectedValue != "0" ? true : false;
    }

    private void btnSubmit_onClick(object sender, EventArgs e)
    {
        this.uiTime = Request.Form["databaseTime"].ToString();
        string getTime = Session["saveTime"].ToString();
        int saveTime = Convert.ToInt32(getTime);
        using (OleDbConnection connection = new OleDbConnection(connectionString))
        using (OleDbCommand cmd = new OleDbCommand("INSERT INTO Speedruns ([UserID],[Time],[TimeUI],[Category]) " + "VALUES (?, ?, ?, ?)", connection))
        {
            Button origin = sender as Button;
            cmd.Parameters.Add("@UserID", OleDbType.BigInt).Value =
                Convert.ToInt32 (Session["UserID"]);
            cmd.Parameters.Add("@Time", OleDbType.BigInt).Value =
                saveTime;
            cmd.Parameters.Add("@TimeUI", OleDbType.Char).Value =
                this.uiTime;
            cmd.Parameters.Add("@Category", OleDbType.BigInt).Value =
                Convert.ToInt32(catSelect.SelectedItem.Value);

            connection.Open();

            try
            {
                cmd.ExecuteNonQuery();
                Session["Message"] = "Success! Your time has been added. Please note, it may take some time for your submission to appear on the leaderboard.";
                Response.Redirect("/home.aspx");
            }
            catch
            {
                complete.InnerHtml = "Something went wrong. Please try again later.";
            }
        }
    }

</script>

<DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <title>Save your time</title>
    </head>
    <body onload="calculateTimes()">
            <nav>
                <a href="home.aspx">Home</a>
                <a href="leaderboard.aspx">Leaderboard</a>
                <a href="admin.aspx">Admin</a>
            </nav>
        <form id="saveTime" runat="server">
            <div>
                <h1>Save your time</h1>
                <a></a>
                <a>The time you wish to save is: </a>
                <a id="timeToSave"></a>
                <input type="hidden" id="database_Time" name="databaseTime" value="<%=this.uiTime %>" />
            </div>
            <div>
                <a>Please select the game you have been playing.</a>
                <asp:DropDownList AutoPostBack="true" ID="gameSelect" runat="server" OnSelectedIndexChanged="gameSelect_SelectedIndexChanged"></asp:DropDownList>
            </div>
            <div>
                <a>Now, select the category you have been playing.</a>
                <asp:DropDownList ID="catSelect" runat="server"></asp:DropDownList>
            </div>
            <div>
                <asp:Button ID="send" runat="server" OnClick="btnSubmit_onClick" Text="Submit" />
            </div>
            <div>
                <a id="complete" runat="server"></a>
            </div>
        </form>
    </body>
</html>

<script>
    var units = ["hours", "minutes", "seconds", "milliseconds"];
    var zeros = "0000";
    var finalTime = "";
    var database_Time;


    function calculateTimes() {
        // For testing purposes, to ensure that a number always appears (this helps make sure everything is as it should be)
        if (sessionStorage.getItem("saveTime") != undefined) {
            var difference = sessionStorage.getItem("saveTime");
        } else {
            var difference = 3661001;
        }
       

        var timing = {
            hours: Math.floor(difference / (1000 * 60 * 60) % 24),
            minutes: Math.floor(difference / (1000 * 60) % 60),
            seconds: Math.floor((difference / 1000) % 60),
            milliseconds: Math.floor(difference % 1000)
        }
        var i;
        for (i = 0; i < 4; i++) {
            var addZeros = zeros.concat(timing[units[i]]);
            sliceZeros = addZeros.slice((i >= 3) ? -3 : -2);
            timing[units[i]] = sliceZeros;
            finalTime = finalTime.concat(sliceZeros);
            if (i <= 1) {
                finalTime = finalTime.concat(":");
            }
            if (i == 2) {
                finalTime = finalTime.concat(".");
            }
        }
        document.getElementById("timeToSave").innerHTML = finalTime;
        document.getElementById("database_Time").value = finalTime;
    }
</script>
