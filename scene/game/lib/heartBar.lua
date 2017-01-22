
-- Heart bar module

local fx = require( "com.ponywolf.ponyfx" )

-- Define module
local M = {}
local composer = require( "composer" )

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
  
	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds
  
  function group:boostHearts()
    for i=1,max do
      display.remove(hearts[i])
    end
    max = max + 1
    group:makeHearts()
  end
  
  
  function group:makeHearts()
    local row = 0
    local rowlength = 4
    for i = 1, max do
      hearts[i] = display.newImageRect( "scene/game/img/shield.png", w, h )
      group:insert( hearts[i] )
      local col = (i-1) % rowlength
      if col == 0 and i > rowlength then row = row + 1 end
      hearts[i].x = col * ( (w/2) + spacing )
      hearts[i].y = row * ( spacing * 1.6 ) --0
      hearts[i].alpha = 0
      timer.performWithDelay((i-1)*250,
        function()
          hearts[i].xScale = 0.1
          hearts[i].yScale = 0.1
--          audio.play( sounds.pbr )
          transition.to(hearts[i],{alpha=1,xScale=1,yScale=1,time=500,transition=easing.inOutQuad})
        end)
      if not hearts[i].breathing then
        timer.performWithDelay(i*500,
          function()
            fx.breath(hearts[i], 0.1, 500)
          end)
      end
    end
    group.count = max
  end

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

	function group:heal( amount, container )
    if container == true then
      group:boostHearts()
    else
      self:damage( -( amount or 1 ) )
    end
	end

  function group:get() return max or 0 end


	function group:finalize()
		-- On remove, cleanup instance 
	end
	group:addEventListener( "finalize" )

  group:makeHearts()
	-- Return instance
	return group
end

return M
