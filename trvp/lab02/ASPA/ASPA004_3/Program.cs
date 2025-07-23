using DAL004;
using Microsoft.AspNetCore.Diagnostics;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

Repository.JSONFileName = "Celebrities.json";

using (IRepository repository = Repository.Create("Celebrities"))
{
    app.UseExceptionHandler("/Celebrities/Error");

    app.MapGet("/Celebrities", () => repository.getAllCelebrities());

    app.MapGet("/Celebrities/{id:int}", (int id) =>
    {
        Celebrity? celebrity = repository.getCelebrityById(id);
        if (celebrity == null)
            throw new FoundByIdException($"Celebrity Id = {id}");

        return celebrity;
    });

    app.MapPost("/Celebrities", (Celebrity celebrity) =>
    {
        int? id = repository.addCelebrity(celebrity);
        if (id == null)
            throw new AddCelebrityException("/Celebrities error, id == null");

        if (repository.SaveChanges() <= 0)
            throw new SaveException("/Celebrities error, SaveChanges() <= 0");

        return new Celebrity((int)id, celebrity.Firstname, celebrity.Surname, celebrity.PhotoPath);
    });

    app.MapPut("/Celebrities/{id:int}", (int id, Celebrity celebrity) =>
    {
        Celebrity? existingCelebrity = repository.getCelebrityById(id);
        if (existingCelebrity == null)
            throw new FoundByIdException($"Celebrity Id = {id}");

        existingCelebrity.Firstname = celebrity.Firstname;
        existingCelebrity.Surname = celebrity.Surname;
        existingCelebrity.PhotoPath = celebrity.PhotoPath;

        if (repository.SaveChanges() <= 0)
            throw new SaveException("/Celebrities error, SaveChanges() <= 0");

        return Results.Ok(existingCelebrity);
    });

    app.MapDelete("/Celebrities/{id:int}", (int id) =>
    {
        bool success = repository.delCelebrityById(id);
        if (!success)
            throw new DeleteCelebrityException($"Ошибка при удалении знаменитости с ID = {id}");

        if (repository.SaveChanges() <= 0)
            throw new SaveException("/Celebrities error, SaveChanges() <= 0");

        return Results.NoContent();
    });

    app.MapFallback((HttpContext ctx) =>
        Results.NotFound(new { error = $"path {ctx.Request.Path} not supported" }));

    app.Map("/Celebrities/Error", (HttpContext ctx) =>
    {
        Exception? ex = ctx.Features.Get<IExceptionHandlerFeature>()?.Error;

        IResult rc = Results.Problem(
            detail: "Произошла неизвестная ошибка",
            instance: app.Environment.EnvironmentName,
            title: "ASPA004",
            statusCode: 500
        );

        if (ex != null)
        {
            string errorDetail = $"{ex.Message}\nStackTrace: {ex.StackTrace}";

            if (ex is FoundByIdException)
                rc = Results.NotFound(new { title = "Ошибка поиска", detail = errorDetail });

            else if (ex is BadHttpRequestException)
                rc = Results.BadRequest(new { title = "Ошибка запроса", detail = errorDetail });

            else if (ex is SaveException)
                rc = Results.Problem(
                    title: "Ошибка сохранения",
                    detail: errorDetail,
                    instance: app.Environment.EnvironmentName,
                    statusCode: 500
                );

            else if (ex is AddCelebrityException)
                rc = Results.Problem(
                    title: "Ошибка добавления",
                    detail: errorDetail,
                    instance: app.Environment.EnvironmentName,
                    statusCode: 500
                );

            else if (ex is DeleteCelebrityException)
                rc = Results.Problem(
                    title: "Ошибка удаления",
                    detail: errorDetail,
                    instance: app.Environment.EnvironmentName,
                    statusCode: 500
                );

            else if (ex is UpdateCelebrityException)
                rc = Results.Problem(
                    title: "Ошибка обновления",
                    detail: errorDetail,
                    instance: app.Environment.EnvironmentName,
                    statusCode: 500
                );

            else
                rc = Results.Problem(
                    title: "Неизвестная ошибка",
                    detail: errorDetail,
                    instance: app.Environment.EnvironmentName,
                    statusCode: 500
                );
        }

        return rc;
    });

    app.Run();
}

public class FoundByIdException : Exception
{
    public FoundByIdException(string message) : base($"Ошибка поиска по ID: {message}") { }
}

public class SaveException : Exception
{
    public SaveException(string message) : base($"Ошибка при сохранении: {message}") { }
}

public class AddCelebrityException : Exception
{
    public AddCelebrityException(string message) : base($"Ошибка при добавлении: {message}") { }
}

public class DeleteCelebrityException : Exception
{
    public DeleteCelebrityException(string message) : base($"Ошибка при удалении: {message}") { }
}
public class UpdateCelebrityException : Exception
{
    public UpdateCelebrityException(string message) : base($"Ошибка при обновлении: {message}") { }
}
