# Ecommerce User Journey Analysis
### End-to-end Analytics Engineering Project
*Snowflake · dbt · Python · Power BI · Dagster*
---

## Overview
This project analyzes eCommerce behavioral data from a large multi-category online store (Kaggle dataset, Oct 2019 — Apr 2020, 15.6M users, 89M events). 

Built as a complete analytics engineering project — raw data through production-grade dbt models, Python behavioral analysis, and a Power BI dashboard — demonstrating the full modern data stack.
The goal was to identify opportunities across the full user journey — from first visit to repeat purchase — and translate data patterns into actionable business recommendations. 

Findings are relevant to Product Managers making UX and feature decisions, Marketing teams designing re-engagement campaigns, and Growth teams establishing baseline conversion and retention metrics.


## Tech Stack
| Layer           | Tool             | Purpose                   |
|-----------------|------------------|---------------------------|
| Data Warehouse  | Snowflake        | Storage and compute       |
| Data Modeling   | dbt 1.11         | Transformation pipeline   |
| Orchestration   | Dagster          | Scheduling and monitoring |
| Analysis        | Python (Jupyter) | Behavioral analysis       |
| Visualization   | Power BI         | Dashboard and reporting   |
| Version Control | Git/GitHub       | Code management           |


## Architecture

```
Raw monthly files (Snowflake RAW schema)
         ↓
stg_events — unified, cleaned, typed events
         ↓
int_sessions — session-level aggregations
int_users — user lifetime metrics
int_purchases — purchase-level enrichment
         ↓
dim_users — user dimension with segments and tiers
fct_sessions — session fact table
fct_purchases — purchase fact table (incremental)
         ↓
Power BI Dashboard — 4 pages + recommendations
```

## Project Structure
```
ecommerce-behavior-analysis/
├── README.md
├── documentation                 ← dbt generated documentation screenshots
│   ├── Lineage.PNG
│   └── stg_events.PNG
├── packages.yml                  ← dbt_utils package
├── models/
│   ├── staging/
│   │   ├── stg_events.sql
│   │   └── stg_events.yml
│   ├── intermediate/
│   │   ├── int_sessions.sql
│   │   ├── int_users.sql
│   │   ├── int_purchases.sql
│   │   └── intermediate.yml
│   └── marts/
│       ├── dim_users.sql
│       ├── fct_sessions.sql
│       ├── fct_purchases.sql    ← incremental model
│       └── marts.yml
├── macros/
│   ├── union_sources.sql        ← dynamic source union
│   ├── event_flag.sql           ← reusable event aggregation
│   └── safe_divide.sql          ← null-safe division
├── tests/
│   └── assert_no_negative_revenue.sql
├── dagster_project/
│   ├── definitions.py           ← orchestration pipeline
|   └──_screenshots/
│       ├── Automation.PNG
│       ├── Catalog.PNG
│       ├── Lineage.PNG
│       └── Runs.PNG
├── notebooks/
│   ├── 01_funnel_analysis.ipynb
│   ├── 02_cohort_retention.ipynb
│   ├── 03_ltv_prediction.ipynb
│   ├── 04_ab_test.ipynb
│   └── 05_basket_analysis.ipynb
└── dashboard/
    └── screenshots/
        ├── 1_User_Journey.png
        ├── 2_Funnel_Analysis.png
        ├── 3_Retention&LTV.png
        ├── 4_Basket_Analysis.png
        └── 5_Recommendations.png
```

## Engineering Highlights

**dbt Data Modeling**
- Layered architecture: staging → intermediate → marts
- 27 data quality tests across all layers
- Tests caught real issues: non-unique session IDs, timezone inconsistencies, NULL price handling
- Custom singular test: `assert_no_negative_revenue`
- Relationship tests ensuring referential integrity across marts

**Macros**
- `union_sources` — generates UNION ALL dynamically from a source list using Jinja loops, eliminating repetitive SQL
- `event_flag` — reusable event type aggregation (flag or count) using parametrized Jinja macro
- `safe_divide` — null-safe division preventing pipeline failures on zero denominators

**Incremental Model**
- `fct_purchases` materialized as incremental — subsequent runs process only new events using `event_time` watermark
- `unique_key` defined as composite `[user_session, product_id, event_time]` to handle updates correctly
- Full refresh available via `dbt run --full-refresh`

**Orchestration**
- Dagster pipeline with monthly schedule
- All dbt models registered as Dagster assets with full lineage
- Run history and failure alerting via Dagster UI

**Authentication**
- RSA key-pair authentication for Snowflake connection
- No password stored in configuration files


Key Findings
- 87% of users never add a single item to cart — the primary conversion challenge is initial engagement, not cart abandonment  
- 43% of users who add to cart never complete their purchase, representing the clearest short-term conversion opportunity
- Repeat buyers generate 6x more revenue than one-time buyers ($1,658 vs $268 average LTV) — converting just 10% of one-time buyers to repeat buyers represents a $136M revenue opportunity
- 65% of purchases contain only a single item, suggesting significant untapped cross-sell potential at checkout
- Sport, Construction and Apparel categories show 2.69x purchase affinity — users who buy in one category are nearly 3x more likely to buy in associated categories


## Analysis Overview
| Notebook         | Question answered             | Method                         |
|------------------|-------------------------------|--------------------------------|
| Funnel Analysis  | Where do users drop off?      | Session vs user level funnel   |
| Cohort Retention | Do users come back?           | Monthly cohort analysis        |
| LTV Prediction   | What is a user worth?         | Multiplier model + backtesting |
| A/B Test         | Do evening buyers spend more? | Mann-Whitney U test            |
| Basket Analysis  | What do users buy together?   | Apriori association rules      |


## Key Decisions & Methodology Notes

**Data Modeling**
- Staging models kept as views — no storage cost, always fresh
- Intermediate models kept as views — building blocks, not consumer-facing
- Marts materialized as tables — fast query performance for BI tools
- `fct_purchases` made incremental — append-only fact table benefits most from watermark-based processing

**Analysis**
- User-level funnel used as primary metric — session-level significantly understates cart abandonment
- Mann-Whitney U chosen over t-test — revenue distributions are heavily right-skewed (mean ~2x median)
- Multiplier method preferred for LTV — more interpretable than power curve, validated with <7% backtesting error
- Apriori run at user level — only 3.2% of sessions contain multiple categories, insufficient for session-level rules

**A/B Test Finding**
- Evening vs morning purchase value: statistically significant (p < 0.0001) but negligible effect size (r = 0.028)
- Recommendation: do not act — large sample size inflates statistical significance; practical impact is minimal

  
## Dashboard

Power BI dashboard — 4 pages telling the full user journey story:

| Page                    | Content                                    |
|-------------------------|--------------------------------------------|
| Who are our users?      | KPIs, user segments, revenue concentration |
| Where do we lose them?  | Funnel analysis, conversion rates          |
| Who are our best users? | Retention, LTV, cohort analysis            |
| What do they buy?       | Categories, basket size, affinities        |

Screenshots: `/dashboard/screenshots/`