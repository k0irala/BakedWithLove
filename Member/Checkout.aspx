<%@ Page Title="Checkout | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Checkout.aspx.cs" Inherits="Member_Checkout" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <p class="small"><a href="Cart.aspx">&larr; Back to cart</a></p>
    <h1 class="page-title">Checkout</h1>

    <asp:Label ID="lblError" runat="server" CssClass="alert alert-error" Visible="false" style="display:block" />
    <asp:ValidationSummary runat="server" CssClass="validation-summary" HeaderText="Please check your details:" ValidationGroup="checkout" />

    <div class="two-col">
        <div class="stack">

            <%-- 1. Delivery or pickup --%>
            <section class="card">
                <h2>1. How would you like it?</h2>
                <div class="radio-cards" style="grid-template-columns:1fr 1fr">
                    <div><asp:RadioButton ID="rbDelivery" runat="server" GroupName="deliveryType" Checked="true" Text="&#128666; Delivery" AutoPostBack="true" OnCheckedChanged="Recalculate" /></div>
                    <div><asp:RadioButton ID="rbPickup" runat="server" GroupName="deliveryType" Text="&#128717; Pickup (free)" AutoPostBack="true" OnCheckedChanged="Recalculate" /></div>
                </div>

                <div class="field-row" style="margin-top:14px">
                    <div class="field">
                        <label for="<%= txtDate.ClientID %>">Date</label>
                        <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDate" ErrorMessage="Choose a delivery or pickup date." Text="Required." CssClass="error" Display="Dynamic" ValidationGroup="checkout" />
                        <asp:CustomValidator ID="cvDate" runat="server" ControlToValidate="txtDate" OnServerValidate="cvDate_ServerValidate" ErrorMessage="Date must be between today and 30 days from now." Text="Choose a date within the next 30 days." CssClass="error" Display="Dynamic" ValidationGroup="checkout" />
                    </div>
                    <div class="field">
                        <label for="<%= txtPhone.ClientID %>">Contact number</label>
                        <asp:TextBox ID="txtPhone" runat="server" TextMode="Phone" MaxLength="10" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPhone" ErrorMessage="Contact number is required." Text="Required." CssClass="error" Display="Dynamic" ValidationGroup="checkout" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPhone" ValidationExpression="^9[78]\d{8}$" ErrorMessage="Enter a valid 10-digit mobile number." Text="10 digits starting 97/98." CssClass="error" Display="Dynamic" ValidationGroup="checkout" />
                    </div>
                </div>

                <div data-show-when="deliveryType=rbDelivery">
                    <div class="field">
                        <label for="<%= txtAddress.ClientID %>">Delivery address</label>
                        <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="2" MaxLength="250" />
                        <asp:CustomValidator ID="cvAddress" runat="server" OnServerValidate="cvAddress_ServerValidate" ValidateEmptyText="true" ControlToValidate="txtAddress" ErrorMessage="Delivery address is required." Text="Required for delivery." CssClass="error" Display="Dynamic" ValidationGroup="checkout" />
                    </div>
                </div>

                <div data-show-when="deliveryType=rbPickup">
                    <div class="field">
                        <label for="<%= ddlSlot.ClientID %>">Pickup time slot</label>
                        <asp:DropDownList ID="ddlSlot" runat="server" DataTextField="SlotLabel" DataValueField="SlotID" AppendDataBoundItems="true">
                            <asp:ListItem Value="">-- Choose a time --</asp:ListItem>
                        </asp:DropDownList>
                        <asp:CustomValidator ID="cvSlot" runat="server" OnServerValidate="cvSlot_ServerValidate" ValidateEmptyText="true" ControlToValidate="ddlSlot" ErrorMessage="Please choose an available pickup slot." Text="Choose a slot." CssClass="error" Display="Dynamic" ValidationGroup="checkout" />
                        <div class="hint">Pick up from New Baneshwor, Kathmandu. Each slot has limited space.</div>
                    </div>
                </div>
            </section>

            <%-- 2. Gift --%>
            <section class="card">
                <h2>2. Is this a gift? &#127873;</h2>
                <asp:CheckBox ID="chkGift" runat="server" Text=" Yes, send it to someone else" CssClass="check" />
                <div data-show-when="chkGift=on" style="margin-top:12px">
                    <p class="hint">Ordering from abroad? We'll deliver to your loved one and call them before we arrive. Gift orders are delivered to the recipient's address.</p>
                    <div class="field-row">
                        <div class="field">
                            <label for="<%= txtRecipient.ClientID %>">Recipient's name</label>
                            <asp:TextBox ID="txtRecipient" runat="server" MaxLength="100" />
                            <asp:CustomValidator ID="cvRecipient" runat="server" OnServerValidate="GiftField_ServerValidate" ValidateEmptyText="true" ControlToValidate="txtRecipient" ErrorMessage="Recipient's name is required for gifts." Text="Required." CssClass="error" Display="Dynamic" ValidationGroup="checkout" />
                        </div>
                        <div class="field">
                            <label for="<%= txtRecipientPhone.ClientID %>">Recipient's local number</label>
                            <asp:TextBox ID="txtRecipientPhone" runat="server" TextMode="Phone" MaxLength="10" />
                            <asp:CustomValidator ID="cvRecipientPhone" runat="server" OnServerValidate="GiftPhone_ServerValidate" ValidateEmptyText="true" ControlToValidate="txtRecipientPhone" ErrorMessage="Enter the recipient's 10-digit mobile number." Text="10 digits starting 97/98." CssClass="error" Display="Dynamic" ValidationGroup="checkout" />
                        </div>
                    </div>
                    <div class="field">
                        <label for="<%= txtRecipientAddress.ClientID %>">Recipient's address</label>
                        <asp:TextBox ID="txtRecipientAddress" runat="server" TextMode="MultiLine" Rows="2" MaxLength="250" />
                        <asp:CustomValidator ID="cvRecipientAddress" runat="server" OnServerValidate="GiftField_ServerValidate" ValidateEmptyText="true" ControlToValidate="txtRecipientAddress" ErrorMessage="Recipient's address is required for gifts." Text="Required." CssClass="error" Display="Dynamic" ValidationGroup="checkout" />
                    </div>
                    <div class="field">
                        <label for="<%= txtGiftMessage.ClientID %>">Gift message (printed on a card)</label>
                        <asp:TextBox ID="txtGiftMessage" runat="server" TextMode="MultiLine" Rows="2" MaxLength="300" placeholder="Happy Birthday Mum! Love from London." />
                    </div>
                </div>
            </section>

            <%-- 3. Payment --%>
            <section class="card">
                <h2>3. Payment</h2>
                <div class="radio-cards">
                    <div><asp:RadioButton ID="rbCOD" runat="server" GroupName="payment" Checked="true" Text="&#128181; Cash on Delivery" /></div>
                    <div><asp:RadioButton ID="rbEsewa" runat="server" GroupName="payment" Text="&#128154; eSewa" /></div>
                    <div><asp:RadioButton ID="rbKhalti" runat="server" GroupName="payment" Text="&#128156; Khalti" /></div>
                    <div><asp:RadioButton ID="rbCard" runat="server" GroupName="payment" Text="&#128179; Card" /></div>
                </div>
                <p class="hint">Online payments are simulated for this prototype - no real money is taken.</p>

                <asp:PlaceHolder ID="phPoints" runat="server">
                    <div class="field" style="margin-top:12px">
                        <asp:CheckBox ID="chkPoints" runat="server" CssClass="check" AutoPostBack="true" OnCheckedChanged="Recalculate" />
                    </div>
                </asp:PlaceHolder>

                <div class="field">
                    <label for="<%= txtNotes.ClientID %>">Notes for the bakery (allergies, delivery instructions)</label>
                    <asp:TextBox ID="txtNotes" runat="server" TextMode="MultiLine" Rows="2" MaxLength="500" />
                </div>
            </section>
        </div>

        <aside class="card">
            <h2>Your order</h2>
            <asp:Repeater ID="rptItems" runat="server">
                <ItemTemplate>
                    <div class="summary-line small">
                        <span><%# Eval("Quantity") %> &times; <%# Server.HtmlEncode(Eval("ProductName").ToString()) %></span>
                        <span><%# Shop.Money(Eval("LineTotal")) %></span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <hr style="border:0;border-top:1px solid var(--line)" />
            <div class="summary-line"><span>Subtotal</span><span><asp:Literal ID="litSubtotal" runat="server" /></span></div>
            <div class="summary-line"><span>Delivery</span><span><asp:Literal ID="litFee" runat="server" /></span></div>
            <asp:PlaceHolder ID="phDiscount" runat="server" Visible="false">
                <div class="summary-line" style="color:var(--green)"><span>Loyalty points</span><span>- <asp:Literal ID="litDiscount" runat="server" /></span></div>
            </asp:PlaceHolder>
            <div class="summary-line total"><span>Total</span><span><asp:Literal ID="litTotal" runat="server" /></span></div>
            <p class="hint">You'll earn <strong><asp:Literal ID="litEarn" runat="server" /> points</strong> when this order is delivered.</p>
            <asp:Button ID="btnPlace" runat="server" Text="Place order" CssClass="btn btn-block" OnClick="btnPlace_Click" ValidationGroup="checkout" OnClientClick="if (typeof(Page_ClientValidate) == 'function' && !Page_ClientValidate('checkout')) return false; this.value='Placing order...';" UseSubmitBehavior="false" />
        </aside>
    </div>
</asp:Content>
