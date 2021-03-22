<%@ Page Language="C#" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Windows.Forms" %>


<!DOCTYPE html>

<script runat="server">

    public static string connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" + "Data Source=" + System.Web.HttpContext.Current.Server.MapPath("Database.accdb") + ";";
    public static String cmdString = ("SELECT Speedruns.UserID, Speedruns.TimeUI, Speedruns.Category, Speedruns.isVerified, Speedruns.isHidden, " +
                "Users.ID, Users.Username, " +
                "Categories.ID, Categories.Category, Games.ID, Games.Game, Speedruns.Category " +
                "FROM ((Users INNER JOIN Speedruns ON Users.[ID] = Speedruns.[UserID]) " +
                "INNER JOIN Categories ON Speedruns.[Category] = Categories.[ID]) " +
                "INNER JOIN Games ON Categories.Game = Games.ID " +
                "WHERE (((Speedruns.isVerified)=False) AND ((Speedruns.isHidden)=False));");
    BindingSource adminBindSrc = new BindingSource();
    DataGridView dataGridView = new DataGridView();
    OleDbDataAdapter dataAdapter;

    private void Page_Load() {

        //if (!this.Page.User.Identity.IsAuthenticated)
        //{
        //    FormsAuthentication.RedirectToLoginPage();
        //}
        //else
        //{
        loggedIn.InnerText = "Logged in as: " + User.Identity.Name;


        //    if (Session["isAdmin"].ToString() != "True")
        //    {
        //        Response.Redirect("/home.aspx");
        //    }

        //displayGridView.DataSource = adminBindSrc;

        //}
    }
    public void GetData(string selectCommand)
    {
        using (OleDbConnection con = new OleDbConnection(connectionString))
        {
            dataAdapter = new OleDbDataAdapter(selectCommand, con);

            //make a new datatable + bind to bindingsource
            DataTable dataTable = new DataTable();
            //{
            //    Locale = CultureInfo.InvariantCulture
            //};
            dataAdapter.Fill(dataTable);
            //adminBindSrc.DataSource = dataTable;

            //dataGridView.AutoResizeColumns(
            //    DataGridViewAutoSizeColumnsMode.AllCellsExceptHeader);

            //set datagridview to take from bindingsource
            //dataGridView.DataSource = adminBindSrc;
            //displayGridView.DataSource = dataTable;
            //displayGridView.DataBind();
            leaderboard.DataSource = dataTable;
            leaderboard.DataBind();
        }
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
    <form id="form1" runat="server">
        hello
        <div>
            <asp:DataGrid runat="server" ID="leaderboard" AutoGenerateColumns="false">
                <Columns>
                    <asp:BoundColumn DataField="Username"
                        HeaderText="Username"></asp:BoundColumn>
                    <asp:BoundColumn 
                        DataField="TimeUI"
                        HeaderText="Time"></asp:BoundColumn>
                </Columns>
            </asp:DataGrid>
            

            <asp:GridView ID="displayGridView" runat="server" AutoGenerateColumns="False" DataKeyNames="UserID" DataSourceID="SqlDataSource1" >
                <Columns>

                    <asp:BoundField DataField="Users.ID" HeaderText="ID" InsertVisible="False" ReadOnly="True" SortExpression="ID" />
                    <asp:BoundField DataField="Game" HeaderText="Game" SortExpression="Game" />
                    <asp:BoundField DataField="Categories.Category" HeaderText="Category" SortExpression="Categories.Category" />
                    <asp:CheckBoxField DataField="isVerified" HeaderText="Approve" SortExpression="isVerified" />

                </Columns>
            </asp:GridView>
            <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
                ConnectionString="<%$ ConnectionStrings:ConnectionString %>" 
                ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" 
                SelectCommand="SELECT Speedruns.UserID, Speedruns.TimeUI, Speedruns.Category, Speedruns.isVerified, Speedruns.isHidden, Users.ID, Users.Username, Categories.ID, Categories.Category, Games.ID, Games.Game, Speedruns.Category FROM ((Users INNER JOIN Speedruns ON Users.[ID] = Speedruns.[UserID]) 
                INNER JOIN Categories ON Speedruns.[Category] = Categories.[ID])
                INNER JOIN Games ON Categories.Game = Games.ID
                WHERE (((Speedruns.isVerified)=False) AND ((Speedruns.isHidden)=False));">

            </asp:SqlDataSource>
        </div>
    </form>
</body>
</html>
