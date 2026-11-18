<%@ Page Title="Reviews & Feedback | Bakery Admin" Language="C#" MasterPageFile="~/Admin/Admin.master" AutoEventWireup="true" CodeFile="Feedback.aspx.cs" Inherits="Admin_Feedback" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">Reviews &amp; feedback</h1>

    <section class="section">
        <h2>Product reviews</h2>
        <p class="muted small">Hide reviews that are inappropriate. Hidden reviews don't count towards product ratings.</p>
        <div class="table-wrap">
            <asp:GridView ID="gvReviews" runat="server" DataSourceID="dsReviews" DataKeyNames="ReviewID" AutoGenerateColumns="false"
                CssClass="grid-table" GridLines="None" AllowPaging="true" PageSize="8" PagerStyle-CssClass="pager" EmptyDataText="No reviews yet.">
                <Columns>
                    <asp:BoundField DataField="CreatedAt" HeaderText="Date" DataFormatString="{0:dd MMM}" ReadOnly="true" />
                    <asp:BoundField DataField="ProductName" HeaderText="Product" ReadOnly="true" />
                    <asp:BoundField DataField="FullName" HeaderText="Customer" ReadOnly="true" />
                    <asp:TemplateField HeaderText="Rating">
                        <ItemTemplate><bwl:StarRating runat="server" Rating='<%# Convert.ToDecimal(Eval("Rating")) %>' ShowCount="false" /></ItemTemplate>
                        <EditItemTemplate><bwl:StarRating runat="server" Rating='<%# Convert.ToDecimal(Eval("Rating")) %>' ShowCount="false" /></EditItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Comment" HeaderText="Comment" ReadOnly="true" NullDisplayText="-" />
                    <asp:CheckBoxField DataField="IsVisible" HeaderText="Visible" />
                    <asp:CommandField ShowEditButton="true" EditText="Show/Hide" ShowDeleteButton="true" />
                </Columns>
            </asp:GridView>
        </div>
    </section>

    <section class="section">
        <h2>Visitor feedback</h2>
        <div class="table-wrap">
            <asp:GridView ID="gvFeedback" runat="server" DataSourceID="dsFeedback" DataKeyNames="FeedbackID" AutoGenerateColumns="false"
                CssClass="grid-table" GridLines="None" AllowPaging="true" PageSize="8" PagerStyle-CssClass="pager" EmptyDataText="No feedback yet."
                OnRowCommand="gvFeedback_RowCommand">
                <Columns>
                    <asp:BoundField DataField="CreatedAt" HeaderText="Date" DataFormatString="{0:dd MMM, h:mm tt}" />
                    <asp:TemplateField HeaderText="From"><ItemTemplate><strong><%# Server.HtmlEncode(Eval("Name").ToString()) %></strong><br /><a class="small" href='mailto:<%# Server.HtmlEncode(Eval("Email").ToString()) %>'><%# Server.HtmlEncode(Eval("Email").ToString()) %></a></ItemTemplate></asp:TemplateField>
                    <asp:BoundField DataField="Subject" HeaderText="Subject" />
                    <asp:BoundField DataField="Message" HeaderText="Message" />
                    <asp:TemplateField HeaderText="">
                        <ItemTemplate>
                            <%# (bool)Eval("IsRead") ? "<span class='badge'>Read</span>" : "<span class='badge badge-pending'>New</span>" %>
                            <asp:LinkButton runat="server" CommandName="MarkRead" CommandArgument='<%# Eval("FeedbackID") %>' Visible='<%# !(bool)Eval("IsRead") %>' CssClass="small">Mark read</asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="Delete" CssClass="small" OnClientClick="return confirm('Delete this feedback?');">Delete</asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </section>

    <asp:SqlDataSource ID="dsReviews" runat="server" ConnectionString="<%$ ConnectionStrings:BakeryDB %>"
        SelectCommand="SELECT r.ReviewID, r.CreatedAt, r.Rating, r.Comment, r.IsVisible, p.ProductName, u.FullName
                       FROM Reviews r JOIN Products p ON p.ProductID = r.ProductID JOIN Users u ON u.UserID = r.UserID ORDER BY r.CreatedAt DESC"
        UpdateCommand="UPDATE Reviews SET IsVisible = @IsVisible WHERE ReviewID = @ReviewID"
        DeleteCommand="DELETE FROM Reviews WHERE ReviewID = @ReviewID">
        <UpdateParameters>
            <asp:Parameter Name="IsVisible" Type="Boolean" />
            <asp:Parameter Name="ReviewID" Type="Int32" />
        </UpdateParameters>
        <DeleteParameters><asp:Parameter Name="ReviewID" Type="Int32" /></DeleteParameters>
    </asp:SqlDataSource>

    <asp:SqlDataSource ID="dsFeedback" runat="server" ConnectionString="<%$ ConnectionStrings:BakeryDB %>"
        SelectCommand="SELECT FeedbackID, Name, Email, Subject, Message, IsRead, CreatedAt FROM Feedback ORDER BY IsRead, CreatedAt DESC"
        DeleteCommand="DELETE FROM Feedback WHERE FeedbackID = @FeedbackID">
        <DeleteParameters><asp:Parameter Name="FeedbackID" Type="Int32" /></DeleteParameters>
    </asp:SqlDataSource>
</asp:Content>
