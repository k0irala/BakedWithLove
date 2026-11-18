<%@ Page Title="Dashboard | Bakery Admin" Language="C#" MasterPageFile="~/Admin/Admin.master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="Admin_Dashboard" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">Good <%= DateTime.Now.Hour < 12 ? "morning" : DateTime.Now.Hour < 17 ? "afternoon" : "evening" %>, <%: Auth.FullName %>!</h1>

    <div class="stat-grid">
        <div class="stat"><div class="num"><asp:Literal ID="litTodaySales" runat="server" /></div><div class="lbl">Sales today</div></div>
        <div class="stat"><div class="num"><asp:Literal ID="litWeekSales" runat="server" /></div><div class="lbl">Sales last 7 days</div></div>
        <div class="stat" style="border-color:var(--amber)"><div class="num"><asp:Literal ID="litPending" runat="server" /></div><div class="lbl"><a href="Orders.aspx?status=Pending">Orders to confirm</a></div></div>
        <div class="stat" style="border-color:#5e35b1"><div class="num"><asp:Literal ID="litCustom" runat="server" /></div><div class="lbl"><a href="CustomRequests.aspx">Custom cakes to review</a></div></div>
        <div class="stat" style="border-color:var(--green)"><div class="num"><asp:Literal ID="litCustomers" runat="server" /></div><div class="lbl">Customers</div></div>
        <div class="stat" style="border-color:var(--blue)"><div class="num"><asp:Literal ID="litAvgOrder" runat="server" /></div><div class="lbl">Average order</div></div>
        <div class="stat" style="border-color:var(--amber)"><div class="num"><asp:Literal ID="litRating" runat="server" /></div><div class="lbl">Average rating</div></div>
        <div class="stat" style="border-color:var(--red)"><div class="num"><asp:Literal ID="litLowStock" runat="server" /></div><div class="lbl">Low-stock products</div></div>
    </div>

    <div class="two-col section">
        <div class="card">
            <h2>Sales - last 7 days</h2>
            <%-- Bar chart built from plain HTML/CSS; heights are calculated on the server --%>
            <div class="bar-chart" role="img" aria-label="Bar chart of daily sales for the last 7 days">
                <asp:Repeater ID="rptChart" runat="server">
                    <ItemTemplate>
                        <div class="bar-col">
                            <span class="bar-val"><%# Eval("Label") %></span>
                            <div class="bar" data-height='<%# Eval("Height") %>px' title='<%# Eval("Day") %>: <%# Eval("Label") %>'></div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            <div class="bar-labels">
                <asp:Repeater ID="rptChartLabels" runat="server">
                    <ItemTemplate><span><%# Eval("Day") %></span></ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <div class="card">
            <h2>Top sellers</h2>
            <asp:Repeater ID="rptTop" runat="server">
                <ItemTemplate>
                    <div class="hbar">
                        <span class="name" title='<%# Eval("ProductName") %>'><%# Server.HtmlEncode(Eval("ProductName").ToString()) %></span>
                        <span class="track"><span class="fill" data-width='<%# Eval("Pct") %>%' style="width:0"></span></span>
                        <strong><%# Eval("Sold") %></strong>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <div class="two-col-even">
        <div class="card">
            <div class="row between"><h2 style="margin:0">&#9888; Stock alerts</h2><a class="small" href="Products.aspx">Manage stock</a></div>
            <p class="muted small">Products with 3 or fewer left.</p>
            <div class="table-wrap" style="box-shadow:none">
                <asp:GridView ID="gvLowStock" runat="server" AutoGenerateColumns="false" CssClass="grid-table" GridLines="None" EmptyDataText="All products are well stocked.">
                    <Columns>
                        <asp:BoundField DataField="ProductName" HeaderText="Product" />
                        <asp:TemplateField HeaderText="Stock">
                            <ItemTemplate><span class='badge <%# (int)Eval("Stock") == 0 ? "badge-cancelled" : "badge-pending" %>'><%# (int)Eval("Stock") == 0 ? "Sold out" : Eval("Stock") + " left" %></span></ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <div class="card">
            <div class="row between"><h2 style="margin:0">Latest orders</h2><a class="small" href="Orders.aspx">All orders</a></div>
            <div class="table-wrap" style="box-shadow:none;margin-top:8px">
                <asp:GridView ID="gvRecent" runat="server" AutoGenerateColumns="false" CssClass="grid-table" GridLines="None">
                    <Columns>
                        <asp:HyperLinkField DataTextField="OrderID" DataTextFormatString="#{0}" DataNavigateUrlFields="OrderID" DataNavigateUrlFormatString="Orders.aspx?id={0}" HeaderText="Order" />
                        <asp:BoundField DataField="FullName" HeaderText="Customer" />
                        <asp:TemplateField HeaderText="Total"><ItemTemplate><%# Shop.Money(Eval("TotalAmount")) %></ItemTemplate></asp:TemplateField>
                        <asp:TemplateField HeaderText="Status"><ItemTemplate><span class='<%# Shop.StatusCss(Eval("Status")) %>'><%# Eval("Status") %></span></ItemTemplate></asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>
