require("ui.uieditor.widgets.HUD.ChallengeWidget.ChallengeProgress")

CoD.Zombie.CommonHudRequire()

local PreLoadFunc = function(self, controller)
    CoD.Zombie.CommonPreLoadHud(self, controller)
    CoD.UsermapName = "Challenges Map"
end

local PostLoadFunc = function(self, controller)
    CoD.Zombie.CommonPostLoadHud(self, controller)
end

LUI.createMenu.T7Hud_zm_challenges = function(controller)
    local self = CoD.Menu.NewForUIEditor("T7Hud_zm_challenges")

    if PreLoadFunc then
        PreLoadFunc(self, controller)
    end

    self.soundSet = "HUD"
    self:setOwner(controller)
    self:setLeftRight(true, true, 0, 0)
    self:setTopBottom(true, true, 0, 0)
    self:playSound("menu_open", controller)
    self.buttonModel = Engine.CreateModel(Engine.GetModelForController(controller), "T7Hud_zm_challenges.buttonPrompts")
    self.anyChildUsesUpdateState = true

    -- Standard zombies HUD elements
    self.Rounds = CoD.ZmRndContainer.new(self, controller)
    self.Rounds:setLeftRight(false, true, -200, 0)
    self.Rounds:setTopBottom(true, false, 0, 140)
    self.Rounds:setScale(0.8)
    self:addElement(self.Rounds)

    self.Ammo = CoD.ZmAmmoContainerFactory.new(self, controller)
    self.Ammo:setLeftRight(true, true, 0, 0)
    self.Ammo:setTopBottom(true, true, 0, 0)
    self:addElement(self.Ammo)

    self.Score = CoD.ZMScr.new(self, controller)
    self.Score:setLeftRight(true, true, 0, 0)
    self.Score:setTopBottom(true, true, 0, 0)
    self:addElement(self.Score)

    self.Perks = CoD.ZMPerksContainerFactory.new(self, controller)
    self.Perks:setLeftRight(true, true, 0, 0)
    self.Perks:setTopBottom(true, true, 0, 0)
    self:addElement(self.Perks)

    self.Notification = CoD.Notification.new(self, controller)
    self.Notification:setLeftRight(true, true, 0, 0)
    self.Notification:setTopBottom(true, true, 0, 0)
    self:addElement(self.Notification)

    self.ZmNotifBGBContainerFactory = CoD.ZmNotifBGB_ContainerFactory.new(self, controller)
    self.ZmNotifBGBContainerFactory:setLeftRight(true, true, 0, 0)
    self.ZmNotifBGBContainerFactory:setTopBottom(true, true, 0, 0)
    self:addElement(self.ZmNotifBGBContainerFactory)

    self.CursorHint = CoD.ZMCursorHint.new(self, controller)
    self.CursorHint:setLeftRight(true, true, 0, 0)
    self.CursorHint:setTopBottom(true, true, 0, 0)
    self:addElement(self.CursorHint)

    self.CenterConsole = CoD.CenterConsole.new(self, controller)
    self.CenterConsole:setLeftRight(true, true, 0, 0)
    self.CenterConsole:setTopBottom(true, true, 0, 0)
    self:addElement(self.CenterConsole)

    self.DeadSpectate = CoD.DeadSpectate.new(self, controller)
    self.DeadSpectate:setLeftRight(true, true, 0, 0)
    self.DeadSpectate:setTopBottom(true, true, 0, 0)
    self:addElement(self.DeadSpectate)

    self.MPScr = CoD.MPScr.new(self, controller)
    self.MPScr:setLeftRight(true, true, 0, 0)
    self.MPScr:setTopBottom(true, true, 0, 0)
    self:addElement(self.MPScr)

    self.PrematchCountdown = CoD.ZM_PrematchCountdown.new(self, controller)
    self.PrematchCountdown:setLeftRight(true, true, 0, 0)
    self.PrematchCountdown:setTopBottom(true, true, 0, 0)
    self:addElement(self.PrematchCountdown)

    self.ScoreboardWidgetCP = CoD.ScoreboardWidgetCP.new(self, controller)
    self.ScoreboardWidgetCP:setLeftRight(true, true, 0, 0)
    self.ScoreboardWidgetCP:setTopBottom(true, true, 0, 0)
    self:addElement(self.ScoreboardWidgetCP)

    self.BubbleGumPackInGame = CoD.BubbleGumPackInGame.new(self, controller)
    self.BubbleGumPackInGame:setLeftRight(true, true, 0, 0)
    self.BubbleGumPackInGame:setTopBottom(true, true, 0, 0)
    self:addElement(self.BubbleGumPackInGame)

    self.IngameChatClientContainer = CoD.IngameChatClientContainer.new(self, controller)
    self.IngameChatClientContainer:setLeftRight(true, false, 4, 404)
    self.IngameChatClientContainer:setTopBottom(false, true, -282, -34)
    self:addElement(self.IngameChatClientContainer)

    -- Custom Challenge Progress Widget (positioned internally)
    self.ChallengeProgress = CoD.ChallengeProgress.new(self, controller)
    self.ChallengeProgress:setLeftRight(true, true, 0, 0)
    self.ChallengeProgress:setTopBottom(true, true, 0, 0)
    self:addElement(self.ChallengeProgress)

    self:registerEventHandler("menu_opened", function(element, event)
        local controller = event.controller
        SizeToSafeArea(element, controller)
        return false
    end)

    self:processEvent({
        name = "menu_opened",
        controller = controller
    })

    self:subscribeToGlobalModel(controller, "PerController", "scriptNotify", function(model)
        CoD.Zombie.HandleScriptNotifies(self, controller, model)
    end)

    if PostLoadFunc then
        PostLoadFunc(self, controller)
    end

    return self
end
