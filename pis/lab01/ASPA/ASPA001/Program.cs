using Microsoft.AspNetCore.HttpLogging;

internal class Program               // Определение внутреннего класса 'internal' означает, что класс доступен только внутри текущей сборки.
{
    private static void Main(string[] args)   // Точка входа в приложение. Метод Main вызывается при запуске приложения.
    {
        //// Создаем экземпляр WebApplicationBuilder с настройками по умолчанию.
        //var builder = WebApplication.CreateBuilder(args);

        //// Строим приложение на основе созданного builder.
        //var app = builder.Build();

        //// Определяем маршрут для HTTP GET-запроса к корню сайта "/".
        //// При обращении к адресу "/" сервер вернет строку "Мое первое ASPA!".
        //app.MapGet("/", () => "Мое первое ASPA!");

        //// Запускаем приложение и начинаем прослушивание входящих запросов.
        //app.Run();

        //// Создаем экземпляр WebApplicationBuilder с настройками по умолчанию.
        var builder = WebApplication.CreateBuilder(args);

        // Включаем встроенный HTTP Logging
        builder.Services.AddHttpLogging(logging =>
        {
            logging.LoggingFields = HttpLoggingFields.All;
            logging.RequestHeaders.Add("User-Agent");
            logging.ResponseHeaders.Add("Content-Type");
            logging.MediaTypeOptions.AddText("application/json");
            logging.RequestBodyLogLimit = 4096;
            logging.ResponseBodyLogLimit = 4096;
        });

        //// Строим приложение на основе созданного builder.
        var app = builder.Build();

        // Добавляем HTTP логирование в конвейер
        app.UseHttpLogging();

        //// Определяем маршрут для HTTP GET-запроса к корню сайта "/".
        //// При обращении к адресу "/" сервер вернет строку "Мое первое ASPA!".
        app.MapGet("/", () => "Мое первое ASPA!");

        //// Запускаем приложение и начинаем прослушивание входящих запросов.
        app.Run();
    }
}
