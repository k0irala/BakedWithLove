using System;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_Products : Page
{
    // SVG is not accepted from uploads because SVG files can contain scripts
    private static readonly string[] AllowedTypes = { ".jpg", ".jpeg", ".png", ".webp" };

    /// <summary>Saves an uploaded product photo and returns its ~/ path, or null if none/invalid.</summary>
    private string SaveImage(FileUpload upload, out string error)
    {
        error = null;
        if (upload == null || !upload.HasFile) return null;

        string ext = Path.GetExtension(upload.FileName).ToLowerInvariant();
        if (Array.IndexOf(AllowedTypes, ext) < 0 || upload.PostedFile.ContentLength > 4 * 1024 * 1024)
        {
            error = "Photo must be a JPG, PNG or WEBP under 4 MB.";
            return null;
        }
        string folder = Server.MapPath("~/Images/Products/Uploads");
        Directory.CreateDirectory(folder);
        string name = Guid.NewGuid().ToString("N") + ext;
        upload.SaveAs(Path.Combine(folder, name));
        return "~/Images/Products/Uploads/" + name;
    }

    protected void gvProducts_RowUpdating(object sender, GridViewUpdateEventArgs e)
    {
        string error;
        string url = SaveImage((FileUpload)gvProducts.Rows[e.RowIndex].FindControl("fuEditImage"), out error);
        if (error != null)
        {
            ShowMsg(error, false);
            e.Cancel = true;
            return;
        }
        if (url != null)
            Db.Execute("UPDATE Products SET ImageUrl = @i WHERE ProductID = @p", Db.Param("@i", url), Db.Param("@p", e.Keys["ProductID"]));
    }

    protected void gvProducts_RowUpdated(object sender, GridViewUpdatedEventArgs e)
    {
        ShowMsg(e.Exception == null ? "Product updated." : "Could not update product: " + e.Exception.Message, e.Exception == null);
        e.ExceptionHandled = true;
    }

    protected void gvProducts_RowDeleted(object sender, GridViewDeletedEventArgs e)
    {
        ShowMsg(e.Exception == null ? "Product removed (hidden from the shop if it has past orders)." : "Could not delete: " + e.Exception.Message, e.Exception == null);
        e.ExceptionHandled = true;
    }

    protected void dvInsert_ItemInserting(object sender, DetailsViewInsertEventArgs e)
    {
        string error;
        string url = SaveImage((FileUpload)dvInsert.FindControl("fuImage"), out error);
        if (error != null)
        {
            ShowMsg(error, false);
            e.Cancel = true;
            return;
        }
        if (url == null)
        {
            url = "~/Images/Products/placeholder.svg";   // no photo uploaded
        }
        e.Values["ImageUrl"] = url;
    }

    protected void dvInsert_ItemInserted(object sender, DetailsViewInsertedEventArgs e)
    {
        if (e.Exception != null)
        {
            ShowMsg("Could not add product: " + e.Exception.Message, false);
            e.ExceptionHandled = true;
            e.KeepInInsertMode = true;
            return;
        }
        Flash.Set("New product added.", true);
        Response.Redirect(Request.RawUrl);
    }

    private void ShowMsg(string text, bool ok)
    {
        lblMsg.Text = Server.HtmlEncode(text);
        lblMsg.CssClass = "alert " + (ok ? "alert-success" : "alert-error");
        lblMsg.Visible = true;
    }
}
