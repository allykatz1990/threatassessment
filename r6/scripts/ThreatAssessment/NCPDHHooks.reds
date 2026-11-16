// Threat Assessment - Tactical Police & Jurisdiction Overhaul - hooks into the base game's police
// Copyright (C) 2026 the Threat Assessment authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// Every hook WRAPS a base game function (never replaces it), so other mods that wrap the same
// functions keep working. Functions wrapped (see also COMPATIBILITY.md):
//   PreventionSystem.CalculateCrimeScoreForNPC      crime filter, ramp, plateau, escalation
//   PreventionSystem.CalculateCrimeScoreForVehicle  plateau for vehicle damage
//   PreventionSystem.NotifyVehicleExplosion         destroyed police vehicles count as major crimes
//   PreventionSystem.OnCrimeWitnessRequest          witness calls about petty crime are ignored
//   PreventionSystem.TryUpdateStarState             heat freeze while the perimeter holds
//   PreventionSystem.ChangeHeatStage                tells the mod when the heat changes
// Known other mods wrapping the same functions: Gang Retaliation (CalculateCrimeScoreForNPC),
// Cop Killer (ChangeHeatStage). Both work in either load order.

// ---------------------------------------------------------------- helpers added to PreventionSystem

// False whenever a quest is steering the police. Then the mod does nothing at all.
@addMethod(PreventionSystem)
public func NCPDH_QuestFree() -> Bool {
  if !this.m_defaultHeatLevels {
    return false;   // a quest set minimum / maximum heat
  }
  if AbsF(this.m_crimeScoreMultiplierByQuest - 1.0) > 0.001 {
    return false;   // a quest changed how much crimes count
  }
  if this.m_forceEternalGreyStars || this.m_blockOnFootSpawnByQuest || this.m_blockVehicleSpawnByQuest {
    return false;
  }
  if this.IsSystemLocked() || this.IsPlayerInQuestArea() {
    return false;
  }
  return true;
}

@addMethod(PreventionSystem)
public func NCPDH_RaiseOneStar(reason: String) -> Void {
  this.HeatPipeline(reason);
}

// Asks the game for one roadblock (police car plus crew) on a road at the given distance from V.
// The base game only does this when V is driving; the perimeter also wants it on foot.
@addMethod(PreventionSystem)
public func NCPDH_RequestRoadblock(minDistance: Float, maxDistance: Float) -> Bool {
  if this.m_blockVehicleSpawnByQuest || this.ReachedRoadblockLimit() {
    return false;
  }
  let vehicleRecord: wref<Vehicle_Record>;
  let range: Vector2;
  if !this.TryGetRoadblockDataFromHeatStage(this.m_heatStage, vehicleRecord, range) {
    return false;
  }
  let vehicleIDs: array<TweakDBID>;
  ArrayPush(vehicleIDs, vehicleRecord.GetID());
  let ticketID = GameInstance.GetPreventionSpawnSystem(this.GetGameInstance()).RequestRoadBlockadeSpawn(vehicleIDs, new Vector2(minDistance, maxDistance), 2u);
  this.m_agentRegistry.CreateTicket(ticketID, vehiclePoliceStrategy.None);
  return true;
}

// ---------------------------------------------------------------- crime score

@wrapMethod(PreventionSystem)
private final func CalculateCrimeScoreForNPC(request: ref<PreventionDamageRequest>) -> Void {
  let sys = NCPDHSystem.Get(this.GetGameInstance());
  if !IsDefined(sys) || !sys.Active(this) {
    wrappedMethod(request);
    return;
  }
  let before = this.m_totalCrimeScore;
  wrappedMethod(request);
  let delta = this.m_totalCrimeScore - before;
  this.m_totalCrimeScore = before + sys.AdjustNPCScore(this, request, delta);
  if sys.TakePendingRaise() && IsDefined(this.m_preventionDataTable) {
    // The filter or escalation decided this hit earns the next star: fill the meter so the
    // base game's own pipeline raises the heat right after this function returns.
    this.m_totalCrimeScore = MaxF(this.m_totalCrimeScore, this.m_preventionDataTable.HeatThresholdCapacity());
  }
}

@wrapMethod(PreventionSystem)
private final func CalculateCrimeScoreForVehicle(request: ref<PreventionDamageRequest>) -> Void {
  let sys = NCPDHSystem.Get(this.GetGameInstance());
  if !IsDefined(sys) || !sys.Active(this) {
    wrappedMethod(request);
    return;
  }
  let before = this.m_totalCrimeScore;
  wrappedMethod(request);
  let delta = this.m_totalCrimeScore - before;
  this.m_totalCrimeScore = before + sys.AdjustVehicleScore(this, delta);
}

@wrapMethod(PreventionSystem)
public final static func NotifyVehicleExplosion(veh: ref<VehicleObject>) -> Void {
  wrappedMethod(veh);
  if !IsDefined(veh) || !veh.IsPrevention() {
    return;
  }
  let ps = veh.GetPreventionSystem();
  let sys = NCPDHSystem.Get(veh.GetGame());
  if IsDefined(ps) && IsDefined(sys) {
    sys.OnPoliceVehicleDestroyed(ps);
  }
}

// ---------------------------------------------------------------- witnesses

@wrapMethod(PreventionSystem)
protected final func OnCrimeWitnessRequest(request: ref<PreventionCrimeWitnessRequest>) -> Void {
  let sys = NCPDHSystem.Get(this.GetGameInstance());
  if IsDefined(sys) && !this.IsChasingPlayer() && sys.Active(this) && sys.ShouldIgnoreWitness() {
    sys.Log("Witness call about a petty crime: ignored");
    return;
  }
  wrappedMethod(request);
}

// ---------------------------------------------------------------- heat freeze and heat changes

@wrapMethod(PreventionSystem)
private final func TryUpdateStarState() -> Void {
  let sys = NCPDHSystem.Get(this.GetGameInstance());
  if IsDefined(sys) && sys.Active(this) {
    // Catches chases already running when a save loads, which never pass through ChangeHeatStage.
    if NCPDHSystem.Stage(this.m_heatStage) >= 3 {
      sys.EnsureTicking();
    }
    if sys.IsHoldingPerimeter() && !this.m_securityAreaResetCheck && IsDefined(this.m_player) {
      // Heat freeze: the police always know where V is while the ring holds, so the stars never
      // go grey or start to fade.
      this.SetLastKnownPlayerPosition(this.m_player.GetWorldPosition());
      this.UpdateStarStateTo(EStarState.Active);
      return;
    }
  }
  wrappedMethod();
}

@wrapMethod(PreventionSystem)
private final func ChangeHeatStage(newHeatStage: EPreventionHeatStage, heatChangeReason: String) -> Void {
  let prev = NCPDHSystem.Stage(this.m_heatStage);
  wrappedMethod(newHeatStage, heatChangeReason);
  let cur = NCPDHSystem.Stage(this.m_heatStage);
  if prev != cur {
    let sys = NCPDHSystem.Get(this.GetGameInstance());
    if IsDefined(sys) {
      sys.OnHeatChanged(this, prev, cur);
    }
  }
}
