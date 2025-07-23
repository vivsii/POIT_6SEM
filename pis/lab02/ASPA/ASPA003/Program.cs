using DAL003;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.UseDirectoryBrowser(new DirectoryBrowserOptions
{
    FileProvider = new PhysicalFileProvider(
        Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Celebrities", "download")),
    RequestPath = "/Celebrities/download"
});

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(
        Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "Celebrities", "download")),
    RequestPath = "/Celebrities/download",
    OnPrepareResponse = ctx =>
    {
        ctx.Context.Response.Headers.Append("Content-Disposition", "attachment");
    }
});

Repository.JSONFileName = "Celebrities.json";
using (IRepository repository = Repository.Create("Celebrities"))
{
    app.MapGet("/Celebrities", () => repository.getAllCelebrities());
    app.MapGet("/Celebrities/{id:int}", (int id) => repository.getCelebrityById(id));
    app.MapGet("/Celebrities/BySurname/{surname}", (string surname) => repository.getCelebritiesBySurname(surname));

    app.MapGet("/Celebrities/PhotoPathById/{id:int}", (int id) =>
    {
        var photoPath = repository.getPhotoPathById(id);

        if (!string.IsNullOrEmpty(photoPath))
        {
            return Results.Ok($"/Celebrities/download/{photoPath}");
        }

        return Results.NotFound("Фото не найдено.");
    });
}

app.Run();