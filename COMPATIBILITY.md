# Threat Assessment – compatibility notes

Every base-game function this mod touches is wrapped (`@wrapMethod`), never replaced. No tweak
files, no archives, no REDmod.

Tweak values changed at runtime (TweakXL `SetFlat`, one value at a time, originals cached for the
session): on each `PreventionHeatTable_Record` the game uses, `maxUnitCount`, `maxUnitFallbackCount`,
`spawnedEngagedCars`, `spawnedSupportCars`, `vehicleTicketsAmount`, `vehicleSpawnCooldown`,
`vehicleTicketCooldown`. Mods that set the same values in `.yaml` / `.tweak` files still work: their
values become the base this mod scales from.

| Function (class `PreventionSystem`) | Why | Other mods on the test PC that wrap it |
|---|---|---|
| `CalculateCrimeScoreForNPC` | Petty crime filter, ramp, 3-star plateau, major-crime count | Gang Retaliation 1.4.0 (`PoliceImmunity.reds`) |
| `CalculateCrimeScoreForVehicle` | Plateau for vehicle damage | – |
| `NotifyVehicleExplosion` (static) | Destroyed police vehicles count as major crimes | – |
| `OnCrimeWitnessRequest` | Witness calls: petty ones ignored, others must finish a timed call | – |
| `CallPolice.Activate` (behavior task) | Remembers who is calling; always calls the original | They Will Remember 3.0.1 |
| `DamageSystem.ProcessLocalizedDamage` | V hitting a corporation's guards (provocation) | Weaponpunk 2077 |
| `PreventionSystem.execInstructionSafe` (called, not wrapped) | Clearing heat at the Dogtown border | – |
| `TryUpdateStarState` | Heat freeze while the perimeter holds | – |
| `ChangeHeatStage` | Tells the mod when heat changes | Cop Killer 2.42 |
| `GetDataTableForCurrentHeat` | Response size per star | – |
| `PoliceLostPlayer` | Search timing | – |
| `UpdateStarStateTo` | Search timing | – |
| `OnPreventionSearchingStatusRequest` | Police keep searching for the set time | – |

Added methods: `PreventionSystem.NCPDH_QuestFree`, `PreventionSystem.NCPDH_RaiseOneStar`.

AI orders: the perimeter sends `AIMoveToCommand`, `AIHoldPositionCommand` and `AISetCombatPresetCommand`
(cautious style, restored afterwards) to registered police units on foot, and cancels them when the
perimeter ends. Arriving police cars get an `AIVehicleDriveToPointAutonomousCommand` to a spot on the
ring and an `ExitVehicle` event for their crew. Units the game flags as quest NPCs are
never given orders.

Checked against (Vortex downloads, 2026-11-16): Cop Killer 2.42, Gang Retaliation 1.4.0,
They Will Remember 3.0.1, NCA Lite 2.3.3, Reinforcements System 1.2.1, Reinforcements Gang Vs Gang
3.1.3, Fighting Gangs Allowed, Factions Evolved 3.01, The Gangs Of Night City 7.0.1,
Enemies of Night City, Cyber Enemies 1.0.2, Lifepath Bonuses 4.3.4, NightCityTrafficOverhaul 3.05,
DynamicCityDensity 1.5, ImmersiveShootingAI, Stealthrunner, BetterStealth, CollateralDamage 2.5,
Trace Position Overhaul, Spawned NPC Post Combat Fix. None replaces a function listed above.

Roaming patrols: when the always-loaded world sector loads, the weights of police entries in the
crowd registry (`worldCommunityRegistryNode`) are scaled. Nothing is replaced, so Night City Alive's
and Night City Traffic Overhaul's edits to the same registry are kept; the scaling stacks on top.

Pause hotkey: Codeware `Input/Key` callback (keyboard only, default F7).

Corporate squads: spawned with Codeware's `DynamicEntitySystem`, tagged `ThreatAssessment` and
`ThreatAssessment.Corp`, from base-game Arasaka, Militech and Kang Tao character records (missing
records are skipped). They wait while entities tagged `TheyWillRemember.Squad` (They Will Remember)
or `GangRetaliation` (Gang Retaliation) exist, so ambushes don't stack. No code dependency on
either mod.

## Other police and wanted-level mods

Checked from each mod's files (2026-11-17) or, where marked, from its Nexus description only.
"Loads fine" means no two mods replace the same function, so redscript compiles and nothing
crashes. Whether the two together play the way you want is a different question, answered below.

| Mod | Loads with Threat Assessment | How they play together |
|---|---|---|
| Eyes on V – No Automatic Civilian Crime Reports 0.8.0 | Yes. Both only wrap; they share `OnCrimeWitnessRequest` and stack in either order. | Eyes on V blocks civilian crime reports while police aren't already chasing V, so heat only starts when police see the crime. Threat Assessment's witness calls then never reach NCPD; turning off "Witnesses have to finish the call" changes nothing. Everything else (perimeter, jurisdictions, response size, search) works as normal. |
| NCPD Prevention Police Enhancement 2.9.2 (NCPDPPE) | Yes. NCPDPPE replaces `CalculateCrimeScoreForVehicle`, `StartSearchingTimerRequest`, `OnHeatChanged` and others; Threat Assessment only wraps. The only shared functions are `CalculateCrimeScoreForNPC` and `CalculateCrimeScoreForVehicle`, and wraps stack on top of a replacement. | Both rework the whole heat system, so they overlap: Threat Assessment scales NCPDPPE's response tables again on top of NCPDPPE's own numbers, both lengthen the search, and NCPDPPE gives Pacifica its own security preset that Threat Assessment then switches off. Pick one, or keep NCPDPPE and turn off Threat Assessment's "Response size per star", "Response depends on the district" and "Police keep searching longer". Not tested in game together. |
| Law Enforcement Overhaul 3.4 | Yes. Tweak files only (district presets and spawn pools), no scripts. | Threat Assessment scales whichever response table the district uses, so Law Enforcement Overhaul's mercenaries, corporate units and Kurtz militia get the perimeter, sizing and search like NCPD does. Where the two disagree, Threat Assessment's district rules win: with "No police in Pacifica" on, Law Enforcement Overhaul's Pacifica mercenaries don't respond either; in Dogtown and the corporate districts at 3-4 stars, its units withdraw and Threat Assessment's Barghest or corporate squads come instead. To keep Law Enforcement Overhaul's version, turn off "No police in Pacifica", "NCPD stays out of Barghest turf" and set the corporate districts to Off. |
| Someone Call The Police | Not checked from files (Nexus description only). | Same idea as Threat Assessment's witness calls (one of its inspirations): witnesses must finish a call, chance by district. Running both doubles the witness handling. Use one; with Someone Call The Police installed, turn off "Witnesses have to finish the call" and "Ignore witness calls about petty crime". |
| Someone Call NCPD | Not checked from files (Nexus description only). | Covers something Threat Assessment doesn't: civilians reporting gang fights and shootouts that don't involve V. Should sit alongside it. |
| The Thin Blue Line | Not checked from files (Nexus description only). | Overlaps with officers fleeing after V's kill streak: Thin Blue Line makes NCPD retreat and drop the heat after enough kills. Both can run; expect Thin Blue Line to end some chases that Threat Assessment's perimeter would otherwise keep frozen. Not tested together. |

Watch in testing: Cop Killer and Gang Retaliation also send move orders to NPCs in some situations.
