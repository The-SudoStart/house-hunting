-- Store verified landlord identity details used for property management trust.

CREATE TABLE IF NOT EXISTS landlord_profiles (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    verified_phone_number VARCHAR(20) NOT NULL UNIQUE,
    account_type VARCHAR(50) NOT NULL CHECK (account_type IN ('landlord', 'property_agent')),
    profile_photo_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_landlord_profiles_verified_phone_number
    ON landlord_profiles(verified_phone_number);

CREATE INDEX IF NOT EXISTS idx_landlord_profiles_account_type
    ON landlord_profiles(account_type);
