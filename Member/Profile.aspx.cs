using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Member_Profile : Page
{
    protected int TierProgress;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DataRow u = Db.Row("SELECT FullName, Email, Phone, Address FROM Users WHERE UserID = @u", Db.Param("@u", Auth.UserId));
            txtName.Text = u["FullName"].ToString();
            txtEmail.Text = u["Email"].ToString();
            txtPhone.Text = Convert.ToString(u["Phone"]);
            txtAddress.Text = Convert.ToString(u["Address"]);
            BindPoints();
            BindNotices();
        }
        litName.Text = Server.HtmlEncode(txtName.Text.Split(' ')[0]);
        BindLoyaltyCard();
    }

    private void BindLoyaltyCard()
    {
        int points = Convert.ToInt32(Db.Scalar("SELECT LoyaltyPoints FROM Users WHERE UserID = @u", Db.Param("@u", Auth.UserId)));
        string tier = Shop.Tier(points);
        int next = Shop.NextTierAt(points);
        litPoints.Text = points.ToString();
        litPointsValue.Text = Shop.Money(points);
        lblTier.Text = (tier == "Gold" ? "&#127942; " : tier == "Silver" ? "&#129352; " : "&#129353; ") + tier + " member";
        lblTier.CssClass = "badge badge-" + tier.ToLower();
        litNextTier.Text = next == 0 ? "You've reached our top tier. Thank you for your love!" :
            (next - points) + " more points to reach " + (next == 200 ? "Silver" : "Gold") + ". Earn 1 point for every Rs. 100 spent.";
        TierProgress = next == 0 ? 100 : (int)(points * 100.0 / next);
    }

    private void BindPoints()
    {
        gvPoints.DataSource = Db.Query("SELECT CreatedAt, Description, Points FROM LoyaltyTransactions WHERE UserID = @u ORDER BY CreatedAt DESC", Db.Param("@u", Auth.UserId));
        gvPoints.DataBind();
    }

    private void BindNotices()
    {
        DataTable t = Db.Query("SELECT TOP 10 NotificationID, OrderID, Title, Message, Channel, IsRead, CreatedAt FROM Notifications WHERE UserID = @u ORDER BY CreatedAt DESC", Db.Param("@u", Auth.UserId));
        rptNotices.DataSource = t;
        rptNotices.DataBind();
        lblNoNotices.Visible = t.Rows.Count == 0;
        lnkMarkRead.Visible = t.Select("IsRead = false").Length > 0;
    }

    protected void gvPoints_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvPoints.PageIndex = e.NewPageIndex;
        BindPoints();
    }

    protected void lnkMarkRead_Click(object sender, EventArgs e)
    {
        Db.Execute("UPDATE Notifications SET IsRead = 1 WHERE UserID = @u", Db.Param("@u", Auth.UserId));
        BindNotices();
    }

    protected void cvEmail_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = Convert.ToInt32(Db.Scalar("SELECT COUNT(*) FROM Users WHERE Email = @e AND UserID <> @u",
            Db.Param("@e", args.Value.Trim()), Db.Param("@u", Auth.UserId))) == 0;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;
        Db.Execute("UPDATE Users SET FullName = @n, Email = @e, Phone = @p, Address = @a WHERE UserID = @u",
            Db.Param("@n", txtName.Text.Trim()), Db.Param("@e", txtEmail.Text.Trim()), Db.Param("@p", txtPhone.Text.Trim()),
            Db.Param("@a", txtAddress.Text.Trim()), Db.Param("@u", Auth.UserId));

        // Re-issue the login cookie so the new name shows straight away
        Auth.SignIn(Auth.UserId, txtName.Text.Trim(), Auth.IsAdmin ? "Admin" : "Customer", false);
        litName.Text = Server.HtmlEncode(txtName.Text.Trim().Split(' ')[0]);
        ShowMsg(lblProfileMsg, "Your profile has been updated.", true);
    }

    protected void btnPassword_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;
        DataRow u = Db.Row("SELECT PasswordSalt, PasswordHash FROM Users WHERE UserID = @u", Db.Param("@u", Auth.UserId));
        if (!Auth.VerifyPassword(txtCurrent.Text, u["PasswordSalt"].ToString(), u["PasswordHash"].ToString()))
        {
            ShowMsg(lblPwMsg, "Your current password is incorrect.", false);
            return;
        }
        string salt, hash;
        Auth.HashPassword(txtNew.Text, out salt, out hash);
        Db.Execute("UPDATE Users SET PasswordSalt = @s, PasswordHash = @h WHERE UserID = @u", Db.Param("@s", salt), Db.Param("@h", hash), Db.Param("@u", Auth.UserId));
        ShowMsg(lblPwMsg, "Password changed successfully.", true);
    }

    private void ShowMsg(Label label, string text, bool ok)
    {
        label.Text = text;
        label.CssClass = "alert " + (ok ? "alert-success" : "alert-error");
        label.Visible = true;
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Auth.SignOut();
        Response.Redirect("~/Default.aspx");
    }
}
