use config::{Config, ConfigError, Environment, File};
use serde::Deserialize;

#[derive(Debug, Deserialize, Clone)]
pub struct AppConfig {
    #[serde(default = "default_server_host")]
    pub server_host: String,
    #[serde(default = "default_server_port")]
    pub server_port: u16,
    #[serde(default = "default_log_level")]
    pub log_level: String,
    pub database_url: String,
}

impl AppConfig {
    pub fn from_env() -> Result<Self, ConfigError> {
        let config = Config::builder()
            .add_source(File::with_name("config/app").required(false))
            .add_source(Environment::with_prefix("APP").separator("__"))
            .build()?;

        config.try_deserialize()
    }

    pub fn server_address(&self) -> String {
        format!("{}:{}", self.server_host, self.server_port)
    }
}

impl Default for AppConfig {
    fn default() -> Self {
        Self {
            server_host: default_server_host(),
            server_port: default_server_port(),
            log_level: default_log_level(),
            database_url: default_database_url(),
        }
    }
}

fn default_server_host() -> String {
    "127.0.0.1".to_string()
}

fn default_server_port() -> u16 {
    3000
}

fn default_log_level() -> String {
    "info".to_string()
}

fn default_database_url() -> String {
    "postgres://postgres:postgres@localhost:5432/house_hunting".to_string()
}
