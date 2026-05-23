#!/usr/bin/env bash
# =============================================================================
# Compile + run the counter simulation. Optionally open GTKWave.
#
# Usage:
#   run.sh                       # compile + run
#   run.sh --gtk                 # compile + run + open GTKWave
#   run.sh --clean               # wipe sim/ before building
#   run.sh --help                # show this help
#
# Layout this script assumes:
#   m-Counter/rtl/      -> RTL sources (counter.v)
#   m-Counter/tb/       -> testbench (counter_tb.v)
#   m-Counter/sim/      -> output dir (simv + *.vcd) — gitignored
#   m-Counter/waves/    -> GTKWave save files (.gtkw)
#
# counter.v is standalone — no sibling-repo dependencies.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

SIM_DIR="$MODULE_DIR/sim"
RTL_DIR="$MODULE_DIR/rtl"
TB_DIR="$MODULE_DIR/tb"
WAVES_DIR="$MODULE_DIR/waves"

OPEN_GTK=0
CLEAN=0

usage() {
    sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --gtk)   OPEN_GTK=1; shift ;;
        --clean) CLEAN=1; shift ;;
        --help|-h) usage ;;
        *) echo "ERROR: unknown flag '$1' (try --help)" >&2; exit 2 ;;
    esac
done

TB_FILE="$TB_DIR/counter_tb.v"
GTKW_FILE="$WAVES_DIR/counter.gtkw"
VCD_FILE="$SIM_DIR/counter_tb.vcd"

SOURCES=(
    "$RTL_DIR/counter.v"
    "$TB_FILE"
)

mkdir -p "$SIM_DIR"

if (( CLEAN )); then
    echo "[run.sh] cleaning $SIM_DIR"
    rm -f "$SIM_DIR"/simv "$SIM_DIR"/*.vcd
fi

SIMV="$SIM_DIR/simv"

echo "[run.sh] compiling iverilog -> $SIMV"
( cd "$SIM_DIR" && iverilog -g2012 -o "$SIMV" "${SOURCES[@]}" )

echo "[run.sh] running vvp"
( cd "$SIM_DIR" && vvp "$SIMV" )

if (( OPEN_GTK )); then
    if [[ ! -f "$VCD_FILE" ]]; then
        echo "[run.sh] WARNING: expected VCD not found at $VCD_FILE — opening gtkwave without it"
        gtkwave "$GTKW_FILE" >/dev/null 2>&1 &
    elif [[ ! -f "$GTKW_FILE" ]]; then
        echo "[run.sh] NOTE: no save file at $GTKW_FILE — opening gtkwave with VCD only"
        gtkwave "$VCD_FILE" >/dev/null 2>&1 &
    else
        gtkwave "$VCD_FILE" "$GTKW_FILE" >/dev/null 2>&1 &
    fi
fi
