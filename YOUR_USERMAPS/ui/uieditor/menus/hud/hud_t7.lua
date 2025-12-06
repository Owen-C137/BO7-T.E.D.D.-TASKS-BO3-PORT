-- The Giant Hud Base, Rebuilt from the ground up by the D3V Team

require("ui.uieditor.widgets.HUD.ZM_Perks.ZMPerksContainerFactory")
require("ui.uieditor.widgets.HUD.ZM_RoundWidget.ZmRndContainer")
require("ui.uieditor.widgets.HUD.ZM_AmmoWidgetFactory.ZmAmmoContainerFactory")
require("ui.uieditor.widgets.HUD.ZM_Score.ZMScr")
require("ui.uieditor.widgets.DynamicContainerWidget")
require("ui.uieditor.widgets.Notifications.Notification")
require("ui.uieditor.widgets.HUD.ZM_NotifFactory.ZmNotifBGB_ContainerFactory")
require("ui.uieditor.widgets.HUD.ZM_CursorHint.ZMCursorHint")
require("ui.uieditor.widgets.HUD.CenterConsole.CenterConsole")
require("ui.uieditor.widgets.HUD.DeadSpectate.DeadSpectate")
require("ui.uieditor.widgets.MPHudWidgets.ScorePopup.MPScr")
require("ui.uieditor.widgets.HUD.ZM_PrematchCountdown.ZM_PrematchCountdown")
require("ui.uieditor.widgets.Scoreboard.CP.ScoreboardWidgetCP")
require("ui.uieditor.widgets.HUD.ZM_TimeBar.ZM_BeastmodeTimeBarWidget")
require("ui.uieditor.widgets.ZMInventory.RocketShieldBluePrint.RocketShieldBlueprintWidget")
require("ui.uieditor.widgets.Chat.inGame.IngameChatClientContainer")
require("ui.uieditor.widgets.BubbleGumBuffs.BubbleGumPackInGame")
require("ui.uieditor.widgets.HUD.ChallengeWidget.ChallengeProgress")
require("ui.uieditor.widgets.HUD.ChallengeWidget.ChallengeComplete")
require("ui.uieditor.widgets.HUD.ChallengeWidget.ChallengeFailed")
require("ui.uieditor.widgets.HUD.ChallengeWidget.MachineSpawnNotification")

require("ui.utils.CoreUtil")
require("ui.utils.T7FontLoader")

CoD.Zombie.CommonHudRequire()

local PreLoadFunc = function(self, controller)
	FontLoader(self, { "" }) -- Load fonts here; "folder/font"
	CoD.Zombie.CommonPreLoadHud(self, controller)
end	

local PostLoadFunc = function(self, controller)
    CoD.Zombie.CommonPostLoadHud(self, controller)
end

LUI.createMenu.T7Hud_zm_factory = function(controller)
    local self = CoD.Menu.NewForUIEditor("T7Hud_zm_factory")
    
    if PreLoadFunc then
        PreLoadFunc(self, controller)
    end

	if not CoD.ZMPerksFactory then
		CoD.ZMPerksFactory =
		{
			quick_revive = "bl3_qr",
			doubletap2 = "bl3_doubletap",
			juggernaut = "bl3_jug",
			sleight_of_hand = "bl3_speed_cola",
			dead_shot = "bl3_deadshot",
			phdflopper = "bl3_phdflopper",
			marathon = "bl3_marathon",
			additional_primary_weapon = "bl3_3guns",
			electric_cherry = "bl3_electriccherry",
			widows_wine = "bl3_widows",
			tombstone = "bl3_tombstone",
			vultureaid = "bl3_vulture",
			whoswho = "bl3_whoswho",
			dive_to_nuke = "specialty_divetonuke_zombies",
			madgaz_moonshine = "bl3_moonshine",
			banana_colada = "bl3_banana_colada",
			bull_ice_blast = "bl3_bull_ice_blast",
			crusaders_ale = "bl3_crusader_ale",
			bloodwolf = "bl3_luna",
			perception = "bl3_death_perception",
			death_perception = "bl3_death_perception",
			winterwail = "bl3_winters_wail",
			razor = "bl3_razor",
			bandolier = "bl3_bandolier",
			blazephase = "bl3_blaze_phase",
			stronghold = "bl3_stronghold",
			victorious = "bl3_tortoise",
			zombshell = "bl3_zombshell",
			slider = "bl3_phd_slider",
			dyingwish = "bl3_dyingwish",
			timeslip = "bl3_timeslip",
			ffyl = "bl3_fighters_fizz",
			icu = "bl3_icu",
			tactiquilla = "bl3_tac",
			milk = "bl3_milk",
			elemental_pop = "bl3_elemental_pop",
			wind_runner = "bl3_windrunner_whiskey",
			directionalfire = "$blacktransparent",
			salvage_shake = "$blacktransparent",
			atomic_liqueur = "$blacktransparent",
			snails_pace = "$blacktransparent",
			cryo_slide = "$blacktransparent",
			multiplier = "$blacktransparent",
    		brawl = "$blacktransparent",
    		groovybrew = "$blacktransparent"
		}
	end
	
	require("ui.uieditor.widgets.hud.customperksfactory")
    
    self.soundSet = "HUD"
    self:setOwner(controller)
    self:setLeftRight(true, true, 0, 0)
    self:setTopBottom(true, true, 0, 0)
    self:playSound("menu_open", controller)
    self.buttonModel = Engine.CreateModel(Engine.GetModelForController(controller), "T7Hud_zm_factory.buttonPrompts")
    self.anyChildUsesUpdateState = true
    
    self.PerksWidget = CoD.ZMPerksContainerFactory.new(self, controller)
    self.PerksWidget:setLeftRight(true, false, 130, 281)
    self.PerksWidget:setTopBottom(false, true, -62, -26)
    self:addElement(self.PerksWidget)
    self.ZMPerksContainerFactory = self.PerksWidget
    
    self.RoundCounter = CoD.ZmRndContainer.new(self, controller)
    self.RoundCounter:setLeftRight(true, false, -32, 192)
    self.RoundCounter:setTopBottom(false, true, -174, 18)
    self.RoundCounter:setScale(0.8)
    self:addElement(self.RoundCounter)
    self.Rounds = self.RoundCounter
    
    self.AmmoWidget = CoD.ZmAmmoContainerFactory.new(self, controller)
    self.AmmoWidget:setLeftRight(false, true, -427.000000, 3.000000)
    self.AmmoWidget:setTopBottom(false, true, -232.000000, 0.000000)
    self:addElement(self.AmmoWidget)
    self.Ammo = self.AmmoWidget
    
    self.ScoreWidget = CoD.ZMScr.new(self, controller)
    self.ScoreWidget:setLeftRight(true, false, 30.000000, 164.000000)
    self.ScoreWidget:setTopBottom(false, true, -256.000000, -128.000000)
    self.ScoreWidget:setYRot(30.000000)
    self:addElement(self.ScoreWidget)
    self.Score = self.ScoreWidget

    self.Score.StateTable = {
		{
			stateName = "HudStart",
			condition = function(self, ItemRef, UpdateTable)
				local condition = IsModelValueTrue(controller, "hudItems.playerSpawned")
				if condition then
					if Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) and Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_WEAPON_HUD_VISIBLE) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_GAME_ENDED) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_KILLCAM) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_UI_ACTIVE) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_SCOPED) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_VEHICLE) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC) then
						condition = not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_EMP_ACTIVE)
					else
						condition = false
					end
				end
				return condition
			end
		}
	}
	self.Score:mergeStateConditions(self.Score.StateTable)

    SubscribeToModelAndUpdateState(controller, self, self.Score, "hudItems.playerSpawned")

    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_HUD_VISIBLE)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_WEAPON_HUD_VISIBLE)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_HUD_HARDCORE)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_GAME_ENDED)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_IN_KILLCAM)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_UI_ACTIVE)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_IS_SCOPED)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_IN_VEHICLE)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.Score, Enum.UIVisibilityBit.BIT_EMP_ACTIVE)
    
    self.fullscreenContainer = CoD.DynamicContainerWidget.new(self, controller)
	self.fullscreenContainer:setLeftRight(false, false, -640, 640)
	self.fullscreenContainer:setTopBottom(false, false, -360, 360)
	self:addElement(self.fullscreenContainer)
	
	self.Notifications = CoD.Notification.new(self, controller)
	self.Notifications:setLeftRight(true, true, 0, 0)
	self.Notifications:setTopBottom(true, true, 0, 0)
	self:addElement(self.Notifications)
	
	self.ZmNotifBGBContainerFactory = CoD.ZmNotifBGB_ContainerFactory.new(self, controller)
	self.ZmNotifBGBContainerFactory:setLeftRight(false, false, -156, 156)
	self.ZmNotifBGBContainerFactory:setTopBottom(true, false, -6, 247)
	self.ZmNotifBGBContainerFactory:setScale(0.75)
	self:addElement(self.ZmNotifBGBContainerFactory)
	
	self.ZmNotifBGBContainerFactory:subscribeToGlobalModel(controller, "PerController", "scriptNotify", function(ModelRef)
		if IsParamModelEqualToString(ModelRef, "zombie_bgb_token_notification") then
			AddZombieBGBTokenNotification(self, self.ZmNotifBGBContainerFactory, controller, ModelRef)
		elseif IsParamModelEqualToString(ModelRef, "zombie_bgb_notification") then
			AddZombieBGBNotification(self, self.ZmNotifBGBContainerFactory, ModelRef)
		elseif IsParamModelEqualToString(ModelRef, "zombie_notification") then
			AddZombieNotification(self, self.ZmNotifBGBContainerFactory, ModelRef)
		end
	end)
    
    self.CursorHint = CoD.ZMCursorHint.new(self, controller)
	self.CursorHint:setLeftRight(false, false, -250, 250)
	self.CursorHint:setTopBottom(true, false, 522, 616)
	self:addElement(self.CursorHint)
	
	self.CursorHint.StateTable = {
		{
			stateName = "Active_1x1",
			condition = function(self, ItemRef, UpdateTable)
				local condition = IsCursorHintActive(controller)
				if condition then
					if Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) or not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_UI_ACTIVE) or Engine.GetModelValue(Engine.GetModel(DataSources.HUDItems.getModel(controller), "cursorHintIconRatio")) ~= 1 then
						condition = false
					else
						condition = true
					end
				end
				return condition
			end
		},
		{
			stateName = "Active_2x1",
			condition = function(self, ItemRef, UpdateTable)
				local condition = IsCursorHintActive(controller)
				if condition then
					if Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) or not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_UI_ACTIVE) or Engine.GetModelValue(Engine.GetModel(DataSources.HUDItems.getModel(controller), "cursorHintIconRatio")) ~= 2 then
						condition = false
					else
						condition = true
					end
				end
				return condition
			end
		},
		{
			stateName = "Active_4x1",
			condition = function(self, ItemRef, UpdateTable)
				local condition = IsCursorHintActive(controller)
				if condition then
					if Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) or not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT) or Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_UI_ACTIVE) or Engine.GetModelValue(Engine.GetModel(DataSources.HUDItems.getModel(controller), "cursorHintIconRatio")) ~= 4 then
						condition = false
					else
						condition = true
					end
				end
				return condition
			end
		},
		{
			stateName = "Active_NoImage",
			condition = function(self, ItemRef, UpdateTable)
				local condition = IsCursorHintActive(controller)
				if condition then
					if not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) and Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT) and not Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_UI_ACTIVE) then
						condition = IsModelValueEqualTo(controller, "hudItems.cursorHintIconRatio", 0)
					else
						condition = false
					end
				end
				return condition
			end
		}
	}
	self.CursorHint:mergeStateConditions(self.CursorHint.StateTable)

    SubscribeToModelAndUpdateState(controller, self, self.CursorHint, "hudItems.showCursorHint")
    SubscribeToModelAndUpdateState(controller, self, self.CursorHint, "hudItems.cursorHintIconRatio")

    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.CursorHint, Enum.UIVisibilityBit.BIT_HUD_VISIBLE)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.CursorHint, Enum.UIVisibilityBit.BIT_HUD_HARDCORE)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.CursorHint, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.CursorHint, Enum.UIVisibilityBit.BIT_UI_ACTIVE)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.CursorHint, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.CursorHint, Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.CursorHint, Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK)
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.CursorHint, Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING)
    
    self.ConsoleCenter = CoD.CenterConsole.new(self, controller)
	self.ConsoleCenter:setLeftRight(false, false, -370, 370)
	self.ConsoleCenter:setTopBottom(true, false, 68.5, 166.5)
	self:addElement(self.ConsoleCenter)
	
	self.DeadSpectate = CoD.DeadSpectate.new(self, controller)
	self.DeadSpectate:setLeftRight(false, false, -150, 150)
	self.DeadSpectate:setTopBottom(false, true, -180, -120)
	self:addElement(self.DeadSpectate)
	
	self.MPScore = CoD.MPScr.new(self, controller)
	self.MPScore:setLeftRight(false, false, -50, 50)
	self.MPScore:setTopBottom(true, false, 233.5, 258.5)
	self:addElement(self.MPScore)
	
	self.MPScore:subscribeToGlobalModel(controller, "PerController", "scriptNotify", function(ModelRef)
		if IsParamModelEqualToString(ModelRef, "score_event") and PropertyIsTrue(self, "menuLoaded") then
			PlayClipOnElement(self, {
				elementName = "MPScore",
				clipName = "NormalScore"
			}, controller)
			SetMPScoreText(self, self.MPScore, controller, ModelRef)
		end
	end)
    
    self.ZMPrematchCountdown0 = CoD.ZM_PrematchCountdown.new(self, controller)
	self.ZMPrematchCountdown0:setLeftRight(false, false, -640, 640)
	self.ZMPrematchCountdown0:setTopBottom(false, false, -360, 360)
	self:addElement(self.ZMPrematchCountdown0)
	
	self.ScoreboardWidget = CoD.ScoreboardWidgetCP.new(self, controller)
	self.ScoreboardWidget:setLeftRight(false, false, -503, 503)
	self.ScoreboardWidget:setTopBottom(true, false, 247, 773)
	self:addElement(self.ScoreboardWidget)
	
	self.ZMBeastBar = CoD.ZM_BeastmodeTimeBarWidget.new(self, controller)
	self.ZMBeastBar:setLeftRight(false, false, -242.5, 321.5)
	self.ZMBeastBar:setTopBottom(false, true, -174, -18)
	self.ZMBeastBar:setScale(0.7)
	self:addElement(self.ZMBeastBar)
	
	self.RocketShieldBlueprintWidget = CoD.RocketShieldBlueprintWidget.new(self, controller)
	self.RocketShieldBlueprintWidget:setLeftRight(true, false, -36.5, 277.5)
	self.RocketShieldBlueprintWidget:setTopBottom(true, false, 104, 233)
	self.RocketShieldBlueprintWidget:setScale(0.8)
	self:addElement(self.RocketShieldBlueprintWidget)
	
	self.RocketShieldBlueprintWidget.StateTable = {
		{
			stateName = "Scoreboard",
			condition = function(self, ItemRef, UpdateTable)
				local condition = Engine.IsVisibilityBitSet(controller, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN)
				if condition then
					condition = AlwaysFalse()
				end

				return condition
			end
		}
	}
	self.RocketShieldBlueprintWidget:mergeStateConditions(self.RocketShieldBlueprintWidget.StateTable)

    SubscribeToModelAndUpdateState(controller, self, self.CursorHint, "zmInventory.widget_shield_parts")
    SubscribeToVisibilityBitAndUpdateElementState(controller, self, self.CursorHint, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN)

    
    self.IngameChatClientContainer = CoD.IngameChatClientContainer.new(self, controller)
	self.IngameChatClientContainer:setLeftRight(true, false, 0, 360)
	self.IngameChatClientContainer:setTopBottom(true, false, -2.5, 717.5)
	self:addElement(self.IngameChatClientContainer)
	
	self.IngameChatClientContainer0 = CoD.IngameChatClientContainer.new(self, controller)
	self.IngameChatClientContainer0:setLeftRight(true, false, 0, 360)
	self.IngameChatClientContainer0:setTopBottom(true, false, -2.5, 717.5)
	self:addElement(self.IngameChatClientContainer0)
	
	self.BubbleGumPackInGame = CoD.BubbleGumPackInGame.new(self, controller)
	self.BubbleGumPackInGame:setLeftRight(false, false, -184, 184)
	self.BubbleGumPackInGame:setTopBottom(true, false, 36, 185)
	self:addElement(self.BubbleGumPackInGame)
	
	-- Challenge Progress Widget
	self.ChallengeProgress = CoD.ChallengeProgress.new(self, controller)
	self.ChallengeProgress:setLeftRight(true, false, 50, 450)
	self.ChallengeProgress:setTopBottom(true, false, 250, 370)
	self:addElement(self.ChallengeProgress)
	
	-- Challenge Complete Widget
	self.ChallengeComplete = CoD.ChallengeComplete.new(self, controller)
	self.ChallengeComplete:setLeftRight(true, false, 50, 450)
	self.ChallengeComplete:setTopBottom(true, false, 200, 320)
	self:addElement(self.ChallengeComplete)
	
	-- Challenge Failed Widget
	self.ChallengeFailed = CoD.ChallengeFailed.new(self, controller)
	self.ChallengeFailed:setLeftRight(true, false, 50, 450)
	self.ChallengeFailed:setTopBottom(true, false, 200, 320)
	self:addElement(self.ChallengeFailed)
	
	-- Machine Spawn Notification Widget
	self.MachineSpawnNotification = CoD.MachineSpawnNotification.new(self, controller)
	self:addElement(self.MachineSpawnNotification)
	
	self.Score.navigation = {
		up = self.ScoreboardWidget,
		right = self.ScoreboardWidget
	}
	self.ScoreboardWidget.navigation = {
		left = self.Score,
		down = self.Score
	}
	CoD.Menu.AddNavigationHandler(self, self, controller)
    
    self:registerEventHandler("menu_loaded", function(element, Event)
		SizeToSafeArea(element, controller)
		SetProperty(self, "menuLoaded", true)
		return element:dispatchEventToChildren(Event)
	end)

	self.Score.id = "Score"
	self.ScoreboardWidget.id = "ScoreboardWidget"

	self:processEvent({
		name = "menu_loaded",
		controller = controller
	})
	self:processEvent({
		name = "update_state",
		menu = self
	})

	if not self:restoreState() then
		self.ScoreboardWidget:processEvent({
			name = "gain_focus",
			controller = controller
		})
	end
    
    LUI.OverrideFunction_CallOriginalSecond(self, "close", function(element)
		element.ZMPerksContainerFactory:close()
		element.Rounds:close()
		element.Ammo:close()
		element.Score:close()
		element.fullscreenContainer:close()
		element.Notifications:close()
		element.ZmNotifBGBContainerFactory:close()
		element.CursorHint:close()
		element.ConsoleCenter:close()
		element.DeadSpectate:close()
		element.MPScore:close()
		element.ZMPrematchCountdown0:close()
		element.ScoreboardWidget:close()
		element.ZMBeastBar:close()
		element.RocketShieldBlueprintWidget:close()
		element.IngameChatClientContainer:close()
		element.IngameChatClientContainer0:close()
		element.BubbleGumPackInGame:close()
		element.ChallengeProgress:close()
		element.ChallengeComplete:close()
		element.ChallengeFailed:close()
		element.MachineSpawnNotification:close()

		Engine.UnsubscribeAndFreeModel(Engine.GetModel(Engine.GetModelForController(controller), "T7Hud_zm_factory.buttonPrompts"))
	end)

	if PostLoadFunc then
		PostLoadFunc(self, controller)
	end

	return self
end