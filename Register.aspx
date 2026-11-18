<%@ Page Title="Create Account | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Register.aspx.cs" Inherits="RegisterPage" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="card form" style="margin:10px auto">
        <div class="center">
            <h1>Create your account</h1>
            <p class="muted small">Join today and get <strong>50 welcome points</strong> (worth Rs. 50) for your first order.</p>
        </div>

        <asp:Panel runat="server" DefaultButton="btnRegister">
            <asp:ValidationSummary runat="server" CssClass="validation-summary" HeaderText="Please fix the following:" DisplayMode="BulletList" />
            <asp:Label ID="lblError" runat="server" CssClass="alert alert-error" Visible="false" style="display:block" />

            <div class="field">
                <label for="<%= txtName.ClientID %>">Full name</label>
                <asp:TextBox ID="txtName" runat="server" MaxLength="100" autocomplete="name" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName" ErrorMessage="Full name is required." Text="*" CssClass="error" Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server" ControlToValidate="txtName" ValidationExpression="^[A-Za-z][A-Za-z .'-]{1,99}$" ErrorMessage="Name can only contain letters, spaces, dots and hyphens." Text="Letters only, please." CssClass="error" Display="Dynamic" />
            </div>
            <div class="field">
                <label for="<%= txtEmail.ClientID %>">Email</label>
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="150" autocomplete="email" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." Text="*" CssClass="error" Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email address." Text="Invalid email." CssClass="error" Display="Dynamic" />
                <asp:CustomValidator ID="cvEmail" runat="server" ControlToValidate="txtEmail" OnServerValidate="cvEmail_ServerValidate" ErrorMessage="An account with this email already exists." Text="Already registered." CssClass="error" Display="Dynamic" />
            </div>
            <div class="field">
                <label for="<%= txtPhone.ClientID %>">Mobile number</label>
                <asp:TextBox ID="txtPhone" runat="server" TextMode="Phone" MaxLength="10" placeholder="98XXXXXXXX" autocomplete="tel" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPhone" ErrorMessage="Mobile number is required." Text="*" CssClass="error" Display="Dynamic" />
                <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPhone" ValidationExpression="^9[78]\d{8}$" ErrorMessage="Enter a 10-digit Nepali mobile number starting with 97 or 98." Text="10 digits starting with 97/98." CssClass="error" Display="Dynamic" />
            </div>
            <div class="field">
                <label for="<%= txtAddress.ClientID %>">Delivery address</label>
                <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="2" MaxLength="250" autocomplete="street-address" />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtAddress" ErrorMessage="Address is required." Text="*" CssClass="error" Display="Dynamic" />
            </div>
            <div class="field-row">
                <div class="field">
                    <label for="<%= txtPassword.ClientID %>">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="new-password" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPassword" ErrorMessage="Password is required." Text="*" CssClass="error" Display="Dynamic" />
                    <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPassword" ValidationExpression="^(?=.*[A-Za-z])(?=.*\d).{8,}$" ErrorMessage="Password must be at least 8 characters with letters and numbers." Text="Min 8 chars, letters + numbers." CssClass="error" Display="Dynamic" />
                </div>
                <div class="field">
                    <label for="<%= txtConfirm.ClientID %>">Confirm password</label>
                    <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" autocomplete="new-password" />
                    <asp:CompareValidator runat="server" ControlToValidate="txtConfirm" ControlToCompare="txtPassword" ErrorMessage="Passwords do not match." Text="Passwords do not match." CssClass="error" Display="Dynamic" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtConfirm" ErrorMessage="Please confirm your password." Text="*" CssClass="error" Display="Dynamic" />
                </div>
            </div>
            <div class="field">
                <asp:CheckBox ID="chkTerms" runat="server" Text=" I agree to receive order updates by email" CssClass="check" />
                <asp:CustomValidator runat="server" ClientValidationFunction="checkTerms" OnServerValidate="cvTerms_ServerValidate" ErrorMessage="Please agree to receive order updates." Text="Required." CssClass="error" Display="Dynamic" />
            </div>
            <asp:Button ID="btnRegister" runat="server" Text="Create account" CssClass="btn btn-block" OnClick="btnRegister_Click" />
        </asp:Panel>

        <p class="center small" style="margin-top:16px">Already have an account? <a href="Login.aspx">Log in</a></p>
    </div>

    <script>
        function checkTerms(source, args) {
            args.IsValid = document.getElementById("<%= chkTerms.ClientID %>").checked;
        }
    </script>
</asp:Content>
