import requests
import pkg_resources
from datetime import datetime
from tqdm import tqdm
import argparse

# Argument parsing
parser = argparse.ArgumentParser(description="Find obsolete Python packages.")
parser.add_argument("--years", type=int, default=2, help="Obsolete threshold in years (default: 2)")
args = parser.parse_args()
threshold_years = args.years

now = datetime.now()
headers = {"User-Agent": "find-obsolete-packages/0.1"}

installed_packages = list(pkg_resources.working_set)
obsolete_packages = []

print(f"Analyzing {len(installed_packages)} installed packages (threshold: {threshold_years} year(s))...\n")

for dist in tqdm(installed_packages, desc="Checking packages"):
    try:
        url = f"https://pypi.org/pypi/{dist.project_name}/json"
        resp = requests.get(url, headers=headers, timeout=5)
        data = resp.json()

        latest_dates = [
            datetime.strptime(file["upload_time_iso_8601"], "%Y-%m-%dT%H:%M:%S.%fZ")
            for release in data["releases"].values()
            for file in release if "upload_time_iso_8601" in file
        ]

        if not latest_dates:
            continue

        latest_date = max(latest_dates)
        delta_years = (now - latest_date).days / 365

        if delta_years >= threshold_years:
            obsolete_packages.append((dist.project_name, int(delta_years)))

    except Exception:
        continue  # Silencieux mais robuste

# Résultat
print("\n--- Results ---")
if obsolete_packages:
    print(f"Found {len(obsolete_packages)} obsolete package(s) (not updated in {threshold_years}+ years):\n")
    for name, age in sorted(obsolete_packages, key=lambda x: -x[1]):
        print(f"- {name} (last updated {age} years ago)")
else:
    print(f"No packages are obsolete (older than {threshold_years} year(s)).")
