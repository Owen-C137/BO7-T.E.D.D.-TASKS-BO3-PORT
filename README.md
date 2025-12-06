# T.E.D.D. TASKS - Black Ops 3 Port

A fully-featured port of the T.E.D.D. Tasks system from Call of Duty: Black Ops 7, bringing dynamic challenges, progressive difficulty, and tier-based rewards to your Black Ops 3 Zombies maps.

## Features

### Challenge System
- **Dynamic Machine Spawning** - Machines spawn at random locations each round
- **Progressive Difficulty** - Three challenge tiers (Rare → Epic → Legendary) with escalating requirements
- **Kill-Based Challenge** - Complete kill objectives within time limits
- **Round Scaling** - Difficulty automatically scales with round number (10% increase per round, capped at 250%)
- **Tier Advancement** - Complete Rare to unlock Epic, complete Epic to unlock Legendary
- **Time Pressure** - 40 seconds for Rare, 60 for Epic, 80 for Legendary (each tier gets full time)

### Reward System
- **Tier-Based Rewards** - Better tiers = better rewards
  - **Rare**: 2-3 basic rewards (points, ammo, basic powerups)
  - **Epic**: 3-4 improved rewards (includes perks!)
  - **Legendary**: 3-4 premium rewards (high chance for Juggernog, Double Tap, etc.)
- **No Duplicates** - Never get the same reward type twice in one crate
- **Weighted Loot** - Rare items are truly rare, common items appear more often
- **Guaranteed Rewards**:
  - Epic: At least 1 powerup OR perk
  - Legendary: At least 1 perk AND 1 powerup
- **Quality Tiers** - Higher tiers favor premium perks and powerups
- **Shareable Rewards** - Melee a reward to share it with your team!

### UI System
- **Real-Time Progress Tracking** - Live kill counter and timer on-screen
- **Tier Visuals** - Color-coded UI (Green → Blue → Purple)
- **Machine Spawn Notifications** - Alert when new machines appear
- **Completion/Failure Overlays** - Clear feedback on challenge results
- **Reward Display** - Shows which tier rewards you earned

### Configuration
Extensive configuration options via `zm_tedd_tasks_config.gsh`:
- Enable/disable challenges
- Adjust difficulty scaling
- Modify time limits per tier
- Configure reward weights and guarantees
- Set machine spawn behavior
- Customize cooldowns and costs

---

## Installation

### Step 1: Copy Files

1. **Copy BO3_ROOT contents** to your Black Ops 3 root directory:
   ```
   Call of Duty Black Ops III/
   ```
   This includes:
   - Map prefabs
   - Model exports
   - Sound assets
   - FX files

2. **Copy YOUR_USERMAPS contents** to your map folder:
   ```
   Call of Duty Black Ops III/usermaps/YOUR_MAP_NAME/
   ```
   This includes:
   - GSC/CSC scripts
   - UI widgets
   - Zone file

### Step 2: Script Integration

1. **Add to your main map GSC** (`usermaps/YOUR_MAP_NAME/scripts/zm/zm_YOUR_MAP_NAME.gsc`):
   ```gsc
   // TEDD Tasks System
   #using scripts\zm\tedd_tasks\zm_tedd_tasks_core;
   ```

2. **Add to your main map CSC** (`usermaps/YOUR_MAP_NAME/scripts/zm/zm_YOUR_MAP_NAME.csc`):
   ```gsc
   // TEDD Tasks System
   #using scripts\zm\tedd_tasks\zm_tedd_tasks_core;
   
   // Custom red eyes for horde zombies (add after #using statements)
   #define RED_EYE_FX "zombie/fx_glow_eye_red"
   #precache("client_fx", RED_EYE_FX);
   ```

3. **Add to your zone file** (`zone_source/YOUR_MAP_NAME.zone`):
   ```
   include,hud_t7
   include,tedd_tasks
   ```
4. **Add to your sound zone file** (`sound\zoneconfig/YOUR_MAP_NAME.szc`):
   ```
    {
    "Type" : "ALIAS",
    "Name" : "tedd_tasks",
    "Filename" : "tedd_tasks.csv",
    "Specs" : [ ] 
    },
   ```

### Step 3: Radiant Setup

**Location**: `map_source/_prefabs/_OwensAssets/bo7/tedd_tasks/`

**Pre-Made Prefabs** (Drag & Drop Ready):
- `tedd_location_1.map`
- `tedd_location_2.map`
- `tedd_location_3.map`

**Installation**:
1. Drag a prefab into your map
2. Position it where you want the challenge machine to spawn
3. **Stamp the prefab** 
4. Resize the `trigger_multiple` zone to define the "Kill in Zone" / "Survive in Zone" challenge area
5. Done!

---

## Adding Additional Machines (Optional)

If you want more than 3 machine locations:

### Manual Setup

1. **Drag in** `challenge_machine.map` prefab (do NOT stamp)

2. **Add KVPs to the machine entity**:
   - Key: `script_int`
   - Value: `4` (or next sequential number)
   
   - Key: `targetname`
   - Value: `challenge_machine_spawn_4` (match the script_int number)

3. **Create a trigger_multiple** (Entity Browser):
   - Key: `targetname`
   - Value: `challenge_zone_4`
   
   - Key: `script_int`
   - Value: `4` (match the machine's script_int)

4. **Position the trigger** around the area for zone-based challenges

5. **Now stamp the prefab**

> **Important**: The `script_int` value links the machine, trigger, and reward location together. All three must have the same number.

---

## Installing with Custom HUD (Alternative Method)

If you **already have a custom HUD** installed in your map, use the `YOUR_USERMAPS-CUSTOM HUD` folder instead:

### Modified Installation Steps:

1. **Copy files from `YOUR_USERMAPS-CUSTOM HUD`** instead of `YOUR_USERMAPS`
   - This version excludes `hud_t7.zpkg` to avoid conflicts

2. **DO NOT add to your zone file:**
   ```
   include,hud_t7  // ❌ Skip this line - you already have a custom HUD
   ```

3. **Modify your existing HUD's main .lua file** (usually `T7Hud_zm_YourMap.lua`):

   **Add these require() statements** (after existing BubbleGum line):
   ```lua
   require("ui.uieditor.widgets.BubbleGumBuffs.BubbleGumPackInGame")
   
   -- TEDD Tasks Widgets
   require("ui.uieditor.widgets.HUD.ChallengeWidget.ChallengeProgress")
   require("ui.uieditor.widgets.HUD.ChallengeWidget.ChallengeComplete")
   require("ui.uieditor.widgets.HUD.ChallengeWidget.ChallengeFailed")
   require("ui.uieditor.widgets.HUD.ChallengeWidget.MachineSpawnNotification")
   ```

   **Add widget initialization** (in the `PostLoadFunc` section, after creating other widgets):
   ```lua
   -- Add TEDD Tasks widgets to HUD
   self.ChallengeProgress = CoD.ChallengeProgress.new(menu, controller)
   self:addElement(self.ChallengeProgress)
   
   self.ChallengeComplete = CoD.ChallengeComplete.new(menu, controller)
   self:addElement(self.ChallengeComplete)
   
   self.ChallengeFailed = CoD.ChallengeFailed.new(menu, controller)
   self:addElement(self.ChallengeFailed)
   
   self.MachineSpawnNotification = CoD.MachineSpawnNotification.new(menu, controller)
   self:addElement(self.MachineSpawnNotification)
   ```

   **Add cleanup** (near the bottom, after BubbleGum cleanup):
   ```lua
   element.BubbleGumPackInGame:close()
   
   -- TEDD Tasks cleanup
   element.ChallengeProgress:close()
   element.ChallengeComplete:close()
   element.ChallengeFailed:close()
   element.MachineSpawnNotification:close()
   ```

4. **Continue with Step 2 and Step 3** from the main installation guide above

---

## Configuration

Edit `scripts/zm/tedd_tasks/zm_tedd_tasks_config.gsh` to customize:

### Challenge Types
Currently enabled:
- `CHALLENGE_ENABLE_KILLS` - Kill X zombies within time limit

Future challenges (disabled by default):
- Headshots, Melee, Trap Kills, Location-based, and more

### Difficulty Scaling
```gsc
#define CHALLENGE_ROUND_SCALING_ENABLED     true
#define CHALLENGE_ROUND_SCALING_FACTOR      0.10    // 10% increase per round
#define CHALLENGE_ROUND_SCALING_MAX         2.5     // Cap at 250%
```

### Time Limits
```gsc
#define CHALLENGE_PROGRESSIVE_RARE_TIME     40      // Rare tier
#define CHALLENGE_PROGRESSIVE_EPIC_TIME     60      // Epic tier
#define CHALLENGE_PROGRESSIVE_LEGENDARY_TIME 80     // Legendary tier
```

### Reward Weights
Adjust probability of each reward type per tier:
```gsc
// Rare: Lots of points/ammo, no perks
#define WEIGHT_RARE_BONUS_POINTS    50
#define WEIGHT_RARE_AMMO            30
#define WEIGHT_RARE_POWERUP         15
#define WEIGHT_RARE_PERK            0       // No perks in Rare!

// Epic: Perks now available
#define WEIGHT_EPIC_PERK            10

// Legendary: High chance for premium rewards
#define WEIGHT_LEGENDARY_PERK       25
#define WEIGHT_LEGENDARY_POWERUP    25
```

### Machine Spawning
```gsc
#define CHALLENGE_SPAWN_PER_ROUND   true    // Spawn every round?
#define CHALLENGE_SPAWN_ROUND_DELAY 1       // Wait X rounds before first spawn
#define CHALLENGE_RANDOM_LOCATION   true    // Random location each time
```

---

## How It Works

### Game Flow
1. **Machine spawns** at start of round (or after cooldown)
2. **Activate machine** - Free to use
3. **Complete Rare tier** (10 kills in 40 seconds)
4. **Advance to Epic tier** automatically (20 kills in 60 seconds)
5. **Advance to Legendary tier** (30 kills in 80 seconds)
6. **Claim rewards** - Walk to reward crate and open it
7. **Pick up rewards** - Press F to claim your personal rewards
8. **Share rewards** - Melee a reward to make it visible to everyone!

### Challenge States
- **Idle** - Machine ready to activate
- **Active** - Challenge in progress
- **Success** - Challenge completed, rewards spawned
- **Failed** - Time ran out, machine enters cooldown (30 seconds)

### Reward System
- Each player gets their own randomized rewards (2-4 items)
- Rewards spawn in a circle around the machine
- Only visible to the owner initially
- Melee a reward to share it with your team
- First player to claim a shared reward gets it

---

## Troubleshooting

### Machine not spawning
- Check `CHALLENGE_SPAWN_ROUND_DELAY` in config (default: round 1+)
- Verify prefab has correct KVPs (`script_int`, `targetname`)
- Make sure zone file includes `tedd_tasks`

### Rewards not showing
- Verify all scripts are in `scripts/zm/tedd_tasks/`
- Check zone file has `include,tedd_tasks`
- Ensure UI widgets are in `ui/uieditor/widgets/HUD/ChallengeWidget/`

### UI not appearing
- Verify CSC has `#using scripts\zm\tedd_tasks\zm_tedd_tasks_core;`
- Check `hud_t7.zpkg` includes the widget lua files
- Make sure `T7Hud_zm_challenges.lua` is in `ui/uieditor/menus/hud/`

### Compile errors
- Ensure ALL files from YOUR_USERMAPS are copied
- Verify zone file syntax (no typos in `include,tedd_tasks`)
- Check main map GSC/CSC have the #using statements

---

## Credits

- **Treyarch:** Custom models, animations, FX, and sounds
- **Activision:** Custom GSC implementation for BO3 (developed with assistance from generative AI)

## Development Note

**No credit to me required in your map** This trap was created primarily through AI assistance, so I dont feel i deserve any credit for it - my contribution was mainly porting the models from BO7 and making sure everything worked correctly. Feel free to use this in your maps however you wish.

---

## Future Updates

Planned features:
- Additional challenge types
- Weapon rewards
- Wonder weapon rewards
- Custom challenge zones with unique objectives

---

## License

Free to use in your custom zombies maps. Credit is not required.
