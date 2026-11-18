using System.Web;

/// <summary>One-time message shown at the top of the next page (e.g. "Added to cart").</summary>
public static class Flash
{
    public static void Set(string message, bool success)
    {
        HttpContext.Current.Session["FlashMsg"] = message;
        HttpContext.Current.Session["FlashOk"] = success;
    }

    /// <summary>Returns the HTML for the pending message (if any) and clears it.</summary>
    public static string Take()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx.Session == null || ctx.Session["FlashMsg"] == null) return "";
        string msg = HttpUtility.HtmlEncode((string)ctx.Session["FlashMsg"]);
        bool ok = (bool)ctx.Session["FlashOk"];
        ctx.Session.Remove("FlashMsg");
        ctx.Session.Remove("FlashOk");
        return "<div class=\"alert " + (ok ? "alert-success" : "alert-error") + " pop\" role=\"status\">" + msg + "</div>";
    }
}
