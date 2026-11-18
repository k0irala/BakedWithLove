<%@ Page Title="Baked With Love | Home" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="DefaultPage" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <section class="hero">
        <div>
            <h1>Baked with love, just for you</h1>
            <p>Fresh cakes, cupcakes, cookies and pastries from our Kathmandu kitchen. Order for yourself, design your dream cake, or send a sweet surprise to someone you love.</p>
            <div class="row">
                <a class="btn" href="Menu.aspx">Order now</a>
                <a class="btn btn-outline" href="Member/CustomCake.aspx">Design a cake</a>
            </div>
        </div>
        <div class="hero-art">
            <img src="Images/hero-cake.svg" alt="Animated birthday cake with candles" width="320" height="300" />
        </div>
    </section>

    <section class="section promo-strip" aria-label="Ready to take today">
        <div>
            <strong>&#9201; Ready to Take - today only</strong><br />
            <span class="small"><asp:Literal ID="litReadyCount" runat="server" /> fresh treats on the shelf. Order before we close!</span>
        </div>
        <div class="countdown" data-until="<%= ClosingTime %>"></div>
        <a class="btn btn-light btn-small" href="ReadyToTake.aspx">See what's ready</a>
    </section>

    <section class="section">
        <h2>Shop by category</h2>
        <div class="category-tiles">
            <asp:Repeater ID="rptCategories" runat="server">
                <ItemTemplate>
                    <a class="category-tile" href='Menu.aspx?cat=<%# Eval("CategoryID") %>'>
                        <img src='<%# Shop.Img(Eval("ImageUrl")) %>' alt="" width="72" height="72" />
                        <%# Server.HtmlEncode(Eval("CategoryName").ToString()) %>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </section>

    <section class="section">
        <div class="section-head">
            <h2>Best sellers</h2>
            <a href="Menu.aspx">View all &rarr;</a>
        </div>
        <div class="grid">
            <asp:Repeater ID="rptBest" runat="server">
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
    </section>

    <asp:PlaceHolder ID="phRecent" runat="server" Visible="false">
        <section class="section">
            <h2>Recently viewed</h2>
            <div class="category-chips">
                <asp:Repeater ID="rptRecent" runat="server">
                    <ItemTemplate>
                        <a class="category-tile" style="width:96px;flex:0 0 auto" href='Product.aspx?id=<%# Eval("ProductID") %>'>
                            <img src='<%# Shop.Img(Eval("ImageUrl")) %>' alt="" width="72" height="72" />
                            <%# Server.HtmlEncode(Eval("ProductName").ToString()) %>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </section>
    </asp:PlaceHolder>

    <section class="section feature-list" aria-label="Why order from us">
        <div class="feature"><span class="ico">&#127874;</span><strong>Custom cakes</strong><br /><span class="muted small">Pick size, flavour, filling and design</span></div>
        <div class="feature"><span class="ico">&#127873;</span><strong>Gift a cake</strong><br /><span class="muted small">Send love to family, even from abroad</span></div>
        <div class="feature"><span class="ico">&#129370;</span><strong>Eggless options</strong><br /><span class="muted small">Tell us about allergies too</span></div>
        <div class="feature"><span class="ico">&#11088;</span><strong>Loyalty rewards</strong><br /><span class="muted small">Earn points on every order</span></div>
    </section>

    <section class="section">
        <h2>What our customers say</h2>
        <asp:DataList ID="dlReviews" runat="server" RepeatLayout="Flow" RepeatDirection="Vertical" CssClass="grid-1">
            <ItemTemplate>
                <div class="card">
                    <bwl:StarRating runat="server" Rating='<%# Convert.ToDecimal(Eval("Rating")) %>' ShowCount="false" />
                    <p style="margin:.4em 0">&ldquo;<%# Server.HtmlEncode(Eval("Comment").ToString()) %>&rdquo;</p>
                    <span class="muted small">- <%# Server.HtmlEncode(Eval("FullName").ToString()) %>, on <a href='Product.aspx?id=<%# Eval("ProductID") %>'><%# Server.HtmlEncode(Eval("ProductName").ToString()) %></a></span>
                </div>
            </ItemTemplate>
        </asp:DataList>
    </section>
</asp:Content>
