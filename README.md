# counter — Parameterizable Up/Down Counter in Verilog

A simple parameterized synchronous counter that increments on `inc`, decrements on `dec`, and wraps cleanly at both ends of its `WIDTH`-bit range. Async-low reset returns the count to zero.

> Part of Roy Ayalon's Verilog learning project — designed and reviewed alongside a 34-year Verilog veteran.

---

## Features

- **Configurable `WIDTH`** — any positive integer (counter wraps at `2^WIDTH`)
- **Configurable `INC_SIZE`** / **`DEC_SIZE`** — width of the inc/dec request inputs
- **Async-low reset** — `count` returns to 0 immediately on `rst_n` falling, no clock edge required
- **Overflow / underflow wrap** — exercised explicitly in the testbench
- **Standalone** — no sibling-repo dependencies; pure self-contained Verilog

---

## Block diagram

```
                 ┌─────────────────────────────────┐
                 │            counter              │
                 │                                 │
       inc  ───►│                                 │
       dec  ───►│      ┌──────────────────┐       │
                 │      │  count_q [WIDTH] │ ────► count
       clk  ───►│      │   +1 / -1 / hold │       │
       rst_n ──►│      └──────────────────┘       │
                 │     (async reset to 0)         │
                 └─────────────────────────────────┘
```

When both `inc` and `dec` are asserted in the same cycle, `inc` wins (per the RTL's priority).

---

## Parameters

| Name       | Default | Description                                        |
|------------|---------|----------------------------------------------------|
| `WIDTH`    | 8       | Bit-width of the count (wraps at `2^WIDTH`)        |
| `INC_SIZE` | 1       | Bit-width of the `inc` request input               |
| `DEC_SIZE` | 1       | Bit-width of the `dec` request input               |

---

## Ports

| Name    | Direction | Width        | Description                                          |
|---------|-----------|--------------|------------------------------------------------------|
| `clk`   | input     | 1            | Clock                                                |
| `rst_n` | input     | 1            | Active-low **asynchronous** reset                    |
| `inc`   | input     | `INC_SIZE`   | When non-zero, count increments by 1 each cycle      |
| `dec`   | input     | `DEC_SIZE`   | When non-zero (and `inc==0`), count decrements by 1  |
| `count` | output    | `WIDTH`      | Current count value                                  |

---

## Behavior

| `rst_n` | `inc` | `dec` | Next-cycle `count`               |
|---------|-------|-------|----------------------------------|
| 0       | x     | x     | `0` (async)                      |
| 1       | 0     | 0     | hold                             |
| 1       | 1     | 0     | `count + 1` (wraps at `2^WIDTH`) |
| 1       | 0     | 1     | `count - 1` (wraps at `0`)       |
| 1       | 1     | 1     | `count + 1` (inc has priority)   |

---

## Running the simulation

```sh
./scripts/run.sh             # compile + run
./scripts/run.sh --gtk       # compile + run + open GTKWave
./scripts/run.sh --clean     # wipe sim/ then rebuild
./scripts/run.sh --help      # usage
```

Or invoke `iverilog` directly:

```sh
iverilog -g2012 -o sim/simv rtl/counter.v tb/counter_tb.v && \
    ( cd sim && vvp simv )
```

Waveforms land in `sim/counter_tb.vcd`.

---

## Testbench summary

[tb/counter_tb.v](tb/counter_tb.v) is a self-checking testbench built in father's style. It runs six sub-tests with `WIDTH=8`:

| #  | Test                                                              | What it verifies                                |
|----|-------------------------------------------------------------------|-------------------------------------------------|
| T1 | Hold reset for several cycles                                     | `count == 0` while reset asserted               |
| T2 | Drive `inc=1` for 255 cycles                                      | Count reaches `MAX_COUNT = 0xFF`                |
| T3 | One more `inc` at MAX_COUNT                                       | Overflow wrap → `count == 0x00`                 |
| T4 | Drive `dec=1` at `count==0`                                       | Underflow wrap → `count == 0xFF`                |
| T5 | Continue `dec=1` for 255 more cycles                              | Count walks back down to `0x00`                 |
| T6 | Re-assert `rst_n=0` mid-run while incrementing                    | `count` returns to 0 asynchronously              |

End-of-test prints one of three banners:
- **`UVM TEST PASSED`** — every check matched
- **`UVM TEST FAILED`** — a count mismatch (`expected != actual`)
- **`UVM TEST ERROR`** — watchdog fired (`SIM_LENGTH = 20000` time units)

Every `@(posedge clk)` is followed by `#1` before any stimulus assignment to avoid the active-region race documented in `.claude/context/lessons-learned.md` (lesson #4).

---

## A note on the RTL

`counter.v` is the one module in the project that still uses an implicit `always @(posedge clk or negedge rst_n)` block instead of an explicit [`m_ff`](https://github.com/Roy-Ayalon/m-ff) instance. This is **intentional** — it predates the m_ff-only standard and is kept as a learning-history artifact. A future revision will migrate it to `m_ff` for consistency with the rest of the project.

---

## File layout

```
m-Counter/
├── rtl/           # synthesizable RTL
│   └── counter.v
├── tb/            # testbench
│   └── counter_tb.v
├── sim/           # simv binary + *.vcd outputs (gitignored)
├── scripts/       # run.sh — compile + run + optional GTKWave
│   └── run.sh
├── waves/         # GTKWave save files (*.gtkw)
├── spec/          # spec / requirement docs
├── README.md
└── animation_prompt.md
```

---

## Author

**Roy Ayalon** — Electrical Engineering graduate, learning Verilog through father-son design reviews.
