# systemd

## default settings

- cgroup
    - allow normal users setup cgroup v2 recursive userns
    - enable nonroot user CPU, CPUSET, and I/O delegation for rootless container
    - enable systemd accounting for limits
- journald
    - limit maximum memory and disk usage for journal to 64m in ram and 128mb on disk
- resolved
    - add stub listener for resolved on ipv6 loopback

### notes

- DefaultTimeoutStartSec=, DefaultTimeoutStopSec=, DefaultTimeoutAbortSec=, DefaultRestartSec=

    Configures the default timeouts for starting, stopping and aborting of units, as well as the default time to sleep between automatic restarts of units, as configured per-unit in TimeoutStartSec=, TimeoutStopSec=, TimeoutAbortSec= and RestartSec= (for services, see systemd.service(5) for details on the per-unit settings). Disabled by default, when service with Type=oneshot is used. For non-service units, DefaultTimeoutStartSec= sets the default TimeoutSec= value.

    - DefaultTimeoutStartSec= and DefaultTimeoutStopSec= default to 90s.
    - DefaultTimeoutAbortSec= is not set by default so that all units fall back to TimeoutStopSec=.
    - DefaultRestartSec= defaults to 100ms.

- DefaultStartLimitIntervalSec=, DefaultStartLimitBurst=

    Configure the default unit start rate limiting, as configured per-service by StartLimitIntervalSec= and StartLimitBurst=. See systemd.service(5) for details on the per-service settings.

    - DefaultStartLimitIntervalSec= defaults to 10s.
    - DefaultStartLimitBurst= defaults to 5.
