<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data.OleDb" %>

<script runat="server">
    private void btnLogin_onClick(object sender, EventArgs e)
    {
        String connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" +
                    "Data Source=" + Server.MapPath("Database.accdb") + ";";
        OleDbConnection connection = new OleDbConnection(connectionString);
        OleDbCommand cmd;
        OleDbDataReader r;
        String username = Request.Form["username"];
        String password = Request.Form["password"];
        String commandText = "SELECT * FROM Users WHERE Username = ? AND Password = ?";

        cmd = new OleDbCommand(commandText, connection);
        cmd.Parameters.Add(new OleDbParameter("Username", username));
        cmd.Parameters.Add(new OleDbParameter("Password", password));
        connection.Open();
        r = cmd.ExecuteReader();
        if (r.Read())
        {
            parData.InnerHtml = "Login Successful!";
            Session["UserID"] = r["ID"];
            FormsAuthentication.RedirectFromLoginPage(username, false);

        }
        else
        {
            parData.InnerHtml = "Username or password not recognised.";
        }
        connection.Close();
    }
</script>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="saveTime" runat="server">
        <div>
            <a>The time you wish to save is: </a>
            <a id="parData" runat="server"></a>
        </div>
    </form>
</body>
</html>

<script>
    var saveTime = sessionStorage.getItem("saveTime");
</script>
