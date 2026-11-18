using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;

/// <summary>
/// Live order-tracking timeline: Placed -> Confirmed -> Out for Delivery / Ready for Pickup -> Delivered.
/// Times come from the OrderStatusHistory table.
/// </summary>
public partial class Controls_OrderTimeline : UserControl
{
    public int OrderID { get; set; }
    public string Status { get; set; }
    public string DeliveryType { get; set; }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        DataTable history = Db.Query("SELECT Status, MAX(ChangedAt) AS ChangedAt FROM OrderStatusHistory WHERE OrderID = @o GROUP BY Status",
            Db.Param("@o", OrderID));
        Dictionary<string, DateTime> times = new Dictionary<string, DateTime>();
        foreach (DataRow r in history.Rows) times[r["Status"].ToString()] = (DateTime)r["ChangedAt"];

        bool pickup = DeliveryType == "Pickup";
        List<string[]> steps = new List<string[]>();
        steps.Add(new[] { Shop.Pending, "Placed", "&#128221;" });
        if (Status == Shop.Cancelled)
        {
            steps.Add(new[] { Shop.Cancelled, "Cancelled", "&#10005;" });
        }
        else
        {
            steps.Add(new[] { Shop.Confirmed, "Confirmed", "&#127856;" });
            steps.Add(pickup ? new[] { Shop.ReadyForPickup, "Ready for pickup", "&#128717;" }
                             : new[] { Shop.OutForDelivery, "Out for delivery", "&#128666;" });
            steps.Add(new[] { Shop.Delivered, pickup ? "Collected" : "Delivered", "&#127881;" });
        }

        // Find how far the order has progressed
        int reached = 0;
        for (int i = 0; i < steps.Count; i++)
        {
            if (steps[i][0] == Status) reached = i;
        }

        List<object> data = new List<object>();
        for (int i = 0; i < steps.Count; i++)
        {
            string css = i <= reached ? "done" : "";
            if (i == reached && Status != Shop.Delivered && Status != Shop.Cancelled) css += " current";
            if (steps[i][0] == Shop.Cancelled) css = "cancelled";
            DateTime when;
            data.Add(new
            {
                Css = css,
                Label = steps[i][1],
                Icon = i <= reached ? steps[i][2] : (i + 1).ToString(),
                When = times.TryGetValue(steps[i][0], out when) ? when.ToString("dd MMM, h:mm tt") : ""
            });
        }
        rptSteps.DataSource = data;
        rptSteps.DataBind();
    }
}
