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

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "General")
  @runtimeProperty("ModSettings.displayName", "Pause key (keyboard)")
  @runtimeProperty("ModSettings.description", "Press to pause or resume everything this mod does, for example if a mission behaves oddly. A message shows the new state. The setting above stays as it is.")
  public let pauseKey: EInputKey = EInputKey.IK_F7;

  // ------------------------------------------------------------------ Compatibility
  // Added in 0.6.0. Other police mods that do the same job as parts of this mod are found when the
  // game starts (NCPDHCompat.reds). For each overlapping job ("area") the dropdown picks who
  // handles it. "Automatic" lets the check decide; the other two values override it. The feature
  // switches in the other categories still apply on top: an area set to Threat Assessment with
  // its feature switched off stays off.
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Compatibility")
  @runtimeProperty("ModSettings.displayName", "Automatic compatibility checks")
  @runtimeProperty("ModSettings.description", "When the game starts, looks for other police mods that do the same job as parts of this one (so far: NCPD Duty Expansion) and lets them handle it. Each job set to Automatic below follows this. Off: every job set to Automatic runs Threat Assessment's version.")
  public let autoCompat: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Compatibility")
  @runtimeProperty("ModSettings.displayName", "Starting a chase")
  @runtimeProperty("ModSettings.description", "Who decides whether a crime with no stars starts a chase: the petty crime filter and witness calls. NCPD Duty Expansion starts chases from its own witness reports and blocks the base game's, so with it installed Threat Assessment's filter and calls have nothing to act on. Automatic hands this to it in every district where its crime system is on.")
  @runtimeProperty("ModSettings.displayValues.Auto", "Automatic")
  @runtimeProperty("ModSettings.displayValues.ThreatAssessment", "Threat Assessment")
  @runtimeProperty("ModSettings.displayValues.OtherMod", "Other mod (Threat Assessment's off)")
  public let compatChaseStart: NCPDHCompatChoice = NCPDHCompatChoice.Auto;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Compatibility")
  @runtimeProperty("ModSettings.displayName", "Search time")
  @runtimeProperty("ModSettings.description", "Who decides how long the police search once they lose you (Police keep searching longer). NCPD Duty Expansion sets its own search time, shortens it if you donate to NCPD, and remembers you afterwards with Sticky Heat. Threat Assessment's minimum search would cancel the donation.")
  @runtimeProperty("ModSettings.displayValues.Auto", "Automatic")
  @runtimeProperty("ModSettings.displayValues.ThreatAssessment", "Threat Assessment")
  @runtimeProperty("ModSettings.displayValues.OtherMod", "Other mod (Threat Assessment's off)")
  public let compatSearch: NCPDHCompatChoice = NCPDHCompatChoice.Auto;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Compatibility")
  @runtimeProperty("ModSettings.displayName", "Heat at the Dogtown border")
  @runtimeProperty("ModSettings.description", "Who decides what happens to heat when you cross into or out of Dogtown. NCPD Duty Expansion carries it across as Sticky Heat on purpose. Set to Threat Assessment to keep the border as a hard jurisdiction line: the heat is cleared and Duty Expansion's Sticky Heat on the far side is put back to what it was before you crossed.")
  @runtimeProperty("ModSettings.displayValues.Auto", "Automatic")
  @runtimeProperty("ModSettings.displayValues.ThreatAssessment", "Threat Assessment")
  @runtimeProperty("ModSettings.displayValues.OtherMod", "Other mod (Threat Assessment's off)")
  public let compatDogtownBorder: NCPDHCompatChoice = NCPDHCompatChoice.Auto;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Compatibility")
  @runtimeProperty("ModSettings.displayName", "Show what was handed over")
  @runtimeProperty("ModSettings.description", "A few seconds after a save loads, a message lists the jobs another mod is handling. The debug log always lists every decision.")
  public let compatNotice: Bool = true;

  // ------------------------------------------------------------------ Petty crime filter
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Petty crime filter")
  @runtimeProperty("ModSettings.displayName", "Ignore petty crime")
  @runtimeProperty("ModSettings.description", "With no stars, hurting or killing a civilian adds no heat until the kill count below is reached. Attacks on police always count. May be handed to another mod: see Compatibility.")
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

  // ------------------------------------------------------------------ Witness calls
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Witness calls")
  @runtimeProperty("ModSettings.displayName", "Witnesses have to finish the call")
  @runtimeProperty("ModSettings.description", "With no stars, a civilian calling NCPD takes time. Kill or knock out the caller before the call goes through and nobody comes. Once you are already wanted, calls go through at once. May be handed to another mod: see Compatibility.")
  public let witnessCalls: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Witness calls")
  @runtimeProperty("ModSettings.displayName", "Call length (seconds)")
  @runtimeProperty("ModSettings.description", "How long you have to stop a caller.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "2")
  @runtimeProperty("ModSettings.max", "60")
  public let callSeconds: Float = 10.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Witness calls")
  @runtimeProperty("ModSettings.displayName", "Rich districts: chance a witness calls (percent)")
  @runtimeProperty("ModSettings.description", "City Center and Westbrook (Charter Hill, North Oak, Japantown).")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  public let callChanceRich: Int32 = 90;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Witness calls")
  @runtimeProperty("ModSettings.displayName", "Middle districts: chance a witness calls (percent)")
  @runtimeProperty("ModSettings.description", "Watson and Heywood.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  public let callChanceMid: Int32 = 60;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Witness calls")
  @runtimeProperty("ModSettings.displayName", "Poor districts: chance a witness calls (percent)")
  @runtimeProperty("ModSettings.description", "Santo Domingo, Pacifica, the Badlands and Dogtown, where nobody expects NCPD to come anyway.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  public let callChancePoor: Int32 = 25;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Witness calls")
  @runtimeProperty("ModSettings.displayName", "On-screen warning")
  @runtimeProperty("ModSettings.description", "Shows when a witness starts calling, when the call goes through, and when you cut it off.")
  public let callWarning: Bool = true;

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

  // ------------------------------------------------------------------ District wealth
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "District wealth")
  @runtimeProperty("ModSettings.displayName", "Response depends on the district")
  @runtimeProperty("ModSettings.description", "Rich districts get a faster, bigger police response; poor districts get fewer officers who take longer to come. Works on top of the per-star numbers.")
  public let wealthScaling: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "District wealth")
  @runtimeProperty("ModSettings.displayName", "Rich districts: officers (percent)")
  @runtimeProperty("ModSettings.description", "City Center and Westbrook.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "25")
  @runtimeProperty("ModSettings.max", "300")
  public let richCount: Int32 = 125;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "District wealth")
  @runtimeProperty("ModSettings.displayName", "Rich districts: time between cars (percent)")
  @runtimeProperty("ModSettings.description", "Lower is faster.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "25")
  @runtimeProperty("ModSettings.max", "300")
  public let richDelay: Int32 = 75;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "District wealth")
  @runtimeProperty("ModSettings.displayName", "Poor districts: officers (percent)")
  @runtimeProperty("ModSettings.description", "Santo Domingo, the Badlands (Pacifica and Dogtown have their own rules).")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "25")
  @runtimeProperty("ModSettings.max", "300")
  public let poorCount: Int32 = 60;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "District wealth")
  @runtimeProperty("ModSettings.displayName", "Poor districts: time between cars (percent)")
  @runtimeProperty("ModSettings.description", "Higher is slower.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "25")
  @runtimeProperty("ModSettings.max", "300")
  public let poorDelay: Int32 = 150;

  // ------------------------------------------------------------------ Crime scene and patrols
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Crime scene and patrols")
  @runtimeProperty("ModSettings.displayName", "Police go to the crime scene")
  @runtimeProperty("ModSettings.description", "At 1 and 2 stars, arriving police cars drive to where the crime happened and the officers search from there, instead of driving straight at you.")
  public let respondToScene: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Crime scene and patrols")
  @runtimeProperty("ModSettings.displayName", "Police cars in traffic (percent)")
  @runtimeProperty("ModSettings.description", "How many NCPD cars drive around in normal traffic, compared with the base game (and traffic mods). 0 removes them. Applies after restarting the game.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  public let patrolCars: Int32 = 50;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Crime scene and patrols")
  @runtimeProperty("ModSettings.displayName", "Officers on foot patrol (percent)")
  @runtimeProperty("ModSettings.description", "How many NCPD officers walk the streets, compared with the base game. 0 removes them. Officers placed at crime scenes and checkpoints by the game are not affected. Applies after restarting the game.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  public let patrolFoot: Int32 = 50;

  // ------------------------------------------------------------------ Search
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Search")
  @runtimeProperty("ModSettings.displayName", "Police keep searching longer")
  @runtimeProperty("ModSettings.description", "Once the police lose sight of you they keep searching (grey stars) for at least the time below before the stars start to fade. May be handed to another mod: see Compatibility.")
  public let longSearch: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Search")
  @runtimeProperty("ModSettings.displayName", "Shortest search (in-game minutes)")
  @runtimeProperty("ModSettings.description", "Measured on the game clock, so it follows any mod that changes how fast time passes. At the normal clock speed one in-game minute is about 7.5 real seconds. Used when the real-time option below is off.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "60")
  public let searchMinutes: Float = 5.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Search")
  @runtimeProperty("ModSettings.displayName", "Count search time in real minutes")
  @runtimeProperty("ModSettings.description", "Use real time instead of the game clock for the shortest search.")
  public let searchRealTime: Bool = false;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Search")
  @runtimeProperty("ModSettings.displayName", "Shortest search (real minutes)")
  @runtimeProperty("ModSettings.description", "Used when the real-time option above is on.")
  @runtimeProperty("ModSettings.step", "0.5")
  @runtimeProperty("ModSettings.min", "0.5")
  @runtimeProperty("ModSettings.max", "15.0")
  public let searchRealMinutes: Float = 3.0;

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
  // Default 5 since 0.6.0 (was 2): chosen by the author after in-game testing.
  public let eventsFor4: Int32 = 5;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Escalation (4 and 5 stars)")
  @runtimeProperty("ModSettings.displayName", "Major crimes for 5 stars")
  @runtimeProperty("ModSettings.description", "How many major crimes at 4 stars bring MaxTac.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "10")
  // Default 10 since 0.6.0 (was 3): chosen by the author after in-game testing. 10 is the
  // slider maximum.
  public let eventsFor5: Int32 = 10;

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
  @runtimeProperty("ModSettings.description", "From 3 stars, officers hold a ring around you and shoot from it instead of rushing in. While they search, the ring sits where they last saw you. Once they engage, heat is frozen until you break out and run.")
  public let perimeter: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "3-star perimeter")
  @runtimeProperty("ModSettings.displayName", "Perimeter radius (meters)")
  @runtimeProperty("ModSettings.description", "How far from you the officers hold the ring.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "80")
  // Default 50 since 0.6.0 (was 30): chosen by the author after in-game testing.
  public let radius: Float = 50.0;

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

  // ------------------------------------------------------------------ Corporate response
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Corporate security in corporate districts")
  @runtimeProperty("ModSettings.description", "In the districts set below, the corporation that owns the turf sends its own security alongside the police, one corporation per chase. They hold the perimeter like the police, and their elite units go in at the star level set under Who may enter the perimeter.")
  public let corpResponse: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Stars before corporate security responds")
  @runtimeProperty("ModSettings.description", "The heat level at which corporate squads start arriving.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "5")
  public let corpStars: Int32 = 3;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Response time (seconds)")
  @runtimeProperty("ModSettings.description", "How long after the heat reaches that level the first corporate squad arrives.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "180")
  public let corpDelay: Float = 20.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Time between squads (seconds)")
  @runtimeProperty("ModSettings.description", "How often the corporation checks the numbers and sends more units to match the police.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "300")
  public let corpWaveDelay: Float = 20.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "NCPD hands over at 3-4 stars")
  @runtimeProperty("ModSettings.description", "In corporate districts: NCPD handles 1-2 stars, pulls out completely at 3-4 stars and leaves it to the corporation, then comes back alongside the corporation and MaxTac at 5 stars. Off: police and corporation work side by side from the star level above.")
  public let corpTakeover: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Corporate units per 100 police")
  @runtimeProperty("ModSettings.description", "How many corporate units come for every 100 NCPD officers on the scene (at 3-4 stars with the handover on: for every 100 the police would have sent). 100 is one for one.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "300")
  public let corpRatio: Int32 = 100;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Fewest corporate units")
  @runtimeProperty("ModSettings.description", "The corporation always sends at least this many, even if few police are on the scene.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "20")
  public let corpMin: Int32 = 4;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Most corporate units at once")
  @runtimeProperty("ModSettings.description", "A ceiling to protect performance.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "4")
  @runtimeProperty("ModSettings.max", "40")
  public let corpMax: Int32 = 24;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Mech at 5 stars")
  @runtimeProperty("ModSettings.description", "Arasaka and Militech bring one mech at 5 stars.")
  public let corpMechs: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "NCPD in corporate districts (percent)")
  @runtimeProperty("ModSettings.description", "Once corporate security responds, how many police still come, compared with the normal response for that star level. Corporate numbers follow the police, so lowering this lowers both.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "10")
  @runtimeProperty("ModSettings.max", "100")
  public let corpNcpdShare: Int32 = 100;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Corporations protect their own")
  @runtimeProperty("ModSettings.description", "Attacking a corporation's guards out in the city (Arasaka, Militech, Kang Tao, Barghest) brings a squad of theirs at any heat level. Not inside their own restricted areas, in missions or against quest characters.")
  public let corpProvoke: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Squad size when provoked")
  @runtimeProperty("ModSettings.description", "How many units the corporation sends.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "12")
  public let provokeSize: Int32 = 4;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Time between provoked squads (seconds)")
  @runtimeProperty("ModSettings.description", "The shortest time before the same thing can bring another squad.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "30")
  @runtimeProperty("ModSettings.max", "600")
  public let provokeCooldown: Float = 120.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "How long a provoked squad hunts you (seconds)")
  @runtimeProperty("ModSettings.description", "After this they leave once out of sight.")
  @runtimeProperty("ModSettings.step", "10")
  @runtimeProperty("ModSettings.min", "30")
  @runtimeProperty("ModSettings.max", "600")
  public let provokeStay: Float = 180.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate response")
  @runtimeProperty("ModSettings.displayName", "Wait while a gang squad is on you")
  @runtimeProperty("ModSettings.description", "Corporate squads hold back while a They Will Remember or Gang Retaliation squad is already after you, so two ambushes never stack.")
  public let corpHoldForGangs: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate districts")
  @runtimeProperty("ModSettings.displayName", "Corpo Plaza")
  @runtimeProperty("ModSettings.description", "Arasaka Tower, Militech and Kang Tao offices: shared ground.")
  @runtimeProperty("ModSettings.displayValues.Off", "NCPD only")
  @runtimeProperty("ModSettings.displayValues.Arasaka", "Arasaka")
  @runtimeProperty("ModSettings.displayValues.Militech", "Militech")
  @runtimeProperty("ModSettings.displayValues.KangTao", "Kang Tao")
  @runtimeProperty("ModSettings.displayValues.Mixed", "Shared ground (random)")
  @runtimeProperty("ModSettings.displayValues.Barghest", "Barghest")
  public let corpCorpoPlaza: NCPDHCorpChoice = NCPDHCorpChoice.Mixed;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate districts")
  @runtimeProperty("ModSettings.displayName", "Downtown")
  @runtimeProperty("ModSettings.description", "The rest of City Center.")
  @runtimeProperty("ModSettings.displayValues.Off", "NCPD only")
  @runtimeProperty("ModSettings.displayValues.Arasaka", "Arasaka")
  @runtimeProperty("ModSettings.displayValues.Militech", "Militech")
  @runtimeProperty("ModSettings.displayValues.KangTao", "Kang Tao")
  @runtimeProperty("ModSettings.displayValues.Mixed", "Shared ground (random)")
  @runtimeProperty("ModSettings.displayValues.Barghest", "Barghest")
  public let corpDowntown: NCPDHCorpChoice = NCPDHCorpChoice.Mixed;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate districts")
  @runtimeProperty("ModSettings.displayName", "Arasaka Waterfront")
  @runtimeProperty("ModSettings.description", "Arasaka's docks and warehouses in Watson.")
  @runtimeProperty("ModSettings.displayValues.Off", "NCPD only")
  @runtimeProperty("ModSettings.displayValues.Arasaka", "Arasaka")
  @runtimeProperty("ModSettings.displayValues.Militech", "Militech")
  @runtimeProperty("ModSettings.displayValues.KangTao", "Kang Tao")
  @runtimeProperty("ModSettings.displayValues.Mixed", "Shared ground (random)")
  @runtimeProperty("ModSettings.displayValues.Barghest", "Barghest")
  public let corpArasakaWaterfront: NCPDHCorpChoice = NCPDHCorpChoice.Arasaka;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate districts")
  @runtimeProperty("ModSettings.displayName", "North Oak")
  @runtimeProperty("ModSettings.description", "The Arasaka estate and the richest hills in the city.")
  @runtimeProperty("ModSettings.displayValues.Off", "NCPD only")
  @runtimeProperty("ModSettings.displayValues.Arasaka", "Arasaka")
  @runtimeProperty("ModSettings.displayValues.Militech", "Militech")
  @runtimeProperty("ModSettings.displayValues.KangTao", "Kang Tao")
  @runtimeProperty("ModSettings.displayValues.Mixed", "Shared ground (random)")
  @runtimeProperty("ModSettings.displayValues.Barghest", "Barghest")
  public let corpNorthOaks: NCPDHCorpChoice = NCPDHCorpChoice.Arasaka;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate districts")
  @runtimeProperty("ModSettings.displayName", "Charter Hill")
  @runtimeProperty("ModSettings.description", "Westbrook's corporate offices.")
  @runtimeProperty("ModSettings.displayValues.Off", "NCPD only")
  @runtimeProperty("ModSettings.displayValues.Arasaka", "Arasaka")
  @runtimeProperty("ModSettings.displayValues.Militech", "Militech")
  @runtimeProperty("ModSettings.displayValues.KangTao", "Kang Tao")
  @runtimeProperty("ModSettings.displayValues.Mixed", "Shared ground (random)")
  @runtimeProperty("ModSettings.displayValues.Barghest", "Barghest")
  public let corpCharterHill: NCPDHCorpChoice = NCPDHCorpChoice.Off;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate districts")
  @runtimeProperty("ModSettings.displayName", "Japantown")
  @runtimeProperty("ModSettings.description", "Westbrook's entertainment district.")
  @runtimeProperty("ModSettings.displayValues.Off", "NCPD only")
  @runtimeProperty("ModSettings.displayValues.Arasaka", "Arasaka")
  @runtimeProperty("ModSettings.displayValues.Militech", "Militech")
  @runtimeProperty("ModSettings.displayValues.KangTao", "Kang Tao")
  @runtimeProperty("ModSettings.displayValues.Mixed", "Shared ground (random)")
  @runtimeProperty("ModSettings.displayValues.Barghest", "Barghest")
  public let corpJapanTown: NCPDHCorpChoice = NCPDHCorpChoice.Off;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Corporate districts")
  @runtimeProperty("ModSettings.displayName", "Dogtown")
  @runtimeProperty("ModSettings.description", "Barghest runs Dogtown and keeps NCPD out.")
  @runtimeProperty("ModSettings.displayValues.Off", "NCPD only")
  @runtimeProperty("ModSettings.displayValues.Arasaka", "Arasaka")
  @runtimeProperty("ModSettings.displayValues.Militech", "Militech")
  @runtimeProperty("ModSettings.displayValues.KangTao", "Kang Tao")
  @runtimeProperty("ModSettings.displayValues.Mixed", "Shared ground (random)")
  @runtimeProperty("ModSettings.displayValues.Barghest", "Barghest")
  public let corpDogtown: NCPDHCorpChoice = NCPDHCorpChoice.Barghest;

  // ------------------------------------------------------------------ No-go zones
  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Dogtown and Pacifica")
  @runtimeProperty("ModSettings.displayName", "Barghest responds on its turf")
  @runtimeProperty("ModSettings.description", "Barghest soldiers answer crimes in districts set to Barghest (Dogtown by default), matching the numbers NCPD would have sent. Their elites and exo suits come at 5 stars.")
  public let barghestResponse: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Dogtown and Pacifica")
  @runtimeProperty("ModSettings.displayName", "Stars before Barghest responds")
  @runtimeProperty("ModSettings.description", "The heat level at which Barghest starts sending soldiers.")
  @runtimeProperty("ModSettings.step", "1")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "5")
  public let barghestStars: Int32 = 1;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Dogtown and Pacifica")
  @runtimeProperty("ModSettings.displayName", "NCPD stays out of Barghest turf")
  @runtimeProperty("ModSettings.description", "NCPD is not allowed in Dogtown: no officers or cars at any star level. Only MaxTac comes, at 5 stars. Officers who follow you in turn back.")
  public let dogtownNoNcpd: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Dogtown and Pacifica")
  @runtimeProperty("ModSettings.displayName", "Heat stops at the Dogtown border")
  @runtimeProperty("ModSettings.description", "Dogtown is its own jurisdiction. Cross into Dogtown and all NCPD heat is gone; leave Dogtown and the heat you earned with Barghest stays behind. May be handed to another mod: see Compatibility.")
  public let dogtownBorder: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Dogtown and Pacifica")
  @runtimeProperty("ModSettings.displayName", "No police in Pacifica")
  @runtimeProperty("ModSettings.description", "NCPD doesn't patrol or respond in Pacifica. Crimes there add no heat and witnesses don't call. Come in with stars and the police turn back, and the heat clears after the time below.")
  public let pacificaNoPolice: Bool = true;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Dogtown and Pacifica")
  @runtimeProperty("ModSettings.displayName", "Heat clears in Pacifica after (seconds)")
  @runtimeProperty("ModSettings.description", "Come into Pacifica with stars and NCPD gives up after this long. While you are still wanted, gates like the Dogtown checkpoint stay shut and the guards treat you as a wanted criminal.")
  @runtimeProperty("ModSettings.step", "5")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "300")
  public let pacificaClearSeconds: Float = 15.0;

  @runtimeProperty("ModSettings.mod", "Threat Assessment")
  @runtimeProperty("ModSettings.category", "Dogtown and Pacifica")
  @runtimeProperty("ModSettings.displayName", "Not even MaxTac in Pacifica")
  @runtimeProperty("ModSettings.description", "With no police in Pacifica on, MaxTac stays out too. Off: MaxTac still comes at 5 stars.")
  public let pacificaNoMaxTac: Bool = true;

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
