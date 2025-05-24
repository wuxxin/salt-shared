#!/usr/bin/env python3
# /// script
# dependencies = [
#   "icalendar",
# ]
# ///

import sys
import argparse
from datetime import datetime, date, time
from dateutil.tz import tzlocal, UTC
from icalendar import Calendar

# Global variable for verbose mode, set by argparse
VERBOSE = False


def vprint(*args, **kwargs):
    """Prints to stderr if VERBOSE is True"""
    if VERBOSE:
        print(*args, file=sys.stderr, **kwargs)


def parse_user_date_to_datetime(date_str: str) -> date:
    """
    Parses a 'dd.mm.yyyy' date string or 'now' and returns a datetime.date object
    Raises ValueError if parsing fails
    """
    if date_str.lower() == "now":
        # Return the current date (without time component, as the function returns a date object)
        return datetime.now(tzlocal()).date()
    try:
        return datetime.strptime(date_str, "%d.%m.%Y").date()
    except ValueError as e:
        raise argparse.ArgumentTypeError(
            f"Invalid date format: '{date_str}'. Please use dd.mm.yyyy or 'now'."
        ) from e


def normalize_date_to_utc(
    dt_val, component_name="UnknownComponent", field_name="UnknownField"
) -> datetime | None:
    """
    Converts a date or datetime value to a timezone-aware UTC datetime
    - If datetime.date, assumes 00:00:00 local time
    - If naive datetime.datetime, assumes local time
    - If aware datetime.datetime, converts to UTC
    Returns None if dt_val is None
    """
    if dt_val is None:
        return None

    local_tz = tzlocal()
    utc_dt = None

    if isinstance(dt_val, datetime):
        if dt_val.tzinfo is None or dt_val.tzinfo.utcoffset(dt_val) is None:
            # Naive datetime, assume local
            vprint(
                f"  Verbose: Component '{component_name}', field '{field_name}': Found naive datetime {dt_val}. Assuming local timezone ({local_tz})."
            )
            utc_dt = dt_val.replace(tzinfo=local_tz).astimezone(UTC)
        else:
            # Aware datetime, convert to UTC
            vprint(
                f"  Verbose: Component '{component_name}', field '{field_name}': Found aware datetime {dt_val}. Converting to UTC."
            )
            utc_dt = dt_val.astimezone(UTC)
    elif isinstance(dt_val, date):
        # Date only, assume 00:00:00 local time
        vprint(
            f"  Verbose: Component '{component_name}', field '{field_name}': Found date object {dt_val}. Assuming 00:00:00 local time ({local_tz})."
        )
        naive_dt = datetime.combine(dt_val, time.min)
        utc_dt = naive_dt.replace(tzinfo=local_tz).astimezone(UTC)
    else:
        vprint(
            f"  Warning: Component '{component_name}', field '{field_name}': Unexpected date type {type(dt_val)}. Skipping this date field."
        )
        return None

    vprint(
        f"  Verbose: Component '{component_name}', field '{field_name}': Normalized to UTC: {utc_dt}"
    )
    return utc_dt


def get_event_relevant_date_utc(component):
    """
    Tries to get a relevant date from the component in the order:
        DTSTART, DTEND, CREATED, LAST-MODIFIED
    Normalizes the found date to UTC
    Returns (datetime_utc, field_name_used) or (None, None)
    """
    # Property names to check in order of preference
    date_fields_preference = ["DTSTART", "DTEND", "CREATED", "LAST-MODIFIED"]
    component_name = component.name if hasattr(component, "name") else str(type(component))

    for field_name in date_fields_preference:
        prop = component.get(field_name)
        if prop:
            # The actual date/datetime value is in prop.dt
            dt_val = prop.dt
            vprint(
                f"  Verbose: Component '{component_name}': Checking field '{field_name}' with value '{dt_val}'."
            )
            utc_date = normalize_date_to_utc(dt_val, component_name, field_name)
            if utc_date:
                return utc_date, field_name
        else:
            vprint(
                f"  Verbose: Component '{component_name}': Field '{field_name}' not found or empty."
            )

    vprint(
        f"  Warning: Component '{component_name}': No suitable date field found among {date_fields_preference}."
    )
    return None, None


def get_boundary_datetime_utc(
    date_obj: date | None, is_end_date: bool, default_datetime_local: datetime
) -> datetime:
    """
    Calculates the UTC boundary datetime
        If date_obj is provided (from user input like dd.mm.yyyy or 'now'), it's used,
        Otherwise, default_datetime_local is used
    For is_end_date=True, it represents the end of the specified date_obj day (23:59:59.999999),
        or the exact time of default_datetime_local if date_obj is None and default is 'now'
    For is_end_date=False, it represents the start of the specified date_obj day (00:00:00),
        or the exact time of default_datetime_local if date_obj is None and default is 'now'
    The resulting local datetime is converted to UTC
    """
    local_dt = None
    local_tz = tzlocal()

    if date_obj:
        # User provided a specific date via --from or --to (e.g. "01.01.2024" or "now")
        # The date_obj is a datetime.date object.
        if is_end_date:
            # For 'to_date', boundary is end of the specified day
            local_dt = datetime.combine(date_obj, time.max).replace(tzinfo=local_tz)
        else:
            # For 'from_date', boundary is start of the specified day
            local_dt = datetime.combine(date_obj, time.min).replace(tzinfo=local_tz)
    else:
        # Use the provided default_datetime_local
        # This default_datetime_local is already timezone-aware (tzlocal)
        local_dt = default_datetime_local

    return local_dt.astimezone(UTC)


def main():
    global VERBOSE

    parser = argparse.ArgumentParser(
        description="Filter iCalendar entries based on a date range. Reads from stdin, writes to stdout.",
        formatter_class=argparse.RawTextHelpFormatter,
        epilog="Example: cat calendar.ics | ./filter-ical.py --from 01.01.2023 --to now > filtered.ics",
    )
    parser.add_argument(
        "--from",
        dest="from_date_str",
        type=parse_user_date_to_datetime,
        help="Start date for filtering (dd.mm.yyyy or 'now'). Inclusive.\nDefault: 01.01.1970.",
    )
    parser.add_argument(
        "--to",
        dest="to_date_str",
        type=parse_user_date_to_datetime,
        help="End date for filtering (dd.mm.yyyy or 'now'). Inclusive.\nDefault: 31.12.9999 (far future).",
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Enable verbose output to stderr."
    )

    args = parser.parse_args()
    VERBOSE = args.verbose

    # --- Check for piped input ---
    if sys.stdin.isatty():
        print("Error: No iCalendar data piped to stdin.", file=sys.stderr)
        parser.print_help(sys.stderr)
        sys.exit(1)

    vprint("Filter-iCal starting...")
    vprint(
        f"Raw arguments: from='{args.from_date_str}', to='{args.to_date_str}', verbose={args.verbose}"
    )

    # --- Determine filter range ---
    # Default for --from is 1970-01-01 00:00:00 local time
    default_from_datetime_local = datetime(1970, 1, 1, 0, 0, 0, tzinfo=tzlocal())
    # Default for --to is Dec 31, 9999, 23:59:59.999999 local time
    default_to_datetime_local = datetime(9999, 12, 31, 23, 59, 59, 999999, tzinfo=tzlocal())

    # args.from_date_str and args.to_date_str are datetime.date objects if specified, or None,
    #   get_boundary_datetime_utc handles these cases correctly
    # If 'now' was used, args.from_date_str/args.to_date_str will be today's date,
    #   the get_boundary_datetime_utc will then use 00:00:00 or 23:59:59 of that "now" date

    from_utc = get_boundary_datetime_utc(
        args.from_date_str,
        is_end_date=False,
        default_datetime_local=default_from_datetime_local,
    )
    to_utc = get_boundary_datetime_utc(
        args.to_date_str, is_end_date=True, default_datetime_local=default_to_datetime_local
    )

    vprint(f"Filtering effective from (UTC): {from_utc.isoformat()}")
    vprint(f"Filtering effective to (UTC):   {to_utc.isoformat()}")

    # --- Read and parse iCalendar data from stdin ---
    try:
        ical_data = sys.stdin.buffer.read()
        if not ical_data:
            print(
                "Warning: Empty input from stdin. No output will be generated.",
                file=sys.stderr,
            )
            empty_cal = Calendar()
            empty_cal.add("prodid", "-//FilteriCal Script//Empty Output//EN")
            empty_cal.add("version", "2.0")
            sys.stdout.buffer.write(empty_cal.to_ical())
            sys.exit(0)
        original_cal = Calendar.from_ical(ical_data)
    except Exception as e:
        print(
            f"Error: Could not parse iCalendar data from stdin. Details: {e}", file=sys.stderr
        )
        sys.exit(1)

    vprint(
        f"Successfully parsed iCalendar data. Found {len(original_cal.subcomponents)} top-level components."
    )

    # --- Create new calendar for filtered entries ---
    filtered_cal = Calendar()

    for key, value in original_cal.items():
        if not isinstance(value, list) or not (value and isinstance(value[0], Calendar)):
            if key.upper() in ("PRODID", "VERSION") and original_cal.get(key):
                filtered_cal.add(key.lower(), original_cal.get(key))
            elif key.upper() not in ("BEGIN", "END", "VERSION", "PRODID"):
                filtered_cal.add(key, value)

    if not filtered_cal.get("prodid"):
        filtered_cal.add("prodid", "-//FilteriCal Script//EN")
    if not filtered_cal.get("version"):
        filtered_cal.add("version", "2.0")

    for component in original_cal.walk():
        if component.name == "VTIMEZONE":
            filtered_cal.add_component(component)
            vprint(f"Copied VTIMEZONE: {component.get('tzid')}")

    # --- Filter components ---
    event_types_to_filter = ("VEVENT", "VTODO", "VJOURNAL", "VFREEBUSY")
    included_count = 0
    processed_count = 0

    for component in original_cal.walk():
        if component.name in event_types_to_filter:
            processed_count += 1
            vprint(
                f"\nProcessing component: {component.name} (UID: {component.get('uid', 'N/A')})"
            )

            event_relevant_utc, field_name_used = get_event_relevant_date_utc(component)

            if event_relevant_utc and field_name_used:
                vprint(
                    f"  Using field '{field_name_used}' with UTC value: {event_relevant_utc.isoformat()}"
                )
                if from_utc <= event_relevant_utc <= to_utc:
                    filtered_cal.add_component(component)
                    included_count += 1
                    vprint("  Component INCLUDED in output.")
                else:
                    vprint("  Component EXCLUDED (date out of range).")
            else:
                vprint(
                    "  Warning: Component EXCLUDED as no suitable date could be extracted for filtering."
                )
        elif component.name not in ("VCALENDAR", "VTIMEZONE"):
            vprint(
                f"Skipping component of type {component.name} as it's not in filterable types or already handled."
            )

    vprint(f"\nFiltering complete. Processed {processed_count} filterable components.")
    vprint(f"Included {included_count} components in the output.")

    # --- Output filtered iCalendar data to stdout ---
    try:
        output_bytes = filtered_cal.to_ical()
        sys.stdout.buffer.write(output_bytes)
    except Exception as e:
        print(
            f"Error: Could not serialize filtered iCalendar data. Details: {e}",
            file=sys.stderr,
        )
        sys.exit(1)

    vprint("Filter-iCal finished.")


if __name__ == "__main__":
    main()
