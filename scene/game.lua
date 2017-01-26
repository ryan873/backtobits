
-- Include modules/libraries
local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )
local tiled = require( "com.ponywolf.ponytiled" )
local physics = require( "physics" )
local json = require( "json" )
local scoring = require( "scene.game.lib.score" )
local tracks = require( "scene.game.lib.tracks" )
local heartBar = require( "scene.game.lib.heartBar" )


-- Variables local to scene
local map, hero, title, shield, parallax1, parallax2, parallax3, parallax4

-- Create a new Composer scene
local scene = composer.newScene()

-- This function is called when scene is created
function scene:create( event )

	local sceneGroup = self.view  -- Add scene display objects to this group

	-- Start physics before loading map
	physics.start()
	physics.setGravity( 0, 0 )

	-- Load our map
	local filename = event.params.map or "scene/game/map/sandbox.json"
  
  print('Loading map: ' .. filename)
  
  
  -- did we beat the game? influences sprites for replay
  if not scene.beat then
    local beat = event.params.beat or false
--    print('beat? ' .. tostring(beat))
    scene.beat = beat  
  end
	local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
	map = tiled.new( mapData, "scene/game/map" )
	--map.xScale, map.yScale = 0.85, 0.85
  local mapScale = mapData.properties.mapScale or 1.0
  map.xScale, map.yScale = 1.0, 1.0

  local song = mapData.properties.song or "backto8bit"

  local xGravity = 0 -- wind?
  local yGravity = mapData.properties.gravity or 48 -- get map gravity if it exists
  
  physics.setGravity( xGravity, yGravity )
  
  -- pause gravity start so hero can appear
  physics.pause()
  timer.performWithDelay(700, function()
      physics.start()
    end)
	-- Sounds
	local sndDir = "scene/game/sfx/"
	scene.sounds = {
    
    --[[
    levelMusic = {
        audio.loadSound( sndDir .. "loops/venus.mp3" ),
        audio.loadSound( sndDir .. "loops/ladders.mp3" ),
        audio.loadSound( sndDir .. "loops/playstation.mp3" ),
        audio.loadSound( sndDir .. "loops/8bitface.mp3" ),
        audio.loadSound( sndDir .. "loops/backto8bit.mp3" )
      },
    ]]--
    
    levelMusic = audio.loadSound( sndDir .. "loops/" .. song .. ".mp3"),
    
		thud = audio.loadSound( sndDir .. "thud.wav" ),
		exit = audio.loadSound( sndDir .. "exit.wav" ),
		kill = audio.loadSound( sndDir .. "kill.wav" ),
    died = audio.loadSound( sndDir .. "died.wav" ),
		squish = audio.loadSound( sndDir .. "squish.wav" ),
		slime = audio.loadSound( sndDir .. "slime.wav" ),
		door = audio.loadSound( sndDir .. "door.wav" ),
		hurt = {
			audio.loadSound( sndDir .. "hurt1.wav" ),
			audio.loadSound( sndDir .. "hurt2.wav" ),
		},
		hit = audio.loadSound( sndDir .. "hit.wav" ),
		coin = audio.loadSound( sndDir .. "coin.wav" ),
		victory = audio.loadSound( sndDir .. "victory.wav" ),
		lazer = audio.loadSound( sndDir .. "lazer.wav" ),
		pbr = audio.loadSound( sndDir .. "pbr.wav" ),
		jump = audio.loadSound( sndDir .. "jump.wav" ),
		boxbump = audio.loadSound( sndDir .. "boxbump.wav" )
	}

	-- Find our hero!
	map.extensions = "scene.game.lib."
	map:extend( "hero" )
	hero = map:findObject( "hero" )
	hero.filename = filename
  hero.jumpforce = mapData.properties.jumpforce or -760
  hero.swim = mapData.properties.swim or false
  hero.ice = mapData.properties.ice or false

  -- bring in map and hero
  transition.to(map, {xScale=mapScale, yScale=mapScale, delay=500, time=2000, transition=easing.inOutQuad})
  transition.from(hero, {xScale=0.01, yScale=0.01, alpha=0, time=500, delay=100, transition=easing.inOutQuad})

  -- find title if it exists
  title = map:findObject( "title" ) or nil
  if (title) then
    transition.from( title, { xScale = 2.5, yScale = 2.5, alpha=0, delay=1500, time = 1000, transition = easing.outBounce } )
  end

  
	-- Find our enemies and other items
	map:extend( "pbr", "blob", "enemy", "enter", "exit", "continue", "coin", "heart", "spikes", "block", "droplet", "bubble" )

	-- Find the parallax layer
	parallax1 = map:findLayer( "parallax1" )
	parallax2 = map:findLayer( "parallax2" )
	parallax3 = map:findLayer( "parallax3" )
	parallax4 = map:findLayer( "parallax4" )

	-- Add our scoring module
	local gem = display.newImageRect( sceneGroup, "scene/game/img/gem.png", 64, 64 )
	gem.x = display.contentWidth - gem.contentWidth / 2 - 24
	gem.y = display.screenOriginY + gem.contentHeight / 2 + 20

	scene.score = scoring.new( { score = event.params.score, font = "scene/game/font/04B_03__.TTF"} )
	local score = scene.score
	score.x = display.contentWidth - score.contentWidth / 2 - 32 - gem.width
	score.y = display.screenOriginY + score.contentHeight / 2 + 32

  if scene.tracks == nil then
    scene.tracks = tracks.new( {} )
  end
  
  local tracks = scene.tracks
  tracks.x = display.contentWidth/2 - tracks.width/2
  tracks.y = score.y - 16

	-- Add our hearts module
  local hearts = event.params.hearts or 3
	scene.shield = heartBar.new({max=hearts,spacing=32})
  local shield = scene.shield
	shield.x = 48
	shield.y = 48 --display.screenOriginY + shield.contentHeight / 2 + 16
	hero.shield = shield

	-- Touch the sheilds to go back to the main...
  --[[
	function shield:tap(event)
		fx.fadeOut( function()
				composer.gotoScene( "scene.menu")
			end )
	end
	shield:addEventListener("tap")
  ]]--
  
	-- Insert our game items in the correct back-to-front order
	sceneGroup:insert( map )
--	sceneGroup:insert( tracks )
	sceneGroup:insert( score )
	sceneGroup:insert( gem )
	sceneGroup:insert( shield )

end

-- Function to scroll the map
local function enterFrame( event )

	local elapsed = event.time

	-- Easy way to scroll a map based on a character
	if hero and hero.x and hero.y and not hero.isDead then
		local x, y = hero:localToContent( 0, -32 )
		x, y = display.contentCenterX - x, display.contentCenterY - y
		map.x, map.y = map.x + x, map.y + y
		-- Easy parallax
		if parallax4 then -- totally static parallax
			parallax4.x, parallax4.y = hero.x - parallax4.width/2, map.y / 8 + parallax4.height/4 -- Affects x more than y
		end
		if parallax3 then -- totally static parallax
			parallax3.x, parallax3.y = hero.x - parallax3.width/2, map.y / 8 + parallax3.height/4 -- Affects x more than y
		end
		if parallax2 then -- more static parallax
			parallax2.x, parallax2.y = hero.x - parallax2.width/2 + map.x * .01 - 256, map.y / 8 + parallax2.height/7 -- Affects x more than y
		end
		if parallax1 then -- more dynamic parallax
			parallax1.x, parallax1.y = hero.x - parallax1.width/2 + map.x * .05, parallax1.y -- + map.y / 8 -- Affects x more than y
		end
	end
  
  -- are we drunk?
  --[[
  local newScale = math.abs(math.sin(elapsed*0.001))
  
  local newXScale = 0.5 + (newScale * 0.5)
  local newYScale = 1.0 - (newScale * 0.5)
  
  map.xScale, map.yScale = newXScale, newYScale
  ]]--
  

  
end


-- This function is called when scene comes fully on screen
function scene:show( event )

	local phase = event.phase
	if ( phase == "will" ) then
		fx.fadeIn()	-- Fade up from black
		Runtime:addEventListener( "enterFrame", enterFrame )
	elseif ( phase == "did" ) then
		-- For more details on options to play a pre-loaded sound, see the Audio Usage/Functions guide:
		-- https://docs.coronalabs.com/guide/media/audioSystem/index.html
		audio.play( self.sounds.levelMusic, { loops = -1, fadein = 0, channel = 15 } )
	end
end

-- This function is called when scene goes fully off screen
function scene:hide( event )

	local phase = event.phase
	if ( phase == "will" ) then
--		audio.fadeOut( { time = 1000 } )
	elseif ( phase == "did" ) then
		Runtime:removeEventListener( "enterFrame", enterFrame )
	end
end

-- This function is called when scene is destroyed
function scene:destroy( event )

	audio.stop()  -- Stop all audio
	for s, v in pairs( self.sounds ) do  -- Release all audio handles
		audio.dispose( v )
		self.sounds[s] = nil
	end
end


scene:addEventListener( "create" )
scene:addEventListener( "show" )
scene:addEventListener( "hide" )
scene:addEventListener( "destroy" )

return scene
