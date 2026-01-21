#!/usr/bin/env python3
"""
Decode_Sound tutorial (pilot) implementation for PsychoPy 2024.2.4.

Run this file inside PsychoPy (Coder) or from a PsychoPy-enabled Python
environment. This script is a minimal, user-friendly version for tutorial
testing with LPT triggers on Windows.
"""

from __future__ import annotations

import csv
import os
import random
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np
from psychopy import core, event, gui, sound, visual

try:
    from psychopy import parallel
except Exception:
    parallel = None


# -----------------------------
# User-facing configuration
# -----------------------------
RUN_PROFILE = "tutorial"  # "tutorial" or "full"
USE_TRIGGERS = True
LPT_ADDRESS = 0x3FF8
DATA_DIR = Path("psychopy/data")
FULLSCREEN = True
DEFAULT_LANG = "English"

# Timing (seconds)
CUE_DELAYS = [1.2, 1.3, 1.4, 1.5, 1.6, 1.7]
CONTROL_CUE_DELAYS = [1.1, 1.2, 1.3, 1.4, 1.5]
STIM_DELAY = 0.1
RESPONSE_WINDOW = 1.0
TOO_FAST_THRESHOLD = 0.7
FIXED_ITI_FRAMES = 75

# Audio
SAMPLE_RATE = 44100
SOUND_DUR = 0.2
FADE_DUR = 0.03
BEEP_VOL = 0.07

LOW_FREQ = 251.63
HIGH_FREQ = 523.26

# Control timing (ms)
CONTROL_ITI_MS = list(range(1250, 1451, 50))


# -----------------------------
# Trigger mapping
# -----------------------------
EXP_TRIGGERS = {
    "low": {"active": [11, 12, 13, 14, 15], "passive": [51, 52, 53, 54, 55]},
    "high": {"active": [21, 22, 23, 24, 25], "passive": [61, 62, 63, 64, 65]},
    "low_noise": {
        "active": [71, 72, 73, 74, 75],
        "passive": [91, 92, 93, 94, 95],
    },
    "high_noise": {
        "active": [101, 102, 103, 104, 105],
        "passive": [111, 112, 113, 114, 115],
    },
}

CONTROL_TRIGGERS = {"active": [121, 122, 123]}

TRIG_ESC = 201
TRIG_TOO_FAST = 202
TRIG_FINISH = 203


# -----------------------------
# Helpers
# -----------------------------
@dataclass
class TrialResult:
    data: Dict[str, object]


def make_tone(freq: float, noise: bool) -> np.ndarray:
    t = np.arange(0, SOUND_DUR, 1.0 / SAMPLE_RATE)
    tone = np.sin(2 * np.pi * freq * t)
    if noise:
        rng = np.random.default_rng()
        tone = tone + rng.normal(0, 1.0, size=len(tone))
    n_fade = max(1, int(FADE_DUR * SAMPLE_RATE))
    fade_in = np.linspace(0, 1, n_fade)
    fade_out = np.linspace(1, 0, n_fade)
    steady = np.ones(len(tone) - 2 * n_fade)
    envelope = np.concatenate([fade_in, steady, fade_out])
    tone = tone * envelope
    tone = tone.astype(np.float32)
    return np.column_stack([tone, tone])


def build_sounds() -> Dict[str, sound.Sound]:
    low = make_tone(LOW_FREQ, noise=False)
    high = make_tone(HIGH_FREQ, noise=False)
    low_noise = make_tone(LOW_FREQ, noise=True)
    high_noise = make_tone(HIGH_FREQ, noise=True)

    sounds = {
        "low": sound.Sound(value=low, sampleRate=SAMPLE_RATE, stereo=True),
        "high": sound.Sound(value=high, sampleRate=SAMPLE_RATE, stereo=True),
        "low_noise": sound.Sound(value=low_noise, sampleRate=SAMPLE_RATE, stereo=True),
        "high_noise": sound.Sound(value=high_noise, sampleRate=SAMPLE_RATE, stereo=True),
    }
    for s in sounds.values():
        s.setVolume(BEEP_VOL)
    return sounds


class TriggerPort:
    def __init__(self, use_triggers: bool, address: int):
        self.port = None
        self.enabled = False
        if use_triggers and parallel is not None:
            try:
                self.port = parallel.ParallelPort(address=address)
                self.enabled = True
            except Exception:
                self.port = None
                self.enabled = False

    def send(self, code: int):
        if not self.enabled:
            return
        self.port.setData(code)
        core.wait(0.01)
        self.port.setData(0)


def exp_trigger_code(block_type: str, stim_type: str, event_id: int) -> int:
    return EXP_TRIGGERS[stim_type][block_type][event_id - 1]


def control_trigger_code(block_type: str, event_id: int) -> int:
    return CONTROL_TRIGGERS[block_type][event_id - 1]


def show_text(win: visual.Window, text: str, wait_keys: bool = True):
    stim = visual.TextStim(win, text=text, color="black", height=0.05, wrapWidth=1.4)
    stim.draw()
    win.flip()
    if wait_keys:
        event.waitKeys()


def wait_with_abort(clock: core.Clock, duration: float):
    end_time = clock.getTime() + duration
    while clock.getTime() < end_time:
        if "escape" in event.getKeys(["escape"]):
            raise KeyboardInterrupt
        core.wait(0.01)


def wait_for_mouse_press(
    mouse: event.Mouse, clock: core.Clock, min_delay: float, trigger_port: TriggerPort
) -> Tuple[float, float, bool]:
    mouse.clickReset()
    while True:
        if "escape" in event.getKeys(["escape"]):
            raise KeyboardInterrupt
        if mouse.getPressed()[0]:
            button_down = clock.getTime()
            return button_down, button_down, True
        core.wait(0.001)


def get_language() -> str:
    dlg = gui.Dlg(title="Decode_Sound")
    dlg.addText("Select language")
    dlg.addField("Language", choices=["English", "Deutsch"], initial=DEFAULT_LANG)
    result = dlg.show()
    if dlg.OK:
        return result[0]
    raise KeyboardInterrupt


def get_participant_info() -> Dict[str, str]:
    info = {"participant": "", "session": "1"}
    dlg = gui.DlgFromDict(info, title="Participant Info")
    if not dlg.OK:
        raise KeyboardInterrupt
    return info


def build_trials_tutorial() -> Dict[str, List[str]]:
    base = ["low"] * 5 + ["high"] * 5 + ["low_noise"] + ["high_noise"]
    active = base[:]
    passive = base[:]
    random.shuffle(active)
    random.shuffle(passive)
    return {"active": active, "passive": passive}


def build_trials_full() -> List[str]:
    stim_types = ["low"] * 30 + ["high"] * 30
    random.shuffle(stim_types)
    low_idx = [i for i, s in enumerate(stim_types) if s == "low"]
    high_idx = [i for i, s in enumerate(stim_types) if s == "high"]
    random.shuffle(low_idx)
    random.shuffle(high_idx)
    for i in low_idx[:2]:
        stim_types[i] = "low_noise"
    for i in high_idx[:2]:
        stim_types[i] = "high_noise"
    return stim_types


def main():
    random.seed()
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    try:
        lang = get_language()
        info = get_participant_info()
    except KeyboardInterrupt:
        return

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    subject_id = info["participant"] or "unknown"
    data_file = DATA_DIR / f"sub{subject_id}_{RUN_PROFILE}_{timestamp}.csv"

    win = visual.Window(
        size=[1280, 720],
        fullscr=FULLSCREEN,
        color=[0.4, 0.4, 0.4],
        colorSpace="rgb",
        units="height",
    )
    win.mouseVisible = False

    clock = core.Clock()
    triggers = TriggerPort(USE_TRIGGERS, LPT_ADDRESS)
    sounds = build_sounds()

    frame_rate = win.getActualFrameRate() or 60.0
    iti_duration = FIXED_ITI_FRAMES / frame_rate

    if lang == "Deutsch":
        intro_text = "Dies ist eine Anleitungssitzung."
        task_text = "Druecke die Leertaste, wenn du das Rauschen hoerst."
        continue_text = "Druecke eine beliebige Taste, um fortzufahren."
        too_fast_text = "Zu schnell. Versuche es nochmal."
    else:
        intro_text = "This is an instruction session."
        task_text = "Press the space bar when you hear noise."
        continue_text = "Press any key to continue."
        too_fast_text = "Too fast. Try again."

    show_text(win, intro_text + "\n\n" + continue_text)
    show_text(win, task_text + "\n\n" + continue_text)

    results: List[TrialResult] = []

    if RUN_PROFILE in ("tutorial", "pilot"):
        blocks = [("active", 12), ("passive", 12), ("control", 5)]
        block_trials = build_trials_tutorial()
    else:
        blocks = [("active", 60), ("passive", 60)] * 5
        block_trials = {}

    total_blocks = len(blocks)
    last_active_delays: List[float] = []

    try:
        for block_index, (block_type, trial_count) in enumerate(blocks, start=1):
            block_label = f"Block {block_index}/{total_blocks} ({block_type.capitalize()})"
            show_text(win, block_label + "\n\n" + continue_text)

            if block_type in ("active", "passive"):
                if RUN_PROFILE in ("tutorial", "pilot"):
                    trial_types = block_trials[block_type][:]
                else:
                    trial_types = build_trials_full()
            else:
                trial_types = ["control"] * trial_count

            if block_type == "passive":
                passive_delays = [min(2.5, d) for d in last_active_delays]
                random.shuffle(passive_delays)
            else:
                passive_delays = []
                if block_type == "active":
                    last_active_delays = []

            for trial_index in range(1, trial_count + 1):
                valid_trial = False
                while not valid_trial:
                    stim_type = trial_types[trial_index - 1]
                    catch_trial = stim_type in ("low_noise", "high_noise")

                    trial_start = clock.getTime()
                    trigger_trial = None
                    trigger_cue = None
                    trigger_press = None
                    trigger_stim = None
                    trigger_resp = None

                    if block_type == "control":
                        trig = control_trigger_code("active", 1)
                        triggers.send(trig)
                        trigger_trial = trig
                    else:
                        trig = exp_trigger_code(block_type, stim_type, 1)
                        triggers.send(trig)
                        trigger_trial = trig

                    fixation = visual.TextStim(win, text="+", color="black", height=0.05)
                    fixation.draw()
                    win.flip()
                    cross_on = clock.getTime()

                    cue_delay = random.choice(
                        CONTROL_CUE_DELAYS if block_type == "control" else CUE_DELAYS
                    )
                    wait_with_abort(clock, cue_delay)
                    fixation.height = 0.08
                    fixation.draw()
                    win.flip()
                    cue_start = clock.getTime()

                    if block_type == "control":
                        trig = control_trigger_code("active", 2)
                        triggers.send(trig)
                        trigger_cue = trig
                    else:
                        trig = exp_trigger_code(block_type, stim_type, 2)
                        triggers.send(trig)
                        trigger_cue = trig

                    if block_type == "control":
                        mouse = event.Mouse(win=win)
                        button_down, _, _ = wait_for_mouse_press(
                            mouse, clock, TOO_FAST_THRESHOLD, triggers
                        )
                        button_delay = button_down - cue_start
                        if button_delay < TOO_FAST_THRESHOLD:
                            triggers.send(TRIG_TOO_FAST)
                            show_text(win, too_fast_text + "\n\n" + continue_text)
                            valid_trial = False
                            continue
                        trig = control_trigger_code("active", 3)
                        triggers.send(trig)
                        trigger_press = trig

                        control_iti_ms = random.choice(CONTROL_ITI_MS)
                        control_iti = control_iti_ms / 1000.0
                        wait_with_abort(clock, control_iti)

                        win.flip()
                        wait_with_abort(clock, iti_duration)

                        result = {
                            "subject_id": subject_id,
                            "run_profile": RUN_PROFILE,
                            "block_index": block_index,
                            "block_total": total_blocks,
                            "block_type": block_type,
                            "trial_index": trial_index,
                            "trial_total": trial_count,
                            "stim_type": "control",
                            "catch_trial": False,
                            "cue_delay": cue_delay,
                            "passive_delay": "",
                            "trial_start": trial_start,
                            "cross_on": cross_on,
                            "cue_start": cue_start,
                            "button_down": button_down,
                            "stim_on": "",
                            "stim_off": "",
                            "stim_duration": "",
                            "stim_delay_actual": "",
                            "response_key": "",
                            "response_made": "",
                            "response_correct": "",
                            "rt": "",
                            "iti_planned": control_iti,
                            "iti_actual": "",
                            "control_iti": control_iti,
                            "control_iti_planned": control_iti,
                            "trigger_trial": trigger_trial,
                            "trigger_cue": trigger_cue,
                            "trigger_press": trigger_press,
                            "trigger_stim": "",
                            "trigger_response": "",
                            "notes": "",
                        }
                        results.append(TrialResult(result))
                        valid_trial = True
                        continue

                    if block_type == "active":
                        mouse = event.Mouse(win=win)
                        button_down, _, _ = wait_for_mouse_press(
                            mouse, clock, TOO_FAST_THRESHOLD, triggers
                        )
                        button_delay = button_down - cue_start
                        if button_delay < TOO_FAST_THRESHOLD:
                            triggers.send(TRIG_TOO_FAST)
                            show_text(win, too_fast_text + "\n\n" + continue_text)
                            valid_trial = False
                            continue
                        trig = exp_trigger_code(block_type, stim_type, 3)
                        triggers.send(trig)
                        trigger_press = trig
                        last_active_delays.append(button_delay)
                    else:
                        target_delay = passive_delays[trial_index - 1]
                        target_time = cue_start + target_delay
                        wait_with_abort(clock, max(0, target_time - clock.getTime()))
                        button_down = clock.getTime()
                        trig = exp_trigger_code(block_type, stim_type, 3)
                        triggers.send(trig)
                        trigger_press = trig

                    target_time = button_down + STIM_DELAY
                    wait_with_abort(clock, max(0, target_time - clock.getTime()))
                    stim_on = clock.getTime()
                    sounds[stim_type].play()
                    trig = exp_trigger_code(block_type, stim_type, 4)
                    triggers.send(trig)
                    trigger_stim = trig

                    wait_with_abort(clock, SOUND_DUR)
                    stim_off = clock.getTime()

                    response_start = clock.getTime()
                    response_key = ""
                    response_made = False
                    rt = ""

                    event.clearEvents()
                    while clock.getTime() - response_start < RESPONSE_WINDOW:
                        keys = event.getKeys(["space", "escape"])
                        if "escape" in keys:
                            raise KeyboardInterrupt
                        if "space" in keys:
                            response_made = True
                            response_key = "space"
                            rt = clock.getTime() - response_start
                            trig = exp_trigger_code(block_type, stim_type, 5)
                            triggers.send(trig)
                            trigger_resp = trig
                            break
                        core.wait(0.005)

                    response_correct = (
                        (catch_trial and response_made)
                        or ((not catch_trial) and (not response_made))
                    )

                    if response_made:
                        iti_planned = max(0.0, RESPONSE_WINDOW - (rt or 0.0))
                    else:
                        iti_planned = iti_duration

                    win.flip()
                    wait_with_abort(clock, iti_planned)

                    result = {
                        "subject_id": subject_id,
                        "run_profile": RUN_PROFILE,
                        "block_index": block_index,
                        "block_total": total_blocks,
                        "block_type": block_type,
                        "trial_index": trial_index,
                        "trial_total": trial_count,
                        "stim_type": stim_type,
                        "catch_trial": catch_trial,
                        "cue_delay": cue_delay,
                        "passive_delay": "" if block_type == "active" else target_delay,
                        "trial_start": trial_start,
                        "cross_on": cross_on,
                        "cue_start": cue_start,
                        "button_down": button_down,
                        "stim_on": stim_on,
                        "stim_off": stim_off,
                        "stim_duration": SOUND_DUR,
                        "stim_delay_actual": stim_on - button_down,
                        "response_key": response_key,
                        "response_made": response_made,
                        "response_correct": response_correct,
                        "rt": rt,
                        "iti_planned": iti_planned,
                        "iti_actual": "",
                        "control_iti": "",
                        "control_iti_planned": "",
                        "trigger_trial": trigger_trial,
                        "trigger_cue": trigger_cue,
                        "trigger_press": trigger_press,
                        "trigger_stim": trigger_stim,
                        "trigger_response": trigger_resp,
                        "notes": "",
                    }
                    results.append(TrialResult(result))
                    valid_trial = True

            if block_index < total_blocks:
                if lang == "Deutsch":
                    break_text = 'Druecke "C" zum Fortfahren oder "Esc" zum Abbrechen.'
                else:
                    break_text = 'Press "C" to continue or "Esc" to abort.'
                show_text(win, break_text, wait_keys=False)
                while True:
                    keys = event.getKeys(["c", "escape"])
                    if "escape" in keys:
                        raise KeyboardInterrupt
                    if "c" in keys:
                        break
                    core.wait(0.01)

        triggers.send(TRIG_FINISH)
        if lang == "Deutsch":
            show_text(win, "Experiment beendet. Vielen Dank!", wait_keys=True)
        else:
            show_text(win, "Experiment finished. Thank you!", wait_keys=True)

    except KeyboardInterrupt:
        triggers.send(TRIG_ESC)
    finally:
        win.close()

    if results:
        fieldnames = list(results[0].data.keys())
        with data_file.open("w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            for row in results:
                writer.writerow(row.data)


if __name__ == "__main__":
    main()
