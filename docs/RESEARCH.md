# Comparable Games & Simulation Architecture — Research Notes

## Context

Before building further systems, we researched four genuinely independent bodies of prior art that "Worldly Life" draws from: text-driven life simulators (BitLife and its lineage), character-driven dynasty simulation (the Crusader Kings series), trade/piracy simulation (Patrician, Port Royale, Sid Meier's Pirates!, and the Dope Wars/Taipan! text-trading lineage), and the underlying technical problem common to all of them — simulating a persistent world without simulating every NPC in full detail every tick. This doc distills that research into concrete, actionable findings, and ties them back to the tiered-simulation model already proposed in [ARCHITECTURE.md](ARCHITECTURE.md).

Every claim below is sourced; where a source could not be fetched directly (bot-protected pages), that's flagged so wording is treated as paraphrase, not verbatim quotation.

---

## 1. Life Simulation — BitLife and Its Lineage

### Time and the aging loop
BitLife's time advancement is **discrete and player-triggered**, not continuous — a single "Age" button advances one year (or six months, an optional setting) and fires that year's bundle of events before returning control. There is no simulation between presses. Life stages (childhood → school → adulthood → old age) are soft narrative phases layered on the age counter that gate which menus/actions are available, not a hard state machine.

Two useful contrast points:
- **Kudos** (2006) uses a much denser turn: one day per turn, only ages 20–30, one activity choice per day. It trades breadth-of-life for density-of-choice — useful if we ever want a "zoomed in" mode for a specific life period.
- **Alter Ego** (1986, designed by a psychologist) used a **node-tree map** per life phase where the player chose *which* experience to pursue next, rather than everything firing automatically — a materially different feel from BitLife's "just press Age."

### Event system
No public teardown of BitLife's actual event data exists, but the studio's own site confirms events are **entirely hand-authored** (no procedural generation) — implying a tagged event-table architecture: each event is a record with eligibility conditions (age, country, career, prior-choice flags) and per-choice stat deltas, run through a generic presentation engine. Choices are almost never single-axis — they're legible trade-offs across 2+ stats plus a relationship/record consequence (e.g., sucking up to a teacher raises Grades but lowers Popularity), which is what makes a technically simple yearly tick feel like "every choice matters."

**Reigns** (2016) is the more rigorously documented event-selection architecture worth studying directly: a small set of always-visible faction meters forms the current game state, and the pool of available decision-cards is **silently recomputed every turn** from that state before a card is drawn — mixing pure random draws with authored branching chains unlocked by prior choices. This "state → filtered card pool → binary choice → state" loop is clean and provably scalable to our event system.

Friends and enemies in BitLife are **not independently simulated** — they're lightweight flagged records (identity + relationship score + a reappearance cooldown) that a later event-selection pass matches against, with pre-written text referencing the earlier encounter on reappearance. This is a cheap, effective illusion of continuity worth copying directly for our Tier 2 background population.

### Careers
Job **availability** gates on education + stat thresholds; **promotion** is a separate rolling check influenced by an explicit "Work Harder" action, relationship with your supervisor, and (for some tracks like military) a largely fixed schedule regardless of performance. Concrete tree shapes we can mirror:
- **Medical**: High School → University (Biology/Chemistry major) → Medical School → GP → apply for specialist openings as they appear.
- **Military**: enlisted (no degree, tops at a fixed senior enlisted rank) vs. officer (degree required, tops at General/Admiral) — two parallel tracks from the same starting point, exactly the "Peasant → Soldier → Knight → Noble" vs "instant conscript" split we already envision.
- **Criminal**: fixed rank ladder (Associate → Soldier → Underboss → Godfather) advanced by committing crimes and paying tribute, with a genre-appropriate twist — going to prison does *not* remove you from the syndicate, unlike a legitimate job, which is a nice small rule that differentiates the risk profile of that whole career path.

### Relationships and the inheritance bridge
This is the most directly relevant mechanic to our BitLife-meets-CK ambition: BitLife's **Will/Testament and "Generations"** system lets a player leave everything to one heir or split it among several, with the option to continue play as that heir when the current character dies (including inherited money, and heirlooms as a distinct item category). This is essentially a minimal, single-lineage version of Crusader Kings' succession system (§2) — we can treat it as the floor, and CK's succession-law variety as the ceiling to grow into.

### Stats and UI
Four always-visible core stats (Happiness, Health, Smarts, Looks) plus derived Money/Karma/Fame, with **temporary, context-scoped secondary stats** spun up only within a subsystem (Grades/Popularity while in school, a prison behavior rating while incarcerated, a follower count for influencers) and dropped from the UI once that phase ends. This "small persistent HUD + disposable subsystem stats" pattern is directly reusable for our mobile UI budget.

The main screen is styled as a literal scrollable **diary feed** — every age-up appends entries, which gives a free chronicle/history log without a separate screen. Death produces a tombstone-styled summary card with a themed **Ribbon** (one of ~40, each tied to a dominant life pattern — wealth, fame, longevity, crime) that doubles as permanent meta-progression. Our own Chronicle screen (per ARCHITECTURE.md) is exactly this pattern already; the Ribbon idea is worth adding as a cheap, high-value addition.

---

## 2. Dynasty & World Simulation — Crusader Kings I/II/III

### The character-driven model
CK's foundational choice, present since CK1 (2004): **the character is the unit of simulation, not the province.** Every ruler, courtier, and vassal — landed or not — is a full character object (traits, skills, relationships, opinions, health, AI personality). The map is a *consequence* of who holds what, never a directly-simulated territorial process. Territory changes only as a side effect of a character dying, marrying, or losing a war. Lead designer Henrik Fåhraeus called this "Emergent Stories": narrative emerges from simulating character sheets, not from scripted plot. **This validates our architecture doc's WorldState-as-character-graph approach directly** — a single title-tree data structure (barony→county→duchy→kingdom→empire, each node tagged with both a de jure parent and a de facto liege) can drive succession, vassalage, and war obligations simultaneously, because they all walk the same graph.

### Succession
Death **triggers succession** for any held titles; a character's heir is actually pre-computed continuously (not just rolled at death). What transfers: split titles per the active succession law, plus *all* gold, artifacts, and men-at-arms to the primary heir, plus a fraction of the deceased's legitimacy and any unpressed claims. If no valid heir exists, titles escheat up to the dead ruler's own liege.

Succession law families worth modeling, roughly in complexity order:
1. **Single-heir**: Primogeniture (oldest child), Ultimogeniture (youngest), House Seniority (oldest living house member, not necessarily a child).
2. **Partition/gavelkind**: split titles among all eligible children, primary heir guaranteed the capital + primary title.
3. **Elective**: vassal electors (defined as everyone two title-ranks below the elected title) vote among eligible candidates — CK3's Tanistry Elective variant specifically favors distant relatives over close family, modeling real Gaelic succession.
4. **Gender laws** stack orthogonally on top of any of the above (Male Only / Male Preference / Equal / Female Preference / Female Only).

Changing succession law costs a large resource sum and requires vassal consent (positive opinion, or they're terrified/imprisoned) — succession law itself is gated by the vassal-opinion system in §2.2, not a free player choice.

### The vassal/feudal contract
Every vassal has exactly one liege (a strict pyramid, a deliberate simplification of real medieval multi-vassalage). Each vassal owes **tax** and **levy** obligations at a liege-set tier (Exempt→Low→Normal→High→Extortionate for tax; None→Low→Normal→High→Massive for levy). Raising obligations imposes a permanent opinion penalty on that vassal and a temporary realm-wide instability penalty. Contribution is *halved* if a vassal's holdings sit outside their liege's proper de jure hierarchy — the game mechanically discourages "unnatural" conquest-born empires.

**This is the direct mechanical answer to our architecture doc's example chain** ("King declares war → Lord receives military obligation → Army begins recruiting"): the liege's own levies mobilize immediately on war declaration, and vassals contribute per their contract's Levy tier; refusing to answer the call brands a vassal an oathbreaker, a punishable offense. If a liege's demands exceed what vassals will bear, vassals form **Factions** (independence, dissolution, liberty, claimant) that can accumulate enough combined strength to revolt, throwing their *entire* military at their liege rather than the fractional levy they'd contribute to a foreign war — which is why large realms are structurally fragile unless the ruler keeps a large personal demesne.

### Traits, AI, and event eligibility
Personality traits are the AI's actual decision weights, not flavor text — the wiki documents concrete numeric hooks (Wrathful: +35 Boldness, +20 Vengefulness; Brave: +10 Attraction Opinion). AI personality is scored along named axes (Boldness, Zeal, Rationality, Honor, Compassion, Vengefulness, roughly −100..+100), which the AI's scored-modifier decision formulas read directly. Traits also gate which decisions/interactions even *appear* (Forgiving unlocks "Abandon Hook," Arbitrary unlocks "Dismiss Hook"), and schemes have explicit trait modifiers (Honest/Just/Compassionate take a −40 to −80 penalty toward accepting a murder scheme; Greedy gets +20 from bribes).

At a coarser level, CK3 buckets AI rulers into a small number of **Economic Archetypes** (Warlike, Cautious, Builder, Unpredictable) for long-horizon behavior — a deliberate simplification so "smarter AI" work is amortized across a handful of buckets rather than re-authored per character. **This maps directly onto our Tier 1 (local/relevant NPC) simulation**: give each Tier-1 character a small numeric personality-axis block plus one archetype tag, and both event eligibility and simple AI decisions can be a shared scoring function rather than bespoke per-NPC logic.

### Event system architecture (concrete, directly implementable)
This is the most reusable material found across all four research threads. Both CK2 and CK3 use a declarative scripting format (plain text, not compiled) with the same conceptual pieces:

```
# CK3 event structure
superexample.1337 = {
    type = character_event
    title = "..."
    trigger = { culture = { has_innovation = innovation_guilds } }
    immediate = { add_gold = 50 }
    option = {
        name = "..."
        trigger_event = { id = yearly.1012  days = { 7 14 } }
        ai_chance = { base = 50  modifier = { add = 15  has_trait = sadistic } }
    }
}
```

Two complementary scheduling models, both worth implementing:
- **Mean Time to Happen (MTTH)**: an event isn't triggered by direct code; it's scheduled with a random draw such that, after the specified mean time, it has a 50% chance of having fired. Modifiers scale the mean time multiplicatively (low factor = fires sooner). This is a cheap per-character "next eligible fire time" recalculated whenever a relevant modifier changes — ideal for ambient/flavor events.
- **on_action + weighted random**: named hook points the engine calls automatically at specific moments (birth, death, marriage, a yearly pulse), each optionally firing a **weighted table** of events (`100 = event_a, 50 = event_b, 50 = nothing`) — ideal for reactive events tied to a specific game action, and far cheaper than a very-low-MTTH event for the same purpose (this is literally why Paradox introduced weight-based on_action events in a patch — MTTH events were measured as slower).

Decisions (the player/AI-initiated counterpart to events) separate `is_shown` (visible), `is_valid` (currently takeable), `cost` (resource gate), and `ai_check_interval` (how often the AI re-evaluates it — a direct AI-performance lever). Triggers compose with standard boolean logic (AND/OR/NOT/NAND/NOR) over a scope-walking syntax (`title:k_france.holder = father`).

**Recommendation**: adopt this exact two-tier scheduler shape (MTTH-style ambient events + on_action-style weighted reactive events) for our own `event_resolver.gd` rather than inventing a different model — it's a proven, cheap, and expressive design.

### Intrigue and schemes
CK3's Schemes track four measurable numbers per active scheme: **Potential** (max success chance, capped 95%), **Secrecy** (chance of non-detection, breached via a monthly roll), **Breaches** (5 = auto-fail), and **Advantage** (a spendable currency that buys success-chance up to Potential). Agents (up to 5) fill mechanically distinct roles with skill multipliers (Assassin: +0.75/Prowess +0.25/Intrigue; Muscle: +1/Prowess). This is a clean, self-contained subsystem we could implement independently of the rest of the world sim once we're ready for a criminal/intrigue career branch.

### Simulating hundreds of characters efficiently
Directly documented performance detail is thin (some dev diaries were bot-blocked), but what's confirmed: CK3's launch performance diary reported the simulation advancing faster on multi-core hardware specifically "thanks to improved threading" versus CK2, implying meaningful per-character work is parallelizable across characters within a tick. The team's own retrospective credited a shift from **"programming individuals" to "programming systems"** — general, reusable frameworks (the trait/opinion/AI-archetype system above) that many characters share and the engine can batch-evaluate — as the single biggest AI/performance/stability win, "significantly reducing crashes" as a side effect of the same refactor. A GDC talk on CK3's DNA-based procedural portrait system cites "tens of thousands of distinctive characters" as an explicit target scale even for a purely cosmetic subsystem, giving a rough sense of the total world population CK3 assumes exists even though only a small "currently relevant" subset gets full AI attention each tick.

### Map/territory hierarchy
Six title tiers (Barony→County→Duchy→Kingdom→Empire→Hegemony), vassalage strictly rank-ordered. **De jure** (the fixed, lore-defined "proper" hierarchy) vs. **de facto** (who actually controls what) is the core tension: holding land within your proper de jure hierarchy grants +50% taxes/levies, holding it outside costs −50% and −5 vassal opinion. **De jure drift**: if a duchy sits inside the "wrong" kingdom for 100 continuous years, its de jure kingdom updates to match — the legal map slowly reshapes toward sustained control. A **De Jure Claim Casus Belli** lets a ruler wage a bounded, legible war to complete a claim they already partially hold (cost scales with county count in the target), which is both how the map "correctly" re-consolidates and how the AI gets a bounded, legible war-goal instead of unlimited conquest.

---

## 3. Trading & Piracy Simulation

### Regional economy: simulated, not scripted — and why that's not expensive
Patrician IV's director stated plainly that its economy is "fully simulated... there is, apart from missions, no scripting at all" — construction, production, buying, transport, selling, and consumption are all simulated in a closed system across 32 towns, each specializing in producing some goods and lacking others. Crucially, this is rendered to the player as a **4-diamond supply/demand indicator** (four red = extreme shortage/high price, four green = extreme surplus/low price) rather than raw numbers — much more legible in a text/card UI than a price chart.

Port Royale 4 adds a genuinely useful refinement: **price memory/hysteresis**. A town that's had reliable recent supply "relaxes" and keeps prices low even during a brief shortage; a town starved for a long stretch pays a premium even right after a shipment arrives — because *recent history* of availability, not just the instantaneous stock number, feeds the price function. This is cheap to implement (an exponential moving average of recent stock alongside the current stock) and meaningfully more convincing than a naive stock-vs-price curve.

Uncharted Waters' older, simpler model — selling in a port pushes its price down, buying pushes it up, full stop, no separate production simulation — is a legitimate fallback floor if the full Patrician model is more than we need for a first pass.

### Travel and risk
Port Royale models wind/current as a first-class input to travel time (routing *around* a headwind can beat the geometrically shorter upwind path) and marks storm-prone zones. For risk during transit, the two clean patterns found: Port Royale ties encounter risk to convoy composition (escorts vs. unarmed cargo ships, larger convoys better for long/dangerous routes, leaner convoys more efficient for short milk-runs); the older text-trading games (below) resolve it as a simple per-leg encounter-chance roll. **We don't need to simulate geography in real time to capture "route risk" — model each leg as (day-cost, danger modifier, encounter-chance roll), exactly as the text-trading lineage already does.**

### Combat resolution — strong precedent for text/auto-resolve over real-time
This is a key validating finding for our stated design (text-based battles): even within games that *offer* real-time naval combat, players largely don't use it. Patrician IV offers a deliberately minimal battle system specifically because the devs didn't want combat friction competing with the trading loop, and ships a one-click auto-resolve. Port Royale 3/4 offers both a manual real-time battle *and* full stat-based auto-resolve — community reporting is that **most players default to auto-resolve** because manual combat is "too much hassle" relative to the payoff. Commercially successful games built entirely around menu/turn-based resolution exist in this space too: **Star Traders: Frontiers** resolves both space combat and trading purely through turn-based menus (ability selection, range bands, an option to close and board) with zero real-time layer. **Sunless Sea** resolves most danger through text-based branching choices with explicit risk percentages, using a slow top-down travel map only for pacing.

Sid Meier's Pirates! remains the reference for what a *fuller* combat model looks like if we ever want one: ship positioning + cannon volleys, then a boarding phase combining an abstracted crew-count comparison with a one-on-one captain swordfight resolved by relative attack/defend timing (high/low/middle) — notably, the original 1987 game's swordfighting was *more* elaborate and the 2004 remake deliberately simplified it, a useful precedent that even the genre's gold standard trimmed combat complexity over time rather than adding to it.

### Text-based trading precedents — directly validates our approach
This is the load-bearing finding of the whole research pass. The Dope Wars/Taipan!/Space Trader lineage proves a genuinely satisfying trading game needs nothing more than: a handful of locations (6–8), a handful of goods (4–12), per-good-per-location price *ranges* (Dope Wars' canonical ruleset is literally hard-coded uniform-random ranges per drug, no simulation at all — e.g., Cocaine 15000–29999, Weed 300–899), a hard turn/day counter creating urgency (Dope Wars: 30 days, hard stop), an inventory-capacity constraint forcing portfolio decisions, and a binary/ternary menu choice for risk events (Taipan!: Fight/Run, or pay escalating protection money; Space Trader: Fight/Flee/**Surrender**, where surrendering costs most of your cargo but preserves your ship — a genuinely useful "lesser evil" option many trading games omit). Escalating risk over time is modeled cheaply too — Dope Wars' police-encounter chance climbs roughly 0.5%/day as the game progresses, a second clock pressuring the player alongside a loan shark's compounding daily interest.

**King of Dragon Pass** is the strongest evidence that pure text/menu resolution can carry real depth: 614 hand-written event scenes, each referencing prior decisions, proving the *ceiling* on "does this feel rich" is set by event-writing craft and callback design, not by adding simulation fidelity. Combined with Patrician's supply/demand *state* (§3.1) sitting underneath a Dope-Wars-style text-resolution skeleton, this gives us a complete, low-risk architecture for the merchant career: simulated regional stock/price state (cheap, per-town counters) + text-menu buy/sell/travel/encounter resolution (proven fun on its own even with zero simulation, per Dope Wars) + investment in event-writing variety for the "soul" of the system.

### Reputation across factions
Sid Meier's Pirates! tracks a **separate reputation ladder per nation** (you can be a Duke with Spain and a nobody with France simultaneously), with real tension: attacking a nation you're at war with helps your standing with their enemies, but attacking a *neutral* nation always costs reputation regardless of the broader war state. Uncharted Waters Online's variant is more relevant to a merchant-first game: reputation is generated by **investment volume** in a nation's cities rather than combat, which ties the reputation system directly into the trading loop instead of siloing it as a separate "quest currency."

---

## 4. Simulation Architecture — Making a Persistent World Affordable

This section is the direct technical answer to our hardest problem, and it's backed by both real open-source Godot code and named, documented AAA techniques.

### What real open-source projects actually do (code inspected directly)
No open-source project solves the full problem — BitLife-style clones (`OpenLife`, `PyLife`, `Life-Simulator1`) only ever simulate the single player character, with "friends"/"family" as inert data bags mutated only on interaction; there is no open-source Crusader Kings-alike engine, only content mods in Paradox's own format. But several real Godot grand-strategy prototypes independently converged on a shared architecture worth adopting directly:

- **[Thomas-Holtvedt/opengs](https://github.com/Thomas-Holtvedt/opengs)** (163 stars): a `Database` autoload singleton (`extends Node`) holds all world state as plain dictionaries (`Dictionary[String, Country]`, `Dictionary[String, Province]`), while `Country`/`Province` themselves `extends Resource` — deliberately not `Node`, kept cheap and natively serializable. World content loads from plain text/JSON "definition" files plus per-entity "history" files via dedicated `*_importer.gd` classes — **the same definition-file + dated-history-file split Crusader Kings itself uses** (see §2's character history-file example), independently reinvented in Godot.
- **[SamTheBlow/grand-strategy-game](https://github.com/SamTheBlow/grand-strategy-game)** (16 stars, actively maintained): the most instructive repo found. Every gameplay change — including RNG advancement itself — is a serializable `Action` object (`to_raw_dict()`/`from_raw_dict()`) applied through a central `Game.apply_action()`, with a lockable, seedable RNG wrapper for deterministic replay. Independent subsystems register as `GameComponent`s with an explicit `priority_index` so update order is data, not hardcoded sequencing. None of its core simulation classes (`Game`, `Province`, `Country`) extend `Node` — they're implicitly `RefCounted`.
- **[dementive/gsg](https://github.com/dementive/gsg)**: when GDScript-level performance genuinely isn't enough, the answer found in the wild is a compiled C++ engine module using the `flecs` ECS library — not a GDScript ECS addon (several exist — GECS, godot-ecs, gdECSv4 — but all explicitly note they can't match compiled-language ECS performance). **Recommendation: don't reach for a GDScript ECS framework prematurely; plain RefCounted/Resource objects in dictionaries are simpler to debug and sufficient until profiling proves otherwise, with a C++/flecs module as the documented escape hatch if it's ever needed.**

**This directly confirms and refines our architecture doc's existing design**: entities as `RefCounted`, a `WorldState` autoload as a thin dictionary-based registry (not a god-object with logic embedded), and content defined in external data files loaded through importers — we'd already landed on the right shape independently; this research adds the "definition file + dated history file" pattern and the `Action`-object-for-all-mutation pattern as concrete refinements worth adopting.

### Level-of-detail / simulation tiering — a well-established technique family with real names
"AI LOD" (or "simulation LOD") is a named, established pattern, not something we'd be inventing:
- **Assassin's Creed Unity**: 10,000 crowd NPCs on screen, but only ~40 actually AI-controlled and ~120 rendered at high resolution at any time — the rest are recycled through an object pool that swaps low-detail for high-detail NPCs as player attention moves, invisibly, with a single shared "brain" animating the low tier in aggregate.
- **Watch Dogs: Legion**'s "Census" system (a named GDC talk) generates and simulates the entire population's schedules/relationships/jobs so *any* pedestrian can be promoted to a fully playable character on demand — the closest AAA analog to our "every NPC has a life, most of it statistical until the player cares" ambition.
- **RimWorld's Storyteller**: incidents fire via a Poisson-process-style "mean time between" check per interval, weighted by data-defined category/population/difficulty curves (`IncidentDef` data references a `workerClass` for logic) — a cheap statistical substitute for full causal simulation of "why did this happen," directly reusable for our background world events (a war breaking out, a king dying) without simulating every possible precondition every tick.
- **Crusader Kings 3 itself** doesn't ship a formal LOD system, but the community had to build one via mods/patches: an "Obscured by Distance" trait applied to rulers/courtiers outside the player's relevance range mechanically throttles their event frequency and AI activity, and official patches added a curated "always simulate" whitelist (rulers, commanders, close kin, active plot participants) with statistical culling for everyone else — **this is a very close match to our own Tier 0/1/2 proposal, and the concrete lesson is to implement tier membership as data on the entity (a flag/trait) rather than a hardcoded branch, so it's tunable and debuggable.**
- **The Sims 4**'s "Neighborhood Stories" simulates aging/pregnancy/career/death for unplayed households in the background, decoupled from full needs/routing simulation — and these subsystems are independently toggleable, i.e., tiering isn't one on/off switch but several.
- **Kenshi** is a cautionary example: by default it only simulates what's near the player and freezes/teleport-resumes everything else, and a *community* project had to retrofit true background simulation after the fact — evidence that even a game explicitly built around "a living world" doesn't solve this for free; it has to be designed in from the start, which is exactly what we're doing now rather than retrofitting later.

### Data-driven event authoring — the common shape across CK3, RimWorld, and Dwarf Fortress
All three converge on the same four principles, independent of engine or genre: (1) content lives in plain text/JSON, not compiled code, so it's diffable, moddable, and editable by non-programmers; (2) engine code exposes a stable, named set of hook points (CK3's on_actions, RimWorld's incident categories, Dwarf Fortress's generation phases) that data plugs into, rather than the programmer writing every event; (3) "when is this valid" (trigger/data) and "what happens" (effect/worker-class) are cleanly separated so content can be tuned without touching logic; (4) history is modeled as a sorted sequence of dated events replayed against entity state — which composes naturally with save/load (a save is just "state as of the last replayed event" plus the log) and with our "world continues independent of the player" requirement.

### Godot-specific conventions confirmed
- Model dynasties, characters, provinces as `RefCounted` (cheapest, no scene-tree overhead) or `Resource` (if native `.tres` (de)serialization is wanted, with a noted gotcha: Resources are cached/shared by path unless explicitly `duplicate()`d). Reserve `Node` strictly for things that must live in the scene tree — visual representations and UI.
- A single autoload singleton as a thin dictionary-based registry (matches our `WorldState` design already) — keep gameplay logic in separate systems, not embedded in the autoload itself.
- For save/load at world scale, prefer explicit `to_raw_dict()`/`from_raw_dict()` methods over relying on Godot's native Resource serialization once entity count grows past a few hundred — it decouples the save format from engine-internal class shape and doubles as the same format usable for an event/action log.

---

## 5. Synthesis — What This Means for Worldly Life

Cross-referencing all four research threads against [ARCHITECTURE.md](ARCHITECTURE.md):

1. **Our existing Tier 0/1/2 simulation model is validated by real precedent**, not just a reasonable-sounding idea — it's the same shape CK3's community-patched courtier culling, Watch Dogs Legion's Census, AC Unity's NPC pooling, and Sims 4's Neighborhood Stories all independently converged on. The refinement this research adds: **implement tier membership as data on the entity (a flag/trait), not a hardcoded branch** — this is what makes it tunable, debuggable, and consistent with how we'll already be doing event eligibility.

2. **Adopt a two-tier event scheduler**, modeled directly on CK's MTTH (ambient/flavor events, a per-character "next eligible fire time" recalculated on modifier change) + on_action weighted-random (reactive events tied to a specific game action, e.g. `on_marriage`, `on_ruler_death`, `on_war_declared`). This is a proven, cheap, expressive design we don't need to invent from scratch.

3. **Model world content as definition files + dated history files**, the pattern CK3 uses and that opengs independently reinvented in Godot — a character's biography (or a settlement's, or a kingdom's) is a sorted list of dated events replayed at load time, which is simultaneously our save format, our event log, and our Chronicle screen's data source for free.

4. **The vassal/feudal contract system gives us the concrete mechanism for the exact chain our architecture doc already describes** ("King declares war → Lord receives military obligation → Army begins recruiting → Player can be called to service") — tax/levy obligation tiers on each vassal relationship, liege war-declaration mobilizes the liege's own levies immediately and issues a call-to-arms that vassals answer per their contract tier or become "oathbreakers."

5. **The merchant/trading career should be built as: cheap simulated regional stock/price state (per-town counters with a short-term rolling average, rendered as a coarse shortage/surplus indicator, not raw numbers) + text-menu resolution for travel/encounters/combat** — this isn't a corner-cutting compromise, it's a genre-validated design (Patrician's own director explicitly chose simplicity for legibility; Port Royale's own playerbase prefers auto-resolve over real-time combat; the entire Dope Wars/Taipan! lineage proves the loop is fun on pure menus with zero simulation underneath).

6. **Battle/combat resolution should default to stat-comparison/auto-resolve with a short branching-menu escalation** (fight/hold/retreat/protect-yourself, matching our architecture doc's example choices already), not real-time or animated combat — directly validated by what players in adjacent commercial games actually choose when given the option.

7. **Inheritance/succession can start as BitLife's simple single-heir Will system and grow toward CK's full succession-law variety** (primogeniture → partition → elective) as a natural difficulty/depth ramp rather than needing to build the complex version first.

8. **Traits should function as real decision weights, not flavor text**, from day one — even a minimal numeric personality-axis block (courage, ambition, honesty, greed) attached to Tier 0/1 characters lets us reuse the same scoring approach for event eligibility, simple AI choices, and relationship compatibility, avoiding bespoke per-character logic as the character count grows.

None of this requires an architecture rewrite — it's a set of concrete refinements and validated design choices layered onto the plan already in ARCHITECTURE.md, plus two genuinely new, low-cost additions worth folding in: a BitLife-style **Ribbon/epitaph system** for the Chronicle screen, and modeling background-world events through an explicit **on_action-style hook table** rather than ad hoc trigger checks scattered through code.

---

## Sources

**Life simulation**: [BitLife Fandom Wiki](https://bitlife-life-simulator.fandom.com/) (Age, Events, Stats, Careers, Education, Relationships, Generations, Inheritance, Will/Testament, Ribbons, God Mode pages), [bitlifeapp.com/about](https://bitlifeapp.com/about/), [Game Developer: Stillfront acquires Candywriter](https://www.gamedeveloper.com/business/stillfront-group-acquires-casual-game-maker-candywriter-for-74-4-million), [Wikipedia: Kudos](https://en.wikipedia.org/wiki/Kudos_(video_game)), [Wikipedia: Alter Ego (1986)](https://en.wikipedia.org/wiki/Alter_Ego_(1986_video_game)), [Game Developer: Reigns adaptive narrative deep dive](https://www.gamedeveloper.com/design/game-design-deep-dive-creating-an-adaptive-narrative-in-i-reigns-i-), plus career-specific guides from ProGameGuides, Gfinity, WriterParty, Gamertweak (see agent transcripts for full list).

**Crusader Kings**: [ck3.paradoxwikis.com](https://ck3.paradoxwikis.com/) (Event_modding, Triggers, Effects, Succession, Succession_laws, Title, Casus_belli, Traits, Schemes, Death), [ck2.paradoxwikis.com/Event_modding](https://ck2.paradoxwikis.com/Event_modding), [Bret Devereaux (acoup.blog): "Rascally Vassals"](https://acoup.blog/2022/09/23/collections-teaching-paradox-crusader-kings-iii-part-iia-rascally-vassals/), [Henrik Fåhraeus, GDC 2014 "Emergent Stories in CK2"](https://media.gdcvault.com/GDC2014/Presentations/Fahraeus_Henrik_Emergent_Stories_in.pdf), [Shacknews: final CK3 dev diary on AI performance](https://www.shacknews.com/article/120064/final-crusader-kings-3-developer-diary-deeply-discusses-modding-ai-performance), [GDC Vault: CK3 DNA-based portrait system](https://gdcvault.com/play/1027354/Creating-a-Portrait-System-Based).

**Trading & piracy**: [GameWatcher: Patrician IV director interview](https://www.gamewatcher.com/interviews/patrician-iv-interview/11366), Port Royale 4 Steam guides on production costs and economy, [PCGamesN: Port Royale 4 review](https://www.pcgamesn.com/port-royale-4/review), [sidmeierspirates.fandom.com](https://sidmeierspirates.fandom.com/) (Weather, Wind, Factions, Governor, Rank, Fencing, Treasure Galleon), [Wikipedia: Taipan!](https://en.wikipedia.org/wiki/Taipan!), [dopewars.sourceforge.io](https://dopewars.sourceforge.io/), [Kevin Burke: "DopeWars Explained"](https://kevin.burke.dev/old_kevin/dopewars-explained/), [Wikipedia: Space Trader (Palm OS)](https://en.wikipedia.org/wiki/Space_Trader_(Palm_OS)), [Designer Notes: Offworld Trading Company GDC postmortem](https://www.designer-notes.com/offworld-trading-company-gdc-postmortem/), King of Dragon Pass developer blog and StrategyWiki.

**Simulation architecture**: [Thomas-Holtvedt/opengs](https://github.com/Thomas-Holtvedt/opengs), [SamTheBlow/grand-strategy-game](https://github.com/SamTheBlow/grand-strategy-game), [dementive/gsg](https://github.com/dementive/gsg), [lampe-games/godot-open-rts](https://github.com/lampe-games/godot-open-rts), [GameAIPro Chapter 14: "Phenomenal AI Level-of-Detail Control with the LOD Trader"](http://www.gameaipro.com/GameAIPro/GameAIPro_Chapter14_Phenomenal_AI_Level-of-Detail_Control_with_the_LOD_Trader.pdf), [GDC Vault: "Massive Crowd on Assassin's Creed Unity"](https://gdcvault.com/play/1022411/Massive-Crowd-on-Assassin-s), [GDC Vault: "Census — The Systemic Backbone Behind Play As Anyone in Watch Dogs: Legion"](https://www.gdcvault.com/play/1027018/Census-The-Systemic-Backbone-Behind), [RimWorld-Decompile (GitHub)](https://github.com/), [Sims Wiki: Story progression](https://sims.fandom.com/wiki/Story_progression), [Dwarf Fortress Wiki: Advanced world generation](https://dwarffortresswiki.org/index.php/Advanced_world_generation), [Steam Workshop: "A Culling of the Weak" CK3 mod](https://steamcommunity.com/workshop/filedetails/?id=3604013167), [Nexus Mods: Qyvaria CK3 Performance](https://www.nexusmods.com/crusaderkings3/mods/179).

*Note: some forum-hosted dev diaries (Paradox forums) and a small number of wiki pages returned bot-protection errors on direct fetch; content sourced from those is marked as paraphrase from search-engine snippets rather than verbatim quotation in the original agent reports.*
