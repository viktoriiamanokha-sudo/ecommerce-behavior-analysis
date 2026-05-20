from dagster import Definitions, ScheduleDefinition, define_asset_job, AssetExecutionContext
from dagster_dbt import DbtCliResource, dbt_assets
from pathlib import Path

# ── paths ────────────────────────────────────────────────────────────
DBT_PROJECT_PATH  = Path(__file__).parent.parent
DBT_PROFILES_PATH = Path(__file__).parent.parent
DBT_MANIFEST_PATH = DBT_PROJECT_PATH / "target" / "manifest.json"

# ── dbt assets ───────────────────────────────────────────────────────
@dbt_assets(manifest=DBT_MANIFEST_PATH)
def ecommerce_dbt_assets(
    context: AssetExecutionContext,
    dbt: DbtCliResource
):
    yield from dbt.cli(["run"], context=context).stream()

# ── job ──────────────────────────────────────────────────────────────
ecommerce_dbt_job = define_asset_job(
    name="ecommerce_dbt_job",
    selection=[ecommerce_dbt_assets]
)

# ── schedule — runs daily at 6am ─────────────────────────────────────
daily_schedule = ScheduleDefinition(
    job=ecommerce_dbt_job,
    cron_schedule="0 6 1 * *",
    name="daily_ecommerce_refresh"
)

# ── definitions — entry point for Dagster ────────────────────────────
defs = Definitions(
    assets=[ecommerce_dbt_assets],
    schedules=[daily_schedule],
    jobs=[ecommerce_dbt_job],
    resources={
        "dbt": DbtCliResource(
            project_dir=str(DBT_PROJECT_PATH),
            profiles_dir=str(DBT_PROFILES_PATH),
        )
    }
)