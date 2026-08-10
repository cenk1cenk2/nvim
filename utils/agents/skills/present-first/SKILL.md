---
name: present-first
description: present-first Toggle the draft-and-present posture that gates skills which write - off with "just write it" or "skip the gates", back on with the slash form. The posture already rides along with every writing skill; load this only to change its state. Not for presenting a single change, which the writing skill handles itself.
references:
  - ../references/present-first.md
  - ../references/mode-toggle.md
argumentHint: '[on|off]'
---

## Present-First Toggle

The posture, its approval conditions, and what survives being switched off are all defined in `present-first`, which arrives with this skill and with every skill that writes. Nothing needs loading for it to apply — this skill only changes its state.

## Toggle

On/off mechanics per `mode-toggle`.

- **On:** the default. Also `/present-first`, "gate the writes", "ask before writing".
- **Off:** "just write it", "skip the gates", "stop presenting", "no gates". Lasts the session.
- **Level:** none — on or off.
- **Survives disengage:** nothing. Posture only; spawns nothing and writes nothing itself.
- Layers under every other mode and never turns one on or off.

Acknowledge in one line which state is now active, and name what `present-first` still gates when switching off — destructive steps and any skill's own stricter rule are not covered by the toggle.
