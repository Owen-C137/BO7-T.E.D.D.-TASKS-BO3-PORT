// ====================================================================
// TEDD Tasks System - Core
// Handles initialization, clientfield registration, zombie monitoring
// ====================================================================

#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\tedd_tasks\zm_tedd_tasks_config.gsh;

// Import other TEDD modules
#using scripts\zm\tedd_tasks\zm_tedd_tasks_machine;
#using scripts\zm\tedd_tasks\zm_tedd_tasks_challenges;
#using scripts\zm\tedd_tasks\zm_tedd_tasks_rewards;
#using scripts\zm\tedd_tasks\zm_tedd_tasks_utils;

#using_animtree("zm_challenge_machine");

#precache("xanim", "sat_zm_obelisk_tesla_tower_silver_fxanim_off_idle");
#precache("xanim", "sat_zm_obelisk_tesla_tower_silver_fxanim_on_idle");
#precache("xanim", "sat_zm_obelisk_tesla_tower_silver_fxanim_start");
#precache("xanim", "sat_zm_obelisk_tesla_tower_silver_fxanim_stop");
#precache("xanim", "sat_zm_obelisk_tesla_tower_silver_fxanim_talking");
#precache("fx", "_OwensAssets/bo7/tedd_machine_marker/tedd_trial_marker");
#precache("fx", "zombie/fx_margwa_teleport_spawn_zod_zmb");
#precache("fx", "zombie/fx_margwa_teleport_zod_zmb");
#precache("fx", "zombie/fx_powerup_on_solo_zmb");
#precache("fx", "zombie/fx_powerup_on_green_zmb");
#precache("fx", "zombie/fx_ritual_barrier_defend_zod_zmb");
#precache("fx", "zombie/fx_glow_eye_orange");

#namespace zm_tedd_tasks_core;

REGISTER_SYSTEM_EX("zm_tedd_tasks_core", &__init__, &__main__, undefined)

//*****************************************************************************
// INITIALIZATION
//*****************************************************************************

function __init__()
{
    // Register clientfields for challenge UI (clientuimodel auto-creates UI models)
    clientfield::register("clientuimodel", "tedd_challenge_active", VERSION_SHIP, 1, "int");
    clientfield::register("clientuimodel", "tedd_challenge_timer", VERSION_SHIP, 8, "int"); // 0-255 seconds
    clientfield::register("clientuimodel", "tedd_challenge_tier", VERSION_SHIP, 2, "int"); // 0-3 (Rare, Epic, Legendary, Ultra)
    clientfield::register("clientuimodel", "tedd_challenge_completed", VERSION_SHIP, 1, "int");
    clientfield::register("clientuimodel", "tedd_challenge_failed", VERSION_SHIP, 1, "int");
    clientfield::register("clientuimodel", "tedd_challenge_reward", VERSION_SHIP, 13, "int"); // 0-8191 points
    clientfield::register("clientuimodel", "tedd_challenge_type", VERSION_SHIP, 4, "int"); // 0-15 (supports all 12 challenge types)
    clientfield::register("clientuimodel", "tedd_challenge_weapon_class_id", VERSION_SHIP, 3, "int"); // 0-7 weapon classes
    clientfield::register("clientuimodel", "tedd_challenge_kills_current", VERSION_SHIP, 10, "int"); // 0-1023 kills
    clientfield::register("clientuimodel", "tedd_challenge_kills_required", VERSION_SHIP, 10, "int"); // 0-1023 kills
    
    // Reward model glow effect (using FX)
    clientfield::register("scriptmover", "reward_glow", VERSION_SHIP, 1, "int");
    
    // Reward model outline effect (using duplicate_render)
    clientfield::register("scriptmover", "reward_outline", VERSION_SHIP, 1, "int");
    
    // Reward shared state (0 = owner-only orange, 1 = shared green)
    clientfield::register("scriptmover", "reward_shared", VERSION_SHIP, 1, "int");
    
    // Machine spawn notification
    clientfield::register("clientuimodel", "tedd_machine_spawn_active", VERSION_SHIP, 1, "int");
    clientfield::register("clientuimodel", "tedd_machine_spawn_location", VERSION_SHIP, 3, "int"); // 0-7 locations
    
    // Horde zombie red eyes
    clientfield::register("actor", "horde_zombie_eyes", VERSION_SHIP, 1, "int");
    
    // Register zombie kill callback
    callback::on_ai_killed(&on_zombie_killed);
}

function __main__()
{
    // Register FX
    level._effect["tedd_machine_marker"] = CHALLENGE_MACHINE_FX;
    level._effect["tedd_machine_spawn"] = "zombie/fx_margwa_teleport_spawn_zod_zmb";
    level._effect["tedd_machine_despawn"] = "zombie/fx_margwa_teleport_zod_zmb";
    level._effect["zone_barrier"] = "zombie/fx_ritual_barrier_defend_zod_zmb";
    level._effect["zone_marker"] = "zombie/fx_glow_eye_orange";
    
    // Initialize level variables
    level.tedd_challenge_active = false;
    level.tedd_active_machine = undefined;
    level.tedd_machine_available = true;
    level.tedd_last_machine_index = -1;
    level.tedd_zone_fx = [];
    
    // Find all machine spawn locations
    level.tedd_spawn_locations = GetEntArray("challenge_machine", "targetname");
    level.tedd_reward_crates = GetEntArray("challenge_machine_reward", "targetname");
    
    // Find all zone barrier FX models (script_model in Radiant with targetname "zone_barrier_fx")
    level.tedd_zone_fx_models = GetEntArray("zone_barrier_fx", "targetname");
    
    IPrintLnBold("^6[DEBUG] Found " + level.tedd_zone_fx_models.size + " zone FX models");
    
    // Store original positions/angles, then delete models (will respawn when challenge starts)
    level.tedd_zone_fx_data = [];
    foreach(fx_model in level.tedd_zone_fx_models)
    {
        fx_data = SpawnStruct();
        fx_data.origin = fx_model.origin;
        fx_data.angles = fx_model.angles;
        fx_data.script_int = fx_model.script_int;
        fx_data.script_noteworthy = fx_model.script_noteworthy;
        level.tedd_zone_fx_data[level.tedd_zone_fx_data.size] = fx_data;
        
        // Delete the model - will respawn dynamically
        fx_model Delete();
    }
    
    // Hide all machines and crates initially
    foreach(machine in level.tedd_spawn_locations)
    {
        machine Hide();
    }
    
    foreach(crate in level.tedd_reward_crates)
    {
        crate Hide();
    }
    
    // Start zombie death monitoring
    level thread monitor_zombie_spawns();
    
    // Wait for game start
    level flag::wait_till("initial_blackscreen_passed");
    
    // Start zombie death monitoring (for progressive tier challenges)
    level thread monitor_zombie_spawns();
    
    // Start machine spawning system
    if(level.tedd_spawn_locations.size > 0)
    {
        if(CHALLENGE_SPAWN_PER_ROUND)
        {
            level thread round_based_spawn_manager();
        }
        else
        {
            // Wait for power if required
            if(CHALLENGE_REQUIRES_POWER)
            {
                level flag::wait_till("power_on");
            }
            level thread zm_tedd_tasks_machine::spawn_machine();
        }
    }
}

//*****************************************************************************
// ZOMBIE MONITORING
//*****************************************************************************

function monitor_zombie_spawns()
{
    level endon("end_game");
    
    level.tedd_monitored_zombies = [];
    
    IPrintLnBold("^2[TEDD] Zombie monitoring system started!");
    
    while(true)
    {
        zombies = GetAITeamArray("axis"); // Get all zombies
        
        foreach(zombie in zombies)
        {
            if(!IsDefined(zombie.tedd_being_watched))
            {
                zombie.tedd_being_watched = true;
                zombie thread watch_zombie_death();
            }
        }
        
        wait(0.25); // Poll 4 times per second
    }
}

function watch_zombie_death()
{
    self waittill("death", attacker);
    
    // Check if challenge is active - if not, don't process kills
    if(!IsDefined(level.tedd_challenge_active) || !level.tedd_challenge_active)
    {
        return;
    }
    
    // CRITICAL: Check if this is a trap kill (tedd_trap_kill flag)
    // Trap kills should ONLY count for CHALLENGE_TYPE_TRAP_KILLS challenges
    // NOTE: Using tedd_trap_kill instead of marked_for_death to avoid false positives from Death Machine/powerups
    if(IsDefined(self.tedd_trap_kill) && self.tedd_trap_kill)
    {
        IPrintLnBold("^6[DEBUG] Zombie has tedd_trap_kill flag - this is a TRAP KILL");
        
        // This is a trap kill - only process if current challenge is TRAP_KILLS
        if(!IsDefined(level.tedd_challenge_type) || level.tedd_challenge_type != CHALLENGE_TYPE_TRAP_KILLS)
        {
            IPrintLnBold("^1[TRAP KILL BLOCKED] Challenge is not TRAP_KILLS - returning");
            // Not a trap kills challenge - ignore trap kills
            return;
        }
        else
        {
            IPrintLnBold("^2[TRAP KILL ALLOWED] Challenge IS TRAP_KILLS - continuing to trap handler");
        }
        
        // For trap kills, find the player who activated the trap
        // Trap should have stored the player reference
        if(IsDefined(attacker) && IsDefined(attacker.activated_by_player))
        {
            attacker = attacker.activated_by_player;
        }
        else
        {
            // Fallback: give credit to first player
            players = GetPlayers();
            if(players.size > 0)
            {
                attacker = players[0];
            }
            else
            {
                return;
            }
        }
    }
    else
    {
        // Regular kill - must be from a player
        if(!IsDefined(attacker) || !IsPlayer(attacker))
        {
            return;
        }
    }
    
    // Check for headshot using zombie's stored damage info
    is_headshot = false;
    is_melee = false;
    
    if(IsDefined(self.damagelocation))
    {
        // Use official zm_utility::is_headshot() - same method as scoreboard
        is_headshot = zm_utility::is_headshot(self.damageweapon, self.damagelocation, self.damagemod);
        
        // Melee detection
        is_melee = (IsDefined(self.damagemod) && self.damagemod == "MOD_MELEE");
    }
    
    // Check for location-based kills
    if(IsDefined(level.tedd_challenge_type) && level.tedd_challenge_type == CHALLENGE_TYPE_KILL_IN_LOCATION)
        {
            // Check if BOTH player AND zombie are inside the challenge zone
            player_in_zone = false;
            zombie_in_zone = false;
            
            if(IsDefined(level.tedd_active_zone))
            {
                // Use IsTouching() with trigger volume (official BO3 method)
                player_in_zone = attacker IsTouching(level.tedd_active_zone);
                zombie_in_zone = self IsTouching(level.tedd_active_zone);
            }
            
            // BOTH must be in zone for kill to count
            if(player_in_zone && zombie_in_zone)
            {
                // Count the kill for location challenge
                level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
            }
            else
            {
                // Notify player why kill didn't count
                if(!player_in_zone)
                {
                    attacker IPrintLn("^1You must be inside the zone!");
                }
                else if(!zombie_in_zone)
                {
                    attacker IPrintLn("^1Zombie must be inside the zone!");
                }
            }
        }
        else if(IsDefined(level.tedd_challenge_type) && level.tedd_challenge_type == CHALLENGE_TYPE_KILL_ELEVATION_HIGH)
        {
            // Check if player is ABOVE zombie (at least 64 units)
            player_height = attacker.origin[2];
            zombie_height = self.origin[2];
            height_difference = player_height - zombie_height;
            
            is_above_zombie = height_difference >= 64;
            
            if(is_above_zombie)
            {
                // Count the kill
                level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
                attacker IPrintLn("^2Kill from above! (+" + int(height_difference) + " units)");
            }
            else
            {
                attacker IPrintLn("^1Must be above zombie! (" + int(height_difference) + " units)");
            }
        }
        else if(IsDefined(level.tedd_challenge_type) && level.tedd_challenge_type == CHALLENGE_TYPE_KILL_ELEVATION_LOW)
        {
            // Check if player is BELOW zombie (at least 64 units)
            player_height = attacker.origin[2];
            zombie_height = self.origin[2];
            height_difference = player_height - zombie_height;
            
            is_below_zombie = height_difference <= -64;
            
            if(is_below_zombie)
            {
                // Count the kill
                level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
                attacker IPrintLn("^2Kill from below! (-" + int(abs(height_difference)) + " units)");
            }
            else
            {
                attacker IPrintLn("^1Must be below zombie! (" + int(height_difference) + " units)");
            }
        }
        else if(IsDefined(level.tedd_challenge_type) && level.tedd_challenge_type == CHALLENGE_TYPE_STANDING_STILL)
        {
            // Check if player is standing still (movement < 0.1)
            movement = attacker GetNormalizedMovement();
            movement_length = Length(movement);
            is_standing_still = movement_length < 0.1;
            
            if(is_standing_still)
            {
                level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
                attacker IPrintLn("^2Standing still kill!");
            }
            else
            {
                attacker IPrintLn("^1Must stand still to kill!");
            }
        }
        else if(IsDefined(level.tedd_challenge_type) && level.tedd_challenge_type == CHALLENGE_TYPE_CROUCHING)
        {
            // Check if player is crouched
            is_crouching = attacker GetStance() == "crouch";
            
            if(is_crouching)
            {
                level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
                attacker IPrintLn("^2Crouched kill!");
            }
            else
            {
                attacker IPrintLn("^1Must be crouched to kill!");
            }
        }
        else if(IsDefined(level.tedd_challenge_type) && level.tedd_challenge_type == CHALLENGE_TYPE_SLIDING)
        {
            // Check if player is sliding
            is_sliding = attacker IsSliding();
            
            if(is_sliding)
            {
                level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
                attacker IPrintLn("^2Sliding kill!");
            }
            else
            {
                attacker IPrintLn("^1Must be sliding to kill!");
            }
        }
        else if(IsDefined(level.tedd_challenge_type) && level.tedd_challenge_type == CHALLENGE_TYPE_JUMPING)
        {
            // Check if player is airborne (not on ground)
            is_jumping = !attacker IsOnGround();
            
            if(is_jumping)
            {
                level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
                attacker IPrintLn("^2Airborne kill!");
            }
            else
            {
                attacker IPrintLn("^1Must be in air to kill!");
            }
        }
        else if(IsDefined(level.tedd_challenge_type) && level.tedd_challenge_type == CHALLENGE_TYPE_WEAPON_CLASS)
        {
            // Check if weapon class matches
            weapon_class = undefined;
            
            if(IsDefined(self.damageweapon))
            {
                weapon_class = zm_tedd_tasks_utils::get_weapon_class_from_weapon(self.damageweapon);
                
                // Debug output
                if(IsDefined(self.damageweapon.name))
                {
                    attacker IPrintLnBold("^6[DEBUG] Weapon name: " + self.damageweapon.name);
                }
            }
            
            // Build debug strings
            weapon_class_str = "UNKNOWN";
            if(IsDefined(weapon_class))
            {
                weapon_class_str = weapon_class;
            }
            
            required_class_str = "UNKNOWN";
            if(IsDefined(level.tedd_required_weapon_class))
            {
                required_class_str = level.tedd_required_weapon_class;
            }
            
            attacker IPrintLnBold("^6[WEAPON CLASS] Detected: " + weapon_class_str + " | Required: " + required_class_str);
            
            is_correct_class = (IsDefined(weapon_class) && IsDefined(level.tedd_required_weapon_class) && weapon_class == level.tedd_required_weapon_class);
            
            if(is_correct_class)
            {
                attacker IPrintLnBold("^2[WEAPON CLASS CHALLENGE] Processing " + weapon_class + " kill!");
                level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
            }
            else
            {
                attacker IPrintLnBold("^1[WEAPON CLASS CHALLENGE] Wrong weapon class - skipping");
            }
        }
        else if(IsDefined(level.tedd_challenge_type) && level.tedd_challenge_type == CHALLENGE_TYPE_EQUIPMENT_KILLS)
        {
            // Check if kill was by equipment (grenades, betties, monkeys)
            is_equipment_kill = false;
            
            if(IsDefined(self.damagemod))
            {
                // Check for equipment MODs (matches old system)
                if(self.damagemod == "MOD_GRENADE" || 
                   self.damagemod == "MOD_GRENADE_SPLASH" || 
                   self.damagemod == "MOD_PROJECTILE" || 
                   self.damagemod == "MOD_PROJECTILE_SPLASH" || 
                   self.damagemod == "MOD_EXPLOSIVE" || 
                   self.damagemod == "MOD_EXPLOSIVE_SPLASH")
                {
                    is_equipment_kill = true;
                }
            }
            
            if(is_equipment_kill)
            {
                weapon_name = "equipment";
                if(IsDefined(self.damageweapon))
                {
                    weapon_name = self.damageweapon.name;
                }
                attacker IPrintLnBold("^2[EQUIPMENT CHALLENGE] Kill with " + weapon_name + " (MOD: " + self.damagemod + ")");
                level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
            }
            else
            {
                attacker IPrintLnBold("^1[EQUIPMENT CHALLENGE] Not an equipment kill (MOD: " + self.damagemod + ")");
            }
        }
        else if(IsDefined(level.tedd_challenge_type) && level.tedd_challenge_type == CHALLENGE_TYPE_TRAP_KILLS)
        {
            attacker IPrintLnBold("^6[DEBUG] Reached TRAP_KILLS handler section");
            
            // Trap kills: ONLY count kills with tedd_trap_kill flag
            // The exclusivity check above ensures this challenge is ONLY active when it's a trap_kills challenge
            // But we still need to verify the zombie actually has the flag (wasn't just a regular kill)
            // NOTE: Using tedd_trap_kill instead of marked_for_death to avoid false positives from Death Machine
            if(IsDefined(self.tedd_trap_kill) && self.tedd_trap_kill)
            {
                attacker IPrintLnBold("^2[TRAP KILLS CHALLENGE] Zombie has tedd_trap_kill - processing trap kill!");
                level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
            }
            else
            {
                attacker IPrintLnBold("^1[TRAP KILLS CHALLENGE] Zombie DOES NOT have tedd_trap_kill - skipping");
            }
        }
        else
        {
            // Process kill for other challenge types (kills, headshots, melee, etc.)
            level thread zm_tedd_tasks_challenges::process_progressive_kill(is_headshot, is_melee);
        }
    
    // Notify challenge system of kill (for future challenge types)
    level notify("tedd_zombie_killed", attacker, self);
}

function on_zombie_killed(attacker, mod, weapon, zombie)
{
    // Callback for additional tracking if needed
}

//*****************************************************************************
// ROUND-BASED SPAWNING
//*****************************************************************************

function round_based_spawn_manager()
{
    level endon("end_game");
    
    while(true)
    {
        level waittill("start_of_round");
        
        IPrintLnBold("^6[DEBUG] Round " + level.round_number + " - Checking machine spawn...");
        
        if(level.round_number >= CHALLENGE_SPAWN_ROUND_DELAY)
        {
            IPrintLnBold("^6[DEBUG] challenge_active=" + level.tedd_challenge_active);
            IPrintLnBold("^6[DEBUG] active_reward=" + (IsDefined(level.tedd_active_reward) ? "YES" : "NO"));
            IPrintLnBold("^6[DEBUG] machine_available=" + level.tedd_machine_available);
            IPrintLnBold("^6[DEBUG] active_machine=" + (IsDefined(level.tedd_active_machine) ? "YES" : "NO"));
            
            // Check power requirement
            if(CHALLENGE_REQUIRES_POWER && !level flag::get("power_on"))
            {
                IPrintLnBold("^1[DEBUG] NOT spawning machine - power not on");
                continue;
            }
            
            // Don't spawn if challenge active or reward crate present
            if(!level.tedd_challenge_active && 
               !IsDefined(level.tedd_active_reward) && 
               level.tedd_machine_available)
            {
                IPrintLnBold("^2[DEBUG] Spawning machine!");
                level thread zm_tedd_tasks_machine::spawn_machine();
            }
            else
            {
                IPrintLnBold("^1[DEBUG] NOT spawning machine - conditions not met");
            }
        }
    }
}


