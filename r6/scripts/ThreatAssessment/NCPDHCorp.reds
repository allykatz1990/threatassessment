// Threat Assessment - Tactical Police & Jurisdiction Overhaul - corporate jurisdictions
// Copyright (C) 2026 the Threat Assessment authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// In corporate districts, from 3 stars, the corporation that owns the turf sends its own security
// squads alongside (fewer) NCPD. They hold the same perimeter as the police; their elite units go in
// at 5 stars, like MaxTac. Heavier units at 4 stars (Militech adds drones), a mech at 5.
//
// Squads are spawned with Codeware's DynamicEntitySystem and tagged "ThreatAssessment.Corp", using
// the base game's own Arasaka, Militech and Kang Tao character records. Records that do not exist
// in the player's game are skipped and logged. Nothing spawns while a quest steers the police, and
// squads wait while a They Will Remember or Gang Retaliation squad is already on the player.

enum NCPDHCorpChoice {
  Off = 0,
  Arasaka = 1,
  Militech = 2,
  KangTao = 3,
  Mixed = 4
}

public class NCPDHCorpUnit {
  public let id: EntityID;
  public let spawnedAt: Float;
  public let ready: Bool;     // made hostile and given V as a target
  public let isMech: Bool;
}

public class NCPDHCorp {
  private let m_units: array<ref<NCPDHCorpUnit>>;
  private let m_corp: NCPDHCorpChoice;      // the corporation answering this chase
  private let m_firstWaveAt: Float;
  private let m_lastWave: Float;
  private let m_announced: Bool;
  private let m_heldForGangs: Bool;

  public func Reset() -> Void {
    this.m_corp = NCPDHCorpChoice.Off;
    this.m_firstWaveAt = -1.0;
    this.m_lastWave = -10000.0;
    this.m_announced = false;
  }

  public func HasUnits() -> Bool {
    return ArraySize(this.m_units) > 0;
  }

  // ---------------------------------------------------------------- who owns this district
  public static func ChoiceFor(cfg: ref<NCPDHConfig>, ps: ref<PreventionSystem>) -> NCPDHCorpChoice {
    if !cfg.corpResponse || !IsDefined(ps) {
      return NCPDHCorpChoice.Off;
    }
    let district = ps.GetCurrentDistrict();
    if !IsDefined(district) || !IsDefined(district.GetDistrictRecord()) {
      return NCPDHCorpChoice.Off;
    }
    // Walk from the sub-district up to the top-level district; the first one with a setting wins.
    let rec: wref<District_Record> = district.GetDistrictRecord();
    let depth = 0;
    while IsDefined(rec) && depth < 4 {
      let c = NCPDHCorp.ChoiceForType(cfg, rec.Type());
      if NotEquals(c, NCPDHCorpChoice.Off) {
        return c;
      }
      rec = rec.ParentDistrict();
      depth += 1;
    }
    return NCPDHCorpChoice.Off;
  }

  private static func ChoiceForType(cfg: ref<NCPDHConfig>, t: gamedataDistrict) -> NCPDHCorpChoice {
    switch t {
      case gamedataDistrict.CorpoPlaza:
        return cfg.corpCorpoPlaza;
      case gamedataDistrict.Downtown:
        return cfg.corpDowntown;
      case gamedataDistrict.ArasakaWaterfront:
        return cfg.corpArasakaWaterfront;
      case gamedataDistrict.NorthOaks:
        return cfg.corpNorthOaks;
      case gamedataDistrict.CharterHill:
        return cfg.corpCharterHill;
      case gamedataDistrict.JapanTown:
        return cfg.corpJapanTown;
      case gamedataDistrict.Dogtown:
        return cfg.corpDogtown;
    }
    return NCPDHCorpChoice.Off;
  }

  public static func Name(c: NCPDHCorpChoice) -> String {
    switch c {
      case NCPDHCorpChoice.Arasaka:
        return "Arasaka";
      case NCPDHCorpChoice.Militech:
        return "Militech";
      case NCPDHCorpChoice.KangTao:
        return "Kang Tao";
      case NCPDHCorpChoice.Mixed:
        return "Mixed";
    }
    return "none";
  }

  // ---------------------------------------------------------------- unit lists (base game records)
  private static func Pool(c: NCPDHCorpChoice, tier: Int32) -> array<TweakDBID> {
    let l: array<TweakDBID>;
    switch c {
      case NCPDHCorpChoice.Arasaka:
        if tier == 1 {
          ArrayPush(l, t"Character.arasaka_ranger1_ranged2_masamune_ma");
          ArrayPush(l, t"Character.arasaka_ranger1_ranged2_shingen_ma");
          ArrayPush(l, t"Character.arasaka_ranger1_ranged2_shingen_wa");
          ArrayPush(l, t"Character.arasaka_security1_ranged1_shingen_ma");
          ArrayPush(l, t"Character.arasaka_soldier1_ranged3_masamune_mah_rare");
          ArrayPush(l, t"Character.arasaka_soldier2_shotgun2_tactician_mah_rare");
        }
        if tier == 2 {
          ArrayPush(l, t"Character.arasaka_tank2_gunner2_defender_mb_rare");
          ArrayPush(l, t"Character.arasaka_netrunner_netrunner2_yukimura_ma_rare");
          ArrayPush(l, t"Character.arasaka_bodyguard_ranged3_masamune_mb_rare");
          ArrayPush(l, t"Character.arasaka_sniper_sniper3_ashura_ma_elite");
        }
        if tier == 3 {
          ArrayPush(l, t"Character.arasaka_cyborg_franged3_shingen_ma_elite");
          ArrayPush(l, t"Character.arasaka_terminator_shotgun3_zhuo_mah_elite");
          ArrayPush(l, t"Character.arasaka_rare2_gunner3_hmg_mm_elite");
          ArrayPush(l, t"Character.arasaka_ninja_fmelee3_katana_ma_elite");
        }
        if tier == 4 {
          ArrayPush(l, t"Character.arasaka_minotaur");
        }
        break;
      case NCPDHCorpChoice.Militech:
        if tier == 1 {
          ArrayPush(l, t"Character.militech_ranger1_ranged1_lexington_ma");
          ArrayPush(l, t"Character.militech_ranger1_ranged1_saratoga_ma");
          ArrayPush(l, t"Character.militech_ranger2_ranged2_ajax_ma");
          ArrayPush(l, t"Character.militech_ranger2_ranged2_omaha_ma");
        }
        if tier == 2 {
          ArrayPush(l, t"Character.militech_enforcer2_shotgun2_tactician_mah_rare");
          ArrayPush(l, t"Character.militech_tech_franged2_omaha_ma_rare");
          ArrayPush(l, t"Character.militech_recon_sniper2_achilles_ma_rare");
          ArrayPush(l, t"Character.militech_drone_wyvern_hard");
          ArrayPush(l, t"Character.militech_drone_griffin_medium");
        }
        if tier == 3 {
          ArrayPush(l, t"Character.militech_soldier3_shotgun3_crusher_mah_elite");
          ArrayPush(l, t"Character.militech_strongarms_hmelee3_fists_mb_elite");
          ArrayPush(l, t"Character.militech_android_android2_ajax_ma");
        }
        if tier == 4 {
          ArrayPush(l, t"Character.militech_minotaur");
        }
        break;
      case NCPDHCorpChoice.KangTao:
        if tier == 1 {
          ArrayPush(l, t"Character.kangtao_ranger1_ranged2_dian_ma");
          ArrayPush(l, t"Character.kangtao_android_android2_dian_ma");
        }
        if tier == 2 {
          ArrayPush(l, t"Character.kangtao_soldier2_shotgun2_zhuo_mah_rare");
        }
        if tier == 3 {
          ArrayPush(l, t"Character.kangtao_soldier2_shotgun3_zhuo_mah_elite");
          ArrayPush(l, t"Character.kangtao_officer_grenadier3_mah_elite");
        }
        break;
    }
    // Keep only records that exist in this game (some may need Phantom Liberty).
    let ok: array<TweakDBID>;
    let i = 0;
    while i < ArraySize(l) {
      if IsDefined(TweakDBInterface.GetCharacterRecord(l[i])) {
        ArrayPush(ok, l[i]);
      }
      i += 1;
    }
    return ok;
  }

  private static func PickFrom(pool: array<TweakDBID>, out id: TweakDBID) -> Bool {
    if ArraySize(pool) == 0 {
      return false;
    }
    id = pool[RandRange(0, ArraySize(pool))];
    return true;
  }

  // ---------------------------------------------------------------- every tick
  // Spawns waves and gives corporate units the ring rules. Returns how many hold the ring.
  public func Tick(sys: ref<NCPDHSystem>, ps: ref<PreventionSystem>, stage: Int32, now: Float, anchor: Vector4, perimeterOn: Bool) -> Int32 {
    let cfg = sys.Config();
    let game = sys.GetGameInstance();
    let des = GameInstance.GetDynamicEntitySystem();
    let player = GetPlayer(game);
    if !IsDefined(des) || !IsDefined(player) {
      return 0;
    }
    let active = sys.Active(ps) && stage >= cfg.corpStars;
    let here = NCPDHCorp.ChoiceFor(cfg, ps);

    // ---- waves
    if active && NotEquals(here, NCPDHCorpChoice.Off) {
      if Equals(this.m_corp, NCPDHCorpChoice.Off) {
        this.m_corp = here;
        if Equals(here, NCPDHCorpChoice.Mixed) {
          let roll = RandRange(0, 3);
          this.m_corp = NCPDHCorpChoice.Arasaka;
          if roll == 1 {
            this.m_corp = NCPDHCorpChoice.Militech;
          }
          if roll == 2 {
            this.m_corp = NCPDHCorpChoice.KangTao;
          }
        }
        this.m_firstWaveAt = now + cfg.corpDelay;
        sys.Log(s"Corporate district: \(NCPDHCorp.Name(this.m_corp)) security responding in \(cfg.corpDelay) s");
      }
      let gangs = cfg.corpHoldForGangs && (des.IsPopulated(n"TheyWillRemember.Squad") || des.IsPopulated(n"GangRetaliation"));
      if gangs {
        if !this.m_heldForGangs {
          this.m_heldForGangs = true;
          sys.Log("Gang squad already on V: corporate squads hold back");
        }
      } else {
        this.m_heldForGangs = false;
        if now >= this.m_firstWaveAt && now - this.m_lastWave >= cfg.corpWaveDelay {
          let target = stage >= 5 ? cfg.corpSquad5 : (stage == 4 ? cfg.corpSquad4 : cfg.corpSquad3);
          let alive = this.AliveCount(des);
          if alive < target {
            this.SpawnWave(sys, anchor, stage, Min(target - alive, 4), now);
            this.m_lastWave = now;
          }
        }
      }
    }

    // ---- units already spawned
    let valid = 0;
    let i = ArraySize(this.m_units) - 1;
    while i >= 0 {
      let u = this.m_units[i];
      let unit = des.GetEntity(u.id) as ScriptedPuppet;
      if !IsDefined(unit) {
        if !des.IsSpawning(u.id) && now - u.spawnedAt > 30.0 {
          // Never appeared, or despawned by the game.
          des.DeleteEntity(u.id);
          ArrayErase(this.m_units, i);
        }
      } else {
        let dist = Vector4.Distance(unit.GetWorldPosition(), player.GetWorldPosition());
        if !unit.IsActive() {
          if dist > 40.0 || now - u.spawnedAt > 600.0 {
            des.DeleteEntity(u.id);
            ArrayErase(this.m_units, i);
          }
        } else {
          if !u.ready {
            this.MakeHostile(unit, player);
            u.ready = true;
          }
          if !active {
            // Chase over (or quest took over): leave once out of the way.
            if dist > 60.0 {
              des.DeleteEntity(u.id);
              ArrayErase(this.m_units, i);
            }
          } else {
            if perimeterOn && sys.RingUnit(unit, stage, now, false) {
              valid += 1;
            }
          }
        }
      }
      i -= 1;
    }
    if !active && !this.HasUnits() {
      this.Reset();
    }
    return valid;
  }

  private func AliveCount(des: ref<DynamicEntitySystem>) -> Int32 {
    let n = 0;
    let i = 0;
    while i < ArraySize(this.m_units) {
      let unit = des.GetEntity(this.m_units[i].id) as ScriptedPuppet;
      if !IsDefined(unit) || unit.IsActive() {
        n += 1;   // still spawning counts too
      }
      i += 1;
    }
    return n;
  }

  private func MechAlive(des: ref<DynamicEntitySystem>) -> Bool {
    let i = 0;
    while i < ArraySize(this.m_units) {
      if this.m_units[i].isMech {
        let unit = des.GetEntity(this.m_units[i].id) as ScriptedPuppet;
        if !IsDefined(unit) || unit.IsActive() {
          return true;
        }
      }
      i += 1;
    }
    return false;
  }

  // One squad, arriving on foot from a spot outside the ring.
  private func SpawnWave(sys: ref<NCPDHSystem>, anchor: Vector4, stage: Int32, count: Int32, now: Float) -> Void {
    let cfg = sys.Config();
    let game = sys.GetGameInstance();
    let des = GameInstance.GetDynamicEntitySystem();
    let nav = GameInstance.GetNavigationSystem(game);
    // Find a point on the navmesh 15-30 m outside the ring.
    let origin: Vector4;
    let found = false;
    let tries = 0;
    while !found && tries < 8 {
      let a = RandRangeF(0.0, 6.2831);
      let d = cfg.radius + RandRangeF(15.0, 30.0);
      let want = new Vector4(anchor.X + CosF(a) * d, anchor.Y + SinF(a) * d, anchor.Z + 2.0, 1.0);
      let p = nav.GetNearestNavmeshPointBelowOnlyHumanNavmesh(want, 1.0, 5);
      if Vector4.Length(p) > 1.0 && Vector4.Distance(p, want) < 12.0 {
        origin = p;
        found = true;
      }
      tries += 1;
    }
    if !found {
      sys.Log("Corporate squad: no spot to arrive from, trying again later");
      return;
    }
    let face = EulerAngles.ToQuat(Vector4.ToRotation(anchor - origin));
    let tier1 = NCPDHCorp.Pool(this.m_corp, 1);
    let tier2 = NCPDHCorp.Pool(this.m_corp, 2);
    let tier3 = NCPDHCorp.Pool(this.m_corp, 3);
    let spawned = 0;
    let i = 0;
    while i < count {
      let id: TweakDBID;
      let ok = false;
      if stage >= 5 && RandF() < 0.6 {
        ok = NCPDHCorp.PickFrom(tier3, id);
      }
      if !ok && stage >= 4 && RandF() < 0.5 {
        ok = NCPDHCorp.PickFrom(tier2, id);
      }
      if !ok {
        ok = NCPDHCorp.PickFrom(tier1, id);
      }
      if ok {
        let offset = new Vector4(RandRangeF(-3.0, 3.0), RandRangeF(-3.0, 3.0), 0.0, 0.0);
        this.SpawnOne(des, id, origin + offset, face, now, false);
        spawned += 1;
      }
      i += 1;
    }
    if stage >= 5 && cfg.corpMechs && !this.MechAlive(des) {
      let mech: TweakDBID;
      if NCPDHCorp.PickFrom(NCPDHCorp.Pool(this.m_corp, 4), mech) {
        this.SpawnOne(des, mech, origin, face, now, true);
        spawned += 1;
        sys.Log("Corporate mech deployed");
      }
    }
    sys.Log(s"\(NCPDHCorp.Name(this.m_corp)) squad of \(spawned) sent at \(stage) stars");
    if !this.m_announced && spawned > 0 {
      this.m_announced = true;
      NCPDHVoice.Play(sys, NCPDHVoiceEvent.EliteEnter, null);
    }
  }

  private func SpawnOne(des: ref<DynamicEntitySystem>, record: TweakDBID, pos: Vector4, face: Quaternion, now: Float, isMech: Bool) -> Void {
    let spec = new DynamicEntitySpec();
    spec.recordID = record;
    spec.appearanceName = n"random";
    spec.position = pos;
    spec.orientation = face;
    spec.persistState = false;
    spec.persistSpawn = false;
    spec.alwaysSpawned = true;
    spec.spawnInView = false;
    spec.active = true;
    spec.tags = [n"ThreatAssessment", n"ThreatAssessment.Corp"];
    let u = new NCPDHCorpUnit();
    u.id = des.CreateEntity(spec);
    u.spawnedAt = now;
    u.isMech = isMech;
    ArrayPush(this.m_units, u);
  }

  private func MakeHostile(unit: ref<ScriptedPuppet>, player: ref<PlayerPuppet>) -> Void {
    let ua = unit.GetAttitudeAgent();
    let pa = player.GetAttitudeAgent();
    if IsDefined(ua) && IsDefined(pa) {
      ua.SetAttitudeTowards(pa, EAIAttitude.AIA_Hostile);
    }
    TargetTrackingExtension.InjectThreat(unit, player);
  }
}
