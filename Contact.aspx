<%@ Page Title="Contact & Feedback | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="Contact.aspx.cs" Inherits="ContactPage" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">Contact &amp; Feedback</h1>

    <div class="two-col">
        <div class="card">
            <h2>Tell us what you think</h2>
            <p class="muted small">Comments, suggestions or questions - we read every message.</p>

            <asp:Panel ID="pnlForm" runat="server" DefaultButton="btnSend" CssClass="form">
                <div class="field">
                    <label for="<%= txtName.ClientID %>">Your name</label>
                    <asp:TextBox ID="txtName" runat="server" MaxLength="100" autocomplete="name" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtName" ErrorMessage="Name is required." Text="Name is required." CssClass="error" Display="Dynamic" />
                </div>
                <div class="field">
                    <label for="<%= txtEmail.ClientID %>">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="150" autocomplete="email" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." Text="Email is required." CssClass="error" Display="Dynamic" />
                    <asp:RegularExpressionValidator runat="server" ControlToValidate="txtEmail" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email address." Text="Enter a valid email address." CssClass="error" Display="Dynamic" />
                </div>
                <div class="field">
                    <label for="<%= ddlSubject.ClientID %>">Subject</label>
                    <asp:DropDownList ID="ddlSubject" runat="server">
                        <asp:ListItem Value="">-- Choose a topic --</asp:ListItem>
                        <asp:ListItem>Compliment</asp:ListItem>
                        <asp:ListItem>Suggestion</asp:ListItem>
                        <asp:ListItem>Order question</asp:ListItem>
                        <asp:ListItem>Custom cake enquiry</asp:ListItem>
                        <asp:ListItem>Complaint</asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlSubject" InitialValue="" ErrorMessage="Please choose a subject." Text="Please choose a subject." CssClass="error" Display="Dynamic" />
                </div>
                <div class="field">
                    <label for="<%= txtMessage.ClientID %>">Message</label>
                    <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="5" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtMessage" ErrorMessage="Message is required." Text="Message is required." CssClass="error" Display="Dynamic" />
                    <asp:RegularExpressionValidator runat="server" ControlToValidate="txtMessage" ValidationExpression="^[\s\S]{10,1000}$" ErrorMessage="Message must be 10 to 1000 characters." Text="Message must be 10 to 1000 characters." CssClass="error" Display="Dynamic" />
                </div>
                <asp:Button ID="btnSend" runat="server" Text="Send feedback" CssClass="btn btn-block" OnClick="btnSend_Click" />
            </asp:Panel>

            <asp:Panel ID="pnlThanks" runat="server" Visible="false" CssClass="empty-state pop">
                <span class="ico">&#128150;</span>
                <h2>Thank you!</h2>
                <p>Your feedback has been sent to our team.</p>
                <a class="btn btn-outline" href="Menu.aspx">Back to the menu</a>
            </asp:Panel>
        </div>

        <aside class="stack">
            <div class="card">
                <h3>&#128205; Visit us</h3>
                <p class="small">Baked With Love<br />New Baneshwor, Kathmandu, Nepal</p>
                <h3>&#128222; Call</h3>
                <p class="small"><a href="tel:+9779800000001">+977 980-0000001</a></p>
                <h3>&#9200; Opening hours</h3>
                <p class="small">Every day, 8:00 AM - 8:00 PM<br />Custom cakes: order at least 2 days ahead.</p>
            </div>
            <div class="card">
                <h3>Pickup &amp; delivery</h3>
                <p class="small">Delivery inside Kathmandu valley costs Rs. 100, free for orders over Rs. 2,000. Pickup is free - choose a time slot at checkout.</p>
            </div>
        </aside>
    </div>
</asp:Content>
