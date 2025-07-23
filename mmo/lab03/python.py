import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.tree import DecisionTreeClassifier, plot_tree
from sklearn.neighbors import KNeighborsClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix, accuracy_score, precision_score, recall_score
from sklearn.preprocessing import StandardScaler

# Загрузка данных
data = pd.read_csv('diabetes.csv')

# Разделение на признаки и метки
X = data.drop('Outcome', axis=1)  # Матрица признаков
y = data['Outcome']  # Вектор меток

# Масштабирование признаков
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Разделение на обучающую и тестовую выборки
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)

def evaluate_model(y_true, y_pred, model_name):
    """Функция для оценки модели"""
    accuracy = accuracy_score(y_true, y_pred)
    precision = precision_score(y_true, y_pred)
    recall = recall_score(y_true, y_pred)
    conf_matrix = confusion_matrix(y_true, y_pred)
    
    print(f"\nРезультаты для модели {model_name}:")
    print(f"Accuracy: {accuracy:.3f}")
    print(f"Precision: {precision:.3f}")
    print(f"Recall: {recall:.3f}")
    print("Матрица ошибок:")
    print(conf_matrix)
    return accuracy

# 1. Дерево решений
print("\n=== Дерево решений ===")
dt = DecisionTreeClassifier(random_state=42)
dt.fit(X_train, y_train)
dt_pred = dt.predict(X_test)
dt_accuracy_before = evaluate_model(y_test, dt_pred, "Дерево решений (до оптимизации)")

# Оптимизация дерева решений
dt_params = {
    'max_depth': [3, 5, 7, 10],
    'max_features': ['sqrt', 'log2', None]
}
dt_grid = GridSearchCV(DecisionTreeClassifier(random_state=42), dt_params, cv=5)
dt_grid.fit(X_train, y_train)
dt_best_pred = dt_grid.predict(X_test)
dt_accuracy_after = evaluate_model(y_test, dt_best_pred, "Дерево решений (после оптимизации)")
print(f"Лучшие параметры: {dt_grid.best_params_}")

# Визуализация дерева (с ограниченной глубиной для читаемости)
plt.figure(figsize=(20,10))
plot_tree(DecisionTreeClassifier(max_depth=3, random_state=42).fit(X_train, y_train), 
         feature_names=X.columns, class_names=['0', '1'], filled=True)
plt.savefig('decision_tree.png')
plt.close()

# 2. k-ближайших соседей
print("\n=== k-ближайших соседей ===")
knn = KNeighborsClassifier()
knn.fit(X_train, y_train)
knn_pred = knn.predict(X_test)
knn_accuracy_before = evaluate_model(y_test, knn_pred, "k-NN (до оптимизации)")

# Оптимизация k-NN
knn_params = {
    'n_neighbors': [3, 5, 7, 9, 11],
    'weights': ['uniform', 'distance']
}
knn_grid = GridSearchCV(KNeighborsClassifier(), knn_params, cv=5)
knn_grid.fit(X_train, y_train)
knn_best_pred = knn_grid.predict(X_test)
knn_accuracy_after = evaluate_model(y_test, knn_best_pred, "k-NN (после оптимизации)")
print(f"Лучшие параметры: {knn_grid.best_params_}")

# 3. Случайный лес
print("\n=== Случайный лес ===")
rf = RandomForestClassifier(random_state=42)
rf.fit(X_train, y_train)
rf_pred = rf.predict(X_test)
rf_accuracy_before = evaluate_model(y_test, rf_pred, "Случайный лес (до оптимизации)")

# Оптимизация случайного леса
rf_params = {
    'max_depth': [3, 5, 7],
    'max_features': ['sqrt', 'log2'],
    'n_estimators': [100, 200]
}
rf_grid = GridSearchCV(RandomForestClassifier(random_state=42), rf_params, cv=5)
rf_grid.fit(X_train, y_train)
rf_best_pred = rf_grid.predict(X_test)
rf_accuracy_after = evaluate_model(y_test, rf_best_pred, "Случайный лес (после оптимизации)")
print(f"Лучшие параметры: {rf_grid.best_params_}")

# Сравнение моделей
print("\n=== Итоговое сравнение моделей ===")
models_comparison = {
    'Дерево решений': dt_accuracy_after,
    'k-NN': knn_accuracy_after,
    'Случайный лес': rf_accuracy_after
}
best_model = max(models_comparison.items(), key=lambda x: x[1])
print("\nТочность моделей после оптимизации:")
for model, accuracy in models_comparison.items():
    print(f"{model}: {accuracy:.3f}")
print(f"\nЛучшая модель для данного датасета: {best_model[0]} с точностью {best_model[1]:.3f}")