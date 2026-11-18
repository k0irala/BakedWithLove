using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Member_Checkout : Page
{
    private DataTable cart;
    private int userPoints;

    protected void Page_Load(object sender, EventArgs e)
    {
        cart = Db.Query(Shop.CartSql, Db.Param("@u", Auth.UserId));
        if (cart.Rows.Count == 0)
        {
            Response.Redirect("~/Member/Cart.aspx");
            return;
        }
        userPoints = Convert.ToInt32(Db.Scalar("SELECT LoyaltyPoints FROM Users WHERE UserID = @u", Db.Param("@u", Auth.UserId)));

        if (!IsPostBack)
        {
            DataRow u = Db.Row("SELECT Phone, Address FROM Users WHERE UserID = @u", Db.Param("@u", Auth.UserId));
            txtPhone.Text = Convert.ToString(u["Phone"]);
            txtAddress.Text = Convert.ToString(u["Address"]);
            txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtDate.Attributes["min"] = DateTime.Today.ToString("yyyy-MM-dd");
            txtDate.Attributes["max"] = DateTime.Today.AddDays(30).ToString("yyyy-MM-dd");

            ddlSlot.DataSource = Db.Query("SELECT SlotID, SlotLabel FROM PickupSlots WHERE IsActive = 1 ORDER BY SlotID");
            ddlSlot.DataBind();

            rptItems.DataSource = cart;
            rptItems.DataBind();
        }
        Recalculate(null, null);
    }

    // ---------- Totals ----------
    private decimal Subtotal
    {
        get
        {
            decimal s = 0;
            foreach (DataRow r in cart.Rows) s += (decimal)r["LineTotal"];
            return s;
        }
    }

    private decimal Fee
    {
        get
        {
            if (rbPickup.Checked)
            {
                return 0;   // pickup is always free
            }
            return Shop.DeliveryFee(Subtotal);
        }
    }

    /// <summary>Points can pay for up to half of the subtotal (1 point = Rs. 1).</summary>
    private int MaxPointsUsable { get { return (int)Math.Min(userPoints, Math.Floor(Subtotal / 2)); } }

    private int PointsUsed
    {
        get
        {
            if (chkPoints.Checked)
            {
                return MaxPointsUsable;
            }
            return 0;
        }
    }

    protected void Recalculate(object sender, EventArgs e)
    {
        phPoints.Visible = MaxPointsUsable > 0;
        chkPoints.Text = " Use " + MaxPointsUsable + " loyalty points (save " + Shop.Money(MaxPointsUsable) + ") - you have " + userPoints;

        decimal total = Subtotal + Fee - PointsUsed;
        litSubtotal.Text = Shop.Money(Subtotal);
        if (rbPickup.Checked)
        {
            litFee.Text = "Free (pickup)";
        }
        else if (Fee == 0)
        {
            litFee.Text = "FREE";
        }
        else
        {
            litFee.Text = Shop.Money(Fee) + " <span class='muted small'>(pickup is free)</span>";
        }
        phDiscount.Visible = PointsUsed > 0;
        litDiscount.Text = Shop.Money(PointsUsed);
        litTotal.Text = Shop.Money(total);
        litEarn.Text = Shop.PointsEarned(total).ToString();
    }

    // ---------- Validation ----------
    /// <summary>
    /// Reads the date box (format yyyy-MM-dd). Returns false if the text is not a valid date.
    /// </summary>
    private bool TryGetChosenDate(out DateTime date)
    {
        return DateTime.TryParseExact(txtDate.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out date);
    }

    protected void cvDate_ServerValidate(object source, ServerValidateEventArgs args)
    {
        // The date must be between today and 30 days from now
        DateTime date;
        if (!TryGetChosenDate(out date))
        {
            args.IsValid = false;
            return;
        }
        args.IsValid = date >= DateTime.Today && date <= DateTime.Today.AddDays(30);
    }

    protected void cvAddress_ServerValidate(object source, ServerValidateEventArgs args)
    {
        // Address needed only for delivery that is not a gift (gifts use the recipient's address)
        args.IsValid = !rbDelivery.Checked || chkGift.Checked || args.Value.Trim().Length >= 5;
    }

    protected void cvSlot_ServerValidate(object source, ServerValidateEventArgs args)
    {
        // A time slot is only needed for pickup orders
        if (!rbPickup.Checked)
        {
            args.IsValid = true;
            return;
        }

        int slotId;
        DateTime date;
        if (!int.TryParse(args.Value, out slotId) || !TryGetChosenDate(out date))
        {
            args.IsValid = false;
            return;
        }

        // Places left = slot capacity minus orders already booked for that slot on that day
        object placesLeft = Db.Scalar("SELECT s.Capacity - (SELECT COUNT(*) FROM Orders o WHERE o.SlotID = s.SlotID AND o.PreferredDate = @d AND o.Status <> 'Cancelled') " +
            "FROM PickupSlots s WHERE s.SlotID = @s AND s.IsActive = 1", Db.Param("@s", slotId), Db.Param("@d", date));
        args.IsValid = placesLeft != null && Convert.ToInt32(placesLeft) > 0;
        if (!args.IsValid)
        {
            cvSlot.ErrorMessage = "That pickup slot is full on " + date.ToString("dd MMM") + ". Please choose another time.";
        }
    }

    protected void GiftField_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = !chkGift.Checked || args.Value.Trim().Length >= 2;
    }

    protected void GiftPhone_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = !chkGift.Checked || Regex.IsMatch(args.Value.Trim(), @"^9[78]\d{8}$");
    }

    // ---------- Place order ----------
    protected void btnPlace_Click(object sender, EventArgs e)
    {
        Page.Validate("checkout");
        if (!Page.IsValid) return;

        // ----- 1. Work out all the values for the order -----
        bool gift = chkGift.Checked;
        bool pickup = rbPickup.Checked;
        int pointsUsed = PointsUsed;
        decimal subtotal = Subtotal;
        decimal fee = Fee;
        decimal total = subtotal + fee - pointsUsed;

        DateTime chosenDate;
        TryGetChosenDate(out chosenDate);   // already checked by cvDate

        string deliveryType = "Delivery";
        if (pickup)
        {
            deliveryType = "Pickup";
        }

        // Address: none for pickup, the recipient's address for a gift, otherwise the customer's own
        string address = null;
        if (!pickup && gift)
        {
            address = txtRecipientAddress.Text.Trim();
        }
        else if (!pickup)
        {
            address = txtAddress.Text.Trim();
        }

        object slotId = null;   // only pickup orders have a time slot
        if (pickup)
        {
            slotId = int.Parse(ddlSlot.SelectedValue);
        }

        string notes = null;
        if (txtNotes.Text.Trim() != "")
        {
            notes = txtNotes.Text.Trim();
        }

        string giftMessage = null;
        if (txtGiftMessage.Text.Trim() != "")
        {
            giftMessage = txtGiftMessage.Text.Trim();
        }

        // Simulated payment: online methods are marked Paid with a made-up reference number;
        // cash is paid when the order is delivered.
        string method = "Cash on Delivery";
        string paymentStatus = "Unpaid";
        string transactionRef = null;
        object paidAt = null;
        string refPrefix = "";
        if (rbEsewa.Checked)
        {
            method = "eSewa";
            refPrefix = "ESW";
        }
        else if (rbKhalti.Checked)
        {
            method = "Khalti";
            refPrefix = "KHL";
        }
        else if (rbCard.Checked)
        {
            method = "Card";
            refPrefix = "CRD";
        }

        if (method != "Cash on Delivery")
        {
            paymentStatus = "Paid";
            transactionRef = refPrefix + "-" + DateTime.Now.ToString("yyMMddHHmmss");
            paidAt = DateTime.Now;
        }

        // ----- 2. Save everything in ONE transaction -----
        // A transaction means: either every step below is saved, or (if anything fails) nothing is.
        int orderId;

        using (SqlConnection con = new SqlConnection(Db.ConnStr))
        {
            con.Open();
            SqlTransaction tx = con.BeginTransaction();
            try
            {
                // Re-check stock inside the transaction so two customers can't buy the last cake
                foreach (DataRow r in cart.Rows)
                {
                    int ok = Db.ExecuteTx(con, tx, "UPDATE Products SET Stock = Stock - @q WHERE ProductID = @p AND Stock >= @q",
                        Db.Param("@q", r["Quantity"]), Db.Param("@p", r["ProductID"]));
                    if (ok == 0) throw new InvalidOperationException("Sorry, " + r["ProductName"] + " just sold out. Please update your cart.");
                }

                orderId = (int)Db.ScalarTx(con, tx,
                    "INSERT INTO Orders (UserID, SubTotal, DeliveryFee, PointsDiscount, TotalAmount, Status, DeliveryType, DeliveryAddress, ContactPhone, PreferredDate, SlotID, IsGift, Notes) " +
                    "VALUES (@u, @sub, @fee, @pts, @tot, 'Pending', @type, @addr, @phone, @date, @slot, @gift, @notes); SELECT CAST(SCOPE_IDENTITY() AS INT);",
                    Db.Param("@u", Auth.UserId), Db.Param("@sub", subtotal), Db.Param("@fee", fee), Db.Param("@pts", pointsUsed), Db.Param("@tot", total),
                    Db.Param("@type", deliveryType), Db.Param("@addr", address),
                    Db.Param("@phone", txtPhone.Text.Trim()), Db.Param("@date", chosenDate),
                    Db.Param("@slot", slotId), Db.Param("@gift", gift), Db.Param("@notes", notes));

                foreach (DataRow r in cart.Rows)
                {
                    Db.ExecuteTx(con, tx, "INSERT INTO OrderItems (OrderID, ProductID, ProductName, Quantity, UnitPrice) VALUES (@o, @p, @n, @q, @price)",
                        Db.Param("@o", orderId), Db.Param("@p", r["ProductID"]), Db.Param("@n", r["ProductName"]), Db.Param("@q", r["Quantity"]), Db.Param("@price", r["Price"]));
                }

                Db.ExecuteTx(con, tx, "INSERT INTO OrderStatusHistory (OrderID, Status) VALUES (@o, 'Pending')", Db.Param("@o", orderId));

                Db.ExecuteTx(con, tx, "INSERT INTO Payments (OrderID, PaymentMethod, Amount, PaymentStatus, TransactionRef, PaidAt) VALUES (@o, @m, @a, @s, @ref, @at)",
                    Db.Param("@o", orderId), Db.Param("@m", method), Db.Param("@a", total), Db.Param("@s", paymentStatus),
                    Db.Param("@ref", transactionRef), Db.Param("@at", paidAt));

                if (gift)
                {
                    Db.ExecuteTx(con, tx, "INSERT INTO GiftDetails (OrderID, RecipientName, RecipientPhone, RecipientAddress, GiftMessage) VALUES (@o, @n, @p, @a, @m)",
                        Db.Param("@o", orderId), Db.Param("@n", txtRecipient.Text.Trim()), Db.Param("@p", txtRecipientPhone.Text.Trim()),
                        Db.Param("@a", txtRecipientAddress.Text.Trim()), Db.Param("@m", giftMessage));
                }

                if (pointsUsed > 0)
                {
                    Db.ExecuteTx(con, tx, "UPDATE Users SET LoyaltyPoints = LoyaltyPoints - @p WHERE UserID = @u AND LoyaltyPoints >= @p", Db.Param("@p", pointsUsed), Db.Param("@u", Auth.UserId));
                    Db.ExecuteTx(con, tx, "INSERT INTO LoyaltyTransactions (UserID, OrderID, Points, Description) VALUES (@u, @o, @p, @d)",
                        Db.Param("@u", Auth.UserId), Db.Param("@o", orderId), Db.Param("@p", -pointsUsed), Db.Param("@d", "Redeemed on order #" + orderId));
                }

                Db.ExecuteTx(con, tx, "DELETE FROM CartItems WHERE UserID = @u", Db.Param("@u", Auth.UserId));
                tx.Commit();
            }
            catch (InvalidOperationException ex)
            {
                tx.Rollback();
                lblError.Text = Server.HtmlEncode(ex.Message);
                lblError.Visible = true;
                return;
            }
            catch
            {
                tx.Rollback();
                throw;
            }
        }

        // ----- 3. Tell the customer and show their order -----
        Notify.Send(Auth.UserId, orderId, "Order #" + orderId + " received",
            "Thank you! We have received your order for " + Shop.Money(total) + " (" + deliveryType.ToLower() + " on " +
            chosenDate.ToString("dd MMM yyyy") + "). Our bakers will confirm it shortly.", true);

        Response.Redirect("~/Member/MyOrders.aspx?placed=" + orderId);
    }
}
