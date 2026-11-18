<%@ Control Language="C#" AutoEventWireup="true" CodeFile="OrderTimeline.ascx.cs" Inherits="Controls_OrderTimeline" %>
<ol class="timeline" aria-label="Order progress">
    <asp:Repeater ID="rptSteps" runat="server">
        <ItemTemplate>
            <li class="<%# Eval("Css") %>">
                <span class="dot"><%# Eval("Icon") %></span>
                <%# Eval("Label") %>
                <time><%# Eval("When") %></time>
            </li>
        </ItemTemplate>
    </asp:Repeater>
</ol>
