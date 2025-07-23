import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.datasets import load_breast_cancer
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.svm import SVC
from sklearn.model_selection import train_test_split
import time

# 1. Загрузка данных
X, y = load_breast_cancer(return_X_y=True, as_frame=True)

# 2. Построение гистограммы весов первых компонент
# Без нормализации
pca_no_scaling = PCA(n_components=2)
X_pca_no_scaling = pca_no_scaling.fit_transform(X)

# С нормализацией
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)
pca_with_scaling = PCA(n_components=2)
X_pca_with_scaling = pca_with_scaling.fit_transform(X_scaled)

# Визуализация весов компонент
plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
plt.bar(range(len(pca_no_scaling.components_[0])), pca_no_scaling.components_[0])
plt.title('Веса первой компоненты без нормализации')
plt.xlabel('Признаки')
plt.ylabel('Вес')

plt.subplot(1, 2, 2)
plt.bar(range(len(pca_with_scaling.components_[0])), pca_with_scaling.components_[0])
plt.title('Веса первой компоненты с нормализацией')
plt.xlabel('Признаки')
plt.ylabel('Вес')

plt.tight_layout()
plt.show()

# 3. Визуализация распределения классов
plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
plt.scatter(X_pca_no_scaling[:, 0], X_pca_no_scaling[:, 1], c=y, cmap='viridis')
plt.title('Распределение классов без нормализации')
plt.xlabel('Первая главная компонента')
plt.ylabel('Вторая главная компонента')

plt.subplot(1, 2, 2)
plt.scatter(X_pca_with_scaling[:, 0], X_pca_with_scaling[:, 1], c=y, cmap='viridis')
plt.title('Распределение классов с нормализацией')
plt.xlabel('Первая главная компонента')
plt.ylabel('Вторая главная компонента')

plt.tight_layout()
plt.show()

# 4. Обучение SVM без PCA
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

start_time = time.time()
svm = SVC(kernel='rbf')
svm.fit(X_train, y_train)
svm_time = time.time() - start_time
svm_score = svm.score(X_test, y_test)

print(f"\nSVM без PCA:")
print(f"Точность: {svm_score:.3f}")
print(f"Время обучения: {svm_time:.3f} секунд")

# 5. Обучение SVM с PCA
# Определение количества компонент для сохранения 90% дисперсии
pca = PCA()
pca.fit(X_scaled)
cumulative_variance = np.cumsum(pca.explained_variance_ratio_)
n_components = np.argmax(cumulative_variance >= 0.9) + 1

plt.figure(figsize=(10, 6))
plt.plot(range(1, len(cumulative_variance) + 1), cumulative_variance, 'bo-')
plt.axhline(y=0.9, color='r', linestyle='--')
plt.axvline(x=n_components, color='g', linestyle='--')
plt.xlabel('Количество компонент')
plt.ylabel('Накопленная дисперсия')
plt.title('График накопленной дисперсии')
plt.grid(True)
plt.show()

print(f"\nКоличество компонент для сохранения 90% дисперсии: {n_components}")

# Применение PCA с выбранным количеством компонент
pca = PCA(n_components=n_components)
X_pca = pca.fit_transform(X_scaled)
X_train_pca, X_test_pca, y_train, y_test = train_test_split(X_pca, y, test_size=0.2, random_state=42)

start_time = time.time()
svm_pca = SVC(kernel='rbf')
svm_pca.fit(X_train_pca, y_train)
svm_pca_time = time.time() - start_time
svm_pca_score = svm_pca.score(X_test_pca, y_test)

print(f"\nSVM с PCA:")
print(f"Точность: {svm_pca_score:.3f}")
print(f"Время обучения: {svm_pca_time:.3f} секунд") 