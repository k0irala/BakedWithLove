using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ReadyToTakePage : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;
        DataTable t = Db.Query(Shop.ProductSelect + " AND p.IsReadyToday = 1 AND p.Stock > 0 ORDER BY p.Stock ASC");
        dlReady.DataSource = t;
        dlReady.DataBind();
        pnlEmpty.Visible = t.Rows.Count == 0;
    }

    protected string StockText(int stock)
    {
        return stock <= 3 ? "Only " + stock + " left!" : stock + " in stock";
    }

    protected void dlReady_ItemCommand(object source, DataListCommandEventArgs e)
    {
        if (e.CommandName != "Add") return;
        if (!Auth.IsLoggedIn)
        {
            Response.Redirect("~/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl));
            return;
        }
        string error = Shop.AddToCart(Auth.UserId, Convert.ToInt32(e.CommandArgument), 1);
        if (error != null)
        {
            Flash.Set(error, false);   // show the problem in red
        }
        else
        {
            Flash.Set("Added to your cart.", true);
        }
        Response.Redirect(Request.RawUrl);
    }
}
