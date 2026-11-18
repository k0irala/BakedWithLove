using System;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_Categories : Page
{
    protected void cvUnique_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = Convert.ToInt32(Db.Scalar("SELECT COUNT(*) FROM Categories WHERE CategoryName = @n", Db.Param("@n", args.Value.Trim()))) == 0;
    }

    protected void btnAddCat_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;
        txtNewName.Text = txtNewName.Text.Trim();
        dsCategories.Insert();
        Flash.Set("Category '" + txtNewName.Text + "' added.", true);
        Response.Redirect(Request.RawUrl);
    }

    protected void btnAddSlot_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;
        dsSlots.Insert();
        Flash.Set("Pickup slot added.", true);
        Response.Redirect(Request.RawUrl);
    }

    protected void gvCategories_RowDeleted(object sender, GridViewDeletedEventArgs e)
    {
        if (e.Exception != null || e.AffectedRows == 0)
            ShowMsg("This category still has products. Move or delete them first.", false);
        else
            ShowMsg("Category deleted.", true);
        e.ExceptionHandled = true;
    }

    protected void gvCategories_RowUpdated(object sender, GridViewUpdatedEventArgs e)
    {
        if (e.Exception != null)
        {
            ShowMsg("Could not save: that name may already be in use.", false);
            e.ExceptionHandled = true;
            e.KeepInEditMode = true;
        }
        else ShowMsg("Category updated.", true);
    }

    private void ShowMsg(string text, bool ok)
    {
        lblMsg.Text = Server.HtmlEncode(text);
        lblMsg.CssClass = "alert " + (ok ? "alert-success" : "alert-error");
        lblMsg.Visible = true;
    }
}
