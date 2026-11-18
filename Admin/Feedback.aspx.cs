using System;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_Feedback : Page
{
    protected void gvFeedback_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "MarkRead") return;
        Db.Execute("UPDATE Feedback SET IsRead = 1 WHERE FeedbackID = @id", Db.Param("@id", Convert.ToInt32(e.CommandArgument)));
        gvFeedback.DataBind();
    }
}
