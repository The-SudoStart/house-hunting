use chrono::{DateTime, Utc};
use serde::Serialize;
use sqlx::{Error, PgPool};

use crate::models::House;

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
