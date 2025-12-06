require( "ui.utils.CoreUtil" )

CoD.CKBB = InheritFrom( LUI.UIElement )

function CoD.CKBB.new( menu, controller )
    
    local self = LUI.UIElement.new()

    if PreLoadFunc then
        PreLoadFunc( menu, controller )
    end

    self:setClass( CoD.CKBB )
    self.id = "CKBB"
    self.soundSet = "default"
    self.anyChildUsesUpdateState = true
    self:setLeftRight( true, false, 0, 24 )
    self:setTopBottom( true, false, 0, 24 )

    self.bindbg = LUI.UIImage.new( menu, controller )
	self.bindbg:setLeftRight( true, false, 0, 24 )
	self.bindbg:setTopBottom( true, false, 0, 24 )
	self.bindbg:setImage(RegisterImage("lui_ui_misc_keybind_background"))
	self:addElement( self.bindbg )

    self.bind = LUI.UIText.new( menu, controller )
	self.bind:setLeftRight( true, false, 0, 24 )
	self.bind:setTopBottom( true, false, 0, 24 )
	self.bind:setTTF( "fonts/tekoRegular.ttf" )
	self.bind:setAlignment( Enum.LUIAlignment.LUI_ALIGNMENT_CENTER )
	self:addElement( self.bind )

    self.clipsPerState = {
        DefaultState = {
            DefaultClip = function()
                self:setupElementClipCounter( 2 )

                self.bindbg:completeAnimation()
                self.bindbg:setAlpha( 1 )
                self.clipFinished( self.bindbg, {} )

                self.bind:completeAnimation()
                self.bind:setRGB( 0, 0, 0 )
                self.clipFinished( self.bind, {} )
            end
        }
    }

    LUI.OverrideFunction_CallOriginalSecond( self, "close", function( element )
        element.bindbg:close()
        element.bind:close()
    end)

    if PostLoadFunc then
        PostLoadFunc( menu, controller)
    end
    
    return self

end