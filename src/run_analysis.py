"""Create the views, run every query in sql/ and save each result as a CSV.

Usage (from the project root, after build_db.py):
    python src/run_analysis.py
"""
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DB_PATH = ROOT / "olist.duckdb"
SQL_DIR = ROOT / "sql"
RESULTS_DIR = ROOT / "reports" / "results"


def main() -> None:
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    with duckdb.connect(str(DB_PATH)) as con:
        con.execute((SQL_DIR / "01_views.sql").read_text(encoding="utf-8"))

        query_files = [SQL_DIR / "02_data_quality.sql", *sorted(SQL_DIR.glob("q*.sql"))]
        for path in query_files:
            df = con.execute(path.read_text(encoding="utf-8")).df()
            df.to_csv(RESULTS_DIR / f"{path.stem}.csv", index=False)
            print(f"\n=== {path.stem} ({len(df)} rows) ===")
            print(df.head(12).to_string(index=False))


if __name__ == "__main__":
    main()
