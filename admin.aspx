<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Windows.Forms" %>


<!DOCTYPE html>

<script runat="server">

    public static string connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" + "Data Source=" + System.Web.HttpContext.Current.Server.MapPath("Database.accdb") + ";";
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
                //verify_username.InnerText = "YourMom69";
                //verify_time.InnerText = "00:06:54.321";
                //verify_game.InnerText = "Bioshock";
                //verify_category.InnerText = "Any%";
            }
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
                    form1.Visible = false;
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


                con.Close();
            }
        }

        public void btnApprove_onClick(object sender, EventArgs e)
        {
            //String cmdString = "UPDATE Speedruns SET isVerified = True WHERE Speedruns.ID = " + currentID;
            //using (OleDbConnection con = new OleDbConnection(connectionString))
            //{
            //    OleDbCommand command = new OleDbCommand(cmdString, con);
            //    con.Open();
            //    command.ExecuteNonQuery();
            //    con.Close();
            //}
            updateRecord("isVerified");
            GetData();
        }

        public void btnDeny_onClick(object sender, EventArgs e)
        {
            //String cmdString = "UPDATE Speedruns SET isHidden = True WHERE Speedruns.ID = " + currentID;
            //using (OleDbConnection con = new OleDbConnection(connectionString))
            //{
            //    OleDbCommand command = new OleDbCommand(cmdString, con);
            //    con.Open();
            //    command.ExecuteNonQuery();
            //    con.Close();
            //}
            updateRecord("isHidden");
            GetData();
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
    <p id="verify_empty" runat="server"></p>
    <form id="form1" runat="server">
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
    </form>
</body>
</html>
