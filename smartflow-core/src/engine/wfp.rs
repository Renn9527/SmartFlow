use anyhow::Result;

use crate::{
    engine::{proxifyre::ProxifyreBackend, ProxyEngine},
    model::{AppConfig, EngineMode},
};

pub struct WfpEngine {
    backend: ProxifyreBackend,
}

impl Default for WfpEngine {
    fn default() -> Self {
        Self {
            backend: ProxifyreBackend::new("wfp"),
        }
    }
}

impl ProxyEngine for WfpEngine {
    fn mode(&self) -> EngineMode {
        EngineMode::Wfp
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
