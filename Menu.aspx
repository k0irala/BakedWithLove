<%@ Page Title="Menu | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Menu.aspx.cs" Inherits="MenuPage" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">Our Menu</h1>

    <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch" CssClass="stack">
        <div class="row">
            <asp:TextBox ID="txtSearch" runat="server" CssClass="input" placeholder="Search cakes, cookies..." TextMode="Search" style="flex:1;min-width:180px" aria-label="Search products" />
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn" OnClick="Filter_Changed" CausesValidation="false" />
        </div>
        <div class="row between">
            <asp:CheckBox ID="chkEggless" runat="server" Text=" Eggless only" CssClass="check" AutoPostBack="true" OnCheckedChanged="Filter_Changed" />
            <asp:DropDownList ID="ddlSort" runat="server" CssClass="input" style="width:auto" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" aria-label="Sort products">
                <asp:ListItem Value="popular">Most popular</asp:ListItem>
                <asp:ListItem Value="price-asc">Price: low to high</asp:ListItem>
                <asp:ListItem Value="price-desc">Price: high to low</asp:ListItem>
                <asp:ListItem Value="rating">Top rated</asp:ListItem>
            </asp:DropDownList>
        </div>
    </asp:Panel>

    <nav class="category-chips section" aria-label="Categories">
        <a class='chip <%= CategoryId == 0 ? "active" : "" %>' href="Menu.aspx">All</a>
        <asp:Repeater ID="rptCats" runat="server">
            <ItemTemplate>
                <a class='chip <%# (int)Eval("CategoryID") == CategoryId ? "active" : "" %>' href='Menu.aspx?cat=<%# Eval("CategoryID") %>'><%# Server.HtmlEncode(Eval("CategoryName").ToString()) %></a>
            </ItemTemplate>
        </asp:Repeater>
    </nav>

    <p class="muted small"><asp:Literal ID="litCount" runat="server" /></p>

    <div class="grid">
        <asp:Repeater ID="rptProducts" runat="server">
            <ItemTemplate>
                <bwl:ProductCard runat="server"
                    ProductID='<%# (int)Eval("ProductID") %>' ProductName='<%# (string)Eval("ProductName") %>'
                    Price='<%# (decimal)Eval("Price") %>' ImageUrl='<%# Eval("ImageUrl") as string %>'
                    Stock='<%# (int)Eval("Stock") %>' IsReadyToday='<%# (bool)Eval("IsReadyToday") %>'
                    IsEggless='<%# (bool)Eval("IsEggless") %>' AvgRating='<%# (decimal)Eval("AvgRating") %>'
                    ReviewCount='<%# (int)Eval("ReviewCount") %>' />
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
        <span class="ico">&#129473;</span>
        No treats match your search. <a href="Menu.aspx">Show everything</a>
    </asp:Panel>
</asp:Content>
