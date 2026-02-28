use anyhow::Result;

use crate::{
    engine::{proxifyre::ProxifyreBackend, ProxyEngine},
    model::{AppConfig, EngineMode},
};

pub struct ApiHookEngine {
    backend: ProxifyreBackend,
}

impl Default for ApiHookEngine {
    fn default() -> Self {
        Self {
            backend: ProxifyreBackend::new("api_hook"),
        }
    }
}

impl ProxyEngine for ApiHookEngine {
    fn mode(&self) -> EngineMode {
        EngineMode::ApiHook
    }

    fn start(&self, config: &AppConfig) -> Result<()> {
        self.backend.start(config)
    }

    fn stop(&self) -> Result<()> {
        self.backend.stop()
    }

    fn reload_rules(&self, config: &AppConfig) -> Result<()> {
        self.backend.reload(config)
    }
}
