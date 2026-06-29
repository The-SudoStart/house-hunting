use axum::body::Body;
use axum::http::{Request, StatusCode};
use house_hunting::config::AppConfig;
use house_hunting::db::{create_pool, run_migrations};
use house_hunting::routes::create_router;
use serde_json::json;
use tower::ServiceExt;

#[tokio::test]
async fn landlord_profile_can_be_created_and_retrieved(
) -> Result<(), Box<dyn std::error::Error + Send + Sync>> {
    let config = AppConfig::from_env().unwrap_or_default();
    let pool = create_pool(&config.database_url).await?;
    run_migrations(&pool).await?;
    let app = create_router(pool);

    let phone_number = format!(
        "+2378{}",
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)?
            .as_millis()
    );

    let create_request = Request::builder()
        .method("POST")
        .uri("/landlord-profiles")
        .header("content-type", "application/json")
        .body(Body::from(
            json!({
                "full_name": "Boris Landlord",
                "verified_phone_number": phone_number,
                "account_type": "property_agent",
                "profile_photo_url": null
            })
            .to_string(),
        ))?;

    let create_response = app.clone().oneshot(create_request).await?;
    assert_eq!(create_response.status(), StatusCode::CREATED);

    let create_body_bytes = axum::body::to_bytes(create_response.into_body(), usize::MAX).await?;
    let create_body: serde_json::Value = serde_json::from_slice(&create_body_bytes)?;

    assert_eq!(create_body["status"], "success");
    assert_eq!(create_body["data"]["full_name"], "Boris Landlord");
    assert_eq!(create_body["data"]["verified_phone_number"], phone_number);
    assert_eq!(create_body["data"]["account_type"], "property_agent");

    let encoded_phone_number = phone_number.replace('+', "%2B");
    let get_request = Request::builder()
        .uri(format!(
            "/landlord-profiles?phone_number={encoded_phone_number}"
        ))
        .body(Body::empty())?;

    let get_response = app.oneshot(get_request).await?;
    assert_eq!(get_response.status(), StatusCode::OK);

    let get_body_bytes = axum::body::to_bytes(get_response.into_body(), usize::MAX).await?;
    let get_body: serde_json::Value = serde_json::from_slice(&get_body_bytes)?;

    assert_eq!(get_body["status"], "success");
    assert_eq!(get_body["data"]["full_name"], "Boris Landlord");
    assert_eq!(get_body["data"]["verified_phone_number"], phone_number);
    assert_eq!(get_body["data"]["account_type"], "property_agent");

    Ok(())
}
