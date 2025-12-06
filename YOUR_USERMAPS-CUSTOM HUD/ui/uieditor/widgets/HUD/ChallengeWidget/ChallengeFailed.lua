-- Challenge Failed Widget
-- Shows as overlay when challenge fails
-- Red/grey theme with failure messaging

CoD.ChallengeFailed = InheritFrom(LUI.UIElement)

function CoD.ChallengeFailed.new(menu, controller)
    local self = LUI.UIElement.new()
    
    if PreLoadFunc then
        PreLoadFunc(self, controller)
    end
    
    self:setUseStencil(false)
    self:setClass(CoD.ChallengeFailed)
    self.id = "ChallengeFailed"
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
    
    -- tedd_challenge_body (BEHIND - grey body for failure)
    self.tedd_challenge_body = LUI.UIImage.new()
    self.tedd_challenge_body:setLeftRight(true, false, 30, 260)
    self.tedd_challenge_body:setTopBottom(true, false, 24, 95)
    self.tedd_challenge_body:setImage(RegisterImage("i_mtl_tedd_task_common_ui_body"))
    self.tedd_challenge_body:setRGB(0.5, 0.5, 0.5)
    self.tedd_challenge_body:setScale(1.00)
    self.tedd_challenge_body:setAlpha(1)
    self:addElement(self.tedd_challenge_body)
    
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
    
    -- Failure X icon (ON TOP - red X icon)
    self.tadd_challenge_check = LUI.UIImage.new()
    self.tadd_challenge_check:setLeftRight(true, false, 16, 46)
    self.tadd_challenge_check:setTopBottom(true, false, 10, 38)
    self.tadd_challenge_check:setImage(RegisterImage("i_mtl_teddd_task_ui_ex"))
    self.tadd_challenge_check:setRGB(1.0, 0.2, 0.2)
    self.tadd_challenge_check:setScale(1.00)
    self.tadd_challenge_check:setAlpha(1)
    self:addElement(self.tadd_challenge_check)
    
    -- Header text ("T.E.D.D. TASK FAILED!") - smaller font
    self.HeaderTitle = LUI.UIText.new()
    self.HeaderTitle:setLeftRight(true, false, 55, 215)
    self.HeaderTitle:setTopBottom(true, false, 6, 21)
    self.HeaderTitle:setTTF("fonts/default.ttf")
    self.HeaderTitle:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    self.HeaderTitle:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_TOP)
    self.HeaderTitle:setText("T.E.D.D. TASK FAILED!")
    self.HeaderTitle:setRGB(1, 0.3, 0.3)
    self:addElement(self.HeaderTitle)
    
    -- Body description ("Challenge Failed") - smaller font
    self.FailureText = LUI.UIText.new()
    self.FailureText:setLeftRight(true, false, 60, 216)
    self.FailureText:setTopBottom(true, false, 25, 40)
    self.FailureText:setTTF("fonts/default.ttf")
    self.FailureText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    self.FailureText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_TOP)
    self.FailureText:setText("Challenge Failed")
    self.FailureText:setRGB(0.8, 0.8, 0.8)
    self:addElement(self.FailureText)
    
    -- Better luck message - smaller font
    self.MessageText = LUI.UIText.new()
    self.MessageText:setLeftRight(true, false, 60, 216)
    self.MessageText:setTopBottom(true, false, 44, 59)
    self.MessageText:setTTF("fonts/default.ttf")
    self.MessageText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_LEFT)
    self.MessageText:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_TOP)
    self.MessageText:setText("Better luck next time")
    self.MessageText:setRGB(0.7, 0.7, 0.7)
    self:addElement(self.MessageText)
    
    -- Get model references (CSC creates these, Lua just gets them)
    local controllerModel = Engine.GetModelForController(controller)
    
    -- Subscribe to challenge_failed to show/hide with animation
    self:subscribeToModel(Engine.GetModel(controllerModel, "tedd_challenge_failed"), function(modelRef)
        local failed = Engine.GetModelValue(modelRef)
        if failed == 1 then
            -- Animate in (fade + scale)
            self:setAlpha(0)
            self:setScale(0.8, 0.8)
            self:beginAnimation("failed_entrance", 300, false, false, CoD.TweenType.Elastic)
            self:setAlpha(1)
            self:setScale(1.0, 1.0)
            
            -- Auto-hide after 10 seconds
            self:registerEventHandler("failed_entrance", function()
                self:beginAnimation("failed_hold", 10000, false, false, CoD.TweenType.Linear)
            end)
            
            self:registerEventHandler("failed_hold", function()
                self:beginAnimation("failed_exit", 300, false, false, CoD.TweenType.Linear)
                self:setAlpha(0)
            end)
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

return CoD.ChallengeFailed
