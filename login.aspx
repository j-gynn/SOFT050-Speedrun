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

<html>
    <head>
        <title>Log In</title>
        <style type="text/css">
        .hide {
            display: none;
        }
    
        .notAvailable:hover + .hide {
            display: block;
            color: red;
        }
        </style>
    </head>
    <body>
        <form id="login" runat="server">
            <label><b>Username</b></label>
            <asp:TextBox ID="username" placeholder="Username" required="true" runat="server" TextMode="SingleLine"></asp:TextBox>

            <label><b>Password</b></label>
            <asp:TextBox ID="password" placeholder="Password" required="true" runat="server" TextMode="Password"></asp:TextBox>

            <asp:Button ID="Button1" runat="server" BorderStyle="None" Font-Size="X-Large" OnClick="btnLogin_onClick" Text="Log In" />
            <br />
            <label>
                <input class="notAvailable" type="checkbox" checked="checked" name="rememberMe" /> Remember me
                <a class="hide">Note: This feature is not available in the current build.</a>
            </label>
        </form>
        <a id="parData" runat="server"></a>

        <div>
            <div>Not a member? <a href="#" class="notAvailable">Sign up now.</a><a class="hide">Note: This feature is not available in the current build.</a></div>
        </div>

        <div class="container" style="background-color:#f1f1f1">
            <button type="button" id="btnCancel" disabled>Cancel</button>
            <span class="forgotPwd">Forgot <a href="#" class="notAvailable">password?</a> <a class="hide">Note: This feature is not available in the current build.</a></span>
        </div>
    </body>
</html>
