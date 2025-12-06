-- Challenge Complete Widget - REDESIGNED
-- Shows as overlay on top of ChallengeProgress widget when challenge completes
-- Matches the progress widget style with tier-based colors

CoD.ChallengeComplete = InheritFrom(LUI.UIElement)

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

function CoD.ChallengeComplete.new(menu, controller)
    local self = LUI.UIElement.new()
    
    if PreLoadFunc then
        PreLoadFunc(self, controller)
    end
    
    self:setUseStencil(false)
    self:setClass(CoD.ChallengeComplete)
    self.id = "ChallengeComplete"
    self.soundSet = "default"
    -- Match ChallengeProgress dimensions exactly (overlay on top)
    self:setLeftRight(true, false, 20, 280)
    self:setTopBottom(true, false, 20, 130)
    self:setAlpha(0)
    
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
    self.TierIcon = LUI.UIImage.new()
    self.TierIcon:setLeftRight(true, false, 220, 258)
    self.TierIcon:setTopBottom(true, false, 57, 95)
    self.TierIcon:setImage(RegisterImage("i_mtl_ui_icon_trials_common_loot_container"))
    self.TierIcon:setRGB(1.000, 1.000, 1.000)
    self.TierIcon:setScale(1.00)
    self.TierIcon:setAlpha(1)
    self:addElement(self.TierIcon)
    
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
    
    -- tadd_challenge_check (ON TOP - checkmark icon - COMPLETE)
    self.tadd_challenge_check = LUI.UIImage.new()
    self.tadd_challenge_check:setLeftRight(true, false, 16, 46)
    self.tadd_challenge_check:setTopBottom(true, false, 10, 38)
    self.tadd_challenge_check:setImage(RegisterImage("i_mtl_teddd_task_ui_check"))
    self.tadd_challenge_check:setRGB(1.000, 1.000, 1.000)
    self.tadd_challenge_check:setScale(1.00)
    self.tadd_challenge_check:setAlpha(1)
    self:addElement(self.tadd_challenge_check)
    
    -- Header text ("T.E.D.D. TASK COMPLETE") - smaller font
    self.HeaderTitle = LUI.UIText.new()
    self.HeaderTitle:setLeftRight(true, false, 55, 215)
    self.HeaderTitle:setTopBottom(true, false, 6, 21)
    self.HeaderTitle:setTTF("fonts/default.ttf")
    self.HeaderTitle:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    self.HeaderTitle:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_TOP)
    self.HeaderTitle:setText("T.E.D.D. TASK COMPLETE")
    self.HeaderTitle:setRGB(1, 1, 1)
    self:addElement(self.HeaderTitle)
    
    -- Body description ("YOU COMPLETED [TIER]") - smaller font
    self.TierNameText = LUI.UIText.new()
    self.TierNameText:setLeftRight(true, false, 60, 216)
    self.TierNameText:setTopBottom(true, false, 25, 40)
    self.TierNameText:setTTF("fonts/default.ttf")
    self.TierNameText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    self.TierNameText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_TOP)
    self.TierNameText:setText("YOU COMPLETED COMMON")
    self.TierNameText:setRGB(1, 1, 1)
    self:addElement(self.TierNameText)
    
    -- Claim rewards message - smaller font
    self.RewardText = LUI.UIText.new()
    self.RewardText:setLeftRight(true, false, 60, 216)
    self.RewardText:setTopBottom(true, false, 44, 59)
    self.RewardText:setTTF("fonts/default.ttf")
    self.RewardText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    self.RewardText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_TOP)
    self.RewardText:setText("CLAIM YOUR REWARDS")
    self.RewardText:setRGB(1, 0.9, 0.3)
    self:addElement(self.RewardText)
    
    -- Get model references (CSC creates these, Lua just gets them)
    local controllerModel = Engine.GetModelForController(controller)
    
    -- Helper function to update tier visuals
    local function updateTierVisuals()
        local tierModel = Engine.GetModel(controllerModel, "tedd_challenge_tier")
        local tier = Engine.GetModelValue(tierModel) or 0
        local tierName = TierNames[tier] or "COMMON"
        local tierBodyImage = TierBodyImages[tier] or TierBodyImages[0]
        local tierContainerImage = TierContainerImages[tier] or TierContainerImages[0]
        
        -- Update body background image to match tier
        self.tedd_challenge_body:setImage(RegisterImage(tierBodyImage))
        
        -- Update loot container icon to match tier
        self.TierIcon:setImage(RegisterImage(tierContainerImage))
        
        -- Update tier name text
        self.TierNameText:setText("YOU COMPLETED " .. tierName)
    end
    
    -- Subscribe to tier changes (updates visuals when tier is set)
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_tier"), function(modelRef)
        -- Only update visuals if widget is visible (completed)
        local completedModel = Engine.GetModel(controllerModel, "tedd_challenge_completed")
        if completedModel and Engine.GetModelValue(completedModel) == 1 then
            updateTierVisuals()
        end
    end)
    
    -- Subscribe to challenge_completed to show/hide with animation
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_completed"), function(modelRef)
        local completed = Engine.GetModelValue(modelRef)
        if completed == 1 then
            -- Update visuals based on current tier
            updateTierVisuals()
            
            -- Animate in (fade + scale)
            self:setAlpha(0)
            self:setScale(0.8, 0.8)
            self:beginAnimation("complete_entrance", 300, false, false, CoD.TweenType.Elastic)
            self:setAlpha(1)
            self:setScale(1.0, 1.0)
            
            -- NO AUTO-HIDE - stays visible until player claims reward (GSC will clear clientfield)
        else
            -- Immediately hide
            self:setAlpha(0)
        end
    end)
    
    if PostLoadFunc then
        PostLoadFunc(self, controller, menu)
    end
    
    return self
end

return CoD.ChallengeComplete
