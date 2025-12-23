using Aura.Application.Services.Users;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// In-memory user service for demo (does not touch other infra)
builder.Services.AddSingleton<IUserService, UserService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// For local dev we serve only HTTP on http://localhost:5000
// so we skip HTTPS redirection to tránh warning và shutdown.
app.UseAuthorization();
app.MapControllers();
app.Run();

