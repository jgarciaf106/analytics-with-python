# Python Module example

# library imports
import os
import json
import pandas as pd
import numpy as np
import pyodbc
from sqlalchemy import create_engine

# set engine db
def setEngine(credFile,dsn,path='C:/Users/garciand/OneDrive - HP Inc/Desktop/Python/Credentials/'):
    credentials = path + '{0}.json'.format(credFile)
    with open(credentials) as get:
        data = json.load(get)
        userName = data['userName']
        passWord = data['password']
    # db create connection engine
    return create_engine('mssql+pyodbc://{0}:{1}@{2}'.format(userName, passWord, dsn))

# query external file queries
def externalQuery(queryName, engine, path='C:/Users/garciand/OneDrive - HP Inc/Desktop/Python/Queries/'):
    queryPath = path + '{0}.sql'.format(queryName)
    with open(queryPath) as get:
        query = get.read()
    return pd.read_sql_query(query,engine)

# query inline queries
def internalQuery(query,engine):
    return pd.read_sql_query(query,engine)

# query inline queries
def exportData(odf,filename,sheetName,path='C:/Users/garciand/OneDrive - HP Inc/Desktop/Ad-hoc Requests/'):
    # save file to outpu folder
    odf.to_excel('{0}{1}.xlsx'.format(path,filename), sheet_name=sheetName, engine='xlsxwriter')