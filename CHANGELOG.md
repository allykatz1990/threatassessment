# Changelog

## 0.6.0 beta

Automatic compatibility checks.

- New settings category **Compatibility**. When the game starts, the mod looks for other police
  mods that do the same job as parts of it and lets them handle that job. Each overlapping job has
  a dropdown: **Automatic** (the default; follows the check), **Threat Assessment** (always use
  this mod's version) or **Other mod** (never use this mod's version). A master switch,
  "Automatic compatibility checks", turns the detection off; then every Automatic job runs this
  mod's version. The feature switches in the other categories still apply on top.
- First mod checked: **NCPD Duty Expansion** (1.11). With it installed, Automatic hands it:
  - **Starting a chase** (petty crime filter, witness calls about petty crime, timed witness
    calls), in every district where its crime system is on. It blocks the base game's own chase
    start there and uses its own witness reports, so this mod's filter and calls had nothing to act
    on. Checked live per district with its own settings (its Dogtown and Badlands modes, and its
    rule that the base game runs until The Rescue is done).
  - **Search time**: it sets its own, shortens it for NCPD donors and keeps Sticky Heat afterwards.
  - **Heat at the Dogtown border**: it carries heat across as Sticky Heat on purpose. Set this to
    Threat Assessment to keep the border a hard line; the mod then also puts Duty Expansion's
    Sticky Heat on the far side back to what it was before you crossed.
- A message a few seconds after loading lists what was handed over (setting "Show what was handed
  over"). The debug log lists every decision; the CET `Report()` command prints them too.
- New defaults from testing: perimeter radius 50 m (was 30), 5 major crimes for 4 stars (was 2),
  10 major crimes for 5 stars (was 3). Saved settings are kept; use the menu's Defaults button to
  pick up the new values.
- Detection happens when the scripts compile, so there is no dependency on the other mod, and
  adding or removing it takes effect on the next game start.

## 0.5.1 beta

Packaging only, no gameplay changes.

- The readme, license, changelog, testing guide and compatibility notes now carry the mod's name
  (`README-ThreatAssessment.md`, `LICENSE-ThreatAssessment.txt` and so on), so they can't clash
  with another mod's files in Vortex

## 0.5.0 beta

First public beta.

- Petty crime filter, with witness calls about petty crime ignored
- Witness call-ins: callers must finish a 10-second call, willingness by district wealth
- Fast ramp to 3 stars, plateau at 3, major crimes for 4 and 5
- Response size per star (thin at 1-2, big at 3-4), slower dispatch at low stars
- District wealth scaling: rich districts faster and bigger, poor ones thinner and slower
- Police go to the crime scene at 1-2 stars
- Fewer police cars in traffic and officers on foot patrol
- Longer searches (game clock or real time)
- 3-star perimeter: ring follows V, cover, cars park on the ring, heat freeze, breakout, low-rank
  officers flee, only MaxTac and heavy units go in at 5 stars; checked twice a second
- Corporate jurisdictions: Arasaka, Militech, Kang Tao take over at 3-4 stars in their districts,
  one corporation per chase, matching police numbers; NCPD back at 5 with MaxTac
- Corporations protect their own: attacking their guards in the city brings a squad at any heat
- Dogtown: Barghest instead of NCPD, heat stops at the border both ways
- Pacifica: no police; heat clears after 15 s there, so the Dogtown checkpoint opens
- Optical camo respected
- Officer and corporate voice lines, with a CET command to test every line
- Quest safety: quest-controlled police untouched, quest characters never ordered or counted, pause
  key (F7)
- Every feature in the settings menu (Mod Settings / Mod Configuration Menu)
