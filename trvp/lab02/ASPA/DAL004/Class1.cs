using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace DAL004
{
    public interface IRepository : IDisposable
    {
        string BasePath { get; }
        Celebrity[] getAllCelebrities();
        Celebrity? getCelebrityById(int id);
        Celebrity[] getCelebritiesBySurname(string Surname);
        string? getPhotoPathById(int id);
        int? addCelebrity(Celebrity celebrity);
        bool delCelebrityById(int id);
        int? updCelebrityById(int id, Celebrity celebrity);
        int SaveChanges();
    }

    public class Celebrity
    {
        public int Id { get; set; }
        public string Firstname { get; set; }
        public string Surname { get; set; }
        public string PhotoPath { get; set; }

        public Celebrity(int id, string firstname, string surname, string photoPath)
        {
            Id = id;
            Firstname = firstname;
            Surname = surname;
            PhotoPath = photoPath;
        }
    }

    public class Repository : IRepository
    {
        private readonly string _basePath;
        private List<Celebrity> _celebrities;

        public static string JSONFileName { get; set; }

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

        public int? addCelebrity(Celebrity celebrity)
        {
            if (_celebrities.Any(c => c.Id == celebrity.Id && celebrity.Id != 0))
                return null;

            int newId = _celebrities.Count > 0 ? _celebrities.Max(c => c.Id) + 1 : 1;
            var newCelebrity = new Celebrity(newId, celebrity.Firstname, celebrity.Surname, celebrity.PhotoPath);

            _celebrities.Add(newCelebrity);
            SaveChanges();
            return newId;
        }


        public bool delCelebrityById(int id)
        {
            var celebrity = getCelebrityById(id);
            if (celebrity == null) return false;

            _celebrities.Remove(celebrity);
            SaveChanges();
            return true;
        }

        public int? updCelebrityById(int id, Celebrity updatedCelebrity)
        {
            var index = _celebrities.FindIndex(c => c.Id == id);
            if (index == -1) return null;

            _celebrities[index] = new Celebrity(id, updatedCelebrity.Firstname, updatedCelebrity.Surname, updatedCelebrity.PhotoPath);
            SaveChanges();
            return id;
        }
        public int SaveChanges()
        {
            var jsonFilePath = Path.Combine(_basePath, JSONFileName);
            File.WriteAllText(jsonFilePath, JsonSerializer.Serialize(_celebrities));
            return _celebrities.Count;
        }

        public void Dispose()
        {
            _celebrities.Clear();
        }
    }
}