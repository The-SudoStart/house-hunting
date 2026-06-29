use axum::{extract::State, http::StatusCode, Json};
use serde::Serialize;
use sqlx::PgPool;

use crate::models::CreateHouse;
use crate::repository::{create_house as insert_house, get_all_houses, HouseResponse};
use crate::routes::ApiError;

/// Response wrapper for a collection of house listings.
#[derive(Debug, Clone, Serialize)]
pub struct HousesListResponse {
    pub status: &'static str,
    pub data: Vec<HouseResponse>,
}

/// Response wrapper for a single house listing.
#[derive(Debug, Clone, Serialize)]
pub struct HouseCreateResponse {
    pub status: &'static str,
    pub data: HouseResponse,
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

/// Handler for `POST /houses`.
pub async fn create_house(
    State(pool): State<PgPool>,
    Json(payload): Json<CreateHouse>,
) -> Result<(StatusCode, Json<HouseCreateResponse>), ApiError> {
    validate_create_house(&payload)?;

    let house = insert_house(&pool, &payload).await.map_err(|err| {
        tracing::error!("Database insert failed: {}", err);
        ApiError::new(
            "internal_server_error",
            "Failed to create house listing. Please try again later.",
        )
    })?;

    let body = HouseCreateResponse {
        status: "success",
        data: HouseResponse::from(house),
    };

    Ok((StatusCode::CREATED, Json(body)))
}

fn validate_create_house(payload: &CreateHouse) -> Result<(), ApiError> {
    if payload.title.trim().is_empty() {
        return Err(ApiError::new("bad_request", "Title is required."));
    }
    if payload.price <= 0.0 {
        return Err(ApiError::new(
            "bad_request",
            "Price must be greater than zero.",
        ));
    }
    if payload.address.trim().is_empty() {
        return Err(ApiError::new("bad_request", "Address is required."));
    }
    if payload.city.trim().is_empty() {
        return Err(ApiError::new("bad_request", "City is required."));
    }
    if payload.landlord_phone.trim().is_empty() {
        return Err(ApiError::new("bad_request", "Landlord phone is required."));
    }

    Ok(())
}
