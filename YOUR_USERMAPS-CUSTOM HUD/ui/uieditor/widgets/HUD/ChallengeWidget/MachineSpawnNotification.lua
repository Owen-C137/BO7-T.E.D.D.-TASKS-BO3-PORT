-- T.E.D.D. Machine Spawn Notification Widget
-- Shows when a challenge machine spawns in the map
CoD.MachineSpawnNotification = InheritFrom(LUI.UIElement)

local PostLoadFunc = function(self, controller)
    -- Get UI model for machine spawn notification
    local controllerModel = Engine.GetModelForController(controller)
    
    -- Subscribe to spawn active changes
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_machine_spawn_active"), function(model)
        local active = Engine.GetModelValue(model) or 0
        DebugPrint("[MachineSpawnNotification] Active changed to: " .. tostring(active))
        
        if active == 1 then
            -- Show notification
            DebugPrint("[MachineSpawnNotification] Showing notification (setAlpha 1)")
            self:setAlpha(1)
            
            -- Auto-hide after 7 seconds
            self:registerEventHandler("transition_complete_hide", function(element, event)
                DebugPrint("[MachineSpawnNotification] Auto-hide (setAlpha 0)")
                self:setAlpha(0)
            end)
            
            -- Start hide timer
            self:beginAnimation("hide", 7000, false, false)
            self:setAlpha(0)
        else
            DebugPrint("[MachineSpawnNotification] Hiding notification (setAlpha 0)")
            self:setAlpha(0)
        end
    end)
    
    -- Subscribe to location changes
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_machine_spawn_location"), function(model)
        local locationIndex = Engine.GetModelValue(model) or 0
        DebugPrint("[MachineSpawnNotification] Location changed to: " .. tostring(locationIndex))
        
        -- Location names based on script_structs in map
        local locationNames = {
            [0] = "^2SPAWN ROOM",
            [1] = "^2COURTYARD",
            [2] = "^2POWER ROOM",
            [3] = "^2LABORATORY",
            [4] = "^2ARMORY",
            [5] = "^2UNKNOWN LOCATION"
        }
        
        local locationName = locationNames[locationIndex] or "^2UNKNOWN LOCATION"
        self.LocationText:setText(locationName)
        DebugPrint("[MachineSpawnNotification] Location text set to: " .. locationName)
    end)
    
    DebugPrint("[MachineSpawnNotification] PostLoadFunc completed - subscriptions registered")
end

CoD.MachineSpawnNotification.new = function(menu, controller)
    local self = LUI.UIElement.new()
    
    if PreLoadFunc then
        PreLoadFunc(self, controller)
    end
    
    self:setUseStencil(false)
    self:setClass(CoD.MachineSpawnNotification)
    self.id = "MachineSpawnNotification"
    self.soundSet = "default"
    
    -- Full screen positioning for absolute coordinates
    self:setLeftRight(true, false, 0, 1280)
    self:setTopBottom(true, false, 0, 720)
    
    -- Background image (added FIRST = bottom layer)
    self.Background = LUI.UIImage.new()
    self.Background:setLeftRight(true, false, 442.666666666667, 836.666666666667)
    self.Background:setTopBottom(true, false, 208.666666666667, 261.333333333333)
    self.Background:setImage(RegisterImage("i_mtl_tedd_initial_spawn_background"))
    self.Background:setAlpha(1)
    self:addElement(self.Background)
    
    -- Border image (added SECOND = middle layer)
    self.Border = LUI.UIImage.new()
    self.Border:setLeftRight(true, false, 478.666666666667, 799.333333333333)
    self.Border:setTopBottom(true, false, 205.333333333333, 264.666666666667)
    self.Border:setImage(RegisterImage("i_mtl_tedd_initial_spawn_border"))
    self.Border:setAlpha(1)
    self:addElement(self.Border)
    
    -- Title text area (image placeholder to control render order)
    self.TitleTextArea = LUI.UIImage.new()
    self.TitleTextArea:setLeftRight(true, false, 505.333333333333, 774.666666666667)
    self.TitleTextArea:setTopBottom(true, false, 228, 242.666666666667)
    self.TitleTextArea:setImage(RegisterImage(""))
    self.TitleTextArea:setAlpha(0)
    self:addElement(self.TitleTextArea)
    
    -- TEDD Icon (added AFTER background/border but BEFORE text = renders on top of bg/border)
    self.TeddIcon = LUI.UIImage.new()
    self.TeddIcon:setLeftRight(true, false, 563.333333333333, 714.666666666667)
    self.TeddIcon:setTopBottom(true, false, 82, 235.333333333333)
    self.TeddIcon:setImage(RegisterImage("i_mtl_tedd_initial_spawn"))
    self.TeddIcon:setAlpha(1)
    self:addElement(self.TeddIcon)
    
    -- Title text (actual text element added last)
    self.TitleText = LUI.UIText.new()
    self.TitleText:setLeftRight(true, false, 505.333333333333, 774.666666666667)
    self.TitleText:setTopBottom(true, false, 228, 242.666666666667)
    self.TitleText:setText("^3A T.E.D.D. TASK HAS APPEARED")
    self.TitleText:setTTF("fonts/default.ttf")
    self.TitleText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_CENTER)
    self.TitleText:setRGB(1, 0.8, 0)
    self:addElement(self.TitleText)
    
    -- Location text (will be set dynamically)
    self.LocationText = LUI.UIText.new()
    self.LocationText:setLeftRight(true, false, 505.333333333333, 774.666666666667)
    self.LocationText:setTopBottom(true, false, 245, 260)
    self.LocationText:setText("^2UNKNOWN")  -- Default, will be updated
    self.LocationText:setTTF("fonts/default.ttf")
    self.LocationText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_CENTER)
    self.LocationText:setRGB(0.5, 1, 0.5)
    self:addElement(self.LocationText)
    
    -- Start hidden
    self:setAlpha(0)
    
    if PostLoadFunc then
        PostLoadFunc(self, controller)
    end
    
    return self
end

return CoD.MachineSpawnNotification
