using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;

public partial class Admin_Dashboard : Page
{
    // Revenue counts every order that wasn't cancelled
    private const string Valid = "Status <> 'Cancelled'";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;

        litTodaySales.Text = Shop.Money(Db.Scalar("SELECT ISNULL(SUM(TotalAmount),0) FROM Orders WHERE " + Valid + " AND CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)"));
        litWeekSales.Text = Shop.Money(Db.Scalar("SELECT ISNULL(SUM(TotalAmount),0) FROM Orders WHERE " + Valid + " AND OrderDate >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE))"));
        litPending.Text = Db.Scalar("SELECT COUNT(*) FROM Orders WHERE Status = 'Pending'").ToString();
        litCustom.Text = Db.Scalar("SELECT COUNT(*) FROM CustomOrders WHERE Status IN ('Pending Review', 'Accepted')").ToString();
        litCustomers.Text = Db.Scalar("SELECT COUNT(*) FROM Users WHERE Role = 'Customer'").ToString();
        litAvgOrder.Text = Shop.Money(Db.Scalar("SELECT ISNULL(AVG(TotalAmount),0) FROM Orders WHERE " + Valid));
        object rating = Db.Scalar("SELECT AVG(CAST(Rating AS DECIMAL(4,2))) FROM Reviews");
        litRating.Text = rating == null ? "-" : Convert.ToDecimal(rating).ToString("0.0") + " &#9733;";

        DataTable low = Db.Query("SELECT ProductName, Stock FROM Products WHERE IsActive = 1 AND Stock <= 3 ORDER BY Stock, ProductName");
        litLowStock.Text = low.Rows.Count.ToString();
        gvLowStock.DataSource = low;
        gvLowStock.DataBind();

        gvRecent.DataSource = Db.Query("SELECT TOP 6 o.OrderID, u.FullName, o.TotalAmount, o.Status FROM Orders o JOIN Users u ON u.UserID = o.UserID ORDER BY o.OrderDate DESC");
        gvRecent.DataBind();

        BindChart();
        BindTopSellers();
    }

    private void BindChart()
    {
        DataTable sales = Db.Query("SELECT CAST(OrderDate AS DATE) AS Day, SUM(TotalAmount) AS Total FROM Orders WHERE " + Valid +
            " AND OrderDate >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE)) GROUP BY CAST(OrderDate AS DATE)");

        // Fill in all 7 days, including days with no sales
        Dictionary<DateTime, decimal> byDay = new Dictionary<DateTime, decimal>();
        foreach (DataRow r in sales.Rows) byDay[(DateTime)r["Day"]] = (decimal)r["Total"];

        decimal max = 1;
        foreach (decimal v in byDay.Values) max = Math.Max(max, v);

        List<object> points = new List<object>();
        for (int i = 6; i >= 0; i--)
        {
            DateTime d = DateTime.Today.AddDays(-i);
            decimal total;
            byDay.TryGetValue(d, out total);
            string dayName = d.ToString("ddd");   // e.g. "Mon"
            if (i == 0) dayName = "Today";

            string label = total.ToString("0");   // e.g. "790"
            if (total == 0) label = "-";
            if (total >= 1000) label = (total / 1000m).ToString("0.#") + "k";   // e.g. "2.1k"

            points.Add(new
            {
                Day = dayName,
                Label = label,
                Height = Math.Max(3, (int)(total * 150 / max)) // pixels; tallest bar = 150px
            });
        }
        rptChart.DataSource = points;
        rptChart.DataBind();
        rptChartLabels.DataSource = points;
        rptChartLabels.DataBind();
    }

    private void BindTopSellers()
    {
        DataTable top = Db.Query("SELECT TOP 5 oi.ProductName, SUM(oi.Quantity) AS Sold FROM OrderItems oi JOIN Orders o ON o.OrderID = oi.OrderID " +
            "WHERE o." + Valid + " GROUP BY oi.ProductName ORDER BY Sold DESC");
        int max = 1;
        foreach (DataRow r in top.Rows) max = Math.Max(max, (int)r["Sold"]);
        top.Columns.Add("Pct", typeof(int));
        foreach (DataRow r in top.Rows) r["Pct"] = (int)r["Sold"] * 100 / max;
        rptTop.DataSource = top;
        rptTop.DataBind();
    }
}
