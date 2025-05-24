#!/usr/bin/env python3
# /// script
# dependencies = [
#   "icalendar",
# ]
# ///

import subprocess
import sys
import os
from icalendar import Calendar

TEST_VCAL_CONTENT = """BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//TestGen//Test VCAL 1.0//EN
CALSCALE:GREGORIAN
BEGIN:VEVENT
UID:event1@example.com
DTSTAMP:20240101T000000Z
DTSTART:20240101T100000Z
SUMMARY:Event 1 - Should be filtered out (before range)
END:VEVENT
BEGIN:VEVENT
UID:event2@example.com
DTSTAMP:20240101T000000Z
DTSTART:20240102T100000Z
SUMMARY:Event 2 - Should be filtered out (before range)
END:VEVENT
BEGIN:VEVENT
UID:event3@example.com
DTSTAMP:20240101T000000Z
DTSTART:20240103T100000Z
SUMMARY:Event 3 - Should be included
END:VEVENT
BEGIN:VEVENT
UID:event4@example.com
DTSTAMP:20240101T000000Z
DTSTART:20240104T100000Z
SUMMARY:Event 4 - Should be included
END:VEVENT
BEGIN:VEVENT
UID:event5@example.com
DTSTAMP:20240101T000000Z
DTSTART:20240105T100000Z
SUMMARY:Event 5 - Should be included
END:VEVENT
BEGIN:VEVENT
UID:event6@example.com
DTSTAMP:20240101T000000Z
DTSTART:20240106T100000Z
SUMMARY:Event 6 - Should be included
END:VEVENT
BEGIN:VEVENT
UID:event7@example.com
DTSTAMP:20240101T000000Z
DTSTART:20240107T100000Z
SUMMARY:Event 7 - Should be included
END:VEVENT
BEGIN:VEVENT
UID:event8@example.com
DTSTAMP:20240101T000000Z
DTSTART:20240108T100000Z
SUMMARY:Event 8 - Should be included
END:VEVENT
BEGIN:VEVENT
UID:event9@example.com
DTSTAMP:20240101T000000Z
DTSTART:20240109T100000Z
SUMMARY:Event 9 - Should be filtered out (after range)
END:VEVENT
BEGIN:VEVENT
UID:event10@example.com
DTSTAMP:20240101T000000Z
DTSTART:20240110T100000Z
SUMMARY:Event 10 - Should be filtered out (after range)
END:VEVENT
END:VCALENDAR
"""


def run_test():
    """
    Runs the filter-ical.py script with test.vcal data and asserts results.
    """
    print("Starting test-filter.py...")

    # --- Configuration ---
    # Path to the filter-ical.py script. Assumes it's in the same directory.
    script_to_test = os.path.join(os.path.dirname(__file__), "filter-ical.py")
    if not os.path.exists(script_to_test):
        print(f"Error: filter-ical.py not found at {script_to_test}", file=sys.stderr)
        print(
            "Please ensure filter-ical.py is in the same directory and executable.",
            file=sys.stderr,
        )
        sys.exit(1)
    if not os.access(script_to_test, os.X_OK):
        print(f"Error: filter-ical.py at {script_to_test} is not executable.", file=sys.stderr)
        print("Please run: chmod +x filter-ical.py", file=sys.stderr)
        sys.exit(1)

    # Dates for filtering (dd.mm.yyyy format as expected by filter-ical.py)
    # We want to select events from 2024-01-03 to 2024-01-08 inclusive.
    from_date_str = "03.01.2024"
    to_date_str = "08.01.2024"

    # Expected UIDs for the middle 6 events
    expected_uids = [
        "event3@example.com",
        "event4@example.com",
        "event5@example.com",
        "event6@example.com",
        "event7@example.com",
        "event8@example.com",
    ]

    print(f"Filtering from {from_date_str} to {to_date_str}.")

    # --- Execute filter-ical.py ---
    try:
        # Command to execute. Using sys.executable to call the python interpreter explicitly on the script.
        command = [
            sys.executable,
            script_to_test,
            "--from",
            from_date_str,
            "--to",
            to_date_str,
            # "--verbose" # Uncomment for debugging the filter script itself
        ]

        # Run the command, piping TEST_VCAL_CONTENT to its stdin
        process = subprocess.Popen(
            command,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=False,  # Work with bytes for stdin/stdout
        )
        # Encode input string to bytes
        stdout_bytes, stderr_bytes = process.communicate(
            input=TEST_VCAL_CONTENT.encode("utf-8")
        )

        # Decode stderr for printing if necessary
        stderr_output = stderr_bytes.decode("utf-8")
        if process.returncode != 0:
            print(
                f"Error: filter-ical.py exited with code {process.returncode}", file=sys.stderr
            )
            print("Stderr from filter-ical.py:", file=sys.stderr)
            print(stderr_output, file=sys.stderr)
            sys.exit(1)

        if "--verbose" in command and stderr_output:  # Print verbose output if requested
            print("--- Verbose output from filter-ical.py ---")
            print(stderr_output)
            print("--- End of verbose output ---")

    except Exception as e:
        print(f"An error occurred while running filter-ical.py: {e}", file=sys.stderr)
        sys.exit(1)

    # --- Parse and Validate Output ---
    try:
        filtered_ical_str = stdout_bytes.decode("utf-8")
        if not filtered_ical_str.strip():
            print("Error: filter-ical.py produced empty output.", file=sys.stderr)
            sys.exit(1)

        filtered_cal = Calendar.from_ical(filtered_ical_str)
    except Exception as e:
        print(
            f"Error: Could not parse the filtered iCalendar output. Details: {e}",
            file=sys.stderr,
        )
        print("--- Filtered Output (raw) ---")
        print(filtered_ical_str)
        print("--- End of Raw Output ---")
        sys.exit(1)

    # Extract VEVENT components from the filtered calendar
    filtered_events = [comp for comp in filtered_cal.walk() if comp.name == "VEVENT"]

    # Assertion 1: Check the number of events
    print(f"Number of events in filtered output: {len(filtered_events)}")
    assert len(filtered_events) == 6, (
        f"Assertion Failed: Expected 6 events, got {len(filtered_events)}"
    )

    # Assertion 2: Check the UIDs of the events
    filtered_uids = sorted([str(event.get("uid")) for event in filtered_events])
    print(f"UIDs in filtered output: {filtered_uids}")
    assert filtered_uids == sorted(expected_uids), (
        f"Assertion Failed: UIDs do not match. Expected {sorted(expected_uids)}, got {filtered_uids}"
    )

    print("\nAll tests passed successfully!")
    print("The filter correctly selected the middle 6 events.")


if __name__ == "__main__":
    run_test()
