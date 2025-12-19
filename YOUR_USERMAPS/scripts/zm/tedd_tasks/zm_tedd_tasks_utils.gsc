// ====================================================================
// TEDD Tasks System - Utilities
// Helper functions for tier names, rewards, logging, etc.
// ====================================================================

#using scripts\shared\exploder_shared;
#using scripts\zm\_zm_utility;

#insert scripts\zm\tedd_tasks\zm_tedd_tasks_config.gsh;

#namespace zm_tedd_tasks_utils;

//*****************************************************************************
// TIER UTILITIES
//*****************************************************************************

function get_tier_name(tier)
{
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            return "Rare";
        case CHALLENGE_TIER_EPIC:
            return "Epic";
        case CHALLENGE_TIER_LEGENDARY:
            return "Legendary";
        case CHALLENGE_TIER_ULTRA:
            return "Ultra";
    }
    return "Unknown";
}

function get_tier_reward(tier)
{
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            return CHALLENGE_TIER_RARE_REWARD;
        case CHALLENGE_TIER_EPIC:
            return CHALLENGE_TIER_EPIC_REWARD;
        case CHALLENGE_TIER_LEGENDARY:
            return CHALLENGE_TIER_LEGENDARY_REWARD;
        case CHALLENGE_TIER_ULTRA:
            return CHALLENGE_TIER_ULTRA_REWARD;
    }
    return 500;
}

//*****************************************************************************
// ROUND SCALING
//*****************************************************************************

function get_scaled_requirement(base_value, current_round)
{
    if(!CHALLENGE_ROUND_SCALING_ENABLED)
    {
        return base_value;
    }
    
    // Only scale from the starting round onwards
    if(current_round < CHALLENGE_ROUND_SCALING_START)
    {
        return base_value;
    }
    
    // Calculate scaling multiplier
    rounds_past_start = current_round - CHALLENGE_ROUND_SCALING_START;
    multiplier = 1.0 + (rounds_past_start * CHALLENGE_ROUND_SCALING_FACTOR);
    
    // Cap at max multiplier
    if(multiplier > CHALLENGE_ROUND_SCALING_MAX)
    {
        multiplier = CHALLENGE_ROUND_SCALING_MAX;
    }
    
    scaled_value = int(base_value * multiplier);
    return scaled_value;
}

//*****************************************************************************
// TIER REQUIREMENTS
//*****************************************************************************

function get_tier_kill_in_location_required(tier)
{
    base_kills = 0;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            base_kills = CHALLENGE_TIER_RARE_KILL_IN_LOCATION;
            break;
        case CHALLENGE_TIER_EPIC:
            base_kills = CHALLENGE_TIER_EPIC_KILL_IN_LOCATION;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            base_kills = CHALLENGE_TIER_LEGENDARY_KILL_IN_LOCATION;
            break;
        default:
            base_kills = CHALLENGE_TIER_RARE_KILL_IN_LOCATION;
            break;
    }
    
    // Apply round scaling
    return get_scaled_requirement(base_kills, level.round_number);
}

function get_tier_survive_in_location_required(tier)
{
    // Survive location does NOT scale with rounds - fixed time requirements
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            return CHALLENGE_TIER_RARE_SURVIVE_IN_LOCATION;
        case CHALLENGE_TIER_EPIC:
            return CHALLENGE_TIER_EPIC_SURVIVE_IN_LOCATION;
        case CHALLENGE_TIER_LEGENDARY:
            return CHALLENGE_TIER_LEGENDARY_SURVIVE_IN_LOCATION;
        default:
            return CHALLENGE_TIER_RARE_SURVIVE_IN_LOCATION;
    }
}

function get_tier_kill_elevation_high_required(tier)
{
    // Base requirement
    base_required = 0;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            base_required = CHALLENGE_TIER_RARE_KILL_ELEVATION_HIGH;
            break;
        case CHALLENGE_TIER_EPIC:
            base_required = CHALLENGE_TIER_EPIC_KILL_ELEVATION_HIGH;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            base_required = CHALLENGE_TIER_LEGENDARY_KILL_ELEVATION_HIGH;
            break;
        default:
            base_required = CHALLENGE_TIER_RARE_KILL_ELEVATION_HIGH;
            break;
    }
    
    // Apply round scaling if enabled
    if(CHALLENGE_ROUND_SCALING_ENABLED)
    {
        return get_scaled_requirement(base_required, level.round_number);
    }
    
    return base_required;
}

function get_tier_kill_elevation_low_required(tier)
{
    // Base requirement
    base_required = 0;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            base_required = CHALLENGE_TIER_RARE_KILL_ELEVATION_LOW;
            break;
        case CHALLENGE_TIER_EPIC:
            base_required = CHALLENGE_TIER_EPIC_KILL_ELEVATION_LOW;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            base_required = CHALLENGE_TIER_LEGENDARY_KILL_ELEVATION_LOW;
            break;
        default:
            base_required = CHALLENGE_TIER_RARE_KILL_ELEVATION_LOW;
            break;
    }
    
    // Apply round scaling if enabled
    if(CHALLENGE_ROUND_SCALING_ENABLED)
    {
        return get_scaled_requirement(base_required, level.round_number);
    }
    
    return base_required;
}

function get_tier_standing_still_required(tier)
{
    base_required = 0;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            base_required = CHALLENGE_TIER_RARE_STANDING_STILL;
            break;
        case CHALLENGE_TIER_EPIC:
            base_required = CHALLENGE_TIER_EPIC_STANDING_STILL;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            base_required = CHALLENGE_TIER_LEGENDARY_STANDING_STILL;
            break;
        default:
            base_required = CHALLENGE_TIER_RARE_STANDING_STILL;
            break;
    }
    
    return get_scaled_requirement(base_required, level.round_number);
}

function get_tier_crouching_required(tier)
{
    base_required = 0;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            base_required = CHALLENGE_TIER_RARE_CROUCHING;
            break;
        case CHALLENGE_TIER_EPIC:
            base_required = CHALLENGE_TIER_EPIC_CROUCHING;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            base_required = CHALLENGE_TIER_LEGENDARY_CROUCHING;
            break;
        default:
            base_required = CHALLENGE_TIER_RARE_CROUCHING;
            break;
    }
    
    return get_scaled_requirement(base_required, level.round_number);
}

function get_tier_sliding_required(tier)
{
    base_required = 0;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            base_required = CHALLENGE_TIER_RARE_SLIDING;
            break;
        case CHALLENGE_TIER_EPIC:
            base_required = CHALLENGE_TIER_EPIC_SLIDING;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            base_required = CHALLENGE_TIER_LEGENDARY_SLIDING;
            break;
        default:
            base_required = CHALLENGE_TIER_RARE_SLIDING;
            break;
    }
    
    return get_scaled_requirement(base_required, level.round_number);
}

function get_tier_jumping_required(tier)
{
    base_required = 0;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            base_required = CHALLENGE_TIER_RARE_JUMPING;
            break;
        case CHALLENGE_TIER_EPIC:
            base_required = CHALLENGE_TIER_EPIC_JUMPING;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            base_required = CHALLENGE_TIER_LEGENDARY_JUMPING;
            break;
        default:
            base_required = CHALLENGE_TIER_RARE_JUMPING;
            break;
    }
    
    return get_scaled_requirement(base_required, level.round_number);
}

function get_tier_trap_kills_required(tier)
{
    base_required = 0;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            base_required = CHALLENGE_TIER_RARE_TRAP_KILLS;
            break;
        case CHALLENGE_TIER_EPIC:
            base_required = CHALLENGE_TIER_EPIC_TRAP_KILLS;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            base_required = CHALLENGE_TIER_LEGENDARY_TRAP_KILLS;
            break;
        default:
            base_required = CHALLENGE_TIER_RARE_TRAP_KILLS;
            break;
    }
    
    return get_scaled_requirement(base_required, level.round_number);
}

function get_tier_weapon_class_required(tier)
{
    base_required = 0;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            base_required = CHALLENGE_TIER_RARE_WEAPON_CLASS;
            break;
        case CHALLENGE_TIER_EPIC:
            base_required = CHALLENGE_TIER_EPIC_WEAPON_CLASS;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            base_required = CHALLENGE_TIER_LEGENDARY_WEAPON_CLASS;
            break;
        default:
            base_required = CHALLENGE_TIER_RARE_WEAPON_CLASS;
            break;
    }
    
    return get_scaled_requirement(base_required, level.round_number);
}

function get_tier_equipment_kills_required(tier)
{
    base_required = 0;
    
    switch(tier)
    {
        case CHALLENGE_TIER_RARE:
            base_required = CHALLENGE_TIER_RARE_EQUIPMENT_KILLS;
            break;
        case CHALLENGE_TIER_EPIC:
            base_required = CHALLENGE_TIER_EPIC_EQUIPMENT_KILLS;
            break;
        case CHALLENGE_TIER_LEGENDARY:
            base_required = CHALLENGE_TIER_LEGENDARY_EQUIPMENT_KILLS;
            break;
        default:
            base_required = CHALLENGE_TIER_RARE_EQUIPMENT_KILLS;
            break;
    }
    
    return get_scaled_requirement(base_required, level.round_number);
}

function get_weapon_class_from_weapon(weapon)
{
    if(!IsDefined(weapon))
        return undefined;
    
    // CRITICAL: Check for wonder weapons FIRST (before regular weapon class)
    // Wonder weapons like Ray Gun are classified as pistols in stats table
    weapon_name = weapon.name;
    if(IsDefined(weapon_name))
    {
        if(IsSubStr(weapon_name, "ray_gun") || IsSubStr(weapon_name, "raygun"))
            return "wonder_weapon";
        if(IsSubStr(weapon_name, "thundergun"))
            return "wonder_weapon";
        if(IsSubStr(weapon_name, "tesla"))
            return "wonder_weapon";
    }
    
    // Now check regular weapon class
    weapon_class = zm_utility::getweaponclasszm(weapon);
    
    if(!IsDefined(weapon_class))
        return undefined;
    
    switch(weapon_class)
    {
        case "weapon_pistol":
        case "pistol":
            return "pistol";
        case "weapon_assault":
        case "rifle":
            return "rifle";
        case "weapon_lmg":
        case "mg":
            return "lmg";
        case "weapon_cqb":
        case "spread":
        case "shotgun":
            return "shotgun";
        case "weapon_smg":
        case "smg":
            return "smg";
        case "weapon_sniper":
        case "sniper":
            return "sniper";
        case "weapon_launcher":
        case "rocketlauncher":
        case "launcher":
            return "launcher";
        case "weapon_explosive":
        case "grenade":
            return undefined;
    }
    
    return undefined;
}

function get_weapon_class_display_name(weapon_class)
{
    if(!IsDefined(weapon_class))
        return "Unknown";
    
    switch(weapon_class)
    {
        case "pistol":
            return "Pistols";
        case "rifle":
            return "Assault Rifles";
        case "lmg":
            return "Light Machine Guns";
        case "shotgun":
            return "Shotguns";
        case "smg":
            return "Submachine Guns";
        case "sniper":
            return "Sniper Rifles";
        case "launcher":
            return "Launchers";
        case "wonder_weapon":
            return "Wonder Weapons";
        default:
            return "Unknown";
    }
}

function get_weapon_class_id(weapon_class)
{
    if(!IsDefined(weapon_class))
        return 0;
    
    switch(weapon_class)
    {
        case "pistol":
            return 0;
        case "rifle":
            return 1;
        case "lmg":
            return 2;
        case "shotgun":
            return 3;
        case "smg":
            return 4;
        case "sniper":
            return 5;
        case "launcher":
            return 6;
        case "wonder_weapon":
            return 7;
        default:
            return 0;
    }
}

//*****************************************************************************
// ZONE BARRIER FX SYSTEM (Delete and Respawn Pattern)
//*****************************************************************************

function show_zone_barrier_fx(zone_trigger)
{
    if(!IsDefined(zone_trigger) || !IsDefined(zone_trigger.script_int))
    {
        IPrintLnBold("^1[FX ERROR] Zone trigger missing script_int!");
        return;
    }
    
    zone_id = zone_trigger.script_int;
    count = 0;
    
    IPrintLnBold("^2[FX] Spawning barriers for zone " + zone_id);
    
    // Initialize array
    if(!IsDefined(level.tedd_active_zone_fx_models))
        level.tedd_active_zone_fx_models = [];
    
    // Spawn models with FX for this zone ID
    foreach(fx_data in level.tedd_zone_fx_data)
    {
        if(IsDefined(fx_data.script_int) && fx_data.script_int == zone_id)
        {
            // Spawn the model
            fx_model = Spawn("script_model", fx_data.origin);
            fx_model.angles = fx_data.angles;
            fx_model SetModel("tag_origin");
            
            // Attach FX based on script_noteworthy
            if(IsDefined(fx_data.script_noteworthy) && fx_data.script_noteworthy == "marker")
            {
                PlayFXOnTag(level._effect["zone_marker"], fx_model, "tag_origin");
            }
            else
            {
                PlayFXOnTag(level._effect["zone_barrier"], fx_model, "tag_origin");
            }
            
            // Store for cleanup
            level.tedd_active_zone_fx_models[level.tedd_active_zone_fx_models.size] = fx_model;
            count++;
        }
    }
    
    IPrintLnBold("^2Zone barrier activated! (" + count + " FX spawned)");
}

function hide_zone_barrier_fx()
{
    IPrintLnBold("^6[FX] Deleting zone barriers");
    
    // Delete all active FX models
    if(IsDefined(level.tedd_active_zone_fx_models))
    {
        foreach(fx_model in level.tedd_active_zone_fx_models)
        {
            if(IsDefined(fx_model))
            {
                fx_model Delete();
            }
        }
        level.tedd_active_zone_fx_models = [];
    }
}

//*****************************************************************************
// LOGGING
//*****************************************************************************

function log_message(message)
{
    log_string = "[TEDD][" + GetTime() + "] " + message;
    LogPrint(log_string + "\n");
}
