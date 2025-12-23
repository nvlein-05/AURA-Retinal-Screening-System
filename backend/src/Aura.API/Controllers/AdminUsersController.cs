using Aura.API.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Aura.API.Controllers;

[ApiController]
[Route("api/admin/users")]
[Authorize(Policy = "AdminOnly")]
public class AdminUsersController : ControllerBase
{
    private readonly AdminAccountRepository _repo;
    private readonly IConfiguration _config;

    public AdminUsersController(AdminAccountRepository repo, IConfiguration config)
    {
        _repo = repo;
        _config = config;
    }

    private bool UseDemoMode => _config.GetValue<bool>("Admin:UseDemoMode", false);

    private static List<AdminUserRowDto> DemoUsers => new()
    {
        new("user-1", "nguyen.van.a@gmail.com", "nguyenvana", "Nguyễn", "Văn A", true, true),
        new("user-2", "tran.thi.b@gmail.com", "tranthib", "Trần", "Thị B", true, true),
        new("user-3", "le.van.c@gmail.com", "levanc", "Lê", "Văn C", false, false),
    };

    [HttpGet]
    public async Task<ActionResult<List<AdminUserRowDto>>> List([FromQuery] string? search, [FromQuery] bool? isActive)
    {
        try
        {
            return Ok(await _repo.ListUsersAsync(search, isActive));
        }
        catch
        {
            if (UseDemoMode) return Ok(DemoUsers);
            return StatusCode(500, new { message = "Không kết nối được database." });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(string id, [FromBody] AdminUpdateUserDto dto)
    {
        try
        {
            var n = await _repo.UpdateUserAsync(id, dto);
            return n == 0 ? NotFound() : NoContent();
        }
        catch
        {
            if (UseDemoMode) return NoContent();
            return StatusCode(500, new { message = "Không kết nối được database." });
        }
    }

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> SetStatus(string id, [FromBody] AdminUpdateUserDto dto)
    {
        if (!dto.IsActive.HasValue) return BadRequest(new { message = "Thiếu IsActive" });
        try
        {
            var n = await _repo.SetUserActiveAsync(id, dto.IsActive.Value);
            return n == 0 ? NotFound() : NoContent();
        }
        catch
        {
            if (UseDemoMode) return NoContent();
            return StatusCode(500, new { message = "Không kết nối được database." });
        }
    }
}


