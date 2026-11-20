#!/usr/bin/env bash
set -euo pipefail

tag="${1:?Usage: scripts/package-release.sh vX.Y.Z [output-directory] [git-ref]}"
output="${2:-.}"
ref="${3:-HEAD}"
repo="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
component="delonghi_daedalus"
package="$component.zip"

if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z]+([.-][0-9A-Za-z]+)*)?$ ]]; then
    echo "Release tag must be vX.Y.Z or vX.Y.Z-suffix" >&2
    exit 1
fi

mkdir -p "$output"
temporary="$(mktemp -d "$output/.daedalus-release.XXXXXX")"
trap 'rm -rf "$temporary"' EXIT

# Archive the commit, so local test output cannot enter the asset.
git -C "$repo" archive --format=tar "$ref" -- "custom_components/$component" > "$temporary/component.tar"
git -C "$repo" show "$ref:hacs.json" > "$temporary/hacs.json"
git -C "$repo" show "$ref:LICENSE" > "$temporary/LICENSE"
python3 - "$temporary" "$tag" "$component" "$package" <<'PYZIP'
import json
import sys
import tarfile
import zipfile
from datetime import UTC, datetime
from pathlib import Path, PurePosixPath

directory = Path(sys.argv[1])
tag, domain, package = sys.argv[2:]
hacs = json.loads((directory / "hacs.json").read_text())
if hacs.get("zip_release") is not True or hacs.get("filename") != package:
    raise SystemExit(f"hacs.json must name the {package} release asset")

prefix = PurePosixPath("custom_components", domain)
with tarfile.open(directory / "component.tar") as tree, zipfile.ZipFile(directory / package, "w") as released:
    for member in tree.getmembers():
        if member.isdir():
            continue
        filename = PurePosixPath(member.name).relative_to(prefix)
        if "__pycache__" in filename.parts or filename.match("*.bak-*") or filename.suffix == ".pyc":
            continue
        if not member.isfile():
            raise SystemExit(f"Unexpected release file type: {filename}")
        timestamp = datetime.fromtimestamp(member.mtime, UTC).timetuple()[:6]
        info = zipfile.ZipInfo(filename.as_posix(), timestamp)
        info.external_attr = (0o100000 | member.mode) << 16
        released.writestr(info, tree.extractfile(member).read(), compress_type=zipfile.ZIP_DEFLATED)
    # Use the same Git archive timestamp as the component members.
    manifest_mtime = tree.getmember((prefix / "manifest.json").as_posix()).mtime
    notice = zipfile.ZipInfo("LICENSE", datetime.fromtimestamp(manifest_mtime, UTC).timetuple()[:6])
    notice.external_attr = 0o100644 << 16
    released.writestr(notice, (directory / "LICENSE").read_bytes(), compress_type=zipfile.ZIP_DEFLATED)

with zipfile.ZipFile(directory / package) as released:
    if corrupt := released.testzip():
        raise SystemExit(f"Invalid release archive member: {corrupt}")
    manifest = json.loads(released.read("manifest.json"))
    if manifest.get("domain") != domain or f"v{manifest.get('version')}" != tag:
        raise SystemExit(f"Release manifest domain/version does not match the asset and {tag}")
    if "config_flow.py" not in released.namelist():
        raise SystemExit("Release archive must contain the component files at its root")
PYZIP

mv "$temporary/$package" "$output/$package"
