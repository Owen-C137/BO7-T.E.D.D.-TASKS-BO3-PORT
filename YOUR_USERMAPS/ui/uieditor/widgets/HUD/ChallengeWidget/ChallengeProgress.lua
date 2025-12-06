-- T.E.D.D. Tasks Widget - Tier System
CoD.ChallengeProgress = InheritFrom(LUI.UIElement)

-- Tier color definitions (RGB values) - Phase 1: 3 Tiers
local TierColors = {
    [0] = {0.0, 0.4, 1.0},  -- Rare: Blue
    [1] = {0.6, 0.2, 1.0},  -- Epic: Purple
    [2] = {1.0, 0.7, 0.0},  -- Legendary: Gold
    [3] = {1.0, 0.1, 0.1}   -- Ultra: Red (reserved)
}

-- Tier names
local TierNames = {
    [0] = "RARE",
    [1] = "EPIC",
    [2] = "LEGENDARY",
    [3] = "ULTRA"
}

-- Tier body background images
local TierBodyImages = {
    [0] = "i_mtl_tedd_task_rare_ui_body",
    [1] = "i_mtl_tedd_task_epic_ui_body",
    [2] = "i_mtl_tedd_task_legendary_ui_body",
    [3] = "i_mtl_tedd_task_ultra_ui_body"
}

-- Tier loot container images
local TierContainerImages = {
    [0] = "i_mtl_ui_icon_trials_rare_loot_container",
    [1] = "i_mtl_ui_icon_trials_epic_loot_container",
    [2] = "i_mtl_ui_icon_trials_legendary_loot_container",
    [3] = "i_mtl_ui_icon_trials_ultra_loot_container"
}

CoD.ChallengeProgress.new = function(menu, controller)
    local self = LUI.UIElement.new()

    if PreLoadFunc then
        PreLoadFunc(self, controller)
    end

    self:setUseStencil(false)
    self:setClass(CoD.ChallengeProgress)
    self.id = "ChallengeProgress"
    self.soundSet = "default"
    self:setLeftRight(true, false, 20, 280)
    self:setTopBottom(true, false, 20, 130)
    
    -- tedd_challenge_header (BEHIND - added first)
    self.tedd_challenge_header = LUI.UIImage.new()
    self.tedd_challenge_header:setLeftRight(true, false, 32, 260)
    self.tedd_challenge_header:setTopBottom(true, false, 4, 26)
    self.tedd_challenge_header:setImage(RegisterImage("i_mtl_teddd_task_ui_header"))
    self.tedd_challenge_header:setRGB(1.000, 1.000, 1.000)
    self.tedd_challenge_header:setScale(1.00)
    self.tedd_challenge_header:setAlpha(1)
    self:addElement(self.tedd_challenge_header)
    
    -- tedd_challenge_body (BEHIND - tier-colored body, will change image based on tier)
    self.tedd_challenge_body = LUI.UIImage.new()
    self.tedd_challenge_body:setLeftRight(true, false, 30, 260)
    self.tedd_challenge_body:setTopBottom(true, false, 24, 95)
    self.tedd_challenge_body:setImage(RegisterImage("i_mtl_tedd_task_common_ui_body"))
    self.tedd_challenge_body:setRGB(1.000, 1.000, 1.000)
    self.tedd_challenge_body:setScale(1.00)
    self.tedd_challenge_body:setAlpha(1)
    self:addElement(self.tedd_challenge_body)
    
    -- Loot container icon (tier-colored, bottom right)
    self.Image6 = LUI.UIImage.new()
    self.Image6:setLeftRight(true, false, 220, 258)
    self.Image6:setTopBottom(true, false, 57, 95)
    self.Image6:setImage(RegisterImage("i_mtl_ui_icon_trials_common_loot_container"))
    self.Image6:setRGB(1.000, 1.000, 1.000)
    self.Image6:setScale(1.00)
    self.Image6:setAlpha(1)
    self:addElement(self.Image6)
    
    -- tedd_challenge_circle (ON TOP - background circle)
    self.tedd_challenge_circle = LUI.UIImage.new()
    self.tedd_challenge_circle:setLeftRight(true, false, 8, 54)
    self.tedd_challenge_circle:setTopBottom(true, false, 1, 47)
    self.tedd_challenge_circle:setImage(RegisterImage("i_mtl_teddd_task_ui_circle"))
    self.tedd_challenge_circle:setRGB(1.000, 1.000, 1.000)
    self.tedd_challenge_circle:setScale(1.00)
    self.tedd_challenge_circle:setAlpha(1)
    self:addElement(self.tedd_challenge_circle)
    
    -- tedd_challenge_boarder (ON TOP)
    self.tedd_challenge_boarder = LUI.UIImage.new()
    self.tedd_challenge_boarder:setLeftRight(true, false, 11, 51)
    self.tedd_challenge_boarder:setTopBottom(true, false, 5, 42)
    self.tedd_challenge_boarder:setImage(RegisterImage("i_mtl_teddd_task_ui_boarder"))
    self.tedd_challenge_boarder:setRGB(1.000, 1.000, 1.000)
    self.tedd_challenge_boarder:setScale(1.00)
    self.tedd_challenge_boarder:setAlpha(1)
    self:addElement(self.tedd_challenge_boarder)
    
    -- tadd_challenge_ex (ON TOP - exclamation mark icon)
    self.tadd_challenge_ex = LUI.UIImage.new()
    self.tadd_challenge_ex:setLeftRight(true, false, 16, 46)
    self.tadd_challenge_ex:setTopBottom(true, false, 10, 38)
    self.tadd_challenge_ex:setImage(RegisterImage("i_mtl_teddd_task_ui_ex"))
    self.tadd_challenge_ex:setRGB(1.000, 1.000, 1.000)
    self.tadd_challenge_ex:setScale(1.00)
    self.tadd_challenge_ex:setAlpha(1)
    self:addElement(self.tadd_challenge_ex)
    
    -- Header text ("T.E.D.D. TASKS") - smaller font
    self.HeaderTitle = LUI.UIText.new()
    self.HeaderTitle:setLeftRight(true, false, 55, 170)
    self.HeaderTitle:setTopBottom(true, false, 6, 24)
    self.HeaderTitle:setTTF("fonts/default.ttf")
    self.HeaderTitle:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    self.HeaderTitle:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_TOP)
    self.HeaderTitle:setText("T.E.D.D. TASKS")
    self.HeaderTitle:setRGB(1, 1, 1)
    self:addElement(self.HeaderTitle)
    
    -- Challenge Description (challenge type) - smaller font
    self.DescText = LUI.UIText.new()
    self.DescText:setLeftRight(true, false, 49, 256)
    self.DescText:setTopBottom(true, false, 29, 56)
    self.DescText:setTTF("fonts/default.ttf")
    self.DescText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    self.DescText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_TOP)
    self.DescText:setText("")
    self.DescText:setRGB(1, 1, 1)
    self:addElement(self.DescText)
    
    -- Time label text - smaller font
    self.TimeLabel = LUI.UIText.new()
    self.TimeLabel:setLeftRight(true, false, 49, 78)
    self.TimeLabel:setTopBottom(true, false, 59, 73)
    self.TimeLabel:setTTF("fonts/default.ttf")
    self.TimeLabel:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    self.TimeLabel:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_TOP)
    self.TimeLabel:setText("TIME:")
    self.TimeLabel:setRGB(1, 1, 1)
    self:addElement(self.TimeLabel)
    
    -- Countdown timer text - smaller font
    self.TimerText = LUI.UIText.new()
    self.TimerText:setLeftRight(true, false, 195, 218)
    self.TimerText:setTopBottom(true, false, 59, 73)
    self.TimerText:setTTF("fonts/default.ttf")
    self.TimerText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_RIGHT)
    self.TimerText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_TOP)
    self.TimerText:setText("")
    self.TimerText:setRGB(1, 1, 1)
    self:addElement(self.TimerText)
    
    -- Progress bar fill - solid color (added FIRST so it's behind the background)
    self.BarFill = LUI.UIImage.new()
    self.BarFill:setLeftRight(true, false, 48, 48)
    self.BarFill:setTopBottom(true, false, 74, 92)
    self.BarFill:setRGB(0.5, 0.5, 0.5)
    self.BarFill:setAlpha(1)
    self:addElement(self.BarFill)
    
    -- Progress bar background - using image (added SECOND so it's on top)
    self.BarBackground = LUI.UIImage.new()
    self.BarBackground:setLeftRight(true, false, 48, 218)
    self.BarBackground:setTopBottom(true, false, 74, 92)
    self.BarBackground:setImage(RegisterImage("i_mtl_tedd_tasks_progressbar_outer"))
    self.BarBackground:setRGB(1.000, 1.000, 1.000)
    self.BarBackground:setAlpha(1)
    self:addElement(self.BarBackground)
    
    -- Kill counter text (hidden, using progress bar visual only)
    self.KillText = LUI.UIText.new()
    self.KillText:setLeftRight(true, false, 49, 110)
    self.KillText:setTopBottom(true, false, 76, 90)
    self.KillText:setTTF("fonts/default.ttf")
    self.KillText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    self.KillText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_MIDDLE)
    self.KillText:setText("0 / 10")
    self.KillText:setRGB(1, 1, 1)
    self.KillText:setAlpha(0)
    self:addElement(self.KillText)
    
    -- Get UI models that CSC creates (CSC uses fieldname as model path)
    local controllerModel = Engine.GetModelForController(controller)
    
    -- Subscribe to challenge_active (subscribeToModel handles nil gracefully)
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_active"), function(model)
        local active = Engine.GetModelValue(model) or 0
        
        if active == 1 then
            self:setAlpha(1)
            -- For horde challenge, show timer-based progress (no kill counter)
            self.BarFill:setLeftRight(true, false, 48, 48) -- Reset progress bar
        else
            self:setAlpha(0)
        end
    end)
    
    -- Subscribe to challenge_completed
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_completed"), function(model)
        local completed = Engine.GetModelValue(model)
        if completed and completed == 1 then
            self:setAlpha(0)
        end
    end)
    
    -- Helper function to update description text based on tier and challenge type
    local function updateChallengeDescription()
        local tierModel = Engine.GetModel(controllerModel, "tedd_challenge_tier")
        local challengeTypeModel = Engine.GetModel(controllerModel, "tedd_challenge_type")
        
        local tier = Engine.GetModelValue(tierModel) or 0
        local challengeType = Engine.GetModelValue(challengeTypeModel) or 0
        local tierName = TierNames[tier] or "RARE"
        
        if challengeType == 0 then
            -- Horde challenge - show tier in description
            self.DescText:setText("^3SURVIVE THE " .. tierName .. " HORDE")
            self.KillText:setAlpha(0) -- Hide kill counter for horde
        elseif challengeType == 1 then
            -- Kills challenge - no tier in description
            self.DescText:setText("^3ELIMINATE ZOMBIES")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 2 then
            -- Headshots challenge - no tier in description
            self.DescText:setText("^3GET HEADSHOTS")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 3 then
            -- Melee challenge - no tier in description
            self.DescText:setText("^3MELEE KILLS")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 4 then
            -- Kill in Location challenge - no tier in description
            self.DescText:setText("^3KILL ZOMBIES IN ZONE")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 5 then
            -- Survive in Location challenge - no tier in description
            self.DescText:setText("^3SURVIVE IN ZONE")
            self.KillText:setAlpha(1) -- Show time counter (reuses kill counter UI)
        elseif challengeType == 6 then
            -- Kill Elevation High challenge - no tier in description
            self.DescText:setText("^3KILL FROM ABOVE")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 7 then
            -- Kill Elevation Low challenge - no tier in description
            self.DescText:setText("^3KILL FROM BELOW")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 8 then
            -- Standing Still challenge
            self.DescText:setText("^3KILL WHILE STILL")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 9 then
            -- Crouching challenge
            self.DescText:setText("^3KILL WHILE CROUCHED")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 10 then
            -- Sliding challenge
            self.DescText:setText("^3KILL WHILE SLIDING")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 11 then
            -- Jumping challenge
            self.DescText:setText("^3KILL WHILE AIRBORNE")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 12 then
            -- Trap Kills challenge
            self.DescText:setText("^3GET TRAP KILLS")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 13 then
            -- Weapon Class challenge - get weapon class name from uimodel
            local weaponClassIdModel = Engine.GetModel(controllerModel, "tedd_challenge_weapon_class_id")
            local weaponClassId = 0
            if weaponClassIdModel then
                weaponClassId = Engine.GetModelValue(weaponClassIdModel) or 0
            end
            
            local weaponClassNames = {
                [0] = "PISTOL",
                [1] = "ASSAULT RIFLE",
                [2] = "LMG",
                [3] = "SHOTGUN",
                [4] = "SMG",
                [5] = "SNIPER",
                [6] = "LAUNCHER",
                [7] = "WONDER WEAPON"
            }
            
            local weaponClassName = weaponClassNames[weaponClassId] or "WEAPON"
            self.DescText:setText("^3GET " .. weaponClassName .. " KILLS")
            self.KillText:setAlpha(1) -- Show kill counter
        elseif challengeType == 14 then
            -- Equipment Kills challenge
            self.DescText:setText("^3GET EQUIPMENT KILLS")
            self.KillText:setAlpha(1) -- Show kill counter
        else
            self.DescText:setText("^3" .. tierName .. " CHALLENGE")
            self.KillText:setAlpha(0)
        end
    end
    
    -- Subscribe to challenge_tier
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_tier"), function(model)
        local tier = Engine.GetModelValue(model) or 0
        local tierColor = TierColors[tier] or TierColors[0]
        local tierBodyImage = TierBodyImages[tier] or TierBodyImages[0]
        local tierContainerImage = TierContainerImages[tier] or TierContainerImages[0]
        
        -- Update body background image to match tier
        self.tedd_challenge_body:setImage(RegisterImage(tierBodyImage))
        
        -- Update progress bar color to match tier
        self.BarFill:setRGB(tierColor[1], tierColor[2], tierColor[3])
        
        -- Update loot container icon to match tier
        self.Image6:setImage(RegisterImage(tierContainerImage))
        
        -- Update description text
        updateChallengeDescription()
    end)
    
    -- Subscribe to challenge_type (so description updates when challenge type changes)
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_type"), function(model)
        -- Update description text
        updateChallengeDescription()
    end)
    
    -- Subscribe to weapon_class_id (for weapon_class challenge description)
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_weapon_class_id"), function(model)
        -- Update description text (weapon class name changes)
        updateChallengeDescription()
    end)
    
    -- Subscribe to challenge_timer
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_timer"), function(model)
        local timeRemaining = Engine.GetModelValue(model) or 0
        local minutes = math.floor(timeRemaining / 60)
        local seconds = timeRemaining % 60
        self.TimerText:setText(string.format("%d:%02d", minutes, seconds))
        
        -- Timer is displayed for ALL challenges, but progress bar only uses timer for horde
        local challengeTypeModel = Engine.GetModel(controllerModel, "tedd_challenge_type")
        local challengeType = Engine.GetModelValue(challengeTypeModel) or 0
        
        if challengeType == 0 then
            -- Horde challenge - use timer for progress bar
            local tierModel = Engine.GetModel(controllerModel, "tedd_challenge_tier")
            local tier = Engine.GetModelValue(tierModel) or 0
            local maxTimes = {[0] = 60, [1] = 90, [2] = 120, [3] = 180}  -- Rare, Epic, Legendary, Ultra (horde times)
            local maxTime = maxTimes[tier] or 60
            
            local progress = timeRemaining / maxTime
            local barWidth = progress * 170  -- Width from 48 to 218 = 170 pixels
            self.BarFill:setLeftRight(true, false, 48, 48 + barWidth)
        end
        -- For progressive challenges (type 1-3), progress bar is controlled by kills subscription
    end)
    
    -- Subscribe to kills_current for progressive tier challenges
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_kills_current"), function(model)
        local killsCurrent = Engine.GetModelValue(model) or 0
        
        -- Update kill counter text
        local killsRequiredModel = Engine.GetModel(controllerModel, "tedd_challenge_kills_required")
        local killsRequired = Engine.GetModelValue(killsRequiredModel) or 0
        self.KillText:setText(killsCurrent .. " / " .. killsRequired)
        
        -- Update progress bar based on kills for progressive challenges
        local challengeTypeModel = Engine.GetModel(controllerModel, "tedd_challenge_type")
        local challengeType = Engine.GetModelValue(challengeTypeModel) or 0
        
        if challengeType > 0 then
            -- Progressive tier challenge (kills, headshots, melee)
            if killsRequired > 0 then
                local progress = math.min(killsCurrent / killsRequired, 1.0)  -- Clamp to 100%
                local barWidth = progress * 170  -- Width from 48 to 218 = 170 pixels
                self.BarFill:setLeftRight(true, false, 48, 48 + barWidth)
            else
                -- If killsRequired is 0, reset to empty
                self.BarFill:setLeftRight(true, false, 48, 48)
            end
        end
    end)
    
    -- Subscribe to kills_required for progressive tier challenges
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_kills_required"), function(model)
        local killsRequired = Engine.GetModelValue(model) or 0
        
        -- Update kill counter text
        local killsCurrentModel = Engine.GetModel(controllerModel, "tedd_challenge_kills_current")
        local killsCurrent = Engine.GetModelValue(killsCurrentModel) or 0
        self.KillText:setText(killsCurrent .. " / " .. killsRequired)
        
        -- Update progress bar when required changes (tier progression)
        local challengeTypeModel = Engine.GetModel(controllerModel, "tedd_challenge_type")
        local challengeType = Engine.GetModelValue(challengeTypeModel) or 0
        
        if challengeType > 0 and killsRequired > 0 then
            local progress = math.min(killsCurrent / killsRequired, 1.0)
            local barWidth = progress * 170
            self.BarFill:setLeftRight(true, false, 48, 48 + barWidth)
        end
    end)
    
    -- Start hidden until challenge activates (set at end after all elements initialized)
    self:setAlpha(0)
    
    if PostLoadFunc then
        PostLoadFunc(self, controller)
    end

    return self
end

return CoD.ChallengeProgress
