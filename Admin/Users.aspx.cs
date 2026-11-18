using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_Users : Page
{
    protected void gvUsers_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        // Admins can't delete their own account
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        Control del = e.Row.FindControl("lnkDelete");
        if (del != null && (int)DataBinder.Eval(e.Row.DataItem, "UserID") == Auth.UserId) del.Visible = false;
    }

    protected void gvUsers_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        // Stop an admin from locking themselves out
        if ((int)e.Keys["UserID"] == Auth.UserId && (e.NewValues["Role"].ToString() != "Admin" || !(bool)e.NewValues["IsActive"]))
        {
            ShowMsg("You can't remove your own admin access or deactivate yourself.", false);
            e.Cancel = true;
        }
    }

    protected void dsUsers_Deleting(object sender, SqlDataSourceCommandEventArgs e)
    {
        e.Command.Parameters["@CurrentUser"].Value = Auth.UserId;
    }

    protected void gvUsers_RowUpdated(object sender, GridViewUpdatedEventArgs e)
    {
        ShowMsg(e.Exception == null ? "User updated. Role changes apply next time they log in." : "Could not update user.", e.Exception == null);
        e.ExceptionHandled = true;
    }

    protected void gvUsers_RowDeleted(object sender, GridViewDeletedEventArgs e)
    {
        ShowMsg(e.Exception == null ? "User removed (or deactivated if they have orders)." : "Could not delete user.", e.Exception == null);
        e.ExceptionHandled = true;
    }

    private void ShowMsg(string text, bool ok)
    {
        lblMsg.Text = Server.HtmlEncode(text);
        lblMsg.CssClass = "alert " + (ok ? "alert-success" : "alert-error");
        lblMsg.Visible = true;
    }
}
