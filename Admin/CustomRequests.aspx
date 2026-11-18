<%@ Page Title="Custom Cakes | Bakery Admin" Language="C#" MasterPageFile="~/Admin/Admin.master" AutoEventWireup="true" CodeFile="CustomRequests.aspx.cs" Inherits="Admin_CustomRequests" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">Custom cake requests</h1>
    <p class="muted small">Workflow: <span class="badge badge-pending-review">Pending Review</span> &rarr; send a quote <span class="badge badge-quoted">Quoted</span> &rarr; customer <span class="badge badge-accepted">Accepted</span> &rarr; <span class="badge badge-in-progress">In Progress</span> &rarr; <span class="badge badge-completed">Completed</span></p>

    <div class="table-wrap">
        <asp:GridView ID="gvRequests" runat="server" AutoGenerateColumns="false" CssClass="grid-table" GridLines="None" DataKeyNames="CustomOrderID"
            OnSelectedIndexChanged="gvRequests_SelectedIndexChanged" EmptyDataText="No custom cake requests yet." SelectedRowStyle-BackColor="#fde4ec">
            <Columns>
                <asp:BoundField DataField="CustomOrderID" HeaderText="#" />
                <asp:BoundField DataField="FullName" HeaderText="Customer" />
                <asp:TemplateField HeaderText="Cake"><ItemTemplate><%# Eval("CakeSize") %> <%# Server.HtmlEncode(Eval("Flavor").ToString()) %> &middot; <%# Eval("EggOption") %></ItemTemplate></asp:TemplateField>
                <asp:BoundField DataField="Occasion" HeaderText="Occasion" />
                <asp:BoundField DataField="RequiredDate" HeaderText="Needed" DataFormatString="{0:dd MMM}" />
                <asp:TemplateField HeaderText="Quote"><ItemTemplate><%# Shop.Money(Eval("QuotedPrice")) %></ItemTemplate></asp:TemplateField>
                <asp:TemplateField HeaderText="Status"><ItemTemplate><span class='<%# Shop.StatusCss(Eval("Status")) %>'><%# Eval("Status") %></span></ItemTemplate></asp:TemplateField>
                <asp:CommandField ShowSelectButton="true" SelectText="Review &rarr;" />
            </Columns>
        </asp:GridView>
    </div>

    <asp:Panel ID="pnlDetail" runat="server" Visible="false" CssClass="two-col section">
        <div class="card">
            <h2>Request #<asp:Literal ID="litId" runat="server" /></h2>
            <asp:DetailsView ID="dvRequest" runat="server" AutoGenerateRows="false" CssClass="details-table" GridLines="None">
                <Fields>
                    <asp:BoundField DataField="FullName" HeaderText="Customer" />
                    <asp:BoundField DataField="Email" HeaderText="Email" />
                    <asp:BoundField DataField="Phone" HeaderText="Phone" />
                    <asp:BoundField DataField="CakeSize" HeaderText="Size" />
                    <asp:BoundField DataField="Flavor" HeaderText="Flavour" />
                    <asp:BoundField DataField="Filling" HeaderText="Filling" />
                    <asp:BoundField DataField="EggOption" HeaderText="Egg" />
                    <asp:BoundField DataField="Occasion" HeaderText="Occasion" />
                    <asp:BoundField DataField="DesignNotes" HeaderText="Design" />
                    <asp:BoundField DataField="CakeMessage" HeaderText="Message on cake" NullDisplayText="-" />
                    <asp:TemplateField HeaderText="Allergies">
                        <ItemTemplate><%# Eval("AllergyNotes") == DBNull.Value ? "-" : "<strong style='color:var(--red)'>&#9888; " + Server.HtmlEncode(Eval("AllergyNotes").ToString()) + "</strong>" %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="RequiredDate" HeaderText="Needed on" DataFormatString="{0:dddd, dd MMM yyyy}" />
                    <asp:BoundField DataField="DeliveryType" HeaderText="Collection" />
                    <asp:BoundField DataField="CreatedAt" HeaderText="Requested" DataFormatString="{0:dd MMM, h:mm tt}" />
                </Fields>
            </asp:DetailsView>
        </div>

        <div class="stack">
            <asp:Panel ID="pnlImage" runat="server" CssClass="card">
                <h3>Reference photo</h3>
                <asp:HyperLink ID="lnkImage" runat="server" Target="_blank"><asp:Image ID="imgRef" runat="server" style="border-radius:12px" /></asp:HyperLink>
            </asp:Panel>

            <div class="card form">
                <h3>Respond to customer</h3>
                <div class="field">
                    <label for="<%= ddlStatus.ClientID %>">Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server">
                        <asp:ListItem>Pending Review</asp:ListItem>
                        <asp:ListItem>Quoted</asp:ListItem>
                        <asp:ListItem>Rejected</asp:ListItem>
                        <asp:ListItem>In Progress</asp:ListItem>
                        <asp:ListItem>Completed</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="field">
                    <label for="<%= txtPrice.ClientID %>">Quoted price (Rs.)</label>
                    <asp:TextBox ID="txtPrice" runat="server" TextMode="Number" />
                    <asp:RangeValidator runat="server" ControlToValidate="txtPrice" Type="Double" MinimumValue="100" MaximumValue="200000" ErrorMessage="Price must be between 100 and 200,000." CssClass="error" Display="Dynamic" ValidationGroup="quote" />
                    <asp:CustomValidator runat="server" OnServerValidate="cvPrice_ServerValidate" ErrorMessage="Enter a price before sending a quote." CssClass="error" Display="Dynamic" ValidationGroup="quote" />
                </div>
                <div class="field">
                    <label for="<%= txtNote.ClientID %>">Note to customer</label>
                    <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" Rows="3" MaxLength="300" placeholder="e.g. Unicorn topper included. Eggless sponge confirmed." />
                </div>
                <asp:Button ID="btnSave" runat="server" Text="Save and notify customer" CssClass="btn" OnClick="btnSave_Click" ValidationGroup="quote" />
            </div>
        </div>
    </asp:Panel>
</asp:Content>
