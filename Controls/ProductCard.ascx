<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ProductCard.ascx.cs" Inherits="Controls_ProductCard" %>
<%@ Register TagPrefix="uc" TagName="StarRating" Src="~/Controls/StarRating.ascx" %>
<article class="product-card">
    <a class="thumb" href="<%= DetailUrl %>">
        <img src="<%= Shop.Img(ImageUrl) %>" alt="<%: ProductName %>" loading="lazy" width="400" height="400" />
        <% if (Stock <= 0) { %>
            <span class="tag sold">Sold out today</span>
        <% } else if (IsReadyToday) { %>
            <span class="tag">&#10003; Ready today</span>
        <% } %>
        <% if (IsEggless) { %><span class="tag tag-egg">Eggless</span><% } %>
    </a>
    <div class="body">
        <a class="name" href="<%= DetailUrl %>"><%: ProductName %></a>
        <uc:StarRating ID="stars" runat="server" />
        <div class="foot">
            <span class="price"><%= Shop.Money(Price) %></span>
            <asp:Button ID="btnAdd" runat="server" Text="+ Add" CssClass="btn btn-small" OnClick="btnAdd_Click" CausesValidation="false" />
        </div>
    </div>
</article>
