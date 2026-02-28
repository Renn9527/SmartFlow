use std::{collections::HashSet, time::Duration};

use tokio::time;

use crate::{
    model::UiLogEvent,
    process::{list_processes, rule_matches_process},
    state::CoreState,
};

pub fn start_process_watcher(state: CoreState) {
    tokio::spawn(async move {
        let mut seen: HashSet<u32> = HashSet::new();
        let mut ticker = time::interval(Duration::from_secs(2));

        loop {
            ticker.tick().await;

            let processes = list_processes();
            let rules = state.config.read().rules.clone();

            for process in processes {
                if !seen.insert(process.pid) {
                    continue;
                }

                for rule in &rules {
                    if rule_matches_process(rule, &process) {
                        {
                            let mut stats = state.stats.write();
                            *stats.rule_hits.entry(rule.id.clone()).or_insert(0) += 1;
                            *stats.process_hits.entry(process.name.clone()).or_insert(0) += 1;
                        }

                        state.add_log(UiLogEvent::new(
                            "info",
                            "watcher",
                            format!(
                                "rule '{}' matched process {} (pid={})",
                                rule.name, process.name, process.pid
                            ),
                        ));
                    }
                }
            }
        }
    });
}
