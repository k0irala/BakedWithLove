using System;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Member_CustomCake : Page
{
    private static readonly string[] AllowedTypes = { ".jpg", ".jpeg", ".png", ".webp" };

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtDate.Attributes["min"] = DateTime.Today.AddDays(2).ToString("yyyy-MM-dd");
            txtDate.Attributes["max"] = DateTime.Today.AddDays(60).ToString("yyyy-MM-dd");
            BindRequests();
        }
    }

    private void BindRequests()
    {
        DataTable t = Db.Query("SELECT * FROM CustomOrders WHERE UserID = @u ORDER BY CreatedAt DESC", Db.Param("@u", Auth.UserId));
        rptRequests.DataSource = t;
        rptRequests.DataBind();
        lblNoRequests.Visible = t.Rows.Count == 0;
    }

    protected void cvDate_ServerValidate(object source, ServerValidateEventArgs args)
    {
        DateTime d;
        args.IsValid = DateTime.TryParseExact(args.Value, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d)
                       && d >= DateTime.Today.AddDays(2) && d <= DateTime.Today.AddDays(60);
    }

    protected void cvFile_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (!fuReference.HasFile) { args.IsValid = true; return; }
        string ext = Path.GetExtension(fuReference.FileName).ToLowerInvariant();
        args.IsValid = Array.IndexOf(AllowedTypes, ext) >= 0
                       && fuReference.PostedFile.ContentType.StartsWith("image/")
                       && fuReference.PostedFile.ContentLength <= 4 * 1024 * 1024;
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;

        // Save the photo with a random name so users can't overwrite each other's files
        string imageUrl = null;
        if (fuReference.HasFile)
        {
            string folder = Server.MapPath("~/Uploads/Custom");
            Directory.CreateDirectory(folder);
            string fileName = Guid.NewGuid().ToString("N") + Path.GetExtension(fuReference.FileName).ToLowerInvariant();
            fuReference.SaveAs(Path.Combine(folder, fileName));
            imageUrl = "~/Uploads/Custom/" + fileName;
        }

        string size = "1 lb";
        if (rbSize2.Checked) size = "2 lb";
        if (rbSize3.Checked) size = "3 lb";
        if (rbSize4.Checked) size = "2-tier";

        string eggOption = "With egg";
        if (rbEggless.Checked) eggOption = "Eggless";

        object id = Db.Scalar(
            "INSERT INTO CustomOrders (UserID, CakeSize, Flavor, Filling, EggOption, Occasion, DesignNotes, CakeMessage, AllergyNotes, ReferenceImage, RequiredDate, DeliveryType) " +
            "VALUES (@u, @size, @fl, @fi, @egg, @occ, @des, @msg, @all, @img, @date, @type); SELECT CAST(SCOPE_IDENTITY() AS INT);",
            Db.Param("@u", Auth.UserId), Db.Param("@size", size), Db.Param("@fl", ddlFlavor.SelectedValue), Db.Param("@fi", ddlFilling.SelectedValue),
            Db.Param("@egg", eggOption), Db.Param("@occ", ddlOccasion.SelectedValue),
            Db.Param("@des", txtDesign.Text.Trim()), Db.Param("@msg", Blank(txtMessage.Text)), Db.Param("@all", Blank(txtAllergy.Text)),
            Db.Param("@img", imageUrl), Db.Param("@date", DateTime.ParseExact(txtDate.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture)),
            Db.Param("@type", rbDelivery.Checked ? "Delivery" : "Pickup"));

        Notify.Send(Auth.UserId, null, "Custom cake request #" + id + " received",
            "Thanks! Our bakers will review your " + size + " " + ddlFlavor.SelectedValue + " cake design and send you a price within 24 hours.", true);
        Flash.Set("Your custom cake request has been sent! We'll reply with a price soon.", true);
        Response.Redirect(Request.RawUrl);
    }

    protected void rptRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);
        string newStatus = e.CommandName == "Accept" ? "Accepted" : "Declined";
        int changed = Db.Execute("UPDATE CustomOrders SET Status = @s WHERE CustomOrderID = @id AND UserID = @u AND Status = 'Quoted'",
            Db.Param("@s", newStatus), Db.Param("@id", id), Db.Param("@u", Auth.UserId));
        if (changed > 0)
        {
            Notify.Send(Auth.UserId, null, "Custom cake #" + id + " " + newStatus.ToLower(),
                newStatus == "Accepted" ? "Great! Your custom cake is confirmed. Pay when you collect it or on delivery." : "You declined the quote. Feel free to send a new request any time.", true);
            Flash.Set(newStatus == "Accepted" ? "Quote accepted - our bakers will start on your cake!" : "Quote declined.", true);
        }
        Response.Redirect(Request.RawUrl);
    }

    private static object Blank(string s)
    {
        return string.IsNullOrWhiteSpace(s) ? null : s.Trim();
    }
}
