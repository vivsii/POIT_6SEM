import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import MinMaxScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score, calinski_harabasz_score
from scipy.cluster.hierarchy import dendrogram, linkage
from sklearn.cluster import AgglomerativeClustering

# 1. Загрузка и подготовка данных
df = pd.read_csv('Country-data.csv')

# Выбираем числовые признаки для кластеризации
numeric_columns = df.select_dtypes(include=[np.number]).columns
X = df[numeric_columns]

# 2. Проверка на пропуски
print("Количество пропусков в данных:")
print(X.isnull().sum())

# 3. Нормализация данных
scaler = MinMaxScaler()
X_scaled = scaler.fit_transform(X)

# 4. Определение оптимального количества кластеров методом локтя
inertia = []
K_range = range(1, 11)
for k in K_range:
    kmeans = KMeans(n_clusters=k, random_state=42)
    kmeans.fit(X_scaled)
    inertia.append(kmeans.inertia_)

plt.figure(figsize=(10, 6))
plt.plot(K_range, inertia, 'bo-')
plt.xlabel('Количество кластеров')
plt.ylabel('Инерция')
plt.title('Метод локтя для определения оптимального количества кластеров')
plt.grid(True)
plt.show()

# Выбираем оптимальное количество кластеров (например, 3)
optimal_k = 3
kmeans = KMeans(n_clusters=optimal_k, random_state=42)
kmeans_labels = kmeans.fit_predict(X_scaled)

# 5. Визуализация результатов K-means
plt.figure(figsize=(10, 6))
plt.scatter(X_scaled[:, 0], X_scaled[:, 1], c=kmeans_labels, cmap='viridis')
plt.title('Кластеризация методом K-means')
plt.xlabel(numeric_columns[0])
plt.ylabel(numeric_columns[1])
plt.colorbar(label='Кластер')
plt.show()

# 6. Иерархическая кластеризация
Z = linkage(X_scaled, method='ward')
plt.figure(figsize=(10, 7))
dendrogram(Z)
plt.title('Дендрограмма')
plt.xlabel('Индекс образца')
plt.ylabel('Расстояние')
plt.show()

# 7. Визуализация результатов иерархической кластеризации
hierarchical = AgglomerativeClustering(n_clusters=optimal_k)
hierarchical_labels = hierarchical.fit_predict(X_scaled)

plt.figure(figsize=(10, 6))
plt.scatter(X_scaled[:, 0], X_scaled[:, 1], c=hierarchical_labels, cmap='viridis')
plt.title('Кластеризация методом иерархической кластеризации')
plt.xlabel(numeric_columns[0])
plt.ylabel(numeric_columns[1])
plt.colorbar(label='Кластер')
plt.show()

# 8. Оценка качества кластеризации
print("\nМетрики качества кластеризации:")
print("K-means:")
print(f"Silhouette score: {silhouette_score(X_scaled, kmeans_labels):.3f}")
print(f"Calinski-Harabasz score: {calinski_harabasz_score(X_scaled, kmeans_labels):.3f}")

print("\nИерархическая кластеризация:")
print(f"Silhouette score: {silhouette_score(X_scaled, hierarchical_labels):.3f}")
print(f"Calinski-Harabasz score: {calinski_harabasz_score(X_scaled, hierarchical_labels):.3f}")

# 9. Визуализация конкретного объекта (выбранной страны)
# Выбираем конкретную страну (например, "United States")
selected_country_name = "Belarus"  # Можно изменить на любую другую страну из датасета
selected_country_index = df[df['country'] == selected_country_name].index[0]

plt.figure(figsize=(12, 8))
# Визуализация всех точек кластеров
scatter = plt.scatter(X_scaled[:, 0], X_scaled[:, 1], c=kmeans_labels, cmap='viridis', alpha=0.6, label='Кластеры')
# Визуализация выбранной страны
plt.scatter(X_scaled[selected_country_index, 0], X_scaled[selected_country_index, 1], 
           c='red', s=300, marker='*', label=f'Выбранная страна: {selected_country_name}')

plt.title('Кластеризация с выделенной страной')
plt.xlabel(numeric_columns[0])
plt.ylabel(numeric_columns[1])
plt.legend()
plt.colorbar(scatter, label='Кластер')
plt.show()

# Вывод информации о выбранной стране
print(f"\nИнформация о выбранной стране ({selected_country_name}):")
print(df.iloc[selected_country_index]) 