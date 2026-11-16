# Contributing

Thanks for helping. A few rules keep the mod compatible and easy to work on:

- **Wrap, never replace.** Use `@wrapMethod`, never `@replaceMethod`. Add every function you wrap to
  `COMPATIBILITY.md`.
- **No REDmod, no archives.** Scripts only.
- **Keep the prefix.** Everything this mod adds uses the `NCPDH` prefix so it never collides with
  other mods.
- **Quest safety first.** Anything new must do nothing while `NCPDH_QuestFree()` is false, and must
  never touch NPCs the game flags as quest characters.
- **Every feature gets a setting** in `NCPDHConfig.reds`, with a description in plain words.
- **Log your decisions.** Use `NCPDHSystem.Log()` so testers can turn on the debug log and see what
  happened.
- **One file per system:** settings, the core system, hooks into the game, and voice lines.

Testing: the game can't be run in CI, so describe what you tested in game in your pull request.
