-- Simple test widget - just a red box with text
CoD.TestWidget = InheritFrom(LUI.UIElement)

CoD.TestWidget.new = function(menu, controller)
    local self = LUI.UIElement.new()
    
    self:setClass(CoD.TestWidget)
    self.id = "TestWidget"
    self:setLeftRight(true, false, 0, 400)
    self:setTopBottom(true, false, 0, 200)
    
    -- Red background
    self.bg = LUI.UIImage.new()
    self.bg:setLeftRight(true, true, 0, 0)
    self.bg:setTopBottom(true, true, 0, 0)
    self.bg:setRGB(1, 0, 0)
    self.bg:setAlpha(0.8)
    self:addElement(self.bg)
    
    -- Text
    self.text = LUI.UIText.new()
    self.text:setLeftRight(true, true, 10, -10)
    self.text:setTopBottom(true, false, 80, 120)
    self.text:setText("^2TEST WIDGET VISIBLE")
    self.text:setTTF("fonts/default.ttf")
    self.text:setAlignment(Enum.LUIAlignment.LUI_ALIGNMENT_CENTER)
    self.text:setRGB(1, 1, 1)
    self:addElement(self.text)
    
    return self
end

return CoD.TestWidget
