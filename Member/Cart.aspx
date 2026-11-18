<%@ Page Title="My Cart | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Cart.aspx.cs" Inherits="Member_Cart" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">My Cart</h1>

    <asp:Panel ID="pnlCart" runat="server" CssClass="two-col">
        <div class="card">
            <asp:Repeater ID="rptCart" runat="server" OnItemCommand="rptCart_ItemCommand">
                <ItemTemplate>
                    <div class="cart-item">
                        <a href='../Product.aspx?id=<%# Eval("ProductID") %>'>
                            <img src='<%# Shop.Img(Eval("ImageUrl")) %>' alt="" width="72" height="72" /></a>
                        <div>
                            <div class="row between">
                                <a class="name" href='../Product.aspx?id=<%# Eval("ProductID") %>' style="font-weight: 600; color: var(--brown)"><%# Server.HtmlEncode(Eval("ProductName").ToString()) %></a>
                                <asp:LinkButton runat="server" CommandName="Remove" CommandArgument='<%# Eval("CartItemID") %>' CssClass="small" ToolTip="Remove item" CausesValidation="false">Remove</asp:LinkButton>
                            </div>
                            <div class="muted small"><%# Shop.Money(Eval("Price")) %> each<%# (int)Eval("Quantity") > (int)Eval("Stock") ? " &middot; <span class='error' style='display:inline'>Only " + Eval("Stock") + " left</span>" : "" %></div>
                            <div class="row between" style="margin-top: 6px">
                                <span class="qty">
                                    <asp:LinkButton runat="server" CommandName="Minus" CommandArgument='<%# Eval("CartItemID") %>' ToolTip="Decrease quantity" CausesValidation="false">&minus;</asp:LinkButton>
                                    <span class="qty-val"><%# Eval("Quantity") %></span>
                                    <asp:LinkButton runat="server" CommandName="Plus" CommandArgument='<%# Eval("CartItemID") %>' ToolTip="Increase quantity" CausesValidation="false">+</asp:LinkButton>
                                </span>
                                <strong><%# Shop.Money(Eval("LineTotal")) %></strong>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <p class="small" style="margin-top: 12px"><a href="../Menu.aspx">&larr; Continue shopping</a></p>
        </div>

        <aside class="card">
            <h2>Order summary</h2>
            <div class="summary-line"><span>Items (<asp:Literal ID="litItems" runat="server" />)</span><span><asp:Literal ID="litSubtotal" runat="server" /></span></div>
            <div class="summary-line"><span>Delivery</span><span class="muted small">calculated at checkout</span></div>
            <asp:Label ID="lblFreeHint" runat="server" CssClass="alert alert-info small" Style="display: block; margin: 10px 0" />
            <div class="summary-line total"><span>Subtotal</span><span><asp:Literal ID="litTotal" runat="server" /></span></div>
            <asp:Label ID="lblStockError" runat="server" CssClass="alert alert-error small" Visible="false" Style="display: block" />
            <asp:HyperLink ID="lnkCheckout" runat="server" NavigateUrl="~/Member/Checkout.aspx" CssClass="btn btn-block" Style="margin-top: 12px">Proceed to checkout</asp:HyperLink>
        </aside>
    </asp:Panel>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="card empty-state">
        <span class="ico">&#128722;</span>
        <h2>Your cart is empty</h2>
        <p>Fill it with something sweet!</p>
        <a class="btn" href="../Menu.aspx">Browse the menu</a>
    </asp:Panel>
</asp:Content>
