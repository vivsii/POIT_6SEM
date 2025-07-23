import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pandas.plotting import scatter_matrix
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score, mean_squared_error

# 1. Загрузка данных
df = pd.read_csv('salary_data_cleaned.csv')

# 2. Выбираем только числовые признаки
numeric_df = df.select_dtypes(include=[np.number])

# 3. Анализ корреляции с целевой переменной
target = 'avg_salary'
if target not in numeric_df.columns:
    raise ValueError(f"Целевая переменная '{target}' отсутствует в наборе числовых столбцов")

# Считаем корреляцию и отбираем только значимые признаки (|corr| > 0.3)
corr_matrix_full = numeric_df.corr()
correlations = corr_matrix_full[target].drop(target)
selected_features = correlations[correlations.abs() > 0.3].index.tolist()

# Формируем новый датафрейм только с целевой переменной и отобранными признаками
reduced_df = numeric_df[[target] + selected_features]

# 4. Тепловая карта
plt.figure(figsize=(8, 6))
sns.heatmap(reduced_df.corr(), annot=True, fmt='.2f', cmap='coolwarm')
plt.title('Корреляционная матрица (выборка признаков)')
plt.tight_layout()
plt.show()

# 5. Матрица диаграмм рассеяния
scatter_matrix(reduced_df, figsize=(10, 10), diagonal='hist', alpha=0.7)
plt.suptitle('Матрица диаграмм рассеяния (выборка признаков)')
plt.tight_layout()
plt.show()

# 6. Простая линейная регрессия по признаку с наибольшей корреляцией
best_feature = correlations[selected_features].abs().idxmax()
print(f"Выбранный признак для простой линейной регрессии: {best_feature}")

X_simple = reduced_df[[best_feature]].values
y = reduced_df[target].values
model_simple = LinearRegression().fit(X_simple, y)
y_pred_simple = model_simple.predict(X_simple)

# Визуализация простой модели
plt.figure(figsize=(6, 4))
plt.scatter(X_simple, y, label='Данные')
x_range = np.linspace(X_simple.min(), X_simple.max(), 100).reshape(-1, 1)
y_line = model_simple.predict(x_range)
plt.plot(x_range, y_line, color='red', label='Модель')
plt.xlabel(best_feature)
plt.ylabel(target)
plt.title(f'Простая линейная регрессия: {target} ~ {best_feature}')
plt.legend()
plt.tight_layout()
plt.show()

# Метрики
r2_simple = r2_score(y, y_pred_simple)
rmse_simple = np.sqrt(mean_squared_error(y, y_pred_simple))
print(f"Simple Linear Regression\nR2 = {r2_simple:.3f}\nRMSE = {rmse_simple:.3f}")

# 7. Многомерная регрессия
X_multi = reduced_df[selected_features].values
model_multi = LinearRegression().fit(X_multi, y)
y_pred_multi = model_multi.predict(X_multi)

r2_multi = r2_score(y, y_pred_multi)
rmse_multi = np.sqrt(mean_squared_error(y, y_pred_multi))
print(f"Multiple Linear Regression\nR2 = {r2_multi:.3f}\nRMSE = {rmse_multi:.3f}")

# 8. Вывод
if r2_multi > r2_simple:
    print("Многомерная модель описывает данные лучше простой.")
else:
    print("Простая модель описывает данные лучше или сравнимо.")
