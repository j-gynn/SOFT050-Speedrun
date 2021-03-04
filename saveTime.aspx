<%@ Page Language="C#" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>

<script runat="server">

    //public class GamesDatabase 


    void Page_Load() {
        if (!IsPostBack)
        {
            String connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" +
                        "Data Source=" + Server.MapPath("Database.accdb") + ";";

            using (OleDbConnection con = new OleDbConnection(connectionString))
            {
                OleDbDataAdapter da = new OleDbDataAdapter("SELECT * FROM Games", con);

                DataSet dataset = new DataSet();
                da.Fill(dataset);

                DataView view = dataset.Tables[0].DefaultView;
                view.Sort = "Game ASC";
                gameSelect.DataSource = dataset.Tables[0];
                gameSelect.DataValueField = "ID"; // From the database
                gameSelect.DataTextField = "Game"; // Visible in UI
                gameSelect.DataBind();

                gameSelect.Items.Insert(0, new ListItem() { Text = "Select a game", Value = "0" });
                catSelect.Items.Insert(0, new ListItem() { Text = "Select a category", Value = "0" });
            }
        }
    }

    private void gameSelect_SelectedIndexChanged(object sender, EventArgs e)
    {
        String connectionString = "Provider=Microsoft.ACE.OLEDB.12.0;" +
                        "Data Source=" + Server.MapPath("Database.accdb") + ";";

        using (OleDbConnection con = new OleDbConnection(connectionString))
        {
            DropDownList origin = sender as DropDownList;
            String cmdString = ("SELECT * FROM Categories WHERE Game = '"+origin.SelectedItem.Value+"'");
            OleDbDataAdapter da = new OleDbDataAdapter(cmdString, con);

            DataSet dataset = new DataSet();
            da.Fill(dataset);

            DataView view = dataset.Tables[0].DefaultView;
            view.Sort = "Category ASC";
            catSelect.DataSource = dataset.Tables[0];
            catSelect.DataValueField = "ID"; // From the database
            catSelect.DataTextField = "Category"; // Visible in UI
            catSelect.DataBind();
            catSelect.Items.Insert(0, new ListItem() { Text = "Select a category", Value = "0" });

        }
    }

</script>

<DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
        <title></title>
    </head>
    <body onload="calculateTimes()">
        <form id="saveTime" runat="server">
            <div>
                <a id="test" runat="server"></a>
                <a>The time you wish to save is: </a>
                <a id="timeToSave">
                </a>
            </div>
            <div>
                <a>Please select the game you have been playing.</a>
                <asp:DropDownList AutoPostBack="true" ID="gameSelect" runat="server" onchange="dropDownEnabled()" OnSelectedIndexChanged="gameSelect_SelectedIndexChanged"></asp:DropDownList>
            </div>
            <div>
                <a>Now, select the category you have been playing.</a>
                <asp:DropDownList AutoPostBack="true" ID="catSelect" runat="server"></asp:DropDownList>
            </div>
        </form>
    </body>
</html>

<script>
    var units = ["hours", "minutes", "seconds", "milliseconds"];
    var zeros = "0000";
    var finalTime = "";


    function calculateTimes() {
        // For testing purposes, to ensure that a number always appears (this helps make sure everything is as it should be)
        if (sessionStorage.getItem("saveTime") != undefined) {
            var difference = sessionStorage.getItem("saveTime");
        } else {
            var difference = 3661001; // FOR TESTING - One hour, one minute, one second and one millisecond (in milliseconds)
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
    }

    function dropDownEnabled() {
        var option = gameSelect.options[gameSelect.selectedIndex].value;
        var catSelect = document.getElementById("catSelect");
        catSelect.disabled = option == 0 ? true : false;
    }
</script>
