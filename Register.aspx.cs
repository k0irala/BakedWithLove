using System;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class RegisterPage : Page
{
    private const int WelcomePoints = 50;

    protected void cvEmail_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = Convert.ToInt32(Db.Scalar("SELECT COUNT(*) FROM Users WHERE Email = @e", Db.Param("@e", args.Value.Trim()))) == 0;
    }

    protected void cvTerms_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = chkTerms.Checked;
    }

    protected void btnRegister_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        string salt, hash;
        Auth.HashPassword(txtPassword.Text, out salt, out hash);

        object newId = Db.Scalar(
            "INSERT INTO Users (FullName, Email, Phone, Address, PasswordSalt, PasswordHash, Role, LoyaltyPoints) " +
            "VALUES (@n, @e, @p, @a, @s, @h, 'Customer', @pts); SELECT CAST(SCOPE_IDENTITY() AS INT);",
            Db.Param("@n", txtName.Text.Trim()), Db.Param("@e", txtEmail.Text.Trim()), Db.Param("@p", txtPhone.Text.Trim()),
            Db.Param("@a", txtAddress.Text.Trim()), Db.Param("@s", salt), Db.Param("@h", hash), Db.Param("@pts", WelcomePoints));

        int userId = (int)newId;
        Db.Execute("INSERT INTO LoyaltyTransactions (UserID, Points, Description) VALUES (@u, @p, 'Welcome bonus')",
            Db.Param("@u", userId), Db.Param("@p", WelcomePoints));
        Notify.Send(userId, null, "Welcome to Baked With Love!",
            "Your account is ready. We've added " + WelcomePoints + " welcome points (worth Rs. " + WelcomePoints + ") to use on your first order.", true);

        Auth.SignIn(userId, txtName.Text.Trim(), "Customer", false);
        Flash.Set("Welcome, " + txtName.Text.Trim() + "! Your account has been created.", true);

        string returnUrl = Request.QueryString["ReturnUrl"];
        if (!string.IsNullOrEmpty(returnUrl) && returnUrl.StartsWith("/") && !returnUrl.StartsWith("//"))
            Response.Redirect(returnUrl);
        else
            Response.Redirect("~/Menu.aspx");
    }
}
