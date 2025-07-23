import numpy
import pandas

rows = 1
cols = 20
lower_bound = 1
upper_bound = 100

random_array = numpy.random.randint(lower_bound, upper_bound, size=(rows, cols))
print(f'Исходный массив: {random_array}')

first_half, second_half = numpy.split(random_array, 2, axis=1)
print('Первая часть массива:')
print(first_half)
print('Вторая часть массива:')
print(second_half)

value_to_find = 10
indexes = numpy.where(random_array == value_to_find)[0]

print(f'Кол-во вхождений 10-ти - {len(indexes)}')

#Второе задание
array = numpy.array([1,2,3,4,5,6])
series = pandas.Series(array)
print('Series:')
print(series)

print(f'{series + 2}')
print(f'{series * 2}')
print(f'{series ** 2}')

array_2d = numpy.array([[1,2,3], [4,5,6], [7,8,9]])
dataframe = pandas.DataFrame(array_2d, columns=['Column1','Column2','Column3'])
print('\nDataFrame:')
print(dataframe)

dataframe = dataframe.drop(columns=['Column2'])
print(f'{dataframe}')
print(f'Размер dataframe - {len(dataframe)}')

value_to_find = 4
indexes = numpy.where(random_array == value_to_find)[0]

print(f'Кол-во вхождений 4 - {len(indexes)}')
