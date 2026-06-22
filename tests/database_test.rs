use house_hunting::config::AppConfig;
use house_hunting::db::{create_pool, run_migrations, verify_connection};

#[tokio::test]
async fn database_connection_succeeds() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let config = AppConfig::from_env().unwrap_or_default();
    let pool = create_pool(&config.database_url).await?;
    verify_connection(&pool).await?;
    Ok(())
}

#[tokio::test]
async fn migrations_execute_successfully() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let config = AppConfig::from_env().unwrap_or_default();
    let pool = create_pool(&config.database_url).await?;
    run_migrations(&pool).await?;
    Ok(())
}

#[tokio::test]
async fn houses_table_has_all_required_columns(
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let config = AppConfig::from_env().unwrap_or_default();
    let pool = create_pool(&config.database_url).await?;
    run_migrations(&pool).await?;

    let columns: Vec<(String,)> = sqlx::query_as(
        "SELECT column_name FROM information_schema.columns WHERE table_name = 'houses' ORDER BY ordinal_position"
    )
    .fetch_all(&pool)
    .await?;

    let column_names: Vec<String> = columns.into_iter().map(|c| c.0).collect();

    assert!(
        column_names.contains(&"id".to_string()),
        "missing id column"
    );
    assert!(
        column_names.contains(&"title".to_string()),
        "missing title column"
    );
    assert!(
        column_names.contains(&"description".to_string()),
        "missing description column"
    );
    assert!(
        column_names.contains(&"price".to_string()),
        "missing price column"
    );
    assert!(
        column_names.contains(&"bedrooms".to_string()),
        "missing bedrooms column"
    );
    assert!(
        column_names.contains(&"bathrooms".to_string()),
        "missing bathrooms column"
    );
    assert!(
        column_names.contains(&"square_feet".to_string()),
        "missing square_feet column"
    );
    assert!(
        column_names.contains(&"property_type".to_string()),
        "missing property_type column"
    );
    assert!(
        column_names.contains(&"address".to_string()),
        "missing address column"
    );
    assert!(
        column_names.contains(&"city".to_string()),
        "missing city column"
    );
    assert!(
        column_names.contains(&"state".to_string()),
        "missing state column"
    );
    assert!(
        column_names.contains(&"zip_code".to_string()),
        "missing zip_code column"
    );
    assert!(
        column_names.contains(&"country".to_string()),
        "missing country column"
    );
    assert!(
        column_names.contains(&"latitude".to_string()),
        "missing latitude column"
    );
    assert!(
        column_names.contains(&"longitude".to_string()),
        "missing longitude column"
    );
    assert!(
        column_names.contains(&"landlord_phone".to_string()),
        "missing landlord_phone column"
    );
    assert!(
        column_names.contains(&"created_at".to_string()),
        "missing created_at column"
    );
    assert!(
        column_names.contains(&"updated_at".to_string()),
        "missing updated_at column"
    );

    Ok(())
}

#[tokio::test]
async fn houses_table_has_required_indexes() -> Result<(), Box<dyn std::error::Error + Send + Sync>>
{
    let config = AppConfig::from_env().unwrap_or_default();
    let pool = create_pool(&config.database_url).await?;
    run_migrations(&pool).await?;

    let indexes: Vec<(String,)> =
        sqlx::query_as("SELECT indexname FROM pg_indexes WHERE tablename = 'houses'")
            .fetch_all(&pool)
            .await?;

    let index_names: Vec<String> = indexes.into_iter().map(|i| i.0).collect();

    assert!(
        index_names.contains(&"idx_houses_created_at".to_string()),
        "missing idx_houses_created_at"
    );
    assert!(
        index_names.contains(&"idx_houses_city".to_string()),
        "missing idx_houses_city"
    );
    assert!(
        index_names.contains(&"idx_houses_price".to_string()),
        "missing idx_houses_price"
    );
    assert!(
        index_names.contains(&"idx_houses_location".to_string()),
        "missing idx_houses_location"
    );
    assert!(
        index_names.contains(&"idx_houses_landlord_phone".to_string()),
        "missing idx_houses_landlord_phone"
    );

    Ok(())
}

#[tokio::test]
async fn houses_table_can_insert_and_select() -> Result<(), Box<dyn std::error::Error + Send + Sync>>
{
    let config = AppConfig::from_env().unwrap_or_default();
    let pool = create_pool(&config.database_url).await?;
    run_migrations(&pool).await?;

    sqlx::query(
        "INSERT INTO houses (title, description, price, bedrooms, bathrooms, square_feet, property_type, address, city, state, zip_code, country, latitude, longitude, landlord_phone)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)"
    )
    .bind("Test House")
    .bind("A lovely test house")
    .bind(150000.00)
    .bind(3)
    .bind(2.5)
    .bind(1200)
    .bind("house")
    .bind("123 Test Street")
    .bind("Yaounde")
    .bind("Centre")
    .bind("12345")
    .bind("Cameroon")
    .bind(3.8480)
    .bind(11.5021)
    .bind("+237123456789")
    .execute(&pool)
    .await?;

    let row: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM houses WHERE title = 'Test House'")
        .fetch_one(&pool)
        .await?;

    assert_eq!(row.0, 1, "Expected one house to be inserted");

    Ok(())
}
