import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, confusion_matrix, RocCurveDisplay
from sklearn.preprocessing import StandardScaler

# Загрузка данных
data = pd.read_csv('diabetes.csv')

# Разделение на признаки и метки
X = data.drop('Outcome', axis=1)
y = data['Outcome']

# Масштабирование признаков
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Разделение на обучающую и тестовую выборки
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.2, random_state=42)

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

# 1. Логистическая регрессия
print("\n=== Логистическая регрессия ===")

# С разными значениями C
for C in [1, 100, 0.01]:
    print(f"\nC = {C}")
    lr = LogisticRegression(C=C, random_state=42)
    lr.fit(X_train, y_train)
    print(f"Правильность на обучающем наборе: {lr.score(X_train, y_train):.2f}")
    print(f"Правильность на тестовом наборе: {lr.score(X_test, y_test):.2f}")

# С L2-регуляризацией
print("\nL2-регуляризация:")
lr_l2 = LogisticRegression(penalty='l2', C=0.1, random_state=42)
lr_l2.fit(X_train, y_train)
lr_l2_pred = lr_l2.predict(X_test)
evaluate_model(y_test, lr_l2_pred, "Логистическая регрессия (L2)")

# 2. Метод опорных векторов
print("\n=== Метод опорных векторов ===")
svc = SVC(random_state=42)
svc.fit(X_train, y_train)
print(f"Правильность на обучающем наборе: {svc.score(X_train, y_train):.2f}")
print(f"Правильность на тестовом наборе: {svc.score(X_test, y_test):.2f}")

# Поиск лучших параметров
svc_params = {"C": [0.1, 1, 10], "gamma": [0.2, 0.6, 1]}
svc_grid = GridSearchCV(SVC(random_state=42), svc_params, cv=5, n_jobs=-1)
svc_grid.fit(X_train, y_train)
print(f"\nЛучшие параметры: {svc_grid.best_params_}")
print(f"Лучшая точность: {svc_grid.best_score_:.3f}")

svc_best = svc_grid.best_estimator_
svc_best_pred = svc_best.predict(X_test)
evaluate_model(y_test, svc_best_pred, "SVC (оптимизированный)")

# 3. Дерево решений
print("\n=== Дерево решений ===")
dt = DecisionTreeClassifier(random_state=42)
dt.fit(X_train, y_train)
print(f"Правильность на обучающем наборе: {dt.score(X_train, y_train):.2f}")
print(f"Правильность на тестовом наборе: {dt.score(X_test, y_test):.2f}")
dt_pred = dt.predict(X_test)
evaluate_model(y_test, dt_pred, "Дерево решений")

# 4. K-ближайших соседей
print("\n=== K-ближайших соседей ===")
knn = KNeighborsClassifier()
knn.fit(X_train, y_train)
print(f"Правильность на обучающем наборе: {knn.score(X_train, y_train):.2f}")
print(f"Правильность на тестовом наборе: {knn.score(X_test, y_test):.2f}")
knn_pred = knn.predict(X_test)
evaluate_model(y_test, knn_pred, "K-ближайших соседей")

# ROC-кривые
plt.figure(figsize=(10, 8))
ax = plt.gca()

# Логистическая регрессия
RocCurveDisplay.from_estimator(lr_l2, X_test, y_test, ax=ax, name='Logistic Regression')

# Метод опорных векторов
RocCurveDisplay.from_estimator(svc_best, X_test, y_test, ax=ax, name='SVC')

# Дерево решений
RocCurveDisplay.from_estimator(dt, X_test, y_test, ax=ax, name='Decision Tree')

# K-ближайших соседей
RocCurveDisplay.from_estimator(knn, X_test, y_test, ax=ax, name='KNN')

plt.title('ROC-кривые для всех моделей')
plt.savefig('roc_curves.png')
plt.close()