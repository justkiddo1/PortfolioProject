from bs4 import BeautifulSoup
import requests
import pandas as pd

url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_by_revenue'

page = requests.get(url)

soup = BeautifulSoup(page.text, 'html.parser')

table = soup.find_all('table', class_='wikitable sortable sticky-header-multi sort-under')[0]

tbody = table.find('tbody')

if tbody:
    first_row = tbody.find('tr')
    if first_row:
        world_titles = first_row.find_all('th')
        World_table_titles = [title.text.strip() for title in world_titles]
    else:
        print("Không tìm thấy hàng đầu tiên trong tbody.")
else:
    print("Không tìm thấy thẻ tbody trong bảng.")

df = pd.DataFrame(columns=World_table_titles)

column_data=tbody.find_all('tr')[1:]

for row in column_data:
    if row.find('th',{"colspan":"2"}):
        continue
    row_data= row.find_all(['th','td'])
    individual_row_data=[data.text.strip() for data in row_data]


    if len(individual_row_data) == len(World_table_titles) :
        length= len(df)
        df.loc[length] = individual_row_data

df.to_csv(r'C:\Users\Quang Huy\Desktop\DataSet\LargestCompanyinUSA.csv',index=False)













