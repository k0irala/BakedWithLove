<%@ Page Title="Ready to Take | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="ReadyToTake.aspx.cs" Inherits="ReadyToTakePage" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="promo-strip">
        <div>
            <h1 style="color:#fff;margin:0;font-size:1.4rem">&#9201; Ready to Take</h1>
            <span class="small">Baked this morning and waiting on our shelf. Collect today or get it delivered within hours.</span>
        </div>
        <div class="countdown" data-until="<%= DateTime.Today.AddHours(20).ToString("yyyy-MM-ddTHH:mm:ss") %>"></div>
    </div>

    <p class="muted small section">Stock updates live as customers order. Last updated <%= DateTime.Now.ToString("h:mm tt") %>.</p>

    <%-- DataList shows each product with its live stock level --%>
    <asp:DataList ID="dlReady" runat="server" RepeatLayout="Flow" RepeatDirection="Horizontal" CssClass="grid" OnItemCommand="dlReady_ItemCommand">
        <ItemTemplate>
            <article class="product-card">
                <a class="thumb" href='Product.aspx?id=<%# Eval("ProductID") %>'>
                    <img src='<%# Shop.Img(Eval("ImageUrl")) %>' alt='<%# Server.HtmlEncode(Eval("ProductName").ToString()) %>' loading="lazy" width="400" height="400" />
                    <span class="tag"><%# StockText((int)Eval("Stock")) %></span>
                </a>
                <div class="body">
                    <a class="name" href='Product.aspx?id=<%# Eval("ProductID") %>'><%# Server.HtmlEncode(Eval("ProductName").ToString()) %></a>
                    <span class="muted small"><%# Eval("CategoryName") %></span>
                    <div class="foot">
                        <span class="price"><%# Shop.Money(Eval("Price")) %></span>
                        <asp:Button runat="server" Text="+ Add" CssClass="btn btn-small" CommandName="Add" CommandArgument='<%# Eval("ProductID") %>' CausesValidation="false" />
                    </div>
                </div>
            </article>
        </ItemTemplate>
    </asp:DataList>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
        <span class="ico">&#129360;</span>
        Everything has been sold out today! Check the <a href="Menu.aspx">full menu</a> to pre-order for tomorrow.
    </asp:Panel>
</asp:Content>
