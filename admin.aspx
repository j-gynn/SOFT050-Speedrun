<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Windows.Forms" %>


<!DOCTYPE html>

<script runat="server">

    public static string connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" + "Data Source=" + System.Web.HttpContext.Current.Server.MapPath("assets/Database.accdb") + ";";
    public int currentID = 0;

    private void Page_Load() {

        if (!this.Page.User.Identity.IsAuthenticated)
        {
            FormsAuthentication.RedirectToLoginPage();
        }
        else
        {
            loggedIn.InnerText = "Logged in as: " + User.Identity.Name;
            if (Session["isAdmin"].ToString() != "True")
            {
                Response.Redirect("/home.aspx");
            }
            GetData();
        }
    }

    public void btnApprove_onClick(object sender, EventArgs e)
    {
        updateRecord("isVerified");
        GetData();
    }

    public void btnDeny_onClick(object sender, EventArgs e)
    {
        updateRecord("isHidden");
        GetData();
    }

    public void GetData()
    {
        using (OleDbConnection con = new OleDbConnection(connectionString))
        {
            String cmdString = ("SELECT TOP 1 Speedruns.ID, Speedruns.UserID, Speedruns.TimeUI, Speedruns.Category, Speedruns.isVerified, Speedruns.isHidden, " +
                "Users.ID, Users.Username, " +
                "Categories.ID, Categories.Category, Games.ID, Games.Game, Speedruns.Category " +
                "FROM ((Users INNER JOIN Speedruns ON Users.[ID] = Speedruns.[UserID]) " +
                "INNER JOIN Categories ON Speedruns.[Category] = Categories.[ID]) " +
                "INNER JOIN Games ON Categories.Game = Games.ID " +
                "WHERE (((Speedruns.isVerified)=False) AND ((Speedruns.isHidden)=False));");

            OleDbCommand command = new OleDbCommand(cmdString, con);
            OleDbDataReader r;
            con.Open();
            r = command.ExecuteReader();
            if (!r.HasRows) {
                verify_empty.InnerHtml = "No more records to show. <a href='home.aspx'>Return to home.</a>";
                approveTimes.Visible = false;
            } else {
                while (r.Read())
                {
                    verify_username.InnerHtml = r["Username"].ToString();
                    verify_time.InnerText = r["TimeUI"].ToString();
                    verify_game.InnerText = r["Game"].ToString();
                    verify_category.InnerText = r["Categories.Category"].ToString();
                    currentID = Convert.ToInt32(r["Speedruns.ID"]);
                }
            }

            cmdString = ("SELECT Users.ID, Users.Username, Users.isAdmin FROM Users");
            command = new OleDbCommand(cmdString, con);
            r = command.ExecuteReader();
            if (!r.HasRows)
                {
                    
                }

            con.Close();
        }
    }

    public void updateRecord(string changeVar)
    {
        String cmdString = "UPDATE Speedruns SET " + changeVar + " = True WHERE Speedruns.ID = " + currentID;
        using (OleDbConnection con = new OleDbConnection(connectionString))
        {
            OleDbCommand command = new OleDbCommand(cmdString, con);
            con.Open();
            command.ExecuteNonQuery();
            con.Close();
        }
        //test
        GetData();
    }


    public void btnAdminPromote_onClick(object sender, EventArgs e)
    {
        //test
    }

    public void btnAdminDemote_onClick(object sender, EventArgs e)
    {
        //test
    }

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>

<body>
    <nav>
        <a href="home.aspx">Home</a>
        <p id="loggedIn" runat="server"></p>
    </nav>
    <h1>Admin Console</h1>
    
    <form id="form1" runat="server">
        <h3>Approve times</h3>
        <p id="verify_empty" runat="server"></p>
        <div id="approveTimes" runat="server">
            <table>
            <tbody>
                <tr>
                    <td>
                        <b>User:</b> <span id="verify_username" runat="server"></span>
                    </td>
                    <td>
                        <b>Time:</b> <span id="verify_time" runat="server"></span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <b>Game:</b> <span id="verify_game" runat="server"></span>
                    </td>
                    <td>
                        <b>Category:</b> <span id="verify_category" runat="server"></span>
                    </td>
                </tr>
                <tr>
                    <td style="text-align:right">
                        <button type="button" id="btnApprove" runat="server" onserverclick="btnApprove_onClick">Approve</button>
                    </td>
                    <td style="text-align:left">
                        <button type="button" id="btnDeny" runat="server" onserverclick="btnDeny_onClick">Deny</button>
                    </td>
                </tr>
            </tbody>
            </table>
        </div>

        <h3>Promote a user to admin</h3>
        <asp:DropDownList ID="adminPromoteList" runat="server"></asp:DropDownList>
        <button runat="server" type="submit" id="btnAdminPromote" onserverclick="btnAdminPromote_onClick">Promote to Admin</button>

        <h3>Demote an admin to user</h3>
        <asp:DropDownList ID="adminDemoteList" runat="server"></asp:DropDownList>
        <button runat="server" type="submit" id="btnAdminDemote" onserverclick="btnAdminDemote_onClick">Promote to Admin</button>
    </form>
</body>
</html>
