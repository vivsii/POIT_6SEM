using Microsoft.AspNetCore.HttpLogging;

internal class Program               // ����������� ����������� ������ 'internal' ��������, ��� ����� �������� ������ ������ ������� ������.
{
    private static void Main(string[] args)   // ����� ����� � ����������. ����� Main ���������� ��� ������� ����������.
    {
        //// ������� ��������� WebApplicationBuilder � ����������� �� ���������.
        //var builder = WebApplication.CreateBuilder(args);

        //// ������ ���������� �� ������ ���������� builder.
        //var app = builder.Build();

        //// ���������� ������� ��� HTTP GET-������� � ����� ����� "/".
        //// ��� ��������� � ������ "/" ������ ������ ������ "��� ������ ASPA!".
        //app.MapGet("/", () => "��� ������ ASPA!");

        //// ��������� ���������� � �������� ������������� �������� ��������.
        //app.Run();

        //// ������� ��������� WebApplicationBuilder � ����������� �� ���������.
        var builder = WebApplication.CreateBuilder(args);

        // �������� ���������� HTTP Logging
        builder.Services.AddHttpLogging(logging =>
        {
            logging.LoggingFields = HttpLoggingFields.All;
            logging.RequestHeaders.Add("User-Agent");
            logging.ResponseHeaders.Add("Content-Type");
            logging.MediaTypeOptions.AddText("application/json");
            logging.RequestBodyLogLimit = 4096;
            logging.ResponseBodyLogLimit = 4096;
        });

        //// ������ ���������� �� ������ ���������� builder.
        var app = builder.Build();

        // ��������� HTTP ����������� � ��������
        app.UseHttpLogging();

        //// ���������� ������� ��� HTTP GET-������� � ����� ����� "/".
        //// ��� ��������� � ������ "/" ������ ������ ������ "��� ������ ASPA!".
        app.MapGet("/", () => "��� ������ ASPA!");

        //// ��������� ���������� � �������� ������������� �������� ��������.
        app.Run();
    }
}
