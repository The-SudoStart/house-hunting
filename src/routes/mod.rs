use axum::{http::StatusCode, response::IntoResponse, routing::get, Json, Router};
use serde::Serialize;
use sqlx::PgPool;
use tower_http::cors::CorsLayer;
use tower_http::trace::TraceLayer;

pub mod health;
pub mod house;
pub mod landlord_profile;

/// API-level error type that produces consistent JSON responses.
#[derive(Debug, Clone, Serialize)]
pub struct ApiError {
    pub status: &'static str,
    pub message: String,
}

impl ApiError {
    pub fn new(status: &'static str, message: impl Into<String>) -> Self {
        Self {
            status,
            message: message.into(),
        }
    }
}

impl IntoResponse for ApiError {
    fn into_response(self) -> axum::response::Response {
        let status = match self.status {
            "not_found" => StatusCode::NOT_FOUND,
            "bad_request" => StatusCode::BAD_REQUEST,
            "internal_server_error" => StatusCode::INTERNAL_SERVER_ERROR,
            _ => StatusCode::INTERNAL_SERVER_ERROR,
        };

        (status, Json(self)).into_response()
    }
}

pub fn create_router(pool: PgPool) -> Router {
    Router::new()
        .route("/health", get(health::health_check))
        .route("/houses", get(house::list_houses))
        .route(
            "/landlord-profiles",
            get(landlord_profile::get_profile).post(landlord_profile::create_profile),
        )
        .with_state(pool)
        .layer(CorsLayer::permissive())
        .layer(TraceLayer::new_for_http())
}
