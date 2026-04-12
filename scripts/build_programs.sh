#!/usr/bin/env bash
set -e

DISK_FILE="xfs-interface/disk_setup_s26.txt"
ROOT_DIR="$(pwd)"
DISK_DIR="$(cd "$(dirname "$DISK_FILE")" && pwd)"

awk '/^load/ { print $NF }' "$DISK_FILE" | while read -r path; do
    # Expand $HOME etc.
    eval path="$path"

    # Make path absolute relative to disk file location
    if [[ "$path" != /* ]]; then
        xsm="$DISK_DIR/$path"
    else
        xsm="$path"
    fi

    # ---------- SPL ----------
    if [[ "$xsm" == *"/spl/"* ]]; then
        src="${xsm%.xsm}.spl"
        if [[ -f "$src" ]]; then
            echo "[SPL ] $src → $xsm"
            (
              cd "$ROOT_DIR/spl" &&
              ./spl "$src"
            )
        else
            echo "[SKIP] $xsm (no .spl source)"
        fi

    # ---------- EXPL (samples only) ----------
    elif [[ "$xsm" == *"/expl/samples/"* ]]; then
        src="${xsm%.xsm}.expl"
        if [[ -f "$src" ]]; then
            echo "[EXPL] $src → $xsm"
            (
              cd "$ROOT_DIR/expl" &&
              ./expl "$src"
            )
        else
            echo "[SKIP] $xsm (no .expl source)"
        fi

    else
        echo "[SKIP] $xsm (handwritten / external)"
    fi
done
