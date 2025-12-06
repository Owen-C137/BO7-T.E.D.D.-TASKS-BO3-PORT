// ====================================================================
// TEDD Tasks System - Machine Management
// Handles machine spawning, despawning, states, animations
// ====================================================================

#using scripts\shared\array_shared;
#using scripts\shared\util_shared;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_score;

#insert scripts\zm\tedd_tasks\zm_tedd_tasks_config.gsh;

// Import challenges module for start_horde_challenge
#using scripts\zm\tedd_tasks\zm_tedd_tasks_challenges;

#using_animtree("zm_challenge_machine");

#namespace zm_tedd_tasks_machine;

//*****************************************************************************
// MACHINE SPAWNING
//*****************************************************************************

function spawn_machine()
{
    if(IsDefined(level.tedd_active_machine))
    {
        return; // Machine already spawned
    }
    
    // Select random location (different from last one if possible)
    selected_machine = undefined;
    selected_index = -1;
    
    if(CHALLENGE_RANDOM_LOCATION && level.tedd_spawn_locations.size > 1)
    {
        // Pick random machine that's different from last one
        attempts = 0;
        while(attempts < 10)
        {
            selected_index = RandomInt(level.tedd_spawn_locations.size);
            
            if(selected_index != level.tedd_last_machine_index)
            {
                break;
            }
            
            attempts++;
        }
        
        selected_machine = level.tedd_spawn_locations[selected_index];
    }
    else
    {
        // Use first machine
        selected_index = 0;
        selected_machine = level.tedd_spawn_locations[0];
    }
    
    // Store last index
    level.tedd_last_machine_index = selected_index;
    
    // Show the model
    selected_machine Show();
    
    // Set up animtree for animations
    selected_machine useanimtree(#animtree);
    
    // Play idle off animation
    selected_machine thread play_machine_animation("off_idle");
    
    // Spawn FX helper model (rotated 90 degrees on X axis for correct FX orientation)
    fx_model = Spawn("script_model", selected_machine.origin);
    fx_model.angles = selected_machine.angles + (-90, 0, 0);
    fx_model SetModel("tag_origin");
    fx_model LinkTo(selected_machine);
    
    // Play FX on the rotated helper model
    playfxontag(level._effect["tedd_machine_marker"], fx_model, "tag_origin");
    
    // Create unitrigger for interaction
    unitrigger_stub = SpawnStruct();
    unitrigger_stub.origin = selected_machine.origin + (0, 0, 32);
    unitrigger_stub.angles = selected_machine.angles;
    unitrigger_stub.script_unitrigger_type = "unitrigger_radius_use";
    unitrigger_stub.radius = CHALLENGE_MACHINE_RADIUS;
    unitrigger_stub.script_height = CHALLENGE_MACHINE_HEIGHT;
    unitrigger_stub.cursor_hint = "HINT_NOICON";
    unitrigger_stub.require_look_at = true;
    unitrigger_stub.machine_model = selected_machine;
    unitrigger_stub.prompt_and_visibility_func = &machine_update_hint;
    
    // Register the unitrigger
    zm_unitrigger::register_static_unitrigger(unitrigger_stub, &machine_trigger_think);
    
    // Find linked trigger volume (if exists) for location challenges
    // Use script_int matching system (same as old system)
    zone_trigger = undefined;
    if(IsDefined(selected_machine.script_int))
    {
        machine_id = selected_machine.script_int;
        
        // Find trigger with matching script_int
        all_triggers = GetEntArray("trigger_multiple", "classname");
        foreach(trigger in all_triggers)
        {
            if(IsDefined(trigger.script_int) && trigger.script_int == machine_id)
            {
                zone_trigger = trigger;
                IPrintLnBold("^2Machine linked to zone: " + trigger.targetname);
                break;
            }
        }
        
        if(!IsDefined(zone_trigger))
        {
            IPrintLnBold("^1No trigger found with ID " + machine_id);
        }
    }
    
    // Store active machine reference
    level.tedd_active_machine = SpawnStruct();
    level.tedd_active_machine.model = selected_machine;
    level.tedd_active_machine.trigger = unitrigger_stub;
    level.tedd_active_machine.machine_index = selected_index;
    level.tedd_active_machine.fx_model = fx_model;
    level.tedd_active_machine.location_index = selected_index;
    level.tedd_active_machine.zone_trigger = zone_trigger;  // Store for location challenges
    
    // Show spawn notification to all players
    level thread show_machine_spawn_notification(selected_index);
    
    // Set initial state to IDLE (exactly like old system)
    set_machine_state(selected_machine, "idle");
    
    // Play machine idle sound with talking animation, return to off_idle (machine not active yet)
    selected_machine thread play_voice_line_with_anim("tedd_tasks_machine_idle", 5.0, "off_idle");
}

function machine_update_hint(player)
{
    // Check if challenge already active
    if(level.tedd_challenge_active)
    {
        self SetHintString("");
        return false;
    }
    
    // Check if machine is on cooldown (not available)
    if(!level.tedd_machine_available)
    {
        self SetHintString("^1Machine on cooldown...");
        return false;
    }
    
    // Check cost
    if(CHALLENGE_COST > 0)
    {
        self SetHintString("Hold ^3&&1^7 to start Challenge [Cost: ^3" + CHALLENGE_COST + "^7]");
    }
    else
    {
        self SetHintString("Hold ^3&&1^7 to start Challenge");
    }
    
    return true;
}

function machine_trigger_think()
{
    self endon("death");
    
    while(true)
    {
        self waittill("trigger", player);
        
        // Check if challenge already active
        if(level.tedd_challenge_active)
        {
            continue;
        }
        
        // Check if machine is available (not on cooldown)
        if(!level.tedd_machine_available)
        {
            player IPrintLnBold("^1Machine is on cooldown!");
            continue;
        }
        
        // Check cost
        if(CHALLENGE_COST > 0 && player.score < CHALLENGE_COST)
        {
            player IPrintLnBold("^1Not enough points! Need: " + CHALLENGE_COST);
            continue;
        }
        
        // Deduct cost
        if(CHALLENGE_COST > 0)
        {
            player zm_score::minus_to_player_score(CHALLENGE_COST);
        }
        
        // Mark machine as unavailable during challenge
        level.tedd_machine_available = false;
        
        // Play challenge start sound with talking animation (6 second duration, on_idle)
        if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
        {
            level.tedd_active_machine.model thread zm_tedd_tasks_machine::play_voice_line_with_anim("tedd_tasks_challenge_start", 6.0, "on_idle");
        }
        
        // Start random enabled challenge
        level thread start_random_challenge();
        break; // Stop listening after activation
    }
}

//*****************************************************************************
// MACHINE STATES
//*****************************************************************************

function set_machine_state(machine_model, state)
{
    if(!IsDefined(machine_model))
    {
        return;
    }
    
    // Hide all states (all 6 bones - exactly like old system)
    machine_model hidepart(MACHINE_TAG_IDLE);
    machine_model hidepart(MACHINE_TAG_ACTIVATED);
    machine_model hidepart(MACHINE_TAG_SUCCESS);
    machine_model hidepart(MACHINE_TAG_FAILED);
    machine_model hidepart(MACHINE_TAG_SMILE);
    machine_model hidepart(MACHINE_TAG_NEUTRAL);
    
    // Show requested state
    switch(state)
    {
        case "idle":
            machine_model showpart(MACHINE_TAG_IDLE);
            break;
        case "activated":
            machine_model showpart(MACHINE_TAG_ACTIVATED);
            break;
        case "success":
            machine_model showpart(MACHINE_TAG_SUCCESS);
            break;
        case "failed":
            machine_model showpart(MACHINE_TAG_FAILED);
            break;
        case "smile":
            machine_model showpart(MACHINE_TAG_SMILE);
            break;
        case "neutral":
            machine_model showpart(MACHINE_TAG_NEUTRAL);
            break;
    }
}

//*****************************************************************************
// MACHINE ANIMATIONS
//*****************************************************************************

function play_machine_animation(anim_name)
{
    self endon("death");
    
    if(!IsDefined(self))
    {
        return;
    }
    
    // Get full animation name
    full_anim_name = "sat_zm_obelisk_tesla_tower_silver_fxanim_" + anim_name;
    
    // Play the animation using AnimScripted (same as old system)
    self AnimScripted(full_anim_name, self.origin, self.angles, full_anim_name);
}

function play_voice_line_with_anim(sound_alias, duration, idle_anim)
{
    self endon("death");
    
    if(!IsDefined(self))
    {
        return;
    }
    
    // Default to on_idle if not specified
    if(!IsDefined(idle_anim))
    {
        idle_anim = "on_idle";
    }
    
    // Play voice line
    self PlaySound(sound_alias);
    
    // Play talking animation
    self thread play_machine_animation("talking");
    
    // Wait for duration, then return to specified idle state
    if(IsDefined(duration))
    {
        wait(duration);
        self thread play_machine_animation(idle_anim);
    }
}

function play_activation_sequence()
{
    self endon("death");
    
    // Play start animation
    self thread play_machine_animation("start");
    self PlaySound("zmb_powerup_grabbed");
    wait(2.0);
    
    // Play talking animation
    self thread play_machine_animation("talking");
    self PlaySound("zmb_vocals_announcer_success");
    wait(5.0);
    
    // Play idle
    self thread play_machine_animation("on_idle");
}

//*****************************************************************************
// MACHINE DESPAWN
//*****************************************************************************

function despawn_machine()
{
    if(!IsDefined(level.tedd_active_machine))
    {
        return;
    }
    
    // Delete FX model (stops FX effects)
    if(IsDefined(level.tedd_active_machine.fx_model))
    {
        level.tedd_active_machine.fx_model Delete();
    }
    
    // Unregister unitrigger
    if(IsDefined(level.tedd_active_machine.trigger))
    {
        zm_unitrigger::unregister_unitrigger(level.tedd_active_machine.trigger);
    }
    
    // Hide model
    if(IsDefined(level.tedd_active_machine.model))
    {
        level.tedd_active_machine.model Hide();
    }
    
    // Clear reference
    level.tedd_active_machine = undefined;
    level.tedd_machine_available = true;
}

//*****************************************************************************
// MACHINE FAILURE COOLDOWN
//*****************************************************************************

function machine_fail_cooldown()
{
    if(!IsDefined(level.tedd_active_machine))
    {
        return;
    }
    
    // Machine is in failed state - wait for cooldown
    wait(CHALLENGE_FAIL_COOLDOWN);
    
    // Transition back to idle state with voice line
    if(IsDefined(level.tedd_active_machine) && IsDefined(level.tedd_active_machine.model))
    {
        set_machine_state(level.tedd_active_machine.model, "idle");
        level.tedd_active_machine.model thread play_voice_line_with_anim("tedd_tasks_machine_idle", 4.0, "off_idle");
    }
    
    // Make machine available for new challenges
    level.tedd_machine_available = true;
}

//*****************************************************************************
// MACHINE SPAWN NOTIFICATION
//*****************************************************************************

function show_machine_spawn_notification(location_index)
{
    IPrintLnBold("^3[GSC] Showing machine spawn notification - Location: " + location_index);
    
    // Show notification to all players
    players = GetPlayers();
    
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_machine_spawn_location", location_index);
        player clientfield::set_player_uimodel("tedd_machine_spawn_active", 1);
        IPrintLnBold("^3[GSC] Set clientfields for player: " + player.name);
    }
    
    // Auto-hide after 7 seconds (sync with widget animation)
    wait(7);
    
    foreach(player in players)
    {
        player clientfield::set_player_uimodel("tedd_machine_spawn_active", 0);
    }
    
    IPrintLnBold("^3[GSC] Machine spawn notification hidden");
}

//*****************************************************************************
// CHALLENGE SELECTION
//*****************************************************************************

function start_random_challenge()
{
    // Build array of enabled challenge types
    enabled_challenges = [];
    
    if(CHALLENGE_ENABLE_SURVIVE_HORDE)
    {
        enabled_challenges[enabled_challenges.size] = "horde";
    }
    
    if(CHALLENGE_ENABLE_KILLS)
    {
        enabled_challenges[enabled_challenges.size] = "kills";
    }
    
    if(CHALLENGE_ENABLE_HEADSHOTS)
    {
        enabled_challenges[enabled_challenges.size] = "headshots";
    }
    
    if(CHALLENGE_ENABLE_MELEE)
    {
        enabled_challenges[enabled_challenges.size] = "melee";
    }
    
    if(CHALLENGE_ENABLE_KILL_IN_LOCATION)
    {
        enabled_challenges[enabled_challenges.size] = "kill_in_location";
    }
    
    if(CHALLENGE_ENABLE_SURVIVE_IN_LOCATION)
    {
        enabled_challenges[enabled_challenges.size] = "survive_in_location";
    }
    
    if(CHALLENGE_ENABLE_KILL_ELEVATION_HIGH)
    {
        enabled_challenges[enabled_challenges.size] = "kill_elevation_high";
    }
    
    if(CHALLENGE_ENABLE_KILL_ELEVATION_LOW)
    {
        enabled_challenges[enabled_challenges.size] = "kill_elevation_low";
    }
    
    if(CHALLENGE_ENABLE_STANDING_STILL)
    {
        enabled_challenges[enabled_challenges.size] = "standing_still";
    }
    
    if(CHALLENGE_ENABLE_CROUCHING)
    {
        enabled_challenges[enabled_challenges.size] = "crouching";
    }
    
    if(CHALLENGE_ENABLE_SLIDING)
    {
        enabled_challenges[enabled_challenges.size] = "sliding";
    }
    
    if(CHALLENGE_ENABLE_JUMPING)
    {
        enabled_challenges[enabled_challenges.size] = "jumping";
    }
    
    if(CHALLENGE_ENABLE_TRAP_KILLS)
    {
        enabled_challenges[enabled_challenges.size] = "trap_kills";
    }
    
    if(CHALLENGE_ENABLE_WEAPON_CLASS)
    {
        enabled_challenges[enabled_challenges.size] = "weapon_class";
    }
    
    if(CHALLENGE_ENABLE_EQUIPMENT_KILLS)
    {
        enabled_challenges[enabled_challenges.size] = "equipment_kills";
    }
    
    // Fallback if no challenges enabled
    if(enabled_challenges.size == 0)
    {
        IPrintLnBold("^1ERROR: No challenges enabled in config!");
        return;
    }
    
    // Filter out last challenge type to ensure variety (if more than 1 type enabled)
    if(IsDefined(level.tedd_last_challenge_type) && enabled_challenges.size > 1)
    {
        filtered_challenges = [];
        foreach(type in enabled_challenges)
        {
            if(type != level.tedd_last_challenge_type)
            {
                filtered_challenges[filtered_challenges.size] = type;
            }
        }
        
        // Use filtered list if we have options, otherwise use all
        if(filtered_challenges.size > 0)
        {
            enabled_challenges = filtered_challenges;
        }
    }
    
    // Pick random challenge from filtered list
    selected_challenge = array::random(enabled_challenges);
    
    // Store for next time
    level.tedd_last_challenge_type = selected_challenge;
    
    IPrintLnBold("^3Starting challenge: ^2" + selected_challenge);
    
    // Start the selected challenge
    switch(selected_challenge)
    {
        case "horde":
            level thread zm_tedd_tasks_challenges::start_horde_challenge();
            break;
        case "kills":
            level thread zm_tedd_tasks_challenges::start_kills_challenge();
            break;
        case "headshots":
            level thread zm_tedd_tasks_challenges::start_headshots_challenge();
            break;
        case "melee":
            level thread zm_tedd_tasks_challenges::start_melee_challenge();
            break;
        case "kill_in_location":
            level thread zm_tedd_tasks_challenges::start_kill_in_location_challenge();
            break;
        case "survive_in_location":
            level thread zm_tedd_tasks_challenges::start_survive_in_location_challenge();
            break;
        case "kill_elevation_high":
            level thread zm_tedd_tasks_challenges::start_kill_elevation_high_challenge();
            break;
        case "kill_elevation_low":
            level thread zm_tedd_tasks_challenges::start_kill_elevation_low_challenge();
            break;
        case "standing_still":
            level thread zm_tedd_tasks_challenges::start_standing_still_challenge();
            break;
        case "crouching":
            level thread zm_tedd_tasks_challenges::start_crouching_challenge();
            break;
        case "sliding":
            level thread zm_tedd_tasks_challenges::start_sliding_challenge();
            break;
        case "jumping":
            level thread zm_tedd_tasks_challenges::start_jumping_challenge();
            break;
        case "trap_kills":
            level thread zm_tedd_tasks_challenges::start_trap_kills_challenge();
            break;
        case "weapon_class":
            level thread zm_tedd_tasks_challenges::start_weapon_class_challenge();
            break;
        case "equipment_kills":
            level thread zm_tedd_tasks_challenges::start_equipment_kills_challenge();
            break;
    }
}
