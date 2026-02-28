use std::{collections::VecDeque, path::PathBuf, sync::Arc};

use anyhow::Result;
use parking_lot::RwLock;

use crate::{
    config,
    engine::{mode_name, EngineManager},
    model::{AppConfig, RuntimeStats, UiLogEvent},
};

const MAX_LOGS: usize = 500;

#[derive(Clone)]
pub struct CoreState {
    pub config_path: PathBuf,
    pub config: Arc<RwLock<AppConfig>>,
    pub stats: Arc<RwLock<RuntimeStats>>,
    pub logs: Arc<RwLock<VecDeque<UiLogEvent>>>,
    pub engine: Arc<EngineManager>,
}

impl CoreState {
    pub fn new(config_path: PathBuf, config_data: AppConfig) -> Self {
        let stats = Arc::new(RwLock::new(RuntimeStats {
            engine_mode: mode_name(config_data.engine_mode.clone()),
            ..RuntimeStats::default()
        }));

        let engine = Arc::new(EngineManager::new(
            config_data.engine_mode.clone(),
            stats.clone(),
        ));

        Self {
            config_path,
            config: Arc::new(RwLock::new(config_data)),
            stats,
            logs: Arc::new(RwLock::new(VecDeque::with_capacity(MAX_LOGS))),
            engine,
        }
    }

    pub fn add_log(&self, event: UiLogEvent) {
        let mut logs = self.logs.write();
        logs.push_back(event);
        while logs.len() > MAX_LOGS {
            logs.pop_front();
        }
    }

    pub fn list_logs(&self) -> Vec<UiLogEvent> {
        self.logs.read().iter().cloned().collect()
    }

    pub fn config_snapshot(&self) -> AppConfig {
        self.config.read().clone()
    }

    pub fn stats_snapshot(&self) -> RuntimeStats {
        self.stats.read().clone()
    }

    pub fn persist_config(&self) -> Result<()> {
        let cfg = self.config.read().clone();
        config::save(&self.config_path, &cfg)
    }

    pub fn mutate_config<F, T>(&self, f: F) -> Result<T>
    where
        F: FnOnce(&mut AppConfig) -> T,
    {
        let mut guard = self.config.write();
        let output = f(&mut guard);
        config::save(&self.config_path, &guard)?;
        self.engine.reload_rules(&guard)?;
        Ok(output)
    }
}
