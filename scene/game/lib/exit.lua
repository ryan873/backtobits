
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
  
  --[[
  
  local parent = instance.parent

  	-- Load spritesheet
	local sheetData = { width = 256, height = 256, numFrames = 4, sheetContentWidth = 1024, sheetContentHeight = 1024 }
	local sheet = graphics.newImageSheet( "scene/game/map/noise_sheet.png", sheetData )
	local sequenceData = {
		{ name = "noise", frames = { 1,2,3,4 } }
	}
	instance = display.newSprite( parent, sheet, sequenceData )
	instance.x,instance.y = 96, 0
	instance:setSequence( "noise" )
  instance:play()

  ]]--
  
	if not instance.bodyType then
		physics.addBody( instance, "static", { isSensor = true } )
	end

	function instance:collision( event )
		local phase, other = event.phase, event.other
		if phase == "began" and other.name == "hero" and not other.isDead then
			other.isDead = true
			other.linearDamping = 8
			audio.play( sounds.victory )
			self.fill.effect = "filter.exposure"
			transition.to( self.fill.effect, { time = 666, exposure = -5, onComplete = function()
				fx.fadeOut( function()
					composer.gotoScene( "scene.refresh", { params = { map = self.map, score = scene.score:get() } } )
				end )
			end } )
		end
	end

	instance:addEventListener( "collision" )
	return instance
end

return M
