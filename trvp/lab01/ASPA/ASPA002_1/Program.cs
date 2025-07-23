using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorPages();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseStaticFiles();

app.UseWelcomePage("/aspnetcore");

app.UseRouting();

app.UseAuthorization();

app.MapGet("/aspnetcore", async context =>
{
    context.Response.Redirect("/Index.html");
});

app.MapRazorPages();

app.Run();
