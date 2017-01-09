
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
  instance.xScale, instance.yScale = 0.1, 0.1
	instance:setSequence( "noise" )
  instance.map = map
  instance:play()
  
  transition.to(instance, { time=555, xScale=2, yScale=2, transition=easing.outQuad, onComplete=function()
        transition.to(instance, {time=333, xScale=0.01, yScale=0.01, alpha=0, transition=easing.inQuad})
      end
      })
  
	return instance
end

return M
