#!/usr/bin/env python3

import os
import sys
import shutil
import subprocess
from pathlib import Path


def get_path_entries():
    raw_path = os.environ.get("PATH", "")
    return [
        entry.strip().strip('"')
        for entry in raw_path.split(os.pathsep)
        if entry.strip()
    ]


def normalize_path(path):
    try:
        return os.path.normcase(
            os.path.abspath(os.path.expanduser(path))
        )
    except Exception:
        return os.path.normcase(path)


def find_duplicates(entries):
    seen = {}
    duplicates = []

    for entry in entries:
        normalized = normalize_path(entry)

        if normalized in seen:
            duplicates.append((entry, seen[normalized]))
        else:
            seen[normalized] = entry

    return duplicates


def find_missing(entries):
    return [
        entry
        for entry in entries
        if not os.path.isdir(os.path.expanduser(entry))
    ]


def candidate_names(command):
    if os.name != "nt":
        return [command]

    _, ext = os.path.splitext(command)

    if ext:
        return [command]

    pathext = os.environ.get(
        "PATHEXT",
        ".COM;.EXE;.BAT;.CMD"
    )

    extensions = [
        ext.lower()
        for ext in pathext.split(";")
        if ext
    ]

    names = []

    for ext in extensions:
        names.append(command + ext.lower())
        names.append(command + ext.upper())

    return list(dict.fromkeys(names))


def find_all_occurrences(command, entries):
    matches = []
    seen = set()

    for entry in entries:
        directory = Path(os.path.expanduser(entry))

        try:
            if not directory.is_dir():
                continue
        except OSError:
            continue

        for name in candidate_names(command):
            candidate = directory / name

            try:
                is_candidate = candidate.is_file()
            except OSError:
                is_candidate = False

            if not is_candidate:
                continue

            if os.name != "nt" and not os.access(candidate, os.X_OK):
                continue

            normalized = normalize_path(str(candidate))

            if normalized not in seen:
                seen.add(normalized)
                matches.append(str(candidate))

    return matches


def get_version(executable):
    attempts = [
        [executable, "--version"],
        [executable, "-version"],
        [executable, "-V"],
    ]

    for command in attempts:
        try:
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=3,
                errors="replace",
            )
        except (OSError, subprocess.SubprocessError):
            continue

        output = (result.stdout or result.stderr).strip()

        if output:
            return output.splitlines()[0].strip()

    return "unknown"


def print_title():
    print(
        r"""
____________________________  __   _____________________________________________ 
___  __ \__    |__  __/__  / / /   ___  __ \_  __ \_  ____/__  __/_  __ \__  __ \
__  /_/ /_  /| |_  /  __  /_/ /    __  / / /  / / /  /    __  /  _  / / /_  /_/ /
_  ____/_  ___ |  /   _  __  /     _  /_/ // /_/ // /___  _  /   / /_/ /_  _, _/ 
/_/     /_/  |_/_/    /_/ /_/      /_____/ \____/ \____/  /_/    \____/ /_/ |_|  
"""
    )


def print_general_diagnostic(entries):
    print("PATH entries:")

    for index, entry in enumerate(entries, 1):
        status = (
            "OK"
            if os.path.isdir(os.path.expanduser(entry))
            else "MISSING"
        )

        print(f"  {index:>2}. [{status:<7}] {entry}")

    duplicates = find_duplicates(entries)
    missing = find_missing(entries)

    print("\nDiagnostic:")

    if not duplicates and not missing:
        print("  No obvious PATH issue found.")
        return

    if missing:
        print(f"  Missing directories: {len(missing)}")

        for entry in missing:
            print(f"    - {entry}")

    if duplicates:
        print(f"  Duplicate entries: {len(duplicates)}")

        for duplicate, original in duplicates:
            print(f"    - {duplicate}")
            print(f"      duplicates: {original}")


def print_command_resolution(command, entries):
    print(f"\nCommand: {command}")

    matches = find_all_occurrences(command, entries)

    if not matches:
        resolved = shutil.which(command)

        if resolved:
            matches = [resolved]

    if not matches:
        print("  No executable found in PATH.")
        return

    active = shutil.which(command)

    active_normalized = (
        normalize_path(active)
        if active
        else None
    )

    for index, executable in enumerate(matches, 1):
        marker = ""

        if active_normalized == normalize_path(executable):
            marker = " <- ACTIVE"

        print(f"  {index}. {executable}{marker}")
        print(f"     {get_version(executable)}")

    if active and all(
        normalize_path(active) != normalize_path(item)
        for item in matches
    ):
        print(f"\n  System resolution: {active}")


def main():
    print_title()

    entries = get_path_entries()

    if not entries:
        print("PATH is empty or unavailable.")
        return 1

    commands = sys.argv[1:]

    if not commands:
        print_general_diagnostic(entries)
        return 0

    for command in commands:
        print_command_resolution(command, entries)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())