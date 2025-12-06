EnableGlobals()

function SetKeybindTextAndScale(controller, self, keybind)
    local keybindString = SplitKeybindString(controller, Engine.GetKeyBindingLocalizedString(controller, keybind, 0), "OR")

    if keybindString == "UNBOUND" then
        if keybind == "+sprint" then
            keybind = "+breath_sprint"
            keybindString = SplitKeybindString(controller, Engine.GetKeyBindingLocalizedString(controller, keybind, 0), "OR")
        end
    end

    if Engine.LastInput_Gamepad(controller) then
        self.CKBB.bind:setScale(1)
        self.CKBB.bindbg:setAlpha(0)
    else
        self.CKBB.bind:setScale(1)
        self.CKBB.bindbg:setAlpha(1)
    end

    self.CKBB.bind:setText(keybindString)
    ScaleKeybind(self, keybindString, -120)
end

function ScaleKeybind(self, Text, Amount)
    local stringLength = string.len(Text)

    if stringLength > 5 then
        Amount = -60 + (30 * (stringLength - 5))
    end

    ScaleWidgetToLabelCentered(self, self.CKBB.keybind, Amount)
end

function SplitKeybindString(controller, stringToSplit, splitKeyword)
    if Engine.LastInput_Gamepad(controller) then
        return stringToSplit
    end

    stringToSplit = stringToSplit:lower()
    splitKeyword = splitKeyword:lower()
    local splitString = LUI.splitString(stringToSplit, splitKeyword)[1]

    if splitString then
        return Engine.ToUpper(splitString)
    end

    return Engine.ToUpper(stringToSplit)
end

function SubscribeToVisibilityBitAndUpdateElementState(controller, menu, self, VisiblityBitEnum)
	self:subscribeToModel(Engine.GetModel(Engine.GetModelForController(controller), "UIVisibilityBit." .. VisiblityBitEnum), function(ModelRef)
		menu:updateElementState(self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue(ModelRef),
			modelName = "UIVisibilityBit." .. VisiblityBitEnum
		})
	end)
end

function SubscribeToModelAndUpdateState(controller, menu, self, ModelName)
	self:subscribeToModel(Engine.GetModel(Engine.GetModelForController(controller), ModelName), function(ModelRef)
		menu:updateElementState(self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue(ModelRef),
			modelName = ModelName
		})
	end)
end

function LinkToElementModelAndUpdateState(menu, self, ElementModelName, NeedsSubscription)
	self:linkToElementModel(self, ElementModelName, NeedsSubscription, function(ModelRef)
		menu:updateElementState(self, {
			name = "model_validation",
			menu = menu,
			modelValue = Engine.GetModelValue(ModelRef),
			modelName = ElementModelName
		})
	end)
end

function SubscribeToModelByName(self, controller, ModelName, Callback)
	self:subscribeToModel(Engine.GetModel(Engine.GetModelForController(controller), ModelName), Callback)
end

function ShouldHide(controller)
	local shouldHide = IsModelValueTrue(controller, "hudItems.playerSpawned")

	if shouldHide then
		if Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_VISIBLE)
		and Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_WEAPON_HUD_VISIBLE) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_GAME_ENDED) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_KILLCAM) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_SCOPED) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_VEHICLE) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) 
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_UI_ACTIVE)
		and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC) then
			shouldHide = false
		else
			shouldHide = true
		end
	end

	return shouldHide
	
end

function IPrintlnBold(Message)
	Engine.ComError(Enum.errorCode.ERROR_UI, Message)
end

DisableGlobals()