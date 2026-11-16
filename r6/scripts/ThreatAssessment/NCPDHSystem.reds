// Threat Assessment - Tactical Police & Jurisdiction Overhaul - core system
// Copyright (C) 2026 the Threat Assessment authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// What lives here:
//   1. The crime filter: the one place that decides whether something the player did counts.
//      It only ever lowers or redirects the score the base game computed (see NCPDHHooks.reds).
//   2. Escalation: the major crimes that are the only way past the 3-star plateau.
//   3. The 3-star perimeter: a ring of officers that follows V and holds instead of rushing in.
//   4. Officers fleeing a breakout.
//   5. Voice lines for each of those moments (NCPDHVoice.reds).
//
// Quest safety: nothing here runs while a quest controls the police (see NCPDH_QuestFree in
// NCPDHHooks.reds), and units the game flags as quest NPCs are never given orders.
//
// CET console, for testing:
//   Game.GetScriptableSystemsContainer():Get("NCPDHSystem"):Report()

public class NCPDHTickCallback extends DelayCallback {
  public let sys: wref<NCPDHSystem>;
  public let token: Int32;

  public func Call() -> Void {
    if IsDefined(this.sys) {
      this.sys.OnTick(this.token);
    }
  }
}

public class NCPDHDespawnCallback extends DelayCallback {
  public let sys: wref<NCPDHSystem>;
  public let id: EntityID;

  public func Call() -> Void {
    if IsDefined(this.sys) {
      this.sys.DespawnFled(this.id);
    }
  }
}

// One officer the perimeter has given an order to.
public class NCPDHUnit {
  public let id: EntityID;
  public let cmd: ref<AICommand>;
  public let mode: Int32;     // 0 no order, 1 moving to the ring, 2 holding the ring, 3 fled, 4 free in cover band
  public let sentAt: Float;
  public let target: Vector4;
  public let presetSent: Bool;          // switched to the cautious combat style
  public let origPreset: EAICombatPreset;
  public let creeps: Int32;             // times caught inside the ring (then he is held in place)
  public let entering: Bool;            // allowed inside (MaxTac / heavy), logged once
}

// One police car the perimeter has told to park on the ring.
public class NCPDHVehicle {
  public let id: EntityID;
  public let mode: Int32;     // 1 driving to the ring, 2 parked and crew told to get out (or released)
  public let sentAt: Float;
  public let retries: Int32;
}

public class NCPDHSystem extends ScriptableSystem {
  private let m_config: ref<NCPDHConfig>;
  private let m_instanceID: Int32;

  // crime filter
  private let m_civKillTimes: array<Float>;
  private let m_lastPettyTime: Float;
  private let m_lastSeriousTime: Float;
  private let m_pendingRaise: Bool;

  // escalation
  private let m_escalationTimes: array<Float>;
  private let m_copKillsTowardEvent: Int32;
  private let m_copKillsThisChase: Int32;
  private let m_lastExplosionEvent: Float;

  // perimeter
  private let m_tickToken: Int32;
  private let m_ticking: Bool;
  private let m_lastTickTime: Float;
  private let m_perimeterOn: Bool;
  private let m_engaged: Bool;
  private let m_anchor: Vector4;
  private let m_brokenAt: Float;
  private let m_lastValidUnitTime: Float;
  private let m_units: array<ref<NCPDHUnit>>;
  private let m_corp: ref<NCPDHCorp>;
  private let m_vehicles: array<ref<NCPDHVehicle>>;
  private let m_eliteAnnounced: Bool;
  private let m_lastStandoffLine: Float;

  // search: game-clock time the police lost V, or below zero while they can see V
  private let m_searchStart: Float;
  private let m_searchStartReal: Float;

  // voice: last time each NCPDHVoiceEvent played
  private let m_voiceLast: array<Float>;

  public static func Get(game: GameInstance) -> ref<NCPDHSystem> {
    return GameInstance.GetScriptableSystemsContainer(game).Get(n"NCPDHSystem") as NCPDHSystem;
  }

  private func OnAttach() -> Void {
    this.m_instanceID = RandRange(1, 2000000000);
    this.m_corp = new NCPDHCorp();
    this.m_corp.Reset();
    this.m_lastPettyTime = -10000.0;
    this.m_lastSeriousTime = -10000.0;
    this.m_brokenAt = -10000.0;
    this.m_lastExplosionEvent = -10000.0;
    this.m_searchStart = -1.0;
    this.m_lastStandoffLine = -10000.0;
    let i = 0;
    while i < 10 {
      ArrayPush(this.m_voiceLast, -10000.0);
      i += 1;
    }
  }

  public func Config() -> ref<NCPDHConfig> {
    if !IsDefined(this.m_config) {
      this.m_config = new NCPDHConfig();
      NCPDHRegisterSettings(this.m_config);
    }
    return this.m_config;
  }

  public func Log(text: String) -> Void {
    if this.Config().debugLog {
      ModLog(n"ThreatAssessment", text);
    }
  }

  public func Now() -> Float {
    return EngineTime.ToFloat(GameInstance.GetSimTime(this.GetGameInstance()));
  }

  public static func Stage(h: EPreventionHeatStage) -> Int32 {
    switch h {
      case EPreventionHeatStage.Heat_1:
        return 1;
      case EPreventionHeatStage.Heat_2:
        return 2;
      case EPreventionHeatStage.Heat_3:
        return 3;
      case EPreventionHeatStage.Heat_4:
        return 4;
      case EPreventionHeatStage.Heat_5:
        return 5;
      default:
        return 0;
    }
  }

  private func Prevention() -> ref<PreventionSystem> {
    return GameInstance.GetScriptableSystemsContainer(this.GetGameInstance()).Get(n"PreventionSystem") as PreventionSystem;
  }

  // The mod acts only when switched on and no quest is steering the police.
  public func Active(ps: ref<PreventionSystem>) -> Bool {
    return this.Config().enabled && IsDefined(ps) && ps.NCPDH_QuestFree();
  }

  // ================================================================ crime filter
  // Called with the score the base game just added for a hit on an NPC. Returns what it should
  // add instead. Never more than the base game, except the ramp multiplier below 3 stars.
  public func AdjustNPCScore(ps: ref<PreventionSystem>, request: ref<PreventionDamageRequest>, delta: Float) -> Float {
    let cfg = this.Config();
    let stage = NCPDHSystem.Stage(ps.GetHeatStage());
    let now = this.Now();
    let explosive = Equals(request.attackType, gamedataAttackType.Explosion) || Equals(request.attackType, gamedataAttackType.PressureWave);

    if !request.isTargetPrevention {
      // ---- civilians (and anything else the base game reports that is not police)
      if stage == 0 {
        if !cfg.pettyFilter {
          return delta;
        }
        if explosive {
          // Explosions in public are not petty crime.
          this.m_lastSeriousTime = now;
          this.Log(s"Civilian hit by an explosion: counts (\(delta))");
          return delta;
        }
        if request.isTargetKilled {
          ArrayPush(this.m_civKillTimes, now);
          this.m_civKillTimes = this.Pruned(this.m_civKillTimes, now, cfg.pettyWindow);
          if ArraySize(this.m_civKillTimes) >= cfg.pettyKills {
            this.Log(s"Civilian kill \(ArraySize(this.m_civKillTimes)) of \(cfg.pettyKills) within \(cfg.pettyWindow)s: threshold tripped, police respond");
            ArrayClear(this.m_civKillTimes);
            this.m_lastSeriousTime = now;
            this.m_pendingRaise = true;
            return delta;
          }
          this.m_lastPettyTime = now;
          this.Log(s"Civilian kill \(ArraySize(this.m_civKillTimes)) of \(cfg.pettyKills): petty, ignored");
          return 0.0;
        }
        this.m_lastPettyTime = now;
        this.Log(s"Civilian hurt: petty, ignored (base game wanted \(delta))");
        return 0.0;
      }
      if stage < 3 {
        return delta * cfg.rampMultiplier;
      }
      return this.PlateauScore(delta);
    }

    // ---- police
    this.m_lastSeriousTime = now;
    if request.isTargetKilled {
      this.m_copKillsThisChase += 1;
    }
    if stage < 3 {
      return delta * cfg.rampMultiplier;
    }
    if !cfg.plateau {
      return delta;
    }
    if request.isTargetKilled {
      this.m_copKillsTowardEvent += 1;
      if this.m_copKillsTowardEvent >= cfg.copKillsPerEvent {
        this.m_copKillsTowardEvent = 0;
        this.AddEscalation(s"\(cfg.copKillsPerEvent) police killed");
      }
    }
    if explosive && cfg.explosionEvents && now - this.m_lastExplosionEvent > 3.0 {
      // One grenade hitting five officers is one major crime, not five.
      this.m_lastExplosionEvent = now;
      this.AddEscalation("explosion on police");
    }
    if this.m_perimeterOn {
      NCPDHVoice.Play(this, NCPDHVoiceEvent.AttackInRing, null);
    }
    return this.PlateauScore(delta);
  }

  // Score for vehicle damage: only the plateau applies.
  public func AdjustVehicleScore(ps: ref<PreventionSystem>, delta: Float) -> Float {
    if NCPDHSystem.Stage(ps.GetHeatStage()) >= 3 {
      return this.PlateauScore(delta);
    }
    return delta;
  }

  private func PlateauScore(delta: Float) -> Float {
    let cfg = this.Config();
    if !cfg.plateau {
      return delta;
    }
    return delta * Cast<Float>(cfg.plateauLeak) / 100.0;
  }

  // True once when the filter wants the current hit to raise the heat by one star.
  public func TakePendingRaise() -> Bool {
    let r = this.m_pendingRaise;
    this.m_pendingRaise = false;
    return r;
  }

  // A witness call about a crime the filter just ignored does not start a chase.
  public func ShouldIgnoreWitness() -> Bool {
    let cfg = this.Config();
    if !cfg.pettyFilter || !cfg.pettyWitness {
      return false;
    }
    let now = this.Now();
    if now - this.m_lastPettyTime > cfg.pettyWindow {
      return false;
    }
    return this.m_lastSeriousTime < this.m_lastPettyTime;
  }

  // A copy of the list without entries older than the window.
  private func Pruned(times: array<Float>, now: Float, window: Float) -> array<Float> {
    let kept: array<Float>;
    let i = 0;
    while i < ArraySize(times) {
      if now - times[i] <= window {
        ArrayPush(kept, times[i]);
      }
      i += 1;
    }
    return kept;
  }

  // ================================================================ escalation
  // One major crime at 3 or 4 stars. Enough of them inside the window raise the heat one star.
  public func AddEscalation(reason: String) -> Void {
    let cfg = this.Config();
    let ps = this.Prevention();
    if !cfg.plateau || !IsDefined(ps) {
      return;
    }
    let stage = NCPDHSystem.Stage(ps.GetHeatStage());
    if stage < 3 || stage >= 5 {
      return;
    }
    let now = this.Now();
    ArrayPush(this.m_escalationTimes, now);
    this.m_escalationTimes = this.Pruned(this.m_escalationTimes, now, cfg.escalationWindow);
    let need = stage == 3 ? cfg.eventsFor4 : cfg.eventsFor5;
    this.Log(s"Major crime (\(reason)): \(ArraySize(this.m_escalationTimes)) of \(need) toward \(stage + 1) stars");
    if ArraySize(this.m_escalationTimes) >= need {
      ArrayClear(this.m_escalationTimes);
      this.m_pendingRaise = true;
    }
  }

  // A police vehicle exploded. Called from the base game's explosion notice.
  public func OnPoliceVehicleDestroyed(ps: ref<PreventionSystem>) -> Void {
    if !this.Active(ps) || !this.Config().vehicleEvents || !ps.IsChasingPlayer() {
      return;
    }
    this.AddEscalation("police vehicle destroyed");
    if this.TakePendingRaise() {
      ps.NCPDH_RaiseOneStar("NCPDH_PoliceVehicleDestroyed");
    }
  }

  // ================================================================ heat changes
  public func OnHeatChanged(ps: ref<PreventionSystem>, prev: Int32, cur: Int32) -> Void {
    this.Log(s"Heat \(prev) -> \(cur)");
    ArrayClear(this.m_escalationTimes);
    this.m_copKillsTowardEvent = 0;
    if cur == 0 {
      if prev > 0 && this.Config().enabled {
        NCPDHVoice.Play(this, NCPDHVoiceEvent.GiveUp, null);
      }
      this.Dissolve("heat gone");
      ArrayClear(this.m_units);
      this.m_copKillsThisChase = 0;
      this.m_brokenAt = -10000.0;
      this.m_searchStart = -1.0;
      this.m_corp.Reset();      // the next chase may bring a different corporation
      if this.m_corp.HasUnits() {
        this.EnsureTicking();   // corporate squads still need to leave
      }
      return;
    }
    this.m_eliteAnnounced = false;
    if cur >= 3 || cur >= this.Config().corpStars {
      this.EnsureTicking();
    }
  }

  // ================================================================ search
  public func GameSeconds() -> Float {
    return GameInstance.GetTimeSystem(this.GetGameInstance()).GetGameTimeStamp();
  }

  // The police lost sight of V.
  public func NoteSearchStart() -> Void {
    if this.m_searchStart < 0.0 {
      this.m_searchStart = this.GameSeconds();
      this.m_searchStartReal = this.Now();
      this.Log("Police lost sight of V: search started");
    }
  }

  // The police can see V again.
  public func NoteSighted() -> Void {
    this.m_searchStart = -1.0;
  }

  // In-game seconds the search must still run before the stars may start to fade.
  // Seconds the search must still run (in-game or real seconds, by the setting).
  public func SearchTimeLeft() -> Float {
    let cfg = this.Config();
    if !cfg.longSearch {
      return 0.0;
    }
    if this.m_searchStart < 0.0 {
      this.NoteSearchStart();
    }
    if cfg.searchRealTime {
      return cfg.searchRealMinutes * 60.0 - (this.Now() - this.m_searchStartReal);
    }
    return cfg.searchMinutes * 60.0 - (this.GameSeconds() - this.m_searchStart);
  }

  // ================================================================ perimeter
  // Heat freeze: only once officers have engaged V and while some are actually on the ring.
  public func IsHoldingPerimeter() -> Bool {
    let cfg = this.Config();
    return this.m_perimeterOn && this.m_engaged && cfg.enabled && cfg.perimeter && this.Now() - this.m_lastValidUnitTime < 10.0;
  }

  public func EnsureTicking() -> Void {
    if this.m_ticking {
      return;
    }
    this.m_lastTickTime = this.Now();
    this.ScheduleTick(0.5);
  }

  private func ScheduleTick(delay: Float) -> Void {
    this.m_tickToken += 1;
    let cb = new NCPDHTickCallback();
    cb.sys = this;
    cb.token = this.m_tickToken;
    GameInstance.GetDelaySystem(this.GetGameInstance()).DelayCallback(cb, delay, false);
    this.m_ticking = true;
  }

  public func OnTick(token: Int32) -> Void {
    if token != this.m_tickToken {
      return;
    }
    this.m_ticking = false;
    let game = this.GetGameInstance();
    let cfg = this.Config();
    let ps = this.Prevention();
    if !IsDefined(ps) {
      return;
    }
    let stage = NCPDHSystem.Stage(ps.GetHeatStage());
    let now = this.Now();
    let dt = ClampF(now - this.m_lastTickTime, 0.0, 2.0);
    this.m_lastTickTime = now;
    let player = GetPlayer(game);
    let here = IsDefined(player) ? player.GetWorldPosition() : this.m_anchor;
    if stage < 3 {
      this.Dissolve("below 3 stars");
      // Corporate squads can answer below 3 stars (setting), and leave after the chase.
      if this.m_corp.HasUnits() || (stage > 0 && stage >= cfg.corpStars) {
        this.m_corp.Tick(this, ps, stage, now, here, false);
        this.ScheduleTick(1.0);
      }
      return;
    }

    if !cfg.perimeter || !this.Active(ps) || !ps.CanPreventionReactToInput() || !IsDefined(player) {
      this.Dissolve("switched off or quest controls the police");
      this.m_corp.Tick(this, ps, stage, now, here, false);
      this.ScheduleTick(2.0);
      return;
    }
    if ps.IsPlayerMounted() {
      this.Dissolve("V is in a vehicle");
      this.m_corp.Tick(this, ps, stage, now, here, false);
      this.ScheduleTick(1.0);
      return;
    }

    let registry = PreventionSystem.GetAgentRegistry(game);
    let vPos = player.GetWorldPosition();

    // Engaged: officers are fighting V right now. Otherwise they are searching, and the ring is
    // set around the last place they saw V instead of where V really is.
    let engaged = IsDefined(registry) && registry.IsPoliceInCombatWithPalyer();
    let lkp = ps.GetLastKnownPlayerPosition();
    if Vector4.IsXYZZero(lkp) {
      lkp = vPos;
    }

    if !this.m_perimeterOn {
      // The ring goes up as soon as the heat reaches 3 stars, before the first units arrive.
      if now - this.m_brokenAt >= cfg.reformDelay {
        this.Form(engaged ? vPos : lkp, now);
      }
    } else {
      if engaged && !this.m_engaged {
        this.Log("Officers engaging V: heat frozen while V stays inside the ring");
        let jx = vPos.X - this.m_anchor.X;
        let jy = vPos.Y - this.m_anchor.Y;
        if SqrtF(jx * jx + jy * jy) > cfg.radius {
          // Spotted somewhere else: the ring moves to V.
          this.m_anchor = vPos;
        }
      }
      if engaged {
        this.m_engaged = true;
      }
      let target = engaged ? vPos : lkp;
      let dx = target.X - this.m_anchor.X;
      let dy = target.Y - this.m_anchor.Y;
      let d = SqrtF(dx * dx + dy * dy);
      if engaged && d > cfg.radius + cfg.breakMargin {
        this.Breakout(registry, vPos, now);
        this.ScheduleTick(1.0);
        return;
      }
      // The ring re-centers, but no faster than officers on foot can follow.
      let step = cfg.followSpeed * dt;
      if d <= step || d < 0.01 {
        this.m_anchor = target;
      } else {
        this.m_anchor = new Vector4(this.m_anchor.X + dx / d * step, this.m_anchor.Y + dy / d * step, target.Z, 1.0);
      }
    }

    let valid = 0;
    if this.m_perimeterOn && IsDefined(registry) {
      if cfg.carPerimeter {
        this.CommandVehicles(registry, now);
      }
      valid = this.CommandUnits(registry, stage, now);
    }
    // Corporate squads: waves arrive whether or not a ring stands; on it they keep the ring rules.
    valid += this.m_corp.Tick(this, ps, stage, now, this.m_perimeterOn ? this.m_anchor : vPos, this.m_perimeterOn);
    if this.m_perimeterOn {
      if valid > 0 {
        this.m_lastValidUnitTime = now;
      }
      if valid > 0 && now - this.m_lastStandoffLine > 25.0 {
        this.m_lastStandoffLine = now;
        NCPDHVoice.Play(this, NCPDHVoiceEvent.Standoff, null);
      }
    }
    this.ScheduleTick(1.0);
  }

  private func Form(vPos: Vector4, now: Float) -> Void {
    this.m_perimeterOn = true;
    this.m_engaged = false;
    this.m_anchor = vPos;
    this.m_lastValidUnitTime = now;
    this.m_lastStandoffLine = now;
    this.Log(s"Perimeter formed, radius \(this.Config().radius) m");
    NCPDHVoice.Play(this, NCPDHVoiceEvent.PerimeterSet, null);
  }

  // Gives every officer on foot an order: hold the ring, or move to it. Returns how many are on it.
  private func CommandUnits(registry: ref<PoliceAgentRegistry>, stage: Int32, now: Float) -> Int32 {
    let agents = registry.GetNPCList();
    let valid = 0;
    let i = 0;
    while i < ArraySize(agents) {
      if this.CommandOne(agents[i], stage, now) {
        valid += 1;
      }
      i += 1;
    }
    return valid;
  }

  // One officer. Returns true if he is part of the ring.
  private func CommandOne(agent: ref<NPCAgent>, stage: Int32, now: Float) -> Bool {
    let game = this.GetGameInstance();
    if !IsDefined(agent) || agent.isQuestNPC || agent.markedToBeDespawned {
      return false;
    }
    let unit = agent.unit;
    if !IsDefined(unit) || !unit.IsActive() || VehicleComponent.IsMountedToVehicle(game, unit) {
      return false;
    }
    // Roadblock crews already hold behind their own cars: leave them unless they wander inside.
    let roadblockCrew = Equals(agent.spawnedType, DynamicVehicleType.RoadBlockade) || Equals(agent.spawnedType, DynamicVehicleType.RoadBlockadeWithAV);
    return this.RingUnit(unit, stage, now, roadblockCrew);
  }

  // The ring rules for one unit on foot: police and corporate squads alike.
  public func RingUnit(unit: wref<ScriptedPuppet>, stage: Int32, now: Float, roadblockCrew: Bool) -> Bool {
    let cfg = this.Config();
    let tolerance = 4.0;
    let rec = this.GetUnit(unit.GetEntityID());
    if rec.mode == 3 {
      return false;
    }
    if this.MayEnter(unit, stage) {
      // MaxTac and heavy units are not held back. Regular officers keep the ring while they go in.
      if IsDefined(rec.cmd) {
        AIComponent.CancelCommand(unit, rec.cmd);
        rec.cmd = null;
      }
      if rec.presetSent {
        NCPDHSystem.SendPreset(unit, rec.origPreset);
        rec.presetSent = false;
      }
      rec.mode = 0;
      if !rec.entering {
        rec.entering = true;
        this.Log(s"Entering the perimeter: \(TDBID.ToStringDEBUG(unit.GetRecordID()))");
      }
      if !this.m_eliteAnnounced {
        this.m_eliteAnnounced = true;
        NCPDHVoice.Play(this, NCPDHVoiceEvent.EliteEnter, null);
      }
      return false;
    }

    let pos = unit.GetWorldPosition();
    let dx = pos.X - this.m_anchor.X;
    let dy = pos.Y - this.m_anchor.Y;
    let d = SqrtF(dx * dx + dy * dy);
    if d < 0.5 {
      let a = RandRangeF(0.0, 6.2831);
      dx = CosF(a);
      dy = SinF(a);
      d = 1.0;
    }
    let ring = new Vector4(this.m_anchor.X + dx / d * cfg.radius, this.m_anchor.Y + dy / d * cfg.radius, pos.Z, 1.0);
    let gap = d - cfg.radius;

    if cfg.useCover {
      if !rec.presetSent {
        rec.origPreset = NCPDHSystem.CurrentPreset(unit);
        NCPDHSystem.SendPreset(unit, EAICombatPreset.IsCautious);
        rec.presetSent = true;
      }
      if gap < -2.0 {
        // Inside the ring: back out to it. Once caught, he is held in place when he gets back.
        if rec.mode != 1 {
          rec.creeps += 1;
          this.Log(s"Officer \(EntityID.ToDebugString(rec.id)) crossed into the ring (\(-gap) m), sent back");
        }
        let moved = Vector4.Distance(rec.target, ring) > tolerance;
        if rec.mode != 1 || moved || now - rec.sentAt > 4.0 {
          this.SendMove(unit, rec, ring, moveMovementType.Run, now);
        }
      } else {
        if gap > cfg.coverBand && !roadblockCrew {
          // Too far out: close in to the ring.
          let moved = Vector4.Distance(rec.target, ring) > tolerance;
          if rec.mode != 1 || moved || now - rec.sentAt > 4.0 {
            this.SendMove(unit, rec, ring, gap > 15.0 ? moveMovementType.Sprint : moveMovementType.Run, now);
          }
        } else {
          // In the band: free to pick his own cover and fight from it. An officer who has
          // already crept inside once is held where he is (usually behind the cover he picked).
          if rec.creeps > 0 {
            if gap >= 0.0 && (rec.mode != 2 || now - rec.sentAt > 6.0) {
              this.SendHold(unit, rec, now);
            }
          } else {
            if rec.mode == 1 && gap >= 0.0 && IsDefined(rec.cmd) {
              AIComponent.CancelCommand(unit, rec.cmd);
              rec.cmd = null;
            }
            if rec.mode != 1 || gap >= 0.0 {
              rec.mode = 4;
            }
          }
        }
      }
      return true;
    }

    if roadblockCrew && gap >= -tolerance {
      return true;
    }
    if AbsF(gap) <= tolerance {
      if rec.mode != 2 || now - rec.sentAt > 6.0 {
        this.SendHold(unit, rec, now);
      }
    } else {
      let moved = Vector4.Distance(rec.target, ring) > tolerance;
      if rec.mode != 1 || moved || now - rec.sentAt > 4.0 {
        this.SendMove(unit, rec, ring, gap > 15.0 ? moveMovementType.Sprint : moveMovementType.Run, now);
      }
    }
    return true;
  }

  // MaxTac and heavy units may go inside the ring from the configured star level.
  private func MayEnter(unit: wref<ScriptedPuppet>, stage: Int32) -> Bool {
    let cfg = this.Config();
    if stage < cfg.enterStars {
      return false;
    }
    if cfg.maxTacEnters && PreventionSystem.IsPreventionMaxTac(this.GetGameInstance(), unit) {
      return true;
    }
    return cfg.heavyEnter && NCPDHSystem.IsHeavy(unit);
  }

  // Elite rank, MaxTac rank, or a heavy-weapons archetype. Beat cops and body-armor officers are not.
  public static func IsHeavy(unit: wref<ScriptedPuppet>) -> Bool {
    let rec = TweakDBInterface.GetCharacterRecord(unit.GetRecordID());
    if !IsDefined(rec) {
      return false;
    }
    if IsDefined(rec.Rarity()) {
      let r = rec.Rarity().Type();
      if Equals(r, gamedataNPCRarity.Elite) || Equals(r, gamedataNPCRarity.MaxTac) || Equals(r, gamedataNPCRarity.Boss) {
        return true;
      }
    }
    if IsDefined(rec.ArchetypeData()) && IsDefined(rec.ArchetypeData().Type()) {
      let arch = rec.ArchetypeData().Type().Type();
      return Equals(arch, gamedataArchetypeType.HeavyRangedT2) || Equals(arch, gamedataArchetypeType.HeavyRangedT3)
        || Equals(arch, gamedataArchetypeType.HeavyMeleeT2) || Equals(arch, gamedataArchetypeType.HeavyMeleeT3);
    }
    return false;
  }

  // ---------------------------------------------------------------- combat style
  public static func CurrentPreset(unit: wref<ScriptedPuppet>) -> EAICombatPreset {
    let stats = GameInstance.GetStatsSystem(unit.GetGame());
    let id = Cast<StatsObjectID>(unit.GetEntityID());
    if stats.GetStatValue(id, gamedataStatType.IsReckless) > 0.0 {
      return EAICombatPreset.IsReckless;
    }
    if stats.GetStatValue(id, gamedataStatType.IsAggressive) > 0.0 {
      return EAICombatPreset.IsAggressive;
    }
    if stats.GetStatValue(id, gamedataStatType.IsBalanced) > 0.0 {
      return EAICombatPreset.IsBalanced;
    }
    if stats.GetStatValue(id, gamedataStatType.IsDefensive) > 0.0 {
      return EAICombatPreset.IsDefensive;
    }
    if stats.GetStatValue(id, gamedataStatType.IsCautious) > 0.0 {
      return EAICombatPreset.IsCautious;
    }
    return EAICombatPreset.None;
  }

  public static func SendPreset(unit: wref<ScriptedPuppet>, preset: EAICombatPreset) -> Void {
    let cmd = new AISetCombatPresetCommand();
    cmd.combatPreset = preset;
    AIComponent.SendCommand(unit, cmd);
  }

  // ---------------------------------------------------------------- police cars
  // Cars driving in are sent to a spot on the ring and their crew get out there.
  private func CommandVehicles(registry: ref<PoliceAgentRegistry>, now: Float) -> Void {
    let cfg = this.Config();
    let game = this.GetGameInstance();
    let list = registry.GetVehicleList();
    let i = 0;
    while i < ArraySize(list) {
      let agent = list[i];
      i += 1;
      if IsDefined(agent) && IsDefined(agent.unit) {
        let veh = agent.unit;
        let wheeled = veh as WheeledObject;
        let isRoadblock = Equals(agent.spawnedType, DynamicVehicleType.RoadBlockade) || Equals(agent.spawnedType, DynamicVehicleType.RoadBlockadeWithAV);
        if IsDefined(wheeled) && !isRoadblock && !veh.IsDestroyed() && veh.HasPassengers() {
          let rec = this.GetVehicle(veh.GetEntityID());
          if rec.mode != 2 {
            let pos = veh.GetWorldPosition();
            let dx = pos.X - this.m_anchor.X;
            let dy = pos.Y - this.m_anchor.Y;
            let d = MaxF(SqrtF(dx * dx + dy * dy), 0.1);
            let stuck = rec.mode == 1 && now - rec.sentAt > 15.0;
            if stuck && d > cfg.radius + 40.0 {
              // Stuck far away: try once more, then leave the car to the base game.
              if rec.retries < 1 {
                rec.retries += 1;
                rec.mode = 0;
                this.Log(s"Police car \(EntityID.ToDebugString(rec.id)) stuck \(d) m out, retrying");
              } else {
                rec.mode = 2;
                this.Log(s"Police car \(EntityID.ToDebugString(rec.id)) stuck \(d) m out, released");
              }
            } else {
              if d <= cfg.radius + 16.0 || stuck {
                // At the ring (or inside it already, or stuck nearby): stop here and get out.
                VehicleComponent.QueueEventToAllPassengers(game, veh, AIEvents.ExitVehicleEvent());
                rec.mode = 2;
                rec.sentAt = now;
                this.Log(s"Police car \(EntityID.ToDebugString(rec.id)) parked \(d) m out, crew getting out");
              } else {
                if rec.mode == 0 && d <= cfg.radius + 70.0 {
                  // Aim well outside the ring: cars overshoot, and the crew should get out outside it.
                  let spot = new Vector4(this.m_anchor.X + dx / d * (cfg.radius + 10.0), this.m_anchor.Y + dy / d * (cfg.radius + 10.0), pos.Z, 1.0);
                  let cmd = new AIVehicleDriveToPointAutonomousCommand();
                  cmd.targetPosition = Vector4.Vector4To3(spot);
                  cmd.minimumDistanceToTarget = 4.0;
                  cmd.maxSpeed = 11.0;
                  cmd.minSpeed = 3.0;
                  cmd.clearTrafficOnPath = true;
                  cmd.forcedStartSpeed = -1.0;
                  cmd.driveDownTheRoadIndefinitely = false;
                  let evt = new AICommandEvent();
                  evt.command = cmd;
                  veh.QueueEvent(evt);
                  rec.mode = 1;
                  rec.sentAt = now;
                  this.Log(s"Police car \(EntityID.ToDebugString(rec.id)) told to park on the ring (\(d) m out)");
                }
              }
            }
          }
        }
      }
    }
  }

  private func GetVehicle(id: EntityID) -> ref<NCPDHVehicle> {
    let i = 0;
    while i < ArraySize(this.m_vehicles) {
      if Equals(this.m_vehicles[i].id, id) {
        return this.m_vehicles[i];
      }
      i += 1;
    }
    let rec = new NCPDHVehicle();
    rec.id = id;
    ArrayPush(this.m_vehicles, rec);
    return rec;
  }

  private func SendHold(unit: wref<ScriptedPuppet>, rec: ref<NCPDHUnit>, now: Float) -> Void {
    if IsDefined(rec.cmd) {
      AIComponent.CancelCommand(unit, rec.cmd);
    }
    let cmd = new AIHoldPositionCommand();
    cmd.duration = 8.0;
    cmd.ignoreInCombat = false;
    cmd.removeAfterCombat = true;
    cmd.alwaysUseStealth = false;
    AIComponent.SendCommand(unit, cmd);
    rec.cmd = cmd;
    rec.mode = 2;
    rec.sentAt = now;
  }

  private func SendMove(unit: wref<ScriptedPuppet>, rec: ref<NCPDHUnit>, target: Vector4, speed: moveMovementType, now: Float) -> Void {
    if IsDefined(rec.cmd) {
      AIComponent.CancelCommand(unit, rec.cmd);
    }
    let cmd = new AIMoveToCommand();
    let wp: WorldPosition;
    WorldPosition.SetVector4(wp, target);
    AIPositionSpec.SetWorldPosition(cmd.movementTarget, wp);
    cmd.movementType = speed;
    cmd.desiredDistanceFromTarget = 1.5;
    cmd.finishWhenDestinationReached = true;
    cmd.ignoreNavigation = false;
    cmd.useStart = true;
    cmd.useStop = true;
    cmd.rotateEntityTowardsFacingTarget = false;
    cmd.alwaysUseStealth = false;
    cmd.removeAfterCombat = true;
    cmd.ignoreInCombat = false;
    AIComponent.SendCommand(unit, cmd);
    rec.cmd = cmd;
    rec.mode = 1;
    rec.sentAt = now;
    rec.target = target;
  }

  private func GetUnit(id: EntityID) -> ref<NCPDHUnit> {
    let i = 0;
    while i < ArraySize(this.m_units) {
      if Equals(this.m_units[i].id, id) {
        return this.m_units[i];
      }
      i += 1;
    }
    let rec = new NCPDHUnit();
    rec.id = id;
    ArrayPush(this.m_units, rec);
    return rec;
  }

  // V got clear of the ring. Low-rank officers may run, then everyone else follows base-game rules.
  private func Breakout(registry: ref<PoliceAgentRegistry>, vPos: Vector4, now: Float) -> Void {
    let cfg = this.Config();
    this.Log("V broke the perimeter. Heat unfrozen.");
    NCPDHVoice.Play(this, NCPDHVoiceEvent.BreakOut, null);
    if cfg.flee && IsDefined(registry) {
      let chance = Cast<Float>(Min(cfg.fleeMax, this.m_copKillsThisChase * cfg.fleePerKill)) / 100.0;
      this.Log(s"Flee chance for low-rank officers: \(chance * 100.0)% (\(this.m_copKillsThisChase) police killed this chase)");
      if chance > 0.0 {
        let agents = registry.GetNPCList();
        let i = 0;
        while i < ArraySize(agents) {
          let agent = agents[i];
          i += 1;
          if IsDefined(agent) && !agent.isQuestNPC && IsDefined(agent.unit) && agent.unit.IsActive() {
            let rec = this.GetUnit(agent.unit.GetEntityID());
            if (rec.mode == 1 || rec.mode == 2 || rec.mode == 4) && NCPDHSystem.IsLowRank(agent.unit) && RandF() < chance {
              this.Flee(agent.unit, rec, vPos, now);
            }
          }
        }
      }
    }
    this.Dissolve("breakout");
    this.m_brokenAt = now;
  }

  public static func IsLowRank(unit: wref<ScriptedPuppet>) -> Bool {
    let record = TweakDBInterface.GetCharacterRecord(unit.GetRecordID());
    if !IsDefined(record) || !IsDefined(record.Rarity()) {
      return false;
    }
    let r = record.Rarity().Type();
    return Equals(r, gamedataNPCRarity.Trash) || Equals(r, gamedataNPCRarity.Weak) || Equals(r, gamedataNPCRarity.Normal);
  }

  private func Flee(unit: wref<ScriptedPuppet>, rec: ref<NCPDHUnit>, vPos: Vector4, now: Float) -> Void {
    let game = this.GetGameInstance();
    let player = GetPlayer(game);
    if IsDefined(rec.cmd) {
      AIComponent.CancelCommand(unit, rec.cmd);
      rec.cmd = null;
    }
    rec.mode = 3;
    // Drop V as a target, the same way the base game does when the stars run out.
    let tracker = unit.GetTargetTrackerComponent();
    if IsDefined(tracker) && IsDefined(player) {
      tracker.RemoveThreat(tracker.MapThreat(player));
      tracker.ResetRecentlyDroppedThreat();
    }
    if IsDefined(player) {
      GameObject.ChangeAttitudeToNeutral(unit, player);
    }
    NPCPuppet.ChangeHighLevelState(unit, gamedataNPCHighLevelState.Relaxed);
    // Run straight away from V.
    let pos = unit.GetWorldPosition();
    let dx = pos.X - vPos.X;
    let dy = pos.Y - vPos.Y;
    let d = MaxF(SqrtF(dx * dx + dy * dy), 0.1);
    let away = new Vector4(pos.X + dx / d * 100.0, pos.Y + dy / d * 100.0, pos.Z, 1.0);
    let cmd = new AIMoveToCommand();
    let wp: WorldPosition;
    WorldPosition.SetVector4(wp, away);
    AIPositionSpec.SetWorldPosition(cmd.movementTarget, wp);
    cmd.movementType = moveMovementType.Sprint;
    cmd.desiredDistanceFromTarget = 3.0;
    cmd.finishWhenDestinationReached = true;
    cmd.ignoreNavigation = false;
    cmd.useStart = true;
    cmd.useStop = true;
    cmd.alwaysUseStealth = false;
    cmd.removeAfterCombat = false;
    cmd.ignoreInCombat = false;
    AIComponent.SendCommand(unit, cmd);
    rec.cmd = cmd;
    rec.sentAt = now;
    this.Log(s"Officer \(EntityID.ToDebugString(unit.GetEntityID())) flees");
    NCPDHVoice.Play(this, NCPDHVoiceEvent.Flee, unit);
    let cb = new NCPDHDespawnCallback();
    cb.sys = this;
    cb.id = unit.GetEntityID();
    GameInstance.GetDelaySystem(game).DelayCallback(cb, 20.0, false);
  }

  // A fled officer who got away is removed, so he does not rejoin the chase.
  public func DespawnFled(id: EntityID) -> Void {
    let game = this.GetGameInstance();
    let unit = GameInstance.FindEntityByID(game, id) as ScriptedPuppet;
    let player = GetPlayer(game);
    if !IsDefined(unit) || !unit.IsActive() || !IsDefined(player) {
      return;
    }
    if Vector4.Distance(unit.GetWorldPosition(), player.GetWorldPosition()) > 40.0 {
      this.Log(s"Fled officer \(EntityID.ToDebugString(id)) is gone");
      GameInstance.GetPreventionSpawnSystem(game).RequestDespawn(id);
    }
  }

  // Ends the perimeter and takes back every order it gave, except to officers who fled.
  public func Dissolve(reason: String) -> Void {
    if !this.m_perimeterOn {
      return;
    }
    this.m_perimeterOn = false;
    let game = this.GetGameInstance();
    let i = ArraySize(this.m_units) - 1;
    while i >= 0 {
      let rec = this.m_units[i];
      if rec.mode != 3 {
        let unit = GameInstance.FindEntityByID(game, rec.id) as ScriptedPuppet;
        if IsDefined(unit) && IsDefined(rec.cmd) {
          AIComponent.CancelCommand(unit, rec.cmd);
        }
        if IsDefined(unit) && rec.presetSent && unit.IsActive() {
          NCPDHSystem.SendPreset(unit, rec.origPreset);
        }
        ArrayErase(this.m_units, i);
      }
      i -= 1;
    }
    ArrayClear(this.m_vehicles);
    this.Log(s"Perimeter ended: \(reason)");
  }

  // ================================================================ voice support
  public func VoiceLastTime(e: NCPDHVoiceEvent) -> Float {
    let i = NCPDHVoice.Index(e);
    if i < 0 || i >= ArraySize(this.m_voiceLast) {
      return -10000.0;
    }
    return this.m_voiceLast[i];
  }

  public func SetVoiceLastTime(e: NCPDHVoiceEvent, t: Float) -> Void {
    let i = NCPDHVoice.Index(e);
    if i >= 0 && i < ArraySize(this.m_voiceLast) {
      this.m_voiceLast[i] = t;
    }
  }

  // ================================================================ testing
  public func Report() -> Void {
    let ps = this.Prevention();
    let stage = IsDefined(ps) ? NCPDHSystem.Stage(ps.GetHeatStage()) : -1;
    ModLog(n"ThreatAssessment", s"Report: heat \(stage), active \(this.Active(ps)), perimeter \(this.m_perimeterOn), officers tracked \(ArraySize(this.m_units)), police killed this chase \(this.m_copKillsThisChase), major crimes counted \(ArraySize(this.m_escalationTimes)), recent civilian kills \(ArraySize(this.m_civKillTimes))");
  }
}
