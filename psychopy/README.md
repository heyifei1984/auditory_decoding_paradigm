# PsychoPy Rewrite

This folder contains the PsychoPy 2024.2.4 implementation.

## Quick start (tutorial / pilot)
1) Open PsychoPy (Coder).
2) Open `psychopy/decode_sound_tutorial.py`.
3) At the top of the script, confirm:
   - `RUN_PROFILE = "tutorial"`
   - `FULLSCREEN = True`
   - `LPT_ADDRESS = 0x3FF8`
4) Click Run.

You will be prompted to select a language and enter the participant ID.
The script saves a CSV log to `psychopy/data/`.

## What the tutorial includes
- 1 active block (12 trials: 5 low, 5 high, 1 low+noise, 1 high+noise)
- 1 passive block (12 trials: same composition)
- 1 control block (5 trials)
- Block prompts show block index and type

## Full experiment
- Run `psychopy/decode_sound_experiment.py`
- 10 blocks alternating active/passive, 60 trials each

## Control session
- Run `psychopy/decode_sound_control.py`
- 2 blocks, 50 trials each (active only)

## Controls
- Active press: mouse button
- Catch response: `space`
- Abort: `ESC`

## Notes for experimenters
- Use full screen and close other applications.
- Verify the LPT trigger connection before running participants.
- If no LPT is available, the script automatically logs trigger codes without sending them.
