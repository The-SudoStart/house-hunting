use axum::{routing::get, Router};
use sqlx::PgPool;
use tower_http::cors::CorsLayer;
use tower_http::trace::TraceLayer;

pub mod health;
pub mod house;

pub fn create_router(pool: PgPool) -> Router {
    Router::new()
        .route("/health", get(health::health_check))
        .route("/houses", get(house::list_houses))
        .with_state(pool)
        .layer(CorsLayer::permissive())
        .layer(TraceLayer::new_for_http())
}
