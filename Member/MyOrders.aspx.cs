using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Member_MyOrders : Page
{
    protected string Tab { get { return Request.QueryString["tab"] == "history" ? "history" : "current"; } }

    private int OrderId
    {
        get
        {
            // The order number comes from ?id=5 (Track link) or ?placed=5 (right after checkout)
            string text = Request.QueryString["id"];
            if (text == null)
            {
                text = Request.QueryString["placed"];
            }
            int id;
            int.TryParse(text, out id);
            return id;
        }
    }

    private string orderStatus;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;
        if (OrderId > 0) BindDetail(); else BindList();
    }

    private void BindList()
    {
        string filter = Tab == "history" ? "o.Status IN ('Delivered', 'Cancelled')" : "o.Status NOT IN ('Delivered', 'Cancelled')";
        DataTable orders = Db.Query(
            "SELECT o.OrderID, o.OrderDate, o.TotalAmount, o.Status, o.DeliveryType, o.IsGift, " +
            "(SELECT SUM(Quantity) FROM OrderItems WHERE OrderID = o.OrderID) AS ItemCount, " +
            "STUFF((SELECT ', ' + ProductName FROM OrderItems WHERE OrderID = o.OrderID FOR XML PATH('')), 1, 2, '') AS ItemNames " +
            "FROM Orders o WHERE o.UserID = @u AND " + filter + " ORDER BY o.OrderDate DESC", Db.Param("@u", Auth.UserId));

        rptOrders.DataSource = orders;
        rptOrders.DataBind();
        pnlNone.Visible = orders.Rows.Count == 0;
        litNone.Text = Tab == "history" ? "<h2>No past orders yet</h2>" : "<h2>No orders in progress</h2><p>Your current orders will appear here so you can track them.</p>";
    }

    private void BindDetail()
    {
        // The UserID check stops customers viewing other people's orders by changing the URL
        DataTable t = Db.Query(
            "SELECT o.*, s.SlotLabel, p.PaymentMethod, p.PaymentStatus, p.TransactionRef FROM Orders o " +
            "LEFT JOIN PickupSlots s ON s.SlotID = o.SlotID LEFT JOIN Payments p ON p.OrderID = o.OrderID " +
            "WHERE o.OrderID = @o AND o.UserID = @u", Db.Param("@o", OrderId), Db.Param("@u", Auth.UserId));
        if (t.Rows.Count == 0)
        {
            BindList();
            return;
        }
        DataRow o = t.Rows[0];
        pnlList.Visible = false;
        pnlDetail.Visible = true;
        pnlPlaced.Visible = Request.QueryString["placed"] != null;
        litPlacedId.Text = OrderId.ToString();

        orderStatus = o["Status"].ToString();
        litOrderId.Text = OrderId.ToString();
        lblStatus.Text = orderStatus;
        lblStatus.CssClass = Shop.StatusCss(orderStatus);
        litDate.Text = ((DateTime)o["OrderDate"]).ToString("dddd, dd MMM yyyy 'at' h:mm tt");
        litStatusMsg.Text = orderStatus == Shop.Pending ? "Waiting for the bakery to confirm your order." : Shop.StatusMessage(orderStatus, OrderId);

        timeline.OrderID = OrderId;
        timeline.Status = orderStatus;
        timeline.DeliveryType = o["DeliveryType"].ToString();

        litSub.Text = Shop.Money(o["SubTotal"]);
        litFee.Text = Shop.Money(o["DeliveryFee"]);
        litPts.Text = "- " + Shop.Money(o["PointsDiscount"]);
        litTotal.Text = Shop.Money(o["TotalAmount"]);

        gvItems.DataSource = Db.Query("SELECT ProductID, ProductName, Quantity, UnitPrice FROM OrderItems WHERE OrderID = @o", Db.Param("@o", OrderId));
        gvItems.DataBind();

        dvOrder.DataSource = t;
        dvOrder.DataBind();

        DataRow g = Db.Row("SELECT * FROM GiftDetails WHERE OrderID = @o", Db.Param("@o", OrderId));
        pnlGift.Visible = g != null;
        if (g != null)
        {
            litRecipient.Text = Server.HtmlEncode(g["RecipientName"].ToString());
            litRecipientInfo.Text = Server.HtmlEncode(g["RecipientPhone"] + " - " + g["RecipientAddress"]);
            litGiftMsg.Text = Server.HtmlEncode(Convert.ToString(g["GiftMessage"]));
        }

        pnlCancel.Visible = orderStatus == Shop.Pending;
    }

    protected void gvItems_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        // "Rate" appears only once the order has been delivered
        if (e.Row.RowType == DataControlRowType.DataRow)
            e.Row.FindControl("lnkRate").Visible = orderStatus == Shop.Delivered;
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        object status = Db.Scalar("SELECT Status FROM Orders WHERE OrderID = @o AND UserID = @u", Db.Param("@o", OrderId), Db.Param("@u", Auth.UserId));
        if (status != null && status.ToString() == Shop.Pending)
        {
            Shop.UpdateOrderStatus(OrderId, Shop.Cancelled);
            Flash.Set("Order #" + OrderId + " has been cancelled.", true);
        }
        else
        {
            Flash.Set("This order can no longer be cancelled because the bakery has already started on it.", false);
        }
        Response.Redirect("~/Member/MyOrders.aspx?id=" + OrderId);
    }
}
