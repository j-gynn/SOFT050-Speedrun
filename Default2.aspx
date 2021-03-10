<%@ Page Language="C#" %>

<!DOCTYPE html>

<script runat="server">
    protected string ArrayStore = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        this.ArrayStore = Request.Form["ArrayStore"];
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form runat="server">
        <span id="array_disp"></span>
        <br />
        <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClientClick="UpdateArray()" />
        <input type="hidden" id="array_store" name="ArrayStore" value="<%=this.ArrayStore %>" />
    </form>
</body>
</html>

<script type="text/javascript">
    var array_store;
    window.onload = function () {
        array_store = document.getElementById("array_store");
        document.getElementById("array_disp").innerHTML = array_store.value;
    };
    function UpdateArray() {
        var arr;
        if (array_store.value == "") {
            arr = new Array();
        } else {
            arr = array_store.value.split(",");
        }
        arr.push((arr.length + 1).toString());
        array_store.value = arr.join(", ");
    };
</script>
