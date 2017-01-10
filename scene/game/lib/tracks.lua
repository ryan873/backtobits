
-- Heart bar module

-- Define module
local M = {}

function M.new( options )

	-- Default options for instance
	options = options or {}
	local image = options.image
	local max = options.max or 5
	local spacing = options.spacing or 32
	local w, h = options.width or 64, options.height or 64

	-- Create display group to hold visuals
	local group = display.newGroup()
	local hearts = {}
  local icon = display.newImageRect( "scene/game/map/tracks_score_icon.png", w, h )
  icon.x = 0
  icon.y = 0
  group:insert(icon)
	for i = 1, max do
		hearts[i] = display.newImageRect( "scene/game/map/tracks_score_" .. i .. ".png", w, h )
		hearts[i].x = (i) * ( (w/2) + spacing )
		hearts[i].y = 0
    hearts[i].alpha = 0.1
		group:insert( hearts[i] )
	end
	group.count = max

  function group:activate(num)
    hearts[num].alpha = 1.0  
  end
  

	function group:damage( amount )
		group.count = math.min( max, math.max( 0, group.count - ( amount or 1 ) ) )
		for i = 1, max do
			if i <= group.count then
				hearts[i].alpha = 1
			else
				hearts[i].alpha = 0.2
			end
		end
		return group.count
	end

	function group:heal( amount )
		self:damage( -( amount or 1 ) )
	end

	function group:finalize()
		-- On remove, cleanup instance 
	end
	group:addEventListener( "finalize" )

	-- Return instance
	return group
end

return M
