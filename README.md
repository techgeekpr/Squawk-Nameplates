# Squawk NamePlates

Oversized crowd control, cooldown and potion icons on enemy nameplates, for the
**World of Warcraft: Forever** beta.

Made by **Avoid Me** of **&lt;Squawk&gt;**.

One big icon per enemy nameplate, showing the single most important thing on
that player right now. Built for PvP: you should be able to tell at a glance
that the warrior is in Recklessness, the rogue just popped Evasion, or the
mage is sitting in Ice Block — without reading a row of tiny debuff squares.

## Priority

A unit usually has several things worth knowing about. Only the most
important is drawn, in this order:

| Order | Category | Border | Examples |
| --- | --- | --- | --- |
| 1 | Crowd control | red | Polymorph, Hammer of Justice, Kidney Shot, Fear, Freezing Trap, silences, disarms |
| 2 | Immunity | gold | Ice Block, Divine Shield, Blessing of Protection, Limited Invulnerability Potion |
| 3 | Defensive cooldown | blue | Shield Wall, Evasion, Vanish, Deterrence, Barkskin, Ice Barrier |
| 4 | Offensive cooldown | orange | Recklessness, Death Wish, Combustion, Adrenaline Rush, Cold Blood, Bestial Wrath |
| 5 | Potions and items | green | Free Action, Living Free Action, Restoration, the six protection potions, Mighty Rage, Swiftness |
| 6 | Racials | purple | Will of the Forsaken, Stoneform, Perception, Shadowmeld, Berserking, Blood Fury |

Each category can be switched off on its own.

## The spell data is generated, not typed

Every entry was resolved against Wowhead's Forever spell database and carries
its real spell ids — 143 auras, 751 ids. Matching prefers the id, which is
exact, covers every rank of a spell, and does not care how the name is spelled
or localised; the name is only a fallback for clients that will not hand the
id over.

That mattered: writing the list by hand produced five wrong entries that would
have sat there doing nothing. `Kick - Silenced` is really `Silenced - Kick`,
`Elemental Mastery` and `Greater Blessing of Protection` do not exist in this
database at all, and the id I believed was Insane Strength is Petrification.
None of those would ever have fired.

Potions are deliberately limited to short, fight-changing consumables. Hour
long elixirs, food and Zanza buffs are not listed: seeing "Spirit of Zanza" on
a nameplate tells you nothing useful mid-fight.

Anything missing can be added in game, and it is saved:

```
/snp scan                        list your target's auras and their category
/snp add cc Freezing Trap        watch an aura the defaults do not
/snp remove <name>               stop watching one
```

## Installing

Copy the `SquawkNamePlates` folder into:

```
World of Warcraft\_classic_beta_\Interface\AddOns\
```

Then run `Setup-SavedVariables.ps1` from inside it — see below, it matters on
this client.

**Enemy nameplates must be switched on** or there is nothing to draw on. Press
V, or run `/snp plates` to turn them on at maximum draw distance.

## Settings do not persist without the shim

The Forever beta **writes SavedVariables correctly but never restores them**,
so every addon starts each session with an empty database. This addon works
around it: `SV1`, `SV2` and `SV3` inside the addon folder are directory
junctions pointing at your `WTF\Account\<id>\SavedVariables` folders, and the
TOC loads `SV*\SquawkNamePlates.lua` as an ordinary addon file, which puts last
session's settings back before `Core.lua` runs.

```powershell
powershell -ExecutionPolicy Bypass -File .\Setup-SavedVariables.ps1
```

Junctions need no administrator rights.

## What this client allows, and what it does not

Auras read cleanly here — name, icon, stacks, dispel type and spell id are all
available — which is what makes this addon possible at all. Two caveats:

**Durations are not guaranteed.** The cooldown spiral and the countdown text
both need a readable duration and expiry, so they are optional at runtime and
simply do not draw when the client hides them. The icon still appears.

**Some booleans are secret.** `UnitIsPlayer` and `UnitCanAttack` can return
values that cannot be tested at all — doing so throws outright. Every filter
check is wrapped, and an unreadable answer shows the icon rather than erroring
or silently hiding it.

**PvP trinkets cannot be detected.** Trinket use is a combat log event, and
Midnight removed `COMBAT_LOG_EVENT_UNFILTERED` along with
`CombatLogGetCurrentEventInfo`. Nothing an addon can do brings that back.

No icon enables mouse input, deliberately: an icon over a nameplate that
accepted clicks would swallow the click meant for the plate underneath.

## Commands

```
/snp              open the options (also /squawknameplates, /bd)
/snp diag         nameplate API, cvar state, plates visible, icons showing
/snp test         put a marker on every visible nameplate for five seconds
/snp plates       turn enemy nameplates on at maximum draw distance
/snp scan         list your target's auras and the category each maps to
/snp add <category> <name>
/snp remove <name>
```

If icons do not appear, `/snp diag` will usually say why in one line.

## Files

| File | Contents |
| --- | --- |
| `Core.lua` | database, restore shim, guarded aura reading, priority resolution, slash commands |
| `Spells.lua` | the generated spell tables and the id and name lookups |
| `Display.lua` | the icon, the nameplate pool, timers, diagnostics |
| `Options.lua` | options panel |
