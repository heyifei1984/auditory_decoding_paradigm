#!/usr/bin/env python3
"""
Decode_Sound control session for PsychoPy 2024.2.4.

Run this file inside PsychoPy (Coder) or from a PsychoPy-enabled Python
environment. This script implements the legacy control-only session.
"""

from __future__ import annotations

import csv
import random
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from psychopy import core, event, gui, visual

try:
    from psychopy import parallel
except Exception:
    parallel = None


# -----------------------------
# User-facing configuration
# -----------------------------
RUN_PROFILE = "control"
USE_TRIGGERS = True
LPT_ADDRESS = 0x3FF8
DATA_DIR = Path("psychopy/data")
FULLSCREEN = True
DEFAULT_LANG = "English"

# Timing (seconds)
CONTROL_CUE_DELAYS = [1.1, 1.2, 1.3, 1.4, 1.5]
TOO_FAST_THRESHOLD = 0.7
MAX_CLICK_WAIT = 4.0
FIXED_ITI_FRAMES = 75

# Control timing (ms)
CONTROL_ITI_MS = list(range(1250, 1451, 50))

# Block structure
CONTROL_BLOCKS = 2
TRIALS_PER_BLOCK = 50


# -----------------------------
# Trigger mapping
# -----------------------------
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
    mouse: event.Mouse, clock: core.Clock, timeout_s: float
) -> Tuple[Optional[float], bool]:
    mouse.clickReset()
    start_time = clock.getTime()
    while True:
        if "escape" in event.getKeys(["escape"]):
            raise KeyboardInterrupt
        if mouse.getPressed()[0]:
            return clock.getTime(), False
        if (clock.getTime() - start_time) >= timeout_s:
            return None, True
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


def balanced_list(values: List[float], total_count: int) -> List[float]:
    reps = total_count // len(values)
    remainder = total_count % len(values)
    items = values * reps + values[:remainder]
    random.shuffle(items)
    return items


def balanced_list_ms(values: List[int], total_count: int) -> List[int]:
    reps = total_count // len(values)
    remainder = total_count % len(values)
    items = values * reps + values[:remainder]
    random.shuffle(items)
    return items


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

    frame_rate = win.getActualFrameRate() or 60.0
    iti_duration = FIXED_ITI_FRAMES / frame_rate

    if lang == "Deutsch":
        task_text = "Kontrollblock: Druecke den Knopf, wenn du das Kreuz siehst."
        continue_text = "Druecke eine beliebige Taste, um fortzufahren."
        too_fast_text = "Zu schnell. Versuche es nochmal."
        too_slow_text = "Zu langsam. Bitte wiederhole den Durchgang."
        finish_text = "Kontrollsitzung beendet. Vielen Dank!"
        break_text = 'Bitte machen Sie eine Pause.\n\nDruecke "C", um fortzufahren.'
    else:
        task_text = "Control block: press the button when you see the cross."
        continue_text = "Press any key to continue."
        too_fast_text = "Too fast. Try again."
        too_slow_text = "Too slow. Please repeat the trial."
        finish_text = "Control session finished. Thank you!"
        break_text = 'Please take a break.\n\nPress "C" to continue.'

    show_text(win, task_text + "\n\n" + continue_text)

    results: List[TrialResult] = []
    total_blocks = CONTROL_BLOCKS

    try:
        for block_index in range(1, CONTROL_BLOCKS + 1):
            block_label = f"Control Block {block_index}/{total_blocks}"
            show_text(win, block_label + "\n\n" + continue_text)

            cue_delays = balanced_list(CONTROL_CUE_DELAYS, TRIALS_PER_BLOCK)
            itis_ms = balanced_list_ms(CONTROL_ITI_MS, TRIALS_PER_BLOCK)

            for trial_index in range(1, TRIALS_PER_BLOCK + 1):
                valid_trial = False
                while not valid_trial:
                    cue_delay = cue_delays[trial_index - 1]
                    control_iti = itis_ms[trial_index - 1] / 1000.0

                    trial_start = clock.getTime()
                    trigger_trial = None
                    trigger_cue = None
                    trigger_press = None

                    trig = control_trigger_code("active", 1)
                    triggers.send(trig)
                    trigger_trial = trig

                    fixation = visual.TextStim(win, text="+", color="black", height=0.05)
                    fixation.draw()
                    win.flip()
                    cross_on = clock.getTime()

                    wait_with_abort(clock, cue_delay)
                    fixation.height = 0.08
                    fixation.draw()
                    win.flip()
                    cue_start = clock.getTime()

                    trig = control_trigger_code("active", 2)
                    triggers.send(trig)
                    trigger_cue = trig

                    mouse = event.Mouse(win=win)
                    button_down, timed_out = wait_for_mouse_press(
                        mouse, clock, MAX_CLICK_WAIT
                    )
                    if timed_out:
                        show_text(win, too_slow_text + "\n\n" + continue_text)
                        valid_trial = False
                        continue
                    button_delay = button_down - cue_start
                    if button_delay < TOO_FAST_THRESHOLD:
                        triggers.send(TRIG_TOO_FAST)
                        show_text(win, too_fast_text + "\n\n" + continue_text)
                        valid_trial = False
                        continue

                    trig = control_trigger_code("active", 3)
                    triggers.send(trig)
                    trigger_press = trig

                    button_up = None
                    end_time = button_down + control_iti
                    while clock.getTime() < end_time:
                        if "escape" in event.getKeys(["escape"]):
                            raise KeyboardInterrupt
                        if not mouse.getPressed()[0]:
                            button_up = clock.getTime()
                            break
                        core.wait(0.001)

                    wait_with_abort(clock, max(0, end_time - clock.getTime()))
                    win.flip()
                    wait_with_abort(clock, iti_duration)

                    button_time = "error1" if button_up is None else button_up - button_down

                    result = {
                        "subject_id": subject_id,
                        "run_profile": RUN_PROFILE,
                        "block_index": block_index,
                        "block_total": total_blocks,
                        "block_type": "control",
                        "trial_index": trial_index,
                        "trial_total": TRIALS_PER_BLOCK,
                        "stim_type": "control",
                        "catch_trial": False,
                        "cue_delay": cue_delay,
                        "passive_delay": "",
                        "trial_start": trial_start,
                        "cross_on": cross_on,
                        "cue_start": cue_start,
                        "button_down": button_down,
                        "button_up": button_up or "",
                        "button_time": button_time,
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

            if block_index < total_blocks:
                show_text(win, break_text, wait_keys=False)
                while True:
                    keys = event.getKeys(["c", "escape"])
                    if "escape" in keys:
                        raise KeyboardInterrupt
                    if "c" in keys:
                        break
                    core.wait(0.01)

        triggers.send(TRIG_FINISH)
        show_text(win, finish_text, wait_keys=True)

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
