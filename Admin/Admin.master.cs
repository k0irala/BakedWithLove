using System;
using System.IO;
using System.Web.UI;

public partial class Admin_AdminMaster : MasterPage
{
    protected string PendingBadge = "";
    protected string CustomBadge = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Web.config already blocks non-admins; this is a second line of defence
        if (!Auth.IsAdmin) Response.Redirect("~/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl));
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        int pending = Convert.ToInt32(Db.Scalar("SELECT COUNT(*) FROM Orders WHERE Status = 'Pending'"));
        int custom = Convert.ToInt32(Db.Scalar("SELECT COUNT(*) FROM CustomOrders WHERE Status IN ('Pending Review', 'Accepted')"));
        if (pending > 0) PendingBadge = " <span class=\"badge badge-pending\">" + pending + "</span>";
        if (custom > 0) CustomBadge = " <span class=\"badge badge-pending\">" + custom + "</span>";
    }

    protected string Active(string page)
    {
        return string.Equals(Path.GetFileName(Request.Path), page, StringComparison.OrdinalIgnoreCase) ? "active" : "";
    }

    protected void lnkLogout_Click(object sender, EventArgs e)
    {
        Auth.SignOut();
        Response.Redirect("~/Default.aspx");
    }
}
