using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// Small ADO.NET helper. Every query uses SqlParameters to prevent SQL injection.
/// </summary>
public static class Db
{
    public static string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["BakeryDB"].ConnectionString; }
    }

    /// <summary>
    /// Creates a SQL parameter, e.g. Db.Param("@id", 5).
    /// SQL Server needs DBNull.Value instead of C# null, so we swap it here.
    /// </summary>
    public static SqlParameter Param(string name, object value)
    {
        if (value == null)
        {
            value = DBNull.Value;
        }
        return new SqlParameter(name, value);
    }

    public static DataTable Query(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(sql, con))
        {
            cmd.Parameters.AddRange(parameters);
            DataTable table = new DataTable();
            new SqlDataAdapter(cmd).Fill(table);
            return table;
        }
    }

    /// <summary>Runs a SELECT and returns the first row, or null if nothing was found.</summary>
    public static DataRow Row(string sql, params SqlParameter[] parameters)
    {
        DataTable table = Query(sql, parameters);
        if (table.Rows.Count == 0)
        {
            return null;
        }
        return table.Rows[0];
    }

    public static int Execute(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(sql, con))
        {
            cmd.Parameters.AddRange(parameters);
            con.Open();
            return cmd.ExecuteNonQuery();
        }
    }

    public static object Scalar(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection con = new SqlConnection(ConnStr))
        using (SqlCommand cmd = new SqlCommand(sql, con))
        {
            cmd.Parameters.AddRange(parameters);
            con.Open();
            object result = cmd.ExecuteScalar();
            if (result == DBNull.Value)
            {
                return null;
            }
            return result;
        }
    }

    /// <summary>Runs a command inside an existing transaction (used for checkout).</summary>
    public static object ScalarTx(SqlConnection con, SqlTransaction tx, string sql, params SqlParameter[] parameters)
    {
        using (SqlCommand cmd = new SqlCommand(sql, con, tx))
        {
            cmd.Parameters.AddRange(parameters);
            return cmd.ExecuteScalar();
        }
    }

    public static int ExecuteTx(SqlConnection con, SqlTransaction tx, string sql, params SqlParameter[] parameters)
    {
        using (SqlCommand cmd = new SqlCommand(sql, con, tx))
        {
            cmd.Parameters.AddRange(parameters);
            return cmd.ExecuteNonQuery();
        }
    }
}
