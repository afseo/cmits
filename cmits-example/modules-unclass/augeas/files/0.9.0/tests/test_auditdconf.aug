module Test_auditdconf =
    let empty = Auditdconf.empty
    let entry = Auditdconf.entry
    let lns = Auditdconf.lns

    test empty get "\n" = {}
    test entry get "\n" = *
    test lns get "#
# This file controls the configuration of the audit daemon
#

log_file = /var/log/audit/audit.log
log_format = RAW
log_group = root
priority_boost = 4
flush = INCREMENTAL
freq = 20
num_logs = 4
disp_qos = lossy
" = (
  { "#comment" }
  { "#comment" = "This file controls the configuration of the audit daemon" }
  { "#comment" }
  {  }
  { "log_file" = "/var/log/audit/audit.log" }
  { "log_format" = "RAW" }
  { "log_group" = "root" }
  { "priority_boost" = "4" }
  { "flush" = "INCREMENTAL" }
  { "freq" = "20" }
  { "num_logs" = "4" }
  { "disp_qos" = "lossy" }
)

