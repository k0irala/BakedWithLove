using System;
using System.Text;
using System.Web.UI;

/// <summary>Displays a 0-5 star rating, e.g. ★★★★☆ (12).</summary>
public partial class Controls_StarRating : UserControl
{
    private bool showCount = true;

    public decimal Rating { get; set; }
    public int Count { get; set; }
    public bool ShowCount { get { return showCount; } set { showCount = value; } }

    protected string StarsHtml
    {
        get
        {
            int full = (int)Math.Round(Rating, MidpointRounding.AwayFromZero);
            StringBuilder sb = new StringBuilder();
            for (int i = 1; i <= 5; i++)
            {
                sb.Append(i <= full ? "&#9733;" : "<span class=\"off\">&#9733;</span>");
            }
            return sb.ToString();
        }
    }
}
