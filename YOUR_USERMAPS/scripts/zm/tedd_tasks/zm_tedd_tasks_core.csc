// ====================================================================
// TEDD Tasks System - Client Side
// Handles clientfield callbacks for UI updates
// ====================================================================

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\shared\duplicaterender.gsh;

#namespace zm_tedd_tasks_core;

REGISTER_SYSTEM_EX("zm_tedd_tasks_core", &__init__, &__main__, undefined)

function __init__()
{
    IPrintLnBold("^1[CSC] TEDD Tasks Core __init__() called!");
    
    // HUD elements (clientuimodel - limited bits, persistent UI only)
    clientfield::register("clientuimodel", "tedd_challenge_active", VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_challenge_timer", VERSION_SHIP, 8, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_challenge_tier", VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_challenge_completed", VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_challenge_failed", VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_challenge_reward", VERSION_SHIP, 13, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_challenge_type", VERSION_SHIP, 4, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_challenge_weapon_class_id", VERSION_SHIP, 3, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_challenge_kills_current", VERSION_SHIP, 10, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_challenge_kills_required", VERSION_SHIP, 10, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_machine_spawn_active", VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    clientfield::register("clientuimodel", "tedd_machine_spawn_location", VERSION_SHIP, 3, "int", undefined, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    // Total: 53 bits (within budget)
    
    // Horde zombie red eyes (actor topology uses different flags)
    clientfield::register("actor", "horde_zombie_eyes", VERSION_SHIP, 1, "int", &horde_zombie_eyes_callback, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);
    
    // Reward model glow effect (using FX like powerups)
    clientfield::register("scriptmover", "reward_glow", VERSION_SHIP, 1, "int", &reward_glow_callback, 0, 0);
    
    // Reward model outline effect (using duplicate_render)
    clientfield::register("scriptmover", "reward_outline", VERSION_SHIP, 1, "int", &reward_outline_callback, 0, 0);
    
    // Reward shared state (changes FX color)
    clientfield::register("scriptmover", "reward_shared", VERSION_SHIP, 1, "int", &reward_shared_callback, 0, 0);
    
    // Register outline filter for rewards (white outline)
    duplicate_render::set_dr_filter_offscreen("reward_outline", 20, "reward_outline_active", undefined, DR_TYPE_OFFSCREEN, "mc/hud_outline_model_z_white", DR_CULL_NEVER);
    
    // Load the custom HUD
    LuiLoad("ui.uieditor.menus.HUD.hud_t7");
}

function __main__()
{
    // Client initialization (clientuimodel and toplayer auto-create models, no callbacks needed)
    IPrintLnBold("^1[CSC] TEDD Tasks Core __main__() called!");
    
    // Precache red eye FX
    level._effect["horde_eye_glow_red"] = "zombie/fx_glow_eye_red";
    
    // Precache reward glow FX (use powerup effect)
    level._effect["reward_glow"] = "zombie/fx_powerup_on_solo_zmb";
    level._effect["reward_glow_shared"] = "zombie/fx_powerup_on_green_zmb";
    
    // Wait a frame then force precache
    wait(0.05);
    if(IsDefined(level._effect["horde_eye_glow_red"]))
    {
        // Force the FX to be loaded by the engine
        // This ensures it's available when horde zombies spawn
    }
}

// Horde zombie red eyes callback
function horde_zombie_eyes_callback(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
    if(newVal == 1)
    {
        // Set red eye FX override for this zombie
        self._eyeglow_fx_override = level._effect["horde_eye_glow_red"];
    }
}

// Reward model glow FX callback
function reward_glow_callback(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(newval == 1)
    {
        // Play glow FX on reward model
        self util::waittill_dobj(localclientnum);
        if(!IsDefined(self))
        {
            return;
        }
        
        if(IsDefined(self.reward_fx))
        {
            StopFX(localclientnum, self.reward_fx);
        }
        
        self.reward_fx = PlayFXOnTag(localclientnum, level._effect["reward_glow"], self, "tag_origin");
    }
    else
    {
        // Stop glow FX
        if(IsDefined(self.reward_fx))
        {
            StopFX(localclientnum, self.reward_fx);
            self.reward_fx = undefined;
        }
    }
}

// Reward model outline callback (duplicate_render system)
function reward_outline_callback(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(newval == 1)
    {
        // Enable outline using duplicate_render flag
        self duplicate_render::update_dr_flag(localclientnum, "reward_outline_active", 1);
    }
    else
    {
        // Disable outline
        self duplicate_render::update_dr_flag(localclientnum, "reward_outline_active", 0);
    }
}

// Reward shared state callback (changes FX color)
function reward_shared_callback(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump)
{
    if(newval == 1)
    {
        // Switch to green FX (shared state)
        if(IsDefined(self.reward_fx))
        {
            StopFX(localclientnum, self.reward_fx);
        }
        self.reward_fx = PlayFXOnTag(localclientnum, level._effect["reward_glow_shared"], self, "tag_origin");
    }
    else
    {
        // Switch back to orange FX (owner-only state)
        if(IsDefined(self.reward_fx))
        {
            StopFX(localclientnum, self.reward_fx);
        }
        self.reward_fx = PlayFXOnTag(localclientnum, level._effect["reward_glow"], self, "tag_origin");
    }
}
