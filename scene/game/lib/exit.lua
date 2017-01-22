
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
	instance.isVisible = false
	local parent = instance.parent
	local x, y = instance.x, instance.y

  	-- Load spritesheet
	local sheetData = { width = 256, height = 256, numFrames = 4, sheetContentWidth = 512, sheetContentHeight = 512 }
	local sheet = graphics.newImageSheet( "scene/game/map/noise_sheet.png", sheetData )
	local sequenceData = {
		{ name = "noise", frames = { 1,2,3,4 }, time = 500, loopCount = 0 }
	}
	instance = display.newSprite( parent, sheet, sequenceData )
	instance.x,instance.y = x, y
	instance:setSequence( "noise" )
  instance.map = map
  instance:play()
  

  
	if not instance.bodyType then
		physics.addBody( instance, "static", { isSensor = true } )
	end

	function instance:collision( event )
		local phase, other = event.phase, event.other
		if phase == "began" and other.name == "hero" and not other.isDead then
			other.isDead = true
			other.linearDamping = 8
      audio.play( sounds.exit )
			transition.to( self, { time = 600, xScale = 3, yScale = 3, transition = easing.outQuad, onComplete = function()
        transition.to( self, { time = 400, xScale = 1, yScale = 1, transition = easing.inQuad, onComplete = function()
          fx.fadeOut( function()
            audio.fadeOut( { time = 1000 } )
            composer.gotoScene( "scene.refresh", { params = { map = self.map, beat = scene.beat, hearts = scene.shield:get(), score = scene.score:get() } } )
          end )
        end } )
			end } )
		end
	end

	instance:addEventListener( "collision" )
	return instance
end

return M
