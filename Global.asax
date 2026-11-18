<%@ Application Language="C#" %>
<%@ Import Namespace="System.Security.Principal" %>
<%@ Import Namespace="System.Web.Security" %>

<script runat="server">
    // After Forms Authentication reads the cookie, attach the user's role (stored in the ticket)
    // so that <authorization roles="Admin"> in Web.config and User.IsInRole("Admin") work.
    protected void Application_PostAuthenticateRequest(object sender, EventArgs e)
    {
        if (Context.User == null || !Context.User.Identity.IsAuthenticated) return;

        FormsIdentity identity = Context.User.Identity as FormsIdentity;
        if (identity == null) return;

        string role = identity.Ticket.UserData.Split('|')[0];
        Context.User = new GenericPrincipal(identity, new string[] { role });
    }
</script>
