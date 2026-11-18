using System;
using System.Security.Cryptography;
using System.Web;
using System.Web.Security;

/// <summary>
/// Login helpers.
/// Passwords are never saved as plain text. We save a random "salt" and a hash of
/// (password + salt). To check a login we hash the typed password the same way and compare.
/// </summary>
public static class Auth
{
    // ---------- Passwords ----------

    /// <summary>Creates a new random salt and the hash for a password (used when registering).</summary>
    public static void HashPassword(string password, out string salt, out string hash)
    {
        byte[] saltBytes = new byte[16];
        RandomNumberGenerator random = RandomNumberGenerator.Create();
        random.GetBytes(saltBytes);

        salt = Convert.ToBase64String(saltBytes);
        hash = ComputeHash(password, saltBytes);
    }

    /// <summary>Returns true if the typed password matches the saved hash.</summary>
    public static bool VerifyPassword(string password, string salt, string storedHash)
    {
        string hash = ComputeHash(password, Convert.FromBase64String(salt));
        return hash == storedHash;
    }

    /// <summary>PBKDF2 with SHA-256, repeated 10,000 times to make guessing passwords slow.</summary>
    private static string ComputeHash(string password, byte[] salt)
    {
        Rfc2898DeriveBytes pbkdf2 = new Rfc2898DeriveBytes(password, salt, 10000, HashAlgorithmName.SHA256);
        byte[] hashBytes = pbkdf2.GetBytes(32);
        return Convert.ToBase64String(hashBytes);
    }

    // ---------- Logging in and out ----------

    /// <summary>
    /// Logs the user in by creating the Forms Authentication cookie.
    /// The cookie stores the user's ID as the name, and "Role|Full name" as extra data.
    /// Global.asax reads the role back on every request.
    /// </summary>
    public static void SignIn(int userId, string fullName, string role, bool remember)
    {
        DateTime expires = DateTime.Now.AddMinutes(60);   // 1 hour
        if (remember)
        {
            expires = DateTime.Now.AddDays(7);             // "Keep me logged in" = 7 days
        }

        FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
            1, userId.ToString(), DateTime.Now, expires, remember,
            role + "|" + fullName, FormsAuthentication.FormsCookiePath);

        HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, FormsAuthentication.Encrypt(ticket));
        cookie.HttpOnly = true;   // JavaScript cannot read the login cookie
        if (remember)
        {
            cookie.Expires = expires;
        }
        HttpContext.Current.Response.Cookies.Add(cookie);
    }

    public static void SignOut()
    {
        FormsAuthentication.SignOut();
        HttpContext.Current.Session.Abandon();
    }

    // ---------- Who is logged in? ----------

    public static bool IsLoggedIn
    {
        get
        {
            HttpContext context = HttpContext.Current;
            return context.User != null && context.User.Identity.IsAuthenticated;
        }
    }

    public static bool IsAdmin
    {
        get { return IsLoggedIn && HttpContext.Current.User.IsInRole("Admin"); }
    }

    /// <summary>The logged-in user's ID, or 0 for visitors.</summary>
    public static int UserId
    {
        get
        {
            if (!IsLoggedIn)
            {
                return 0;
            }
            return Convert.ToInt32(HttpContext.Current.User.Identity.Name);
        }
    }

    /// <summary>The logged-in user's full name (saved in the cookie as "Role|Full name").</summary>
    public static string FullName
    {
        get
        {
            if (!IsLoggedIn)
            {
                return "";
            }
            FormsIdentity identity = (FormsIdentity)HttpContext.Current.User.Identity;
            string[] parts = identity.Ticket.UserData.Split('|');
            if (parts.Length < 2)
            {
                return "";
            }
            return parts[1];
        }
    }
}
