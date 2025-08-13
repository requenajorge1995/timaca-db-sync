# SQL Server to Google Sheets Incremental Sync

## Overview

This Python script connects to a SQL Server database via pyodbc, retrieves only new records since the last execution based on the request number, and appends them to a Google Sheets document.

The script stores the last processed request number in a local file `last_request_number.txt` so that each run only processes new data.

---

## Requirements

- **Python:** 3.13.6
- **SQL Server:** connection credentials (ODBC driver required)
- **Google Cloud Project** with:
  - Google Sheets API enabled
  - Service account credentials JSON file

---

## Environment Variables

Create a `.env` file in the project root with:

```env
# Database connection
DB_DRIVER=
DB_SERVER=
DB_PORT=
DB_NAME=
DB_USER=
DB_PASSWORD=

# Google Sheets
GOOGLE_SHEET_KEY=
GOOGLE_CREDENTIALS_FILE=
```

---

## Installation

### 1. Create a virtual environment:

```bash
python -m venv venv
```

### 2. Activate the virtual environment:

**Linux / macOS:**
```bash
source venv/bin/activate
```

**Windows (PowerShell):**
```powershell
venv\Scripts\Activate.ps1
```

### 3. Install dependencies:

```bash
pip install -r requirements.txt
```

---

## Running the Script

Run manually:

```bash
python -m src.main
```

---

## How It Works

1. Reads the last processed request number from last_request_number.txt (defaults to 0 if not found).
2. Connects to SQL Server using pyodbc and environment variables.
3. Executes a parameterized query to fetch only rows where T1.Numero is greater than the last stored request number.
4. Appends results to Google Sheets using the Sheets API.
5. Updates last_request_number.txt with the highest request number from the latest run.

---

## Notes

- Ensure the ODBC driver for SQL Server is installed on your system.
- The Google Sheets document must be shared with the service account email from your credentials file.
- If you want to reset the incremental sync, delete `last_request_number.txt`.