// Threat Assessment - Tactical Police & Jurisdiction Overhaul - settings
// Copyright (C) 2026 the Threat Assessment authors. Written with AI assistance.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY. See the
// GNU General Public License for details: https://www.gnu.org/licenses/
//
// Settings appear in Mod Settings / Mod Configuration Menu when installed. Without them the
// defaults below apply. Every number is a starting value to be tuned in testing. All settings
// apply live.

public class NCPDHConfig {
  // ------------------------------------------------------------------ General
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Enable mod")
  @runtimeProperty("ModSettings.description", "Turn off to pause everything this mod does. The police go back to the base game's rules straight away.")
  public let enabled: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Debug log")
  @runtimeProperty("ModSettings.description", "Writes every heat decision, perimeter change and voice line to the ThreatAssessment log (CET gamelog.log) for testing and bug reports.")
  public let debugLog: Bool = true;

  // ------------------------------------------------------------------ Petty crime filter
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Petty crime filter")
  @runtimeProperty("ModSettings.displayName", "Ignore petty crime")
  @runtimeProperty("ModSettings.description", "With no stars, hurting or killing a civilian adds no heat until the kill count below is reached. Attacks on police always count.")
  public let pettyFilter: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Petty crime filter")
  @runtimeProperty("ModSettings.displayName", "Civilian kills before police care")
  @runtimeProperty("ModSettings.description", "How many civilians must die within the time below before the police respond.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "20")
  public let pettyKills: Int32 = 3;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Petty crime filter")
  @runtimeProperty("ModSettings.displayName", "Time window (seconds)")
  @runtimeProperty("ModSettings.description", "Civilian kills older than this stop counting toward the limit above.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "5")
  @runtimeProperty("ModSettings.max", "300")
  public let pettyWindow: Float = 30.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Petty crime filter")
  @runtimeProperty("ModSettings.displayName", "Ignore witness calls about petty crime")
  @runtimeProperty("ModSettings.description", "A civilian who phones in a crime the filter ignored does not start a chase. Calls about anything else still go through.")
  public let pettyWitness: Bool = true;

  // ------------------------------------------------------------------ Heat
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Heat")
  @runtimeProperty("ModSettings.displayName", "Ramp speed to 3 stars")
  @runtimeProperty("ModSettings.description", "Multiplies heat from crimes at 1 and 2 stars. Above 1 the police reach 3 stars faster.")
  @runtimeProperty("ModSettings.step", "0.1")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "5.0")
  public let rampMultiplier: Float = 1.5;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Heat")
  @runtimeProperty("ModSettings.displayName", "Plateau at 3 stars")
  @runtimeProperty("ModSettings.description", "From 3 stars, ordinary crimes stop adding heat. Only major crimes (see Escalation) push to 4 and 5 stars.")
  public let plateau: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Heat")
  @runtimeProperty("ModSettings.displayName", "Plateau leak (percent)")
  @runtimeProperty("ModSettings.description", "How much heat ordinary crimes still add during the plateau. 0 is a hard plateau, 100 is the base game.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  public let plateauLeak: Int32 = 0;

  // ------------------------------------------------------------------ Search
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Search")
  @runtimeProperty("ModSettings.displayName", "Police keep searching longer")
  @runtimeProperty("ModSettings.description", "Once the police lose sight of you they keep searching (grey stars) for at least the time below before the stars start to fade.")
  public let longSearch: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Search")
  @runtimeProperty("ModSettings.displayName", "Shortest search (in-game minutes)")
  @runtimeProperty("ModSettings.description", "Measured on the game clock. At the normal clock speed one in-game minute is about 7.5 real seconds, so 5 in-game minutes is about 40 real seconds.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "60")
  public let searchMinutes: Float = 5.0;

  // ------------------------------------------------------------------ Response size
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Response size")
  @runtimeProperty("ModSettings.displayName", "Change how many police respond")
  @runtimeProperty("ModSettings.description", "Scales the number of officers and police cars the game sends at each star level (percentages below). Applies the next time the heat changes.")
  public let responseScaling: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Response size")
  @runtimeProperty("ModSettings.displayName", "1 star (percent of base game)")
  @runtimeProperty("ModSettings.description", "Officers and cars sent at 1 star, compared with the base game.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "400")
  public let response1: Int32 = 50;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Response size")
  @runtimeProperty("ModSettings.displayName", "2 stars (percent of base game)")
  @runtimeProperty("ModSettings.description", "Officers and cars sent at 2 stars, compared with the base game.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "400")
  public let response2: Int32 = 60;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Response size")
  @runtimeProperty("ModSettings.displayName", "3 stars (percent of base game)")
  @runtimeProperty("ModSettings.description", "Officers and cars sent at 3 stars, compared with the base game. This is when the big response starts. They all go to the perimeter.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "400")
  public let response3: Int32 = 200;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Response size")
  @runtimeProperty("ModSettings.displayName", "4 stars (percent of base game)")
  @runtimeProperty("ModSettings.description", "Officers and cars sent at 4 stars, compared with the base game.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "400")
  public let response4: Int32 = 200;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Response size")
  @runtimeProperty("ModSettings.displayName", "5 stars (percent of base game)")
  @runtimeProperty("ModSettings.description", "Officers and cars sent at 5 stars, compared with the base game. MaxTac follows its own rules.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "400")
  public let response5: Int32 = 150;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Response size")
  @runtimeProperty("ModSettings.displayName", "Time between cars at 1-2 stars (percent)")
  @runtimeProperty("ModSettings.description", "How long the police take between sending cars at 1 and 2 stars, compared with the base game. 200 is twice as slow.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "50")
  @runtimeProperty("ModSettings.max", "500")
  public let lowStarDelay: Int32 = 200;

  // ------------------------------------------------------------------ Escalation
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Escalation (4 and 5 stars)")
  @runtimeProperty("ModSettings.displayName", "Major crimes for 4 stars")
  @runtimeProperty("ModSettings.description", "How many major crimes at 3 stars raise the heat to 4.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "10")
  public let eventsFor4: Int32 = 2;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Escalation (4 and 5 stars)")
  @runtimeProperty("ModSettings.displayName", "Major crimes for 5 stars")
  @runtimeProperty("ModSettings.description", "How many major crimes at 4 stars bring MaxTac.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "10")
  public let eventsFor5: Int32 = 3;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Escalation (4 and 5 stars)")
  @runtimeProperty("ModSettings.displayName", "Time window (seconds)")
  @runtimeProperty("ModSettings.description", "Major crimes older than this stop counting toward the next star.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "30")
  @runtimeProperty("ModSettings.max", "900")
  public let escalationWindow: Float = 180.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Escalation (4 and 5 stars)")
  @runtimeProperty("ModSettings.displayName", "Police kills per major crime")
  @runtimeProperty("ModSettings.description", "Every this many police killed at 3 stars or more counts as one major crime.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "20")
  public let copKillsPerEvent: Int32 = 4;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Escalation (4 and 5 stars)")
  @runtimeProperty("ModSettings.displayName", "Destroyed police vehicles count")
  @runtimeProperty("ModSettings.description", "Each police vehicle that explodes during a chase counts as one major crime.")
  public let vehicleEvents: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Escalation (4 and 5 stars)")
  @runtimeProperty("ModSettings.displayName", "Explosions on police count")
  @runtimeProperty("ModSettings.description", "Hitting police with an explosion counts as one major crime.")
  public let explosionEvents: Bool = true;

  // ------------------------------------------------------------------ Perimeter
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "3-star perimeter")
  @runtimeProperty("ModSettings.displayName", "Police set a perimeter at 3 stars")
  @runtimeProperty("ModSettings.description", "From 3 stars, officers on foot hold a ring around you and shoot from it instead of rushing in. Heat is frozen until you break out and run.")
  public let perimeter: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "3-star perimeter")
  @runtimeProperty("ModSettings.displayName", "Perimeter radius (meters)")
  @runtimeProperty("ModSettings.description", "How far from you the officers hold the ring.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "80")
  public let radius: Float = 30.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "3-star perimeter")
  @runtimeProperty("ModSettings.displayName", "Ring follow speed (meters per second)")
  @runtimeProperty("ModSettings.description", "How fast the ring re-centers on you. Run faster than this and you can break out. V sprints at about 7.")
  @runtimeProperty("ModSettings.step", "0.5")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "10.0")
  public let followSpeed: Float = 2.5;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "3-star perimeter")
  @runtimeProperty("ModSettings.displayName", "Breakout distance (meters past the ring)")
  @runtimeProperty("ModSettings.description", "How far past the ring you must get before it counts as broken.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "50")
  public let breakMargin: Float = 6.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "3-star perimeter")
  @runtimeProperty("ModSettings.displayName", "Time before a new perimeter (seconds)")
  @runtimeProperty("ModSettings.description", "After a breakout, how long before the police can form a new ring if they catch up with you.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "5")
  @runtimeProperty("ModSettings.max", "300")
  public let reformDelay: Float = 30.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "3-star perimeter")
  @runtimeProperty("ModSettings.displayName", "Officers fight from cover")
  @runtimeProperty("ModSettings.description", "Officers on the ring switch to a cautious fighting style: they pick cover (walls, cars) near the ring and stay there. Off: they stand and hold their spot on the ring.")
  public let useCover: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "3-star perimeter")
  @runtimeProperty("ModSettings.displayName", "Cover band (meters outside the ring)")
  @runtimeProperty("ModSettings.description", "With cover on, how far outside the ring an officer may pick his cover before he is sent closer. Inside the ring always sends him back out.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "4")
  @runtimeProperty("ModSettings.max", "40")
  public let coverBand: Float = 15.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "3-star perimeter")
  @runtimeProperty("ModSettings.displayName", "Police cars park on the ring")
  @runtimeProperty("ModSettings.description", "Arriving police cars stop at the ring instead of driving at you, and the officers get out there. The parked cars become cover.")
  public let carPerimeter: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Who may enter the perimeter")
  @runtimeProperty("ModSettings.displayName", "MaxTac may enter")
  @runtimeProperty("ModSettings.description", "MaxTac moves inside the ring while regular officers keep holding it. Off: MaxTac holds the ring like everyone else.")
  public let maxTacEnters: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Who may enter the perimeter")
  @runtimeProperty("ModSettings.displayName", "Heavy units may enter")
  @runtimeProperty("ModSettings.description", "Heavily armored officers (Elite rank, heavy weapons) may move inside the ring from the star level below. Beat cops and officers in ordinary body armor always stay on the ring.")
  public let heavyEnter: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Who may enter the perimeter")
  @runtimeProperty("ModSettings.displayName", "Stars before heavy units go in")
  @runtimeProperty("ModSettings.description", "The heat level at which heavy units and MaxTac may enter the ring.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "3")
  @runtimeProperty("ModSettings.max", "5")
  public let enterStars: Int32 = 5;

  // ------------------------------------------------------------------ Fleeing
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Officers fleeing")
  @runtimeProperty("ModSettings.displayName", "Low-rank officers may flee a breakout")
  @runtimeProperty("ModSettings.description", "When you break the perimeter, low-ranking officers may run instead of chasing you. The more police you have killed this chase, the more likely.")
  public let flee: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Officers fleeing")
  @runtimeProperty("ModSettings.displayName", "Flee chance per police kill (percent)")
  @runtimeProperty("ModSettings.description", "Each officer you have killed this chase adds this much to the flee chance.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "25")
  public let fleePerKill: Int32 = 5;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Officers fleeing")
  @runtimeProperty("ModSettings.displayName", "Highest flee chance (percent)")
  @runtimeProperty("ModSettings.description", "The flee chance never goes above this.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  public let fleeMax: Int32 = 60;

  // ------------------------------------------------------------------ Voice
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Voice lines")
  @runtimeProperty("ModSettings.displayName", "Officer voice lines")
  @runtimeProperty("ModSettings.description", "Officers call out the perimeter, breakouts, MaxTac arriving and giving up, using the game's own police lines.")
  public let voice: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Voice lines")
  @runtimeProperty("ModSettings.displayName", "Pause between call-outs (seconds)")
  @runtimeProperty("ModSettings.description", "Shortest time between two lines for the same moment, so officers do not talk over each other.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "2")
  @runtimeProperty("ModSettings.max", "60")
  public let voiceCooldown: Float = 8.0;
}

// Mod Settings is optional: these two versions are picked at compile time.
@if(ModuleExists("ModSettingsModule"))
public func NCPDHRegisterSettings(config: ref<NCPDHConfig>) -> Void {
  ModSettings.RegisterListenerToClass(config);
}

@if(!ModuleExists("ModSettingsModule"))
public func NCPDHRegisterSettings(config: ref<NCPDHConfig>) -> Void {}
