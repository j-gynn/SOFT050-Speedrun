<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>

<!DOCTYPE html>

<script runat="server">
    public static string connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" + "Data Source=" + System.Web.HttpContext.Current.Server.MapPath("assets/Database.accdb") + ";";
    public static bool firstRunCat = true;
    public static bool firstRunGame = true;
    public static DataTable catDataSet = new DataTable();
    public static DataTable gamesDataSet = new DataTable();
    public static DataTable speedruns = new DataTable();


    private void Page_Load() {

        if (this.Page.User.Identity.IsAuthenticated)
        {
            loggedIn.InnerText = "Logged in as: " + User.Identity.Name;
            btnLogin.Visible = false;
            if (Session["isAdmin"].ToString() == "True")
            {
                isAdmin.Visible = true;
                isAdmin.InnerText = "Admin";
                isAdmin.HRef = "admin.aspx";
            } else
            {
                isAdmin.Visible = false;
            }
        }
        else
        {
            loggedIn.InnerHtml = "You are not currently logged in. <a id='btnLogin' href='login.aspx?ReturnUrl=%2fleaderboard.aspx' runat='server'>Log in now.</a>";
            btnLogin.Visible = true;

        }


        if (!IsPostBack)
        {
            using (OleDbConnection con = new OleDbConnection(connectionString))
            {
                OleDbDataAdapter da = new OleDbDataAdapter("SELECT * FROM Games", con);

                gamesDataSet.Clear();
                gameSelect.Items.Clear();

                da.Fill(gamesDataSet);

                DataView view = gamesDataSet.DefaultView;
                view.Sort = "Game ASC";
                gameSelect.DataSource = gamesDataSet;
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
        using (OleDbConnection con = new OleDbConnection(connectionString))
        {
            String cmdString = ("SELECT * FROM Categories");
            OleDbDataAdapter da = new OleDbDataAdapter(cmdString, con);
            catDataSet.Clear();
            da.Fill(catDataSet);
            firstRunGame = false;
        }

        leaderboard.Visible = false;
        no_data.InnerText = "";
        DataView view = catDataSet.DefaultView;

        view.Sort = "Category ASC";
        view.RowFilter = "Game = '" + origin.SelectedItem.Value + "'";
        catSelect.DataSource = catDataSet;
        catSelect.DataValueField = "ID";
        catSelect.DataTextField = "Category";
        catSelect.DataBind();
        catSelect.Items.Insert(0, new ListItem() { Text = "Select a category", Value = "0" });
        catSelect.Enabled = origin.SelectedValue != "0" ? true : false;
    }

    private void catSelect_SelectedIndexChanged(object sender, EventArgs e)
    {
        DropDownList origin = sender as DropDownList;
        using (OleDbConnection con = new OleDbConnection(connectionString))
        {
            speedruns.Clear();
            String cmdString = ("SELECT TOP 10 Speedruns.UserID, Speedruns.Time, Speedruns.TimeUI, Speedruns.Category, Speedruns.isVerified, Users.ID, Users.Username " +
                "FROM Users INNER JOIN Speedruns ON Users.[ID] = Speedruns.[UserID] " +
                "WHERE Category = ? AND isVerified = True " +
                "ORDER BY Speedruns.Time;");
            OleDbCommand command = new OleDbCommand(cmdString, con);
            command.Parameters.Add(
                "@Category", OleDbType.VarChar).Value = origin.SelectedItem.Value;
            OleDbDataAdapter da = new OleDbDataAdapter();
            da.SelectCommand = command;

            da.Fill(speedruns);

        }

        leaderboard.Visible = true;
        leaderboard.DataSource = speedruns;
        leaderboard.DataBind();
        if (speedruns.Rows.Count == 0)
        {
            leaderboard.Visible = false;
            no_data.InnerText = "There is no data available for this leaderboard at this time.";
        } else
        {
            leaderboard.Visible = true;
            no_data.InnerText = "";
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Leaderboards</title>
</head>
<body>
    <nav>
        <a href="home.aspx">Home</a>
        <a id="isAdmin" runat="server"></a>
        <p id="loggedIn" runat="server">
        <a id="btnLogin" href="login.aspx?ReturnUrl=%2fleaderboard.aspx" runat="server">Log in now.</a>
        </p>
    </nav>
    <form id="form1" runat="server">
        <div>
            <h1>Leaderboards</h1>
            <a>Select a category to view leaderboards.</a>
            <br />
            <asp:DropDownList AutoPostBack="true" ID="gameSelect" runat="server" OnSelectedIndexChanged="gameSelect_SelectedIndexChanged"></asp:DropDownList>
            <asp:DropDownList AutoPostBack="true" ID="catSelect" runat="server" OnSelectedIndexChanged="catSelect_SelectedIndexChanged"></asp:DropDownList>
            <p></p>
            <asp:DataGrid runat="server" ID="leaderboard" AutoGenerateColumns="false">
                <Columns>
                    <asp:BoundColumn DataField="Username"
                        HeaderText="Username"></asp:BoundColumn>
                    <asp:BoundColumn 
                        DataField="TimeUI"
                        HeaderText="Time"></asp:BoundColumn>
                </Columns>
            </asp:DataGrid>
            <p id="no_data" runat="server"></p>
        </div>
    </form>
</body>
</html>
