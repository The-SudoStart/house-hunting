use axum::{routing::get, Router};
use tower_http::cors::CorsLayer;
use tower_http::trace::TraceLayer;

pub mod health;

pub fn create_router() -> Router {
    Router::new()
        .route("/health", get(health::health_check))
        .layer(CorsLayer::permissive())
        .layer(TraceLayer::new_for_http())
}
