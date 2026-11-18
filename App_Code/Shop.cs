using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;

/// <summary>
/// Business rules for the bakery: money formatting, cart, order statuses, loyalty points.
/// </summary>
public static class Shop
{
    // ---------- Order statuses ----------
    public const string Pending = "Pending";
    public const string Confirmed = "Confirmed";
    public const string OutForDelivery = "Out for Delivery";
    public const string ReadyForPickup = "Ready for Pickup";
    public const string Delivered = "Delivered";
    public const string Cancelled = "Cancelled";

    public static readonly string[] AllStatuses = { Pending, Confirmed, OutForDelivery, ReadyForPickup, Delivered, Cancelled };

    /// <summary>Base SELECT for product listings, including average rating and review count.</summary>
    public const string ProductSelect =
        "SELECT p.ProductID, p.ProductName, p.Description, p.Price, p.ImageUrl, p.Stock, p.IsReadyToday, p.IsEggless, " +
        "p.CategoryID, c.CategoryName, " +
        "CAST(ISNULL((SELECT AVG(CAST(r.Rating AS DECIMAL(4,2))) FROM Reviews r WHERE r.ProductID = p.ProductID AND r.IsVisible = 1), 0) AS DECIMAL(4,2)) AS AvgRating, " +
        "(SELECT COUNT(*) FROM Reviews r WHERE r.ProductID = p.ProductID AND r.IsVisible = 1) AS ReviewCount " +
        "FROM Products p JOIN Categories c ON c.CategoryID = p.CategoryID WHERE p.IsActive = 1 ";

    /// <summary>The current user's cart lines (parameter @u = UserID).</summary>
    public const string CartSql =
        "SELECT ci.CartItemID, ci.ProductID, ci.Quantity, p.ProductName, p.Price, p.ImageUrl, p.Stock, " +
        "ci.Quantity * p.Price AS LineTotal FROM CartItems ci JOIN Products p ON p.ProductID = ci.ProductID " +
        "WHERE ci.UserID = @u AND p.IsActive = 1 ORDER BY ci.AddedAt";

    // ---------- Formatting ----------
    public static string Money(object amount)
    {
        if (amount == null || amount == DBNull.Value) return "-";
        return "Rs. " + Convert.ToDecimal(amount).ToString("N0", CultureInfo.InvariantCulture);
    }

    public static string Img(object url)
    {
        string u = Convert.ToString(url);
        if (string.IsNullOrEmpty(u)) u = "~/Images/Products/placeholder.svg";
        return VirtualPathUtility.ToAbsolute(u);
    }

    public static string StatusCss(object status)
    {
        return "badge badge-" + Convert.ToString(status).ToLower().Replace(" ", "-");
    }

    public static decimal DeliveryFee(decimal subTotal)
    {
        decimal fee = decimal.Parse(ConfigurationManager.AppSettings["DeliveryFee"], CultureInfo.InvariantCulture);
        decimal freeOver = decimal.Parse(ConfigurationManager.AppSettings["FreeDeliveryOver"], CultureInfo.InvariantCulture);
        if (subTotal >= freeOver)
        {
            return 0;   // free delivery on big orders
        }
        return fee;
    }

    // ---------- Loyalty ----------
    /// <summary>1 point for every Rs. 100 spent. 1 point = Rs. 1 discount.</summary>
    public static int PointsEarned(decimal total)
    {
        return (int)Math.Floor(total / 100m);
    }

    public static string Tier(int points)
    {
        if (points >= 500) return "Gold";
        if (points >= 200) return "Silver";
        return "Bronze";
    }

    public static int NextTierAt(int points)
    {
        if (points >= 500) return 0;     // already Gold
        if (points >= 200) return 500;   // Silver -> Gold
        return 200;                      // Bronze -> Silver
    }

    // ---------- Cart ----------
    public static int CartCount(int userId)
    {
        if (userId == 0) return 0;
        object o = Db.Scalar("SELECT ISNULL(SUM(Quantity),0) FROM CartItems WHERE UserID = @u", Db.Param("@u", userId));
        return Convert.ToInt32(o);
    }

    /// <summary>Adds a product to the cart. Returns an error message, or null on success.</summary>
    public static string AddToCart(int userId, int productId, int qty)
    {
        DataRow p = Db.Row("SELECT ProductName, Stock, IsActive FROM Products WHERE ProductID = @p", Db.Param("@p", productId));
        if (p == null || !(bool)p["IsActive"]) return "This product is no longer available.";

        int stock = (int)p["Stock"];
        object inCartObj = Db.Scalar("SELECT Quantity FROM CartItems WHERE UserID = @u AND ProductID = @p",
            Db.Param("@u", userId), Db.Param("@p", productId));
        int inCart = 0;
        if (inCartObj != null)
        {
            inCart = Convert.ToInt32(inCartObj);
        }

        if (stock <= 0) return p["ProductName"] + " is sold out today.";
        if (inCart + qty > stock) return "Only " + stock + " left in stock (you already have " + inCart + " in your cart).";

        if (inCartObj == null)
            Db.Execute("INSERT INTO CartItems (UserID, ProductID, Quantity) VALUES (@u, @p, @q)",
                Db.Param("@u", userId), Db.Param("@p", productId), Db.Param("@q", qty));
        else
            Db.Execute("UPDATE CartItems SET Quantity = Quantity + @q WHERE UserID = @u AND ProductID = @p",
                Db.Param("@u", userId), Db.Param("@p", productId), Db.Param("@q", qty));
        return null;
    }

    // ---------- Order status changes ----------
    /// <summary>
    /// Changes an order's status, records history, notifies the customer by e-mail, and applies
    /// side effects (loyalty points on delivery, stock and points refund on cancellation).
    /// </summary>
    public static void UpdateOrderStatus(int orderId, string newStatus)
    {
        DataRow o = Db.Row("SELECT UserID, Status, TotalAmount, PointsDiscount FROM Orders WHERE OrderID = @o", Db.Param("@o", orderId));
        if (o == null) return;
        string old = o["Status"].ToString();
        if (old == newStatus || old == Cancelled || old == Delivered) return;

        int userId = (int)o["UserID"];
        using (SqlConnection con = new SqlConnection(Db.ConnStr))
        {
            con.Open();
            SqlTransaction tx = con.BeginTransaction();
            try
            {
                Db.ExecuteTx(con, tx, "UPDATE Orders SET Status = @s WHERE OrderID = @o", Db.Param("@s", newStatus), Db.Param("@o", orderId));
                Db.ExecuteTx(con, tx, "INSERT INTO OrderStatusHistory (OrderID, Status) VALUES (@o, @s)", Db.Param("@o", orderId), Db.Param("@s", newStatus));

                if (newStatus == Delivered)
                {
                    int pts = PointsEarned((decimal)o["TotalAmount"]);
                    Db.ExecuteTx(con, tx, "UPDATE Users SET LoyaltyPoints = LoyaltyPoints + @p WHERE UserID = @u", Db.Param("@p", pts), Db.Param("@u", userId));
                    Db.ExecuteTx(con, tx, "INSERT INTO LoyaltyTransactions (UserID, OrderID, Points, Description) VALUES (@u, @o, @p, @d)",
                        Db.Param("@u", userId), Db.Param("@o", orderId), Db.Param("@p", pts), Db.Param("@d", "Earned on order #" + orderId));
                    Db.ExecuteTx(con, tx, "UPDATE Payments SET PaymentStatus = 'Paid', PaidAt = GETDATE() WHERE OrderID = @o AND PaymentStatus = 'Unpaid'", Db.Param("@o", orderId));
                }
                else if (newStatus == Cancelled)
                {
                    // Put the items back into stock
                    Db.ExecuteTx(con, tx, "UPDATE p SET p.Stock = p.Stock + oi.Quantity FROM Products p JOIN OrderItems oi ON oi.ProductID = p.ProductID WHERE oi.OrderID = @o", Db.Param("@o", orderId));
                    // Give back any loyalty points used
                    int used = (int)(decimal)o["PointsDiscount"];
                    if (used > 0)
                    {
                        Db.ExecuteTx(con, tx, "UPDATE Users SET LoyaltyPoints = LoyaltyPoints + @p WHERE UserID = @u", Db.Param("@p", used), Db.Param("@u", userId));
                        Db.ExecuteTx(con, tx, "INSERT INTO LoyaltyTransactions (UserID, OrderID, Points, Description) VALUES (@u, @o, @p, @d)",
                            Db.Param("@u", userId), Db.Param("@o", orderId), Db.Param("@p", used), Db.Param("@d", "Refunded from cancelled order #" + orderId));
                    }
                    Db.ExecuteTx(con, tx, "UPDATE Payments SET PaymentStatus = CASE WHEN PaymentStatus = 'Paid' THEN 'Refunded' ELSE 'Void' END WHERE OrderID = @o", Db.Param("@o", orderId));
                }
                tx.Commit();
            }
            catch
            {
                tx.Rollback();
                throw;
            }
        }

        Notify.Send(userId, orderId, "Order #" + orderId + " is now " + newStatus, StatusMessage(newStatus, orderId), true);
    }

    public static string StatusMessage(string status, int orderId)
    {
        switch (status)
        {
            case Confirmed: return "Good news! The bakery has confirmed order #" + orderId + " and our bakers are preparing it.";
            case OutForDelivery: return "Order #" + orderId + " has been sent out for delivery. Please keep your phone nearby.";
            case ReadyForPickup: return "Order #" + orderId + " is ready! Please collect it from the bakery in your chosen time slot.";
            case Delivered: return "Order #" + orderId + " has been delivered. Enjoy, and please rate your treats! Loyalty points have been added.";
            case Cancelled: return "Order #" + orderId + " has been cancelled. Any payment or points used will be refunded.";
            default: return "Order #" + orderId + " status: " + status + ".";
        }
    }
}
