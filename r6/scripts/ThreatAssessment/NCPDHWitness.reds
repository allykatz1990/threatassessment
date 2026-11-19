// Threat Assessment - Tactical Police & Jurisdiction Overhaul - witness call-ins
// Copyright (C) 2026 the Threat Assessment authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// In the base game a frightened civilian's "call the police" step reports V instantly. Here the
// call takes time. If the caller is killed or knocked out before it goes through, nobody comes.
// Whether a witness calls at all depends on the district: people in rich districts call, people in
// poor ones mostly don't. Calls about crimes the petty filter ignored are not made.
//
// Only calls made while there is no heat are delayed. Once the police are already chasing V, calls
// go straight through as in the base game. Other witness reports (stolen police cars, hacks) are
// not touched.

public class NCPDHCall {
  public let callerID: EntityID;
  public let started: Float;
  public let duration: Float;
  public let crimePos: Vector4;
}

public class NCPDHCallTick extends DelayCallback {
  public let sys: wref<NCPDHSystem>;
  public let token: Int32;

  public func Call() -> Void {
    if IsDefined(this.sys) {
      this.sys.Witness().Tick(this.sys, this.token);
    }
  }
}

public class NCPDHWitness {
  private let m_calls: array<ref<NCPDHCall>>;
  private let m_token: Int32;
  private let m_ticking: Bool;
  private let m_lastCaller: wref<ScriptedPuppet>;
  private let m_lastCallerAt: Float;

  public func NoteCaller(sys: ref<NCPDHSystem>, caller: wref<ScriptedPuppet>) -> Void {
    this.m_lastCaller = caller;
    this.m_lastCallerAt = sys.Now();
  }

  // A witness report reached the police. If it came from a civilian's call a moment ago and V is
  // not wanted yet, hold it back and start a timed call instead. Returns true if taken over.
  public func TakeOver(sys: ref<NCPDHSystem>, ps: ref<PreventionSystem>, crimePos: Vector4) -> Bool {
    if !sys.Config().witnessCalls || sys.WitnessPassing() || ps.IsChasingPlayer() || !sys.Active(ps) {
      return false;
    }
    // Compatibility (0.6.0): another mod may decide what starts a chase (NCPDHCompat.reds). Then
    // the call goes straight to the base game, where that mod handles it.
    if !sys.CompatOurs(NCPDHCompatArea.ChaseStart, ps) {
      return false;
    }
    if !IsDefined(this.m_lastCaller) || sys.Now() - this.m_lastCallerAt > 1.5 {
      return false;   // not a civilian's phone call (stolen police car, hack, script...)
    }
    let caller = this.m_lastCaller;
    this.m_lastCaller = null;
    this.OnCall(sys, ps, caller, crimePos);
    return true;
  }

  // Starts a timed call (or decides the witness won't call). The report is made later, if at all.
  public func OnCall(sys: ref<NCPDHSystem>, ps: ref<PreventionSystem>, caller: wref<ScriptedPuppet>, crimePos: Vector4) -> Void {
    let cfg = sys.Config();
    let game = sys.GetGameInstance();
    if !IsDefined(caller) {
      PreventionSystem.CrimeWitnessRequestToPreventionSystem(game, crimePos);
      return;
    }
    let id = caller.GetEntityID();
    if sys.ShouldIgnoreWitness(ps) {
      sys.Log("Witness saw only petty crime: no call");
      return;
    }
    if this.IsCalling(id) || ArraySize(this.m_calls) >= 5 {
      return;
    }
    let chance = NCPDHWitness.DistrictChance(cfg, ps);
    if RandRange(0, 100) >= chance {
      sys.Log(s"Witness decides not to call NCPD (\(chance)% in this district)");
      return;
    }
    let call = new NCPDHCall();
    call.callerID = id;
    call.started = sys.Now();
    call.duration = cfg.callSeconds;
    call.crimePos = crimePos;
    let first = ArraySize(this.m_calls) == 0;
    ArrayPush(this.m_calls, call);
    sys.Log(s"Witness \(EntityID.ToDebugString(id)) is calling NCPD: \(cfg.callSeconds) s to stop them (\(chance)% chance in this district)");
    NCPDHVoice.Play(sys, NCPDHVoiceEvent.Calling, caller);
    if first && cfg.callWarning {
      NCPDHWitness.Message(game, "A witness is calling NCPD");
    }
    this.EnsureTicking(sys);
  }

  public func IsCalling(id: EntityID) -> Bool {
    let i = 0;
    while i < ArraySize(this.m_calls) {
      if Equals(this.m_calls[i].callerID, id) {
        return true;
      }
      i += 1;
    }
    return false;
  }

  private func EnsureTicking(sys: ref<NCPDHSystem>) -> Void {
    if this.m_ticking {
      return;
    }
    this.m_token += 1;
    let cb = new NCPDHCallTick();
    cb.sys = sys;
    cb.token = this.m_token;
    GameInstance.GetDelaySystem(sys.GetGameInstance()).DelayCallback(cb, 0.5, false);
    this.m_ticking = true;
  }

  public func Tick(sys: ref<NCPDHSystem>, token: Int32) -> Void {
    if token != this.m_token {
      return;
    }
    this.m_ticking = false;
    let game = sys.GetGameInstance();
    let ps = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
    if !IsDefined(ps) || ps.IsChasingPlayer() || !sys.Active(ps) {
      // Already being chased (or the mod is off / a quest took over): pending calls don't matter.
      ArrayClear(this.m_calls);
      return;
    }
    let now = sys.Now();
    let i = ArraySize(this.m_calls) - 1;
    while i >= 0 {
      let call = this.m_calls[i];
      let caller = GameInstance.FindEntityByID(game, call.callerID) as ScriptedPuppet;
      if !IsDefined(caller) || !caller.IsActive() {
        sys.Log(s"Call cut off: witness \(EntityID.ToDebugString(call.callerID)) was stopped");
        ArrayErase(this.m_calls, i);
        if ArraySize(this.m_calls) == 0 && sys.Config().callWarning {
          NCPDHWitness.Message(game, "The call to NCPD was cut off");
        }
      } else {
        if now - call.started >= call.duration {
          sys.Log(s"Call went through: witness \(EntityID.ToDebugString(call.callerID)) reported V to NCPD");
          ArrayClear(this.m_calls);
          sys.AllowWitness();
          PreventionSystem.CrimeWitnessRequestToPreventionSystem(game, call.crimePos);
          if sys.Config().callWarning {
            NCPDHWitness.Message(game, "NCPD has been called");
          }
          return;
        }
      }
      i -= 1;
    }
    if ArraySize(this.m_calls) > 0 {
      this.EnsureTicking(sys);
    }
  }

  // ---------------------------------------------------------------- district willingness
  public static func DistrictChance(cfg: ref<NCPDHConfig>, ps: ref<PreventionSystem>) -> Int32 {
    if cfg.pacificaNoPolice && NCPDHCorp.InDistrict(ps, gamedataDistrict.Pacifica) {
      return 0;   // nobody in Pacifica expects NCPD to answer
    }
    let district = ps.GetCurrentDistrict();
    if !IsDefined(district) || !IsDefined(district.GetDistrictRecord()) {
      return cfg.callChanceMid;
    }
    let rec: wref<District_Record> = district.GetDistrictRecord();
    let depth = 0;
    while IsDefined(rec) && depth < 4 {
      let tier = NCPDHWitness.Wealth(rec.Type());
      if tier == 3 {
        return cfg.callChanceRich;
      }
      if tier == 1 {
        return cfg.callChancePoor;
      }
      if tier == 2 {
        return cfg.callChanceMid;
      }
      rec = rec.ParentDistrict();
      depth += 1;
    }
    return cfg.callChanceMid;
  }

  // 3 rich, 2 middle, 1 poor for the district V is in.
  public static func WealthTier(ps: ref<PreventionSystem>) -> Int32 {
    let district = ps.GetCurrentDistrict();
    if !IsDefined(district) || !IsDefined(district.GetDistrictRecord()) {
      return 2;
    }
    let rec: wref<District_Record> = district.GetDistrictRecord();
    let depth = 0;
    while IsDefined(rec) && depth < 4 {
      let tier = NCPDHWitness.Wealth(rec.Type());
      if tier > 0 {
        return tier;
      }
      rec = rec.ParentDistrict();
      depth += 1;
    }
    return 2;
  }

  // 3 rich, 2 middle, 1 poor, 0 unknown (look at the parent district).
  private static func Wealth(t: gamedataDistrict) -> Int32 {
    switch t {
      case gamedataDistrict.CityCenter:
      case gamedataDistrict.CorpoPlaza:
      case gamedataDistrict.Downtown:
      case gamedataDistrict.Westbrook:
      case gamedataDistrict.CharterHill:
      case gamedataDistrict.NorthOaks:
      case gamedataDistrict.JapanTown:
        return 3;
      case gamedataDistrict.Watson:
      case gamedataDistrict.Heywood:
        return 2;
      case gamedataDistrict.SantoDomingo:
      case gamedataDistrict.Arroyo:
      case gamedataDistrict.RanchoCoronado:
      case gamedataDistrict.Pacifica:
      case gamedataDistrict.Coastview:
      case gamedataDistrict.WestWindEstate:
      case gamedataDistrict.Badlands:
      case gamedataDistrict.NorthBadlands:
      case gamedataDistrict.SouthBadlands:
      case gamedataDistrict.MorroRock:
      case gamedataDistrict.Dogtown:
        return 1;
    }
    return 0;
  }

  // duration added in 0.6.0 for longer messages (compatibility notice); left out it is 3 seconds.
  public static func Message(game: GameInstance, text: String, opt duration: Float) -> Void {
    let msg: SimpleScreenMessage;
    msg.isShown = true;
    msg.duration = duration > 0.0 ? duration : 3.0;
    msg.message = text;
    GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_Notifications).SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(msg), true);
  }
}

// ---------------------------------------------------------------- hooks
// The civilian's call step always runs (other mods, e.g. They Will Remember, wrap it too and may
// stop it). We only remember who is calling. If the call really goes out to the police, the
// report arrives at PreventionSystem.OnCrimeWitnessRequest (NCPDHHooks.reds), where TakeOver()
// turns it into a timed call by that caller.

@wrapMethod(CallPolice)
protected func Activate(context: ScriptExecutionContext) -> Void {
  let owner = ScriptExecutionContext.GetOwner(context) as ScriptedPuppet;
  if IsDefined(owner) {
    let sys = NCPDHSystem.Get(owner.GetGame());
    if IsDefined(sys) {
      sys.Witness().NoteCaller(sys, owner);
    }
  }
  wrappedMethod(context);
}
