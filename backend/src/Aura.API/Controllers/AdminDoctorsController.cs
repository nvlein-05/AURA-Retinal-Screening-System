using Aura.API.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Aura.API.Controllers;

[ApiController]
[Route("api/admin/doctors")]
[Authorize(Policy = "AdminOnly")]
public class AdminDoctorsController : ControllerBase
{
    private readonly AdminAccountRepository _repo;
    private readonly IConfiguration _config;

    public AdminDoctorsController(AdminAccountRepository repo, IConfiguration config)
    {
        _repo = repo;
        _config = config;
    }

    private bool UseDemoMode => _config.GetValue<bool>("Admin:UseDemoMode", false);

    private static List<AdminDoctorRowDto> DemoDoctors => new()
    {
        new("doctor-1", "bs.hoang@hospital.vn", "bshoang", "Hoàng", "Văn Nam", "BS-12345", true, true),
        new("doctor-2", "bs.linh@hospital.vn", "bslinh", "Linh", "Thị Hoa", "BS-67890", true, true),
        new("doctor-3", "bs.minh@hospital.vn", "bsminh", "Minh", "Đức", "BS-11111", false, false),
    };

    [HttpGet]
    public async Task<ActionResult<List<AdminDoctorRowDto>>> List([FromQuery] string? search, [FromQuery] bool? isActive)
    {
        try
        {
            return Ok(await _repo.ListDoctorsAsync(search, isActive));
        }
        catch
        {
            if (UseDemoMode) return Ok(DemoDoctors);
            return StatusCode(500, new { message = "Không kết nối được database." });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(string id, [FromBody] AdminUpdateDoctorDto dto)
    {
        try
        {
            var n = await _repo.UpdateDoctorAsync(id, dto);
            return n == 0 ? NotFound() : NoContent();
        }
        catch
        {
            if (UseDemoMode) return NoContent();
            return StatusCode(500, new { message = "Không kết nối được database." });
        }
    }

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> SetStatus(string id, [FromBody] AdminUpdateDoctorDto dto)
    {
        if (!dto.IsActive.HasValue) return BadRequest(new { message = "Thiếu IsActive" });
        try
        {
            var n = await _repo.SetDoctorActiveAsync(id, dto.IsActive.Value);
            return n == 0 ? NotFound() : NoContent();
        }
        catch
        {
            if (UseDemoMode) return NoContent();
            return StatusCode(500, new { message = "Không kết nối được database." });
        }
    }
}


