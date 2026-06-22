use axum::body::Body;
use axum::http::{Request, StatusCode};
use house_hunting::config::AppConfig;
use house_hunting::db::create_pool;
use house_hunting::routes::create_router;
use tower::ServiceExt;

#[tokio::test]
async fn health_endpoint_returns_ok() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let config = AppConfig::from_env().unwrap_or_default();
    let pool = create_pool(&config.database_url).await?;
    let app = create_router(pool);

    let request = Request::builder().uri("/health").body(Body::empty())?;

    let response = app.oneshot(request).await?;

    assert_eq!(response.status(), StatusCode::OK);

    let body_bytes = axum::body::to_bytes(response.into_body(), usize::MAX).await?;
    let body: serde_json::Value = serde_json::from_slice(&body_bytes)?;

    assert_eq!(body["status"], "healthy");
    assert_eq!(body["version"], "0.1.0");

    Ok(())
}
