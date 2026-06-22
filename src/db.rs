use sqlx::postgres::PgPoolOptions;
use sqlx::{Error, PgPool};
use tracing::{error, info};

pub async fn create_pool(database_url: &str) -> Result<PgPool, Error> {
    PgPoolOptions::new()
        .max_connections(10)
        .connect(database_url)
        .await
}

pub async fn run_migrations(pool: &PgPool) -> Result<(), sqlx::migrate::MigrateError> {
    info!("Running database migrations...");
    sqlx::migrate!("./migrations").run(pool).await?;
    info!("Database migrations completed successfully.");
    Ok(())
}

pub async fn verify_connection(pool: &PgPool) -> Result<(), Error> {
    let row: (i32,) = sqlx::query_as("SELECT 1").fetch_one(pool).await?;

    if row.0 == 1 {
        info!("Database connection verified successfully.");
        Ok(())
    } else {
        error!("Database connection verification failed: unexpected result.");
        Err(Error::RowNotFound)
    }
}
