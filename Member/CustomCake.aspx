<%@ Page Title="Design a Custom Cake | Baked With Love" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeFile="CustomCake.aspx.cs" Inherits="Member_CustomCake" %>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="page-title">&#127874; Design your custom cake</h1>
    <p class="muted">Tell us your dream cake. Our bakers will check the design, confirm the price and get back to you within 24 hours.</p>

    <div class="two-col">
        <div class="card">
            <asp:ValidationSummary runat="server" CssClass="validation-summary" HeaderText="Please complete your cake:" ValidationGroup="cake" />

            <div class="field">
                <span class="label">1. Size</span>
                <div class="radio-cards" id="sizeOptions">
                    <div><asp:RadioButton ID="rbSize1" runat="server" GroupName="size" Text="1 lb<br/><small>serves 6-8</small>" Checked="true" data-price="1200" /></div>
                    <div><asp:RadioButton ID="rbSize2" runat="server" GroupName="size" Text="2 lb<br/><small>serves 12-15</small>" data-price="2200" /></div>
                    <div><asp:RadioButton ID="rbSize3" runat="server" GroupName="size" Text="3 lb<br/><small>serves 20-25</small>" data-price="3200" /></div>
                    <div><asp:RadioButton ID="rbSize4" runat="server" GroupName="size" Text="2-tier<br/><small>serves 35+</small>" data-price="5500" /></div>
                </div>
            </div>

            <div class="field-row">
                <div class="field">
                    <label for="<%= ddlFlavor.ClientID %>">2. Flavour</label>
                    <asp:DropDownList ID="ddlFlavor" runat="server">
                        <asp:ListItem Value="">-- Choose --</asp:ListItem>
                        <asp:ListItem>Vanilla</asp:ListItem><asp:ListItem>Chocolate</asp:ListItem><asp:ListItem>Red Velvet</asp:ListItem>
                        <asp:ListItem>Black Forest</asp:ListItem><asp:ListItem>Butterscotch</asp:ListItem><asp:ListItem>Pineapple</asp:ListItem>
                        <asp:ListItem>Strawberry</asp:ListItem><asp:ListItem>Coffee Mocha</asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlFlavor" ErrorMessage="Choose a flavour." Text="Required." CssClass="error" Display="Dynamic" ValidationGroup="cake" />
                </div>
                <div class="field">
                    <label for="<%= ddlFilling.ClientID %>">3. Filling</label>
                    <asp:DropDownList ID="ddlFilling" runat="server">
                        <asp:ListItem Value="">-- Choose --</asp:ListItem>
                        <asp:ListItem>Fresh Cream</asp:ListItem><asp:ListItem>Chocolate Ganache</asp:ListItem><asp:ListItem>Cream Cheese</asp:ListItem>
                        <asp:ListItem>Fruit Compote</asp:ListItem><asp:ListItem>Nutella</asp:ListItem><asp:ListItem>Caramel</asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlFilling" ErrorMessage="Choose a filling." Text="Required." CssClass="error" Display="Dynamic" ValidationGroup="cake" />
                </div>
            </div>

            <div class="field">
                <span class="label">4. Egg preference</span>
                <div class="radio-cards" style="grid-template-columns:1fr 1fr">
                    <div><asp:RadioButton ID="rbWithEgg" runat="server" GroupName="egg" Text="With egg" Checked="true" /></div>
                    <div><asp:RadioButton ID="rbEggless" runat="server" GroupName="egg" Text="&#129370; Eggless (+Rs. 200)" /></div>
                </div>
            </div>

            <div class="field-row">
                <div class="field">
                    <label for="<%= ddlOccasion.ClientID %>">Occasion</label>
                    <asp:DropDownList ID="ddlOccasion" runat="server">
                        <asp:ListItem>Birthday</asp:ListItem><asp:ListItem>Anniversary</asp:ListItem><asp:ListItem>Wedding</asp:ListItem>
                        <asp:ListItem>Baby Shower</asp:ListItem><asp:ListItem>Graduation</asp:ListItem><asp:ListItem>Festival</asp:ListItem><asp:ListItem>Other</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="field">
                    <label for="<%= txtDate.ClientID %>">Needed on</label>
                    <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
                    <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDate" ErrorMessage="Choose the date you need the cake." Text="Required." CssClass="error" Display="Dynamic" ValidationGroup="cake" />
                    <asp:CustomValidator runat="server" ControlToValidate="txtDate" OnServerValidate="cvDate_ServerValidate" ErrorMessage="Custom cakes need at least 2 days' notice (and up to 60 days ahead)." Text="At least 2 days from today." CssClass="error" Display="Dynamic" ValidationGroup="cake" />
                </div>
            </div>

            <div class="field">
                <label for="<%= txtDesign.ClientID %>">5. Design ideas</label>
                <asp:TextBox ID="txtDesign" runat="server" TextMode="MultiLine" Rows="3" MaxLength="500" placeholder="Colours, theme, toppers, decorations..." />
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtDesign" ErrorMessage="Describe the design you'd like." Text="Required." CssClass="error" Display="Dynamic" ValidationGroup="cake" />
            </div>

            <div class="field">
                <label for="<%= fuReference.ClientID %>">Reference photo (optional)</label>
                <asp:FileUpload ID="fuReference" runat="server" accept="image/jpeg,image/png,image/webp" data-preview="imgPreview" />
                <div class="hint">JPG, PNG or WEBP, up to 4 MB.</div>
                <img id="imgPreview" class="upload-preview hidden" alt="Preview of your reference photo" />
                <asp:CustomValidator ID="cvFile" runat="server" OnServerValidate="cvFile_ServerValidate" ErrorMessage="Reference photo must be a JPG, PNG or WEBP image under 4 MB." Text="Invalid image." CssClass="error" Display="Dynamic" ValidationGroup="cake" />
            </div>

            <div class="field">
                <label for="<%= txtMessage.ClientID %>">Message on the cake</label>
                <asp:TextBox ID="txtMessage" runat="server" MaxLength="40" placeholder="Happy Birthday Aarya" />
                <div class="hint">Up to 40 characters.</div>
            </div>

            <div class="field">
                <label for="<%= txtAllergy.ClientID %>">Allergies &amp; dietary notes</label>
                <asp:TextBox ID="txtAllergy" runat="server" TextMode="MultiLine" Rows="2" MaxLength="300" placeholder="e.g. nut allergy, less sugar" />
                <div class="hint">Our team will review this carefully, but we can't guarantee a kitchen free of all allergens.</div>
            </div>

            <div class="field">
                <span class="label">Collection</span>
                <div class="radio-cards" style="grid-template-columns:1fr 1fr">
                    <div><asp:RadioButton ID="rbPickup" runat="server" GroupName="collect" Text="&#128717; Pickup" Checked="true" /></div>
                    <div><asp:RadioButton ID="rbDelivery" runat="server" GroupName="collect" Text="&#128666; Delivery" /></div>
                </div>
            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Send request to the bakery" CssClass="btn btn-block" OnClick="btnSubmit_Click" ValidationGroup="cake" />
        </div>

        <aside class="stack">
            <div class="points-card">
                <div class="small">Estimated price</div>
                <div class="big" id="estimate">Rs. 1,200</div>
                <div class="small">Final price is confirmed by the bakery after reviewing your design.</div>
            </div>

            <div class="card">
                <h2>My requests</h2>
                <asp:Repeater ID="rptRequests" runat="server" OnItemCommand="rptRequests_ItemCommand">
                    <ItemTemplate>
                        <div class="review">
                            <div class="row between">
                                <strong>#<%# Eval("CustomOrderID") %> &middot; <%# Eval("CakeSize") %> <%# Server.HtmlEncode(Eval("Flavor").ToString()) %></strong>
                                <span class='<%# Shop.StatusCss(Eval("Status")) %>'><%# Eval("Status") %></span>
                            </div>
                            <div class="muted small">For <%# ((DateTime)Eval("RequiredDate")).ToString("dd MMM yyyy") %> &middot; <%# Eval("Occasion") %> &middot; <%# Eval("EggOption") %></div>
                            <%# Eval("QuotedPrice") != DBNull.Value ? "<div style='margin-top:4px'>Quoted price: <strong style='color:var(--pink)'>" + Shop.Money(Eval("QuotedPrice")) + "</strong></div>" : "" %>
                            <%# Eval("AdminNote") != DBNull.Value ? "<div class='small'>Bakery note: " + Server.HtmlEncode(Eval("AdminNote").ToString()) + "</div>" : "" %>
                            <asp:PlaceHolder runat="server" Visible='<%# Eval("Status").ToString() == "Quoted" %>'>
                                <div class="row" style="margin-top:8px">
                                    <asp:Button runat="server" Text="Accept quote" CssClass="btn btn-small" CommandName="Accept" CommandArgument='<%# Eval("CustomOrderID") %>' CausesValidation="false" />
                                    <asp:Button runat="server" Text="Decline" CssClass="btn btn-small btn-outline" CommandName="Decline" CommandArgument='<%# Eval("CustomOrderID") %>' CausesValidation="false" OnClientClick="return confirm('Decline this quote?');" />
                                </div>
                            </asp:PlaceHolder>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblNoRequests" runat="server" CssClass="muted small" Text="You haven't requested a custom cake yet." Visible="false" />
            </div>
        </aside>
    </div>

    <script>
        // Live price estimate (client-side only; the bakery confirms the real price)
        (function () {
            function update() {
                var size = document.querySelector("#sizeOptions input:checked");
                var base = size ? parseInt(size.parentNode.getAttribute("data-price") || size.getAttribute("data-price"), 10) : 1200;
                var eggless = document.getElementById("<%= rbEggless.ClientID %>").checked ? 200 : 0;
                document.getElementById("estimate").textContent = "Rs. " + (base + eggless).toLocaleString("en-IN");
            }
            document.addEventListener("change", update);
            document.addEventListener("DOMContentLoaded", update);
        })();
    </script>
</asp:Content>
