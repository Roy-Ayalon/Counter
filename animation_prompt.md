# Animation Prompt — counter for LinkedIn

A ready-to-paste prompt for generating a short technical animation of the `counter` module. Tested phrasing for tools like **Manim, Motion Canvas, After Effects, Runway, Sora, Kling, or a custom JS/Canvas animator**.

Use the **"Master Prompt"** below as-is. The sections after it (style guide, scene breakdown, signal table) are there in case the tool needs more structure or you want to extend the clip.

---

## Master prompt (copy-paste this)

> Create a clean, technical, ~30-second silent animation explaining how a **parameterized up/down counter** works, designed in Verilog. The animation will be posted on LinkedIn by a junior digital-design engineer (Roy Ayalon) showcasing his hardware design project.
>
> **Visual style:** minimalist engineering aesthetic. Dark navy background (#0d1b2a). Monospace font (JetBrains Mono or Fira Code). Accent colors: cyan (#00d9ff) for data / count value, green (#00ff88) for active inc / posedge, magenta (#ff5dde) for active dec, red (#ff3860) for reset and wrap moments, amber (#ffb000) for hold. Smooth easing on every move. No clutter, no excessive labels — this should look like a hardware-textbook figure that came alive.
>
> **Subject:** an 8-bit counter. Render it as a large hex/decimal display in the center of the frame, showing the current `count` value in both decimal (left) and hex (right). Above the display, show three input pins: `clk` (square wave indicator), `inc` (green LED dot), `dec` (magenta LED dot), and `rst_n` (red, active-low). On the right side, show a horizontal bar (like a thermometer) representing `count / 255` — fills with cyan as count increases. In the **top-right corner**, show a small **clock cycle counter** `CLK: N` in dim green that ticks every clock cycle.
>
> **Scene 1 — Reset (0:00–0:03).**
> `rst_n = 0`. Count display shows `0  0x00`. Cyan bar empty. Red `RESET` label pulsing on the display. Caption fades in at the top: *"counter — parameterized up/down counter"*.
>
> **Scene 2 — Count up (0:03–0:11).**
> Caption: *"inc = 1 → count increments each clock"*. `rst_n` rises. Light up `inc` (green). On every clock tick, count advances. Show it walking through `0 → 1 → 2 → ... → 254 → 255`. Use a smooth time compression: linger on values `0-3`, then fast-forward through the middle with a motion-blur sweep, then slow back down at `253, 254, 255`. The cyan bar fills as count rises. When count reaches 255, the display flashes red briefly with a small `MAX` badge.
>
> **Scene 3 — Overflow wrap (0:11–0:14).**
> Caption: *"overflow wraps to 0"*. One more clock tick with `inc=1`. The display rolls dramatically — `255 → 0` — with a red wrap-around arrow animation around the display. The cyan bar snaps from full to empty.
>
> **Scene 4 — Count down + underflow (0:14–0:22).**
> Caption: *"dec = 1 → count decrements; underflow wraps to 255"*. Turn off `inc`, light up `dec` (magenta). First clock tick: `0 → 255` with another wrap-around arrow (this is the underflow). Then count walks back down `255 → 254 → 253 → ...` using the same time compression. Stop at, say, `0`. Cyan bar drains as count falls.
>
> **Scene 5 — Async reset (0:22–0:26).**
> Caption: *"async reset → count returns to 0 immediately"*. Set `inc=1` again, let count climb a bit (`0 → 1 → 2 → 3 → 4`). Then drop `rst_n=0` **mid-clock-cycle** (between two posedges). The count snaps to `0` immediately — emphasize that this happens **without waiting for a clock edge**. Red flash on `rst_n`.
>
> **Scene 6 — Closing card (0:26–0:30).**
> Fade everything to the side. Center text:
> ```
> counter.v
> Parameterizable. Async reset.
> Wraps both ways.
> Roy Ayalon · Verilog Design
> ```
>
> **Audio:** none. Pure visual. (LinkedIn autoplays muted.)
>
> **Aspect ratio:** 1:1 square (1080×1080) — best for LinkedIn feed engagement.
>
> **Pacing:** crisp, deliberate. Clock ticks are visible. The wrap moments (both overflow and underflow) are the dramatic beats of the video — make them obvious.

---

## Optional add-ons (paste if the tool allows scene-level direction)

### Style guide

- **Background:** solid `#0d1b2a` (dark navy)
- **Grid:** subtle 1-px cyan grid at 5% opacity, behind everything
- **Font:** JetBrains Mono Bold for labels and the count display, JetBrains Mono Regular for values
- **Count display:** large 7-segment-style or monospace digits, decimal on left, hex on right
- **LED dots for inc/dec/rst_n:** small filled circles, glow when active
- **Bar (count / 255):** vertical or horizontal — 200px long, 12px tall, rounded ends, cyan fill on dark
- **Wrap-around animation:** a curved arrow that sweeps over the display in 300 ms with red→cyan gradient
- **Time compression in count-up phase:** slow at `0-3`, motion-blur sweep through `4-251`, slow at `252-255`

### Signal sequence (mirrors testbench behavior)

| Phase                  | rst_n | inc | dec | count walks through          | Note                          |
|------------------------|-------|-----|-----|------------------------------|-------------------------------|
| Reset                  | 0     | 0   | 0   | 0                             | Async reset asserted          |
| Count up               | 1     | 1   | 0   | 0 → 1 → 2 → … → 255           | T2 from testbench              |
| Overflow wrap          | 1     | 1   | 0   | 255 → 0                       | T3 — dramatic moment          |
| Underflow wrap         | 1     | 0   | 1   | 0 → 255                       | T4 — dramatic moment          |
| Count down             | 1     | 0   | 1   | 255 → 254 → … → 0             | T5                             |
| Mid-run reset          | 1→0   | 1   | 0   | counting up → 0 (async snap)  | T6                             |

Use this table to drive the animation frame-by-frame if the tool supports keyframe data.

### LinkedIn caption draft (to go with the video)

> Parameterized up/down counter in Verilog 👇
>
> 8-bit wide, async-low reset, wraps cleanly at both ends. inc=1 walks the count up; dec=1 walks it down. Hit 255 with another inc and it wraps to 0. Hit 0 with a dec and it wraps to 255.
>
> Two details I love about hardware here:
> 1. **Async reset** — the count snaps to 0 the instant `rst_n` falls, not on the next clock edge. You can see it in the waveform: no waiting.
> 2. **Wrap-around is free** — a binary counter naturally rolls over because we just keep the low `WIDTH` bits. The wrap is the absence of carry-out, not a special case.
>
> Designed alongside my father — 34 years of Verilog experience — who reviews every line.
>
> #Verilog #DigitalDesign #FPGA #HardwareEngineering #RTL

---

## Tips per tool

- **Manim (Python):** ask the model to output Manim Community Edition code. Use `DecimalNumber` for the count display and `ChangingDecimal` to animate the increment. Use `Arc` + `Arrow` for the wrap-around animation.
- **Motion Canvas (TS):** great for cycle-accurate engineering animations. Ask for `signal()` references for each input and a `Counter` component with `tween` for the display update.
- **Sora / Runway / Kling (video AI):** paste only the Master Prompt above. Skip the cycle table — these tools handle narrative pacing, not frame data. Specify "no audio" and "1:1 square."
- **After Effects:** the Master Prompt works as a brief; the scene breakdown is the storyboard.
- **Custom JS/Canvas:** feed the signal table directly as JSON.
