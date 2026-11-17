# Nexus upload kit – Threat Assessment 0.5.0 beta

Everything the Nexus "Add mod" form asks for, in the order it asks.

## 1. Mod details

| Field | Value |
|---|---|
| Name | Threat Assessment - Tactical Police and Jurisdiction Overhaul |
| Author | allykatz1990 |
| Version | 0.5.0 beta |
| Category | Gameplay |
| Language | English |
| Adult content | No |

**Summary** (the short line under the title, 350 characters max):

> NCPD acts like the underfunded, understaffed department it is. Petty crime is ignored, witnesses must finish their call, 3 stars brings a containment perimeter, corporations take over in their districts, Barghest runs Dogtown and Pacifica gets no police. Every feature is a setting.

**Description:** paste `docs/nexus-description.txt` (BBCode) into the description box.

## 2. Media

- Primary image: `banner.jpg` (in your Downloads folder and the GitHub repo).
- Second image: `features.jpg` (GitHub repo).
- Gameplay screenshots or one of your video clips help a lot: the perimeter with cars parked on
  the ring, and the corporate handover.

## 3. Files

| Field | Value |
|---|---|
| File | `ThreatAssessment_v0.5beta.zip` (Downloads folder) |
| File name | Threat Assessment 0.5.0 beta |
| Version | 0.5.0 beta |
| Category | Main files |
| Description | First public beta. Install with Vortex or copy the r6 folder into the game folder. |

The zip installs to `r6\scripts\ThreatAssessment\`. The readme, changelog, testing guide, license
and compatibility notes are inside that folder, so nothing lands in the game's root.

## 4. Requirements

Nexus mods (add these under "Nexus requirements"):

| Mod | Nexus ID | Note |
|---|---|---|
| redscript | 1511 | Required |
| TweakXL | 4197 | Required: response size per star |
| Codeware | 7780 | Required: corporate squads, patrols, pause key |
| Mod Settings | 4885 | Optional: settings menu |
| Mod Configuration Menu | 31640 | Optional: settings menu (either this or Mod Settings) |
| Cyber Engine Tweaks | 107 | Optional: debug log and the voice test command |

DLC: Phantom Liberty is optional. Without it, the Barghest response in Dogtown and any Phantom Liberty
units are skipped automatically.

## 5. Permissions and credits

Choose open permissions. The mod is GPL-3.0, which allows anyone to share, change and redistribute
it, as long as anything built from it stays open source under the same license.

| Permission | Setting |
|---|---|
| Upload to other sites | Yes |
| Modify and release | Yes, under GPL-3.0 |
| Convert to other games | Yes, under GPL-3.0 |
| Use assets in other mods | Yes, under GPL-3.0 |
| Use assets in paid mods | No (GPL-3.0 source must stay available) |
| Donation points | Your choice |

Extra permission text:

> Licensed under GPL-3.0: https://github.com/allykatz1990/threatassessment. You may share, modify and
> redistribute it, but anything built from it must stay open source under GPL-3.0 with credit.

Credits text:

> Ideas (no code) from: NCPD and MaxTac Spawn Tweak, Someone Call The Police, Stealth Prevention, Law
> Enforcement Overhaul, NCPD Prevention Police Enhancement, Eyes on V, NCPD Bribe (Ghxst Protocol),
> NCPD Duty Expansion, Vehicle Theft and Stock Market Economy Overhaul, No immediately police
> reinforcements, No Police Dispatch, Lore-Accurate Adam Smasher, Night City Alive. Code written
> with AI assistance (Claude).

## 6. Tags

Gameplay, NCPD, Police, Wanted Level, Combat, AI, Immersion, Lore Friendly, Phantom Liberty,
Overhaul.

## 7. GitHub release (do this first, so the Nexus page can link to it)

On https://github.com/allykatz1990/threatassessment/releases/new:

- Tag: `v0.5.0-beta` (create on publish, target `main`)
- Title: `Threat Assessment 0.5.0 beta`
- Tick "Set as a pre-release"
- Attach `ThreatAssessment_v0.5beta.zip`
- Notes: paste the 0.5.0 beta section of `CHANGELOG.md`, with this line above it:

> First public beta. Requires redscript, TweakXL and Codeware. Install with Vortex or copy the `r6`
> folder into the game folder. Testing guide: TESTING.md.

## 8. Before you click publish

- [ ] Pacifica: cross in with stars and check the heat clears after 15 seconds and the Dogtown
      checkpoint opens.
- [ ] One mission with police or corporate fighting, to confirm the mod stays out of the way.
- [ ] Debug log default: it is on by default for the beta, so testers can send logs. Leave it on,
      or switch the default off for a quieter release.
