// Threat Assessment - Tactical Police & Jurisdiction Overhaul - officer voice lines
// Copyright (C) 2026 the Threat Assessment authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// One event per moment in a police encounter. Each event has a list of the game's own voice-line
// context names; the engine plays them in the speaking officer's own voiceset. A name an officer's
// voiceset lacks plays silently with no error, so every attempt is written to the debug log
// (event, line, officer) and in-game testing tells us which lines police actually have.
//
// To add or swap lines, edit NCPDHVoice.Lines below. Other code (and later integrations) triggers
// a line with NCPDHVoice.Play(system, event, speaker), passing null to let the nearest officer speak.

enum NCPDHVoiceEvent {
  Warning = 0,        // before the first star: a cop tells V to stop (hook ready, used by witness work later)
  PerimeterSet = 1,   // the 3-star ring forms
  Standoff = 2,       // every so often while the ring holds
  AttackInRing = 3,   // V hits police while the ring holds
  BreakOut = 4,       // V breaks through the ring
  Flee = 5,           // a low-rank officer runs
  EliteEnter = 6,     // MaxTac (later: corpo elite squads) moves inside the ring
  GiveUp = 7,         // heat drops to zero
  Calling = 8         // a witness starts phoning NCPD
}

public abstract class NCPDHVoice {

  public static func Index(e: NCPDHVoiceEvent) -> Int32 {
    switch e {
      case NCPDHVoiceEvent.Warning: return 0;
      case NCPDHVoiceEvent.PerimeterSet: return 1;
      case NCPDHVoiceEvent.Standoff: return 2;
      case NCPDHVoiceEvent.AttackInRing: return 3;
      case NCPDHVoiceEvent.BreakOut: return 4;
      case NCPDHVoiceEvent.Flee: return 5;
      case NCPDHVoiceEvent.EliteEnter: return 6;
      case NCPDHVoiceEvent.GiveUp: return 7;
      case NCPDHVoiceEvent.Calling: return 8;
    }
    return 0;
  }

  public static func FromIndex(i: Int32) -> NCPDHVoiceEvent {
    switch i {
      case 1: return NCPDHVoiceEvent.PerimeterSet;
      case 2: return NCPDHVoiceEvent.Standoff;
      case 3: return NCPDHVoiceEvent.AttackInRing;
      case 4: return NCPDHVoiceEvent.BreakOut;
      case 5: return NCPDHVoiceEvent.Flee;
      case 6: return NCPDHVoiceEvent.EliteEnter;
      case 7: return NCPDHVoiceEvent.GiveUp;
      case 8: return NCPDHVoiceEvent.Calling;
    }
    return NCPDHVoiceEvent.Warning;
  }

  public static func Name(e: NCPDHVoiceEvent) -> String {
    switch e {
      case NCPDHVoiceEvent.Warning: return "Warning";
      case NCPDHVoiceEvent.PerimeterSet: return "PerimeterSet";
      case NCPDHVoiceEvent.Standoff: return "Standoff";
      case NCPDHVoiceEvent.AttackInRing: return "AttackInRing";
      case NCPDHVoiceEvent.BreakOut: return "BreakOut";
      case NCPDHVoiceEvent.Flee: return "Flee";
      case NCPDHVoiceEvent.EliteEnter: return "EliteEnter";
      case NCPDHVoiceEvent.GiveUp: return "GiveUp";
      case NCPDHVoiceEvent.Calling: return "Calling";
    }
    return "?";
  }

  public static func Lines(e: NCPDHVoiceEvent) -> array<CName> {
    let l: array<CName>;
    switch e {
      case NCPDHVoiceEvent.Warning:
        ArrayPush(l, n"rep_ask_to_holster");
        ArrayPush(l, n"rep_final_warning");
        break;
      case NCPDHVoiceEvent.PerimeterSet:
        ArrayPush(l, n"enemy_warning");
        ArrayPush(l, n"danger");
        ArrayPush(l, n"start_combat");
        break;
      case NCPDHVoiceEvent.Standoff:
        ArrayPush(l, n"enemy_warning");
        ArrayPush(l, n"danger");
        break;
      case NCPDHVoiceEvent.AttackInRing:
        ArrayPush(l, n"combat_target_hit");
        ArrayPush(l, n"start_combat");
        break;
      case NCPDHVoiceEvent.BreakOut:
        ArrayPush(l, n"combat_target_sight_lost");
        ArrayPush(l, n"stlh_search");
        break;
      case NCPDHVoiceEvent.Flee:
        ArrayPush(l, n"fear_run");
        ArrayPush(l, n"fear_beg");
        break;
      case NCPDHVoiceEvent.EliteEnter:
        ArrayPush(l, n"elite_warning");
        ArrayPush(l, n"stlh_call");
        break;
      case NCPDHVoiceEvent.GiveUp:
        ArrayPush(l, n"combat_ended");
        ArrayPush(l, n"stlh_patrol_back");
        break;
      case NCPDHVoiceEvent.Calling:
        ArrayPush(l, n"phone_start");
        break;
    }
    return l;
  }

  public static func Play(sys: ref<NCPDHSystem>, e: NCPDHVoiceEvent, speaker: wref<ScriptedPuppet>) -> Void {
    if !IsDefined(sys) || !sys.Config().voice {
      return;
    }
    let now = sys.Now();
    if now - sys.VoiceLastTime(e) < sys.Config().voiceCooldown {
      return;
    }
    let who = speaker;
    if !IsDefined(who) {
      who = NCPDHVoice.NearestSpeaker(sys);
    }
    if !IsDefined(who) {
      sys.Log(s"Voice \(NCPDHVoice.Name(e)): no officer near enough to speak");
      return;
    }
    let lines = NCPDHVoice.Lines(e);
    if ArraySize(lines) == 0 {
      return;
    }
    let line = lines[RandRange(0, ArraySize(lines))];
    GameObject.PlayVoiceOver(who, line, n"ThreatAssessment");
    sys.SetVoiceLastTime(e, now);
    sys.Log(s"Voice \(NCPDHVoice.Name(e)): \(NameToString(line)) by \(EntityID.ToDebugString(who.GetEntityID())) (\(TDBID.ToStringDEBUG(who.GetRecordID())))");
  }

  // The closest police officer or corporate / Barghest unit within 60 m of V.
  public static func NearestSpeaker(sys: ref<NCPDHSystem>) -> wref<ScriptedPuppet> {
    let game = sys.GetGameInstance();
    let best = NCPDHVoice.NearestOfficer(game);
    let player = GetPlayer(game);
    if !IsDefined(player) || !IsDefined(sys.Corp()) {
      return best;
    }
    let corp = sys.Corp().Nearest(player.GetWorldPosition(), 60.0);
    if !IsDefined(corp) {
      return best;
    }
    if !IsDefined(best) {
      return corp;
    }
    let vPos = player.GetWorldPosition();
    return Vector4.Distance(corp.GetWorldPosition(), vPos) < Vector4.Distance(best.GetWorldPosition(), vPos) ? corp : best;
  }

  // The closest active police officer on foot within 60 m of V, among the units in the chase.
  public static func NearestOfficer(game: GameInstance) -> wref<ScriptedPuppet> {
    let best: wref<ScriptedPuppet>;
    let player = GetPlayer(game);
    let registry = PreventionSystem.GetAgentRegistry(game);
    if !IsDefined(player) || !IsDefined(registry) {
      return best;
    }
    let vPos = player.GetWorldPosition();
    let bestD = 60.0;
    let agents = registry.GetNPCList();
    let i = 0;
    while i < ArraySize(agents) {
      let agent = agents[i];
      i += 1;
      if IsDefined(agent) && IsDefined(agent.unit) && agent.unit.IsActive() && !VehicleComponent.IsMountedToVehicle(game, agent.unit) {
        let d = Vector4.Distance(agent.unit.GetWorldPosition(), vPos);
        if d < bestD {
          bestD = d;
          best = agent.unit;
        }
      }
    }
    return best;
  }
}
