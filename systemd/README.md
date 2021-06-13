# systemd


+ DefaultTimeoutStartSec=, DefaultTimeoutStopSec=, DefaultTimeoutAbortSec=, DefaultRestartSec=

    Configures the default timeouts for starting, stopping and aborting of units, as well as the default time to sleep between automatic restarts of units, as configured per-unit in TimeoutStartSec=, TimeoutStopSec=, TimeoutAbortSec= and RestartSec= (for services, see systemd.service(5) for details on the per-unit settings). Disabled by default, when service with Type=oneshot is used. For non-service units, DefaultTimeoutStartSec= sets the default TimeoutSec= value.

    + DefaultTimeoutStartSec= and DefaultTimeoutStopSec= default to 90s.
    + DefaultTimeoutAbortSec= is not set by default so that all units fall back to TimeoutStopSec=.
    + DefaultRestartSec= defaults to 100ms.

+ DefaultStartLimitIntervalSec=, DefaultStartLimitBurst=

    Configure the default unit start rate limiting, as configured per-service by StartLimitIntervalSec= and StartLimitBurst=. See systemd.service(5) for details on the per-service settings.

    + DefaultStartLimitIntervalSec= defaults to 10s.
    + DefaultStartLimitBurst= defaults to 5.
