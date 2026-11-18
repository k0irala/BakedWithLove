<%@ Page Title="Products | Bakery Admin" Language="C#" MasterPageFile="~/Admin/Admin.master" AutoEventWireup="true" CodeFile="Products.aspx.cs" Inherits="Admin_Products" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div class="row between">
        <h1 class="page-title">Products</h1>
        <a class="btn btn-small" href="#add">+ Add product</a>
    </div>

    <asp:Label ID="lblMsg" runat="server" Visible="false" style="display:block" />

    <div class="row" style="margin-bottom:12px">
        <asp:TextBox ID="txtSearch" runat="server" CssClass="input" placeholder="Search by name" style="max-width:240px" />
        <asp:DropDownList ID="ddlFilterCat" runat="server" CssClass="input" style="width:auto" DataSourceID="dsCategories"
            DataTextField="CategoryName" DataValueField="CategoryID" AppendDataBoundItems="true" AutoPostBack="true">
            <asp:ListItem Value="0">All categories</asp:ListItem>
        </asp:DropDownList>
        <asp:Button ID="btnSearch" runat="server" Text="Filter" CssClass="btn btn-small btn-outline" CausesValidation="false" />
    </div>

    <%-- ===== GridView: view, edit, delete (bound to SqlDataSource) ===== --%>
    <div class="table-wrap">
        <asp:GridView ID="gvProducts" runat="server" DataSourceID="dsProducts" DataKeyNames="ProductID" AutoGenerateColumns="false"
            CssClass="grid-table" GridLines="None" AllowPaging="true" PageSize="10" AllowSorting="true" PagerStyle-CssClass="pager"
            OnRowUpdating="gvProducts_RowUpdating" OnRowUpdated="gvProducts_RowUpdated" OnRowDeleted="gvProducts_RowDeleted"
            EmptyDataText="No products found.">
            <Columns>
                <asp:TemplateField HeaderText="Photo">
                    <ItemTemplate><img class="thumb" src='<%# Shop.Img(Eval("ImageUrl")) %>' alt="" /></ItemTemplate>
                    <EditItemTemplate>
                        <img class="thumb" src='<%# Shop.Img(Eval("ImageUrl")) %>' alt="" />
                        <asp:FileUpload ID="fuEditImage" runat="server" accept="image/*" style="max-width:150px;font-size:.75rem" />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Name" SortExpression="ProductName">
                    <ItemTemplate><strong><%# Server.HtmlEncode(Eval("ProductName").ToString()) %></strong></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtName" runat="server" Text='<%# Bind("ProductName") %>' MaxLength="100" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName" ErrorMessage="Name required" CssClass="error" Display="Dynamic" ValidationGroup="edit" />
                        <asp:TextBox ID="txtDesc" runat="server" Text='<%# Bind("Description") %>' TextMode="MultiLine" Rows="2" style="margin-top:4px" />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Category" SortExpression="CategoryName">
                    <ItemTemplate><%# Eval("CategoryName") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:DropDownList ID="ddlCat" runat="server" DataSourceID="dsCategories" DataTextField="CategoryName" DataValueField="CategoryID" SelectedValue='<%# Bind("CategoryID") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Price (Rs.)" SortExpression="Price">
                    <ItemTemplate><%# Shop.Money(Eval("Price")) %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtPrice" runat="server" Text='<%# Bind("Price", "{0:0}") %>' TextMode="Number" style="width:90px" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPrice" ErrorMessage="Required" CssClass="error" Display="Dynamic" ValidationGroup="edit" />
                        <asp:RangeValidator runat="server" ControlToValidate="txtPrice" Type="Double" MinimumValue="1" MaximumValue="100000" ErrorMessage="1 - 100,000" CssClass="error" Display="Dynamic" ValidationGroup="edit" />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Stock" SortExpression="Stock">
                    <ItemTemplate><span class='badge <%# (int)Eval("Stock") == 0 ? "badge-cancelled" : (int)Eval("Stock") <= 3 ? "badge-pending" : "badge-delivered" %>'><%# Eval("Stock") %></span></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtStock" runat="server" Text='<%# Bind("Stock") %>' TextMode="Number" style="width:70px" />
                        <asp:RangeValidator runat="server" ControlToValidate="txtStock" Type="Integer" MinimumValue="0" MaximumValue="999" ErrorMessage="0 - 999" CssClass="error" Display="Dynamic" ValidationGroup="edit" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtStock" ErrorMessage="Required" CssClass="error" Display="Dynamic" ValidationGroup="edit" />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:CheckBoxField DataField="IsReadyToday" HeaderText="Ready today" />
                <asp:CheckBoxField DataField="IsEggless" HeaderText="Eggless" />
                <asp:CheckBoxField DataField="IsActive" HeaderText="On sale" />
                <asp:CommandField ShowEditButton="true" ShowDeleteButton="true" ValidationGroup="edit" ButtonType="Link" />
            </Columns>
        </asp:GridView>
    </div>
    <p class="hint">Deleting a product that has been ordered before only hides it from the shop, so order history stays correct.</p>

    <%-- ===== DetailsView: insert a new product ===== --%>
    <section class="card section form-wide" id="add">
        <h2>Add a new product</h2>
        <asp:DetailsView ID="dvInsert" runat="server" DataSourceID="dsProducts" DefaultMode="Insert" AutoGenerateRows="false"
            CssClass="details-table" GridLines="None" OnItemInserting="dvInsert_ItemInserting" OnItemInserted="dvInsert_ItemInserted">
            <Fields>
                <asp:TemplateField HeaderText="Name">
                    <InsertItemTemplate>
                        <asp:TextBox ID="txtName" runat="server" Text='<%# Bind("ProductName") %>' MaxLength="100" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName" ErrorMessage="Product name is required." CssClass="error" Display="Dynamic" ValidationGroup="insert" />
                    </InsertItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Category">
                    <InsertItemTemplate>
                        <asp:DropDownList ID="ddlCat" runat="server" DataSourceID="dsCategories" DataTextField="CategoryName" DataValueField="CategoryID" SelectedValue='<%# Bind("CategoryID") %>' />
                    </InsertItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Description">
                    <InsertItemTemplate>
                        <asp:TextBox ID="txtDesc" runat="server" Text='<%# Bind("Description") %>' TextMode="MultiLine" Rows="3" MaxLength="500" />
                    </InsertItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Price (Rs.)">
                    <InsertItemTemplate>
                        <asp:TextBox ID="txtPrice" runat="server" Text='<%# Bind("Price") %>' TextMode="Number" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtPrice" ErrorMessage="Price is required." CssClass="error" Display="Dynamic" ValidationGroup="insert" />
                        <asp:RangeValidator runat="server" ControlToValidate="txtPrice" Type="Double" MinimumValue="1" MaximumValue="100000" ErrorMessage="Price must be between 1 and 100,000." CssClass="error" Display="Dynamic" ValidationGroup="insert" />
                    </InsertItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Stock">
                    <InsertItemTemplate>
                        <asp:TextBox ID="txtStock" runat="server" Text='<%# Bind("Stock") %>' TextMode="Number" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtStock" ErrorMessage="Stock is required." CssClass="error" Display="Dynamic" ValidationGroup="insert" />
                        <asp:RangeValidator runat="server" ControlToValidate="txtStock" Type="Integer" MinimumValue="0" MaximumValue="999" ErrorMessage="Stock must be 0 - 999." CssClass="error" Display="Dynamic" ValidationGroup="insert" />
                    </InsertItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Photo">
                    <InsertItemTemplate>
                        <asp:FileUpload ID="fuImage" runat="server" accept="image/*" data-preview="newPreview" />
                        <img id="newPreview" class="upload-preview hidden" alt="Preview" />
                        <div class="hint">JPG, PNG or WEBP up to 4 MB. Leave empty to use a placeholder.</div>
                    </InsertItemTemplate>
                </asp:TemplateField>
                <asp:CheckBoxField DataField="IsReadyToday" HeaderText="Ready to take today" />
                <asp:CheckBoxField DataField="IsEggless" HeaderText="Eggless" />
                <asp:TemplateField>
                    <InsertItemTemplate>
                        <asp:Button runat="server" CommandName="Insert" Text="Add product" CssClass="btn" ValidationGroup="insert" />
                    </InsertItemTemplate>
                </asp:TemplateField>
            </Fields>
        </asp:DetailsView>
    </section>

    <%-- ===== Data sources ===== --%>
    <asp:SqlDataSource ID="dsCategories" runat="server" ConnectionString="<%$ ConnectionStrings:BakeryDB %>"
        SelectCommand="SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName" />

    <asp:SqlDataSource ID="dsProducts" runat="server" ConnectionString="<%$ ConnectionStrings:BakeryDB %>"
        SelectCommand="SELECT p.ProductID, p.ProductName, p.Description, p.Price, p.ImageUrl, p.Stock, p.IsReadyToday, p.IsEggless, p.IsActive, p.CategoryID, c.CategoryName
                       FROM Products p JOIN Categories c ON c.CategoryID = p.CategoryID
                       WHERE (@cat = 0 OR p.CategoryID = @cat) AND (@q = '' OR p.ProductName LIKE '%' + @q + '%')
                       ORDER BY p.IsActive DESC, p.ProductID DESC"
        UpdateCommand="UPDATE Products SET ProductName = @ProductName, Description = @Description, CategoryID = @CategoryID, Price = @Price,
                       Stock = @Stock, IsReadyToday = @IsReadyToday, IsEggless = @IsEggless, IsActive = @IsActive WHERE ProductID = @ProductID"
        InsertCommand="INSERT INTO Products (ProductName, Description, CategoryID, Price, Stock, IsReadyToday, IsEggless, ImageUrl)
                       VALUES (@ProductName, @Description, @CategoryID, @Price, @Stock, @IsReadyToday, @IsEggless, @ImageUrl)"
        DeleteCommand="IF EXISTS (SELECT 1 FROM OrderItems WHERE ProductID = @ProductID)
                           UPDATE Products SET IsActive = 0 WHERE ProductID = @ProductID
                       ELSE BEGIN
                           DELETE FROM CartItems WHERE ProductID = @ProductID;
                           DELETE FROM Reviews WHERE ProductID = @ProductID;
                           DELETE FROM Products WHERE ProductID = @ProductID;
                       END"
        CancelSelectOnNullParameter="false">
        <SelectParameters>
            <asp:ControlParameter Name="cat" ControlID="ddlFilterCat" PropertyName="SelectedValue" Type="Int32" DefaultValue="0" />
            <asp:ControlParameter Name="q" ControlID="txtSearch" PropertyName="Text" Type="String" DefaultValue="" ConvertEmptyStringToNull="false" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="ProductName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="CategoryID" Type="Int32" />
            <asp:Parameter Name="Price" Type="Decimal" />
            <asp:Parameter Name="Stock" Type="Int32" />
            <asp:Parameter Name="IsReadyToday" Type="Boolean" />
            <asp:Parameter Name="IsEggless" Type="Boolean" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="ProductID" Type="Int32" />
        </UpdateParameters>
        <InsertParameters>
            <asp:Parameter Name="ProductName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="CategoryID" Type="Int32" />
            <asp:Parameter Name="Price" Type="Decimal" />
            <asp:Parameter Name="Stock" Type="Int32" />
            <asp:Parameter Name="IsReadyToday" Type="Boolean" />
            <asp:Parameter Name="IsEggless" Type="Boolean" />
            <asp:Parameter Name="ImageUrl" Type="String" />
        </InsertParameters>
        <DeleteParameters>
            <asp:Parameter Name="ProductID" Type="Int32" />
        </DeleteParameters>
    </asp:SqlDataSource>
</asp:Content>
