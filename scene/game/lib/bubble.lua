
-- droplet animation

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )

	instance._y = instance.y
  
  delayRandom = (math.random(15)*1000) + (13440 - instance._y)
  
	transition.to( instance, { delay = delayRandom, y = instance._y - 13440, transition = easing.inQuad, time = 30000 } )

	return instance
end

return M
