use axum::{extract::State, http::StatusCode, Json};
use serde::Serialize;
use sqlx::PgPool;

use crate::repository::{get_all_houses, HouseResponse};
use crate::routes::ApiError;

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
