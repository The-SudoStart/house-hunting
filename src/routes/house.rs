use axum::{extract::State, http::StatusCode, response::IntoResponse, Json};
use serde::Serialize;
use sqlx::PgPool;

use crate::repository::{get_all_houses, HouseResponse};

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

/// Response wrapper for a collection of house listings.
#[derive(Debug, Clone, Serialize)]
pub struct HousesListResponse {
    pub status: &'static str,
    pub data: Vec<HouseResponse>,
}

/// Handler for `GET /houses`.
pub async fn list_houses(
    State(pool): State<PgPool>,
) -> Result<(StatusCode, Json<HousesListResponse>), ApiError> {
    let houses = get_all_houses(&pool).await.map_err(|err| {
        tracing::error!("Database query failed: {}", err);
        ApiError::new(
            "internal_server_error",
            "Failed to retrieve house listings. Please try again later.",
        )
    })?;

    let responses: Vec<HouseResponse> = houses.into_iter().map(HouseResponse::from).collect();

    let body = HousesListResponse {
        status: "success",
        data: responses,
    };

    Ok((StatusCode::OK, Json(body)))
}
