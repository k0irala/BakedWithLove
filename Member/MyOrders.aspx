<%@ Page Title="My Orders | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="MyOrders.aspx.cs" Inherits="Member_MyOrders" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- Shown right after checkout (matches the "Thank you" wireframe) --%>
    <asp:Panel ID="pnlPlaced" runat="server" Visible="false" CssClass="card empty-state pop" style="margin-bottom:18px">
        <span class="ico">&#9989;</span>
        <h1>Thank you!</h1>
        <p>Your order <strong>#<asp:Literal ID="litPlacedId" runat="server" /></strong> has been placed. We've sent a confirmation to your email and will let you know as soon as the bakery confirms it.</p>
        <a class="btn btn-outline" href="../Menu.aspx">Keep shopping</a>
    </asp:Panel>

    <%-- ===== Single order detail ===== --%>
    <asp:Panel ID="pnlDetail" runat="server" Visible="false">
        <p class="small"><a href="MyOrders.aspx">&larr; All orders</a></p>
        <div class="row between">
            <h1 class="page-title" style="margin:0">Order #<asp:Literal ID="litOrderId" runat="server" /></h1>
            <asp:Label ID="lblStatus" runat="server" />
        </div>
        <p class="muted small">Placed <asp:Literal ID="litDate" runat="server" /></p>

        <div class="card">
            <h2>Tracking</h2>
            <bwl:OrderTimeline ID="timeline" runat="server" />
            <p class="small" style="margin-top:14px"><asp:Literal ID="litStatusMsg" runat="server" /></p>
        </div>

        <div class="two-col-even section">
            <div class="card">
                <h2>Items</h2>
                <%-- GridView bound to the order's items --%>
                <asp:GridView ID="gvItems" runat="server" AutoGenerateColumns="false" CssClass="grid-table" GridLines="None" OnRowDataBound="gvItems_RowDataBound">
                    <Columns>
                        <asp:BoundField DataField="ProductName" HeaderText="Item" HtmlEncode="true" />
                        <asp:BoundField DataField="Quantity" HeaderText="Qty" />
                        <asp:TemplateField HeaderText="Price"><ItemTemplate><%# Shop.Money(Eval("UnitPrice")) %></ItemTemplate></asp:TemplateField>
                        <asp:TemplateField HeaderText="">
                            <ItemTemplate>
                                <asp:HyperLink ID="lnkRate" runat="server" CssClass="btn btn-small btn-outline" NavigateUrl='<%# "~/Product.aspx?id=" + Eval("ProductID") + "#review" %>' Text="&#11088; Rate" Visible="false" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <div class="summary-line"><span>Subtotal</span><span><asp:Literal ID="litSub" runat="server" /></span></div>
                <div class="summary-line"><span>Delivery</span><span><asp:Literal ID="litFee" runat="server" /></span></div>
                <div class="summary-line"><span>Points discount</span><span><asp:Literal ID="litPts" runat="server" /></span></div>
                <div class="summary-line total"><span>Total</span><span><asp:Literal ID="litTotal" runat="server" /></span></div>
            </div>

            <div class="stack">
                <div class="card small">
                    <h2>Details</h2>
                    <%-- DetailsView shows one order's delivery and payment info --%>
                    <asp:DetailsView ID="dvOrder" runat="server" AutoGenerateRows="false" CssClass="details-table" GridLines="None">
                        <Fields>
                            <asp:BoundField DataField="DeliveryType" HeaderText="Method" />
                            <asp:BoundField DataField="PreferredDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="SlotLabel" HeaderText="Pickup slot" NullDisplayText="-" />
                            <asp:BoundField DataField="DeliveryAddress" HeaderText="Address" NullDisplayText="Bakery counter, New Baneshwor" />
                            <asp:BoundField DataField="ContactPhone" HeaderText="Phone" />
                            <asp:BoundField DataField="PaymentMethod" HeaderText="Payment" />
                            <asp:TemplateField HeaderText="Payment status"><ItemTemplate><span class='<%# Shop.StatusCss(Eval("PaymentStatus")) %>'><%# Eval("PaymentStatus") %></span></ItemTemplate></asp:TemplateField>
                            <asp:BoundField DataField="TransactionRef" HeaderText="Reference" NullDisplayText="-" />
                            <asp:BoundField DataField="Notes" HeaderText="Notes" NullDisplayText="-" />
                        </Fields>
                    </asp:DetailsView>
                </div>

                <asp:Panel ID="pnlGift" runat="server" CssClass="card small" Visible="false">
                    <h2>&#127873; Gift for <asp:Literal ID="litRecipient" runat="server" /></h2>
                    <p><asp:Literal ID="litRecipientInfo" runat="server" /></p>
                    <p style="font-style:italic">&ldquo;<asp:Literal ID="litGiftMsg" runat="server" />&rdquo;</p>
                </asp:Panel>

                <asp:Panel ID="pnlCancel" runat="server" CssClass="card small" Visible="false">
                    <p>Changed your mind? You can cancel while the order is still pending.</p>
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel this order" CssClass="btn btn-danger btn-small" OnClick="btnCancel_Click"
                        OnClientClick="return confirm('Cancel this order? Any payment and points will be refunded.');" CausesValidation="false" />
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>

    <%-- ===== Order list ===== --%>
    <asp:Panel ID="pnlList" runat="server">
        <h1 class="page-title">My Orders</h1>
        <nav class="tabs" aria-label="Order filter">
            <a href="MyOrders.aspx" class='<%= Tab == "current" ? "active" : "" %>'>Current</a>
            <a href="MyOrders.aspx?tab=history" class='<%= Tab == "history" ? "active" : "" %>'>Purchase history</a>
            <a href="CustomCake.aspx">Custom cake requests</a>
        </nav>

        <asp:Repeater ID="rptOrders" runat="server">
            <ItemTemplate>
                <a class="card" href='MyOrders.aspx?id=<%# Eval("OrderID") %>' style="display:block;margin-bottom:12px;color:inherit;text-decoration:none">
                    <div class="row between">
                        <strong>Order #<%# Eval("OrderID") %><%# (bool)Eval("IsGift") ? " &#127873;" : "" %></strong>
                        <span class='<%# Shop.StatusCss(Eval("Status")) %>'><%# Eval("Status") %></span>
                    </div>
                    <div class="muted small"><%# ((DateTime)Eval("OrderDate")).ToString("dd MMM yyyy, h:mm tt") %> &middot; <%# Eval("DeliveryType") %> &middot; <%# Eval("ItemCount") %> item(s)</div>
                    <div class="small" style="margin-top:4px"><%# Server.HtmlEncode(Convert.ToString(Eval("ItemNames"))) %></div>
                    <div class="row between" style="margin-top:6px">
                        <strong style="color:var(--pink)"><%# Shop.Money(Eval("TotalAmount")) %></strong>
                        <span class="small">Track &rarr;</span>
                    </div>
                </a>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlNone" runat="server" Visible="false" CssClass="card empty-state">
            <span class="ico">&#128230;</span>
            <asp:Literal ID="litNone" runat="server" />
            <p><a class="btn" href="../Menu.aspx">Start an order</a></p>
        </asp:Panel>
    </asp:Panel>
</asp:Content>
