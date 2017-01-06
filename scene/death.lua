
-- Include modules/libraries
local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )
local tiled = require( "com.ponywolf.ponytiled" )
local json = require( "json" )

local ui

-- Variables local to scene
local prevScene = composer.getSceneName( "previous" )

-- Create a new Composer scene
local scene = composer.newScene()

-- This function is called when scene is created
function scene:create( event )

	local sceneGroup = self.view  -- Add scene display objects to this group

	local options = { params = event.params }

  -- death sfx
  deathSFX = audio.loadSound("scene/game/sfx/death.wav")
  
  -- button sfx
  buttonSFX = audio.loadSound( "scene/game/sfx/lazer.wav" )

	-- Load our UI
	local uiData = json.decodeFile( system.pathForFile( "scene/menu/ui/death.json", system.ResourceDirectory ) )
	ui = tiled.new( uiData, "scene/menu/ui" )
	ui.x, ui.y = display.contentCenterX - ui.designedWidth/2, display.contentCenterY - ui.designedHeight/2

	-- Find the start button
	start = ui:findObject( "start" )
	function start:tap()
    audio.play(buttonSFX)
		fx.fadeOut( function()
        composer.gotoScene( prevScene, options )
--				composer.gotoScene( "scene.game", { params = { map = "scene/game/map/level1.json" } } )
			end )
	end
	fx.breath( start )


	-- Transtion in logo
	transition.from( ui:findObject( "logo" ), { alpha = 0.125, xScale = 0.5, yScale = 0.5, time = 5000, transition = easing.outQuad } )

	sceneGroup:insert( ui )


end

function scene:show( event )

	local phase = event.phase
	local options = { params = event.params }
	if ( phase == "will" ) then
		fx.fadeIn()
		start:addEventListener( "tap" )
		composer.removeScene( prevScene )
	elseif ( phase == "did" ) then
    audio.play(deathSFX)
--		composer.gotoScene( prevScene, options )
	end
end


-- This function is called when scene goes fully off screen
function scene:hide( event )

	local phase = event.phase
	if ( phase == "will" ) then
		start:removeEventListener( "tap" )
	elseif ( phase == "did" ) then
	end
end

-- This function is called when scene is destroyed
function scene:destroy( event )
	audio.stop()  -- Stop all audio
end


--scene:addEventListener( "show", scene )
scene:addEventListener( "create" )
scene:addEventListener( "show" )
scene:addEventListener( "hide" )
scene:addEventListener( "destroy" )

return scene
