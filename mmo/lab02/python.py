import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.preprocessing import LabelEncoder, OneHotEncoder, MinMaxScaler

data = pd.read_csv('./Automobile.csv')

# 1. Поиск пропусков
data.info()
missing_values = data.isnull().sum()
print("Количество пропущенных значений по столбцам:\n", missing_values)

sns.heatmap(data.isnull(), cbar=False, cmap='viridis')
plt.title('Пропуски в данных')
plt.show()

# 2. Удаление строк и столбцов с пропусками
data = data.dropna()

sns.heatmap(data.isnull(), cbar=False, cmap='viridis')
plt.title('Пропуски в данных')
plt.show()
# 3. Заполнение пропусков
# for column in data.select_dtypes(include=[np.number]):
#     data.loc[:, column] = data[column].fillna(data[column].median())
# for column in data.select_dtypes(include=[object]):
#     data.loc[:, column] = data[column].fillna(data[column].mode()[0])

# 4. Поиск и удаление выбросов boxplot
numeric_columns = data.select_dtypes(include=[np.number]).columns
for column in numeric_columns:
    plt.figure()
    sns.boxplot(x=data[column])
    plt.title(f'Boxplot для {column}')
    plt.show()
    Q1 = data[column].quantile(0.25)
    Q3 = data[column].quantile(0.75)
    IQR = Q3 - Q1
    data = data[~((data[column] < (Q1 - 1.5 * IQR)) | (data[column] > (Q3 + 1.5 * IQR)))]

# 5. Преобразование категориальных данных в числовые
data['origin'] = data['origin'].map({'usa': 1,'europe': 2,'japan': 3})

label_encoder = LabelEncoder()
data['name'] = label_encoder.fit_transform(data['name'])

# 6. Нормализация данных
scaler = MinMaxScaler()
data[numeric_columns] = scaler.fit_transform(data[numeric_columns])

data.to_csv('processed_dataset.csv', index=False)
print("Датасет успешно сохранен в файл 'processed_dataset.csv'")