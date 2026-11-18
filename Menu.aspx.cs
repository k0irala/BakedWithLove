using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

public partial class MenuPage : Page
{
    protected int CategoryId
    {
        get
        {
            int id;
            return int.TryParse(Request.QueryString["cat"], out id) ? id : 0;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtSearch.Text = Convert.ToString(Request.QueryString["q"]);   // "" if there is no search
            rptCats.DataSource = Db.Query("SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryID");
            rptCats.DataBind();
            BindProducts();
        }
    }

    protected void Filter_Changed(object sender, EventArgs e)
    {
        BindProducts();
    }

    private void BindProducts()
    {
        List<SqlParameter> ps = new List<SqlParameter>();
        string sql = "SELECT x.* FROM (" + Shop.ProductSelect + ") x WHERE 1 = 1";

        if (CategoryId > 0)
        {
            sql += " AND x.CategoryID = @cat";
            ps.Add(Db.Param("@cat", CategoryId));
        }
        string q = txtSearch.Text.Trim();
        if (q.Length > 0)
        {
            sql += " AND (x.ProductName LIKE @q OR x.Description LIKE @q OR x.CategoryName LIKE @q)";
            ps.Add(Db.Param("@q", "%" + q + "%"));
        }
        if (chkEggless.Checked) sql += " AND x.IsEggless = 1";

        switch (ddlSort.SelectedValue)
        {
            case "price-asc": sql += " ORDER BY x.Price"; break;
            case "price-desc": sql += " ORDER BY x.Price DESC"; break;
            case "rating": sql += " ORDER BY x.AvgRating DESC, x.ReviewCount DESC"; break;
            default: sql += " ORDER BY CASE WHEN x.Stock > 0 THEN 0 ELSE 1 END, (SELECT ISNULL(SUM(Quantity),0) FROM OrderItems oi WHERE oi.ProductID = x.ProductID) DESC"; break;
        }

        DataTable products = Db.Query(sql, ps.ToArray());
        rptProducts.DataSource = products;
        rptProducts.DataBind();
        pnlEmpty.Visible = products.Rows.Count == 0;
        litCount.Text = products.Rows.Count + (products.Rows.Count == 1 ? " treat" : " treats") + " found";
    }
}
