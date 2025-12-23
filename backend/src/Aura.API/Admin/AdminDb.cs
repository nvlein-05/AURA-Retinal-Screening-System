using Npgsql;

namespace Aura.API.Admin;

public class AdminDb
{
    private readonly IConfiguration _config;

    public AdminDb(IConfiguration config)
    {
        _config = config;
    }

    public NpgsqlConnection OpenConnection()
    {
        var cs = _config.GetConnectionString("DefaultConnection");
        if (string.IsNullOrWhiteSpace(cs))
            throw new InvalidOperationException("ConnectionStrings:DefaultConnection chưa được cấu hình.");

        var conn = new NpgsqlConnection(cs);
        conn.Open();
        return conn;
    }
}


