from pathlib import Path
import pandas as pd
from scipy import stats
import statsmodels.formula.api as smf

df = pd.read_csv("outputs/cleaned_supply_chain_data.csv")
out = Path("outputs")
results = []

# One-way ANOVA: compare lead-time means across supplier groups.
groups = [
    group["Lead time"].dropna().values
    for _, group in df.groupby("Supplier name")
    if group["Lead time"].notna().sum() >= 2
]
if len(groups) >= 2:
    f_stat, p_value = stats.f_oneway(*groups)
    results.append({
        "test": "One-way ANOVA: Lead time by supplier",
        "statistic": f_stat,
        "p_value": p_value,
        "interpretation": "A small p-value suggests at least one supplier mean differs; association is not causation."
    })

# Pearson correlation between available numeric measures.
corr_pairs = [
    ("Shipping times", "Shipping costs"),
    ("Manufacturing lead time", "Manufacturing costs"),
    ("Availability", "Number of products sold"),
    ("Lead time", "Shipping times"),
]
for x, y in corr_pairs:
    pair = df[[x, y]].dropna()
    if len(pair) >= 3 and pair[x].nunique() > 1 and pair[y].nunique() > 1:
        r, p = stats.pearsonr(pair[x], pair[y])
        results.append({
            "test": f"Pearson correlation: {x} vs {y}",
            "statistic": r,
            "p_value": p,
            "interpretation": "Correlation does not establish causation."
        })

pd.DataFrame(results).to_csv(out / "statistical_tests.csv", index=False)

# Multiple regression example: exploratory association for shipping cost.
reg_cols = ["Shipping costs", "Shipping times", "Order quantities", "Price", "Lead time"]
reg = df[reg_cols].dropna()
if len(reg) >= 10:
    model = smf.ols(
        'Q("Shipping costs") ~ Q("Shipping times") + Q("Order quantities") + Q("Price") + Q("Lead time")',
        data=reg
    ).fit()
    with open(out / "shipping_cost_regression.txt", "w", encoding="utf-8") as f:
        f.write(model.summary().as_text())
print("Statistical tests saved to outputs/. Review sample sizes and assumptions before interpreting.")
