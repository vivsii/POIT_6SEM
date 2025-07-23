using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace DAL003
{
    public interface IRepository : IDisposable
    {
        string BasePath { get; }
        Celebrity[] getAllCelebrities();
        Celebrity? getCelebrityById(int id);
        Celebrity[] getCelebritiesBySurname(string Surname);
        string? getPhotoPathById(int id);
    }

    public record Celebrity(int Id, string Firstname, string Surname, string PhotoPath);

    public class Repository : IRepository
    {
        private readonly string _basePath;
        private List<Celebrity> _celebrities;

        public static string JSONFileName { get; set; } = "Celebrities.json";

        public Repository(string directoryName)
        {
            _basePath = Path.Combine(Directory.GetCurrentDirectory(), directoryName);
            loadCelebrities();
        }

        public static Repository Create(string directoryName)
        {
            return new Repository(directoryName);
        }

        private void loadCelebrities()
        {
            var jsonFilePath = Path.Combine(_basePath, JSONFileName);

            if (!Directory.Exists(_basePath))
            {
                Directory.CreateDirectory(_basePath);
            }

            if (!File.Exists(jsonFilePath))
            {
                File.WriteAllText(jsonFilePath, "[]"); 
            }

            var jsonString = File.ReadAllText(jsonFilePath);
            _celebrities = JsonSerializer.Deserialize<List<Celebrity>>(jsonString) ?? new List<Celebrity>();
        }

        public string BasePath => _basePath;

        public Celebrity[] getAllCelebrities()
        {
            return _celebrities.ToArray();
        }

        public Celebrity? getCelebrityById(int id)
        {
            return _celebrities.FirstOrDefault(c => c.Id == id);
        }

        public Celebrity[] getCelebritiesBySurname(string surname)
        {
            return _celebrities.Where(c => c.Surname.Equals(surname, StringComparison.OrdinalIgnoreCase)).ToArray();
        }

        public string? getPhotoPathById(int id)
        {
            var celebrity = getCelebrityById(id);
            return celebrity != null ? Path.Combine(_basePath, celebrity.PhotoPath) : null;
        }

        public void Dispose()
        {
            _celebrities.Clear();
        }
    }
}