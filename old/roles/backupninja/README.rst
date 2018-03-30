BackupNinja Formula

use state roles.backupninja and 
set pillar backupninja
to install and config backup scripts using backupninja

use pillar.backupninja.at: manual to disable calling backupninja via cron

see defaults.jinja for default config options that get merged into pillar setup
see pillar.sample for detailed possibilities
