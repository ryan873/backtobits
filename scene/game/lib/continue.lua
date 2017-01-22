
-- Extends an object to load a new map

-- Define module
local M = {}

local composer = require( "composer" )

local fx = require( "com.ponywolf.ponyfx" )

function M.new( instance )

	if not instance then error( "ERROR: Expected display object" ) end
  
	-- Get current scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds
  
  local map = instance.map
  local beat = instance.beat or false
  if scene.beat then
    beat = scene.beat
  end

	instance.isVisible = false
	local parent = instance.parent
	local x, y = instance.x, instance.y

  	-- Load spritesheet
	local sheetData = { width = 96, height = 96, numFrames = 4, sheetContentWidth = 192, sheetContentHeight = 192 }
	local sheet = graphics.newImageSheet( "scene/game/map/goBlockSheet.png", sheetData )
	local sequenceData = {
		{ name = "shine", frames = { 1,2,3,4 }, time = 500, loopCount = 0 }
	}
	instance = display.newSprite( parent, sheet, sequenceData )
	instance.x,instance.y = x, y
	instance:setSequence( "shine" )
  instance.map = map
  instance.beat = beat
  instance:play()
  
  transition.from(instance, {xScale = 0.01, yScale = 0.01, time=760, delay=1700, alpha=0, transition=easing.outBounce})

  
	if not instance.bodyType then
		physics.addBody( instance, "dynamic", { density = 0.1, bounce = 0.5, friction =  1.0, isSensor = true } )
    instance.isFixedRotation = true
    instance.gravityScale = 0
    instance.isBodyActive = false
    timer.performWithDelay(1900,function() instance.isBodyActive = true end)
	end

	function instance:collision( event )
		local phase, other = event.phase, event.other
		if phase == "began" and other.name == "hero" and not other.isDead then
      audio.play( sounds.lazer )
			other.isDead = true
--			other.linearDamping = 8
			self.fill.effect = "filter.exposure"
      local y = self.y
      transition.to(self, {y=y-32, time=200, transition=easing.outQuad, onComplete=function()
        transition.to( self.fill.effect, { time = 200, exposure = 5 })
        transition.to(self,{y=y, time=400, transition=easing.outBounce, onComplete=function()
          fx.fadeOut( function()
            composer.gotoScene( "scene.refresh", { params = { map = self.map, beat = self.beat, score = scene.score:get() } } )
          end )
        end})
      end})
		end
	end

	instance:addEventListener( "collision" )
	return instance
end

return M
