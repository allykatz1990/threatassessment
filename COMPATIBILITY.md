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
| `OnCrimeWitnessRequest` | Witness calls about petty crime are ignored | – |
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

Watch in testing: Cop Killer and Gang Retaliation also send move orders to NPCs in some situations.
