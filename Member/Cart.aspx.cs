using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Member_Cart : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack) BindCart();
    }

    private void BindCart()
    {
        DataTable cart = Db.Query(Shop.CartSql, Db.Param("@u", Auth.UserId));
        pnlCart.Visible = cart.Rows.Count > 0;
        pnlEmpty.Visible = cart.Rows.Count == 0;
        if (cart.Rows.Count == 0) return;

        rptCart.DataSource = cart;
        rptCart.DataBind();

        decimal subtotal = 0;
        int items = 0;
        bool stockProblem = false;
        foreach (DataRow r in cart.Rows)
        {
            subtotal += (decimal)r["LineTotal"];
            items += (int)r["Quantity"];
            if ((int)r["Quantity"] > (int)r["Stock"]) stockProblem = true;
        }

        litItems.Text = items.ToString();
        litSubtotal.Text = litTotal.Text = Shop.Money(subtotal);

        decimal fee = Shop.DeliveryFee(subtotal);
        decimal freeOver = Convert.ToDecimal(System.Configuration.ConfigurationManager.AppSettings["FreeDeliveryOver"]);
        lblFreeHint.Text = fee == 0 ? "&#127881; You get FREE delivery!" : "Add " + Shop.Money(freeOver - subtotal) + " more for free delivery.";

        lblStockError.Visible = stockProblem;
        lblStockError.Text = "Some items have less stock than you ordered. Please reduce the quantity.";
        lnkCheckout.Enabled = !stockProblem;
        if (stockProblem) lnkCheckout.CssClass += " disabled";
    }

    protected void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);
        // Every statement filters by UserID so customers can only change their own cart
        switch (e.CommandName)
        {
            case "Remove":
                Db.Execute("DELETE FROM CartItems WHERE CartItemID = @id AND UserID = @u", Db.Param("@id", id), Db.Param("@u", Auth.UserId));
                break;
            case "Minus":
                Db.Execute("UPDATE CartItems SET Quantity = Quantity - 1 WHERE CartItemID = @id AND UserID = @u AND Quantity > 1", Db.Param("@id", id), Db.Param("@u", Auth.UserId));
                break;
            case "Plus":
                int changed = Db.Execute("UPDATE ci SET Quantity = Quantity + 1 FROM CartItems ci JOIN Products p ON p.ProductID = ci.ProductID " +
                    "WHERE ci.CartItemID = @id AND ci.UserID = @u AND ci.Quantity < p.Stock", Db.Param("@id", id), Db.Param("@u", Auth.UserId));
                if (changed == 0) Flash.Set("Sorry, there is no more stock of that item.", false);
                break;
        }
        Response.Redirect(Request.RawUrl);
    }
}
