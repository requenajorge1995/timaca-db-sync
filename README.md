# SQL Server to Google Sheets Sync (Stored Procedure)

## Overview

This Python script connects to a SQL Server database via **pyodbc**, executes a stored procedure (`SPConsultaGl`) with a configurable date range, and **overwrites the entire Google Sheet** with the results.

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

1. Calculates a date range based on `DAYS_BACK` (default: last 5 years).
2. Connects to SQL Server using **pyodbc** and environment variables.
3. Executes the stored procedure `SPConsultaGl @desde, @hasta`.
4. Fetches the result set and extracts column headers.
5. Clears the target Google Sheet and overwrites it with the new data.
6. Logs the number of records written and the date range used.

---

## Notes

- Ensure the ODBC driver for SQL Server is installed on your system.
- The Google Sheets document must be shared with the service account email from your credentials file.
- Each run **replaces all data** in the sheet.
