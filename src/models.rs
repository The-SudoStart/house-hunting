use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};

/// Represents a rental property listing.
///
/// This model supports all information required by the MVP
/// while remaining flexible for future enhancements.
#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct House {
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

/// Payload for creating a new house listing.
#[derive(Debug, Clone, Deserialize)]
pub struct CreateHouse {
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
}

/// Payload for updating an existing house listing.
#[derive(Debug, Clone, Deserialize)]
pub struct UpdateHouse {
    pub title: Option<String>,
    pub description: Option<String>,
    pub price: Option<f64>,
    pub bedrooms: Option<i32>,
    pub bathrooms: Option<f64>,
    pub square_feet: Option<i32>,
    pub property_type: Option<String>,
    pub address: Option<String>,
    pub city: Option<String>,
    pub state: Option<String>,
    pub zip_code: Option<String>,
    pub country: Option<String>,
    pub latitude: Option<f64>,
    pub longitude: Option<f64>,
    pub landlord_phone: Option<String>,
}

/// Represents a verified landlord or property agent profile.
#[derive(Debug, Clone, Serialize, Deserialize, sqlx::FromRow)]
pub struct LandlordProfile {
    pub id: i32,
    pub full_name: String,
    pub verified_phone_number: String,
    pub account_type: String,
    pub profile_photo_url: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

/// Payload for creating a landlord profile after phone verification.
#[derive(Debug, Clone, Deserialize)]
pub struct CreateLandlordProfile {
    pub full_name: String,
    pub verified_phone_number: String,
    pub account_type: String,
    pub profile_photo_url: Option<String>,
}
