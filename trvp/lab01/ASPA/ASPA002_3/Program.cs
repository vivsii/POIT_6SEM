using Microsoft.AspNetCore.Diagnostics;
using Microsoft.Extensions.Logging;

internal class Program
{
    private static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        builder.Logging.AddFilter("Microsoft.AspNetCore.Diagnostics", LogLevel.None); // ������ ���������

        var app = builder.Build();

        app.UseExceptionHandler("/error");

        app.MapGet("/", () => "Start");

        app.MapGet("/test1", () =>
        {
            throw new Exception("-- Exception Test --");
        });

        app.MapGet("/test2", () =>
        {
            int x = 0, y = 5, z = 0;
            z = y / x;
            return "test2";
        });

        app.MapGet("/test3", () =>
        {
            int[] x = new int[] { 1, 2, 3 };
            int y = x[3];
            return "test3";
        });

        app.MapGet("/error", async (ILogger<Program> logger, HttpContext context) =>
        {
            IExceptionHandlerFeature? exobj = context.Features.Get<IExceptionHandlerFeature>();
            await context.Response.WriteAsync($"<h1>OOPs!</h1>");
            logger.LogError(exobj?.Error, "ExceptionHAndler");
        });

        app.Run();
    }
}