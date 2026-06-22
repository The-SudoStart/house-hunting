use house_hunting::config::AppConfig;
use house_hunting::db::{create_pool, run_migrations, verify_connection};

#[tokio::test]
async fn database_connection_succeeds() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let config = AppConfig::from_env().unwrap_or_default();
    let pool = create_pool(&config.database_url).await?;
    verify_connection(&pool).await?;
    Ok(())
}

#[tokio::test]
async fn migrations_execute_successfully() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let config = AppConfig::from_env().unwrap_or_default();
    let pool = create_pool(&config.database_url).await?;
    run_migrations(&pool).await?;
    Ok(())
}
