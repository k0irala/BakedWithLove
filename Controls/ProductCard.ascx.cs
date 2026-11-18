using System;
using System.Web.UI;

/// <summary>
/// Reusable product card used on Home, Menu and Ready-to-Take pages.
/// Properties are kept in ViewState so the "Add" button works after a postback.
/// </summary>
public partial class Controls_ProductCard : UserControl
{
    // Each value is saved in ViewState so it is still there after the "Add" button posts back.
    // Convert.ToInt32(null) gives 0 (and ToBoolean gives false, ToString gives ""),
    // so reading a property that was never set is safe.
    public int ProductID
    {
        get { return Convert.ToInt32(ViewState["id"]); }
        set { ViewState["id"] = value; }
    }

    public string ProductName
    {
        get { return Convert.ToString(ViewState["name"]); }
        set { ViewState["name"] = value; }
    }

    public decimal Price
    {
        get { return Convert.ToDecimal(ViewState["price"]); }
        set { ViewState["price"] = value; }
    }

    public string ImageUrl
    {
        get { return Convert.ToString(ViewState["img"]); }
        set { ViewState["img"] = value; }
    }

    public int Stock
    {
        get { return Convert.ToInt32(ViewState["stock"]); }
        set { ViewState["stock"] = value; }
    }

    public bool IsReadyToday
    {
        get { return Convert.ToBoolean(ViewState["ready"]); }
        set { ViewState["ready"] = value; }
    }

    public bool IsEggless
    {
        get { return Convert.ToBoolean(ViewState["egg"]); }
        set { ViewState["egg"] = value; }
    }

    public decimal AvgRating
    {
        get { return Convert.ToDecimal(ViewState["rating"]); }
        set { ViewState["rating"] = value; }
    }

    public int ReviewCount
    {
        get { return Convert.ToInt32(ViewState["reviews"]); }
        set { ViewState["reviews"] = value; }
    }

    protected string DetailUrl
    {
        get { return ResolveUrl("~/Product.aspx?id=" + ProductID); }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        stars.Rating = AvgRating;
        stars.Count = ReviewCount;
        if (Stock > 0)
        {
            btnAdd.Enabled = true;
            btnAdd.Text = "+ Add";
        }
        else
        {
            btnAdd.Enabled = false;
            btnAdd.Text = "Sold out";
        }
        btnAdd.ToolTip = "Add " + ProductName + " to cart";
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        if (!Auth.IsLoggedIn)
        {
            Response.Redirect("~/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl));
            return;
        }
        string error = Shop.AddToCart(Auth.UserId, ProductID, 1);
        if (error != null)
        {
            Flash.Set(error, false);   // show the problem in red
        }
        else
        {
            Flash.Set(ProductName + " added to your cart.", true);
        }
        Response.Redirect(Request.RawUrl);
    }
}
