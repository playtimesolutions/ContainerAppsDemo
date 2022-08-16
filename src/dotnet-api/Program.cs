using DotnetApi;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddKeyVaultSecrets("dotnet-api");
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateLogger();

var app = builder.Build();
app.UseSwagger();
app.UseSwaggerUI();
app.MapGet("/config", () =>
{
    foreach (var k in builder.Configuration
                 .AsEnumerable()
                 .OrderBy(k => k.Key))
    {
        Log.Information($"{k.Key}: {k.Value}");
    }
});

app.Run();