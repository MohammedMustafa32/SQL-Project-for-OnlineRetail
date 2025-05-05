import pandas as pd
from sqlalchemy import create_engine, text

server = 'localhost'
database_Name = 'OnlineRetail'
driver = 'ODBC Driver 17 for SQL Server'

# Create the connection string for SQLAlchemy
conn_str = f"mssql+pyodbc://@{server}/{database_Name}?driver={driver}&trusted_connection=yes"

# Create SQLAlchemy engine to establish connection to the database
engine = create_engine(conn_str)

df = pd.read_sql("select * from Online_Retail", engine)

# Fill missing (NaN) values in the 'InvoiceDate' column using forward fill method
df['InvoiceDate'] = df['InvoiceDate'].fillna(method='ffill')

path="D:\\Courses & Books\\My Courses ( Data Analyst )\\DEPI - Data Analyst\\1 Tech Material\\3 Analytical SQL\\Project"
df.to_csv(f"{path}\\OnlineRetail_dataCleaning.csv", index=False)


# Upload the cleaned data back to the 'Online_Retail' table in the database, replacing the existing table
df.to_sql('Online_Retail', con=engine, index=False, if_exists='replace')    


print(df.head())
print(df.isnull().sum())
