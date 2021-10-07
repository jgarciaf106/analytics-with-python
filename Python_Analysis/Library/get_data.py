# library imports
import os
import codecs
import pyodbc
import json
import argparse
import re
import win32com.client
import datetime as dt
import pandas as pd
import numpy as np
import xlwings as xw
import tkinter as tk
import matplotlib.pyplot as plt
import seaborn as sns
import datetime as dt
import fiscalyear as fy
from tkinter import messagebox
from sqlalchemy import create_engine
from openpyxl import Workbook
from openpyxl.utils.dataframe import dataframe_to_rows
from openpyxl.styles import PatternFill, Border, Side, Alignment, Protection, Font
from win32com.client import Dispatch, constants

# from __future__ import print_function
from pptx import Presentation
from pptx.util import Inches


class Get_Data:

    # init method or constructor
    def __init__(
        self,
        db_type,
        db_name,
        request_from,
    ):
        self.__db_type = db_type
        self.__db_name = db_name
        self.__request_from = request_from
        self.__credentials = db_type
        self.__output_path = None
        self.__query_path = None
        self.__input_path = None
        self.__today = dt.datetime.today() - pd.DateOffset(months=1)
        self.__monthname_long = self.__today.strftime("%B")
        self.__monthname_short = self.__today.strftime("%b")
        self.__monthyear = self.__today.strftime("%m%y")
        self.__fiscal_year = None
        self.__current_quarter = None
        self.__fiscal_quarter = None

    # setter functions
    """
        Function to set input, output, queries paths if needed.
    """

    def set_output_path(self, path):
        self.__output_path = path

    def set_queries_path(self, path):
        self.__query_path = path

    def set_input_path(self, path):
        self.__input_path = path

    def set_fiscal_year(self, s_month, s_day, f_year, s_year="previous"):
        self.__fiscal_year = fy.FiscalYear(f_year)
        fy.setup_fiscal_calendar(
            start_year=s_year, start_month=s_month, start_day=s_day
        )
        self.__fiscal_quarter = str(
            fy.FiscalQuarter.current().prev_fiscal_quarter
        ).split(" ")[0]
        self.__current_quarter = str(
            fy.FiscalQuarter.current().prev_fiscal_quarter
        ).split(" ")[1]

    # set engine db
    """
        Function to initialize the engine to query the specific data base provider
        Enable to work with Postgres, MSSQL, MySQL and Oracle
    """

    def set_engine(self):
        credentials = "C:/Users/garciand/OneDrive - HP Inc/Desktop/Python_Analytics/Python_Analysis/Credentials/{0}.json".format(
            self.__credentials
        )
        with open(credentials) as get:
            data = json.load(get)
            user_name = data["userName"]
            password = data["password"]

        # db create connection engine
        if self.__db_type == "postgres":
            return create_engine(
                "postgresql://{0}:{1}@localhost/{2}".format(
                    user_name, password, self.__db_name
                )
            )
        elif self.__db_type == "mssql":
            return create_engine(
                "mssql+pyodbc://{0}:{1}@{2}".format(user_name, password, self.__db_name)
            )
        elif self.__db_type == "oracle":
            return create_engine(
                "'oracle://{0}:{1}@localhost/{2}".format(
                    user_name, password, self.__db_name
                )
            )
        elif self.__db_type == "mysql":
            return create_engine(
                "mysql://{0}:{1}@localhost/{2}".format(
                    user_name, password, self.__db_name
                )
            )

    # query external file queries
    """
        Function to read external query files stored at an specific location
        Query Name and Engine initialized parameters needed
        returns a dataframe with the query result
    """

    def external_query(self, query_name, engine):
        query_path = self.__query_path + "{0}.sql".format(query_name)
        with open(query_path) as get:
            query = get.read()
        return pd.read_sql_query(query, engine)

    # query inline queries
    """
        Function to read inline query strings stored in a variable or write as parameter
        Query  and Engine initialized parameters needed
        returns a dataframe with the query result
    """

    def internal_query(self, query, engine):
        return pd.read_sql_query(query, engine)

    # read  files
    """
        Function to read external query files stored at an specific location
        File Name and Folder needed to read file 
        returns a dataframe with the data read from the external file
    """

    def file_query(self, file_name, folder):
        file = self.__input_path + folder + "/" + file_name
        return pd.read_excel(file, index_col=0)

    # stores request passwords
    """
        Function to store the password if needed for each request processed.
        Date, File Name and password parameters needed
        saves a password for the file request processed.
    """

    def password_tracker(self, request_date, file_name, password):
        app = xw.App(visible=False)
        wb = xw.Book(
            r"C:/Users/garciand/OneDrive - HP Inc/Desktop/Deliverables/Password Tracker/Password_Tracker.xlsx"
        )
        ws = wb.sheets[0]

        next_row = "A" + str(ws.range("A1").current_region.last_cell.row + 1)

        ws.range(next_row).options(index=False).value = [
            request_date,
            file_name,
            self.__output_path,
            password,
        ]

        wb.save()
        app.quit()

    # delete existing file
    """
        Function to remove exiisting file
        file name required parameter.
    """

    def file_cleaner(self, file):
        if os.path.exists(file):
            os.remove(file)

    # save email to outlook drafts
    """
        Function to attached the current request to outlook and save it as a draft
        Draft email body ready, to be reviewed and sent.
        File name and password required parameters
    """

    def draft_email(self, file_name, password):
        const = win32com.client.constants
        olMailItem = 0x0
        obj = win32com.client.Dispatch("Outlook.Application")

        new_mail = obj.CreateItem(olMailItem)
        new_mail.Subject = "Insert Email Subject Here"
        new_mail.BodyFormat = 2

        signature_htm = os.path.join(
            os.environ["USERPROFILE"], "AppData\\Roaming\\Microsoft\\Signatures\\HP.htm"
        )
        html_file = codecs.open(signature_htm, "r", "utf-8", errors="ignore")
        email_signature = html_file.read()
        html_file.close()

        email_body = """
        <HTML>
            <BODY style="font-family:HP Simplified Light;font-size:14.5px;">
                <p>Hi XXXX,</p>
                <p>Please find attached the report requested.</p>
                <p>[ Start - Delete these lines if file is not password protected ***</p>
                <p>Copy Password Then review file, delete password from this email, send email and share password on a separate email.</p>
                <p>The attached file is password protected, the password will be shared on the following email.</p>
                <p>Password: {0}</p>
                <p>End - Delete these lines if file is not password protected]</p>
                <p>Kind Regards,</p> 
            </BODY>
        </HTML>""".format(
            password
        )
        new_mail.HTMLBody = email_body + email_signature
        new_mail.To = "insert.requester.email@here.com"
        attachment = self.__output_path + file_name + ".xlsx"
        new_mail.Attachments.Add(Source=attachment)
        new_mail.save()
        # new_mail.display(True)
        # new_mail.Send()
        return None

    # save formatted file
    """
        Function to save as a formatted excel file to an specific directory
        dataframe, file name and protect file parameters required.
    """

    def file_saver(self, data, file_name, protect_file):
        # default password
        file_password = ""

        # remove existing files before save
        self.file_cleaner("{0}{1}.xlsx".format(self.__output_path, file_name))

        # workbook / sheet variables
        app = xw.App(visible=False)
        wb = xw.Book()
        ws = wb.sheets[0]

        # excel data header formatting
        ws.range("A1").options(index=False).value = data
        header_format = ws.range("A1").expand("right")
        header_format.color = (0, 150, 214)
        header_format.api.Font.Name = "HP Simplified Light"
        header_format.api.Font.Color = 0xFFFFFF
        header_format.api.Font.Bold = True
        header_format.api.Font.Size = 13

        # excel data content formatting
        data_format = ws.range("A2").expand("table")
        data_format.api.Font.Name = "HP Simplified Light"
        data_format.api.Font.Size = 12

        # save password protect file if needed
        if protect_file == "Yes":
            file_password = "HPI" + str(self.__today.strftime("%I%M%S"))
            wb.api.SaveAs(self.__output_path + file_name, Password=file_password)

        elif protect_file == "No":
            wb.api.SaveAs(self.__output_path + file_name)

        app.quit()

        # update password tracker
        self.password_tracker(
            self.__today,
            file_name,
            file_password,
        )

        # promtp email
        self.draft_email(file_name, file_password)

    # export file to folder
    """
        Function to call functions that finish the process of manage each request.
    """

    def export_data(self, odf, custom_filename="", protect_file="No"):
        # assign file name
        if custom_filename == "":
            file_date = self.__today.strftime("%Y-%m-%d")
            file_name = self.__request_from + " " + file_date
        else:
            file_name = custom_filename

        # save file
        self.file_saver(
            odf,
            file_name,
            protect_file,
        )

    def ppt_analyzer(input, output):

        """Take the input file and analyze the structure.
        The output file contains marked up information to make it easier
        for generating future powerpoint templates.
        """
        prs = Presentation(input)
        # Each powerpoint file has multiple layouts
        # Loop through them all and  see where the various elements are
        for index, _ in enumerate(prs.slide_layouts):
            slide = prs.slides.add_slide(prs.slide_layouts[index])
            # Not every slide has to have a title
            try:
                title = slide.shapes.title
                title.text = "Title for Layout {}".format(index)
            except AttributeError:
                print("No Title for Layout {}".format(index))
            # Go through all the placeholders and identify them by index and type
            for shape in slide.placeholders:
                if shape.is_placeholder:
                    phf = shape.placeholder_format
                    # Do not overwrite the title which is just a special placeholder
                    try:
                        if "Title" not in shape.text:
                            shape.text = "Placeholder index:{} type:{}".format(
                                phf.idx, shape.name
                            )
                    except AttributeError:
                        print("{} has no text attribute".format(phf.type))
                    print("{} {}".format(phf.idx, shape.name))
        prs.save("./Templates/" + output)
            
    def ppt_export(self, file_type, org=None):

         # determine output file HPI Total or L1 Org Dashboard
        if file_type == "HPI":
            output_file = "HPI DEI Dashboard {0} {1}".format(
                self.__current_quarter, self.__fiscal_quarter
            )
        elif file_type == "L1 ORG":
            output_file = "DEI {0} Dashboard {1}".format(org, self.__monthyear)

        # set slides to be updated
        prs = Presentation("./Templates/HP_Presentation_Template.pptx")
        slide_1 = prs.slides[0]
        slide_4 = prs.slides[3]
        slide_6 = prs.slides[5]
        slide_7 = prs.slides[6]
        slide_8 = prs.slides[7]
        slide_9 = prs.slides[8]

        # set placeholders to be updated
        prs_sub_1 = slide_1.placeholders[1]
        prs_sub_4 = slide_4.placeholders[0]
        prs_sub_6 = slide_6.placeholders[0]
        prs_sub_7 = slide_7.placeholders[0]
        prs_sub_8 = slide_8.placeholders[0]
        prs_sub_9 = slide_9.placeholders[0]

        # update placeholders
        if file_type == "HPI":
            prs_sub_1.text = "As of {0} month, end/{1}".format(
                self.__monthname_long, self.__current_quarter
            )
        elif file_type == "L1 ORG":
            prs_sub_1.text = "{0} (As of {1} month, end/{2})".format(
                org, self.__monthname_long, self.__current_quarter
            )

        prs_sub_4.text = (
            self.__fiscal_quarter + " " + self.__current_quarter + " Headcount"
        )
        prs_sub_6.text = "{0}/{1} Status to Diversity Targets (Company Level)".format(
            self.__monthname_short, self.__current_quarter
        )
        prs_sub_7.text = "{0}/{1} Active Headcount by Organization / MRU".format(
            self.__monthname_short, self.__current_quarter
        )
        prs_sub_8.text = (
            "{0}/{1} Active Headcount by Organization / MRU (Absolute values)".format(
                self.__monthname_short, self.__current_quarter
            )
        )
        prs_sub_9.text = "{0}/{1} US Ethnic Groups Not Self-Identified HC by Organization / MRU".format(
            self.__monthname_short, self.__current_quarter
        )

        # save updated template
        prs.save(self.__output_path + file_type + "\\" + output_file + ".pptx")
