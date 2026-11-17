// Threat Assessment - Tactical Police & Jurisdiction Overhaul - fewer roaming patrols
// Copyright (C) 2026 the Threat Assessment authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// Police cars in traffic and officers on foot patrol are not part of the police system: they come
// from the city's crowd tables (the community registry in the always-loaded world sector). When
// that sector loads, this scales the weight of every police entry by the patrol settings. Only
// weights are changed, nothing is replaced, so traffic mods that edit the same tables (Night City
// Alive, Night City Traffic Overhaul) keep their changes and ours stack on top. Officers placed at
// crime scenes and checkpoints by the game are separate and not touched. Idea credit: Night City
// Alive edits the same registry this way.

public class NCPDHPatrols extends ScriptableService {

  private cb func OnLoad() {
    GameInstance.GetCallbackSystem()
      .RegisterCallback(n"Resource/Load", this, n"OnSectorLoaded")
      .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\always_loaded_1.streamingsector"));
  }

  private cb func OnSectorLoaded(event: ref<ResourceEvent>) {
    let sector = event.GetResource() as worldStreamingSector;
    if !IsDefined(sector) {
      return;
    }
    let cfg = new NCPDHConfig();
    NCPDHRegisterSettings(cfg);
    if !cfg.enabled || (cfg.patrolCars >= 100 && cfg.patrolFoot >= 100) {
      return;
    }
    let count = sector.GetNodeCount();
    let i = 0;
    while i < count {
      let node = sector.GetNode(i) as worldCommunityRegistryNode;
      if IsDefined(node) && IsDefined(node.crowdCreationRegistry) {
        this.Scale(node, cfg);
      }
      i += 1;
    }
  }

  private func Scale(node: ref<worldCommunityRegistryNode>, cfg: ref<NCPDHConfig>) -> Void {
    let cars = 0;
    let foot = 0;
    let carMult = Cast<Float>(cfg.patrolCars) / 100.0;
    let footMult = Cast<Float>(cfg.patrolFoot) / 100.0;
    let n = ArraySize(node.crowdCreationRegistry.creationData);
    let i = 0;
    while i < n {
      let j = 0;
      while j < 4 {
        let size = ArraySize(node.crowdCreationRegistry.creationData[i].timePeriods[j].charactersData);
        let k = 0;
        while k < size {
          let entry = node.crowdCreationRegistry.creationData[i].timePeriods[j].charactersData[k];
          let id = StrLower(TDBID.ToStringDEBUG(entry.characterRecordId));
          let isPolice = StrContains(id, "police") || StrContains(id, "ncpd");
          if isPolice && StrBeginsWith(id, "vehicle.") && carMult < 1.0 {
            node.crowdCreationRegistry.creationData[i].timePeriods[j].charactersData[k].weight = entry.weight * carMult;
            cars += 1;
          }
          if isPolice && StrBeginsWith(id, "character.") && footMult < 1.0 {
            node.crowdCreationRegistry.creationData[i].timePeriods[j].charactersData[k].weight = entry.weight * footMult;
            foot += 1;
          }
          k += 1;
        }
        j += 1;
      }
      i += 1;
    }
    if cfg.debugLog {
      ModLog(n"ThreatAssessment", s"Roaming patrols: \(cars) police car entries at \(cfg.patrolCars)%, \(foot) foot patrol entries at \(cfg.patrolFoot)%");
    }
  }
}
