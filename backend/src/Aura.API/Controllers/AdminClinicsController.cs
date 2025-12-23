using Aura.API.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Aura.API.Controllers;

[ApiController]
[Route("api/admin/clinics")]
[Authorize(Policy = "AdminOnly")]
public class AdminClinicsController : ControllerBase
{
    private readonly AdminAccountRepository _repo;
    private readonly IConfiguration _config;

    public AdminClinicsController(AdminAccountRepository repo, IConfiguration config)
    {
        _repo = repo;
        _config = config;
    }

    private bool UseDemoMode => _config.GetValue<bool>("Admin:UseDemoMode", false);

    private static List<AdminClinicRowDto> DemoClinics => new()
    {
        new("clinic-1", "Phòng khám Mắt Sài Gòn", "matsg@clinic.vn", "028-1234-5678", "123 Nguyễn Huệ, Q1, TP.HCM", "Verified", true),
        new("clinic-2", "Bệnh viện Mắt Hà Nội", "mathn@clinic.vn", "024-9876-5432", "456 Phố Huế, Hai Bà Trưng, HN", "Verified", true),
        new("clinic-3", "Phòng khám Đa khoa ABC", "abc@clinic.vn", "028-1111-2222", "789 Lê Lợi, Q3, TP.HCM", "Pending", false),
    };

    [HttpGet]
    public async Task<ActionResult<List<AdminClinicRowDto>>> List([FromQuery] string? search, [FromQuery] bool? isActive)
    {
        try
        {
            return Ok(await _repo.ListClinicsAsync(search, isActive));
        }
        catch
        {
            if (UseDemoMode) return Ok(DemoClinics);
            return StatusCode(500, new { message = "Không kết nối được database." });
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(string id, [FromBody] AdminUpdateClinicDto dto)
    {
        try
        {
            var n = await _repo.UpdateClinicAsync(id, dto);
            return n == 0 ? NotFound() : NoContent();
        }
        catch
        {
            if (UseDemoMode) return NoContent();
            return StatusCode(500, new { message = "Không kết nối được database." });
        }
    }

    [HttpPatch("{id}/status")]
    public async Task<IActionResult> SetStatus(string id, [FromBody] AdminUpdateClinicDto dto)
    {
        if (!dto.IsActive.HasValue) return BadRequest(new { message = "Thiếu IsActive" });
        try
        {
            var n = await _repo.SetClinicActiveAsync(id, dto.IsActive.Value);
            return n == 0 ? NotFound() : NoContent();
        }
        catch
        {
            if (UseDemoMode) return NoContent();
            return StatusCode(500, new { message = "Không kết nối được database." });
        }
    }
}


