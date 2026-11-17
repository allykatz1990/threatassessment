# Testing Threat Assessment 0.5.0 beta

Turn on **Debug log** (Settings → Threat Assessment → General). Everything the mod decides is written
to `bin\x64\plugins\cyber_engine_tweaks\gamelog.log` as `[ThreatAssessment]` lines. Send those lines
with any report.

Expect the base game's known crash when many cars blow up (`PhysicalMeshComponent::InitializePhysicsProxy`
on a trunk part). Check the crash report before blaming the mod.

## 1. Petty crime and witnesses (no stars)

- Kill one civilian: no stars. Log: `Civilian kill 1 of 3: petty, ignored`.
- Kill three within 30 seconds: stars. Log: `threshold tripped`.
- Shoot near civilians in a rich district (Corpo Plaza). On screen: *A witness is calling NCPD*.
  - Stop the caller within 10 seconds: *The call to NCPD was cut off*.
  - Let them finish: *NCPD has been called*, then 1 star.
- Same in Santo Domingo: most witnesses log `decides not to call`.

## 2. Low stars

- At 1 star, police cars should drive to where the crime happened and the officers search there.
  Log: `sent to the crime scene`, then `at the crime scene, officers searching`.
- Response is small and slow at 1-2 stars, bigger in rich districts. Log: `Response for N stars`.
- Hide: the police keep searching for at least 5 in-game minutes. Log: `Still searching`.

## 3. The perimeter (3 stars)

- Officers form a ring about 30 m out, take cover and shoot from there. Cars park on the ring.
- Beat cops who step inside are sent back and then held. Log: `crossed into the ring`. This should
  happen much less than before.
- Sprint out of the ring: `V broke the perimeter`, and low-rank officers may flee.
- Optical camo: the police lose you as in the base game.
- 5 stars: MaxTac and heavy units go inside, others keep the ring.

## 4. Corporate districts and corporations

- Corpo Plaza at 3 stars: NCPD withdraws, one corporation takes over. 5 stars: NCPD back with it.
- Attack Arasaka or Militech guards **out in the city** (not inside their compounds) with no stars:
  *Arasaka security is on its way*, squad arrives. Not again for 2 minutes.

## 5. Dogtown and Pacifica

- Crime in Dogtown: Barghest responds, no NCPD.
- Cross the Dogtown border with stars, either way: heat cleared.
- Crime in Pacifica: no heat at all.

## 6. Patrols

- Restart the game, drive around: noticeably fewer police cars and foot patrols.
  Log on load: `Roaming patrols: N police car entries at 50%`.

## 7. Missions (quest safety)

- Play a mission with police or corporate fights (an Arasaka mission is ideal). The mod should stay
  out of the way. If anything odd happens, press **F7** to pause the mod and note what you saw.
- Watch the log for quest characters in `Entering the perimeter` or `crossed into the ring` lines.
  Those should no longer appear.

## 8. Voice lines

Stand near officers or corporate soldiers and run in the CET console:

    Game.GetScriptableSystemsContainer():Get("NCPDHSystem"):VoiceTest()

Each run plays the next line and logs it. Note which ones you actually hear.
