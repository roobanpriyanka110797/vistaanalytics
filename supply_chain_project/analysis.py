from pathlib import Path
import pandas as pd
import numpy as np

DATA_PATH = Path("data/supply_chain_data.csv")
OUTPUT_DIR = Path("outputs")
OUTPUT_DIR.mkdir(exist_ok=True)

def load_and_clean(path=DATA_PATH):
    df = pd.read_csv(path)
    df.columns = df.columns.astype(str).str.strip()
    # Trim whitespace from text columns.
    for col in df.select_dtypes(include=["object", "string"]).columns:
        df[col] = df[col].astype("string").str.strip()
    # Convert expected numeric fields without failing on occasional malformed values.
    numeric_cols = [
        "Price", "Availability", "Number of products sold", "Revenue generated",
        "Stock levels", "Lead times", "Order quantities", "Shipping times",
        "Shipping costs", "Lead time", "Production volumes",
        "Manufacturing lead time", "Manufacturing costs", "Defect rates", "Costs"
    ]
    for col in numeric_cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")
    before = len(df)
    # SKU is the product identifier in this dataset; duplicates are reported rather than
    # automatically dropped because repeated SKU rows may represent distinct records.
    duplicate_sku_count = int(df["SKU"].duplicated(keep=False).sum()) if "SKU" in df.columns else 0
    df["Low stock flag"] = df["Stock levels"].le(10)
    df["Zero stock flag"] = df["Stock levels"].le(0)
    df["Sales per available unit"] = np.where(
        df["Availability"] > 0,
        df["Number of products sold"] / df["Availability"],
        np.nan
    )
    df["Shipping cost per unit sold"] = np.where(
        df["Number of products sold"] > 0,
        df["Shipping costs"] / df["Number of products sold"],
        np.nan
    )
    quality = {
        "rows_before_cleaning": before,
        "rows_after_cleaning": len(df),
        "duplicate_sku_rows_flagged": duplicate_sku_count,
        "missing_cells_after_numeric_conversion": int(df.isna().sum().sum())
    }
    return df, quality

def calculate_kpis(df):
    return pd.DataFrame([
        {"KPI": "SKU / record count", "Value": df["SKU"].nunique(), "Definition": "Distinct SKU count"},
        {"KPI": "Total products sold", "Value": df["Number of products sold"].sum(), "Definition": "Sum of Number of products sold"},
        {"KPI": "Total revenue generated", "Value": df["Revenue generated"].sum(), "Definition": "Sum of Revenue generated"},
        {"KPI": "Average supplier lead time", "Value": df["Lead time"].mean(), "Definition": "Mean of Lead time field"},
        {"KPI": "Supplier lead-time standard deviation", "Value": df["Lead time"].std(), "Definition": "Standard deviation of Lead time"},
        {"KPI": "Average shipping time", "Value": df["Shipping times"].mean(), "Definition": "Mean of Shipping times"},
        {"KPI": "Average shipping cost", "Value": df["Shipping costs"].mean(), "Definition": "Mean of Shipping costs"},
        {"KPI": "Average manufacturing lead time", "Value": df["Manufacturing lead time"].mean(), "Definition": "Mean of Manufacturing lead time"},
        {"KPI": "Average defect-rate field", "Value": df["Defect rates"].mean(), "Definition": "Mean of Defect rates; unit/scale should be confirmed"},
        {"KPI": "Low-stock records (stock <= 10)", "Value": int(df["Low stock flag"].sum()), "Definition": "Count of rows where Stock levels <= 10"},
        {"KPI": "Average inventory availability", "Value": df["Availability"].mean(), "Definition": "Mean of Availability"}
    ])

def group_table(df, group_col):
    return df.groupby(group_col, dropna=False).agg(
        record_count=("SKU", "count"),
        distinct_skus=("SKU", "nunique"),
        units_sold=("Number of products sold", "sum"),
        revenue=("Revenue generated", "sum"),
        average_lead_time=("Lead time", "mean"),
        lead_time_std=("Lead time", "std"),
        average_shipping_time=("Shipping times", "mean"),
        average_shipping_cost=("Shipping costs", "mean"),
        average_manufacturing_lead_time=("Manufacturing lead time", "mean"),
        average_defect_rate=("Defect rates", "mean"),
        low_stock_count=("Low stock flag", "sum")
    ).reset_index()

if __name__ == "__main__":
    data, quality = load_and_clean()
    data.to_csv(OUTPUT_DIR / "cleaned_supply_chain_data.csv", index=False)
    calculate_kpis(data).to_csv(OUTPUT_DIR / "kpi_summary.csv", index=False)
    for col, filename in [
        ("Product type", "product_summary.csv"),
        ("Supplier name", "supplier_summary.csv"),
        ("Shipping carriers", "carrier_summary.csv"),
        ("Transportation modes", "transportation_mode_summary.csv"),
        ("Routes", "route_summary.csv"),
        ("Location", "location_summary.csv"),
        ("Inspection results", "inspection_summary.csv"),
    ]:
        group_table(data, col).to_csv(OUTPUT_DIR / filename, index=False)
    pd.DataFrame([quality]).to_csv(OUTPUT_DIR / "data_quality_summary.csv", index=False)
    print("Analysis complete. Files saved in outputs/.")
    print(pd.DataFrame([quality]).to_string(index=False))
