<%@ Page Title="Orders | Bakery Admin" Language="C#" MasterPageFile="~/Admin/Admin.master" AutoEventWireup="true" CodeFile="Orders.aspx.cs" Inherits="Admin_Orders" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===== Order detail ===== --%>
    <asp:Panel ID="pnlDetail" runat="server" Visible="false">
        <p class="small"><a href="Orders.aspx">&larr; All orders</a></p>
        <div class="row between">
            <h1 class="page-title" style="margin:0">Order #<asp:Literal ID="litId" runat="server" /> <asp:Literal ID="litGiftIcon" runat="server" /></h1>
            <asp:Label ID="lblStatus" runat="server" />
        </div>

        <div class="card section">
            <bwl:OrderTimeline ID="timeline" runat="server" />
            <asp:Panel ID="pnlUpdate" runat="server" CssClass="row" style="margin-top:18px">
                <label for="<%= ddlNext.ClientID %>" class="label" style="margin:0">Move to:</label>
                <asp:DropDownList ID="ddlNext" runat="server" CssClass="input" style="width:auto" />
                <asp:Button ID="btnUpdate" runat="server" Text="Update status and notify customer" CssClass="btn btn-small" OnClick="btnUpdate_Click"
                    OnClientClick="return confirm('Change the status? The customer will be emailed.');" />
            </asp:Panel>
            <asp:Label ID="lblFinal" runat="server" CssClass="muted small" Visible="false" Text="This order is complete - no further changes." />
        </div>

        <div class="two-col-even">
            <div class="card">
                <h2>Items</h2>
                <asp:GridView ID="gvItems" runat="server" AutoGenerateColumns="false" CssClass="grid-table" GridLines="None">
                    <Columns>
                        <asp:BoundField DataField="ProductName" HeaderText="Item" />
                        <asp:BoundField DataField="Quantity" HeaderText="Qty" />
                        <asp:TemplateField HeaderText="Unit"><ItemTemplate><%# Shop.Money(Eval("UnitPrice")) %></ItemTemplate></asp:TemplateField>
                        <asp:TemplateField HeaderText="Line"><ItemTemplate><%# Shop.Money((decimal)Eval("UnitPrice") * (int)Eval("Quantity")) %></ItemTemplate></asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <div class="summary-line"><span>Subtotal</span><asp:Literal ID="litSub" runat="server" /></div>
                <div class="summary-line"><span>Delivery</span><asp:Literal ID="litFee" runat="server" /></div>
                <div class="summary-line"><span>Points used</span><asp:Literal ID="litPts" runat="server" /></div>
                <div class="summary-line total"><span>Total</span><asp:Literal ID="litTotal" runat="server" /></div>
            </div>

            <div class="stack">
                <div class="card small">
                    <h2>Customer &amp; delivery</h2>
                    <asp:DetailsView ID="dvOrder" runat="server" AutoGenerateRows="false" CssClass="details-table" GridLines="None">
                        <Fields>
                            <asp:BoundField DataField="FullName" HeaderText="Customer" />
                            <asp:BoundField DataField="Email" HeaderText="Email" />
                            <asp:BoundField DataField="ContactPhone" HeaderText="Phone" />
                            <asp:BoundField DataField="OrderDate" HeaderText="Ordered" DataFormatString="{0:dd MMM yyyy, h:mm tt}" />
                            <asp:BoundField DataField="DeliveryType" HeaderText="Method" />
                            <asp:BoundField DataField="PreferredDate" HeaderText="For date" DataFormatString="{0:ddd dd MMM yyyy}" />
                            <asp:BoundField DataField="SlotLabel" HeaderText="Pickup slot" NullDisplayText="-" />
                            <asp:BoundField DataField="DeliveryAddress" HeaderText="Address" NullDisplayText="-" />
                            <asp:BoundField DataField="Notes" HeaderText="Notes / allergies" NullDisplayText="-" />
                            <asp:BoundField DataField="PaymentMethod" HeaderText="Payment" />
                            <asp:TemplateField HeaderText="Payment status"><ItemTemplate><span class='<%# Shop.StatusCss(Eval("PaymentStatus")) %>'><%# Eval("PaymentStatus") %></span></ItemTemplate></asp:TemplateField>
                            <asp:BoundField DataField="TransactionRef" HeaderText="Reference" NullDisplayText="-" />
                        </Fields>
                    </asp:DetailsView>
                </div>
                <asp:Panel ID="pnlGift" runat="server" CssClass="card small" Visible="false">
                    <h2>&#127873; Gift delivery</h2>
                    <p><strong><asp:Literal ID="litRecipient" runat="server" /></strong><br /><asp:Literal ID="litRecipientInfo" runat="server" /></p>
                    <p style="font-style:italic">Card message: &ldquo;<asp:Literal ID="litGiftMsg" runat="server" />&rdquo;</p>
                </asp:Panel>
            </div>
        </div>
    </asp:Panel>

    <%-- ===== Order list ===== --%>
    <asp:Panel ID="pnlList" runat="server">
        <h1 class="page-title">Orders</h1>
        <nav class="tabs" aria-label="Filter by status">
            <asp:Repeater ID="rptTabs" runat="server">
                <ItemTemplate><a href='Orders.aspx<%# Eval("Query") %>' class='<%# Eval("Css") %>'><%# Eval("Label") %> (<%# Eval("Count") %>)</a></ItemTemplate>
            </asp:Repeater>
        </nav>

        <div class="table-wrap">
            <asp:GridView ID="gvOrders" runat="server" AutoGenerateColumns="false" CssClass="grid-table" GridLines="None"
                AllowPaging="true" PageSize="12" PagerStyle-CssClass="pager" OnPageIndexChanging="gvOrders_PageIndexChanging"
                EmptyDataText="No orders with this status.">
                <Columns>
                    <asp:HyperLinkField DataTextField="OrderID" DataTextFormatString="#{0}" DataNavigateUrlFields="OrderID" DataNavigateUrlFormatString="Orders.aspx?id={0}" HeaderText="Order" />
                    <asp:BoundField DataField="OrderDate" HeaderText="Placed" DataFormatString="{0:dd MMM, h:mm tt}" />
                    <asp:BoundField DataField="FullName" HeaderText="Customer" />
                    <asp:TemplateField HeaderText="Type"><ItemTemplate><%# Eval("DeliveryType") %><%# (bool)Eval("IsGift") ? " &#127873;" : "" %></ItemTemplate></asp:TemplateField>
                    <asp:BoundField DataField="PreferredDate" HeaderText="For" DataFormatString="{0:dd MMM}" />
                    <asp:TemplateField HeaderText="Total"><ItemTemplate><%# Shop.Money(Eval("TotalAmount")) %></ItemTemplate></asp:TemplateField>
                    <asp:TemplateField HeaderText="Payment"><ItemTemplate><span class='<%# Shop.StatusCss(Eval("PaymentStatus")) %>'><%# Eval("PaymentMethod") %></span></ItemTemplate></asp:TemplateField>
                    <asp:TemplateField HeaderText="Status"><ItemTemplate><span class='<%# Shop.StatusCss(Eval("Status")) %>'><%# Eval("Status") %></span></ItemTemplate></asp:TemplateField>
                    <asp:HyperLinkField Text="Manage &rarr;" DataNavigateUrlFields="OrderID" DataNavigateUrlFormatString="Orders.aspx?id={0}" />
                </Columns>
            </asp:GridView>
        </div>
    </asp:Panel>
</asp:Content>
