// ====================================================================
// TEDD Tasks System - Challenges
// Phase 1: Horde Challenge Only
// ====================================================================

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_spawner;

#insert scripts\zm\tedd_tasks\zm_tedd_tasks_config.gsh;

// Import other TEDD modules
#using scripts\zm\tedd_tasks\zm_tedd_tasks_machine;
#using scripts\zm\tedd_tasks\zm_tedd_tasks_rewards;
#using scripts\zm\tedd_tasks\zm_tedd_tasks_utils;

#namespace zm_tedd_tasks_challenges;

//*****************************************************************************
// HORDE CHALLENGE
//*****************************************************************************

function start_horde_challenge()
{
    // Pick random tier (Rare, Epic, or Legendary)
    tiers = [];
    tiers[0] = CHALLENGE_TIER_RARE;
    tiers[1] = CHALLENGE_TIER_EPIC;
    tiers[2] = CHALLENGE_TIER_LEGENDARY;
    tier = array::random(tiers);
    
    // Set global challenge state
    level.tedd_challenge_active = true;
    level.tedd_challenge_tier = tier;
    level.tedd_challenge_type = CHALLENGE_TYPE_SURVIVE_HORDE;
    level.tedd_challenge_start_time = GetTime();
    
    // Get tier settings
    time_limit = get_tier_time_limit(tier);
    speed_mult = get_tier_speed_multiplier(tier);
    
    // Set machine to activated state
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
    {
        level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_activation_sequence();
        zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "activated");
    }
    
    // Update UI for all players
    tier_name = zm_tedd_tasks_utils::get_tier_name(tier);
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", tier);
        player clientfield::set_player_uimodel("tedd_challenge_timer", time_limit);
        player IPrintLnBold("^2Survive the " + tier_name + " Horde for " + time_limit + " seconds!");
    }
    
    // Start challenge threads
    level thread horde_timer(time_limit);
    level thread horde_spawner(speed_mult);
    level thread horde_timer_update(time_limit);
}

function horde_timer(time_limit)
{
    level endon("tedd_challenge_complete");
    level endon("tedd_challenge_failed");
    
    wait(time_limit);
    
    // Time's up - challenge complete!
    level notify("tedd_horde_survived");
    level thread complete_challenge();
}

function horde_timer_update(time_limit)
{
    level endon("tedd_challenge_complete");
    level endon("tedd_challenge_failed");
    
    start_time = GetTime();
    
    while(true)
    {
        elapsed = int((GetTime() - start_time) / 1000);
        remaining = time_limit - elapsed;
        
        if(remaining < 0)
        {
            remaining = 0;
        }
        
        // Update all players
        players = getplayers();
        foreach(player in players)
        {
            player clientfield::set_player_uimodel("tedd_challenge_timer", remaining);
        }
        
        wait(1.0);
    }
}

function horde_spawner(speed_multiplier)
{
    level endon("tedd_challenge_complete");
    level endon("tedd_challenge_failed");
    
    while(true)
    {
        // Count ONLY horde zombies (not round zombies)
        zombies = GetAITeamArray("axis");
        current_zombies = 0;
        foreach(zombie in zombies)
        {
            if(IsDefined(zombie.is_horde_zombie) && zombie.is_horde_zombie)
            {
                current_zombies++;
            }
        }
        
        if(current_zombies < HORDE_MAX_ACTIVE_ZOMBIES)
        {
            // Spawn wave
            for(i = 0; i < HORDE_ZOMBIES_PER_WAVE; i++)
            {
                // Get random spawner
                spawner = array::random(level.zombie_spawners);
                
                // Spawn zombie using official spawn_zombie function
                zombie = zombie_utility::spawn_zombie(spawner, spawner.targetname, undefined, undefined);
                
                if(IsDefined(zombie))
                {
                    zombie.is_horde_zombie = true;  // Official flag for horde zombies
                    zombie.tedd_horde_zombie = true;
                    zombie.ignore_enemy_count = 1;  // Exclude from round count (official BO3 flag)
                    zombie.deathpoints_already_given = true;  // Don't interfere with round progression
                    zombie.horde_speed_multiplier = speed_multiplier;
                    
                    // Apply red eye glow (distinguishes horde zombies)
                    zombie thread apply_red_eye_glow();
                    
                    // Apply speed using run cycle (official method)
                    if(speed_multiplier >= 1.4)
                    {
                        // Epic/Legendary/Ultra - Force sprint
                        zombie zombie_utility::set_zombie_run_cycle("sprint");
                    }
                    else if(speed_multiplier >= 1.2)
                    {
                        // Rare - Mix of run and sprint
                        if(RandomInt(100) < 50)
                        {
                            zombie zombie_utility::set_zombie_run_cycle("sprint");
                        }
                        else
                        {
                            zombie zombie_utility::set_zombie_run_cycle("run");
                        }
                    }
                    else
                    {
                        // Common - Normal run cycle
                        zombie zombie_utility::set_zombie_run_cycle("run");
                    }
                    
                    // Cleanup horde zombie on challenge end
                    zombie thread horde_zombie_cleanup();
                }
            }
        }
        
        // Wait before next wave - scale spawn speed with round (higher rounds = faster spawns)
        spawn_delay = HORDE_SPAWN_DELAY_BASE;
        if(CHALLENGE_ROUND_SCALING_ENABLED)
        {
            // Scale spawn delay DOWN as rounds increase (faster spawns = harder)
            rounds_past_start = level.round_number - CHALLENGE_ROUND_SCALING_START;
            if(rounds_past_start > 0)
            {
                delay_reduction = rounds_past_start * 0.05; // 0.05 seconds faster per round
                spawn_delay = HORDE_SPAWN_DELAY_BASE - delay_reduction;
                
                // Clamp to minimum
                if(spawn_delay < HORDE_SPAWN_DELAY_MIN)
                {
                    spawn_delay = HORDE_SPAWN_DELAY_MIN;
                }
            }
        }
        
        wait(spawn_delay);
    }
}

function apply_red_eye_glow()
{
    self endon("death");
    
    // Wait for zombie to fully spawn (official pattern from delayed_zombie_eye_glow)
    if(IsDefined(self.in_the_ground) && self.in_the_ground || (IsDefined(self.in_the_ceiling) && self.in_the_ceiling))
    {
        while(!IsDefined(self.create_eyes))
        {
            wait(0.1);
        }
    }
    else
    {
        wait(0.5);
    }
    
    // Set horde zombie red eyes via clientfield (CSC callback will set _eyeglow_fx_override)
    self clientfield::set("horde_zombie_eyes", 1);
    
    // Activate standard eye glow
    if(!IsDefined(self.no_eye_glow) || !self.no_eye_glow)
    {
        self clientfield::set("zombie_has_eyes", 1);
    }
}

function horde_zombie_cleanup()
{
    self endon("death");
    
    level waittill("tedd_horde_challenge_ended");
    
    // Only despawn if this is actually a horde zombie (not round zombie)
    if(IsDefined(self) && IsAlive(self) && IsDefined(self.is_horde_zombie) && self.is_horde_zombie)
    {
        self DoDamage(self.health + 100, self.origin);
    }
}

//*****************************************************************************
// PROGRESSIVE TIER CHALLENGES (Kills, Headshots, Melee)
//*****************************************************************************

function start_kills_challenge()
{
    // Initialize GLOBAL challenge with progressive tier system (starts at Rare)
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_KILLS;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE; // Start at Rare
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_scaled_requirement(CHALLENGE_TIER_RARE_KILLS, level.round_number);
    level.tedd_challenge_start_time = GetTime();
    level.tedd_highest_tier_completed = -1; // Track highest tier reached (for partial completion rewards)
    
    // Set machine to activated state
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
    {
        level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_activation_sequence();
        zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "activated");
    }
    
    // Update UI for all players
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_type", 1); // 1 = kills
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Kill Challenge Started: Rare Tier - Get " + level.tedd_challenge_kills_required + " kills!");
    }
    
    // Start timer for RARE tier
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

function start_headshots_challenge()
{
    // Initialize GLOBAL challenge with progressive tier system (starts at Rare)
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_HEADSHOTS;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE; // Start at Rare
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_scaled_requirement(CHALLENGE_TIER_RARE_HEADSHOTS, level.round_number);
    level.tedd_challenge_start_time = GetTime();
    
    // Set machine to activated state
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
    {
        level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_activation_sequence();
        zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "activated");
    }
    
    // Update UI for all players
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_type", 2); // 2 = headshots
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Headshot Challenge Started: Rare Tier - Get " + level.tedd_challenge_kills_required + " headshots!");
    }
    
    // Start timer for RARE tier
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

function start_melee_challenge()
{
    // Initialize GLOBAL challenge with progressive tier system (starts at Rare)
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_MELEE;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE; // Start at Rare
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_scaled_requirement(CHALLENGE_TIER_RARE_MELEE, level.round_number);
    level.tedd_challenge_start_time = GetTime();
    
    // Set machine to activated state
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
    {
        level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_activation_sequence();
        zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "activated");
    }
    
    // Update UI for all players
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_type", 3); // 3 = melee
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Melee Challenge Started: Rare Tier - Get " + level.tedd_challenge_kills_required + " melee kills!");
    }
    
    // Start timer for RARE tier
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

function challenge_timer(time_limit)
{
    level endon("tedd_challenge_complete");
    level endon("tedd_challenge_failed");
    
    wait(time_limit);
    
    // Time's up - check if player completed any tiers
    level thread timeout_challenge();
}

function challenge_timer_update(initial_time_limit)
{
    level endon("tedd_challenge_complete");
    level endon("tedd_challenge_failed");
    
    start_time = GetTime();
    time_limit = initial_time_limit;
    
    while(true)
    {
        elapsed = int((GetTime() - start_time) / 1000);
        remaining = time_limit - elapsed;
        
        if(remaining < 0)
        {
            remaining = 0;
        }
        
        // Update all players
        players = getplayers();
        foreach(player in players)
        {
            player clientfield::set_player_uimodel("tedd_challenge_timer", remaining);
        }
        
        wait(1.0);
    }
}

function process_progressive_kill(is_headshot, is_melee)
{
    if(!IsDefined(level.tedd_challenge_active) || !level.tedd_challenge_active)
    {
        return;
    }
    
    // Check if this is a progressive tier challenge
    challenge_type = level.tedd_challenge_type;
    
    // Only process kills for progressive tier challenges (types 1-14)
    if(challenge_type != CHALLENGE_TYPE_KILLS && 
       challenge_type != CHALLENGE_TYPE_HEADSHOTS && 
       challenge_type != CHALLENGE_TYPE_MELEE &&
       challenge_type != CHALLENGE_TYPE_KILL_IN_LOCATION &&
       challenge_type != CHALLENGE_TYPE_KILL_ELEVATION_HIGH &&
       challenge_type != CHALLENGE_TYPE_KILL_ELEVATION_LOW &&
       challenge_type != CHALLENGE_TYPE_STANDING_STILL &&
       challenge_type != CHALLENGE_TYPE_CROUCHING &&
       challenge_type != CHALLENGE_TYPE_SLIDING &&
       challenge_type != CHALLENGE_TYPE_JUMPING &&
       challenge_type != CHALLENGE_TYPE_TRAP_KILLS &&
       challenge_type != CHALLENGE_TYPE_WEAPON_CLASS &&
       challenge_type != CHALLENGE_TYPE_EQUIPMENT_KILLS)
    {
        return; // Not a progressive tier challenge
    }
    
    // Filter kills by challenge type
    if(challenge_type == CHALLENGE_TYPE_HEADSHOTS && !is_headshot)
    {
        return; // Only count headshots for headshot challenge
    }
    
    if(challenge_type == CHALLENGE_TYPE_MELEE && !is_melee)
    {
        return; // Only count melee kills for melee challenge
    }
    
    // CHALLENGE_TYPE_KILLS counts all kills (no filter)
    
    // Increment kill count
    level.tedd_challenge_kills_current++;
    
    // Update UI for all players
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        
        // Show progress message
        remaining = level.tedd_challenge_kills_required - level.tedd_challenge_kills_current;
        if(remaining > 0)
        {
            player IPrintLn("^3Progress: " + level.tedd_challenge_kills_current + "/" + level.tedd_challenge_kills_required);
        }
    }
    
    // Check if current tier complete
    if(level.tedd_challenge_kills_current >= level.tedd_challenge_kills_required)
    {
        // Check if we can advance to next tier
        if(level.tedd_challenge_tier < CHALLENGE_TIER_LEGENDARY)
        {
            // Track that they completed this tier (for partial rewards on timeout)
            level.tedd_highest_tier_completed = level.tedd_challenge_tier;
            
            // Advance to next tier
            level.tedd_challenge_tier++;
            level.tedd_challenge_kills_current = 0; // Reset kills for new tier
            
            // Get new requirements based on challenge type and new tier
            if(challenge_type == CHALLENGE_TYPE_KILLS)
            {
                if(level.tedd_challenge_tier == CHALLENGE_TIER_EPIC)
                {
                    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_scaled_requirement(CHALLENGE_TIER_EPIC_KILLS, level.round_number);
                }
                else if(level.tedd_challenge_tier == CHALLENGE_TIER_LEGENDARY)
                {
                    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_scaled_requirement(CHALLENGE_TIER_LEGENDARY_KILLS, level.round_number);
                }
            }
            else if(challenge_type == CHALLENGE_TYPE_HEADSHOTS)
            {
                if(level.tedd_challenge_tier == CHALLENGE_TIER_EPIC)
                {
                    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_scaled_requirement(CHALLENGE_TIER_EPIC_HEADSHOTS, level.round_number);
                }
                else if(level.tedd_challenge_tier == CHALLENGE_TIER_LEGENDARY)
                {
                    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_scaled_requirement(CHALLENGE_TIER_LEGENDARY_HEADSHOTS, level.round_number);
                }
            }
            else if(challenge_type == CHALLENGE_TYPE_MELEE)
            {
                if(level.tedd_challenge_tier == CHALLENGE_TIER_EPIC)
                {
                    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_scaled_requirement(CHALLENGE_TIER_EPIC_MELEE, level.round_number);
                }
                else if(level.tedd_challenge_tier == CHALLENGE_TIER_LEGENDARY)
                {
                    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_scaled_requirement(CHALLENGE_TIER_LEGENDARY_MELEE, level.round_number);
                }
            }
            else if(challenge_type == CHALLENGE_TYPE_KILL_IN_LOCATION)
            {
                // Use helper function for location challenges
                level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_kill_in_location_required(level.tedd_challenge_tier);
            }
            else if(challenge_type == CHALLENGE_TYPE_KILL_ELEVATION_HIGH)
            {
                // Use helper function for elevation high challenges
                level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_kill_elevation_high_required(level.tedd_challenge_tier);
            }
            else if(challenge_type == CHALLENGE_TYPE_KILL_ELEVATION_LOW)
            {
                // Use helper function for elevation low challenges
                level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_kill_elevation_low_required(level.tedd_challenge_tier);
            }
            else if(challenge_type == CHALLENGE_TYPE_STANDING_STILL)
            {
                level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_standing_still_required(level.tedd_challenge_tier);
            }
            else if(challenge_type == CHALLENGE_TYPE_CROUCHING)
            {
                level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_crouching_required(level.tedd_challenge_tier);
            }
            else if(challenge_type == CHALLENGE_TYPE_SLIDING)
            {
                level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_sliding_required(level.tedd_challenge_tier);
            }
            else if(challenge_type == CHALLENGE_TYPE_JUMPING)
            {
                level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_jumping_required(level.tedd_challenge_tier);
            }
            else if(challenge_type == CHALLENGE_TYPE_TRAP_KILLS)
            {
                level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_trap_kills_required(level.tedd_challenge_tier);
            }
            else if(challenge_type == CHALLENGE_TYPE_WEAPON_CLASS)
            {
                level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_weapon_class_required(level.tedd_challenge_tier);
            }
            
            // Get full time limit for new tier
            new_time_limit = get_tier_time_limit_progressive(level.tedd_challenge_tier);
            
            tier_name = zm_tedd_tasks_utils::get_tier_name(level.tedd_challenge_tier);
            
            // Play tier completion sound with talking animation based on new tier (on_idle - still active)
            if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
            {
                if(level.tedd_challenge_tier == CHALLENGE_TIER_RARE)
                {
                    level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_voice_line_with_anim("tedd_tasks_challenge_tier_rare", 4.0, "on_idle");
                }
                else if(level.tedd_challenge_tier == CHALLENGE_TIER_EPIC)
                {
                    level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_voice_line_with_anim("tedd_tasks_challenge_tier_epic", 5.0, "on_idle");
                }
                else if(level.tedd_challenge_tier == CHALLENGE_TIER_LEGENDARY)
                {
                    level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_voice_line_with_anim("tedd_tasks_challenge_tier_legendary", 4.0, "on_idle");
                }
            }
            
            // Update UI for all players
            foreach(player in players)
            {
                player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
                player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
                player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
                player IPrintLnBold("^3Tier Advanced: " + tier_name + "! Get " + level.tedd_challenge_kills_required + " more!");
            }
            
            // Restart timer threads with new time limit (kill old threads first)
            level notify("tedd_challenge_failed"); // Stop old timer
            wait(0.05);
            level.tedd_challenge_active = true; // Reactivate
            level.tedd_challenge_start_time = GetTime(); // Reset start time for new tier
            
            // Start fresh timer with full time for new tier
            level thread challenge_timer(new_time_limit);
            level thread challenge_timer_update(new_time_limit);
        }
        else
        {
            // Legendary tier complete - challenge complete!
            level thread complete_challenge();
        }
    }
}

function get_tier_time_limit_progressive(tier)
{
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            return CHALLENGE_PROGRESSIVE_RARE_TIME;
        case CHALLENGE_TIER_EPIC:
            return CHALLENGE_PROGRESSIVE_EPIC_TIME;
        case CHALLENGE_TIER_LEGENDARY:
            return CHALLENGE_PROGRESSIVE_LEGENDARY_TIME;
    }
    return CHALLENGE_PROGRESSIVE_RARE_TIME;
}

//*****************************************************************************
// CHALLENGE COMPLETION
//*****************************************************************************

function complete_challenge()
{
    if(!level.tedd_challenge_active)
    {
        return;
    }
    
    level.tedd_challenge_active = false;
    level notify("tedd_challenge_complete");
    level notify("tedd_horde_challenge_ended");  // Cleanup horde zombies
    
    // Get reward amount
    tier = level.tedd_challenge_tier;
    reward_points = zm_tedd_tasks_utils::get_tier_reward(tier);
    
    // Update UI
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_completed", 1);
        player clientfield::set_player_uimodel("tedd_challenge_reward", reward_points);
        player clientfield::set_player_uimodel("tedd_challenge_active", 0);
    }
    
    // Play success animation sequence: stop animation, then voice with talking, then off_idle
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
    {
        level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_machine_animation("stop");
        zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "success");
        wait(1.0); // Wait for stop animation
        level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_voice_line_with_anim("tedd_tasks_challenge_success", 5.0, "off_idle");
    }
    
    // Wait for voice line to finish (5 seconds) + return to off_idle before despawning machine
    wait(5.5);
    
    // Get machine index BEFORE despawning
    machine_index = -1;
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.machine_index))
    {
        machine_index = level.tedd_active_machine.machine_index;
        IPrintLnBold("^2Using machine index for reward: " + machine_index);
    }
    
    // Despawn machine if configured, THEN spawn reward crate
    if(CHALLENGE_DESPAWN_ON_COMPLETE)
    {
        zm_tedd_tasks_machine::despawn_machine();
        wait(0.5);  // Wait for machine to fully despawn
    }
    
    // Spawn reward crate with machine index after machine is gone
    level thread zm_tedd_tasks_rewards::spawn_reward_crate(machine_index);
}
function timeout_challenge()
{
    if(!level.tedd_challenge_active)
    {
        return;
    }
    
    level.tedd_challenge_active = false;
    level notify("tedd_challenge_failed");
    level notify("tedd_horde_challenge_ended");  // Cleanup horde zombies
    
    // Check if they completed ANY tier
    completed_tier = level.tedd_highest_tier_completed;
    
    IPrintLnBold("^6[DEBUG] Timeout - highest_tier_completed: " + (IsDefined(completed_tier) ? completed_tier : "undefined") + " | current tier: " + level.tedd_challenge_tier);
    
    if(IsDefined(completed_tier) && completed_tier >= CHALLENGE_TIER_RARE)
    {
        // They completed at least Rare - give partial success!
        reward_tier = completed_tier;
        reward_points = zm_tedd_tasks_utils::get_tier_reward(reward_tier);
        tier_name = zm_tedd_tasks_utils::get_tier_name(reward_tier);
        
        IPrintLnBold("^6[DEBUG] Setting UI tier to: " + completed_tier + " (" + tier_name + ")");
        
        // Update UI - show as completed with partial reward (use highest completed tier, not current tier)
        players = getplayers();
        foreach(player in players)
        {
            player clientfield::set_player_uimodel("tedd_challenge_tier", completed_tier); // Show the tier they actually completed
            player clientfield::set_player_uimodel("tedd_challenge_completed", 1);
            player clientfield::set_player_uimodel("tedd_challenge_reward", reward_points);
            player clientfield::set_player_uimodel("tedd_challenge_active", 0);
            player IPrintLnBold("^3Time's Up! ^2" + tier_name + " Tier Completed!");
        }
        
        // Play stop animation then set success state, return to off_idle
        if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
        {
            level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_machine_animation("stop");
            zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "success");
            wait(2.0);
            level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_machine_animation("off_idle");
        }
        
        wait(1.0);
        
        // Get machine index and spawn reward
        machine_index = -1;
        if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.machine_index))
        {
            machine_index = level.tedd_active_machine.machine_index;
        }
        
        if(CHALLENGE_DESPAWN_ON_COMPLETE)
        {
            wait(1);
            zm_tedd_tasks_machine::despawn_machine();
            wait(0.5);
        }
        else
        {
            // Keep machine, but make it available again
            level.tedd_machine_available = true;
        }
        
        // Spawn reward crate with the tier they completed
        level thread zm_tedd_tasks_rewards::spawn_reward_crate(machine_index, reward_tier);
    }
    else
    {
        // They didn't complete ANY tier - true failure
        players = getplayers();
        foreach(player in players)
        {
            player clientfield::set_player_uimodel("tedd_challenge_failed", 1);
            player clientfield::set_player_uimodel("tedd_challenge_active", 0);
            player IPrintLnBold("^1Challenge Failed! No tiers completed.");
        }
        
        // Play fail animation sequence: stop, set failed state, voice with talking, then off_idle
        if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
        {
            level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_machine_animation("stop");
            zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "failed");
            wait(1.0); // Wait for stop animation
            level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_voice_line_with_anim("tedd_tasks_challenge_fail", 4.0, "off_idle");
        }
        
        // Wait for fail voice to finish before clearing UI
        wait(5.0);
        
        // Clear failed UI
        foreach(player in players)
        {
            player clientfield::set_player_uimodel("tedd_challenge_failed", 0);
        }
        
        if(CHALLENGE_DESPAWN_ON_FAIL)
        {
            zm_tedd_tasks_machine::despawn_machine();
        }
        else
        {
            // Start cooldown before machine returns to idle
            level thread zm_tedd_tasks_machine::machine_fail_cooldown();
        }
    }
}

//*****************************************************************************
// KILL IN LOCATION CHALLENGE
//*****************************************************************************

function start_kill_in_location_challenge()
{
    // Set global challenge state
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_KILL_IN_LOCATION;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;  // Start at Rare
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_kill_in_location_required(CHALLENGE_TIER_RARE);
    level.tedd_challenge_start_time = GetTime();
    level.tedd_highest_tier_completed = -1;  // Track for partial rewards
    
    // Store the active zone trigger for kill detection
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.zone_trigger))
    {
        level.tedd_active_zone = level.tedd_active_machine.zone_trigger;
        zm_tedd_tasks_utils::log_message("Kill in Location challenge - Zone trigger: " + level.tedd_active_zone.targetname);
    }
    else
    {
        zm_tedd_tasks_utils::log_message("^1ERROR: Kill in Location challenge but no zone trigger found!");
        IPrintLnBold("^1ERROR: No zone trigger linked to this machine!");
        level.tedd_challenge_active = false;
        return;
    }
    
    // Set machine to activated state
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
    {
        level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_activation_sequence();
        zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "activated");
    }
    
    // Update UI for all players
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 4);  // 4 = kill_in_location
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Kill " + level.tedd_challenge_kills_required + " zombies inside the zone!");
    }
    
    // Start timer threads
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

//*****************************************************************************
// SURVIVE IN LOCATION CHALLENGE
//*****************************************************************************

function start_survive_in_location_challenge()
{
    // Set global challenge state
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_SURVIVE_IN_LOCATION;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;  // Start at Rare
    level.tedd_challenge_time_in_zone = 0;  // Time accumulated inside zone
    level.tedd_challenge_time_required = zm_tedd_tasks_utils::get_tier_survive_in_location_required(CHALLENGE_TIER_RARE);
    level.tedd_challenge_start_time = GetTime();
    level.tedd_highest_tier_completed = -1;  // Track for partial rewards
    
    // Store the active zone trigger for position detection
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.zone_trigger))
    {
        level.tedd_active_zone = level.tedd_active_machine.zone_trigger;
        zm_tedd_tasks_utils::log_message("Survive in Location challenge - Zone trigger: " + level.tedd_active_zone.targetname);
    }
    else
    {
        zm_tedd_tasks_utils::log_message("^1ERROR: Survive in Location challenge but no zone trigger found!");
        IPrintLnBold("^1ERROR: No zone trigger linked to this machine!");
        level.tedd_challenge_active = false;
        return;
    }
    
    // Set machine to activated state
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
    {
        level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_activation_sequence();
        zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "activated");
    }
    
    // Update UI for all players
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 5);  // 5 = survive_in_location
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_time_in_zone);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_time_required);
        player IPrintLnBold("^2Stay in the zone for " + level.tedd_challenge_time_required + " seconds!");
    }
    
    // Start timer threads with TOTAL time limit (counts down regardless of zone position)
    time_limit = CHALLENGE_SURVIVE_IN_LOCATION_TIME_LIMIT;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
    
    // Start zone monitoring
    level thread monitor_players_in_zone();
}

//*****************************************************************************
// KILL ELEVATION HIGH CHALLENGE
//*****************************************************************************

function start_kill_elevation_high_challenge()
{
    level.tedd_challenge_type = CHALLENGE_TYPE_KILL_ELEVATION_HIGH;
    level.tedd_challenge_active = true;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_kill_elevation_high_required(level.tedd_challenge_tier);
    level.tedd_challenge_time_required = 0;
    
    // Set machine to activated state
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
    {
        level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_activation_sequence();
        zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "activated");
    }
    
    // Update UI for all players
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 6);  // 6 = kill_elevation_high
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Kill zombies from ABOVE! (" + level.tedd_challenge_kills_required + " required)");
    }
    
    // Start timer threads
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

//*****************************************************************************
// KILL ELEVATION LOW CHALLENGE
//*****************************************************************************

function start_kill_elevation_low_challenge()
{
    level.tedd_challenge_type = CHALLENGE_TYPE_KILL_ELEVATION_LOW;
    level.tedd_challenge_active = true;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_kill_elevation_low_required(level.tedd_challenge_tier);
    level.tedd_challenge_time_required = 0;
    
    // Set machine to activated state
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
    {
        level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_activation_sequence();
        zm_tedd_tasks_machine::set_machine_state(level.tedd_active_machine.model, "activated");
    }
    
    // Update UI for all players
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 7);  // 7 = kill_elevation_low
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Kill zombies from BELOW! (" + level.tedd_challenge_kills_required + " required)");
    }
    
    // Start timer threads
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

function monitor_players_in_zone()
{
    level endon("tedd_challenge_complete");
    level endon("tedd_challenge_timeout");
    
    while(IsDefined(level.tedd_challenge_active) && level.tedd_challenge_active)
    {
        // Check if ANY player is in the zone
        any_player_in_zone = false;
        players = getplayers();
        
        foreach(player in players)
        {
            if(!IsDefined(player) || !IsAlive(player))
                continue;
            
            if(IsDefined(level.tedd_active_zone))
            {
                if(player IsTouching(level.tedd_active_zone))
                {
                    any_player_in_zone = true;
                    break;
                }
            }
        }
        
        // If any player is in zone, increment time
        if(any_player_in_zone)
        {
            level.tedd_challenge_time_in_zone++;
            
            // Update UI for all players
            foreach(player in players)
            {
                player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_time_in_zone);
            }
            
            // Check if tier complete
            if(level.tedd_challenge_time_in_zone >= level.tedd_challenge_time_required)
            {
                // Check if we can advance to next tier
                if(level.tedd_challenge_tier < CHALLENGE_TIER_LEGENDARY)
                {
                    // Track completion
                    level.tedd_highest_tier_completed = level.tedd_challenge_tier;
                    
                    // Advance to next tier
                    level.tedd_challenge_tier++;
                    level.tedd_challenge_time_required = zm_tedd_tasks_utils::get_tier_survive_in_location_required(level.tedd_challenge_tier);
                    
                    tier_name = zm_tedd_tasks_utils::get_tier_name(level.tedd_challenge_tier);
                    
                    // RESET time counter for next tier (per-tier, not cumulative)
                    level.tedd_challenge_time_in_zone = 0;
                    
                    // Update UI for all players
                    foreach(player in players)
                    {
                        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
                        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_time_required);
                        player clientfield::set_player_uimodel("tedd_challenge_kills_current", 0);  // Reset UI counter
                        player IPrintLnBold("^3" + tier_name + " Tier! Survive " + level.tedd_challenge_time_required + " more seconds!");
                    }
                }
                else
                {
                    // Legendary tier complete - challenge complete!
                    level.tedd_highest_tier_completed = CHALLENGE_TIER_LEGENDARY;
                    level thread complete_challenge();
                    return;
                }
            }
        }
        
        wait(1);  // Check every second
    }
}

//*****************************************************************************
// MOVEMENT CHALLENGES (Standing Still, Crouching, Sliding, Jumping)
//*****************************************************************************

function start_standing_still_challenge()
{
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_STANDING_STILL;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_standing_still_required(CHALLENGE_TIER_RARE);
    level.tedd_challenge_start_time = GetTime();
    
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 8);  // 8 = standing_still
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Kill while NOT MOVING! (" + level.tedd_challenge_kills_required + " required)");
    }
    
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

function start_crouching_challenge()
{
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_CROUCHING;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_crouching_required(CHALLENGE_TIER_RARE);
    level.tedd_challenge_start_time = GetTime();
    
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 9);  // 9 = crouching
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Kill while CROUCHED! (" + level.tedd_challenge_kills_required + " required)");
    }
    
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

function start_sliding_challenge()
{
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_SLIDING;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_sliding_required(CHALLENGE_TIER_RARE);
    level.tedd_challenge_start_time = GetTime();
    
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 10);  // 10 = sliding
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Kill while SLIDING! (" + level.tedd_challenge_kills_required + " required)");
    }
    
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

function start_jumping_challenge()
{
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_JUMPING;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_jumping_required(CHALLENGE_TIER_RARE);
    level.tedd_challenge_start_time = GetTime();
    
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 11);  // 11 = jumping
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Kill while AIRBORNE! (" + level.tedd_challenge_kills_required + " required)");
    }
    
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

//*****************************************************************************
// TRAP KILLS & WEAPON CLASS CHALLENGES
//*****************************************************************************

function start_trap_kills_challenge()
{
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_TRAP_KILLS;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_trap_kills_required(CHALLENGE_TIER_RARE);
    level.tedd_challenge_start_time = GetTime();
    
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 12);  // 12 = trap_kills
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Kill with TRAP! (" + level.tedd_challenge_kills_required + " required)");
    }
    
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

function start_weapon_class_challenge()
{
    // Initialize weapon class array
    level.tedd_weapon_classes = [];
    level.tedd_weapon_classes[0] = "pistol";
    level.tedd_weapon_classes[1] = "rifle";
    level.tedd_weapon_classes[2] = "lmg";
    level.tedd_weapon_classes[3] = "shotgun";
    level.tedd_weapon_classes[4] = "smg";
    level.tedd_weapon_classes[5] = "sniper";
    level.tedd_weapon_classes[6] = "launcher";
    level.tedd_weapon_classes[7] = "wonder_weapon";
    
    // Select random weapon class
    level.tedd_required_weapon_class = array::random(level.tedd_weapon_classes);
    weapon_display_name = zm_tedd_tasks_utils::get_weapon_class_display_name(level.tedd_required_weapon_class);
    weapon_class_id = zm_tedd_tasks_utils::get_weapon_class_id(level.tedd_required_weapon_class);
    
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_WEAPON_CLASS;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_weapon_class_required(CHALLENGE_TIER_RARE);
    level.tedd_challenge_start_time = GetTime();
    
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 13);  // 13 = weapon_class
        player clientfield::set_player_uimodel("tedd_challenge_weapon_class_id", weapon_class_id);
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Get " + weapon_display_name + " Kills!");
        player IPrintLnBold("^3Required: " + level.tedd_challenge_kills_required);
    }
    
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}

//*****************************************************************************
// UTILITY FUNCTIONS
//*****************************************************************************

function get_tier_time_limit(tier)
{
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            return CHALLENGE_TIER_RARE_TIME;
        case CHALLENGE_TIER_EPIC:
            return CHALLENGE_TIER_EPIC_TIME;
        case CHALLENGE_TIER_LEGENDARY:
            return CHALLENGE_TIER_LEGENDARY_TIME;
        case CHALLENGE_TIER_ULTRA:
            return CHALLENGE_TIER_ULTRA_TIME;
    }
    return 60;
}

function get_tier_speed_multiplier(tier)
{
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            return HORDE_SPEED_RARE;
        case CHALLENGE_TIER_EPIC:
            return HORDE_SPEED_EPIC;
        case CHALLENGE_TIER_LEGENDARY:
            return HORDE_SPEED_LEGENDARY;
        case CHALLENGE_TIER_ULTRA:
            return HORDE_SPEED_ULTRA;
    }
    return 1.0;
}

function start_equipment_kills_challenge()
{
    level.tedd_challenge_active = true;
    level.tedd_challenge_type = CHALLENGE_TYPE_EQUIPMENT_KILLS;
    level.tedd_challenge_tier = CHALLENGE_TIER_RARE;
    level.tedd_challenge_kills_current = 0;
    level.tedd_challenge_kills_required = zm_tedd_tasks_utils::get_tier_equipment_kills_required(CHALLENGE_TIER_RARE);
    level.tedd_challenge_start_time = GetTime();
    
    players = getplayers();
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_challenge_active", 1);
        player clientfield::set_player_uimodel("tedd_challenge_tier", level.tedd_challenge_tier);
        player clientfield::set_player_uimodel("tedd_challenge_type", 14);  // 14 = equipment_kills
        player clientfield::set_player_uimodel("tedd_challenge_kills_current", level.tedd_challenge_kills_current);
        player clientfield::set_player_uimodel("tedd_challenge_kills_required", level.tedd_challenge_kills_required);
        player IPrintLnBold("^2Get Equipment Kills!");
        player IPrintLnBold("^3Required: " + level.tedd_challenge_kills_required);
    }
    
    time_limit = CHALLENGE_PROGRESSIVE_RARE_TIME;
    level thread challenge_timer(time_limit);
    level thread challenge_timer_update(time_limit);
}
