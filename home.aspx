<%@ Page Language="C#" %>
<script runat="server">
    //Commented out to avoid having to authenticate* every time* I test something new
    protected string difference = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        this.difference = Request.Form["saveTime"];

        if (!Page.User.Identity.IsAuthenticated)
        {
            FormsAuthentication.RedirectToLoginPage();
        }

        if (Session["Message"] != null)
        {
            message.InnerText = Session["Message"].ToString();
        }
    }

    private void btnSave_onClick(object sender, EventArgs e)
    {
        String timeToSave = this.difference;
        Session["saveTime"] = timeToSave;
        Response.Redirect("/saveTime.aspx");
    }

</script>


<html lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8" />
    <title>Speedrun Timer</title>
</head>
<body onload="window_onLoad()">
    <div>
        <h1>Speedrunning</h1>
        <p id="message" runat="server"></p>
        <form runat="server">
            <p id="test" runat="server"></p>
            <p>
                <a id="hours">00</a>
                <a>:</a>
                <a id="minutes">00</a>
                <a>:</a>
                <a id="seconds">00</a>
                <a>.</a>
                <a id="milliseconds">000</a>
            </p>
            <button id="btnStart" onclick="btnStart_onClick()" type="button">Start timer</button> 
            <button id="btnStop" onclick="btnStop_onClick()" type="button" disabled>Stop timer</button>
            <a></a>
            <button id="btnReset" onclick="btnReset_onClick()" type="button" disabled>Reset</button>
            <asp:button id="btnSave" onclick="btnSave_onClick" runat="server" disabled="true" Text="Save"></asp:button>
            <input type="hidden" id="saveTime" name="saveTime" value="<%=this.difference %>" />
        </form>
    </div>
</body>
</html>

<script>
    var difference;
    var len_req = [-3, -2, -2, -2]; //Used for calculating decimal places of time display
    var refresh = 1; // How often the timer refreshes
    var running = false;
    var timeNow;
    var timeStart;
    var timeEnd;
    var timing = {
        hours: 0,
        minutes: 0,
        seconds: 0,
        milliseconds: 0
    };
    var units = ["hours", "minutes", "seconds", "milliseconds"];
    var zeros = "0000";


    function window_onLoad() {
        window.setInterval("stopwatch()", refresh);

    }
    
    function btnStart_onClick() {
        timeStart = new Date().getTime();
        document.getElementById("btnStop").disabled = false;
        document.getElementById("btnStart").disabled = true;
        running = true;
    }

    function btnStop_onClick() {
        document.getElementById("btnStop").disabled = true;
        document.getElementById("btnReset").disabled = false;
        document.getElementById("btnSave").disabled = false;
        running = false;
        sessionStorage.setItem("saveTime", difference);
        document.getElementById("saveTime").value = difference;
    }

    function btnReset_onClick() {
        document.getElementById("btnStart").disabled = false;
        document.getElementById("btnReset").disabled = true;
        document.getElementById("btnSave").disabled = true;
        difference = 0;
        calculateTimes();
    }

    function stopwatch() {
        if (running == true) {
            timeNow = new Date().getTime();
            difference = timeNow - timeStart;
            calculateTimes();
        }
    }

    function calculateTimes() {
        //difference = 3661001; // FOR TESTING - One hour, one minute, one second and one millisecond (in milliseconds)
        timing = {
            hours: Math.floor(difference / (1000 * 60 * 60) % 24),
            minutes: Math.floor(difference / (1000 * 60) % 60),
            seconds: Math.floor((difference / 1000) % 60),
            milliseconds: Math.floor(difference % 1000)
        }
        var i;
        for (i = 0; i < 4; i++) {
            res = zeros.concat(timing[units[i]]);
            correct = res.slice((i >= 3) ? -3 : -2);
            document.getElementById(units[i]).innerText = correct;
        }    
    }
</script>
