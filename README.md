# Auditory Decoding Paradigms

This repo hosts a legacy Psychtoolbox (Octave) paradigm and a PsychoPy
rewrite (2024.2.4) for Windows 10. It is organized so experimenter helpers
can run pilot sessions without digging into the code.

## Quick start (tutorial / pilot, PsychoPy)
1) Open PsychoPy (Coder).
2) Open `psychopy/decode_sound_tutorial.py`.
3) Confirm the settings at the top of the script:
   - `RUN_PROFILE = "tutorial"`
   - `FULLSCREEN = True`
   - `LPT_ADDRESS = 0x3FF8`
4) Click Run and follow the on-screen prompts.

The data file will be saved to `psychopy/data/` as a CSV.

## Structure
- `legacy_paradigm/`: original Psychtoolbox/Octave code
- `docs/`: contract, intake notes, and decisions
- `psychopy/`: PsychoPy implementation and run instructions

## For experimenter helpers
- Active button press uses the mouse.
- Participants respond to noise (catch trials) using the `space` key.
- Press `ESC` at any time to abort safely.
