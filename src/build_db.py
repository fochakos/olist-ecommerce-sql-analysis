"""Build olist.duckdb from the raw CSV files in data/.

Usage (from the project root):
    python src/build_db.py
"""
import os
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DB_PATH = ROOT / "olist.duckdb"


def main() -> None:
    os.chdir(ROOT)  # the SQL uses paths relative to the project root
    sql = (ROOT / "sql" / "00_load.sql").read_text(encoding="utf-8")
    with duckdb.connect(str(DB_PATH)) as con:
        con.execute(sql)
        tables = con.execute(
            "SELECT table_name FROM information_schema.tables ORDER BY table_name"
        ).fetchall()
        for (name,) in tables:
            rows = con.execute(f"SELECT COUNT(*) FROM {name}").fetchone()[0]
            print(f"{name:<22}{rows:>12,} rows")


if __name__ == "__main__":
    main()
