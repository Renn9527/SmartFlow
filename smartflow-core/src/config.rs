use std::{fs, path::PathBuf};

use anyhow::{Context, Result};
use directories::ProjectDirs;

use crate::model::AppConfig;

const APP_VENDOR: &str = "SmartFlow";
const APP_NAME: &str = "SmartFlow";
const CONFIG_FILE: &str = "config.json5";

pub fn resolve_config_path() -> Result<PathBuf> {
    let dirs = ProjectDirs::from("com", APP_VENDOR, APP_NAME)
        .context("unable to resolve app data directory")?;
    let config_dir = dirs.config_dir();
    fs::create_dir_all(config_dir)
        .with_context(|| format!("failed to create config dir {}", config_dir.display()))?;
    Ok(config_dir.join(CONFIG_FILE))
}

pub fn load_or_init(path: &PathBuf) -> Result<AppConfig> {
    if !path.exists() {
        let config = AppConfig::default();
        save(path, &config)?;
        return Ok(config);
    }

    let raw = fs::read_to_string(path)
        .with_context(|| format!("failed to read config: {}", path.display()))?;

    if raw.trim().is_empty() {
        let config = AppConfig::default();
        save(path, &config)?;
        return Ok(config);
    }

    let parsed: AppConfig = json5::from_str(&raw)
        .with_context(|| format!("failed to parse JSON5 config: {}", path.display()))?;
    Ok(parsed)
}

pub fn save(path: &PathBuf, config: &AppConfig) -> Result<()> {
    let body = serde_json::to_string_pretty(config).context("failed to serialize config")?;
    fs::write(path, body).with_context(|| format!("failed to write config: {}", path.display()))?;
    Ok(())
}
