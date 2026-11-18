using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_Orders : Page
{
    private int OrderId
    {
        get
        {
            int id;
            int.TryParse(Request.QueryString["id"], out id);
            return id;
        }
    }

    private string StatusFilter
    {
        get
        {
            string s = Request.QueryString["status"];
            return Array.IndexOf(Shop.AllStatuses, s) >= 0 ? s : "";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;
        if (OrderId > 0) BindDetail(); else BindList();
    }

    // ---------- List ----------
    private void BindList()
    {
        DataTable counts = Db.Query("SELECT Status, COUNT(*) AS N FROM Orders GROUP BY Status");
        int all = 0;
        Dictionary<string, int> byStatus = new Dictionary<string, int>();
        foreach (DataRow r in counts.Rows) { byStatus[r["Status"].ToString()] = (int)r["N"]; all += (int)r["N"]; }

        List<object> tabs = new List<object>();
        tabs.Add(new { Query = "", Label = "All", Count = all, Css = StatusFilter == "" ? "active" : "" });
        foreach (string s in Shop.AllStatuses)
        {
            int n;
            byStatus.TryGetValue(s, out n);
            tabs.Add(new { Query = "?status=" + Server.UrlEncode(s), Label = s, Count = n, Css = StatusFilter == s ? "active" : "" });
        }
        rptTabs.DataSource = tabs;
        rptTabs.DataBind();
        BindGrid();
    }

    private void BindGrid()
    {
        gvOrders.DataSource = Db.Query(
            "SELECT o.OrderID, o.OrderDate, o.DeliveryType, o.IsGift, o.PreferredDate, o.TotalAmount, o.Status, u.FullName, p.PaymentMethod, p.PaymentStatus " +
            "FROM Orders o JOIN Users u ON u.UserID = o.UserID LEFT JOIN Payments p ON p.OrderID = o.OrderID " +
            "WHERE (@s = '' OR o.Status = @s) ORDER BY CASE o.Status WHEN 'Pending' THEN 0 ELSE 1 END, o.OrderDate DESC",
            Db.Param("@s", StatusFilter));
        gvOrders.DataBind();
    }

    protected void gvOrders_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvOrders.PageIndex = e.NewPageIndex;
        BindList();
    }

    // ---------- Detail ----------
    private void BindDetail()
    {
        DataTable t = Db.Query(
            "SELECT o.*, u.FullName, u.Email, s.SlotLabel, p.PaymentMethod, p.PaymentStatus, p.TransactionRef FROM Orders o " +
            "JOIN Users u ON u.UserID = o.UserID LEFT JOIN PickupSlots s ON s.SlotID = o.SlotID LEFT JOIN Payments p ON p.OrderID = o.OrderID " +
            "WHERE o.OrderID = @o", Db.Param("@o", OrderId));
        if (t.Rows.Count == 0) { BindList(); return; }

        DataRow o = t.Rows[0];
        string status = o["Status"].ToString();
        string type = o["DeliveryType"].ToString();
        pnlList.Visible = false;
        pnlDetail.Visible = true;

        litId.Text = OrderId.ToString();
        litGiftIcon.Text = (bool)o["IsGift"] ? "&#127873;" : "";
        lblStatus.Text = status;
        lblStatus.CssClass = Shop.StatusCss(status);
        timeline.OrderID = OrderId;
        timeline.Status = status;
        timeline.DeliveryType = type;

        litSub.Text = Shop.Money(o["SubTotal"]);
        litFee.Text = Shop.Money(o["DeliveryFee"]);
        litPts.Text = "- " + Shop.Money(o["PointsDiscount"]);
        litTotal.Text = Shop.Money(o["TotalAmount"]);

        dvOrder.DataSource = t;
        dvOrder.DataBind();
        gvItems.DataSource = Db.Query("SELECT ProductName, Quantity, UnitPrice FROM OrderItems WHERE OrderID = @o", Db.Param("@o", OrderId));
        gvItems.DataBind();

        DataRow g = Db.Row("SELECT * FROM GiftDetails WHERE OrderID = @o", Db.Param("@o", OrderId));
        pnlGift.Visible = g != null;
        if (g != null)
        {
            litRecipient.Text = Server.HtmlEncode(g["RecipientName"].ToString());
            litRecipientInfo.Text = Server.HtmlEncode(g["RecipientPhone"] + " - " + g["RecipientAddress"]);
            litGiftMsg.Text = Server.HtmlEncode(Convert.ToString(g["GiftMessage"]));
        }

        // Only offer the statuses that make sense next
        ddlNext.Items.Clear();
        foreach (string s in NextStatuses(status, type)) ddlNext.Items.Add(s);
        pnlUpdate.Visible = ddlNext.Items.Count > 0;
        lblFinal.Visible = ddlNext.Items.Count == 0;
    }

    private static List<string> NextStatuses(string current, string deliveryType)
    {
        List<string> next = new List<string>();
        switch (current)
        {
            case Shop.Pending:
                next.Add(Shop.Confirmed);
                next.Add(Shop.Cancelled);
                break;
            case Shop.Confirmed:
                next.Add(deliveryType == "Pickup" ? Shop.ReadyForPickup : Shop.OutForDelivery);
                next.Add(Shop.Cancelled);
                break;
            case Shop.OutForDelivery:
            case Shop.ReadyForPickup:
                next.Add(Shop.Delivered);
                break;
        }
        return next;
    }

    protected void btnUpdate_Click(object sender, EventArgs e)
    {
        DataRow o = Db.Row("SELECT Status, DeliveryType FROM Orders WHERE OrderID = @o", Db.Param("@o", OrderId));
        if (o != null && NextStatuses(o["Status"].ToString(), o["DeliveryType"].ToString()).Contains(ddlNext.SelectedValue))
        {
            Shop.UpdateOrderStatus(OrderId, ddlNext.SelectedValue);
            Flash.Set("Order #" + OrderId + " moved to '" + ddlNext.SelectedValue + "'. The customer has been notified.", true);
        }
        Response.Redirect("~/Admin/Orders.aspx?id=" + OrderId);
    }
}
