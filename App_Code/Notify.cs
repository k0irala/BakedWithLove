using System;
using System.Configuration;
using System.IO;
using System.Net.Mail;
using System.Web.Hosting;

/// <summary>
/// Sends notifications: always saves an in-app notification, and optionally e-mails the customer.
/// In "Pickup" mode (default) e-mails are written to App_Data\Emails as .eml files so the
/// feature works on any PC with no mail server. Set EmailMode = Smtp in Web.config for real e-mail.
/// </summary>
public static class Notify
{
    public static void Send(int userId, object orderId, string title, string message, bool sendEmail)
    {
        Db.Execute("INSERT INTO Notifications (UserID, OrderID, Title, Message, Channel) VALUES (@u, @o, @t, @m, @c)",
            Db.Param("@u", userId), Db.Param("@o", orderId), Db.Param("@t", title), Db.Param("@m", message),
            Db.Param("@c", sendEmail ? "Email" : "In-App"));

        if (!sendEmail) return;

        try
        {
            object email = Db.Scalar("SELECT Email FROM Users WHERE UserID = @u", Db.Param("@u", userId));
            object name = Db.Scalar("SELECT FullName FROM Users WHERE UserID = @u", Db.Param("@u", userId));
            if (email == null) return;

            MailMessage mail = new MailMessage();
            mail.From = new MailAddress(ConfigurationManager.AppSettings["EmailFrom"], "Baked With Love");
            mail.To.Add(new MailAddress(email.ToString(), Convert.ToString(name)));
            mail.Subject = "Baked With Love - " + title;
            mail.IsBodyHtml = true;
            mail.Body = "<div style='font-family:Arial,sans-serif;max-width:520px'>" +
                        "<h2 style='color:#c2185b'>Baked With Love</h2>" +
                        "<p>Hi " + System.Web.HttpUtility.HtmlEncode(Convert.ToString(name)) + ",</p>" +
                        "<p><strong>" + System.Web.HttpUtility.HtmlEncode(title) + "</strong></p>" +
                        "<p>" + System.Web.HttpUtility.HtmlEncode(message) + "</p>" +
                        "<p style='color:#888'>Thank you for ordering with us. Baked with love, just for you.</p></div>";

            using (SmtpClient smtp = new SmtpClient())
            {
                if (ConfigurationManager.AppSettings["EmailMode"] != "Smtp")
                {
                    string folder = HostingEnvironment.MapPath("~/App_Data/Emails");
                    Directory.CreateDirectory(folder);
                    smtp.EnableSsl = false; // SSL only applies to real SMTP sending
                    smtp.DeliveryMethod = SmtpDeliveryMethod.SpecifiedPickupDirectory;
                    smtp.PickupDirectoryLocation = folder;
                }
                smtp.Send(mail);
            }
        }
        catch (Exception ex)
        {
            // E-mail failure must never stop an order. The in-app notification is already saved,
            // and the error is logged to App_Data\email-errors.log for troubleshooting.
            try
            {
                File.AppendAllText(HostingEnvironment.MapPath("~/App_Data/email-errors.log"),
                    DateTime.Now.ToString("s") + "  " + ex.GetType().Name + ": " + ex.Message + Environment.NewLine);
            }
            catch { }
        }
    }
}
