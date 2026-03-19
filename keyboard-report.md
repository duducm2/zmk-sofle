### Eyelash Sofle – ZMK Hardware & Firmware Specification Report

You can paste this entire report into another AI as context for searching a compatible replacement keyboard/PCB.

---

## 1. High-level Keyboard Description

- **Name**: Eyelash Sofle
- **Family**: Sofle-style split ergonomic keyboard
- **Form factor**:
  - **Split** keyboard: left and right halves (`eyelash_sofle_left`, `eyelash_sofle_right`)
  - Staggered column layout with thumb clusters (standard Sofle-style geometry)
- **Approximate matrix size**:
  - **Logical matrix**: 5 rows × 14 columns (5×14)
  - Implemented via a shared matrix transform with per-half column wiring and an offset on the right half
- **Main features (from repo)**:
  - **Wireless BLE** support
  - **USB** support on the central (left) side
  - **Split role support** (central/peripheral)
  - **Rotary encoder** (ALPS EC11 on the left half)
  - **RGB underglow** (WS2812-based strip)
  - **Backlight** driven by PWM
  - **Display** support (nice_view / nice_view_custom shield, SSD1306-type over SPI)
  - **Battery measurement** and **external power control**

---

## 2. MCU / Board Requirements

From `boards/arm/eyelash_sofle/eyelash_sofle.yaml` and defconfigs:

- **Board identity**:
  - `identifier`: `eyelash_sofle`
  - `name`: `Eyelash Sofle`
  - `type`: `mcu` (custom ZMK **board**, not just a shield)
  - ZMK board metadata (`eyelash_sofle.zmk.yml`) also marks it as `type: board`.

- **SoC / MCU**:
  - **Series**: `NRF52X`
  - **Concrete SoC**: `NRF52840_QIAA`
  - **Architecture**: `arm`
  - **RAM**: 40 KB (from board YAML `ram: 40`)
  - **Board Kconfig**: `BOARD_EYELASH_SOFLE_LEFT` / `BOARD_EYELASH_SOFLE_RIGHT` both select this SoC.

- **Required/used on-chip peripherals** (from `eyelash_sofle.yaml` and configs):
  - `adc` – for battery measurement (`zmk,battery-nrf-vddh`).
  - `usb_device` – for USB connection on the central side.
  - `ble` – for wireless connectivity and split communication.
  - `ieee802154` – supported by the MCU, but not necessarily used by the keyboard firmware.
  - `pwm` – used for LED backlight via `pwm-leds` and `pwm0`.
  - `watchdog` – supported; not specifically configured here but part of board support.
  - `gpio` – required for the keyboard matrix, encoder, external power, etc.
  - `i2c` – used for display drivers when `ZMK_DISPLAY` is enabled.
  - `spi` – used for both RGB underglow (WS2812 over SPI3) and display (nice_view over SPI0).

- **Board-level ZMK options (from `Kconfig.defconfig`)**:
  - `ZMK_SPLIT = y` – split keyboard.
  - `ZMK_SPLIT_ROLE_CENTRAL = y` when `BOARD_EYELASH_SOFLE_LEFT`.
  - `BOARD_ENABLE_DCDC = y`, `BOARD_ENABLE_DCDC_HV = y` – DCDC regulators enabled.
  - If `USB` is enabled: `USB_NRFX = y`, `USB_DEVICE_STACK = y`.

**Implication for replacement search**:  
The new board or kit should ideally be based on **nRF52840 (nRF52 series)** or an MCU with **equivalent BLE + USB capability and enough GPIOs** to drive:

- A 5×14 key matrix
- At least one RGB underglow strip (SPI-based)
- One PWM channel for backlight
- External power/battery sensing
- Optional encoder + display

---

## 3. Split & Connectivity Characteristics

From `Kconfig.defconfig`, `eyelash_sofle_left_defconfig`, `eyelash_sofle_right_defconfig`, and `eyelash_sofle.zmk.yml`:

- **Split architecture**:
  - `ZMK_SPLIT = y` indicates a proper ZMK split keyboard.
  - Sibling boards: `eyelash_sofle_left`, `eyelash_sofle_right`.

- **Roles**:
  - **Left half** (`BOARD_EYELASH_SOFLE_LEFT`):
    - Acts as **central** (host-facing).
    - `CONFIG_ZMK_USB = y` and `CONFIG_ZMK_BLE = y`.
    - Handles both USB and BLE connections to the host.
  - **Right half** (`BOARD_EYELASH_SOFLE_RIGHT`):
    - Acts as **peripheral**.
    - `CONFIG_ZMK_USB = n`, `CONFIG_ZMK_BLE = y`.
    - No USB device on the right half, BLE only.

- **Communication**:
  - Split communication is via **BLE** (no TRRS requirement implied by this board).
  - The central half manages BLE links and host connection.

**Implication for replacement search**:  
Look for **split ZMK-compatible boards or kits** where:

- At least one side supports **BLE + USB** and can act as central.
- The other side can function as a BLE peripheral.
- A BLE-based split (not necessarily wired TRRS) is acceptable or preferable.

---

## 4. Key Matrix & Layout Specifications

From `eyelash_sofle.dtsi`, `eyelash_sofle_left.dts`, `eyelash_sofle_right.dts`, `eyelash_sofle-layouts.dtsi`, and `config/eyelash_sofle.json`:

- **Logical matrix** (shared across the board):
  - Node `kscan0` is a `zmk,kscan-gpio-matrix`.
  - `diode-direction = "col2row"`.
  - **Rows**: `rows = <5>`.
  - **Columns**: `columns = <14>`.
  - `default_transform: keymap_transform_0` defines a 5×14 mapping using `RC(row,col)` across all logical keys.

- **Per-half wiring**:
  - Left DTS (`eyelash_sofle_left.dts`):
    - Defines `col-gpios` for **6 columns** on certain `gpio0` pins.
    - Reuses the common `kscan0` node from `eyelash_sofle.dtsi`.
    - Marks `left_encoder` as `status = "okay"`.
  - Right DTS (`eyelash_sofle_right.dts`):
    - Defines `col-gpios` for **7 columns** on `gpio0` pins.
    - Adds `col-offset = <7>` to `default_transform` to shift into the second half of the 14-column matrix.

- **Physical layout**:
  - `eyelash_sofle-layouts.dtsi` defines `eyelash_sofle_layout` with `keys` referencing `key_physical_attrs`, giving coordinates and rotation.
  - `config/eyelash_sofle.json` provides a layout array with `(row, col, x, y, [r, rx, ry])` for each key.
  - This layout matches a **standard Sofle-style split**: staggered columns, traditional top-row to bottom-row fingertip columns, and multi-key thumb clusters.

**Summary for search**:

- **Matrix**: 5 rows × 14 columns, diode direction **col-to-row**.
- **Form factor**: typical Sofle-inspired stagger + thumb clusters, roughly **split 60–70%** style.
- When searching, look for a Sofle or Sofle-compatible layout with **similar key count and thumb cluster design**; the exact row/column geometry should be close but does not have to be 100% identical as long as the layout is broadly Sofle.

---

## 5. GPIO Usage (High-level)

From `eyelash_sofle.dtsi`, `eyelash_sofle_left.dts`, `eyelash_sofle_right.dts`:

- **Rows**:
  - Defined in `eyelash_sofle.dtsi` on `kscan0` as `row-gpios` using:
    - `gpio0` pins: 19, 8, 12, 11
    - `gpio1` pin: 9
  - All with `(GPIO_ACTIVE_HIGH | GPIO_PULL_DOWN)`.

- **Columns**:
  - Left half: `col-gpios` on `gpio0` for 6 columns (specific pins include 3, 28, 30, 21, 23, 22).
  - Right half: `col-gpios` on `gpio0` for 7 columns (pins 22, 29, 3, 28, 30, 21, 23).
  - Total logical columns: 14 (with right side offset).

- **Non-matrix GPIO uses** (from `eyelash_sofle.dtsi`):
  - **RGB underglow**:
    - Uses `spi3` with `SPIM_MOSI` on `P1.12`.
    - `led_strip: ws2812@0` node: `worldsemi,ws2812-spi`, `chain-length = <7>`.
  - **Backlight** (`pwm0`):
    - `PWM_OUT0` on `P1.13`.
  - **External power**:
    - `ext-power` node uses `control-gpios = <&gpio0 13 GPIO_ACTIVE_HIGH>`.
  - **Display (nice_view)**:
    - `nice_view_spi` bound to `spi0`.
    - `spi0` pins: `SPIM_SCK` on `P0.20`, `SPIM_MOSI` on `P0.17`, `SPIM_MISO` on `P0.25`.
    - `cs-gpios = <&gpio0 6 GPIO_ACTIVE_HIGH>`.
  - **Encoder**:
    - `left_encoder` ALPS EC11 on `P1.10` (A) and `P1.14` (B) with pull-ups.

**Implication for replacement search**:  
You need **enough GPIOs** (or equivalent labeled pads) for:

- 5 row lines, 14 column lines.
- 1 PWM-capable pin for backlight.
- 1 data pin (SPI or GPIO) for WS2812 underglow.
- SPI interface plus chip select for the display.
- 2 pins with interrupts/pull-ups for the encoder.
- 1 pin for external power control.

The **exact pin numbers do not have to match**, but the **quantity and capabilities** (GPIO count, PWM, SPI) must.

---

## 6. Lighting & Backlight Requirements

From `eyelash_sofle.dtsi` and `config/eyelash_sofle.conf`:

- **RGB Underglow**:
  - `led_strip` node:
    - `compatible = "worldsemi,ws2812-spi"`.
    - Driven by `spi3` (`nordic,nrf-spim`), with MOSI on `P1.12`.
    - `chain-length = <7>` → 7 WS2812 LEDs (under-glow for 6 keys plus 1 extra).
    - Color mapping: `<LED_COLOR_ID_GREEN LED_COLOR_ID_RED LED_COLOR_ID_BLUE>` (standard GRB).

- **Backlight**:
  - `backlight: pwmleds` node:
    - `pwms = <&pwm0 0 PWM_MSEC(1) PWM_POLARITY_NORMAL>` – uses PWM0 channel 0 on `P1.13`.
  - Config flags in `eyelash_sofle.conf`:
    - `CONFIG_ZMK_BACKLIGHT = y`
    - `CONFIG_ZMK_BACKLIGHT_BRT_START = 100`
    - `CONFIG_ZMK_BACKLIGHT_ON_START = y`
    - `CONFIG_ZMK_BACKLIGHT_AUTO_OFF_IDLE = n`

- **ZMK RGB config flags**:
  - `CONFIG_WS2812_STRIP = y`
  - `CONFIG_ZMK_RGB_UNDERGLOW = y`
  - `CONFIG_ZMK_RGB_UNDERGLOW_EXT_POWER = y`
  - `CONFIG_ZMK_RGB_UNDERGLOW_ON_START = n`
  - `CONFIG_ZMK_RGB_UNDERGLOW_BRT_MAX = 90`
  - `CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_IDLE = y`
  - `CONFIG_ZMK_RGB_UNDERGLOW_AUTO_OFF_USB = y`
  - `CONFIG_ZMK_RGB_UNDERGLOW_HUE_START = 160`
  - `CONFIG_ZMK_RGB_UNDERGLOW_EFF_START = 3`

**Search-oriented interpretation**:

- The keyboard uses **WS2812-compatible RGB underglow**, typically via a 3-pin connection (5V, GND, data).
- It also supports **backlight** (likely per-key or zone) via a PWM channel.
- A compatible board/kit should either:
  - Provide headers/footprints for WS2812 underglow + PWM backlight, **or**
  - Have enough pins and power delivery that you can wire your own underglow and backlight similar to this setup.

---

## 7. Display / Extra Peripherals

From `build.yaml`, `Kconfig.defconfig`, and `eyelash_sofle.dtsi`:

- **Display**:
  - ZMK config: `CONFIG_ZMK_DISPLAY = y`.
  - Kconfig selects:
    - `CONFIG_I2C = y`
    - `CONFIG_SSD1306 = y`
    - LVGL-related defaults when display is present (color depth, DPI, etc.).
  - **Shields in use** (`build.yaml`):
    - `shield: nice_view` (for the left).
    - `shield: nice_view_custom` (for the right).
  - `nice_view_spi` on `spi0` with explicit SCK, MOSI, MISO, and CS pins.

- **Rotary Encoder**:
  - Node `left_encoder: encoder_left` in `eyelash_sofle.dtsi`:
    - `compatible = "alps,ec11"`.
    - `resolution = <4>`, `steps = <40>`.
    - A/B pins on `P1.10` and `P1.14` with pull-ups.
    - In left DTS, `status = "okay"` to enable it.
  - ZMK config:
    - `CONFIG_EC11 = y`
    - `CONFIG_EC11_TRIGGER_GLOBAL_THREAD = y`
    - `CONFIG_ZMK_POINTING = y` (used for scroll/mouse-like behavior via encoder).

- **Battery and Power**:
  - `vbatt` node: `compatible = "zmk,battery-nrf-vddh"`.
  - External power node `ext-power`: `zmk,ext-power-generic` with a control GPIO and `init-delay-ms`.
  - Config: `CONFIG_ZMK_EXT_POWER = y`.
  - ADC is enabled in `eyelash_sofle.dtsi`.

- **USB & BLE details**:
  - Left half: `CONFIG_ZMK_USB = y`, `CONFIG_ZMK_BLE = y`.
  - Right half: `CONFIG_ZMK_USB = n`, `CONFIG_ZMK_BLE = y`.
  - BLE transmit power: `CONFIG_BT_CTLR_TX_PWR_PLUS_8 = y` (stronger TX power).
  - NKRO: `CONFIG_ZMK_HID_REPORT_TYPE_NKRO = n` (no NKRO, standard 6KRO report).

**Search-oriented interpretation**:

A good replacement should:

- Either already support or be easily expandable to **SSD1306/nice_view-style displays**, preferably over SPI (or I²C if reconfigured).
- Offer at least **one encoder footprint** (preferably EC11-compatible) or enough spare GPIOs to add an encoder.
- Be **battery-capable** with on-board power management suitable for wireless split usage.

---

## 8. ZMK Feature Profile

From `eyelash_sofle.conf` and defconfigs:

- **Power & Sleep**:
  - `CONFIG_ZMK_IDLE_SLEEP_TIMEOUT = 3600000` ms (1 hour).
  - `CONFIG_ZMK_SLEEP = y` – general sleep support.

- **Input behavior**:
  - `CONFIG_ZMK_KSCAN_DEBOUNCE_PRESS_MS = 8`
  - `CONFIG_ZMK_KSCAN_DEBOUNCE_RELEASE_MS = 8`
  - `CONFIG_ZMK_HID_REPORT_TYPE_NKRO = n` (standard HID report, not NKRO).

- **RGB & Backlight**:
  - Full underglow and backlight support as detailed above.

- **Display**:
  - `CONFIG_ZMK_DISPLAY = y` (with SSD1306 and LVGL tuning through board Kconfig).

- **Pointing & Encoders**:
  - `CONFIG_EC11 = y`, `CONFIG_EC11_TRIGGER_GLOBAL_THREAD = y`.
  - `CONFIG_ZMK_POINTING = y` (for treating encoder as pointing device).

- **External Power & Battery**:
  - `CONFIG_ZMK_EXT_POWER = y`.
  - `zmk,battery-nrf-vddh` for reading battery voltage via ADC.

- **Connectivity & Security**:
  - BLE on both halves; USB only on central.
  - Passkey entry and bond clearing are disabled by default:
    - `CONFIG_ZMK_BLE_PASSKEY_ENTRY = n`
    - `CONFIG_ZMK_BLE_CLEAR_BONDS_ON_START = n`.

---

## 9. Search-Oriented Summary Block (for another AI)

You can give the following directly to another AI as a compact specification:

```text
Keyboard to match/approximate: "Eyelash Sofle" (custom ZMK board).

Form factor:
- Split ergonomic keyboard, Sofle-style.
- Approximate matrix: 5 rows x 14 columns, diode direction: col-to-row.
- Staggered column layout with thumb clusters; overall geometry similar to a standard Sofle.

MCU / Board:
- Based on Nordic nRF52840 (NRF52840_QIAA), ARM architecture.
- Board acts as a custom ZMK "board" (not just a shield).
- Must support: BLE, USB device, GPIO, SPI, I2C, PWM, ADC, watchdog.
- Enough GPIOs for:
  - 5 row lines + 14 column lines for matrix scanning.
  - RGB underglow data (WS2812-compatible, ~7 LEDs, typically on SPI or a single GPIO).
  - 1 PWM pin for LED backlight.
  - 2 pins for rotary encoder (EC11 style).
  - 1 pin for external power control.
  - Pins for display interface (nice_view / SSD1306-style, SPI preferred).

Split & connectivity:
- ZMK split keyboard (`ZMK_SPLIT = y`).
- Left half is central (USB + BLE); right half is peripheral (BLE only, USB disabled).
- BLE used for both host connection and split communication; no requirement for wired TRRS.

Lighting:
- RGB underglow: WS2812 or compatible LEDs, controlled via SPI (or single-wire) with about 7 LEDs.
- Backlight: PWM-driven LED backlight (per-key or zone acceptable).
- ZMK features: RGB underglow (auto-off on idle/USB, brightness and effect settings), backlight enabled and on at startup.

Display & peripherals:
- Supports nice_view / nice_view_custom display over SPI (SSD1306-compatible).
- ZMK display enabled with LVGL settings.
- One ALPS EC11 rotary encoder on the left half used as a pointing/scrolling device.
- Battery voltage sensing via ADC and external power control via GPIO.

ZMK firmware profile:
- BLE + USB on central, BLE-only on peripheral.
- Sleep after ~1 hour of inactivity.
- Debounce: ~8 ms press/release.
- NKRO disabled (standard HID reports).
- ZMK pointing, RGB underglow, backlight, display, and external power all enabled.

HARD REQUIREMENTS (must-have):
- Split keyboard form factor (two halves).
- ZMK support (either official or feasible to support as a custom board).
- BLE support on both halves; USB at least on one half.
- MCU equivalent to nRF52840 (ARM, BLE, USB, sufficient RAM/flash).
- Sufficient GPIOs for a 5x14 matrix plus RGB, backlight, encoder, display, and power control.
- Ability to connect WS2812 underglow and PWM backlight.
- At least one encoder or ability to add an EC11-style rotary encoder.
- Battery-friendly power design (for wireless split use).

NICE-TO-HAVES:
- Layout very close to standard Sofle (same column stagger and thumb cluster).
- Built-in footprints/headers for WS2812 underglow and encoder.
- Ready-made support for SSD1306/nice_view displays.
- Good documentation and existing ZMK board/shield definitions.
```

---

I’ve based all of this strictly on your repo’s ZMK board, DTS, and config files so another AI can use it as a precise search spec for a compatible Sofle or similar keyboard/PCB.
