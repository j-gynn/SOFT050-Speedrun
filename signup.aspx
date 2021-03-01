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
            Session["username"] = username;
            Response.Redirect("~/home.aspx");

        } else
        {
            parData.InnerHtml = "Username or password not recognised.";
        }
        connection.Close();
    }
</script>

<html>
    <body>
        <form id="register" runat="server">
            <label><b>Username</b></label>
            <asp:TextBox ID="username" placeholder="Username" runat="server" TextMode="SingleLine" required="true"></asp:TextBox>

            <label><b>Password</b></label>
            <asp:TextBox ID="password" placeholder="Password" required="true" runat="server" TextMode="Password"></asp:TextBox>

            <asp:Button ID="Button1" runat="server" BorderStyle="None" Font-Size="X-Large" OnClick="btnLogin_onClick" Text="Log In" />
            <label>
                <input type="checkbox" checked="checked" name="rememberMe" /> Remember me
            </label>
        </form>
        <a id="parData" runat="server"></a>

        <div>
            <span>Not a member? <a href="signup.aspx">Sign up now.</a></span>
        </div>

        <div class="container" style="background-color:#f1f1f1">
            <button type="button" class="btnCancel">Cancel</button>
            <span class="forgotPwd">Forgot <a href="#">password?</a></span>
        </div>
    </body>
</html>