#!/bin/bash

set -eo pipefail

original_user="${SUDO_USER:-root}"

usage() {
    cat <<EOF

Usage: $0 <bridge-name> <tap-device> <up|down>

  Creates/Deletes and Adds/Removes a TAP network device to/from the specified bridge.

Arguments:
  <bridge-name>  Name of the target bridge interface (e.g., lan-bridge)
  <tap-device>   Name of the TAP network device to create/manage (e.g., tap-emu0)
  up             Creates (if needed), adds TAP to bridge, brings it up
  down           Removes TAP from bridge, brings it down, deletes TAP device

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
    local device_created=false

    printf "INFO: Executing UP action for TAP interface '%s' on bridge '%s'.\n" "${tap_if}" "${bridge_if}"

    # Check if the bridge interface exists
    if ! ip link show "${bridge_if}" >/dev/null 2>&1; then
        printf "Error: Bridge interface '%s' does not exist. Ensure it is set up correctly.\n" "${bridge_if}" >&2
        exit 1
    fi

    if ! ip link show "${tap_if}" >/dev/null 2>&1; then
        printf "INFO: TAP device '%s' not found, creating...\n" "${tap_if}"
        if ! ip tuntap add dev "${tap_if}" mode tap user "${original_user}"; then
            printf "Error: Failed to create TAP device '%s'.\n" "${tap_if}" >&2
            exit 1
        fi
        device_created=true
        printf "INFO: TAP device '%s' created successfully, owned by '%s'.\n" "${tap_if}" "${original_user}"
    else
        printf "INFO: TAP device '%s' already exists.\n" "${tap_if}"
    fi

    printf "INFO: Adding '%s' to bridge '%s'...\n" "${tap_if}" "${bridge_if}"
    if ! ip link set dev "${tap_if}" master "${bridge_if}"; then
        printf "Error: Failed to add '%s' to bridge '%s'.\n" "${tap_if}" "${bridge_if}" >&2
        # Attempt cleanup: bring down and maybe delete if we created it
        ip link set dev "${tap_if}" down || true
        if [[ "${device_created}" = true ]]; then
            ip link delete "${tap_if}" || true
        fi
        exit 1
    fi

    printf "INFO: Bringing up '%s'...\n" "${tap_if}"
    if ! ip link set dev "${tap_if}" up; then
        printf "Error: Failed to bring up '%s'.\n" "${tap_if}" >&2
        # Attempt cleanup: remove from bridge and maybe delete if we created it
        ip link set dev "${tap_if}" nomaster || true
        if [[ "${device_created}" = true ]]; then
            ip link delete "${tap_if}" || true
        fi
        exit 1
    fi

    printf "INFO: UP action finished successfully for '%s' on bridge '%s'.\n" "${tap_if}" "${bridge_if}"
}

# Function to perform the 'down' action, Takes bridge name and tap device name as arguments
run_down_action() {
    local bridge_if="$1"
    local tap_if="$2"

    printf "INFO: Executing DOWN action for TAP interface '%s' on bridge '%s'.\n" "${tap_if}" "${bridge_if}"

    # Check if device exists before trying to manage it
    if ! ip link show "${tap_if}" >/dev/null 2>&1; then
        printf "Warning: TAP device '%s' does not exist. Assuming cleanup is complete or not needed.\n" "${tap_if}" >&2
    else
        # Only attempt removal/down if the device exists
        printf "INFO: Removing '%s' from bridge '%s'...\n" "${tap_if}" "${bridge_if}"
        ip link set dev "${tap_if}" nomaster ||
            printf "Warning: Interface '%s' likely already removed from bridge '%s'.\n" "${tap_if}" "${bridge_if}" >&2

        printf "INFO: Bringing down '%s'...\n" "${tap_if}"
        ip link set dev "${tap_if}" down ||
            printf "Warning: Interface '%s' likely already down.\n" "${tap_if}" >&2

        printf "INFO: Deleting TAP device '%s'...\n" "${tap_if}"
        if ! ip link delete "${tap_if}"; then
            # This might happen if something else deleted it between the check and now
            printf "Warning: Failed to delete TAP device '%s'. It might have been deleted already.\n" "${tap_if}" >&2
        else
            printf "INFO: TAP device '%s' deleted successfully.\n" "${tap_if}"
        fi
    fi

    printf "INFO: DOWN action finished for '%s' on bridge '%s'.\n" "${tap_if}" "${bridge_if}"
}

### main ###

# Check for help flags first
if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "-?" ]]; then
    usage
    exit 0
fi

# Check for correct number of arguments
if [[ "$#" -ne 3 ]]; then
    usage >&2 # Print usage to stderr for errors
    exit 1
fi

# Check if running as root via sudo preferably
check_root

bridge_name="$1"
tap_device="$2"
action="$3"

if test "${action}" = "up"; then
    run_up_action "${bridge_name}" "${tap_device}"
elif test "${action}" = "down"; then
    run_down_action "${bridge_name}" "${tap_device}"
else
    printf "Error: Invalid action '%s'. Must be 'up' or 'down'.\n\n" "${action}" >&2
    usage >&2
    exit 1
fi
