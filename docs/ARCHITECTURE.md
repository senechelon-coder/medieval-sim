# Worldly Life — Architecture & Foundation Plan

## Context

This is a greenfield Godot 4 project. The vision is a portrait-mobile, primarily text/UI-driven medieval life simulator combining BitLife-style personal life sim, CK-style dynasties/world sim, AoH-style changing political map, and text-adventure-style travel/battle. Trade and piracy are active parts of the world: merchants move goods between settlements, while pirates raid routes, disrupt prices, and create opportunities or danger for the player. The world simulates independently of the player; the player is one participant in it.

This document is the foundational architecture — project structure, data models, simulation loop, save format, and phased build order — so that later systems (kingdoms, wars, economy, careers, inheritance) can be added without rewrites.

**Defaults assumed below** (flagged so they're easy to revisit, not locked in):
- **GDScript only** — fastest iteration, native mobile export path, sufficient performance if background population stays aggregated rather than simulated per-NPC per-frame.
- **Abstract province graph for the world map** — provinces as data nodes with adjacency + simple shapes, rendered stylized. Far less art/tech overhead than hand-traced polygons, and fits a text/card mobile UI.
- **Godot Resources (.tres) for static/authored game data** (occupations, goods, event tables, kingdom definitions) — inspector-editable, type-safe, no custom parser. Save games are separate (see Save Structure) — not authored data, so they use plain serialization instead.

---

## 1. Project Structure

```
medieval-sim/
  project.godot
  autoload/                  # Singletons (see Section 3)
    TimeManager.gd
    EventBus.gd
    WorldState.gd
    SaveManager.gd
    GameData.gd               # loads/holds all static Resource tables
  core/
    entities/
      character.gd             # Character data class (RefCounted, not Node)
      settlement.gd
      kingdom.gd
      dynasty.gd
      army.gd
      caravan.gd (Phase 4)
      pirate_crew.gd (Phase 4)
    simulation/
      time_system.gd
      character_lifecycle.gd    # aging, births, deaths, marriage rolls
      population_aggregate.gd   # Tier 2 statistical population
      world_tick.gd             # orchestrates per-tick simulation order
    data_models/               # Resource script *definitions* (schemas)
      occupation_def.gd
      good_def.gd
      event_def.gd
      kingdom_def.gd
      settlement_def.gd
    events/
      event_resolver.gd         # picks/executes narrative events from tables
    battle/
      battle_sim.gd              # (Phase 5) text battle resolution
    travel/
      travel_sim.gd              # (Phase 4) travel event sequencing
      trade_route_sim.gd         # merchant movement, supply, demand, and route risk
      piracy_sim.gd              # pirate activity, raids, patrols, and loot
  data/                        # Authored .tres resources (content, not code)
    occupations/
    goods/
    events/
    kingdoms/
    names/
  ui/
    screens/
      life_screen/
      character_screen/
      family_screen/
      career_screen/
      relationships_screen/
      inventory_screen/
      location_screen/
      world_map_screen/
      kingdoms_screen/
      wars_screen/
      chronicle_screen/
    components/                # reusable cards, portraits, list rows, dialogs
    shell/
      main_shell.tscn           # bottom-nav / tab shell, portrait 1080x1920 safe area
  save/
    save_schema.gd
  tests/                      # GUT or lightweight custom test scenes
```

**Key principle:** simulation state (`core/`) is plain data + logic, independent of Nodes/scenes wherever possible. UI (`ui/`) reads state and renders it; it never *owns* simulation state. This keeps the simulation testable headless and keeps save/load simple (serialize data objects, not scene trees).

---

## 2. Core Data Models

All entities are plain GDScript classes (`RefCounted`), not `Node`, so thousands can exist without scene-tree overhead. Each has `to_dict()` / `from_dict()` for saving.

### Character
```
class_name Character extends RefCounted

var id: String                      # stable UUID
var first_name: String
var last_name: String
var sex: String
var birth_date: SimDate
var death_date: SimDate = null
var alive: bool = true

var sim_tier: int                   # 0=player-detail, 1=local, 2=aggregate-only

# Relationships (store IDs, resolve via WorldState registry, not direct refs)
var dynasty_id: String
var father_id: String
var mother_id: String
var spouse_id: String
var children_ids: Array[String]

# Stats (0-100 scale)
var stats: Dictionary   # {strength, intelligence, charisma, piety, martial, stewardship, health}
var traits: Array[String]

# Life state
var occupation_id: String
var employer_id: String             # settlement/lord/organization
var location_id: String             # current settlement id
var wealth: int
var inventory: Array[ItemStack]

var skills: Dictionary              # {combat: 12, trade: 4, ...}
var titles: Array[String]           # "Lord of X", "Knight", etc.

func to_dict() -> Dictionary: ...
static func from_dict(d: Dictionary) -> Character: ...
```

Trader and pirate are supported life paths rather than special player-only modes. A trader's occupation, inventory, caravan or ship association, route knowledge, and reputation use the same character model as other careers. Pirates use occupations and traits alongside membership in a `PirateCrew`; named captains and player-relevant crew are Tier 0/1 characters, while ordinary crew can remain abstracted.

### Settlement
```
class_name Settlement extends RefCounted
var id: String
var name: String
var type: String            # village, town, castle, city
var province_id: String
var population: int                 # aggregate count
var population_sample: Array[String]  # ids of Tier-1 detailed NPCs living here
var prosperity: float
var garrison_strength: int
var goods_prices: Dictionary         # good_id -> current price (derives from GoodDef.base_price)
var lord_character_id: String
```

### Province / Kingdom / Dynasty
```
class_name Province extends RefCounted
var id: String
var name: String
var owner_kingdom_id: String
var neighbor_ids: Array[String]      # adjacency for the province graph
var settlement_ids: Array[String]
var unrest: float

class_name Kingdom extends RefCounted
var id: String
var name: String
var ruler_character_id: String
var dynasty_id: String
var province_ids: Array[String]
var at_war_with: Array[String]       # kingdom ids
var treasury: int

class_name Dynasty extends RefCounted
var id: String
var name: String
var member_ids: Array[String]
var head_character_id: String
```

### Army / War (introduced Phase 5, stubbed earlier)
```
class_name Army extends RefCounted
var id: String
var kingdom_id: String
var commander_id: String
var strength: int
var morale: float
var location_province_id: String
var soldier_ids: Array[String]       # Tier-0/1 members only; rest abstracted as "strength"

class_name War extends RefCounted
var id: String
var attacker_kingdom_id: String
var defender_kingdom_id: String
var war_score: float
var start_date: SimDate
```

### Trade routes / Caravans / Pirate crews (introduced Phase 4)
```
class_name TradeRoute extends RefCounted
var id: String
var settlement_ids: Array[String]
var transport_type: String          # road, river, coastal
var risk: float                     # bandit/pirate danger
var traffic: float

class_name Caravan extends RefCounted
var id: String
var owner_character_id: String
var member_ids: Array[String]
var inventory: Dictionary           # good_id -> quantity
var current_route_id: String
var destination_id: String
var wealth: int

class_name PirateCrew extends RefCounted
var id: String
var captain_character_id: String
var member_ids: Array[String]       # only named/relevant members
var strength: int                   # abstract ordinary crew
var morale: float
var wealth: int
var current_route_id: String
var notoriety: float
```

Trade routes connect settlements and drive the movement of goods. Traders react to price differences, risk, travel time, and available cargo capacity. Successful deliveries increase local supply and can reduce prices; raids or disrupted routes reduce supply and can raise prices. Pirate crews choose vulnerable coastal or river routes, raid traffic, sell loot, gain notoriety, and may be hunted by rulers or patrols. Both systems continue operating when the player follows another career.

### Static definitions (authored as .tres, loaded once at startup into `GameData` autoload)
`OccupationDef`, `GoodDef`, `EventDef`, `KingdomDef` (starting-world seed data), `SettlementDef` — these are read-only templates; runtime entities reference them by id, they are never mutated or saved (save files only store the runtime `Character`/`Settlement`/etc. instances above).

### Simulation tiers (the "don't simulate everyone" mechanism)
- **Tier 0 — Player & close family/household:** full `Character` object, ticked every simulated day, all systems apply (health, relationships, skills, events).
- **Tier 1 — Local/relevant characters:** other named characters in the player's settlement/army/court, or historically significant NPCs (kings, lords). Full `Character` object but ticked less frequently (e.g. monthly) with cheaper logic — lifecycle events (marriage/death/succession) still roll, but no fine-grained daily state.
- **Tier 2 — Background population:** not individual `Character` objects at all. Each `Settlement.population` is a number + a few aggregate stats (avg prosperity, unrest, mortality rate). Births/deaths/famine affect the number statistically. A Tier-2 person is promoted to Tier 1 only when they become relevant (player interacts with them, they inherit a title, etc.).

This tiering is enforced by `WorldState` (Section 3): it holds all Tier-0/1 characters in memory in a dictionary keyed by id, and only Tier-2 aggregates live inside `Settlement`.

---

## 3. Autoload Singletons (the simulation backbone)

- **`TimeManager`** — owns the current `SimDate` (day/month/year), the pause state, and simulation speed multiplier. Advances time on a real-time timer (scaled by speed) or is driven by "advance until next decision" logic during travel/battle. Emits `day_passed`, `month_passed`, `year_passed` signals. Nothing else owns time.
- **`EventBus`** — global signal hub. Systems publish (`EventBus.emit_signal("war_declared", war)`) and other systems subscribe, rather than calling each other directly. This is what implements the "King declares war → lord obligation → recruiting → player called → ..." chain from the vision doc without hard-coupling those systems.
- **`WorldState`** — the live-world registry: dictionaries of all Tier-0/1 `Character`, `Settlement`, `Province`, `Kingdom`, `Dynasty`, `Army`, `War`, `TradeRoute`, `Caravan`, and `PirateCrew` objects by id, plus the player's character id. This is *the* source of truth; UI and systems query it, never hold their own copies.
- **`GameData`** — loads all authored `.tres` definitions at boot into typed lookup dictionaries (`GameData.occupations[id]`, `GameData.goods[id]`, ...). Read-only after load.
- **`SaveManager`** — serializes `WorldState` + `TimeManager` state to/from disk (Section 5).

### Simulation loop order (driven by `TimeManager.day_passed`, orchestrated in `world_tick.gd`)
1. Time advances one day.
2. Tier-0 character update (health/age/current activity resolution, event roll).
3. Tier-1 batch update (only on its cadence, e.g. once/week or once/month, staggered across NPCs to avoid a spike).
4. Tier-2 aggregate update (settlement population/prosperity/unrest drift) — runs on a slower cadence (monthly).
5. World-level systems consume queued `EventBus` events from the day (wars progressing, succession checks, price drift) and may emit new events.
6. UI layer listens to `EventBus`/`WorldState` changes and redraws only what changed — it does not poll every frame.

Pause simply stops `TimeManager` from advancing; speed changes how much simulated time elapses per real second (or, during travel/battle, time advances in discrete jumps to the next decision point rather than continuously).

---

## 4. UI Architecture

- Single `main_shell.tscn` with a bottom tab/nav bar switching between the main areas (Life, Character, Family, Career, Relationships, Inventory, Location, World Map, Kingdoms, Wars, Chronicle) — screens are separate scenes loaded into a content container, not separate top-level scenes, so shell state (nav, notifications) persists.
- Screens are "dumb" — they read from `WorldState`/`GameData` and render; all mutation happens through simulation-layer function calls (e.g. `CharacterLifecycle.attempt_marriage(...)`), never by a screen mutating a `Character` field directly. This keeps save/load and the event chain consistent.
- Reusable `ui/components/`: character portrait card, event/decision card (title + narrative text + choice buttons — this is the primitive for both life events and battle decision prompts), stat bar, list row, map province tile.
- Portrait orientation, safe-area aware root layout; target a reference resolution (e.g. 1080x1920) with Godot's `canvas_items` stretch mode.

---

## 5. Save Structure

- Saves are **not** scene serialization. `SaveManager` walks `WorldState` and calls `to_dict()` on every live entity, producing a single nested `Dictionary`:
  ```
  {
    "save_version": 1,
    "time": {"day":.., "month":.., "year":.., "speed":..},
    "player_character_id": "...",
    "characters": { id: {...}, ... },
    "settlements": { id: {...}, ... },
    "provinces": { id: {...}, ... },
    "kingdoms": { id: {...}, ... },
    "dynasties": { id: {...}, ... },
    "armies": { id: {...}, ... },
    "wars": { id: {...}, ... },
    "trade_routes": { id: {...}, ... },
    "caravans": { id: {...}, ... },
    "pirate_crews": { id: {...}, ... }
  }
  ```
- Serialized with `JSON.stringify` to a file under `user://saves/<slot>.json` (human-readable, easy to debug/inspect during development; can move to a compressed/binary format later without changing the model layer since it's all just dict-in/dict-out).
- `save_version` + a `SaveMigration` step in `SaveManager` so future field additions don't break old saves (append-only migrations, never destructive rewrites).
- Static `GameData` definitions are **not** saved — only referenced by id and reloaded from `.tres` at boot, so content updates (rebalancing an occupation) don't require save migrations unless an id is removed/renamed.
- Autosave on day/month boundary (configurable), manual save from a menu.

---

## 6. Development Phases

**Phase 0 — Project scaffold**
Godot 4 project set up for mobile/portrait export, folder structure above, empty autoloads registered, `main_shell.tscn` with nav stub screens showing placeholder text. No simulation yet. Verifies the project runs on export target.

**Phase 1 — Time & character foundation — COMPLETE**
Implemented: `SimDate` and persistent `TimeManager`; a centralized `PlayerCharacter` model and `WorldState`; culturally structured name/family generation for all three playable realms; character creation; annual mobile-first Age Up progression; health, wealth, standing, traits, upbringing, childhood decisions, and apprenticeship; a scrollable chronicle; persistent faction music; pause/resume and safe return to menu; automatic single-slot saving; and a three-slot load screen with Slots 2–3 intentionally locked. The full flow is Main Menu → Era → Faction → Character Creation → Life, with Back navigation before play and Save & Main Menu after play. **Exit criterion met:** create a character, advance through early life, pause/resume, save, return to menu, and reload without losing identity, date, statistics, progression choices, or chronicle history.

**Phase 2 — Local world & events — COMPLETE**
Implemented serializable `Kingdom`, `Province`, `Settlement`, `Dynasty`, and Tier-1 `LocalCharacter` models; realm-specific seed geography with neighboring provinces and settlements; a usable World tab; named parents, elders, traders, spouses, siblings, and children; saved relationship scores and annual local activities; independent NPC aging, mortality, marriage, and births; independent settlement population/prosperity changes with local reports; and a data-driven event resolver with persistent choices and stat consequences. **Exit criterion met:** settlement life produces meaningful decision events, the surrounding population and economy continue changing independently, and all local-world state survives save/load.

**Phase 3 — Occupation & economy seed — IN PROGRESS**
`OccupationDef`/`GoodDef` tables, basic job assignment (peasant/farmer/soldier/trader start), wage/income tick, simple regional `goods_prices` per settlement. Traders can buy and sell goods, build trade reputation, and progress from travelling peddler toward caravan or ship ownership. **Exit criterion:** player can work an occupation, earn/spend wealth, and see prices differ between at least two settlements.

**Phase 4 — Travel, trade & piracy**
`travel_sim.gd`: multi-day travel between settlements as a day-by-day event sequence (bandits/inn/weather/trader/pirate/etc. drawn from `EventDef` travel-tagged pools), arriving updates `location_id`. `trade_route_sim.gd` moves background merchants and goods between connected settlements. `piracy_sim.gd` creates route danger, raids, loot flows, patrol responses, and pirate-hunting opportunities. The player may trade independently, join or lead a caravan, work aboard a merchant vessel, join a pirate crew, become a captain, raid traffic, or hunt pirates. **Exit criterion:** travel from settlement A to B takes multiple simulated days, trade can produce a buy-low/sell-high profit, at least one background trader changes local supply, and pirate activity can disrupt a route or trigger an encounter without player involvement.

**Phase 5 — Minimal battle & wider-world independence**
`Army`/`War` skeleton, one scripted small battle reachable via a recruitment event chain (`King declares war → obligation → recruit → player joins → battle`), `battle_sim.gd` producing the timestamped narrated-event + choice format from the vision doc, outcome affecting war score and player survival/injury. In parallel, confirm at least one *player-independent* world event can occur (e.g. an NPC king dies and succession resolves, or a second kingdom's war progresses) purely from the Tier-1/Tier-2 simulation ticking in the background. **Exit criterion (full vertical slice):** create character → time advances → ages → lives in settlement → receives events → works occupation → travels → world events happen independent of the player → gets called to a small battle → participates via text choices → outcome recorded.

**Deferred beyond the prototype** (explicitly not in scope now): full political map rendering/border changes, deep criminal/mercenary/clergy branching career trees, detailed naval combat and ship customization, inheritance-on-death/continue-as-heir, full diplomacy, disease/famine systems, Chronicle history log UI, army composition detail beyond abstracted "strength".

---

## 7. Open items to revisit later (not blocking the prototype)

- Whether background Tier-2 simulation eventually needs a coarser "world-tick" thread/off-main-loop batching once kingdom count grows — not a concern at prototype scale (1 kingdom, a few provinces).
- Randomized vs. seeded RNG per save (for reproducibility/debugging) — recommend a save-stored seed from Phase 1 onward, cheap to add now, painful to retrofit.
- Localization — out of scope now; keep narrative/event text centralized in `EventDef.tres` resources (not hardcoded strings in logic) so it isn't a rewrite later.
