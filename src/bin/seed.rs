use house_hunting::config::AppConfig;
use house_hunting::db::{create_pool, run_migrations, verify_connection};
use sqlx::PgPool;
use tracing::{info, warn};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let subscriber = tracing_subscriber::FmtSubscriber::builder()
        .with_max_level(tracing::Level::INFO)
        .finish();
    tracing::subscriber::set_global_default(subscriber)?;

    let config = AppConfig::from_env().unwrap_or_default();
    let pool = create_pool(&config.database_url).await?;
    verify_connection(&pool).await?;
    run_migrations(&pool).await?;

    seed_houses(&pool).await?;

    Ok(())
}

async fn seed_houses(pool: &PgPool) -> Result<(), sqlx::Error> {
    let existing: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM houses")
        .fetch_one(pool)
        .await?;

    if existing.0 > 0 {
        warn!(
            "Houses table already contains {} rows. Truncating before re-seeding.",
            existing.0
        );
        sqlx::query("TRUNCATE TABLE houses RESTART IDENTITY CASCADE")
            .execute(pool)
            .await?;
    }

    info!("Seeding houses table with sample data...");

    let houses = vec![
        (
            "Modern 3-Bedroom Apartment in Bastos",
            Some("Spacious apartment with modern finishes, secure parking, and 24/7 water supply. Located in the upscale Bastos neighborhood, close to embassies and international schools."),
            450000.00,
            Some(3),
            Some(2.0),
            Some(140),
            Some("apartment"),
            "Rue 1.123, Bastos",
            "Yaoundé",
            Some("Centre"),
            Some("12345"),
            Some("Cameroon"),
            Some(3.8480),
            Some(11.5021),
            "+237674123456",
        ),
        (
            "Affordable Studio near University of Yaoundé I",
            Some("Compact studio ideal for students. Shared kitchen and bathroom. Walking distance to campus and affordable restaurants."),
            75000.00,
            Some(1),
            Some(1.0),
            Some(35),
            Some("studio"),
            "Ngoa-Ekelle, Campus Road",
            "Yaoundé",
            Some("Centre"),
            Some("12346"),
            Some("Cameroon"),
            Some(3.8600),
            Some(11.5100),
            "+237675234567",
        ),
        (
            "Family House in Bonapriso",
            Some("Beautiful family home with a small garden, tiled floors, and independent water tank. Quiet street with friendly neighbors."),
            380000.00,
            Some(4),
            Some(2.5),
            Some(200),
            Some("house"),
            "Avenue de Gaulle, Bonapriso",
            "Douala",
            Some("Littoral"),
            Some("23456"),
            Some("Cameroon"),
            Some(4.0500),
            Some(9.7000),
            "+237676345678",
        ),
        (
            "Furnished 2-Bedroom Flat in Akwa",
            Some("Fully furnished flat in the commercial heart of Douala. Close to banks, supermarkets, and public transport. Air conditioning in both bedrooms."),
            250000.00,
            Some(2),
            Some(2.0),
            Some(90),
            Some("apartment"),
            "Boulevard de la Liberté, Akwa",
            "Douala",
            Some("Littoral"),
            Some("23457"),
            Some("Cameroon"),
            Some(4.0430),
            Some(9.6940),
            "+237677456789",
        ),
        (
            "Cozy 1-Bedroom in Buea Town",
            Some("Clean one-bedroom apartment with uninterrupted mountain views. Reliable electricity and good internet coverage. Ideal for young professionals."),
            120000.00,
            Some(1),
            Some(1.0),
            Some(55),
            Some("apartment"),
            "Great Soppo, Buea Town",
            "Buea",
            Some("Southwest"),
            Some("34567"),
            Some("Cameroon"),
            Some(4.1520),
            Some(9.2900),
            "+237678567890",
        ),
        (
            "4-Bedroom Villa in Limbe Beachside",
            Some("Stunning villa with ocean views, large compound, and parking for multiple cars. Perfect for families or expats. 5 minutes walk to the beach."),
            600000.00,
            Some(4),
            Some(3.0),
            Some(280),
            Some("house"),
            "Down Beach Road, Limbe",
            "Limbe",
            Some("Southwest"),
            Some("34568"),
            Some("Cameroon"),
            Some(4.0240),
            Some(9.1900),
            "+237679678901",
        ),
        (
            "Traditional 3-Bedroom House in Bamenda",
            Some("Solid brick house in a calm neighborhood near Mile 2. Large living room, functional kitchen, and strong community security."),
            180000.00,
            Some(3),
            Some(2.0),
            Some(150),
            Some("house"),
            "Mile 2, Nkwen",
            "Bamenda",
            Some("Northwest"),
            Some("45678"),
            Some("Cameroon"),
            Some(6.0000),
            Some(10.1500),
            "+237680789012",
        ),
        (
            "Student Hostel near UB Buea",
            Some("Shared hostel with private rooms. Common study area, generator backup, and gated compound. Popular with University of Buea students."),
            60000.00,
            Some(1),
            Some(1.0),
            Some(25),
            Some("hostel"),
            "Molyko, UB Junction",
            "Buea",
            Some("Southwest"),
            Some("34569"),
            Some("Cameroon"),
            Some(4.1550),
            Some(9.2950),
            "+237681890123",
        ),
        (
            "Luxury Apartment in Deido",
            Some("High-end apartment with marble floors, modern kitchen, and secured elevator access. Close to Douala International Airport."),
            500000.00,
            Some(3),
            Some(2.5),
            Some(160),
            Some("apartment"),
            "Rue Kotto, Deido",
            "Douala",
            Some("Littoral"),
            Some("23458"),
            Some("Cameroon"),
            Some(4.0550),
            Some(9.7650),
            "+237682901234",
        ),
        (
            "Compact Shop-House in Kumba Market",
            Some("Ground floor shop with residential space above. High foot traffic area ideal for small business owners."),
            150000.00,
            Some(2),
            Some(1.5),
            Some(80),
            Some("house"),
            "Kumba Main Market Road",
            "Kumba",
            Some("Southwest"),
            Some("34570"),
            Some("Cameroon"),
            Some(4.6360),
            Some(9.4450),
            "+237683012345",
        ),
        (
            "Newly Built 2-Bedroom in Mokolo",
            Some("Brand new construction with modern fittings, tiled bathrooms, and running water. Good road access and close to the market."),
            130000.00,
            Some(2),
            Some(1.0),
            Some(75),
            Some("apartment"),
            "Mokolo Market Street",
            "Yaoundé",
            Some("Centre"),
            Some("12347"),
            Some("Cameroon"),
            Some(3.8700),
            Some(11.5150),
            "+237684123456",
        ),
        (
            "Rural Homestead in Bafoussam",
            Some("Large family compound on a quiet hillside. Multiple buildings, outdoor kitchen, and ample farmland space. Great for extended families."),
            220000.00,
            Some(5),
            Some(3.0),
            Some(300),
            Some("house"),
            "Bamendjing Road, Bafoussam",
            "Bafoussam",
            Some("West"),
            Some("56789"),
            Some("Cameroon"),
            Some(5.4700),
            Some(10.4200),
            "+237685234567",
        ),
        (
            "Executive Flat in Ngousso",
            Some("Executive flat in a gated compound. Close to government ministries and the Prime Minister's office. Excellent security and water supply."),
            350000.00,
            Some(3),
            Some(2.0),
            Some(130),
            Some("apartment"),
            "Rue du Ministère, Ngousso",
            "Yaoundé",
            Some("Centre"),
            Some("12348"),
            Some("Cameroon"),
            Some(3.8650),
            Some(11.5100),
            "+237686345678",
        ),
        (
            "Simple 2-Bedroom in Maroua",
            Some("Affordable housing in a hot climate city. Thick walls keep interiors cool. Close to the central market and hospital."),
            90000.00,
            Some(2),
            Some(1.0),
            Some(70),
            Some("house"),
            "Rue de l'Hopital, Maroua",
            "Maroua",
            Some("Far-North"),
            Some("67890"),
            Some("Cameroon"),
            Some(10.5910),
            Some(14.3150),
            "+237687456789",
        ),
        (
            "Spacious Duplex in Bonanjo",
            Some("Two-story duplex with a rooftop terrace, large living area, and servant quarters. Located in Douala's administrative district."),
            700000.00,
            Some(5),
            Some(3.5),
            Some(250),
            Some("house"),
            "Avenue du Général de Gaulle, Bonanjo",
            "Douala",
            Some("Littoral"),
            Some("23459"),
            Some("Cameroon"),
            Some(4.0460),
            Some(9.6900),
            "+237688567890",
        ),
        (
            "Garden Flat in Ngaoundéré",
            Some("Ground floor flat with a private garden and fruit trees. Cool highland climate, reliable water, and friendly neighborhood."),
            160000.00,
            Some(3),
            Some(2.0),
            Some(110),
            Some("apartment"),
            "Mardock Avenue, Ngaoundéré",
            "Ngaoundéré",
            Some("Adamawa"),
            Some("78901"),
            Some("Cameroon"),
            Some(7.3200),
            Some(13.5800),
            "+237689678901",
        ),
        (
            "Single Room in Obili",
            Some("Basic single room with shared toilet and bathroom. Very affordable, close to student nightlife and cheap food."),
            40000.00,
            Some(1),
            Some(0.5),
            Some(20),
            Some("room"),
            "Obili, Yaoundé",
            "Yaoundé",
            Some("Centre"),
            Some("12349"),
            Some("Cameroon"),
            Some(3.8550),
            Some(11.5050),
            "+237690789012",
        ),
        (
            "3-Bedroom Bungalow in Garoua",
            Some("Single-story bungalow with a large yard, mango trees, and a borehole. Perfect for families seeking space and privacy."),
            200000.00,
            Some(3),
            Some(2.0),
            Some(160),
            Some("house"),
            "Rue de l'Université, Garoua",
            "Garoua",
            Some("North"),
            Some("89012"),
            Some("Cameroon"),
            Some(9.3000),
            Some(13.4000),
            "+237691890123",
        ),
        (
            "Penthouse in Bali",
            Some("Top-floor penthouse with panoramic views of Yaoundé. Private elevator, marble floors, and integrated smart home features."),
            850000.00,
            Some(4),
            Some(3.5),
            Some(220),
            Some("apartment"),
            "Bali, Yaoundé",
            "Yaoundé",
            Some("Centre"),
            Some("12350"),
            Some("Cameroon"),
            Some(3.8800),
            Some(11.4900),
            "+237692901234",
        ),
        (
            "2-Bedroom Apartment in Bafut",
            Some("Newly renovated apartment with good road access. Close to the palace and local market. Ideal for small families."),
            110000.00,
            Some(2),
            Some(1.0),
            Some(65),
            Some("apartment"),
            "Bafut Palace Road",
            "Bamenda",
            Some("Northwest"),
            Some("45679"),
            Some("Cameroon"),
            Some(6.0800),
            Some(10.1000),
            "+237693012345",
        ),
        (
            "Commercial House in Makepe",
            Some("Mixed-use building with a shop on the ground floor and 3 bedrooms upstairs. Great for entrepreneurs who want to live above their business."),
            280000.00,
            Some(3),
            Some(2.0),
            Some(140),
            Some("house"),
            "Makepe Missoke, Douala",
            "Douala",
            Some("Littoral"),
            Some("23460"),
            Some("Cameroon"),
            Some(4.0950),
            Some(9.7650),
            "+237694123456",
        ),
        (
            "Eco-Friendly House in Buea",
            Some("Solar-powered house with rainwater harvesting and organic garden. Modern design with natural ventilation. Popular with environmentally conscious tenants."),
            320000.00,
            Some(3),
            Some(2.0),
            Some(145),
            Some("house"),
            "Clerks Quarter, Buea",
            "Buea",
            Some("Southwest"),
            Some("34571"),
            Some("Cameroon"),
            Some(4.1600),
            Some(9.2800),
            "+237695234567",
        ),
    ];

    for house in houses {
        sqlx::query(
            "INSERT INTO houses (
                title, description, price, bedrooms, bathrooms, square_feet,
                property_type, address, city, state, zip_code, country,
                latitude, longitude, landlord_phone
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)",
        )
        .bind(house.0)
        .bind(house.1)
        .bind(house.2)
        .bind(house.3)
        .bind(house.4)
        .bind(house.5)
        .bind(house.6)
        .bind(house.7)
        .bind(house.8)
        .bind(house.9)
        .bind(house.10)
        .bind(house.11)
        .bind(house.12)
        .bind(house.13)
        .bind(house.14)
        .execute(pool)
        .await?;
    }

    let new_count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM houses")
        .fetch_one(pool)
        .await?;

    info!(
        "Seeding complete. Houses table now contains {} rows.",
        new_count.0
    );

    Ok(())
}
