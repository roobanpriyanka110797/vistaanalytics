from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

DATA = Path("outputs/cleaned_supply_chain_data.csv")
OUT = Path("outputs/figures")
OUT.mkdir(parents=True, exist_ok=True)
sns.set_theme(style="whitegrid")
df = pd.read_csv(DATA)

def save_bar(data, x, y, title, filename, rotate=25):
    plt.figure(figsize=(10, 6))
    sns.barplot(data=data, x=x, y=y, ci=None, color="C0")
    plt.title(title)
    plt.xticks(rotation=rotate, ha="right")
    plt.tight_layout()
    plt.savefig(OUT / filename, dpi=160)
    plt.close()

save_bar(df, "Product type", "Revenue generated", "Revenue by Product Type", "revenue_by_product.png")
save_bar(df, "Product type", "Number of products sold", "Units Sold by Product Type", "units_sold_by_product.png")
save_bar(df, "Supplier name", "Lead time", "Supplier Lead Time by Record", "lead_time_records_by_supplier.png")
save_bar(df, "Shipping carriers", "Shipping times", "Shipping Time by Carrier", "shipping_time_by_carrier.png")
save_bar(df, "Transportation modes", "Shipping costs", "Shipping Costs by Transportation Mode", "shipping_cost_by_mode.png")
save_bar(df, "Product type", "Manufacturing lead time", "Manufacturing Lead Time by Product Type", "manufacturing_lead_by_product.png")
save_bar(df, "Inspection results", "Defect rates", "Defect-Rate Field by Inspection Result", "defect_rate_by_inspection.png")
save_bar(df, "Location", "Stock levels", "Stock Levels by Location", "stock_by_location.png")

plt.figure(figsize=(9, 6))
sns.scatterplot(data=df, x="Availability", y="Number of products sold", hue="Product type")
plt.title("Sales vs Availability")
plt.tight_layout()
plt.savefig(OUT / "sales_vs_availability.png", dpi=160)
plt.close()
print(f"Charts saved to {OUT}")
