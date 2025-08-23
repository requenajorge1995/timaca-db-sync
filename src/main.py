import os
import sys
from datetime import date, datetime, timedelta

import gspread
import pyodbc
from dotenv import load_dotenv
from google.oauth2.service_account import Credentials

from .logger import get_logger

# =========================
# CONFIGURATION
# =========================
load_dotenv()

# GOOGLE SHEET CONFIG
GOOGLE_SHEET_KEY = os.getenv("GOOGLE_SHEET_KEY")
GOOGLE_CREDENTIALS_FILE = os.getenv("GOOGLE_CREDENTIALS_FILE")

# DATE RANGE CONFIG
DAYS_BACK = 365 * 5 

# =========================
# UTILITY FUNCTIONS
# =========================
def get_connection():
    """Establishes and returns a database connection using environment variables."""
    conn_str = (
        f"DRIVER={{{os.getenv('DB_DRIVER')}}};"
        f"SERVER={os.getenv('DB_SERVER')},{os.getenv('DB_PORT')};"
        f"DATABASE={os.getenv('DB_NAME')};"
        f"UID={os.getenv('DB_USER')};"
        f"PWD={os.getenv('DB_PASSWORD')};"
        "TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str)


def get_date_range():
    """Calculates and returns the date range based on DAYS_BACK constant."""
    today = date.today()
    start_date = today - timedelta(days=DAYS_BACK)
    end_date = today
    return start_date, end_date


def update_google_sheet(rows, headers=None):
    """Overwrites Google Sheets data with new records."""
    try:
        scopes = ["https://www.googleapis.com/auth/spreadsheets"]
        creds = Credentials.from_service_account_file(
            GOOGLE_CREDENTIALS_FILE, scopes=scopes
        )
        client = gspread.authorize(creds)
        sheet = client.open_by_key(GOOGLE_SHEET_KEY).sheet1

        def serialize_value(value):
            if isinstance(value, (datetime, date)):
                return value.strftime("%Y-%m-%d %H:%M:%S")
            return "" if value is None else str(value)

        sheet.clear()
        data_to_insert = []
        
        if headers:
            data_to_insert.append(headers)
        
        for row in rows:
            data_to_insert.append([serialize_value(cell) for cell in row])

        if data_to_insert:
            sheet.update(
                values=data_to_insert,
                range_name="A1",
                value_input_option="USER_ENTERED"
            )
            
    except Exception as e:
        raise RuntimeError(f"Error writing to Google Sheets: {e}")

def fetch_sp_results(cur, sp_name, params):
    """Executes a stored procedure and returns the first result set."""
    cur.execute(f"EXEC {sp_name} " + ",".join("?" * len(params)), params)
    while True:
        try:
            return cur.fetchall()
        except pyodbc.ProgrammingError:
            if not cur.nextset():
                return []

# =========================
# MAIN PROCESS
# =========================
def main():
    logger = get_logger()
    try:
        logger.info("Starting stored procedure execution")

        start_date, end_date = get_date_range()
        logger.info(f"Querying data from {start_date} to {end_date}")

        conn = get_connection()
        cur = conn.cursor()

        rows = fetch_sp_results(cur, 'SPConsultaGl', [start_date, end_date])
        headers = [column[0] for column in cur.description]
        
        if rows:
            update_google_sheet(rows, headers)
            logger.info(f"Google Sheet updated with {len(rows)} records")
            logger.info(f"Date range: {start_date} to {end_date}")
        else:
            logger.info("No records found for the specified date range.")
            update_google_sheet([], headers)

        cur.close()
        conn.close()

    except Exception:
        logger.exception("Execution error")
        sys.exit(1)


if __name__ == "__main__":
    main()
