#!/bin/bash

# Strict mode
set -euo pipefail

usage() {
    cat <<EOF

Usage: $0 <bridge-name> <tap-device> <up|down>

  Adds or removes a TAP network device to/from the specified bridge.

Arguments:
  <bridge-name>  Name of the target bridge interface (e.g., lan)
  <tap-device>   Name of the TAP network device (e.g., tap-emu0)
  up             Adds the TAP device to the bridge and brings it up
  down           Removes the TAP device from the bridge and brings it down

EOF
}

check_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        printf "Error: This script must be run as root (or with sudo).\n" >&2
        exit 1
    fi
}

# Function to perform the 'up' action, Takes bridge name and tap device name as arguments
run_up_action() {
    local bridge_if="$1"
    local tap_if="$2"

    printf "INFO: Executing UP action for TAP interface '%s' on bridge '%s'.\n" "${tap_if}" "${bridge_if}"

    # Check if the bridge interface exists
    if ! ip link show "${bridge_if}" >/dev/null 2>&1; then
        printf "Error: Bridge interface '%s' does not exist. Ensure it is set up correctly.\n" "${bridge_if}" >&2
        exit 1
    fi

    printf "INFO: Adding '%s' to bridge '%s'...\n" "${tap_if}" "${bridge_if}"
    if ! ip link set dev "${tap_if}" master "${bridge_if}"; then
        printf "Error: Failed to add '%s' to bridge '%s'.\n" "${tap_if}" "${bridge_if}" >&2
        # Attempt to bring the interface down cleanly if it exists
        ip link set dev "${tap_if}" down || true
        exit 1
    fi

    printf "INFO: Bringing up '%s'...\n" "${tap_if}"
    if ! ip link set dev "${tap_if}" up; then
        printf "Error: Failed to bring up '%s'.\n" "${tap_if}" >&2
        # Attempt cleanup
        ip link set dev "${tap_if}" nomaster || true
        exit 1
    fi

    printf "INFO: UP action finished successfully for '%s' on bridge '%s'.\n" "${tap_if}" "${bridge_if}"
}

# Function to perform the 'down' action, Takes bridge name and tap device name as arguments
run_down_action() {
    local bridge_if="$1"
    local tap_if="$2"

    printf "INFO: Executing DOWN action for TAP interface '%s' on bridge '%s'.\n" "${tap_if}" "${bridge_if}"

    printf "INFO: Removing '%s' from bridge '%s'...\n" "${tap_if}" "${bridge_if}"
    ip link set dev "${tap_if}" nomaster ||
        printf "Warning: Interface '%s' already removed from bridge '%s' or does not exist.\n" "${tap_if}" "${bridge_if}" >&2

    printf "INFO: Bringing down '%s'...\n" "${tap_if}"
    ip link set dev "${tap_if}" down ||
        printf "Warning: Interface '%s' already down or does not exist.\n" "${tap_if}" >&2

    printf "INFO: DOWN action finished for '%s' on bridge '%s'.\n" "${tap_if}" "${bridge_if}"
}

### main

if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "-?" ]]; then
    usage
    exit 0
fi
if [[ "$#" -ne 3 ]]; then
    usage >&2
    exit 1
fi

bridge_name="$1"
tap_device="$2"
action="$3"

check_root

if test "${action}" = "up"; then
    run_up_action "${bridge_name}" "${tap_device}"
elif test "${action}" = "down"; then
    run_down_action "${bridge_name}" "${tap_device}"
else
    printf "Error: Invalid action '%s'. Must be 'up' or 'down'.\n\n" "${action}" >&2
    usage >&2
    exit 1
fi
