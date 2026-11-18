using System;
using System.Web.UI;

public partial class DefaultPage : Page
{
    /// <summary>Bakery closes at 8 PM; the Ready-to-Take countdown runs until then.</summary>
    protected string ClosingTime
    {
        get { return DateTime.Today.AddHours(20).ToString("yyyy-MM-ddTHH:mm:ss"); }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;

        litReadyCount.Text = Db.Scalar("SELECT COUNT(*) FROM Products WHERE IsActive = 1 AND IsReadyToday = 1 AND Stock > 0").ToString();

        rptCategories.DataSource = Db.Query("SELECT CategoryID, CategoryName, ImageUrl FROM Categories ORDER BY CategoryID");
        rptCategories.DataBind();

        // Best sellers = most units sold (ties broken by rating)
        rptBest.DataSource = Db.Query("SELECT TOP 8 x.* FROM (" + Shop.ProductSelect + ") x " +
            "ORDER BY (SELECT ISNULL(SUM(oi.Quantity),0) FROM OrderItems oi WHERE oi.ProductID = x.ProductID) DESC, x.AvgRating DESC, x.ProductID");
        rptBest.DataBind();

        BindRecentlyViewed();

        dlReviews.DataSource = Db.Query("SELECT TOP 3 r.Rating, r.Comment, r.ProductID, u.FullName, p.ProductName FROM Reviews r " +
            "JOIN Users u ON u.UserID = r.UserID JOIN Products p ON p.ProductID = r.ProductID " +
            "WHERE r.IsVisible = 1 AND r.Comment IS NOT NULL AND r.Rating >= 4 ORDER BY r.CreatedAt DESC");
        dlReviews.DataBind();
    }

    /// <summary>Shows products saved in the "recent" cookie by Product.aspx (personalisation feature).</summary>
    private void BindRecentlyViewed()
    {
        System.Web.HttpCookie cookie = Request.Cookies["recent"];
        if (cookie == null || string.IsNullOrEmpty(cookie.Value)) return;

        System.Collections.Generic.List<int> ids = new System.Collections.Generic.List<int>();
        foreach (string s in cookie.Value.Split('-'))
        {
            int id;
            if (int.TryParse(s, out id)) ids.Add(id);
        }
        if (ids.Count == 0) return;

        // IDs are parsed integers, so joining them into the IN list is safe
        string idList = string.Join(",", ids);
        System.Data.DataTable t = Db.Query("SELECT ProductID, ProductName, ImageUrl FROM Products WHERE IsActive = 1 AND ProductID IN (" + idList + ") " +
            "ORDER BY CHARINDEX('-' + CAST(ProductID AS VARCHAR(10)) + '-', '-" + string.Join("-", ids) + "-')");
        rptRecent.DataSource = t;
        rptRecent.DataBind();
        phRecent.Visible = t.Rows.Count > 0;
    }
}
