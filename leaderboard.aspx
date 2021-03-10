<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>

<!DOCTYPE html>

<script runat="server">
    public static class Global
    {
        public static string connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" + "Data Source=" + System.Web.HttpContext.Current.Server.MapPath("Database.accdb") + ";";
        public static bool firstRunCat = true;
        public static bool firstRunGame = true;
        public static DataTable catDataSet = new DataTable();
        public static DataTable gamesDataSet = new DataTable();
        public static DataTable speedruns = new DataTable();
    }

    private void Page_Load() {
        //if (!this.Page.User.Identity.IsAuthenticated)
        //{
        //    FormsAuthentication.RedirectToLoginPage();
        //}
        //else

        if (!IsPostBack)
        {
            using (OleDbConnection con = new OleDbConnection(Global.connectionString))
            {
                OleDbDataAdapter da = new OleDbDataAdapter("SELECT * FROM Games", con);

                gameSelect.Items.Clear();

                da.Fill(Global.gamesDataSet);

                DataView view = Global.gamesDataSet.DefaultView;
                view.Sort = "Game ASC";
                gameSelect.DataSource = Global.gamesDataSet;
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
        if (Global.firstRunGame == true)
        {
            using (OleDbConnection con = new OleDbConnection(Global.connectionString))
            {
                String cmdString = ("SELECT * FROM Categories");
                OleDbDataAdapter da = new OleDbDataAdapter(cmdString, con);
                da.Fill(Global.catDataSet);
                Global.firstRunGame = false;
            }
        }
        DataView view = Global.catDataSet.DefaultView;
        view.Sort = "Category ASC";
        view.RowFilter = "Game = '" + origin.SelectedItem.Value + "'";
        catSelect.DataSource = Global.catDataSet;
        catSelect.DataValueField = "ID";
        catSelect.DataTextField = "Category";
        catSelect.DataBind();
        catSelect.Items.Insert(0, new ListItem() { Text = "Select a category", Value = "0" });
        catSelect.Enabled = origin.SelectedValue != "0" ? true : false;
    }

    private void catSelect_SelectedIndexChanged(object sender, EventArgs e)
    {
        DropDownList origin = sender as DropDownList;
        if (Global.firstRunCat == true)
        {
            using (OleDbConnection con = new OleDbConnection(Global.connectionString))
            {
                String cmdString = ("SELECT Speedruns.UserID, Speedruns.Time, Speedruns.TimeUI, Speedruns.Category, Speedruns.isVerified, Users.ID, Users.Username " +
                    "FROM Users INNER JOIN Speedruns ON Users.[ID] = Speedruns.[UserID];");
                OleDbDataAdapter da = new OleDbDataAdapter(cmdString, con);
                da.Fill(Global.speedruns);
                Global.firstRunCat = false;
            }
        }
        DataView view = Global.speedruns.DefaultView;
        view.Sort = "Time ASC";
        view.RowFilter = "Category = '" + origin.SelectedItem.Value + "'";
        leaderboard.DataSource = Global.speedruns;
        leaderboard.DataBind();
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Leaderboards</title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div>
                <h1>Leaderboards</h1>
                <a>Select a category to view leaderboards.</a>
                <br />
                <asp:DropDownList AutoPostBack="true" ID="gameSelect" runat="server" OnSelectedIndexChanged="gameSelect_SelectedIndexChanged"></asp:DropDownList>
                <asp:DropDownList AutoPostBack="true" ID="catSelect" runat="server" OnSelectedIndexChanged="catSelect_SelectedIndexChanged"></asp:DropDownList>

                <p>Here's where the leaderboard will eventually be :)</p>
                <asp:DataGrid runat="server" ID="leaderboard" AutoGenerateColumns="false">
                    <Columns>
                        <asp:BoundColumn DataField="Username"
                            HeaderText="Username"></asp:BoundColumn>
                        <asp:BoundColumn DataField="TimeUI"
                            HeaderText="Time"></asp:BoundColumn>
                    </Columns>
                </asp:DataGrid>
            </div>
        </div>
    </form>
</body>
</html>
