<%@ Control Language="C#" AutoEventWireup="true" CodeFile="StarRating.ascx.cs" Inherits="Controls_StarRating" %>
<span class="stars" title="<%= Rating.ToString("0.0") %> out of 5"><%= StarsHtml %><% if (ShowCount) { %> <span class="muted small">(<%= Count %>)</span><% } %></span>
