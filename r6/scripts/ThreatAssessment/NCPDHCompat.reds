// Threat Assessment - Tactical Police & Jurisdiction Overhaul - automatic compatibility checks
// Copyright (C) 2026 the Threat Assessment authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// WHAT THIS FILE DOES
// Some other police mods do the same job as parts of Threat Assessment. Running both versions of
// the same job at once either does nothing (one mod blocks the path the other one uses) or fights
// (each undoes the other). This file finds those mods and, per overlapping job ("area"), decides
// which mod handles it. The player can override every decision in Mod Settings > Compatibility.
//
// HOW DETECTION WORKS
// Detection happens when redscript compiles the scripts at game start, with @if(ModuleExists(...)).
// Each check below comes in two versions; the compiler keeps the one that matches what is
// installed and throws the other away. That means:
//   - No hard dependency: Threat Assessment compiles and runs with or without the other mod.
//   - Code that touches the other mod's fields and methods only exists when that mod exists, so it
//     can never fail to compile on a PC without it.
//   - Installing or removing the other mod takes effect on the next game start (scripts recompile).
//
// THE AREAS (see NCPDHCompatArea) and why each one overlaps
//   ChaseStart     petty crime filter, petty witness calls, timed witness calls. Decides whether
//                  something V did with no stars starts a chase.
//   Search         "Police keep searching longer". Decides how long grey stars last.
//   DogtownBorder  "Heat stops at the Dogtown border". Clears heat when V crosses the border.
//
// MODS CHECKED SO FAR
//   NCPD Duty Expansion 1.11 (Nexus 21547, module "NCPDExpansion"), checked from its files on
//   2026-11-19:
//   - ChaseStart: its wrap of PreventionSystem.HeatPipeline returns without calling the base game
//     while the heat is 0, in every district where its own crime system is on (all of Night City
//     after The Rescue; Dogtown and the Badlands by its settings). It starts chases from its own
//     witness and victim reports instead (ReportingSystem.reds, ChangeHeatStage). So the base
//     game's crime score, which Threat Assessment's petty filter edits, never starts a chase there,
//     and a witness call Threat Assessment times out would be thrown away when it goes through.
//     Checked per district at run time with its own settings (DutyOwnsChaseStart below).
//   - Search: it replaces PreventionSystem.StartSearchingTimerRequest and shortens grey stars for
//     players who donate to NCPD on its NetPage; its Sticky Heat already keeps the police's memory
//     after the stars go. Threat Assessment's minimum search would cancel what the donation bought.
//   - DogtownBorder: its Sticky Heat deliberately carries heat across district borders, and its
//     wrap of PreventionSystem.execInstructionSafe turns heat that Threat Assessment clears at the
//     border into Sticky Heat. When the player chooses Threat Assessment for this area anyway,
//     ForgetCarriedHeat below puts the other side's Sticky Heat back to what it was before V
//     crossed, so the border really does stop the heat.
//
// ADDING ANOTHER MOD LATER
//   1. Find a module name the mod declares ("module Something" at the top of one of its .reds).
//   2. Add a pair of NCPDHCompat_<Mod>Installed functions with @if(ModuleExists("Something")).
//   3. In NCPDHCompat.Conflict, return true for each area that mod also handles.
//   4. Add its name to NCPDHCompat.ConflictingMods and a row to COMPATIBILITY.md.

// The player's choice for one area, shown as a dropdown in Mod Settings.
enum NCPDHCompatChoice {
  Auto = 0,              // Threat Assessment's version unless a mod that does the same job is found
  ThreatAssessment = 1,  // always Threat Assessment's version (its own switch still applies)
  OtherMod = 2           // never Threat Assessment's version, whatever is installed
}

// The overlapping jobs. Numbers are only used in the log.
enum NCPDHCompatArea {
  ChaseStart = 0,
  Search = 1,
  DogtownBorder = 2
}

// ================================================================ compile-time detection
// NCPD Duty Expansion declares the module "NCPDExpansion" (Util.reds, PhoneService.reds, ...).

@if(ModuleExists("NCPDExpansion"))
public func NCPDHCompat_DutyExpansionInstalled() -> Bool {
  return true;
}

@if(!ModuleExists("NCPDExpansion"))
public func NCPDHCompat_DutyExpansionInstalled() -> Bool {
  return false;
}

// True when NCPD Duty Expansion's crime system decides whether a chase starts where V is now.
// Mirrors its HeatPipeline wrap: it blocks the base game at 0 stars when the district is set to
// "none" (no heat at all) or when its new reactions are used there (which it also switches off
// until The Rescue is done). Both checks are its own public config methods, so its settings menu
// (Dogtown / Badlands modes) is followed live.
@if(ModuleExists("NCPDExpansion"))
public func NCPDHCompat_DutyOwnsChaseStart(ps: ref<PreventionSystem>) -> Bool {
  if !IsDefined(ps) || !IsDefined(ps.m_dutyConfig) {
    // Its config is attached when a save loads. Without it, its wrap falls through to the base
    // game, so Threat Assessment's filter is the one that works.
    return false;
  }
  let area = ps.m_currentStickyDistrict;
  return ps.m_dutyConfig.UseNewPreventionReaction(area) || ps.m_dutyConfig.DisableNewAndVanillaPreventionReaction(area);
}

@if(!ModuleExists("NCPDExpansion"))
public func NCPDHCompat_DutyOwnsChaseStart(ps: ref<PreventionSystem>) -> Bool {
  return false;
}

// NCPD Duty Expansion keeps one Sticky Heat level per area: 1 Night City, 2 Dogtown, 3 Badlands
// (its StickyDistrict enum). These three read and write it through its own public methods.

// Sticky Heat level (0-5) it holds for an area. 0 without the mod.
@if(ModuleExists("NCPDExpansion"))
public func NCPDHCompat_DutyStickyLevel(ps: ref<PreventionSystem>, area: Int32) -> Int32 {
  if !IsDefined(ps) || !IsDefined(ps.m_dutyConfig) || area < 1 || area > 3 {
    return 0;
  }
  return ps.GetStickyHeatStageInt(IntEnum<StickyDistrict>(area));
}

@if(!ModuleExists("NCPDExpansion"))
public func NCPDHCompat_DutyStickyLevel(ps: ref<PreventionSystem>, area: Int32) -> Int32 {
  return 0;
}

// The area V is in now, by its own district rules (1-3). 0 without the mod.
@if(ModuleExists("NCPDExpansion"))
public func NCPDHCompat_DutyCurrentArea(ps: ref<PreventionSystem>) -> Int32 {
  if !IsDefined(ps) {
    return 0;
  }
  return EnumInt(ps.GetStickyDistrict());
}

@if(!ModuleExists("NCPDExpansion"))
public func NCPDHCompat_DutyCurrentArea(ps: ref<PreventionSystem>) -> Int32 {
  return 0;
}

// Sets an area's Sticky Heat back to a level. StoreStickyHeatStage is the method the mod itself
// uses for this (it also refreshes its HUD and restarts its fade timer).
@if(ModuleExists("NCPDExpansion"))
public func NCPDHCompat_DutySetStickyLevel(ps: ref<PreventionSystem>, area: Int32, level: Int32) -> Void {
  if !IsDefined(ps) || !IsDefined(ps.m_dutyConfig) || area < 1 || area > 3 {
    return;
  }
  ps.StoreStickyHeatStage(IntEnum<StickyDistrict>(area), Max(level, 0), true, false);
}

@if(!ModuleExists("NCPDExpansion"))
public func NCPDHCompat_DutySetStickyLevel(ps: ref<PreventionSystem>, area: Int32, level: Int32) -> Void {}

// ================================================================ decisions

// Runs ForgetCarriedHeat once more shortly after the border clear, in case the other mod's own
// district update lands a moment after ours.
public class NCPDHCompatBorderCallback extends DelayCallback {
  public let sys: wref<NCPDHSystem>;
  public func Call() -> Void {
    if IsDefined(this.sys) {
      this.sys.Compat().ForgetCarriedHeat(this.sys, true);
    }
  }
}

// Shows the startup notice a few seconds after a save loads, once the HUD is up.
public class NCPDHCompatNoticeCallback extends DelayCallback {
  public let sys: wref<NCPDHSystem>;
  public func Call() -> Void {
    if IsDefined(this.sys) {
      this.sys.Compat().Announce(this.sys);
    }
  }
}

public class NCPDHCompat {
  // Sticky Heat snapshot from before V crossed the Dogtown border (index 1-3, see above).
  private let m_stickyBefore: array<Int32>;
  // Area V crossed into, waiting for ForgetCarriedHeat. 0 when nothing is pending.
  private let m_borderTarget: Int32;

  public func Init() -> Void {
    ArrayClear(this.m_stickyBefore);
    let i = 0;
    while i < 4 {
      ArrayPush(this.m_stickyBefore, 0);
      i += 1;
    }
    this.m_borderTarget = 0;
  }

  // ---------------------------------------------------------------- detection summary

  // True when an installed mod does the same job as this area. ps may be null; then district-
  // dependent checks assume the other mod is active (used for the startup notice).
  public static func Conflict(area: NCPDHCompatArea, ps: ref<PreventionSystem>) -> Bool {
    if NCPDHCompat_DutyExpansionInstalled() {
      switch area {
        case NCPDHCompatArea.ChaseStart:
          return !IsDefined(ps) || NCPDHCompat_DutyOwnsChaseStart(ps);
        case NCPDHCompatArea.Search:
          return true;
        case NCPDHCompatArea.DogtownBorder:
          return true;
      }
    }
    return false;
  }

  // Names of the installed mods that overlap, for the log and the notice.
  public static func ConflictingMods() -> String {
    let names = "";
    if NCPDHCompat_DutyExpansionInstalled() {
      names = "NCPD Duty Expansion";
    }
    return names;
  }

  public static func AreaName(area: NCPDHCompatArea) -> String {
    switch area {
      case NCPDHCompatArea.ChaseStart:
        return "starting chases (petty crime filter, witness calls)";
      case NCPDHCompatArea.Search:
        return "search time";
      case NCPDHCompatArea.DogtownBorder:
        return "heat at the Dogtown border";
    }
    return "?";
  }

  public static func Choice(cfg: ref<NCPDHConfig>, area: NCPDHCompatArea) -> NCPDHCompatChoice {
    switch area {
      case NCPDHCompatArea.ChaseStart:
        return cfg.compatChaseStart;
      case NCPDHCompatArea.Search:
        return cfg.compatSearch;
      case NCPDHCompatArea.DogtownBorder:
        return cfg.compatDogtownBorder;
    }
    return NCPDHCompatChoice.Auto;
  }

  // THE decision: does Threat Assessment run its own version of this area right now?
  // The feature's own on/off switch is checked separately by the caller, so "Threat Assessment"
  // here means "allowed to run", not "forced on".
  //   Threat Assessment       -> yes
  //   Other mod               -> no
  //   Automatic               -> yes, unless automatic checks are on and a conflict is found
  public static func Ours(cfg: ref<NCPDHConfig>, area: NCPDHCompatArea, ps: ref<PreventionSystem>) -> Bool {
    let choice = NCPDHCompat.Choice(cfg, area);
    if Equals(choice, NCPDHCompatChoice.ThreatAssessment) {
      return true;
    }
    if Equals(choice, NCPDHCompatChoice.OtherMod) {
      return false;
    }
    if !cfg.autoCompat {
      return true;
    }
    return !NCPDHCompat.Conflict(area, ps);
  }

  // ---------------------------------------------------------------- startup report

  // Writes the decisions to the log and, if anything was handed over, shows one on-screen line.
  public func Announce(sys: ref<NCPDHSystem>) -> Void {
    let cfg = sys.Config();
    let mods = NCPDHCompat.ConflictingMods();
    if StrLen(mods) == 0 {
      sys.Log("Compatibility: no overlapping police mods found");
      return;
    }
    // ps null: report the general case (the chase-start check also varies by district at run time).
    let handed = "";
    let i = 0;
    while i < 3 {
      let area = IntEnum<NCPDHCompatArea>(i);
      let ours = NCPDHCompat.Ours(cfg, area, null);
      let how = Equals(NCPDHCompat.Choice(cfg, area), NCPDHCompatChoice.Auto) ? "automatic" : "set by you";
      let who = ours ? "Threat Assessment" : mods;
      sys.Log(s"Compatibility: \(NCPDHCompat.AreaName(area)) -> \(who) (\(how))");
      if !ours {
        handed = StrLen(handed) == 0 ? NCPDHCompat.AreaName(area) : s"\(handed), \(NCPDHCompat.AreaName(area))";
      }
      i += 1;
    }
    if StrLen(handed) > 0 && cfg.compatNotice {
      NCPDHWitness.Message(sys.GetGameInstance(), s"Threat Assessment: \(mods) handles \(handed). Change in Mod Settings > Compatibility.", 8.0);
    }
  }

  public func ScheduleAnnounce(sys: ref<NCPDHSystem>) -> Void {
    let cb = new NCPDHCompatNoticeCallback();
    cb.sys = sys;
    GameInstance.GetDelaySystem(sys.GetGameInstance()).DelayCallback(cb, 10.0, false);
  }

  // ---------------------------------------------------------------- Dogtown border with Sticky Heat

  // Called every tick while V has heat and is still on the side of the border where it was
  // earned. Remembers the other mod's Sticky Heat for every area so a crossing can be undone.
  public func SnapshotSticky(ps: ref<PreventionSystem>) -> Void {
    if !NCPDHCompat_DutyExpansionInstalled() {
      return;
    }
    if ArraySize(this.m_stickyBefore) < 4 {
      this.Init();
    }
    let a = 1;
    while a <= 3 {
      this.m_stickyBefore[a] = NCPDHCompat_DutyStickyLevel(ps, a);
      a += 1;
    }
  }

  // Called right after Threat Assessment clears the heat at the Dogtown border (only when the
  // player runs Threat Assessment's border rule). The other mod has by now copied the chase into
  // Sticky Heat for the area V crossed into; put that area back to its level from before.
  // The area V came from keeps its Sticky Heat: the police there still remember V.
  public func OnBorderCleared(sys: ref<NCPDHSystem>, ps: ref<PreventionSystem>) -> Void {
    if !NCPDHCompat_DutyExpansionInstalled() {
      return;
    }
    this.m_borderTarget = NCPDHCompat_DutyCurrentArea(ps);
    this.ForgetCarriedHeat(sys, false);
    // Once more a moment later, in case its district update comes after ours.
    let cb = new NCPDHCompatBorderCallback();
    cb.sys = sys;
    GameInstance.GetDelaySystem(sys.GetGameInstance()).DelayCallback(cb, 1.5, false);
  }

  // last: true on the delayed second pass, which also ends the pending border job.
  public func ForgetCarriedHeat(sys: ref<NCPDHSystem>, last: Bool) -> Void {
    let area = this.m_borderTarget;
    if last {
      this.m_borderTarget = 0;
    }
    if area < 1 || area > 3 || ArraySize(this.m_stickyBefore) < 4 {
      return;
    }
    let ps = GameInstance.GetScriptableSystemsContainer(sys.GetGameInstance()).Get(n"PreventionSystem") as PreventionSystem;
    let now = NCPDHCompat_DutyStickyLevel(ps, area);
    let before = this.m_stickyBefore[area];
    if now > before {
      NCPDHCompat_DutySetStickyLevel(ps, area, before);
      sys.Log(s"Compatibility: NCPD Duty Expansion carried the chase over the Dogtown border as Sticky Heat \(now); set back to \(before)");
    }
  }
}
