using System;
using System.IO;
using System.Web.UI;

public partial class SiteMaster : MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        bool loggedIn = Auth.IsLoggedIn;
        phGuest.Visible = phMobileGuest.Visible = !loggedIn;
        phMember.Visible = phMobileMember.Visible = lnkLogout.Visible = loggedIn;
        phAdminLink.Visible = phMobileAdmin.Visible = Auth.IsAdmin;
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        // Done in PreRender so the count is correct after "Add to cart" button clicks
        int count = Shop.CartCount(Auth.UserId);
        lblCartCount.Visible = lblCartCount2.Visible = count > 0;
        lblCartCount.Text = lblCartCount2.Text = count.ToString();
    }

    /// <summary>Returns "active" when the current page is one of the given file names.</summary>
    protected string Active(params string[] pages)
    {
        string current = Path.GetFileName(Request.Path);
        foreach (string p in pages)
        {
            if (string.Equals(p, current, StringComparison.OrdinalIgnoreCase)) return "active";
        }
        return "";
    }

    protected void Logout_Click(object sender, EventArgs e)
    {
        Auth.SignOut();
        Response.Redirect("~/Default.aspx");
    }
}
