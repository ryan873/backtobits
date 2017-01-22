
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
	local heartgroup = {}
  local icon = display.newImageRect( "scene/game/map/tracks_score_icon.png", w, h )
  icon.x = 0
  icon.y = 0
  group:insert(icon)
	for i = 1, max do
    heartgroup[i] = display.newGroup()
    hearts[i] = {}
		hearts[i][0] = display.newImageRect( "scene/game/map/tracks_score_" .. i .. "_empty.png", w, h )
		hearts[i][1] = display.newImageRect( "scene/game/map/tracks_score_" .. i .. ".png", w, h )
--    hearts[i].fill.effect = "filter.woodCut"
--    hearts[i].fill.effect.intensity = 1.0
    hearts[i][0].alpha = 0.25
    hearts[i][1].alpha = 0
    hearts[i][0].blendMode = "overlay"
    heartgroup[i]:insert( hearts[i][0] )
    heartgroup[i]:insert( hearts[i][1] )
		heartgroup[i].x = (i) * ( (w/2) + spacing )
		heartgroup[i].y = 0
		group:insert( heartgroup[i] )
	end
	group.count = max

  function group:activate(num)
    hearts[num][1].alpha = 1.0
    hearts[num][0].alpha = 0
--    hearts[num].fill.effect.intensity = 0
--    hearts[num].fill.effect = nil
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
