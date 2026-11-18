using System;
using System.Data;
using System.Web.UI;

public partial class ContactPage : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Pre-fill name and email for logged-in members
        if (!IsPostBack && Auth.IsLoggedIn)
        {
            DataRow u = Db.Row("SELECT FullName, Email FROM Users WHERE UserID = @u", Db.Param("@u", Auth.UserId));
            if (u != null)
            {
                txtName.Text = u["FullName"].ToString();
                txtEmail.Text = u["Email"].ToString();
            }
        }
    }

    protected void btnSend_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        Db.Execute("INSERT INTO Feedback (Name, Email, Subject, Message) VALUES (@n, @e, @s, @m)",
            Db.Param("@n", txtName.Text.Trim()), Db.Param("@e", txtEmail.Text.Trim()),
            Db.Param("@s", ddlSubject.SelectedValue), Db.Param("@m", txtMessage.Text.Trim()));

        pnlForm.Visible = false;
        pnlThanks.Visible = true;
    }
}
