// ====================================================================
// TEDD Tasks System - Rewards
// Reward crate spawning, menu system, reward delivery
// ====================================================================

#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_powerups;

#insert scripts\zm\tedd_tasks\zm_tedd_tasks_config.gsh;

// Import utils module
#using scripts\zm\tedd_tasks\zm_tedd_tasks_utils;

#namespace zm_tedd_tasks_rewards;

//*****************************************************************************
// REWARD CRATE SPAWNING
//*****************************************************************************

function spawn_reward_crate(machine_index, reward_tier)
{
    // Default to challenge tier if not specified
    if(!IsDefined(reward_tier))
    {
        reward_tier = level.tedd_challenge_tier;
    }
    
    IPrintLnBold("^3[DEBUG] spawn_reward_crate() called with index: " + machine_index + " tier: " + reward_tier);
    
    // Find matching reward crate (same index as machine)
    if(!IsDefined(level.tedd_reward_crates) || level.tedd_reward_crates.size == 0)
    {
        IPrintLnBold("^1[DEBUG] Reward crates array empty or undefined! Size: " + (IsDefined(level.tedd_reward_crates) ? level.tedd_reward_crates.size : "undefined"));
        // Fallback: auto-give points
        auto_give_reward();
        return;
    }
    
    IPrintLnBold("^2[DEBUG] Found " + level.tedd_reward_crates.size + " reward crates");
    
    // Get crate at same index as machine
    reward_crate = undefined;
    if(machine_index >= 0 && machine_index < level.tedd_reward_crates.size)
    {
        reward_crate = level.tedd_reward_crates[machine_index];
        IPrintLnBold("^2[DEBUG] Using reward crate at index " + machine_index);
    }
    else
    {
        IPrintLnBold("^3[DEBUG] Index out of range, using first crate");
        reward_crate = level.tedd_reward_crates[0];
    }
    
    // Safety check
    if(!IsDefined(reward_crate))
    {
        IPrintLnBold("^1[DEBUG] ERROR: reward_crate is undefined after selection!");
        auto_give_reward();
        return;
    }
    
    IPrintLnBold("^2[DEBUG] Showing reward crate at: " + reward_crate.origin);
    
    // Show crate
    reward_crate Show();
    
    // Play reward spawn sound at crate location
    PlaySoundAtPosition("tedd_tasks_reward_spawn", reward_crate.origin);
    
    // Create unitrigger
    unitrigger_stub = SpawnStruct();
    unitrigger_stub.origin = reward_crate.origin + (0, 0, 16);
    unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
    unitrigger_stub.radius = 64;
    unitrigger_stub.script_height = 64;
    unitrigger_stub.cursor_hint = "HINT_NOICON";
    unitrigger_stub.require_look_at = true;
    unitrigger_stub.reward_crate = reward_crate;
    unitrigger_stub.prompt_and_visibility_func = &reward_crate_hint;
    
    zm_unitrigger::register_static_unitrigger(unitrigger_stub, &reward_crate_think);
    
    // Store reference
    level.tedd_active_reward = SpawnStruct();
    level.tedd_active_reward.crate = reward_crate;
    level.tedd_active_reward.trigger = unitrigger_stub;
    level.tedd_active_reward.machine_index = machine_index; // Store index to match reward location
    level.tedd_active_reward.reward_tier = reward_tier; // Store tier for reward selection
    level.tedd_active_reward.players_claimed = []; // Track which players have claimed
    
    // Count how many players need to claim (all living players)
    players = getplayers();
    level.tedd_active_reward.total_rewards = players.size;
    level.tedd_active_reward.rewards_claimed = 0;
    
    IPrintLnBold("^3Reward crate spawned! " + level.tedd_active_reward.total_rewards + " rewards available.");
}

function reward_crate_hint(player)
{
    // Check if level struct still exists
    if(!IsDefined(level.tedd_active_reward))
    {
        self SetHintString("");
        return false;
    }
    
    // Check if crate model still exists
    if(!IsDefined(level.tedd_active_reward.crate))
    {
        self SetHintString("");
        return false;
    }
    
    // Check if THIS player has already claimed
    if(IsDefined(level.tedd_active_reward.players_claimed))
    {
        foreach(claimed_player in level.tedd_active_reward.players_claimed)
        {
            if(claimed_player == player)
            {
                self SetHintString("^1You already opened the crate");
                return false;
            }
        }
    }
    
    // Show hint
    self SetHintString("^2Hold &&1 to claim your rewards");
    return true;
}

function reward_crate_think()
{
    self endon("kill_trigger");
    
    while(true)
    {
        // Wait for a player to interact
        self waittill("trigger", player);
        
        // Check if this player already claimed
        has_claimed = false;
        if(IsDefined(level.tedd_active_reward.players_claimed))
        {
            foreach(claimed_player in level.tedd_active_reward.players_claimed)
            {
                if(claimed_player == player)
                {
                    has_claimed = true;
                    break;
                }
            }
        }
        
        if(has_claimed)
        {
            player IPrintLnBold("^1You already opened the crate!");
            continue; // Allow trigger to continue for other players
        }
        
        // Mark this player as claimed
        if(!IsDefined(level.tedd_active_reward.players_claimed))
        {
            level.tedd_active_reward.players_claimed = [];
        }
        level.tedd_active_reward.players_claimed[level.tedd_active_reward.players_claimed.size] = player;
        level.tedd_active_reward.rewards_claimed++;
        
        player IPrintLnBold("^2You opened the reward crate!");
        
        // Spawn 4 personal rewards for this player
        player thread spawn_player_rewards();
        
        // Check if all players have claimed
        if(level.tedd_active_reward.rewards_claimed >= level.tedd_active_reward.total_rewards)
        {
            IPrintLnBold("^2All players have opened the crate!");
            
            // Unregister trigger
            zm_unitrigger::unregister_unitrigger(self);
            
            // Hide crate after short delay
            wait(1);
            if(IsDefined(level.tedd_active_reward) && IsDefined(level.tedd_active_reward.crate))
            {
                level.tedd_active_reward.crate Hide();
            }
            return;
        }
        
        // Continue loop to allow more players to claim
        wait(0.05);
    }
}

//*****************************************************************************
// REWARD MENU SYSTEM
//*****************************************************************************

function spawn_player_rewards()
{
    IPrintLnBold("^6[DEBUG] spawn_player_rewards() called for player: " + self.name);
    
    // Hide completion UI for this player
    self clientfield::set_player_uimodel("tedd_challenge_completed", 0);
    self clientfield::set_player_uimodel("tedd_challenge_reward", 0);
    
    // Use the stored reward tier (handles partial completion correctly)
    tier = CHALLENGE_TIER_RARE; // Default fallback
    if(IsDefined(level.tedd_active_reward) && IsDefined(level.tedd_active_reward.reward_tier))
    {
        tier = level.tedd_active_reward.reward_tier;
    }
    else if(IsDefined(level.tedd_challenge_tier))
    {
        tier = level.tedd_challenge_tier;
    }
    
    // Get machine index for reward spawn location
    machine_index = 0;
    if(IsDefined(level.tedd_active_reward) && IsDefined(level.tedd_active_reward.machine_index))
    {
        machine_index = level.tedd_active_reward.machine_index;
    }
    
    // Determine reward count based on tier (randomized within range)
    reward_count = get_reward_count_for_tier(tier);
    
    // Roll rewards for this player with tier-based quality
    rewards = roll_rewards_for_tier(tier, reward_count);
    
    // Spawn physical reward models (only visible to this player initially)
    self thread spawn_physical_rewards(rewards, machine_index, self);
    
    self IPrintLnBold("^2Walk up to rewards and press ^3F ^2to claim!");
    self IPrintLnBold("^3Melee a reward to share it with your team!");
}



// ====================================================================
// PHYSICAL REWARD SPAWNING SYSTEM
// ====================================================================

function spawn_physical_rewards(rewards, machine_index, owner)
{
    IPrintLnBold("^6[DEBUG] spawn_physical_rewards() called for player: " + self.name + " at machine index: " + machine_index);
    
    // Get spawn location matching the machine index
    reward_locs = struct::get_array("challenge_machine_reward_loc", "targetname");
    if(!IsDefined(reward_locs) || reward_locs.size == 0)
    {
        IPrintLnBold("^1ERROR: challenge_machine_reward_loc not found!");
        return;
    }
    
    // Use matching index, fallback to first if out of range
    reward_loc = undefined;
    if(machine_index >= 0 && machine_index < reward_locs.size)
    {
        reward_loc = reward_locs[machine_index];
        IPrintLnBold("^6[DEBUG] Using reward location at index " + machine_index + ": " + reward_loc.origin);
    }
    else
    {
        reward_loc = reward_locs[0];
        IPrintLnBold("^3[DEBUG] Machine index out of range, using first location: " + reward_loc.origin);
    }
    
    base_origin = reward_loc.origin;
    
    // Calculate positions in a circle around the struct (no overlap)
    radius = 50;
    reward_count = rewards.size; // Use actual reward count (2-4 based on tier)
    angle_step = 360 / reward_count;
    
    level.tedd_reward_models = [];
    level.tedd_reward_models_count = reward_count; // Store count for cleanup monitoring
    
    for(i = 0; i < reward_count; i++)
    {
        angle = angle_step * i;
        offset_x = radius * Cos(angle);
        offset_y = radius * Sin(angle);
        spawn_pos = base_origin + (offset_x, offset_y, 0); // Spawn at ground level (trigger will add height)
        
        IPrintLnBold("^6[DEBUG] Spawning reward " + (i+1) + " at angle " + angle);
        reward_model = spawn_reward_model(rewards[i], spawn_pos, i);
        if(IsDefined(reward_model))
        {
            IPrintLnBold("^2[DEBUG] Reward model " + (i+1) + " spawned successfully!");
            reward_model.reward_data = rewards[i];
            reward_model.reward_index = i;
            reward_model.base_origin = spawn_pos; // Store base position for unitrigger
            reward_model.owner = owner; // Set owner (only they can see/claim initially)
            reward_model.is_shared = false; // Not shared yet
            
            // Make visible only to owner initially
            reward_model SetInvisibleToAll();
            reward_model SetVisibleToPlayer(owner);
            
            if(!IsDefined(owner.tedd_active_rewards))
            {
                owner.tedd_active_rewards = [];
            }
            owner.tedd_active_rewards[owner.tedd_active_rewards.size] = reward_model;
            
            // Setup pickup FIRST (before bobbing starts)
            reward_model thread reward_setup_pickup(owner);
            
            // Setup melee detection for sharing (with helper trigger)
            reward_model thread reward_melee_watcher_with_trigger(owner);
            
            // Start animations AFTER unitrigger is setup
            reward_model thread reward_float_and_rotate();
        }
        else
        {
            IPrintLnBold("^1[DEBUG] ERROR: Failed to spawn reward model " + (i+1));
        }
    }
    
    IPrintLnBold("^2[DEBUG] All reward models spawned!");
    
    // Start monitoring for when all rewards are claimed
    level thread monitor_all_rewards_claimed();
}

function spawn_reward_model(reward, origin, index)
{
    IPrintLnBold("^6[DEBUG] spawn_reward_model called - type: " + reward.type + " at " + origin);
    
    // For powerups, use official zm_powerups system
    if(reward.type == "powerup" && IsDefined(reward.powerup_name))
    {
        IPrintLnBold("^6[DEBUG] Spawning powerup: " + reward.powerup_name);
        powerup = zm_powerups::specific_powerup_drop(reward.powerup_name, origin, undefined, undefined, undefined, undefined, true); // b_stay_forever = true
        if(IsDefined(powerup))
        {
            powerup.is_challenge_reward = true;
            powerup.reward_index = index; // Store index for cleanup tracking
            powerup thread monitor_powerup_pickup(); // Monitor for pickup
            IPrintLnBold("^2[DEBUG] Powerup spawned successfully!");
            return powerup;
        }
        IPrintLnBold("^1[DEBUG] Powerup spawn FAILED!");
    }
    
    // For other rewards, spawn custom models
    model_name = get_reward_model(reward);
    IPrintLnBold("^6[DEBUG] Spawning model: " + model_name);
    
    model = Spawn("script_model", origin);
    model SetModel(model_name);
    model.angles = (0, 0, 0);
    
    // Make model damageable (required for melee detection)
    model SetCanDamage(true);
    model.health = 999999; // High health so it doesn't die from melee
    
    // Add larger collision box for easier melee detection (especially for small models)
    model SetContents(1); // CONTENTS_SOLID - makes it have collision
    
    // Enable glow FX effect
    model clientfield::set("reward_glow", 1);
    
    // Enable outline effect (using duplicate_render system)
    model clientfield::set("reward_outline", 1);
    
    IPrintLnBold("^2[DEBUG] Model spawned at: " + model.origin);
    return model;
}

function get_reward_model(reward)
{
    switch(reward.type)
    {
        case REWARD_TYPE_PERK:
            return "wpn_t7_zmb_perk_bottle_world";
        case REWARD_TYPE_AMMO:
            return "p7_pouch_ammo_04";
        case REWARD_TYPE_BONUS_POINTS:
            return "jup_zm_tube_essence_01";
        case REWARD_TYPE_EQUIPMENT:
            return EQUIPMENT_MODEL;
        case REWARD_TYPE_POWERUP:
            // For powerups, we'll spawn the actual powerup drop
            return "script_model"; // Placeholder, will use zm_powerups system
    }
    return "jup_zm_tube_essence_01"; // Default
}

function reward_float_and_rotate()
{
    self endon("death");
    self endon("reward_claimed");
    
    // Skip animation for official powerups (they have their own wobble)
    if(IsDefined(self.is_challenge_reward))
    {
        return;
    }
    
    base_z = self.origin[2];
    bob_height = 10;
    bob_time = 2;
    
    while(true)
    {
        // Smooth bobbing motion
        self MoveTo(self.origin + (0, 0, bob_height), bob_time, bob_time * 0.3, bob_time * 0.3);
        self RotateYaw(180, bob_time);
        wait(bob_time);
        
        self MoveTo(self.origin - (0, 0, bob_height), bob_time, bob_time * 0.3, bob_time * 0.3);
        self RotateYaw(180, bob_time);
        wait(bob_time);
    }
}

// NEW: Melee detection with trigger_damage helper (better hitbox)
function reward_melee_watcher_with_trigger(owner)
{
    self endon("death");
    self endon("reward_claimed");
    
    // Skip for powerups (they can't be meleed to share)
    if(IsDefined(self.is_challenge_reward))
    {
        return;
    }
    
    // Spawn invisible trigger_damage around the reward model (larger hitbox)
    trigger = Spawn("trigger_damage", self.origin, 0, 48, 96); // radius 48, height 96 (generous hitbox for small models)
    trigger EnableLinkTo();
    trigger LinkTo(self); // Follow the model
    
    self thread reward_melee_trigger_cleanup(trigger);
    
    while(true)
    {
        // Wait for damage on the trigger (much larger hitbox than model)
        trigger waittill("damage", amount, attacker, direction, point, damageType);
        
        IPrintLnBold("^6[MELEE DEBUG] Damage detected! Type: " + damageType + " Attacker: " + (IsDefined(attacker) ? attacker.name : "undefined"));
        
        // Check if melee damage from owner
        if(IsDefined(attacker) && attacker == owner && damageType == "MOD_MELEE")
        {
            IPrintLnBold("^2[MELEE DEBUG] Valid melee from owner - sharing reward!");
            
            // Mark as shared
            self.is_shared = true;
            
            // Make visible to everyone
            self SetVisibleToAll();
            
            // Change FX to green (shared state)
            self clientfield::set("reward_shared", 1);
            
            // Notify players
            owner IPrintLnBold("^3You shared a reward with your team!");
            
            players = getplayers();
            foreach(player in players)
            {
                if(player != owner)
                {
                    player IPrintLnBold("^2" + owner.name + " ^3shared a reward!");
                }
            }
            
            // Clean up trigger
            trigger Delete();
            
            return; // Stop watching for melee
        }
        
        wait(0.05);
    }
}

// Clean up trigger when reward is claimed/deleted
function reward_melee_trigger_cleanup(trigger)
{
    self util::waittill_any("death", "reward_claimed");
    
    if(IsDefined(trigger))
    {
        trigger Delete();
    }
}

// OLD: Direct model damage detection (kept for reference, not used)
function reward_melee_watcher(owner)
{
    self endon("death");
    self endon("reward_claimed");
    
    // Skip for powerups (they can't be meleed to share)
    if(IsDefined(self.is_challenge_reward))
    {
        return;
    }
    
    while(true)
    {
        // Wait for owner to melee this reward
        self waittill("damage", amount, attacker, direction, point, damageType);
        
        IPrintLnBold("^6[MELEE DEBUG] Damage detected! Type: " + damageType + " Attacker: " + (IsDefined(attacker) ? attacker.name : "undefined"));
        
        // Check if melee damage from owner
        if(IsDefined(attacker) && attacker == owner && damageType == "MOD_MELEE")
        {
            IPrintLnBold("^2[MELEE DEBUG] Valid melee from owner - sharing reward!");
            
            // Mark as shared
            self.is_shared = true;
            
            // Make visible to everyone
            self SetVisibleToAll();
            
            // Change FX to green (shared state)
            self clientfield::set("reward_shared", 1);
            
            // Notify players
            owner IPrintLnBold("^3You shared a reward with your team!");
            
            players = getplayers();
            foreach(player in players)
            {
                if(player != owner)
                {
                    player IPrintLnBold("^2" + owner.name + " ^3shared a reward!");
                }
            }
            
            return; // Stop watching for melee
        }
        
        wait(0.05);
    }
}

function reward_setup_pickup(player)
{
    self endon("death");
    
    // Official powerups handle their own pickup
    if(IsDefined(self.is_challenge_reward))
    {
        // The powerup already has its grab system running
        // Just make it player-specific
        self.powerup_player = player;
        return;
    }
    
    // Create unitrigger for custom reward models (matching old crate pattern)
    trigger_origin = self.base_origin + (0, 0, 16); // Match old crate offset
    IPrintLnBold("^6[DEBUG] Creating unitrigger at: " + trigger_origin);
    
    unitrigger_stub = SpawnStruct();
    unitrigger_stub.origin = trigger_origin;
    unitrigger_stub.angles = self.angles;
    unitrigger_stub.radius = 64;
    unitrigger_stub.script_height = 64; // Match old crate pattern exactly
    unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
    unitrigger_stub.cursor_hint = "HINT_NOICON";
    unitrigger_stub.require_look_at = true;
    unitrigger_stub.reward_model = self; // Store entity reference only (like old crate pattern)
    
    unitrigger_stub.prompt_and_visibility_func = &reward_pickup_hint;
    
    zm_unitrigger::register_static_unitrigger(unitrigger_stub, &reward_pickup_think);
    
    IPrintLnBold("^2[DEBUG] Unitrigger registered successfully!");
    self.unitrigger = unitrigger_stub;
}

function reward_pickup_hint(player)
{
    // Check if model and data still exist
    if(!IsDefined(self.stub.reward_model))
    {
        self SetHintString("");
        return false;
    }
    
    if(!IsDefined(self.stub.reward_model.reward_data))
    {
        self SetHintString("");
        return false;
    }
    
    reward_model = self.stub.reward_model;
    
    // Check if player can claim this reward
    // Can claim if: owner OR shared
    can_claim = false;
    if(IsDefined(reward_model.owner) && reward_model.owner == player)
    {
        can_claim = true; // Owner can always claim
    }
    else if(IsDefined(reward_model.is_shared) && reward_model.is_shared)
    {
        can_claim = true; // Shared reward, anyone can claim
    }
    
    if(!can_claim)
    {
        self SetHintString("");
        return false; // Not owner and not shared = can't see/claim
    }
    
    // Model exists and player can claim, show hint
    reward_name = get_reward_display_name(reward_model.reward_data);
    
    if(reward_model.owner == player)
    {
        self SetHintString("Press ^3&&1^7 to claim " + reward_name + " ^7[Melee to share]");
    }
    else
    {
        // Shared reward
        self SetHintString("Press ^3&&1^7 to claim " + reward_name + " ^7[Shared]");
    }
    return true;
}

function reward_pickup_think()
{
    self endon("kill_trigger");
    
    // Wait for ANY player to claim this reward (first come first serve)
    self waittill("trigger", player);
    
    // Give reward (access through stub reference)
    if(IsDefined(self.stub.reward_model) && IsDefined(self.stub.reward_model.reward_data))
    {
        player thread give_reward(self.stub.reward_model.reward_data);
    }
    
    // Cleanup
    if(IsDefined(self.stub.reward_model))
    {
        // Store index before deleting
        reward_index = self.stub.reward_model.reward_index;
        
        // Disable glow FX before deleting
        self.stub.reward_model clientfield::set("reward_glow", 0);
        self.stub.reward_model notify("reward_claimed");
        self.stub.reward_model Delete();
        
        // Clear from level array so monitor can detect completion
        if(IsDefined(reward_index) && IsDefined(level.tedd_reward_models))
        {
            level.tedd_reward_models[reward_index] = undefined;
            IPrintLnBold("^6[DEBUG] Reward " + (reward_index + 1) + " cleared from level array");
        }
    }
    zm_unitrigger::unregister_unitrigger(self.stub);
}

function get_reward_display_name(reward)
{
    switch(reward.type)
    {
        case REWARD_TYPE_BONUS_POINTS:
            return "^3BONUS POINTS";
        case REWARD_TYPE_PERK:
            if(IsDefined(reward.perk_name))
            {
                return "^2PERK BOTTLE";
            }
            return "^2RANDOM PERK";
        case REWARD_TYPE_AMMO:
            return "^6MAX AMMO";
        case REWARD_TYPE_EQUIPMENT:
            return "^1FRAG GRENADES";
        case REWARD_TYPE_POWERUP:
            if(IsDefined(reward.powerup_name))
            {
                name_map = [];
                name_map["double_points"] = "DOUBLE POINTS";
                name_map["insta_kill"] = "INSTA-KILL";
                name_map["full_ammo"] = "MAX AMMO";
                name_map["nuke"] = "NUKE";
                name_map["fire_sale"] = "FIRE SALE";
                name_map["carpenter"] = "CARPENTER";
                
                if(IsDefined(name_map[reward.powerup_name]))
                {
                    return "^5" + name_map[reward.powerup_name];
                }
            }
            return "^5POWER-UP";
    }
    return "REWARD";
}

function despawn_reward_crate()
{
    if(!IsDefined(level.tedd_active_reward))
    {
        return;
    }
    
    // Prevent double-despawn
    if(IsDefined(level.tedd_active_reward.despawning))
    {
        return;
    }
    
    level.tedd_active_reward.despawning = true;
    
    IPrintLnBold("^6Despawning reward crate...");
    
    // Remove trigger if still exists
    if(IsDefined(level.tedd_active_reward.trigger))
    {
        level.tedd_active_reward.trigger notify("kill_trigger");
        wait(0.05);
        zm_unitrigger::unregister_unitrigger(level.tedd_active_reward.trigger);
        level.tedd_active_reward.trigger = undefined;
    }
    
    // Delete crate model
    if(IsDefined(level.tedd_active_reward.crate))
    {
        level.tedd_active_reward.crate Delete();
        level.tedd_active_reward.crate = undefined;
    }
    
    // Clear reward struct
    level.tedd_active_reward = undefined;
    
    // Clear claimed flags for all players
    players = getplayers();
    foreach(player in players)
    {
        player.tedd_reward_claimed = undefined;
    }
    
    // Allow new machine spawns
    level.tedd_machine_available = true;
    
    IPrintLnBold("^2Challenge cycle complete! Machine can spawn next round.");
}

function despawn_reward_crate_delayed(delay_seconds)
{
    wait(delay_seconds);
    despawn_reward_crate();
}

//*****************************************************************************
// REWARD GENERATION - TIER-BASED SYSTEM
//*****************************************************************************

function get_reward_count_for_tier(tier)
{
    min_count = 2;
    max_count = 4;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            min_count = REWARD_COUNT_RARE_MIN;
            max_count = REWARD_COUNT_RARE_MAX;
            break;
        case CHALLENGE_TIER_EPIC:
            min_count = REWARD_COUNT_EPIC_MIN;
            max_count = REWARD_COUNT_EPIC_MAX;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            min_count = REWARD_COUNT_LEGENDARY_MIN;
            max_count = REWARD_COUNT_LEGENDARY_MAX;
            break;
    }
    
    // Randomize within range
    count = RandomIntRange(min_count, max_count + 1);
    return count;
}

function roll_rewards_for_tier(tier, count)
{
    rewards = [];
    used_types = []; // Track which types we've already rolled
    
    // Track what we've rolled to ensure guarantees are met
    has_perk = false;
    has_powerup = false;
    
    // Roll initial rewards (with duplicate prevention)
    for(i = 0; i < count; i++)
    {
        max_attempts = 20; // Prevent infinite loop
        attempts = 0;
        reward = undefined;
        
        // Keep rolling until we get a unique type (or hit max attempts)
        while(attempts < max_attempts)
        {
            reward = roll_single_reward(tier);
            
            // Check if this type was already rolled
            already_has_type = false;
            foreach(used_type in used_types)
            {
                if(reward.type == used_type)
                {
                    already_has_type = true;
                    break;
                }
            }
            
            // If unique type, use it
            if(!already_has_type)
            {
                break;
            }
            
            attempts++;
        }
        
        // Add reward (even if duplicate after max attempts - safety fallback)
        rewards[i] = reward;
        used_types[used_types.size] = reward.type;
        
        // Track types
        if(reward.type == REWARD_TYPE_PERK)
            has_perk = true;
        if(reward.type == REWARD_TYPE_POWERUP)
            has_powerup = true;
    }
    
    // Apply tier-specific guarantees (may override duplicates)
    switch(tier)
    {
        case CHALLENGE_TIER_EPIC:
            // Epic: Guarantee at least 1 powerup OR perk
            if(EPIC_GUARANTEE_POWERUP_OR_PERK && !has_perk && !has_powerup)
            {
                // Replace first reward with powerup or perk
                if(RandomInt(100) < 50)
                    rewards[0] = create_powerup_reward(tier);
                else
                    rewards[0] = create_perk_reward(tier);
            }
            break;
            
        case CHALLENGE_TIER_LEGENDARY:
            // Legendary: Guarantee 1 perk + 1 powerup
            if(LEGENDARY_GUARANTEE_PERK && !has_perk)
            {
                // Replace first reward with perk
                rewards[0] = create_perk_reward(tier);
            }
            if(LEGENDARY_GUARANTEE_POWERUP && !has_powerup)
            {
                // Replace second reward with powerup (or third if first is powerup)
                if(rewards[0].type == REWARD_TYPE_POWERUP)
                    rewards[1] = create_powerup_reward(tier);
                else
                    rewards[1] = create_powerup_reward(tier);
            }
            break;
    }
    
    return rewards;
}

function roll_single_reward(tier)
{
    // Build weighted pool based on tier
    weighted_pool = [];
    
    // Get weights for this tier
    weights = get_tier_weights(tier);
    
    // Build weighted array (add each type X times based on weight)
    foreach(type, weight in weights)
    {
        for(i = 0; i < weight; i++)
        {
            weighted_pool[weighted_pool.size] = type;
        }
    }
    
    // Pick random from weighted pool
    if(weighted_pool.size == 0)
    {
        // Fallback to points
        return create_points_reward(tier);
    }
    
    reward_type = array::random(weighted_pool);
    
    // Create specific reward based on type
    switch(reward_type)
    {
        case REWARD_TYPE_BONUS_POINTS:
            return create_points_reward(tier);
        case REWARD_TYPE_PERK:
            return create_perk_reward(tier);
        case REWARD_TYPE_AMMO:
            return create_ammo_reward(tier);
        case REWARD_TYPE_POWERUP:
            return create_powerup_reward(tier);
        case REWARD_TYPE_EQUIPMENT:
            return create_equipment_reward(tier);
        case REWARD_TYPE_WEAPON:
            return create_weapon_reward(tier);
        case REWARD_TYPE_WONDER_WEAPON:
            return create_wonder_weapon_reward(tier);
        default:
            return create_points_reward(tier);
    }
}

function get_tier_weights(tier)
{
    weights = [];
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            weights[REWARD_TYPE_BONUS_POINTS] = WEIGHT_RARE_BONUS_POINTS;
            weights[REWARD_TYPE_AMMO] = WEIGHT_RARE_AMMO;
            weights[REWARD_TYPE_POWERUP] = WEIGHT_RARE_POWERUP;
            weights[REWARD_TYPE_EQUIPMENT] = WEIGHT_RARE_EQUIPMENT;
            weights[REWARD_TYPE_PERK] = WEIGHT_RARE_PERK;
            weights[REWARD_TYPE_WEAPON] = WEIGHT_RARE_WEAPON;
            weights[REWARD_TYPE_WONDER_WEAPON] = WEIGHT_RARE_WONDER_WEAPON;
            break;
            
        case CHALLENGE_TIER_EPIC:
            weights[REWARD_TYPE_BONUS_POINTS] = WEIGHT_EPIC_BONUS_POINTS;
            weights[REWARD_TYPE_AMMO] = WEIGHT_EPIC_AMMO;
            weights[REWARD_TYPE_POWERUP] = WEIGHT_EPIC_POWERUP;
            weights[REWARD_TYPE_EQUIPMENT] = WEIGHT_EPIC_EQUIPMENT;
            weights[REWARD_TYPE_PERK] = WEIGHT_EPIC_PERK;
            weights[REWARD_TYPE_WEAPON] = WEIGHT_EPIC_WEAPON;
            weights[REWARD_TYPE_WONDER_WEAPON] = WEIGHT_EPIC_WONDER_WEAPON;
            break;
            
        case CHALLENGE_TIER_LEGENDARY:
            weights[REWARD_TYPE_BONUS_POINTS] = WEIGHT_LEGENDARY_BONUS_POINTS;
            weights[REWARD_TYPE_AMMO] = WEIGHT_LEGENDARY_AMMO;
            weights[REWARD_TYPE_POWERUP] = WEIGHT_LEGENDARY_POWERUP;
            weights[REWARD_TYPE_EQUIPMENT] = WEIGHT_LEGENDARY_EQUIPMENT;
            weights[REWARD_TYPE_PERK] = WEIGHT_LEGENDARY_PERK;
            weights[REWARD_TYPE_WEAPON] = WEIGHT_LEGENDARY_WEAPON;
            weights[REWARD_TYPE_WONDER_WEAPON] = WEIGHT_LEGENDARY_WONDER_WEAPON;
            break;
            
        default:
            // Fallback to Rare weights
            weights[REWARD_TYPE_BONUS_POINTS] = 50;
            weights[REWARD_TYPE_AMMO] = 30;
            weights[REWARD_TYPE_POWERUP] = 15;
            weights[REWARD_TYPE_EQUIPMENT] = 5;
            break;
    }
    
    return weights;
}

// ====================================================================
// REWARD CREATION FUNCTIONS (Type-Specific)
// ====================================================================

function create_points_reward(tier)
{
    reward = SpawnStruct();
    reward.type = REWARD_TYPE_BONUS_POINTS;
    
    // Randomize points within tier range
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            reward.amount = RandomIntRange(POINTS_RARE_MIN, POINTS_RARE_MAX + 1);
            break;
        case CHALLENGE_TIER_EPIC:
            reward.amount = RandomIntRange(POINTS_EPIC_MIN, POINTS_EPIC_MAX + 1);
            break;
        case CHALLENGE_TIER_LEGENDARY:
            reward.amount = RandomIntRange(POINTS_LEGENDARY_MIN, POINTS_LEGENDARY_MAX + 1);
            break;
        default:
            reward.amount = 1000;
            break;
    }
    
    return reward;
}

function create_perk_reward(tier)
{
    reward = SpawnStruct();
    reward.type = REWARD_TYPE_PERK;
    
    // Select perk based on tier quality
    perk_pool = [];
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            // Common perks only (shouldn't happen due to weight 0, but safety)
            perk_pool[0] = PERK_COMMON_SPEED_COLA;
            perk_pool[1] = PERK_COMMON_STAMINUP;
            perk_pool[2] = PERK_COMMON_DEADSHOT;
            break;
            
        case CHALLENGE_TIER_EPIC:
            // Mix of common and premium (70% common, 30% premium)
            perk_pool[0] = PERK_COMMON_SPEED_COLA;
            perk_pool[1] = PERK_COMMON_STAMINUP;
            perk_pool[2] = PERK_COMMON_DEADSHOT;
            perk_pool[3] = PERK_COMMON_SPEED_COLA;
            perk_pool[4] = PERK_COMMON_STAMINUP;
            perk_pool[5] = PERK_COMMON_DEADSHOT;
            perk_pool[6] = PERK_COMMON_DEADSHOT;
            perk_pool[7] = PERK_PREMIUM_JUGGERNOG;
            perk_pool[8] = PERK_PREMIUM_QUICK_REVIVE;
            perk_pool[9] = PERK_PREMIUM_DOUBLE_TAP;
            break;
            
        case CHALLENGE_TIER_LEGENDARY:
            // Premium perks heavily favored (80% premium, 20% common)
            perk_pool[0] = PERK_PREMIUM_JUGGERNOG;
            perk_pool[1] = PERK_PREMIUM_QUICK_REVIVE;
            perk_pool[2] = PERK_PREMIUM_DOUBLE_TAP;
            perk_pool[3] = PERK_PREMIUM_WIDOWS_WINE;
            perk_pool[4] = PERK_PREMIUM_MULE_KICK;
            perk_pool[5] = PERK_PREMIUM_JUGGERNOG;
            perk_pool[6] = PERK_PREMIUM_QUICK_REVIVE;
            perk_pool[7] = PERK_PREMIUM_DOUBLE_TAP;
            perk_pool[8] = PERK_COMMON_SPEED_COLA;
            perk_pool[9] = PERK_COMMON_STAMINUP;
            break;
    }
    
    reward.perk_name = array::random(perk_pool);
    return reward;
}

function create_ammo_reward(tier)
{
    reward = SpawnStruct();
    reward.type = REWARD_TYPE_AMMO;
    reward.amount = 100; // Full ammo
    return reward;
}

function create_powerup_reward(tier)
{
    reward = SpawnStruct();
    reward.type = REWARD_TYPE_POWERUP;
    
    // Select powerup based on tier quality
    powerup_pool = [];
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            // Basic powerups only
            powerup_pool[0] = POWERUP_BASIC_DOUBLE_POINTS;
            powerup_pool[1] = POWERUP_BASIC_MAX_AMMO;
            powerup_pool[2] = POWERUP_BASIC_DOUBLE_POINTS;
            break;
            
        case CHALLENGE_TIER_EPIC:
            // Better powerups (50% basic, 50% better)
            powerup_pool[0] = POWERUP_BASIC_DOUBLE_POINTS;
            powerup_pool[1] = POWERUP_BASIC_MAX_AMMO;
            powerup_pool[2] = POWERUP_BETTER_INSTA_KILL;
            powerup_pool[3] = POWERUP_BETTER_CARPENTER;
            powerup_pool[4] = POWERUP_BETTER_FIRE_SALE;
            break;
            
        case CHALLENGE_TIER_LEGENDARY:
            // Premium powerups (70% premium, 30% better)
            powerup_pool[0] = POWERUP_PREMIUM_NUKE;
            powerup_pool[1] = POWERUP_PREMIUM_NUKE;
            powerup_pool[2] = POWERUP_PREMIUM_NUKE;
            powerup_pool[3] = POWERUP_BETTER_INSTA_KILL;
            powerup_pool[4] = POWERUP_BETTER_FIRE_SALE;
            powerup_pool[5] = POWERUP_BETTER_CARPENTER;
            powerup_pool[6] = POWERUP_PREMIUM_NUKE;
            break;
    }
    
    reward.powerup_name = array::random(powerup_pool);
    return reward;
}

function create_equipment_reward(tier)
{
    reward = SpawnStruct();
    reward.type = REWARD_TYPE_EQUIPMENT;
    reward.equipment_name = EQUIPMENT_FRAG_GRENADE;
    return reward;
}

function create_weapon_reward(tier)
{
    reward = SpawnStruct();
    reward.type = REWARD_TYPE_WEAPON;
    // TODO: Implement weapon selection logic
    reward.weapon_name = "none"; // Placeholder
    return reward;
}

function create_wonder_weapon_reward(tier)
{
    reward = SpawnStruct();
    reward.type = REWARD_TYPE_WONDER_WEAPON;
    // TODO: Implement wonder weapon selection logic
    reward.weapon_name = "none"; // Placeholder
    return reward;
}

function give_reward(reward)
{
    IPrintLnBold("^3[DEBUG] give_reward() called with type: " + reward.type);
    
    switch(reward.type)
    {
        case REWARD_TYPE_BONUS_POINTS:
            IPrintLnBold("^3[DEBUG] Giving " + reward.amount + " points");
            self zm_score::add_to_player_score(reward.amount);
            self IPrintLnBold("^2+" + reward.amount + " points!");
            break;
        case REWARD_TYPE_PERK:
            IPrintLnBold("^3[DEBUG] Giving perk: " + reward.perk_name);
            self zm_perks::give_perk(reward.perk_name);
            break;
        case REWARD_TYPE_AMMO:
            IPrintLnBold("^3[DEBUG] Giving max ammo");
            self GiveMaxAmmo(self GetCurrentWeapon());
            self IPrintLnBold("^2Max Ammo!");
            break;
        case REWARD_TYPE_EQUIPMENT:
            IPrintLnBold("^3[DEBUG] Giving equipment: " + reward.equipment_name);
            self give_equipment(reward.equipment_name);
            self IPrintLnBold("^2Frag Grenades Refilled!");
            break;
        case REWARD_TYPE_POWERUP:
            IPrintLnBold("^3[DEBUG] Spawning powerup: " + reward.powerup_name);
            level thread zm_powerups::specific_powerup_drop(reward.powerup_name, self.origin);
            self IPrintLnBold("^2Powerup spawned!");
            break;
        default:
            IPrintLnBold("^1[DEBUG] ERROR: Unknown reward type: " + reward.type);
            break;
    }
    
    IPrintLnBold("^3[DEBUG] give_reward() completed");
}

function give_random_perk()
{
    perks = GetArrayKeys(level._custom_perks);
    perk = array::random(perks);
    self zm_perks::give_perk(perk);
    return perk; // Return perk name for notification
}

function give_equipment(equipment_name)
{
    // Get equipment weapon
    equipment_weapon = GetWeapon(equipment_name);
    
    // Check if player has this equipment
    if(self HasWeapon(equipment_weapon))
    {
        // Refill ammo (give max ammo for equipment slot)
        self GiveMaxAmmo(equipment_weapon);
        IPrintLnBold("^3[DEBUG] Refilled equipment ammo");
    }
    else
    {
        // Give equipment weapon
        self GiveWeapon(equipment_weapon);
        self SetWeaponAmmoClip(equipment_weapon, 2); // Start with 2 grenades
        IPrintLnBold("^3[DEBUG] Gave new equipment weapon");
    }
}

//*****************************************************************************
// REWARD DATA CONVERSION
//*****************************************************************************

function get_reward_type_id(reward)
{
    type = reward.type;
    base_type = 0;
    sub_id = 0;
    
    switch(type)
    {
        case "bonus_points":
            base_type = 0;
            break;
        case "perk":
            base_type = 1;
            if(IsDefined(reward.perk_name))
                sub_id = get_perk_id(reward.perk_name);
            break;
        case "ammo":
            base_type = 2;
            break;
        case "powerup":
            base_type = 3;
            if(IsDefined(reward.powerup_name))
                sub_id = get_powerup_id(reward.powerup_name);
            break;
    }
    
    // Encode: bits 0-1 = base type (0-3), bits 2-5 = sub ID (0-15)
    // Result: (sub_id << 2) | base_type
    encoded = (sub_id << 2) | base_type;
    return encoded;
}

function get_perk_id(perk_name)
{
    // Map perk names to IDs (0-15)
    switch(perk_name)
    {
        case "specialty_armorvest": return 0;      // Juggernog
        case "specialty_quickrevive": return 1;     // Quick Revive
        case "specialty_fastreload": return 2;      // Speed Cola
        case "specialty_doubletap2": return 3;      // Double Tap
        case "specialty_staminup": return 4;        // Stamin-Up
        case "specialty_widowswine": return 5;      // Widow's Wine
        case "specialty_deadshot": return 6;        // Deadshot
        case "specialty_additionalprimaryweapon": return 7; // Mule Kick
        default: return 0;
    }
}

function get_powerup_id(powerup_name)
{
    // Map powerup names to IDs (0-15)
    switch(powerup_name)
    {
        case "full_ammo": return 0;
        case "double_points": return 1;
        case "insta_kill": return 2;
        case "nuke": return 3;
        case "fire_sale": return 4;
        case "carpenter": return 5;
        default: return 0;
    }
}

function get_reward_value(reward)
{
    if(IsDefined(reward.amount))
    {
        return int(reward.amount / 10); // Scale down for 10-bit field
    }
    return 0;
}

//*****************************************************************************
// CLEANUP
//*****************************************************************************

function monitor_all_rewards_claimed()
{
    level endon("end_game");
    
    // Get actual reward count
    if(IsDefined(level.tedd_reward_models_count))
    {
        total_rewards = level.tedd_reward_models_count;
    }
    else
    {
        total_rewards = 4; // Fallback
    }
    
    IPrintLnBold("^6[DEBUG] monitor_all_rewards_claimed() started - waiting for all " + total_rewards + " rewards to be claimed");
    
    // Wait until all reward models are deleted or claimed
    while(true)
    {
        wait(0.5);
        
        // Count how many rewards still exist
        remaining_rewards = 0;
        if(IsDefined(level.tedd_reward_models))
        {
            for(i = 0; i < total_rewards; i++)
            {
                if(IsDefined(level.tedd_reward_models[i]))
                {
                    remaining_rewards++;
                }
            }
        }
        
        IPrintLnBold("^6[DEBUG] Remaining rewards: " + remaining_rewards);
        
        // If all rewards are claimed (none remaining), trigger cleanup
        if(remaining_rewards == 0)
        {
            IPrintLnBold("^2[DEBUG] All rewards claimed! Triggering cleanup...");
            wait(2); // Small delay before cleanup
            level thread despawn_reward_crate();
            return; // Exit monitoring
        }
    }
}

function monitor_powerup_pickup()
{
    self endon("death");
    
    // Wait for powerup to be deleted (picked up by official system)
    self waittill("death");
    
    // Clear from level array
    if(IsDefined(self.reward_index) && IsDefined(level.tedd_reward_models))
    {
        level.tedd_reward_models[self.reward_index] = undefined;
        IPrintLnBold("^6[DEBUG] Powerup reward " + (self.reward_index + 1) + " cleared from level array");
    }
}

function auto_give_reward()
{
    // Use the stored reward tier (handles partial completion correctly)
    tier = CHALLENGE_TIER_RARE; // Default fallback
    if(IsDefined(level.tedd_active_reward) && IsDefined(level.tedd_active_reward.reward_tier))
    {
        tier = level.tedd_active_reward.reward_tier;
    }
    else if(IsDefined(level.tedd_challenge_tier))
    {
        tier = level.tedd_challenge_tier;
    }
    
    reward_points = zm_tedd_tasks_utils::get_tier_reward(tier);
    
    players = getplayers();
    foreach(player in players)
    {
        player zm_score::add_to_player_score(reward_points);
        player IPrintLnBold("^2Received " + reward_points + " points!");
        player.tedd_reward_claimed = true;  // Mark as claimed
    }
    
    // Despawn after auto-giving
    wait(2);
    level thread despawn_reward_crate();
}
