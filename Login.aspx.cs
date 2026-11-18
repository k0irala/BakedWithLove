using System;
using System.Data;
using System.Web.Security;
using System.Web.UI;

public partial class LoginPage : Page
{
    protected string ReturnQuery
    {
        get
        {
            string r = Request.QueryString["ReturnUrl"];
            return string.IsNullOrEmpty(r) ? "" : "?ReturnUrl=" + Server.UrlEncode(r);
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;

        if (Auth.IsLoggedIn && !string.IsNullOrEmpty(Request.QueryString["ReturnUrl"]))
        {
            // Logged in but sent here by Forms Authentication = not allowed (e.g. a customer opening an admin page)
            lblInfo.Text = "Your account does not have access to that page. Log in with an admin account to continue.";
            lblInfo.Visible = true;
        }
        else if (!string.IsNullOrEmpty(Request.QueryString["ReturnUrl"]))
        {
            lblInfo.Text = "Please log in to continue.";
            lblInfo.Visible = true;
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        DataRow u = Db.Row("SELECT UserID, FullName, PasswordSalt, PasswordHash, Role, IsActive FROM Users WHERE Email = @e",
            Db.Param("@e", txtEmail.Text.Trim()));

        if (u == null || !Auth.VerifyPassword(txtPassword.Text, u["PasswordSalt"].ToString(), u["PasswordHash"].ToString()))
        {
            lblError.Text = "Incorrect email or password.";
            lblError.Visible = true;
            return;
        }
        if (!(bool)u["IsActive"])
        {
            lblError.Text = "This account has been deactivated. Please contact the bakery.";
            lblError.Visible = true;
            return;
        }

        string role = u["Role"].ToString();
        Auth.SignIn((int)u["UserID"], u["FullName"].ToString(), role, chkRemember.Checked);

        string returnUrl = Request.QueryString["ReturnUrl"];
        if (!string.IsNullOrEmpty(returnUrl) && returnUrl.StartsWith("/") && !returnUrl.StartsWith("//"))
            Response.Redirect(returnUrl);
        else
            Response.Redirect(role == "Admin" ? "~/Admin/Dashboard.aspx" : FormsAuthentication.DefaultUrl);
    }
}
