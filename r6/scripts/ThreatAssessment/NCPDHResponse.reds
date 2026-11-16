// Threat Assessment - Tactical Police & Jurisdiction Overhaul - response size per star
// Copyright (C) 2026 the Threat Assessment authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// How many police the game sends is set by one heat table record per district and star level
// (PreventionHeatTable_Record): maximum officers, cars chasing, support cars, car tickets and the
// cooldowns between cars. Each time the game picks the table for the current heat, this scales
// those values by the percentages in the settings, using TweakXL to change single values (never
// whole files). The original values are cached for the whole game session, so scaling never
// stacks, and turning the mod off puts the originals back the next time heat changes.

// Lives for the whole game session (not reset by loading a save), unlike scriptable systems.
public class NCPDHTweakCache extends ScriptableService {
  private let m_intIDs: array<TweakDBID>;
  private let m_intBase: array<Int32>;
  private let m_floatIDs: array<TweakDBID>;
  private let m_floatBase: array<Float>;

  public static func Get() -> ref<NCPDHTweakCache> {
    return GameInstance.GetScriptableServiceContainer().GetService(n"NCPDHTweakCache") as NCPDHTweakCache;
  }

  public func BaseInt(flat: TweakDBID) -> Int32 {
    let i = 0;
    while i < ArraySize(this.m_intIDs) {
      if Equals(this.m_intIDs[i], flat) {
        return this.m_intBase[i];
      }
      i += 1;
    }
    let v = TweakDBInterface.GetInt(flat, -1);
    ArrayPush(this.m_intIDs, flat);
    ArrayPush(this.m_intBase, v);
    return v;
  }

  public func BaseFloat(flat: TweakDBID) -> Float {
    let i = 0;
    while i < ArraySize(this.m_floatIDs) {
      if Equals(this.m_floatIDs[i], flat) {
        return this.m_floatBase[i];
      }
      i += 1;
    }
    let v = TweakDBInterface.GetFloat(flat, -1.0);
    ArrayPush(this.m_floatIDs, flat);
    ArrayPush(this.m_floatBase, v);
    return v;
  }
}

public abstract class NCPDHResponse {

  // Scales one heat table for its star level. With allowed false (mod off, or a quest steering the
  // police) the original values are put back.
  public static func Apply(sys: ref<NCPDHSystem>, table: ref<PreventionHeatTable_Record>, stage: Int32, allowed: Bool, corpZone: Bool) -> Void {
    let cache = NCPDHTweakCache.Get();
    if !IsDefined(sys) || !IsDefined(table) || !IsDefined(cache) || stage < 1 {
      return;
    }
    let cfg = sys.Config();
    let countPct = 100;
    let delayPct = 100;
    if allowed && cfg.responseScaling {
      countPct = NCPDHResponse.CountPercent(cfg, stage);
      if corpZone && cfg.corpTakeover && stage >= 3 && stage <= 4 {
        // 3-4 stars in a corporate district: the corporation handles it, NCPD sends nobody.
        countPct = 0;
      } else {
        if corpZone && stage >= cfg.corpStars {
          countPct = Max(10, countPct * cfg.corpNcpdShare / 100);
        }
      }
      delayPct = stage <= 2 ? cfg.lowStarDelay : 100;
    }
    let id = table.GetID();
    let changed = false;
    changed = NCPDHResponse.ScaleInt(cache, id, t".maxUnitCount", countPct) || changed;
    changed = NCPDHResponse.ScaleInt(cache, id, t".maxUnitFallbackCount", countPct) || changed;
    changed = NCPDHResponse.ScaleInt(cache, id, t".spawnedEngagedCars", countPct) || changed;
    changed = NCPDHResponse.ScaleInt(cache, id, t".spawnedSupportCars", countPct) || changed;
    changed = NCPDHResponse.ScaleInt(cache, id, t".vehicleTicketsAmount", countPct) || changed;
    changed = NCPDHResponse.ScaleFloat(cache, id, t".vehicleSpawnCooldown", delayPct) || changed;
    changed = NCPDHResponse.ScaleFloat(cache, id, t".vehicleTicketCooldown", delayPct) || changed;
    if changed {
      TweakDBManager.UpdateRecord(id);
      sys.Log(s"Response for \(stage) stars: \(countPct)% units and cars, \(delayPct)% time between cars (\(TDBID.ToStringDEBUG(id))): max officers \(table.MaxUnitCount()), cars \(table.SpawnedEngagedCars()) + \(table.SpawnedSupportCars()) support, tickets \(table.VehicleTicketsAmount())");
    }
  }

  // How many officers the police would have at most for this table and star level, before any
  // corporate takeover. Used to size the corporate response when NCPD has handed over.
  public static func ExpectedPolice(sys: ref<NCPDHSystem>, table: TweakDBID, stage: Int32) -> Int32 {
    let cache = NCPDHTweakCache.Get();
    if !IsDefined(cache) {
      return 0;
    }
    let flat = table;
    TDBID.Append(flat, t".maxUnitCount");
    let base = cache.BaseInt(flat);
    if base < 0 {
      return 0;
    }
    let pct = sys.Config().responseScaling ? NCPDHResponse.CountPercent(sys.Config(), stage) : 100;
    return base * pct / 100;
  }

  public static func CountPercent(cfg: ref<NCPDHConfig>, stage: Int32) -> Int32 {
    switch stage {
      case 1:
        return cfg.response1;
      case 2:
        return cfg.response2;
      case 3:
        return cfg.response3;
      case 4:
        return cfg.response4;
      case 5:
        return cfg.response5;
    }
    return 100;
  }

  private static func ScaleInt(cache: ref<NCPDHTweakCache>, record: TweakDBID, field: TweakDBID, pct: Int32) -> Bool {
    let flat = record;
    TDBID.Append(flat, field);
    let base = cache.BaseInt(flat);
    if base < 0 {
      return false;
    }
    let want = base;
    if pct != 100 {
      want = Max(1, RoundF(Cast<Float>(base) * Cast<Float>(pct) / 100.0));
      if base == 0 || pct == 0 {
        want = 0;
      }
    }
    if TweakDBInterface.GetInt(flat, -1) == want {
      return false;
    }
    return TweakDBManager.SetFlat(flat, ToVariant(want));
  }

  private static func ScaleFloat(cache: ref<NCPDHTweakCache>, record: TweakDBID, field: TweakDBID, pct: Int32) -> Bool {
    let flat = record;
    TDBID.Append(flat, field);
    let base = cache.BaseFloat(flat);
    if base < 0.0 {
      return false;
    }
    let want = base * Cast<Float>(pct) / 100.0;
    if AbsF(TweakDBInterface.GetFloat(flat, -1.0) - want) < 0.01 {
      return false;
    }
    return TweakDBManager.SetFlat(flat, ToVariant(want));
  }
}
