"""Turn the query results in reports/results/ into the charts in reports/figures/.

Usage (from the project root, after run_analysis.py):
    python src/make_charts.py
"""
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib.colors import LinearSegmentedColormap
from matplotlib.ticker import FuncFormatter, PercentFormatter

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "reports" / "results"
FIGURES = ROOT / "reports" / "figures"

# Palette and chart chrome (light mode)
SURFACE = "#fcfcfb"
INK = "#0b0b0b"
INK_2 = "#52514e"
MUTED = "#898781"
GRID = "#e1e0d9"
AXIS = "#c3c2b7"
BLUE = "#2a78d6"
ORANGE = "#eb6834"
BLUE_RAMP = LinearSegmentedColormap.from_list(
    "blue", ["#f3f8fe", "#cde2fb", "#86b6ef", "#3987e5", "#256abf", "#184f95", "#0d366b"]
)

plt.rcParams.update({
    "font.family": ["Segoe UI", "DejaVu Sans", "sans-serif"],
    "font.size": 10,
    "figure.facecolor": SURFACE,
    "axes.facecolor": SURFACE,
    "axes.edgecolor": AXIS,
    "axes.labelcolor": INK_2,
    "axes.titlecolor": INK,
    "axes.titlesize": 13,
    "axes.titleweight": "semibold",
    "axes.titlelocation": "left",
    "axes.titlepad": 14,
    "xtick.color": MUTED,
    "ytick.color": MUTED,
    "xtick.labelcolor": INK_2,
    "ytick.labelcolor": INK_2,
    "axes.spines.top": False,
    "axes.spines.right": False,
    "savefig.dpi": 160,
    "savefig.bbox": "tight",
    "savefig.facecolor": SURFACE,
})


def load(name: str) -> pd.DataFrame:
    return pd.read_csv(RESULTS / f"{name}.csv")


def subtitle(ax, text: str) -> None:
    ax.text(0, 1.015, text, transform=ax.transAxes, color=INK_2, fontsize=9.5, va="bottom")


def y_grid(ax) -> None:
    ax.grid(axis="y", color=GRID, linewidth=0.8)
    ax.set_axisbelow(True)
    ax.spines["left"].set_visible(False)
    ax.tick_params(axis="y", length=0)


def x_grid(ax) -> None:
    ax.grid(axis="x", color=GRID, linewidth=0.8)
    ax.set_axisbelow(True)
    ax.spines["bottom"].set_visible(False)
    ax.tick_params(axis="x", length=0)


def brl_thousands(x, _pos):
    return f"R${x / 1000:,.0f}k"


def monthly_revenue() -> None:
    df = load("q01_monthly_revenue")
    df["purchase_month"] = pd.to_datetime(df["purchase_month"])
    fig, ax = plt.subplots(figsize=(10, 4.6))
    ax.bar(df["purchase_month"], df["revenue"], width=20, color=BLUE, edgecolor=SURFACE, linewidth=1)
    ax.set_title("Revenue grew fast through 2017, then levelled off in 2018", pad=24)
    subtitle(ax, "Delivered orders, item revenue in BRL (excluding freight), Jan 2017 - Aug 2018")
    ax.yaxis.set_major_formatter(FuncFormatter(brl_thousands))
    y_grid(ax)
    nov = df.loc[df["purchase_month"] == "2017-11-01"].iloc[0]
    ax.annotate("Black Friday\nNov 2017", xy=(nov["purchase_month"], nov["revenue"]),
                xytext=(0, 8), textcoords="offset points", ha="center", va="bottom",
                color=INK_2, fontsize=9)
    ax.set_ylim(0, df["revenue"].max() * 1.18)
    ax.xaxis.set_major_formatter(plt.matplotlib.dates.DateFormatter("%b\n%Y"))
    ax.xaxis.set_major_locator(plt.matplotlib.dates.MonthLocator(bymonth=[1, 4, 7, 10]))
    fig.savefig(FIGURES / "01_monthly_revenue.png")
    plt.close(fig)


def late_delivery_reviews() -> None:
    df = load("q07_late_delivery_reviews")
    labels = [s.split(". ", 1)[1] for s in df["delivery_vs_promise"]]
    colors = [BLUE if "early" in s else ORANGE for s in labels]
    fig, ax = plt.subplots(figsize=(9, 4.6))
    bars = ax.bar(labels, df["avg_review_score"], width=0.6, color=colors)
    for bar, score, n in zip(bars, df["avg_review_score"], df["orders"]):
        ax.text(bar.get_x() + bar.get_width() / 2, score + 0.06, f"{score:.2f}",
                ha="center", va="bottom", color=INK, fontsize=10, fontweight="semibold")
        ax.text(bar.get_x() + bar.get_width() / 2, 0.12, f"{n:,} orders",
                ha="center", va="bottom", color="#ffffff", fontsize=8.5)
    ax.set_title("Late deliveries drag reviews from 4.3 stars to 1.7", pad=24)
    subtitle(ax, "Average review score by delivery date vs. the date promised at checkout")
    ax.set_ylim(0, 5)
    ax.set_ylabel("Average review score (1-5)")
    y_grid(ax)
    fig.savefig(FIGURES / "02_late_delivery_reviews.png")
    plt.close(fig)


def top_categories() -> None:
    df = load("q02_category_pareto").head(10).iloc[::-1]
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.barh(df["category"].str.replace("_", " "), df["revenue"], height=0.62, color=BLUE)
    for y, (rev, pct) in enumerate(zip(df["revenue"], df["pct_of_revenue"])):
        ax.text(rev + df["revenue"].max() * 0.01, y, f"{pct:.1f}%", va="center", color=INK_2, fontsize=9)
    ax.set_title("Top 10 categories bring in 62% of revenue", pad=24)
    subtitle(ax, "Item revenue in BRL, delivered orders; labels show share of total revenue")
    ax.xaxis.set_major_formatter(FuncFormatter(brl_thousands))
    ax.set_xlim(0, df["revenue"].max() * 1.12)
    x_grid(ax)
    ax.tick_params(axis="y", length=0)
    fig.savefig(FIGURES / "03_top_categories.png")
    plt.close(fig)


def cohort_retention() -> None:
    df = load("q05_cohort_retention")
    df = df[df["month_number"].between(1, 6)]
    grid = df.pivot(index="cohort_month", columns="month_number", values="retention_pct")
    grid.index = pd.to_datetime(grid.index).strftime("%b %Y")
    fig, ax = plt.subplots(figsize=(8, 7.5))
    im = ax.imshow(grid.values, cmap=BLUE_RAMP, aspect="auto", vmin=0, vmax=1.0)
    for i in range(grid.shape[0]):
        for j in range(grid.shape[1]):
            v = grid.values[i, j]
            if not np.isnan(v):
                ax.text(j, i, f"{v:.2f}%", ha="center", va="center", fontsize=8.5,
                        color="#ffffff" if v > 0.6 else INK)
    ax.set_xticks(range(grid.shape[1]), [f"+{m}" for m in grid.columns])
    ax.set_yticks(range(grid.shape[0]), grid.index)
    ax.set_xlabel("Months after first purchase")
    ax.set_title("Fewer than 1 in 100 customers come back in any month", pad=24)
    subtitle(ax, "Share of each monthly cohort that bought again N months later")
    for side in ("left", "bottom"):
        ax.spines[side].set_visible(False)
    ax.tick_params(length=0)
    cbar = fig.colorbar(im, ax=ax, fraction=0.035, pad=0.02, format=PercentFormatter(decimals=1))
    cbar.outline.set_visible(False)
    cbar.ax.tick_params(colors=MUTED, labelcolor=INK_2, length=0)
    fig.savefig(FIGURES / "04_cohort_retention.png")
    plt.close(fig)


def late_by_state() -> None:
    df = load("q06_delivery_by_state").sort_values("late_pct")
    fig, ax = plt.subplots(figsize=(8.5, 7))
    ax.barh(df["customer_state"], df["late_pct"], height=0.65, color=BLUE)
    for y, (late, days) in enumerate(zip(df["late_pct"], df["avg_delivery_days"])):
        ax.text(late + 0.3, y, f"{late:.1f}%  ({days:.0f} days avg)", va="center", color=INK_2, fontsize=8.5)
    ax.set_title("Late deliveries cluster in the north-east", pad=24)
    subtitle(ax, "Share of delivered orders that arrived after the promised date, by customer state")
    ax.xaxis.set_major_formatter(PercentFormatter(decimals=0))
    ax.set_xlim(0, df["late_pct"].max() * 1.35)
    x_grid(ax)
    ax.tick_params(axis="y", length=0)
    fig.savefig(FIGURES / "05_late_by_state.png")
    plt.close(fig)


def purchase_timing() -> None:
    df = load("q11_purchase_timing")
    grid = df.pivot(index="day_of_week", columns="hour_of_day", values="orders").fillna(0)
    days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    fig, ax = plt.subplots(figsize=(11, 3.8))
    im = ax.imshow(grid.values, cmap=BLUE_RAMP, aspect="auto")
    ax.set_yticks(range(7), days)
    ax.set_xticks(range(0, 24, 2), [f"{h:02d}:00" for h in range(0, 24, 2)])
    ax.set_title("Most orders come in on weekdays between 10:00 and 22:00", pad=24)
    subtitle(ax, "Orders by day of week and hour of purchase (Brasilia time), Jan 2017 - Aug 2018")
    for side in ("left", "bottom"):
        ax.spines[side].set_visible(False)
    ax.tick_params(length=0)
    cbar = fig.colorbar(im, ax=ax, fraction=0.02, pad=0.01)
    cbar.outline.set_visible(False)
    cbar.ax.tick_params(colors=MUTED, labelcolor=INK_2, length=0)
    cbar.set_label("Orders", color=INK_2)
    fig.savefig(FIGURES / "06_purchase_timing.png")
    plt.close(fig)


def main() -> None:
    FIGURES.mkdir(parents=True, exist_ok=True)
    monthly_revenue()
    late_delivery_reviews()
    top_categories()
    cohort_retention()
    late_by_state()
    purchase_timing()
    print(f"Saved charts to {FIGURES}")


if __name__ == "__main__":
    main()
