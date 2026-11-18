<%@ Page Title="Login | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="LoginPage" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="card form" style="margin:10px auto">
        <div class="center">
            <img src="Images/logo.svg" alt="" width="72" height="72" style="margin:0 auto 6px" />
            <h1>Welcome back</h1>
            <p class="muted small">Log in to order, track your treats and collect rewards.</p>
        </div>

        <asp:Panel runat="server" DefaultButton="btnLogin">
            <asp:Label ID="lblError" runat="server" CssClass="alert alert-error" Visible="false" style="display:block" />
            <asp:Label ID="lblInfo" runat="server" CssClass="alert alert-info" Visible="false" style="display:block" />

            <div class="field">
                <label for="<%= txtEmail.ClientID %>">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" autocomplete="username" MaxLength="150" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail" ErrorMessage="Please enter your email." CssClass="error" Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email address." CssClass="error" Display="Dynamic" />
            </div>
            <div class="field">
                <label for="<%= txtPassword.ClientID %>">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="current-password" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword" ErrorMessage="Please enter your password." CssClass="error" Display="Dynamic" />
            </div>
            <div class="field">
                <asp:CheckBox ID="chkRemember" runat="server" Text=" Keep me logged in" CssClass="check" />
            </div>
            <asp:Button ID="btnLogin" runat="server" Text="Log in" CssClass="btn btn-block" OnClick="btnLogin_Click" />
        </asp:Panel>

        <p class="center small" style="margin-top:16px">New here? <a href="Register.aspx<%= ReturnQuery %>">Create an account</a></p>
    </div>
</asp:Content>
