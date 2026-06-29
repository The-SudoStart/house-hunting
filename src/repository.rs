use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::{Error, PgPool};

use crate::models::{CreateLandlordProfile, House, LandlordProfile};

/// Retrieves all house listings from the database, ordered by creation date (newest first).
pub async fn get_all_houses(pool: &PgPool) -> Result<Vec<House>, Error> {
    sqlx::query_as::<_, House>(
        "SELECT id, title, description, price, bedrooms, bathrooms, square_feet, property_type, address, city, state, zip_code, country, latitude, longitude, landlord_phone, created_at, updated_at
         FROM houses
         ORDER BY created_at DESC"
    )
    .fetch_all(pool)
    .await
}

/// Response DTO for a single house listing.
#[derive(Debug, Clone, Serialize)]
pub struct HouseResponse {
    pub id: i32,
    pub title: String,
    pub description: Option<String>,
    pub price: f64,
    pub bedrooms: Option<i32>,
    pub bathrooms: Option<f64>,
    pub square_feet: Option<i32>,
    pub property_type: Option<String>,
    pub address: String,
    pub city: String,
    pub state: Option<String>,
    pub zip_code: Option<String>,
    pub country: Option<String>,
    pub latitude: Option<f64>,
    pub longitude: Option<f64>,
    pub landlord_phone: String,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl From<House> for HouseResponse {
    fn from(house: House) -> Self {
        Self {
            id: house.id,
            title: house.title,
            description: house.description,
            price: house.price,
            bedrooms: house.bedrooms,
            bathrooms: house.bathrooms,
            square_feet: house.square_feet,
            property_type: house.property_type,
            address: house.address,
            city: house.city,
            state: house.state,
            zip_code: house.zip_code,
            country: house.country,
            latitude: house.latitude,
            longitude: house.longitude,
            landlord_phone: house.landlord_phone,
            created_at: house.created_at,
            updated_at: house.updated_at,
        }
    }
}

/// Creates or updates a landlord profile for a verified phone number.
pub async fn create_landlord_profile(
    pool: &PgPool,
    profile: &CreateLandlordProfile,
) -> Result<LandlordProfile, Error> {
    sqlx::query_as::<_, LandlordProfile>(
        "INSERT INTO landlord_profiles (full_name, verified_phone_number, account_type, profile_photo_url)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (verified_phone_number)
         DO UPDATE SET
            full_name = EXCLUDED.full_name,
            account_type = EXCLUDED.account_type,
            profile_photo_url = EXCLUDED.profile_photo_url,
            updated_at = NOW()
         RETURNING id, full_name, verified_phone_number, account_type, profile_photo_url, created_at, updated_at",
    )
    .bind(&profile.full_name)
    .bind(&profile.verified_phone_number)
    .bind(&profile.account_type)
    .bind(&profile.profile_photo_url)
    .fetch_one(pool)
    .await
}

/// Retrieves a landlord profile by verified phone number.
pub async fn get_landlord_profile_by_phone(
    pool: &PgPool,
    verified_phone_number: &str,
) -> Result<Option<LandlordProfile>, Error> {
    sqlx::query_as::<_, LandlordProfile>(
        "SELECT id, full_name, verified_phone_number, account_type, profile_photo_url, created_at, updated_at
         FROM landlord_profiles
         WHERE verified_phone_number = $1",
    )
    .bind(verified_phone_number)
    .fetch_optional(pool)
    .await
}

/// Response DTO for a landlord profile.
#[derive(Debug, Clone, Serialize)]
pub struct LandlordProfileResponse {
    pub id: i32,
    pub full_name: String,
    pub verified_phone_number: String,
    pub account_type: String,
    pub profile_photo_url: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

impl From<LandlordProfile> for LandlordProfileResponse {
    fn from(profile: LandlordProfile) -> Self {
        Self {
            id: profile.id,
            full_name: profile.full_name,
            verified_phone_number: profile.verified_phone_number,
            account_type: profile.account_type,
            profile_photo_url: profile.profile_photo_url,
            created_at: profile.created_at,
            updated_at: profile.updated_at,
        }
    }
}
