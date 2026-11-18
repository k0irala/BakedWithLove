<%@ Page Title="Categories & Slots | Bakery Admin" Language="C#" MasterPageFile="~/Admin/Admin.master" AutoEventWireup="true" CodeFile="Categories.aspx.cs" Inherits="Admin_Categories" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">Categories &amp; pickup slots</h1>
    <asp:Label ID="lblMsg" runat="server" Visible="false" style="display:block" />

    <div class="two-col">
        <section class="stack">
            <h2>Product categories</h2>
            <div class="table-wrap">
                <asp:GridView ID="gvCategories" runat="server" DataSourceID="dsCategories" DataKeyNames="CategoryID" AutoGenerateColumns="false"
                    CssClass="grid-table" GridLines="None" OnRowDeleted="gvCategories_RowDeleted" OnRowUpdated="gvCategories_RowUpdated">
                    <Columns>
                        <asp:TemplateField HeaderText="">
                            <ItemTemplate><img class="thumb" src='<%# Shop.Img(Eval("ImageUrl")) %>' alt="" /></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Name">
                            <ItemTemplate><strong><%# Server.HtmlEncode(Eval("CategoryName").ToString()) %></strong></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtName" runat="server" Text='<%# Bind("CategoryName") %>' MaxLength="60" />
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName" ErrorMessage="Required" CssClass="error" Display="Dynamic" ValidationGroup="editCat" />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Description">
                            <ItemTemplate><span class="small"><%# Server.HtmlEncode(Convert.ToString(Eval("Description"))) %></span></ItemTemplate>
                            <EditItemTemplate><asp:TextBox ID="txtDesc" runat="server" Text='<%# Bind("Description") %>' MaxLength="250" /></EditItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="ProductCount" HeaderText="Products" ReadOnly="true" />
                        <asp:CommandField ShowEditButton="true" ShowDeleteButton="true" ValidationGroup="editCat" />
                    </Columns>
                </asp:GridView>
            </div>
            <p class="hint">A category can only be deleted when it has no products.</p>

            <div class="card form">
                <h3>Add category</h3>
                <div class="field">
                    <label for="<%= txtNewName.ClientID %>">Name</label>
                    <asp:TextBox ID="txtNewName" runat="server" MaxLength="60" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNewName" ErrorMessage="Category name is required." CssClass="error" Display="Dynamic" ValidationGroup="addCat" />
                    <asp:CustomValidator runat="server" ControlToValidate="txtNewName" OnServerValidate="cvUnique_ServerValidate" ErrorMessage="That category already exists." CssClass="error" Display="Dynamic" ValidationGroup="addCat" />
                </div>
                <div class="field">
                    <label for="<%= txtNewDesc.ClientID %>">Description</label>
                    <asp:TextBox ID="txtNewDesc" runat="server" MaxLength="250" />
                </div>
                <asp:Button ID="btnAddCat" runat="server" Text="Add category" CssClass="btn" OnClick="btnAddCat_Click" ValidationGroup="addCat" />
            </div>
        </section>

        <section class="stack">
            <h2>Pickup time slots</h2>
            <div class="table-wrap">
                <asp:GridView ID="gvSlots" runat="server" DataSourceID="dsSlots" DataKeyNames="SlotID" AutoGenerateColumns="false"
                    CssClass="grid-table" GridLines="None">
                    <Columns>
                        <asp:TemplateField HeaderText="Time" ItemStyle-CssClass="nowrap">
                            <ItemTemplate><%# Eval("SlotLabel") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtLabel" runat="server" Text='<%# Bind("SlotLabel") %>' MaxLength="50" />
                                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtLabel" ErrorMessage="Required" CssClass="error" Display="Dynamic" ValidationGroup="editSlot" />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Orders / slot">
                            <ItemTemplate><%# Eval("Capacity") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtCap" runat="server" Text='<%# Bind("Capacity") %>' TextMode="Number" style="width:70px" />
                                <asp:RangeValidator runat="server" ControlToValidate="txtCap" Type="Integer" MinimumValue="1" MaximumValue="50" ErrorMessage="1 - 50" CssClass="error" Display="Dynamic" ValidationGroup="editSlot" />
                            </EditItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="BookedToday" HeaderText="Booked today" ReadOnly="true" />
                        <asp:CheckBoxField DataField="IsActive" HeaderText="Open" />
                        <asp:CommandField ShowEditButton="true" ValidationGroup="editSlot" />
                    </Columns>
                </asp:GridView>
            </div>

            <div class="card form">
                <h3>Add a slot</h3>
                <div class="field-row">
                    <div class="field">
                        <label for="<%= txtSlotLabel.ClientID %>">Time</label>
                        <asp:TextBox ID="txtSlotLabel" runat="server" MaxLength="50" placeholder="07:00 PM - 08:00 PM" />
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtSlotLabel" ErrorMessage="Enter a time range." CssClass="error" Display="Dynamic" ValidationGroup="addSlot" />
                    </div>
                    <div class="field">
                        <label for="<%= txtSlotCap.ClientID %>">Capacity</label>
                        <asp:TextBox ID="txtSlotCap" runat="server" TextMode="Number" Text="5" />
                        <asp:RangeValidator runat="server" ControlToValidate="txtSlotCap" Type="Integer" MinimumValue="1" MaximumValue="50" ErrorMessage="Capacity must be 1 - 50." CssClass="error" Display="Dynamic" ValidationGroup="addSlot" />
                    </div>
                </div>
                <asp:Button ID="btnAddSlot" runat="server" Text="Add slot" CssClass="btn" OnClick="btnAddSlot_Click" ValidationGroup="addSlot" />
            </div>
        </section>
    </div>

    <asp:SqlDataSource ID="dsCategories" runat="server" ConnectionString="<%$ ConnectionStrings:BakeryDB %>"
        SelectCommand="SELECT c.CategoryID, c.CategoryName, c.Description, c.ImageUrl, (SELECT COUNT(*) FROM Products p WHERE p.CategoryID = c.CategoryID) AS ProductCount FROM Categories c ORDER BY c.CategoryID"
        InsertCommand="INSERT INTO Categories (CategoryName, Description, ImageUrl) VALUES (@CategoryName, @Description, '~/Images/Products/placeholder.svg')"
        UpdateCommand="UPDATE Categories SET CategoryName = @CategoryName, Description = @Description WHERE CategoryID = @CategoryID"
        DeleteCommand="DELETE FROM Categories WHERE CategoryID = @CategoryID AND NOT EXISTS (SELECT 1 FROM Products WHERE CategoryID = @CategoryID)">
        <InsertParameters>
            <asp:ControlParameter Name="CategoryName" ControlID="txtNewName" PropertyName="Text" Type="String" />
            <asp:ControlParameter Name="Description" ControlID="txtNewDesc" PropertyName="Text" Type="String" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="CategoryName" Type="String" />
            <asp:Parameter Name="Description" Type="String" />
            <asp:Parameter Name="CategoryID" Type="Int32" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="CategoryID" Type="Int32" />
        </DeleteParameters>
    </asp:SqlDataSource>

    <asp:SqlDataSource ID="dsSlots" runat="server" ConnectionString="<%$ ConnectionStrings:BakeryDB %>"
        SelectCommand="SELECT s.SlotID, s.SlotLabel, s.Capacity, s.IsActive, (SELECT COUNT(*) FROM Orders o WHERE o.SlotID = s.SlotID AND o.PreferredDate = CAST(GETDATE() AS DATE) AND o.Status &lt;&gt; 'Cancelled') AS BookedToday FROM PickupSlots s ORDER BY s.SlotID"
        InsertCommand="INSERT INTO PickupSlots (SlotLabel, Capacity) VALUES (@SlotLabel, @Capacity)"
        UpdateCommand="UPDATE PickupSlots SET SlotLabel = @SlotLabel, Capacity = @Capacity, IsActive = @IsActive WHERE SlotID = @SlotID">
        <InsertParameters>
            <asp:ControlParameter Name="SlotLabel" ControlID="txtSlotLabel" PropertyName="Text" Type="String" />
            <asp:ControlParameter Name="Capacity" ControlID="txtSlotCap" PropertyName="Text" Type="Int32" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="SlotLabel" Type="String" />
            <asp:Parameter Name="Capacity" Type="Int32" />
            <asp:Parameter Name="IsActive" Type="Boolean" />
            <asp:Parameter Name="SlotID" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
</asp:Content>
