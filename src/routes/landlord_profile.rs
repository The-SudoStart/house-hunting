use axum::{
    extract::{Query, State},
    http::StatusCode,
    Json,
};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

use crate::models::CreateLandlordProfile;
use crate::repository::{
    create_landlord_profile, get_landlord_profile_by_phone, LandlordProfileResponse,
};
use crate::routes::ApiError;

/// Response wrapper for one landlord profile.
#[derive(Debug, Clone, Serialize)]
pub struct LandlordProfileBody {
    pub status: &'static str,
    pub data: LandlordProfileResponse,
}

#[derive(Debug, Clone, Deserialize)]
pub struct GetLandlordProfileQuery {
    pub phone_number: String,
}

/// Handler for `POST /landlord-profiles`.
pub async fn create_profile(
    State(pool): State<PgPool>,
    Json(payload): Json<CreateLandlordProfile>,
) -> Result<(StatusCode, Json<LandlordProfileBody>), ApiError> {
    validate_profile_payload(&payload)?;

    let profile = create_landlord_profile(&pool, &payload)
        .await
        .map_err(|err| {
            tracing::error!("Failed to create landlord profile: {}", err);
            ApiError::new(
                "internal_server_error",
                "Failed to create landlord profile. Please try again later.",
            )
        })?;

    Ok((
        StatusCode::CREATED,
        Json(LandlordProfileBody {
            status: "success",
            data: LandlordProfileResponse::from(profile),
        }),
    ))
}

/// Handler for `GET /landlord-profiles?phone_number=...`.
pub async fn get_profile(
    State(pool): State<PgPool>,
    Query(query): Query<GetLandlordProfileQuery>,
) -> Result<(StatusCode, Json<LandlordProfileBody>), ApiError> {
    let phone_number = query.phone_number.trim();
    if phone_number.is_empty() {
        return Err(ApiError::new("bad_request", "phone_number is required."));
    }

    let profile = get_landlord_profile_by_phone(&pool, phone_number)
        .await
        .map_err(|err| {
            tracing::error!("Failed to retrieve landlord profile: {}", err);
            ApiError::new(
                "internal_server_error",
                "Failed to retrieve landlord profile. Please try again later.",
            )
        })?
        .ok_or_else(|| ApiError::new("not_found", "Landlord profile was not found."))?;

    Ok((
        StatusCode::OK,
        Json(LandlordProfileBody {
            status: "success",
            data: LandlordProfileResponse::from(profile),
        }),
    ))
}

fn validate_profile_payload(payload: &CreateLandlordProfile) -> Result<(), ApiError> {
    if payload.full_name.trim().is_empty() {
        return Err(ApiError::new("bad_request", "full_name is required."));
    }

    if payload.verified_phone_number.trim().is_empty() {
        return Err(ApiError::new(
            "bad_request",
            "verified_phone_number is required.",
        ));
    }

    if !matches!(payload.account_type.as_str(), "landlord" | "property_agent") {
        return Err(ApiError::new(
            "bad_request",
            "account_type must be landlord or property_agent.",
        ));
    }

    Ok(())
}
