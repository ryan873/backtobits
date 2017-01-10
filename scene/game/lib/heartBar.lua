
-- Heart bar module

local fx = require( "com.ponywolf.ponyfx" )

-- Define module
local M = {}

function M.new( options )

	-- Default options for instance
	options = options or {}
	local image = options.image
	local max = options.max or 3
	local spacing = options.spacing or 8
	local w, h = options.width or 64, options.height or 64

	-- Create display group to hold visuals
	local group = display.newGroup()
	local hearts = {}
	for i = 1, max do
		hearts[i] = display.newImageRect( "scene/game/img/shield.png", w, h )
		hearts[i].x = (i-1) * ( (w/2) + spacing )
		hearts[i].y = 0
		group:insert( hearts[i] )
    if not hearts[i].breathing then
      timer.performWithDelay(i*500,
        function()
          fx.breath(hearts[i], 0.1, 500)
        end)
    end
	end
	group.count = max

	function group:damage( amount )
		group.count = math.min( max, math.max( 0, group.count - ( amount or 1 ) ) )
		for i = 1, max do
			if i <= group.count then
				hearts[i].alpha = 1
			else
				hearts[i].alpha = 0
			end
		end
    if group.count > 0 then
      if not hearts[group.count].breathing then
        fx.breath(hearts[group.count], 0.1, 500)
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
