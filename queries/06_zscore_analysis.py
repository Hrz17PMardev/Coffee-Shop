import os
import pandas as pd
import numpy as np
import psycopg2
from scipy import stats

# 1. Import the dot-env library
from dotenv import load_dotenv

# 2. Explicitly load the environment variables from your .env file
load_dotenv()

# 1. Establish database connection (Update credentials to match Docker setup)
try:
    conn = psycopg2.connect(
        host="localhost",
        database=os.getenv('DB_NAME'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        port=os.getenv('PORT', '5432')
    )
    print("🔌 Database connection successful!")
except Exception as e:
    print(f"❌ Connection failed: {e}")
    exit()

# 2. Extract analytical view data into Pandas
query = "SELECT location_name, total_units_sold, total_revenue FROM store_ranks_by_quantity_revenue;"
df = pd.read_sql_query(query, conn)
conn.close()

print("\n--- Raw Data Snapshot ---")
print(df)

# 3. Calculate Z-Scores using SciPy
df['revenue_zscore'] = stats.zscore(df['total_revenue'])
df['quantity_zscore'] = stats.zscore(df['total_units_sold'])

# 4. Programmatic Segmentation based on Standard Deviations (Z-Scores)
# - Z < -0.5: Low / Developing
# - -0.5 <= Z <= 0.5: Medium / Rising
# - Z > 0.5: High / Elite
def segment_by_z(z_score, low_label, mid_label, high_label):
    if z_score < -0.5:
        return low_label
    elif -0.5 <= z_score <= 0.5:
        return mid_label
    else:
        return high_label

df['revenue_tier'] = df['revenue_zscore'].apply(segment_by_z, args=('Low', 'Medium', 'High'))
df['volume_tier'] = df['quantity_zscore'].apply(segment_by_z, args=('Developing', 'Rising', 'Elite'))

print("\n--- 📊 Statistical Z-Score Segmentation Results ---")
print(df[['location_name', 'total_revenue', 'revenue_zscore', 'revenue_tier', 'volume_tier']])

# 5. Output specific numbers to paste back into your SQL Functions
print("\n💡 Suggested SQL Thresholds based on mean and standard deviation:")
rev_mean = df['total_revenue'].mean()
rev_std = df['total_revenue'].std()

print(f"Low Threshold (Mean - 0.5*STD): {rev_mean - 0.5 * rev_std:.2f}")
print(f"High Threshold (Mean + 0.5*STD): {rev_mean + 0.5 * rev_std:.2f}")
