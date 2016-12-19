
-- Extends an object to act as a box

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds

	function instance:collision( event )

		local phase, other = event.phase, event.other
		if phase == "began" and other.type == "block" then
--			audio.play( sounds.boxbump)
		end
	end

	instance:addEventListener( "collision" )

	return instance
end

return M
