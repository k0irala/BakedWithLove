<%@ Page Title="My Profile | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Profile.aspx.cs" Inherits="Member_Profile" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="row between">
        <h1 class="page-title">Hi, <asp:Literal ID="litName" runat="server" />!</h1>
        <asp:Button ID="btnLogout" runat="server" Text="Logout" CssClass="btn btn-outline btn-small" OnClick="btnLogout_Click" CausesValidation="false" />
    </div>

    <div class="two-col">
        <div class="stack">
            <%-- Loyalty / gamification card --%>
            <div class="points-card">
                <div class="row between">
                    <span>Loyalty points</span>
                    <asp:Label ID="lblTier" runat="server" />
                </div>
                <div class="big"><asp:Literal ID="litPoints" runat="server" /></div>
                <div class="small">Worth <asp:Literal ID="litPointsValue" runat="server" /> off your next order</div>
                <div class="progress"><span data-width="<%= TierProgress %>%" style="width:0"></span></div>
                <div class="small" style="margin-top:6px"><asp:Literal ID="litNextTier" runat="server" /></div>
            </div>

            <div class="card">
                <h2>Edit profile</h2>
                <asp:Label ID="lblProfileMsg" runat="server" Visible="false" style="display:block" />
                <asp:Panel runat="server" DefaultButton="btnSave" CssClass="form">
                    <div class="field">
                        <label for="<%= txtName.ClientID %>">Full name</label>
                        <asp:TextBox ID="txtName" runat="server" MaxLength="100" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName" ErrorMessage="Name is required." CssClass="error" Display="Dynamic" ValidationGroup="profile" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtName" ValidationExpression="^[A-Za-z][A-Za-z .'-]{1,99}$" ErrorMessage="Letters, spaces, dots and hyphens only." CssClass="error" Display="Dynamic" ValidationGroup="profile" />
                    </div>
                    <div class="field">
                        <label for="<%= txtEmail.ClientID %>">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="150" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." CssClass="error" Display="Dynamic" ValidationGroup="profile" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email." CssClass="error" Display="Dynamic" ValidationGroup="profile" />
                        <asp:CustomValidator runat="server" ControlToValidate="txtEmail" OnServerValidate="cvEmail_ServerValidate" ErrorMessage="Another account already uses this email." CssClass="error" Display="Dynamic" ValidationGroup="profile" />
                    </div>
                    <div class="field">
                        <label for="<%= txtPhone.ClientID %>">Mobile number</label>
                        <asp:TextBox ID="txtPhone" runat="server" TextMode="Phone" MaxLength="10" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPhone" ErrorMessage="Mobile number is required." CssClass="error" Display="Dynamic" ValidationGroup="profile" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPhone" ValidationExpression="^9[78]\d{8}$" ErrorMessage="10 digits starting with 97 or 98." CssClass="error" Display="Dynamic" ValidationGroup="profile" />
                    </div>
                    <div class="field">
                        <label for="<%= txtAddress.ClientID %>">Default delivery address</label>
                        <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="2" MaxLength="250" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddress" ErrorMessage="Address is required." CssClass="error" Display="Dynamic" ValidationGroup="profile" />
                    </div>
                    <asp:Button ID="btnSave" runat="server" Text="Save changes" CssClass="btn" OnClick="btnSave_Click" ValidationGroup="profile" />
                </asp:Panel>
            </div>

            <div class="card">
                <h2>Change password</h2>
                <asp:Label ID="lblPwMsg" runat="server" Visible="false" style="display:block" />
                <asp:Panel runat="server" DefaultButton="btnPassword" CssClass="form">
                    <div class="field">
                        <label for="<%= txtCurrent.ClientID %>">Current password</label>
                        <asp:TextBox ID="txtCurrent" runat="server" TextMode="Password" autocomplete="current-password" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCurrent" ErrorMessage="Enter your current password." CssClass="error" Display="Dynamic" ValidationGroup="pw" />
                    </div>
                    <div class="field-row">
                        <div class="field">
                            <label for="<%= txtNew.ClientID %>">New password</label>
                            <asp:TextBox ID="txtNew" runat="server" TextMode="Password" autocomplete="new-password" />
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNew" ErrorMessage="Enter a new password." CssClass="error" Display="Dynamic" ValidationGroup="pw" />
                            <asp:RegularExpressionValidator runat="server" ControlToValidate="txtNew" ValidationExpression="^(?=.*[A-Za-z])(?=.*\d).{8,}$" ErrorMessage="Min 8 characters, letters and numbers." CssClass="error" Display="Dynamic" ValidationGroup="pw" />
                        </div>
                        <div class="field">
                            <label for="<%= txtConfirm.ClientID %>">Confirm new password</label>
                            <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" autocomplete="new-password" />
                            <asp:CompareValidator runat="server" ControlToValidate="txtConfirm" ControlToCompare="txtNew" ErrorMessage="Passwords do not match." CssClass="error" Display="Dynamic" ValidationGroup="pw" />
                        </div>
                    </div>
                    <asp:Button ID="btnPassword" runat="server" Text="Update password" CssClass="btn btn-outline" OnClick="btnPassword_Click" ValidationGroup="pw" />
                </asp:Panel>
            </div>
        </div>

        <aside class="stack">
            <div class="card">
                <div class="row between">
                    <h2 style="margin:0">Notifications</h2>
                    <asp:LinkButton ID="lnkMarkRead" runat="server" OnClick="lnkMarkRead_Click" CssClass="small" CausesValidation="false">Mark all read</asp:LinkButton>
                </div>
                <ul class="notice-list">
                    <asp:Repeater ID="rptNotices" runat="server">
                        <ItemTemplate>
                            <li class='<%# (bool)Eval("IsRead") ? "" : "unread" %>'>
                                <strong><%# Server.HtmlEncode(Eval("Title").ToString()) %></strong>
                                <%# Eval("Channel").ToString() == "Email" ? "<span class='badge' title='Also sent by email'>&#9993; email</span>" : "" %><br />
                                <span><%# Server.HtmlEncode(Eval("Message").ToString()) %></span><br />
                                <span class="muted small"><%# ((DateTime)Eval("CreatedAt")).ToString("dd MMM, h:mm tt") %></span>
                                <%# Eval("OrderID") != DBNull.Value ? " &middot; <a class='small' href='MyOrders.aspx?id=" + Eval("OrderID") + "'>View order</a>" : "" %>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
                <asp:Label ID="lblNoNotices" runat="server" CssClass="muted small" Text="No notifications yet." Visible="false" />
            </div>

            <div class="card">
                <h2>Points history</h2>
                <asp:GridView ID="gvPoints" runat="server" AutoGenerateColumns="false" CssClass="grid-table" GridLines="None"
                    AllowPaging="true" PageSize="6" OnPageIndexChanging="gvPoints_PageIndexChanging" PagerStyle-CssClass="pager" EmptyDataText="No points yet.">
                    <Columns>
                        <asp:BoundField DataField="CreatedAt" HeaderText="Date" DataFormatString="{0:dd MMM}" />
                        <asp:BoundField DataField="Description" HeaderText="Activity" />
                        <asp:TemplateField HeaderText="Points">
                            <ItemTemplate><strong style='color:<%# (int)Eval("Points") >= 0 ? "var(--green)" : "var(--red)" %>'><%# (int)Eval("Points") > 0 ? "+" : "" %><%# Eval("Points") %></strong></ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <div class="card small">
                <h3>Quick links</h3>
                <p><a href="MyOrders.aspx">&#128230; My orders &amp; tracking</a><br />
                   <a href="MyOrders.aspx?tab=history">&#128338; Purchase history</a><br />
                   <a href="CustomCake.aspx">&#127874; Custom cake requests</a></p>
            </div>
        </aside>
    </div>
</asp:Content>
