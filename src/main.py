import os
import sys
from datetime import date, datetime

import gspread
import pyodbc
from dotenv import load_dotenv
from google.oauth2.service_account import Credentials

from .logger import get_logger

# =========================
# CONFIGURATION
# =========================
load_dotenv()
LAST_REQUEST_NUMBER_FILE = "last_request_number.txt"
DEFAULT_LAST_REQUEST_NUMBER = 0

# GOOGLE SHEET CONFIG
GOOGLE_SHEET_KEY = os.getenv("GOOGLE_SHEET_KEY")
GOOGLE_CREDENTIALS_FILE = os.getenv("GOOGLE_CREDENTIALS_FILE")


# =========================
# UTILITY FUNCTIONS
# =========================
def get_last_request_number():
    """Reads the last processed request number from file."""
    if not os.path.exists(LAST_REQUEST_NUMBER_FILE):
        return DEFAULT_LAST_REQUEST_NUMBER
    try:
        with open(LAST_REQUEST_NUMBER_FILE, "r", encoding="utf-8") as f:
            content = f.read().strip()
            if not content:
                return DEFAULT_LAST_REQUEST_NUMBER
            return int(content)
    except Exception:
        return DEFAULT_LAST_REQUEST_NUMBER


def save_last_request_number(last_request_number):
    """Saves the last processed request number to file."""
    with open(LAST_REQUEST_NUMBER_FILE, "w", encoding="utf-8") as f:
        f.write(str(last_request_number))


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


def append_to_google_sheet(rows):
    """Appends records to a Google Sheets spreadsheet."""
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

        data_to_insert = [[serialize_value(cell) for cell in row] for row in rows]

        sheet.append_rows(data_to_insert, value_input_option="USER_ENTERED")
    except Exception as e:
        raise RuntimeError(f"Error writing to Google Sheets: {e}")


# =========================
# MAIN PROCESS
# =========================
def main():
    logger = get_logger()
    try:
        logger.info("Starting database query")

        last_request_number = get_last_request_number()
        logger.info(f"Last recorded request number: {last_request_number}")

        conn = get_connection()
        cur = conn.cursor()

        query = """
            SELECT
                T1.Numero AS Nro_SC,
                T1.FechaRequisicion AS Fecha_SC,
                T1.Descripcion AS Descripcion_SC,
                T1.CuentaAux AS Cuenta_Auxiliar,
                T1.fechaaprobacionGte AS Aprobacion_SC,
                T2.material AS Material,
                T2.descripcion AS Descripcion_Material,
                T2.FechaAsignada AS Fecha_Asignar_Comprador,
                T2.Comprador AS Comprador,
                T3.fecha AS Fecha_OC,
                T3.FechaConformada AS Conformada_OC,
                T3.FechaAprobada AS Aprobada_OC,
                T4.Nombre AS Descripcion_Cuenta,
                T6.Numero AS Nro_OC,
                T6.FechaEntrega AS Fecha_Est_Llegada,
                T7.Fecha AS Fecha_Recepcion
            FROM dbo.Requisicion AS T1
            LEFT JOIN dbo.DetalleRequisicion AS T2 ON T1.Numero = T2.ID_Requisicion
            LEFT JOIN dbo.Ordenes AS T3 ON T2.Numero = T3.ID_DetalleRequisicion
            LEFT JOIN dbo.CuentasAux AS T4 ON T1.CuentaAux = T4.ID_Cuenta
            LEFT JOIN dbo.DetalleOrdenes AS T6 ON T3.Numero = T6.Numero_Orden
            LEFT JOIN dbo.Recepcion AS T7 ON T6.Numero = T7.ID_DetalleOrdenes
            WHERE T1.Numero > ?
            ORDER BY T1.Numero ASC;
        """

        cur.execute(query, last_request_number)
        rows = cur.fetchall()

        if rows:
            append_to_google_sheet(rows)
            logger.info(f"Records added to Google Sheets: {len(rows)}")

            # Assuming Nro_SC is the first column in the result set
            max_request_number = max(row[0] for row in rows)
            save_last_request_number(max_request_number)
            logger.info(f"Updated last request number to: {max_request_number}")
        else:
            logger.info("No new records found.")

        cur.close()
        conn.close()

    except Exception:
        logger.exception("Execution error")
        sys.exit(1)


if __name__ == "__main__":
    main()
