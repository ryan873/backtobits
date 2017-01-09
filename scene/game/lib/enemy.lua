
-- Module/class for platformer enemy
-- Use this as a template to build an in-game enemy 

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )

	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds
 
  local sprite = instance.sprite or 21 -- starting frame of sprite artwork
  local roamTime = instance.roamTime or 300
  local fish = instance.fish or false -- am I a fish?
  local bullet = instance.bullet or false
  local bulletTimer
  
	-- Store map placement and hide placeholder
	instance.isVisible = false
	local parent = instance.parent
	local x, y = instance.x, instance.y

	-- Load spritesheet
  local imageSheet = "scene/game/img/sprites.png"
  if (scene.beat) then
    imageSheet = "scene/game/img/sprites_beat.png"
  end
	local sheetData = { width = 192, height = 256, numFrames = 79, sheetContentWidth = 1920, sheetContentHeight = 2048 }
	local sheet = graphics.newImageSheet( imageSheet, sheetData )
  local walkFrames = {}
  local animTime = 500
  if (roamTime > 0) then
    walkFrames = { sprite+1, sprite+2, sprite+3, sprite+4}
  else
    animTime = 2000
    walkFrames = { sprite, sprite, sprite, sprite, sprite, sprite, sprite, sprite, sprite, sprite, sprite, sprite, sprite, sprite, sprite, sprite+1, sprite+2, sprite+3, sprite+4}
  end
  
	local sequenceData = {
		{ name = "dead", frames = { sprite } },
		{ name = "walk", frames = walkFrames , time = animTime, loopCount = 0 }
	}
	instance = display.newSprite( parent, sheet, sequenceData )
	instance.x, instance.y = x, y
  instance.bullet = bullet
	instance:setSequence( "walk" )
	instance:play()
  

	-- Add physics
  local enemyGravityScale = 1.0
  if fish == true then
--    print ("I am a fish!")
    enemyGravityScale = 0
  end
  
	physics.addBody( instance, "dynamic", { radius = 54, density = 3, bounce = 0, friction =  1.0 } )
  instance.gravityScale = enemyGravityScale
	instance.isFixedRotation = true
	instance.anchorY = 0.77
	instance.angularDamping = 3
	instance.isDead = false

  function instance:shoot()
--    print('I am shooting...')
    local bullet = display.newImageRect("scene/game/map/bullet.png", 32, 32)
    bullet.x, bullet.y = self.x-self.width/2, self.y+self.width/8
    bullet.xScale = 3.0
    physics.addBody( bullet, "dynamic", {radius=16, density=1,bounce=0.5, friction=0.5})
    bullet.gravityScale = 0
    bullet.isBullet = true
    bullet.type = "bullet"
    bullet:setLinearVelocity(-800, 0)
    instance.parent:insert(bullet)
    timer.performWithDelay(1600, function() display.remove(bullet) end)
  end
  
  local function shoot()
    instance:shoot()
  end

	function instance:die()
		audio.play( sounds.kill )
		self.isFixedRotation = true
		self.isSensor = true
    
    self:applyLinearImpulse( math.random(0,32)-16, -160 ) -- (0, -200)
    self.isDead = true
--    self.yScale = -1
    self:setSequence( "dead" )


	end

	function instance:preCollision( event )
		local other = event.other
		local y1, y2 = self.y + 50, other.y - other.height/2
		-- Also skip bumping into floating platforms
		if event.contact and ( y1 > y2 ) then
      if other.floating then
        event.contact.isEnabled = false
      else
        event.contact.friction = 0.1 --1.0
      end
		end
	end

	local max, direction, flip, timeout = 250, 5000, 0.133, 0
--  print ('roamtime is ' .. roamTime)
  local roam = 0
	direction = direction * ( ( instance.xScale < 0 ) and 1 or -1 )
	flip = flip * ( ( instance.xScale < 0 ) and 1 or -1 )

	local function enterFrame()

		-- Do this every frame
		local vx, vy = instance:getLinearVelocity()
		local dx = direction
		if instance.jumping then dx = dx / 5 end
    if roamTime >= 0 then      
      if ( dx < 0 and vx > -max ) or ( dx > 0 and vx < max ) then
        instance:applyForce( dx or 0, 0, instance.x, instance.y )
      end
		-- Bumped
      if math.abs( vx ) < 1 then
        timeout = timeout + 1
        if timeout > 4 then
          timeout = 0
          direction, flip = -direction, -flip
        end
      end
    end
    
		

    if (not instance.isDead and roamTime >= 0) then
      roam = roam + 1
      if (roam > roamTime) then
        roam = 0
        direction, flip = -direction, -flip
      end      
    end
    
    

		-- Turn around
		instance.xScale = math.min( 1, math.max( instance.xScale + flip, -1 ) )
	end

	function instance:finalize()
		-- On remove, cleanup instance, or call directly for non-visual
		Runtime:removeEventListener( "enterFrame", enterFrame )
    if (bulletTimer) then
      timer.cancel(bulletTimer)
      bulletTimer = nil
    end
		instance = nil
	end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	instance:addEventListener( "finalize" )

	-- Add our enterFrame listener
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- Add our collision listener
	instance:addEventListener( "preCollision" )

	-- Return instance
	instance.name = "enemy"
	instance.type = "enemy"
  
  if (instance.bullet) then  
    bulletTimer = timer.performWithDelay(4000, shoot, -1)
  else
    bulletTimer = nil
  end

	return instance
end

return M
