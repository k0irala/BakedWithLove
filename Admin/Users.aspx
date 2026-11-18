<%@ Page Title="Users | Bakery Admin" Language="C#" MasterPageFile="~/Admin/Admin.master" AutoEventWireup="true" CodeFile="Users.aspx.cs" Inherits="Admin_Users" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">Users</h1>
    <asp:Label ID="lblMsg" runat="server" Visible="false" style="display:block" />

    <asp:Panel runat="server" DefaultButton="btnSearch" CssClass="row" style="margin-bottom:12px">
        <asp:TextBox ID="txtSearch" runat="server" CssClass="input" placeholder="Search name, email or phone" style="max-width:280px" />
        <asp:DropDownList ID="ddlRole" runat="server" CssClass="input" style="width:auto" AutoPostBack="true">
            <asp:ListItem Value="">All roles</asp:ListItem>
            <asp:ListItem>Customer</asp:ListItem>
            <asp:ListItem>Admin</asp:ListItem>
        </asp:DropDownList>
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-small btn-outline" CausesValidation="false" />
    </asp:Panel>

    <%-- Read, Update, Delete through GridView + SqlDataSource --%>
    <div class="table-wrap">
        <asp:GridView ID="gvUsers" runat="server" DataSourceID="dsUsers" DataKeyNames="UserID" AutoGenerateColumns="false"
            CssClass="grid-table" GridLines="None" AllowPaging="true" PageSize="10" AllowSorting="true" PagerStyle-CssClass="pager"
            OnRowDataBound="gvUsers_RowDataBound" OnRowUpdating="gvUsers_RowUpdating" OnRowUpdated="gvUsers_RowUpdated"
            OnRowDeleted="gvUsers_RowDeleted" EmptyDataText="No users found.">
            <Columns>
                <asp:TemplateField HeaderText="Name" SortExpression="FullName">
                    <ItemTemplate><strong><%# Server.HtmlEncode(Eval("FullName").ToString()) %></strong><br /><span class="muted small"><%# Server.HtmlEncode(Eval("Email").ToString()) %></span></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtName" runat="server" Text='<%# Bind("FullName") %>' MaxLength="100" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName" ErrorMessage="Required" CssClass="error" Display="Dynamic" ValidationGroup="editUser" />
                        <span class="muted small"><%# Server.HtmlEncode(Eval("Email").ToString()) %></span>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Phone">
                    <ItemTemplate><%# Eval("Phone") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtPhone" runat="server" Text='<%# Bind("Phone") %>' MaxLength="10" style="width:120px" />
                        <asp:RegularExpressionValidator runat="server" ControlToValidate="txtPhone" ValidationExpression="^9[78]\d{8}$" ErrorMessage="10 digits" CssClass="error" Display="Dynamic" ValidationGroup="editUser" />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Address">
                    <ItemTemplate><span class="small"><%# Server.HtmlEncode(Convert.ToString(Eval("Address"))) %></span></ItemTemplate>
                    <EditItemTemplate><asp:TextBox ID="txtAddress" runat="server" Text='<%# Bind("Address") %>' MaxLength="250" /></EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Role" SortExpression="Role">
                    <ItemTemplate><span class='badge <%# Eval("Role").ToString() == "Admin" ? "badge-confirmed" : "" %>'><%# Eval("Role") %></span></ItemTemplate>
                    <EditItemTemplate>
                        <asp:DropDownList ID="ddlRole" runat="server" SelectedValue='<%# Bind("Role") %>'>
                            <asp:ListItem>Customer</asp:ListItem>
                            <asp:ListItem>Admin</asp:ListItem>
                        </asp:DropDownList>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Points" SortExpression="LoyaltyPoints">
                    <ItemTemplate><%# Eval("LoyaltyPoints") %> <span class='badge badge-<%# Shop.Tier((int)Eval("LoyaltyPoints")).ToLower() %>'><%# Shop.Tier((int)Eval("LoyaltyPoints")) %></span></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtPoints" runat="server" Text='<%# Bind("LoyaltyPoints") %>' TextMode="Number" style="width:80px" />
                        <asp:RangeValidator runat="server" ControlToValidate="txtPoints" Type="Integer" MinimumValue="0" MaximumValue="100000" ErrorMessage="0+" CssClass="error" Display="Dynamic" ValidationGroup="editUser" />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="OrderCount" HeaderText="Orders" ReadOnly="true" SortExpression="OrderCount" />
                <asp:BoundField DataField="CreatedAt" HeaderText="Joined" ReadOnly="true" DataFormatString="{0:dd MMM yyyy}" SortExpression="CreatedAt" />
                <asp:CheckBoxField DataField="IsActive" HeaderText="Active" />
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:LinkButton runat="server" CommandName="Edit" Text="Edit" CausesValidation="false" />
                        <asp:LinkButton ID="lnkDelete" runat="server" CommandName="Delete" Text="Delete" CausesValidation="false"
                            OnClientClick="return confirm('Delete this user? Users with orders will be deactivated instead.');" />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:LinkButton runat="server" CommandName="Update" Text="Save" ValidationGroup="editUser" />
                        <asp:LinkButton runat="server" CommandName="Cancel" Text="Cancel" CausesValidation="false" />
                    </EditItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
    <p class="hint">New customers sign up on the <a href="../Register.aspx">registration page</a>. Customers with past orders are deactivated rather than deleted to keep order records.</p>

    <asp:SqlDataSource ID="dsUsers" runat="server" ConnectionString="<%$ ConnectionStrings:BakeryDB %>"
        SelectCommand="SELECT u.UserID, u.FullName, u.Email, u.Phone, u.Address, u.Role, u.LoyaltyPoints, u.IsActive, u.CreatedAt,
                       (SELECT COUNT(*) FROM Orders o WHERE o.UserID = u.UserID) AS OrderCount
                       FROM Users u
                       WHERE (@role = '' OR u.Role = @role)
                         AND (@q = '' OR u.FullName LIKE '%' + @q + '%' OR u.Email LIKE '%' + @q + '%' OR u.Phone LIKE '%' + @q + '%')
                       ORDER BY u.CreatedAt DESC"
        UpdateCommand="UPDATE Users SET FullName = @FullName, Phone = @Phone, Address = @Address, Role = @Role,
                       LoyaltyPoints = @LoyaltyPoints, IsActive = @IsActive WHERE UserID = @UserID"
        DeleteCommand="IF @UserID = @CurrentUser RETURN;
                       IF EXISTS (SELECT 1 FROM Orders WHERE UserID = @UserID)
                           UPDATE Users SET IsActive = 0 WHERE UserID = @UserID
                       ELSE BEGIN
                           DELETE FROM CartItems WHERE UserID = @UserID;
                           DELETE FROM Notifications WHERE UserID = @UserID;
                           DELETE FROM LoyaltyTransactions WHERE UserID = @UserID;
                           DELETE FROM Reviews WHERE UserID = @UserID;
                           DELETE FROM CustomOrders WHERE UserID = @UserID;
                           DELETE FROM Users WHERE UserID = @UserID;
                       END"
        OnDeleting="dsUsers_Deleting" CancelSelectOnNullParameter="false">
        <SelectParameters>
            <asp:ControlParameter Name="role" ControlID="ddlRole" PropertyName="SelectedValue" Type="String" ConvertEmptyStringToNull="false" DefaultValue="" />
            <asp:ControlParameter Name="q" ControlID="txtSearch" PropertyName="Text" Type="String" ConvertEmptyStringToNull="false" DefaultValue="" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="FullName" Type="String" />
            <asp:Parameter Name="Phone" Type="String" />
            <asp:Parameter Name="Address" Type="String" />
            <asp:Parameter Name="Role" Type="String" />
            <asp:Parameter Name="LoyaltyPoints" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="UserID" Type="Int32" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="UserID" Type="Int32" />
            <asp:Parameter Name="CurrentUser" Type="Int32" />
        </DeleteParameters>
    </asp:SqlDataSource>
</asp:Content>
