<%@ Page Title="Product | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Product.aspx.cs" Inherits="ProductPage" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <p class="small"><a href="Menu.aspx">&larr; Back to menu</a></p>

    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="empty-state">
        <span class="ico">&#128270;</span>Sorry, we couldn't find that product. <a href="Menu.aspx">Browse the menu</a>
    </asp:Panel>

    <asp:Panel ID="pnlProduct" runat="server" CssClass="product-detail">
        <div class="photo">
            <asp:Image ID="imgProduct" runat="server" Width="400" Height="400" style="width:100%;height:auto" />
        </div>
        <div class="stack">
            <span class="badge"><asp:Literal ID="litCategory" runat="server" /></span>
            <h1 style="margin:.3em 0 0"><asp:Literal ID="litName" runat="server" /></h1>
            <bwl:StarRating ID="stars" runat="server" />
            <div class="price"><asp:Literal ID="litPrice" runat="server" /></div>
            <p><asp:Literal ID="litDesc" runat="server" /></p>
            <div class="row">
                <asp:Label ID="lblStock" runat="server" CssClass="badge" />
                <asp:Label ID="lblEggless" runat="server" CssClass="badge" Text="&#129370; Eggless" Visible="false" />
            </div>

            <div class="row">
                <label for="<%= txtQty.ClientID %>" class="label" style="margin:0">Quantity</label>
                <asp:TextBox ID="txtQty" runat="server" TextMode="Number" Text="1" CssClass="input" style="width:90px" min="1" />
                <asp:Button ID="btnAdd" runat="server" Text="Add to cart" CssClass="btn" OnClick="btnAdd_Click" ValidationGroup="cart" />
            </div>
            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQty" ErrorMessage="Enter a quantity." CssClass="error" Display="Dynamic" ValidationGroup="cart" />
            <asp:RangeValidator ID="rvQty" runat="server" ControlToValidate="txtQty" Type="Integer" MinimumValue="1" MaximumValue="99" CssClass="error" Display="Dynamic" ValidationGroup="cart" />

            <div class="card small">
                &#127874; Want something special? <a href="Member/CustomCake.aspx">Design a custom cake</a> with your own size, flavour and message.
            </div>
        </div>
    </asp:Panel>

    <section class="section two-col-even" id="reviews">
        <div class="card">
            <h2>Reviews</h2>
            <asp:Repeater ID="rptReviews" runat="server">
                <ItemTemplate>
                    <div class="review">
                        <div class="row between">
                            <strong><%# Server.HtmlEncode(Eval("FullName").ToString()) %></strong>
                            <bwl:StarRating runat="server" Rating='<%# Convert.ToDecimal(Eval("Rating")) %>' ShowCount="false" />
                        </div>
                        <p style="margin:.3em 0"><%# Server.HtmlEncode(Convert.ToString(Eval("Comment"))) %></p>
                        <span class="muted small"><%# ((DateTime)Eval("CreatedAt")).ToString("dd MMM yyyy") %></span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Label ID="lblNoReviews" runat="server" CssClass="muted" Text="No reviews yet. Be the first!" Visible="false" />
        </div>

        <div class="card" id="review">
            <h2>Rate this treat</h2>
            <asp:Panel ID="pnlReviewForm" runat="server" DefaultButton="btnReview">
                <div class="field">
                    <span class="label">Your rating</span>
                    <div class="star-input">
                        <input type="radio" name="rating" id="r5" value="5" /><label for="r5" title="5 stars">&#9733;</label>
                        <input type="radio" name="rating" id="r4" value="4" /><label for="r4" title="4 stars">&#9733;</label>
                        <input type="radio" name="rating" id="r3" value="3" /><label for="r3" title="3 stars">&#9733;</label>
                        <input type="radio" name="rating" id="r2" value="2" /><label for="r2" title="2 stars">&#9733;</label>
                        <input type="radio" name="rating" id="r1" value="1" /><label for="r1" title="1 star">&#9733;</label>
                    </div>
                </div>
                <div class="field">
                    <label for="<%= txtComment.ClientID %>">Comment</label>
                    <asp:TextBox ID="txtComment" runat="server" TextMode="MultiLine" MaxLength="500" placeholder="How did it taste?" />
                    <asp:RegularExpressionValidator runat="server" ControlToValidate="txtComment" ValidationExpression="^[\s\S]{0,500}$" ErrorMessage="Maximum 500 characters." CssClass="error" Display="Dynamic" ValidationGroup="review" />
                </div>
                <asp:Label ID="lblReviewMsg" runat="server" CssClass="error" />
                <asp:Button ID="btnReview" runat="server" Text="Submit review" CssClass="btn" OnClick="btnReview_Click" ValidationGroup="review" />
            </asp:Panel>
            <asp:Label ID="lblReviewInfo" runat="server" CssClass="muted" Visible="false" />
        </div>
    </section>
</asp:Content>
