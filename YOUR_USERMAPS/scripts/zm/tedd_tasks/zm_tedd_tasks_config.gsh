
// TEDD Tasks System - Configuration
// Staged Implementation: Phase 1 - Horde Challenge Only

// CORE SYSTEM CONFIGURATION

#define CHALLENGE_COST                      0       // Cost to start a challenge (0 = free)
#define CHALLENGE_COOLDOWN                  60      // Seconds before can start another challenge
#define CHALLENGE_REQUIRES_POWER            true    // Require power to be on before machines spawn

// MACHINE CONFIGURATION
// Machine Model & Properties
#define CHALLENGE_MACHINE_MODEL             "sat_zm_obelisk_tesla_tower_silver_fxanim"
#define CHALLENGE_MACHINE_RADIUS            64      // Trigger radius
#define CHALLENGE_MACHINE_HEIGHT            72      // Trigger height
#define CHALLENGE_MACHINE_FX                "_OwensAssets/bo7/tedd_machine_marker/tedd_trial_marker"

// Machine Bone Tags (Material States)
#define MACHINE_TAG_IDLE                    "bone_501061dce59c73f2"    // Default state when spawned
#define MACHINE_TAG_ACTIVATED               "bone_501060dce59c723f"    // Challenge in progress
#define MACHINE_TAG_SUCCESS                 "bone_50105ddce59c6d26"    // Challenge completed successfully
#define MACHINE_TAG_FAILED                  "bone_50105cdce59c6b73"    // Challenge failed/timeout
#define MACHINE_TAG_SMILE                   "bone_50105edce59c6ed9"    // Unused (smiley face)
#define MACHINE_TAG_NEUTRAL                 "bone_50105fdce59c708c"    // Unused (orange straight face)

// Machine Spawn Configuration
#define CHALLENGE_SPAWN_PER_ROUND           true    // Spawn machine every round?
#define CHALLENGE_SPAWN_ROUND_DELAY         1       // Wait X rounds before first spawn
#define CHALLENGE_MAX_ACTIVE                1       // Only 1 machine active at a time
#define CHALLENGE_RANDOM_LOCATION           true    // Pick random location from available spawns
#define CHALLENGE_DESPAWN_ON_COMPLETE       true    // Remove machine when challenge completes
#define CHALLENGE_DESPAWN_ON_FAIL           true    // Keep machine visible after failure
#define CHALLENGE_FAIL_COOLDOWN             30      // Seconds before failed machine returns to idle (if DESPAWN_ON_FAIL = false)

// TIER SYSTEM
// Tier Definitions (3 Tiers + Ultra for special use)
#define CHALLENGE_TIER_RARE                 0
#define CHALLENGE_TIER_EPIC                 1
#define CHALLENGE_TIER_LEGENDARY            2
#define CHALLENGE_TIER_ULTRA                3       // Reserved for special rewards/future use

// Tier Rewards (points for completing challenge)
#define CHALLENGE_TIER_RARE_REWARD          1000
#define CHALLENGE_TIER_EPIC_REWARD          1500
#define CHALLENGE_TIER_LEGENDARY_REWARD     2500
#define CHALLENGE_TIER_ULTRA_REWARD         5000    // Reserved for special rewards

// ROUND SCALING CONFIGURATION
#define CHALLENGE_ROUND_SCALING_ENABLED     true    // Enable/disable scaling
#define CHALLENGE_ROUND_SCALING_FACTOR      0.10    // 10% increase per round
#define CHALLENGE_ROUND_SCALING_MAX         2.5     // Cap at 250% of base
#define CHALLENGE_ROUND_SCALING_START       1       // Start scaling from round 1

// Challenge Type Definitions
#define CHALLENGE_TYPE_SURVIVE_HORDE        "survive_horde"
#define CHALLENGE_TYPE_KILLS                "kills"
#define CHALLENGE_TYPE_HEADSHOTS            "headshots"
#define CHALLENGE_TYPE_MELEE                "melee"
#define CHALLENGE_TYPE_KILL_IN_LOCATION     "kill_in_location"
#define CHALLENGE_TYPE_SURVIVE_IN_LOCATION  "survive_in_location"
#define CHALLENGE_TYPE_KILL_ELEVATION_HIGH  "kill_elevation_high"
#define CHALLENGE_TYPE_KILL_ELEVATION_LOW   "kill_elevation_low"
#define CHALLENGE_TYPE_STANDING_STILL       "standing_still"
#define CHALLENGE_TYPE_CROUCHING            "crouching"
#define CHALLENGE_TYPE_SLIDING              "sliding"
#define CHALLENGE_TYPE_JUMPING              "jumping"
#define CHALLENGE_TYPE_TRAP_KILLS           "trap_kills"
#define CHALLENGE_TYPE_WEAPON_CLASS         "weapon_class"
#define CHALLENGE_TYPE_EQUIPMENT_KILLS      "equipment_kills"

// Challenge Enable/Disable Toggles
#define CHALLENGE_ENABLE_SURVIVE_HORDE      true   // Phase 1: Horde challenge
#define CHALLENGE_ENABLE_KILLS              true    // Phase 3: Basic kills challenge
#define CHALLENGE_ENABLE_HEADSHOTS          true   // Phase 3: Headshot challenge
#define CHALLENGE_ENABLE_MELEE              true   // Phase 3: Melee challenge
#define CHALLENGE_ENABLE_KILL_IN_LOCATION   true   // Kill zombies inside zone
#define CHALLENGE_ENABLE_SURVIVE_IN_LOCATION true  // Survive inside zone
#define CHALLENGE_ENABLE_KILL_ELEVATION_HIGH true  // Kill from above zombies
#define CHALLENGE_ENABLE_KILL_ELEVATION_LOW  true  // Kill from below zombies
#define CHALLENGE_ENABLE_STANDING_STILL      true  // Kill while not moving
#define CHALLENGE_ENABLE_CROUCHING           true  // Kill while crouched
#define CHALLENGE_ENABLE_SLIDING             true  // Kill while sliding
#define CHALLENGE_ENABLE_JUMPING             true  // Kill while airborne
#define CHALLENGE_ENABLE_TRAP_KILLS          true  // Kill with sawblade trap
#define CHALLENGE_ENABLE_WEAPON_CLASS        true  // Kill with specific weapon class
#define CHALLENGE_ENABLE_EQUIPMENT_KILLS     true  // Kill with equipment (grenades, betties, monkeys)

// HORDE CHALLENGE CONFIGURATION
// Time Limits per Tier (seconds) - How long to survive the horde
#define CHALLENGE_TIER_RARE_TIME            60      // 1 minute survival (Rare)
#define CHALLENGE_TIER_EPIC_TIME            90      // 1.5 minute survival (Epic)
#define CHALLENGE_TIER_LEGENDARY_TIME       120     // 2 minute survival (Legendary)
#define CHALLENGE_TIER_ULTRA_TIME           180     // 3 minutes (special/future use)

// Horde Spawn Configuration
#define HORDE_SPAWN_DELAY_BASE              0.5     // Base delay between spawns (seconds)
#define HORDE_SPAWN_DELAY_MIN               0.3     // Minimum delay (fastest spawn rate)
#define HORDE_ZOMBIES_PER_WAVE              6       // Zombies per spawn wave
#define HORDE_MAX_ACTIVE_ZOMBIES            64      // Max zombies active at once

// Horde Speed Multipliers (zombie movement speed by tier)
#define HORDE_SPEED_RARE                    1.2     // 20% faster (Rare)
#define HORDE_SPEED_EPIC                    1.4     // 40% faster (Epic)
#define HORDE_SPEED_LEGENDARY               1.6     // 60% faster (Legendary)
#define HORDE_SPEED_ULTRA                   1.8     // 80% faster (Ultra - special)

// Progressive Challenge Time Limits (seconds) - Time to complete kill-based objectives
#define CHALLENGE_PROGRESSIVE_RARE_TIME     40      // Time for Rare tier (kills/headshots/melee)
#define CHALLENGE_PROGRESSIVE_EPIC_TIME     60      // Time for Epic tier
#define CHALLENGE_PROGRESSIVE_LEGENDARY_TIME 80     // Time for Legendary tier

// Kills Challenge Requirements (BASE - scales with round)
#define CHALLENGE_TIER_RARE_KILLS           10
#define CHALLENGE_TIER_EPIC_KILLS           20
#define CHALLENGE_TIER_LEGENDARY_KILLS      30

// Headshots Challenge Requirements (BASE - ~50% of kills, scales with round)
#define CHALLENGE_TIER_RARE_HEADSHOTS       15
#define CHALLENGE_TIER_EPIC_HEADSHOTS       25
#define CHALLENGE_TIER_LEGENDARY_HEADSHOTS  40

// Melee Challenge Requirements (BASE - ~40% of kills, scales with round)
#define CHALLENGE_TIER_RARE_MELEE           5
#define CHALLENGE_TIER_EPIC_MELEE           10
#define CHALLENGE_TIER_LEGENDARY_MELEE      15

// Kill in Location Challenge Requirements (BASE - scales with round)
#define CHALLENGE_TIER_RARE_KILL_IN_LOCATION    8
#define CHALLENGE_TIER_EPIC_KILL_IN_LOCATION    15
#define CHALLENGE_TIER_LEGENDARY_KILL_IN_LOCATION 25

// Survive in Location Challenge Requirements (PER-TIER SECONDS - does NOT scale with round)
// These are time required IN ZONE per tier (Rare 15s → Epic 25s → Legendary 40s)
// Total in-zone time needed: 15 + 25 + 40 = 80 seconds
#define CHALLENGE_TIER_RARE_SURVIVE_IN_LOCATION    15
#define CHALLENGE_TIER_EPIC_SURVIVE_IN_LOCATION    25
#define CHALLENGE_TIER_LEGENDARY_SURVIVE_IN_LOCATION 40

// Total time limit for survive_in_location challenge (overall countdown timer)
// Should be higher than total in-zone time (80s) to allow for leaving zone
#define CHALLENGE_SURVIVE_IN_LOCATION_TIME_LIMIT   90

// Kill Elevation High Challenge Requirements (BASE - scales with round)
// Player must be at least 64 units ABOVE zombie for kill to count
#define CHALLENGE_TIER_RARE_KILL_ELEVATION_HIGH    8
#define CHALLENGE_TIER_EPIC_KILL_ELEVATION_HIGH    15
#define CHALLENGE_TIER_LEGENDARY_KILL_ELEVATION_HIGH 25

// Kill Elevation Low Challenge Requirements (BASE - scales with round)
// Player must be at least 64 units BELOW zombie for kill to count
#define CHALLENGE_TIER_RARE_KILL_ELEVATION_LOW     8
#define CHALLENGE_TIER_EPIC_KILL_ELEVATION_LOW     15
#define CHALLENGE_TIER_LEGENDARY_KILL_ELEVATION_LOW 25

// Standing Still Challenge Requirements (BASE - scales with round)
// Player must be stationary (movement < 0.1) when killing zombie
#define CHALLENGE_TIER_RARE_STANDING_STILL         8
#define CHALLENGE_TIER_EPIC_STANDING_STILL         15
#define CHALLENGE_TIER_LEGENDARY_STANDING_STILL    25

// Crouching Challenge Requirements (BASE - scales with round)
// Player must be in crouch stance when killing zombie
#define CHALLENGE_TIER_RARE_CROUCHING              8
#define CHALLENGE_TIER_EPIC_CROUCHING              15
#define CHALLENGE_TIER_LEGENDARY_CROUCHING         25

// Sliding Challenge Requirements (BASE - scales with round)
// Player must be sliding when killing zombie
#define CHALLENGE_TIER_RARE_SLIDING                8
#define CHALLENGE_TIER_EPIC_SLIDING                15
#define CHALLENGE_TIER_LEGENDARY_SLIDING           25

// Jumping Challenge Requirements (BASE - scales with round)
// Player must be airborne (not on ground) when killing zombie
#define CHALLENGE_TIER_RARE_JUMPING                8
#define CHALLENGE_TIER_EPIC_JUMPING                15
#define CHALLENGE_TIER_LEGENDARY_JUMPING           25

// Trap Kills Challenge Requirements (BASE - scales with round)
// Kill zombies using the sawblade trap
#define CHALLENGE_TIER_RARE_TRAP_KILLS             8
#define CHALLENGE_TIER_EPIC_TRAP_KILLS             15
#define CHALLENGE_TIER_LEGENDARY_TRAP_KILLS        25

// Weapon Class Challenge Requirements (BASE - scales with round)
// Kill zombies with specific weapon class (random each activation)
#define CHALLENGE_TIER_RARE_WEAPON_CLASS           8
#define CHALLENGE_TIER_EPIC_WEAPON_CLASS           15
#define CHALLENGE_TIER_LEGENDARY_WEAPON_CLASS      25

// Equipment Kills Challenge Requirements (BASE - scales with round)
// Kill zombies using equipment (grenades, betties, monkeys, arnies)
#define CHALLENGE_TIER_RARE_EQUIPMENT_KILLS        6
#define CHALLENGE_TIER_EPIC_EQUIPMENT_KILLS        10
#define CHALLENGE_TIER_LEGENDARY_EQUIPMENT_KILLS   15

// How many rewards each tier gives (randomized within range)
#define REWARD_COUNT_RARE_MIN               2       // Rare: 2-3 rewards
#define REWARD_COUNT_RARE_MAX               3
#define REWARD_COUNT_EPIC_MIN               3       // Epic: 3-4 rewards
#define REWARD_COUNT_EPIC_MAX               4
#define REWARD_COUNT_LEGENDARY_MIN          3       // Legendary: 3-4 rewards (higher quality)
#define REWARD_COUNT_LEGENDARY_MAX          4

#define REWARD_TYPE_BONUS_POINTS            "bonus_points"
#define REWARD_TYPE_PERK                    "perk"
#define REWARD_TYPE_AMMO                    "ammo"
#define REWARD_TYPE_POWERUP                 "powerup"
#define REWARD_TYPE_EQUIPMENT               "equipment"
#define REWARD_TYPE_WEAPON                  "weapon"         // Regular weapon reward
#define REWARD_TYPE_WONDER_WEAPON           "wonder_weapon"  // Wonder weapon (ultra rare)

// RARE TIER WEIGHTS (Basic/Common Rewards)
#define WEIGHT_RARE_BONUS_POINTS            50      // Very common
#define WEIGHT_RARE_AMMO                    30      // Common
#define WEIGHT_RARE_POWERUP                 15      // Uncommon
#define WEIGHT_RARE_EQUIPMENT               5       // Rare
#define WEIGHT_RARE_PERK                    0       // NEVER (no perks in Rare)
#define WEIGHT_RARE_WEAPON                  0       // NEVER
#define WEIGHT_RARE_WONDER_WEAPON           0       // NEVER

// EPIC TIER WEIGHTS (Improved Rewards)
#define WEIGHT_EPIC_BONUS_POINTS            40      // Common
#define WEIGHT_EPIC_AMMO                    20      // Uncommon
#define WEIGHT_EPIC_POWERUP                 20      // Uncommon
#define WEIGHT_EPIC_EQUIPMENT               5       // Rare
#define WEIGHT_EPIC_PERK                    10      // Uncommon (perks now available!)
#define WEIGHT_EPIC_WEAPON                  4       // Rare
#define WEIGHT_EPIC_WONDER_WEAPON           1       // Very rare

// LEGENDARY TIER WEIGHTS (Premium Rewards)
#define WEIGHT_LEGENDARY_BONUS_POINTS       25      // Less common
#define WEIGHT_LEGENDARY_AMMO               10      // Uncommon
#define WEIGHT_LEGENDARY_POWERUP            25      // Common
#define WEIGHT_LEGENDARY_EQUIPMENT          5       // Uncommon
#define WEIGHT_LEGENDARY_PERK               25      // Common (perks very likely!)
#define WEIGHT_LEGENDARY_WEAPON             7       // Uncommon
#define WEIGHT_LEGENDARY_WONDER_WEAPON      3       // Rare

// Rare: No guaranteed rewards (pure RNG from weighted pool)
#define RARE_GUARANTEE_NONE                 true

// Epic: Guarantee at least 1 powerup OR perk (not just points/ammo)
#define EPIC_GUARANTEE_POWERUP_OR_PERK      true

// Legendary: Guarantee at least 1 perk + 1 powerup
#define LEGENDARY_GUARANTEE_PERK            true
#define LEGENDARY_GUARANTEE_POWERUP         true

#define POINTS_RARE_MIN                     500
#define POINTS_RARE_MAX                     1000
#define POINTS_EPIC_MIN                     1000
#define POINTS_EPIC_MAX                     1500
#define POINTS_LEGENDARY_MIN                1500
#define POINTS_LEGENDARY_MAX                2500

// Common Perks (Rare tier if enabled, common in Epic/Legendary)
#define PERK_COMMON_SPEED_COLA              "specialty_fastreload"
#define PERK_COMMON_STAMINUP                "specialty_staminup"
#define PERK_COMMON_DEADSHOT                "specialty_deadshot"

// Premium Perks (Epic/Legendary only)
#define PERK_PREMIUM_JUGGERNOG              "specialty_armorvest"
#define PERK_PREMIUM_QUICK_REVIVE           "specialty_quickrevive"
#define PERK_PREMIUM_DOUBLE_TAP             "specialty_doubletap2"
#define PERK_PREMIUM_WIDOWS_WINE            "specialty_widowswine"
#define PERK_PREMIUM_MULE_KICK              "specialty_additionalprimaryweapon"

// Basic Powerups (Rare tier)
#define POWERUP_BASIC_DOUBLE_POINTS         "double_points"
#define POWERUP_BASIC_MAX_AMMO              "full_ammo"

// Better Powerups (Epic tier)
#define POWERUP_BETTER_INSTA_KILL           "insta_kill"
#define POWERUP_BETTER_CARPENTER            "carpenter"
#define POWERUP_BETTER_FIRE_SALE            "fire_sale"

// Premium Powerups (Legendary tier)
#define POWERUP_PREMIUM_NUKE                "nuke"
#define POWERUP_PREMIUM_PERKAHOLIC          "perkaholic"      // If available in your map
#define POWERUP_PREMIUM_SHOPPING_FREE       "shopping_free"   // If available in your map

#define EQUIPMENT_FRAG_GRENADE              "frag_grenade"
#define EQUIPMENT_SEMTEX                    "sticky_grenade"
#define EQUIPMENT_MODEL                     "wpn_t7_grenade_frag_world"

// Enable/Disable weapon rewards
#define REWARD_ENABLE_WEAPONS               true   // Normal weapons enabled!
#define REWARD_ENABLE_WONDER_WEAPONS        false  // Wonder weapons still need map-specific config

// Weapon reward gives: Random weapon from level.zombie_weapons pool
// Rare: Any available weapon (wall guns preferred)
// Epic: Box weapons + wall guns (higher quality)
// Legendary: Best weapons + Pack-a-Punch upgrade
// Wonder weapon reward gives: Map's wonder weapon (Ray Gun, Thunder Gun, etc.)
