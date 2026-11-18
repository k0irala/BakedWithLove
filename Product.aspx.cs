using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI;

public partial class ProductPage : Page
{
    protected int ProductId
    {
        get
        {
            int id;
            return int.TryParse(Request.QueryString["id"], out id) ? id : 0;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack) BindProduct();
    }

    private void BindProduct()
    {
        DataRow p = Db.Row(Shop.ProductSelect + " AND p.ProductID = @id", Db.Param("@id", ProductId));
        if (p == null)
        {
            pnlNotFound.Visible = true;
            pnlProduct.Visible = false;
            return;
        }

        Title = p["ProductName"] + " | Baked With Love";
        imgProduct.ImageUrl = Shop.Img(p["ImageUrl"]);
        imgProduct.AlternateText = p["ProductName"].ToString();
        litName.Text = Server.HtmlEncode(p["ProductName"].ToString());
        litCategory.Text = Server.HtmlEncode(p["CategoryName"].ToString());
        litPrice.Text = Shop.Money(p["Price"]);
        litDesc.Text = Server.HtmlEncode(Convert.ToString(p["Description"]));
        stars.Rating = (decimal)p["AvgRating"];
        stars.Count = (int)p["ReviewCount"];
        lblEggless.Visible = (bool)p["IsEggless"];

        int stock = (int)p["Stock"];
        if (stock > 0)
        {
            lblStock.Text = ((bool)p["IsReadyToday"] ? "&#10003; Ready today - " : "") + stock + " in stock";
            lblStock.CssClass = "badge badge-delivered";
            rvQty.MaximumValue = stock.ToString();
            rvQty.ErrorMessage = "You can order between 1 and " + stock + ".";
        }
        else
        {
            lblStock.Text = "Sold out today";
            lblStock.CssClass = "badge badge-cancelled";
            btnAdd.Enabled = false;
            btnAdd.CssClass += " disabled";
            rvQty.MaximumValue = "1";
            rvQty.ErrorMessage = "Sold out.";
        }

        RememberRecentlyViewed();
        BindReviews();
    }

    /// <summary>Keeps the last 6 viewed product IDs in a cookie for the "Recently viewed" section on Home.</summary>
    private void RememberRecentlyViewed()
    {
        List<string> ids = new List<string>();
        HttpCookie old = Request.Cookies["recent"];
        if (old != null) ids.AddRange(old.Value.Split(new[] { '-' }, StringSplitOptions.RemoveEmptyEntries));
        ids.Remove(ProductId.ToString());
        ids.Insert(0, ProductId.ToString());
        if (ids.Count > 6) ids.RemoveRange(6, ids.Count - 6);

        HttpCookie cookie = new HttpCookie("recent", string.Join("-", ids));
        cookie.Expires = DateTime.Now.AddDays(30);
        cookie.HttpOnly = true;
        Response.Cookies.Add(cookie);
    }

    private void BindReviews()
    {
        DataTable reviews = Db.Query("SELECT r.Rating, r.Comment, r.CreatedAt, u.FullName FROM Reviews r JOIN Users u ON u.UserID = r.UserID " +
            "WHERE r.ProductID = @id AND r.IsVisible = 1 ORDER BY r.CreatedAt DESC", Db.Param("@id", ProductId));
        rptReviews.DataSource = reviews;
        rptReviews.DataBind();
        lblNoReviews.Visible = reviews.Rows.Count == 0;

        // Only customers who received this product, and haven't reviewed it yet, can rate it
        string reason = null;
        if (!Auth.IsLoggedIn)
            reason = "<a href=\"Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl) + "\">Log in</a> to rate products you have ordered.";
        else if (DeliveredOrderId() == null)
            reason = "You can rate this product after your order containing it has been delivered.";
        else if (Convert.ToInt32(Db.Scalar("SELECT COUNT(*) FROM Reviews WHERE UserID = @u AND ProductID = @p", Db.Param("@u", Auth.UserId), Db.Param("@p", ProductId))) > 0)
            reason = "&#10003; Thank you! You have already reviewed this product.";

        pnlReviewForm.Visible = reason == null;
        lblReviewInfo.Visible = reason != null;
        lblReviewInfo.Text = reason;
    }

    private object DeliveredOrderId()
    {
        return Db.Scalar("SELECT TOP 1 o.OrderID FROM Orders o JOIN OrderItems oi ON oi.OrderID = o.OrderID " +
            "WHERE o.UserID = @u AND oi.ProductID = @p AND o.Status = 'Delivered' ORDER BY o.OrderDate DESC",
            Db.Param("@u", Auth.UserId), Db.Param("@p", ProductId));
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid) return;
        if (!Auth.IsLoggedIn)
        {
            Response.Redirect("~/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl));
            return;
        }
        string error = Shop.AddToCart(Auth.UserId, ProductId, int.Parse(txtQty.Text));
        if (error != null)
        {
            Flash.Set(error, false);   // show the problem in red
        }
        else
        {
            Flash.Set(txtQty.Text + " x " + Server.HtmlDecode(litName.Text) + " added to your cart.", true);
        }
        Response.Redirect(Request.RawUrl);
    }

    protected void btnReview_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid || !Auth.IsLoggedIn) return;

        int rating;
        if (!int.TryParse(Request.Form["rating"], out rating) || rating < 1 || rating > 5)
        {
            lblReviewMsg.Text = "Please choose a star rating.";
            BindProduct();
            return;
        }
        object orderId = DeliveredOrderId();
        if (orderId == null) return;

        Db.Execute("INSERT INTO Reviews (UserID, ProductID, OrderID, Rating, Comment) VALUES (@u, @p, @o, @r, @c)",
            Db.Param("@u", Auth.UserId), Db.Param("@p", ProductId), Db.Param("@o", orderId), Db.Param("@r", rating),
            Db.Param("@c", string.IsNullOrWhiteSpace(txtComment.Text) ? null : txtComment.Text.Trim()));

        Flash.Set("Thanks for your review!", true);
        Response.Redirect(Request.RawUrl + "#reviews");
    }
}
