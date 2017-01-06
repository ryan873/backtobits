
-- Extends an object to act as a pickup

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds
  local track = instance.track

	instance.isVisible = false
	local parent = instance.parent
	local x, y = instance.x, instance.y

	-- Load spritesheet
	local sheetData = { width = 256, height = 256, numFrames = 3, sheetContentWidth = 512, sheetContentHeight = 512 }
	local sheet = graphics.newImageSheet( "scene/game/map/track_sheet.png", sheetData )
	local sequenceData = {
		{ name = "idle", frames = { 1 } },
		{ name = "walk", frames = { 1,2,3 } , time = 500, loopCount = 0 },
	}
	instance = display.newSprite( parent, sheet, sequenceData )
	instance.x, instance.y = x, y
	instance:setSequence( "walk" )
	instance:play()
  

	function instance:collision( event )
		local phase, other = event.phase, event.other
		if phase == "began" and other.type == "hero" then
			audio.play( sounds.lazer )
			scene.score:add( 100 )
      local tracks = scene.tracks
      tracks:activate(track)
			display.remove( self )
		end
	end

	instance._y = instance.y
	physics.addBody( instance, "static", { isSensor = true } )
	transition.from( instance, { y = instance._y - 16, transition = easing.outBounce, time = 500, iterations = -1 } )
	instance:addEventListener( "collision" )

	return instance
end

return M
