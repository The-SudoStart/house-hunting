use house_hunting::config::AppConfig;
use house_hunting::db::{create_pool, run_migrations, verify_connection};
use house_hunting::routes::create_router;
use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;

#[allow(clippy::manual_unwrap_or_default)]
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let config = if let Ok(config) = AppConfig::from_env() {
        config
    } else {
        AppConfig::default()
    };

    let log_level = match config.log_level.parse::<Level>() {
        Ok(level) => level,
        Err(_) => Level::INFO,
    };

    let subscriber = FmtSubscriber::builder().with_max_level(log_level).finish();

    tracing::subscriber::set_global_default(subscriber)?;

    let db_pool = create_pool(&config.database_url).await?;
    verify_connection(&db_pool).await?;
    run_migrations(&db_pool).await?;

    let app = create_router(db_pool);
    let address = config.server_address();

    let listener = tokio::net::TcpListener::bind(&address).await?;

    info!("Server starting on http://{}", address);

    axum::serve(listener, app).await?;

    Ok(())
}
