
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
local map, hero, shield, parallax1, parallax2, parallax3

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
	local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
	map = tiled.new( mapData, "scene/game/map" )
	--map.xScale, map.yScale = 0.85, 0.85

  local song = mapData.properties.song or "backto8bit"

  local xGravity = 0 -- wind?
  local yGravity = mapData.properties.gravity or 48 -- get map gravity if it exists
  
  physics.setGravity( xGravity, yGravity )

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
		sword = audio.loadSound( sndDir .. "sword.wav" ),
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




	-- Find our enemies and other items
	map:extend( "pbr", "blob", "enemy", "exit", "coin", "spikes", "block", "droplet", "bubble" )

	-- Find the parallax layer
	parallax1 = map:findLayer( "parallax1" )
	parallax2 = map:findLayer( "parallax2" )
	parallax3 = map:findLayer( "parallax3" )

	-- Add our scoring module
	local gem = display.newImageRect( sceneGroup, "scene/game/img/gem.png", 64, 64 )
	gem.x = display.contentWidth - gem.contentWidth / 2 - 24
	gem.y = display.screenOriginY + gem.contentHeight / 2 + 20

	scene.score = scoring.new( { score = event.params.score, font = "scene/game/font/04B_03__.TTF"} )
	local score = scene.score
	score.x = display.contentWidth - score.contentWidth / 2 - 32 - gem.width
	score.y = display.screenOriginY + score.contentHeight / 2 + 32

  scene.tracks = tracks.new( {} )
  local tracks = scene.tracks
  tracks.x = display.contentWidth/2 - tracks.width/2
  tracks.y = score.y - 16

	-- Add our hearts module
	shield = heartBar.new({spacing=32})
	shield.x = 48
	shield.y = display.screenOriginY + shield.contentHeight / 2 + 16
	hero.shield = shield

	-- Touch the sheilds to go back to the main...
	function shield:tap(event)
		fx.fadeOut( function()
				composer.gotoScene( "scene.menu")
			end )
	end
	shield:addEventListener("tap")

	-- Insert our game items in the correct back-to-front order
	sceneGroup:insert( map )
	sceneGroup:insert( score )
	sceneGroup:insert( gem )
	sceneGroup:insert( shield )

end

-- Function to scroll the map
local function enterFrame( event )

	local elapsed = event.time

	-- Easy way to scroll a map based on a character
	if hero and hero.x and hero.y and not hero.isDead then
		local x, y = hero:localToContent( 0, 0 )
		x, y = display.contentCenterX - x, display.contentCenterY - y
		map.x, map.y = map.x + x, map.y + y
		-- Easy parallax
		if parallax3 then -- totally static parallax
			parallax3.x, parallax3.y = hero.x - parallax3.width/2, map.y / 8 + parallax2.height/4 -- Affects x more than y
		end
		if parallax2 then -- more static parallax
			parallax2.x, parallax2.y = hero.x - parallax2.width/2 + map.x * .01 - 256, map.y / 8 + parallax2.height/7 -- Affects x more than y
		end
		if parallax1 then -- more dynamic parallax
			parallax1.x, parallax1.y = hero.x - parallax1.width/2 + map.x * .05, parallax1.y -- + map.y / 8 -- Affects x more than y
		end
	end
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
		audio.fadeOut( { time = 1000 } )
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
