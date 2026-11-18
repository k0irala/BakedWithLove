using System;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_CustomRequests : Page
{
    private int SelectedId
    {
        get
        {
            if (ViewState["sel"] == null)
            {
                return 0;
            }
            return (int)ViewState["sel"];
        }
        set { ViewState["sel"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack) BindGrid();
    }

    private void BindGrid()
    {
        gvRequests.DataSource = Db.Query(
            "SELECT c.CustomOrderID, u.FullName, c.CakeSize, c.Flavor, c.EggOption, c.Occasion, c.RequiredDate, c.QuotedPrice, c.Status " +
            "FROM CustomOrders c JOIN Users u ON u.UserID = c.UserID " +
            "ORDER BY CASE c.Status WHEN 'Pending Review' THEN 0 WHEN 'Accepted' THEN 1 WHEN 'In Progress' THEN 2 WHEN 'Quoted' THEN 3 ELSE 4 END, c.RequiredDate");
        gvRequests.DataBind();
    }

    protected void gvRequests_SelectedIndexChanged(object sender, EventArgs e)
    {
        SelectedId = (int)gvRequests.SelectedDataKey.Value;
        BindDetail();
    }

    private void BindDetail()
    {
        DataTable t = Db.Query("SELECT c.*, u.FullName, u.Email, u.Phone FROM CustomOrders c JOIN Users u ON u.UserID = c.UserID WHERE c.CustomOrderID = @id",
            Db.Param("@id", SelectedId));
        if (t.Rows.Count == 0) return;
        DataRow r = t.Rows[0];

        pnlDetail.Visible = true;
        litId.Text = SelectedId.ToString();
        dvRequest.DataSource = t;
        dvRequest.DataBind();

        string img = Convert.ToString(r["ReferenceImage"]);
        pnlImage.Visible = img.Length > 0;
        if (img.Length > 0)
        {
            imgRef.ImageUrl = img;
            lnkImage.NavigateUrl = img;
            imgRef.AlternateText = "Customer's reference photo";
        }

        string status = r["Status"].ToString();
        if (ddlStatus.Items.FindByValue(status) == null) ddlStatus.Items.Add(status);
        ddlStatus.SelectedValue = status;
        txtPrice.Text = r["QuotedPrice"] == DBNull.Value ? "" : ((decimal)r["QuotedPrice"]).ToString("0");
        txtNote.Text = Convert.ToString(r["AdminNote"]);
    }

    protected void cvPrice_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = ddlStatus.SelectedValue != "Quoted" || txtPrice.Text.Trim().Length > 0;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid || SelectedId == 0) return;

        // The quoted price is optional: save NULL if the box is empty
        object priceValue = null;
        decimal price;
        if (decimal.TryParse(txtPrice.Text, NumberStyles.Number, CultureInfo.InvariantCulture, out price))
        {
            priceValue = price;
        }

        string note = null;
        if (txtNote.Text.Trim() != "")
        {
            note = txtNote.Text.Trim();
        }
        string status = ddlStatus.SelectedValue;

        Db.Execute("UPDATE CustomOrders SET Status = @s, QuotedPrice = @p, AdminNote = @n WHERE CustomOrderID = @id",
            Db.Param("@s", status), Db.Param("@p", priceValue), Db.Param("@n", note), Db.Param("@id", SelectedId));

        int userId = (int)Db.Scalar("SELECT UserID FROM CustomOrders WHERE CustomOrderID = @id", Db.Param("@id", SelectedId));
        string msg;
        switch (status)
        {
            case "Quoted": msg = "Your custom cake request #" + SelectedId + " has been quoted at " + Shop.Money(price) + ". Please accept or decline it on the Custom Cake page."; break;
            case "Rejected": msg = "Sorry, we can't make custom cake #" + SelectedId + " as requested. " + txtNote.Text.Trim(); break;
            case "In Progress": msg = "Our bakers have started on your custom cake #" + SelectedId + "!"; break;
            case "Completed": msg = "Your custom cake #" + SelectedId + " is ready. Enjoy your celebration!"; break;
            default: msg = "Custom cake request #" + SelectedId + " status: " + status + "."; break;
        }
        Notify.Send(userId, null, "Custom cake #" + SelectedId + ": " + status, msg, true);

        Flash.Set("Request #" + SelectedId + " saved as '" + status + "' and the customer was notified.", true);
        Response.Redirect(Request.RawUrl);
    }
}
