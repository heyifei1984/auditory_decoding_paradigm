# Behavioral Contract (Draft)

This is the authoritative spec for the PsychoPy rewrite. It captures the
current legacy behavior in `legacy_paradigm/decode_sound/`.

## Scope
- Experiment name: Decode_Sound (auditory decoding)
- Target platform: Windows 10, PsychoPy 2024.2.4
- Included modes: main experiment (active/passive blocks), control blocks, training
- Display: full screen by default
- Hardware: LPT/parallel port triggers on Windows (base address 0x3FF8)
- Exclusions: legacy Linux parallel port paths must be adapted to Windows hardware

## Run profiles
- Pilot profile (initial build):
  - 1 active block, 12 trials (5 low, 5 high, 2 catch: 1 low+noise, 1 high+noise)
  - 1 passive block, 12 trials (same composition)
  - 1 control block, 5 trials (active)
  - Order: active, passive, control
- Full profile (legacy parity):
  - 10 blocks alternating [1 2 1 2 1 2 1 2 1 2], 60 trials per block
  - 4 catch trials per block (2 low+noise, 2 high+noise)

## Stimuli
- Audio stimuli:
  - Low tone: ~251.63 Hz, 0.2 s, 44.1 kHz, 30 ms linear fade in/out
  - High tone: ~523.26 Hz, 0.2 s, 44.1 kHz, 30 ms linear fade in/out
  - Catch tones: low or high mixed with white noise (same duration/envelope)
  - Volume: 0.07 relative amplitude
- Visual stimuli:
  - Fixation cross (small), then larger cross as cue
  - Instruction and block type text on a gray background
  - Blank screen during ITI
- Timing constraints:
  - Cue delay (cross small -> large): 1.2 to 1.7 s in 0.1 s steps
  - Stim onset delay after button-down: 0.1 s
  - Response window: 1.0 s after stimulus offset
  - Control cue delay: 1.1 to 1.5 s in 0.1 s steps
  - Control ITI: 1250 to 1450 ms in 50 ms steps

## Trial structure
- Phase sequence:
  - Trial start trigger
  - Fixation cross (small)
  - Cue onset (larger cross) after cue delay, cue trigger
  - Button press (active) or scheduled button-down (passive), press trigger
  - Audio stimulus onset after 0.1 s, stim trigger
  - Response window (space to indicate noise) starts after audio offset
  - ITI (blank)
- Durations and timing source:
  - Visual timing uses display frame timing; audio uses scheduled onset
  - ITI behavior:
    - If response made: wait for (response_window - RT), then next trial
    - If no response: blank screen for ~75 frames (about 1.25 s at 60 Hz)
  - Control ITI behavior:
    - Blank screen at button-down + control ITI, then fixed blank for ~75 frames
- Response windows:
  - Response required within 1.0 s; no response is allowed

## Conditions and randomization
- Factors:
  - Block type: active (1) vs passive (2)
  - Stimulus type: low, high, low+noise (catch), high+noise (catch)
  - Both low+noise and high+noise are treated as catch trials
- Levels:
  - Pilot profile: 2 experiment blocks (active then passive), 12 trials each
  - Full profile: 10 blocks, alternating [1 2 1 2 1 2 1 2 1 2], 60 trials each
  - Catch trials: 2 in pilot, 4 in full (balanced across low/high noise)
- Randomization rules:
  - Stimulus types are shuffled within each block from [low, high] and then
    catch trials replace two low and two high trials
  - Cue delays are shuffled per block from 1.2 to 1.7 s (0.1 s steps)
  - Passive blocks use a shuffled list of button delays derived from the
    immediately preceding active block; values are clamped at 2.5 s
- Counterbalancing: none (fixed block order)

## Instructions and UI
- Instruction screens:
  - Language prompt (Deutsch/English) at experiment start
  - Task instruction: press space when noise is heard
  - Block-type screen at the start of each block (active/passive/control)
  - Block prompt includes block index and total for the current run, for example:
    "Block 1/6 (Active)"
  - Break screen between blocks (prompt to take a break, then "C" to continue)
- Practice or calibration:
  - Training scripts provide tone demos and short active/passive practice
  - Functional similarity is sufficient for training flow
- Feedback behavior:
  - Active trials: "Too fast" warning if button press < 0.7 s after cue

## Responses
- Input devices:
  - Active press: mouse button (or button emulating mouse press)
  - Response: keyboard space bar
  - Abort: ESC
- Valid keys or buttons:
  - `space` is the only task response
  - `ESC` aborts and cleans up
- RT rules:
  - RT measured from response window start to first key press
  - Correctness rule: respond to catch (noise) trials; withhold on non-catch
  - `response_correct` is true for catch+response, or non-catch+no response

## Triggers and event codes
- Experiment triggers (pp1):
  - Events: 1=trial start, 2=cue, 3=button press, 4=stim, 5=response
  - Low: [11..15] active, [51..55] passive
  - High: [21..25] active, [61..65] passive
  - Low catch: [71..75] active, [91..95] passive
  - High catch: [101..105] active, [111..115] passive
  - Error/finish: 201=esc, 202=too fast, 203=finished
- Control triggers (pp1):
  - Events: 1=trial start, 2=cue, 3=button press
  - Active: [121..123]
  - If no LPT port is available, trigger codes are logged but not sent

## Data logging
- Output format:
  - Per-trial MAT files and per-subject MAT files
- Required fields (main experiment trial files):
  - `trial_num`, `block_num`, `stim_type`, `trial_type`, `catch_trial`, `freq`
  - `trial_start`, `cross_on`, `cue_start`, `button_down`
  - `stim1_on`, `stim1_off`, `stim_duration`, `real_stim_delay`
  - `response_key`, `RT`, `response_made`, `response_correct`
- Additional timing fields for PsychoPy logs:
  - planned vs actual times for cue, button-down, stimulus onset/offset
  - audio device latency if available
- Control trial fields:
  - `trial_num`, `block_num`, `trial_type`, `trial_start`
  - `cross_on`, `cue_start`, `button_down`, `button_up`, `button_time`
  - `control_iti`, `control_iti_planned`
- File naming:
  - Trials: `sub<id>_block<block>_trial<trial>.mat`
  - Subject: `subject<id>.mat`
  - Control trials: `sub<id>_block<block>_trial<trial>_CONTROL.mat`
  - Control subject: `subject<id>_CONTROL.mat`

## Error handling
- Missing responses:
  - No response within 1.0 s sets `response_made = false`
- Invalid inputs:
  - Button press < 0.7 s after cue triggers warning and repeats trial
- Slow inputs:
  - If no button press within 4.0 s after cue, show a \"too slow\" prompt and repeat the trial
- Abort behavior:
  - ESC stops the experiment and closes PTB audio/screen

## Acceptance criteria
- Behavioral equivalence to legacy:
  - Same block count/order and trial count
  - Same cue delay distribution and catch trial insertion
  - Same response window and ITI behavior
- Pilot profile acceptance:
  - 1 active block (12 trials: 5 low, 5 high, 2 catch)
  - 1 passive block (12 trials: 5 low, 5 high, 2 catch)
  - 1 control block (5 trials)
- Timing tolerance:
  - Audio onset scheduled within 1 frame of target time
  - Visual flips aligned within 1 frame of schedule
- Data parity:
  - All fields above recorded with matching semantics
