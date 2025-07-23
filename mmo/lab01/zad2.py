import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

films = pd.read_csv('movie_rank.csv')
print(films)

plt.hist(films['numVotes'], bins=12, edgecolor='black')

plt.title('Гистограмма частот')
plt.xlabel('Значения')
plt.ylabel('Частота')

plt.show()

average = films['numVotes'].mean()
print(f'Среднее значение: {average}')

median = films['numVotes'].mean()
print(f'Медиана: {median}')

cleaned_df = films.dropna()

plt.figure(figsize=(8, 6))
plt.boxplot(cleaned_df['averageRating'], vert=True, patch_artist=True)

plt.title('Box Plot - Average Rating')
plt.ylabel('Рейтинг')
plt.grid(True)

plt.show()

print(cleaned_df.describe())

grouped_df = films.groupby('genres')['averageRating'].mean()
print(grouped_df)

print(films['startYear'].value_counts())
print(films['titleType'].count())
print(films['numVotes'].sum())
