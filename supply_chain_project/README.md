# Supply Chain Performance Analytics — Required-Tools Version

This project follows the tools named in the requirements document:
- Python + Pandas for cleaning
- Pandas + NumPy + Jupyter Notebook for EDA
- SciPy + statsmodels for statistical analysis
- Matplotlib + Seaborn for visualizations
- Power BI / Tableau / Excel for dashboarding
- Moving average / ARIMA are optional forecasting methods, but a time series needs dates.

## Folder structure
- `data/supply_chain_data.csv`: your uploaded dataset
- `analysis.py`: data cleaning, KPI tables, grouped summaries
- `Supply_Chain_EDA.ipynb`: notebook for EDA and statistical analysis
- `visualize.py`: Matplotlib/Seaborn chart export
- `statistical_analysis.py`: SciPy tests and statsmodels regression
- `requirements.txt`: dependencies
- `outputs/`: generated CSV tables and charts after running scripts

## Setup (Windows)
```bash
python -m venv .venv
.venv\\Scripts\\activate
python -m pip install -r requirements.txt
```
## Setup (macOS/Linux)
```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

## Run in order
1. Generate cleaned data and KPI tables:
```bash
python analysis.py
```
2. Create charts:
```bash
python visualize.py
```
3. Run statistical tests:
```bash
python statistical_analysis.py
```
4. Run the notebook:
```bash
jupyter notebook
```
Open `Supply_Chain_EDA.ipynb` and run cells from top to bottom.

## Power BI dashboard
1. Open Power BI Desktop.
2. Home > Get data > Text/CSV.
3. Import `outputs/cleaned_supply_chain_data.csv`.
4. Import `outputs/kpi_summary.csv` if you want a separate KPI table.
5. Create cards for Total Revenue Generated, Total Products Sold, Average Lead Time, Average Shipping Time, and Low-stock records.
6. Create bar charts using Product type, Supplier name, Shipping carriers, Transportation modes, Location, and Inspection results.
7. Add slicers for Product type, Supplier name, Location, Transportation modes, and Shipping carriers.
8. Save as `Supply_Chain_Performance.pbix`.

## Dataset-specific limitations
- The dataset has no order dates, delivery dates, or explicit on-time status; on-time delivery rate and order cycle time cannot be calculated.
- There is no date-indexed demand history; ARIMA or a time-series demand forecast is not defensible with the current file.
- `Lead times` and `Lead time` are separate source fields and have not been silently combined.
- Confirm units/currency for costs and the scale of `Defect rates` before reporting results.
- The data contains only the records in the provided file; conclusions should be described as exploratory.
