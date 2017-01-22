
-- Project: rjoy 0.1
--
-- Hero control via relative position of finger on screen
-- Tap begin = get origin point
-- Tap move = move hero relative to origin point (horizontal only)

--local vibrator = require('plugin.vibrator') -- trying to do haptic feedback on virtual controller




local M = {}
local stage = display.getCurrentStage()

function M.newTapZones(leftPercent,rightPercent)
  
  local moveRect, jumpRect, instance
  
  leftPercent = leftPercent or .70
  rightPercent = rightPercent or .30
  
  instance = display.newGroup()
  
  local w,h = display.contentWidth, display.contentHeight
  
  moveRect  = display.newRect(instance, 0, 0, w*leftPercent, h)
  jumpRect = display.newRect(instance, moveRect.width, 0, w*rightPercent, h)
  
  moveRect.isHitTestable = true
  jumpRect.isHitTestable = true
  
  moveRect.isVisible = false
  jumpRect.isVisible = false
  
  moveRect.anchorX = 0
  jumpRect.anchorX = 0
  
  
  local dpad = display.newImage('img/dpad.png')
  local dpadL = display.newImage('img/dpadLeft.png')
  local dpadR = display.newImage('img/dpadRight.png')
  local buttonUp = display.newImage('img/buttonUp.png')
  local buttonDown = display.newImage('img/buttonDown.png')

  local dpadX,dpadY = 128, display.contentHeight - 128
  local buttonX,buttonY = display.contentWidth - 128, display.contentHeight - 128
  
	dpad.x, dpad.y, dpadL.x, dpadL.y, dpadR.x, dpadR.y = dpadX,dpadY,dpadX-3,dpadY,dpadX+3,dpadY
	buttonUp.x, buttonUp.y, buttonDown.x, buttonDown.y = buttonX,buttonY,buttonX,buttonY
  
  local function dPadManager(pos)
    dpad.isVisible = false
    dpadL.isVisible = false
    dpadR.isVisible = false
    
    if pos < 0 then
      dpadL.isVisible = true
    elseif pos > 0 then
      dpadR.isVisible = true
    else
      dpad.isVisible = true
    end    
  end
  
  local function buttonManager(pos)
    buttonUp.isVisible = false
    buttonDown.isVisible = false
    
    if pos < 0 then
      buttonDown.isVisible = true
    else
      buttonUp.isVisible = true
    end
    
  end



	function moveRect:touch( event )
    
    local startAxis = 1 -- horizontal only here
    local threshold = 10
    
		local phase = event.phase
    
    local parent = self.parent
    local posX, posY = parent:contentToLocal( event.x, event.y)
    
    if phase=="began" or ( phase=="moved" and self.isFocus ) then

      if phase == "began" then
        
        print('-----------------------')
        print('moveRect touch began!')
        stage:setFocus(event.target, event.id)
        self.eventID = event.id
        self.isFocus = true
        self.originX = posX
        self.axisX = 0
        self.dir = 'stop'
        self.lastDir = 'stop'
        
      elseif phase == "moved" then
        
        if posX < self.originX - threshold then
          self.dir = 'left'
          self.axisX = -1
        elseif posX > self.originX + threshold then
          self.dir = 'right'
          self.axisX = 1
        end
        
      end
      
    else
      
      print('moveRect touch ended!')
      dPadManager(0)
      stage:setFocus( nil, event.id )
      self.isFocus = false
      self.axisX = 0
      axisEvent = { name = "axis", axis = { number = startAxis }, normalizedValue = 0 }
      Runtime:dispatchEvent( axisEvent )
      
    end
    
    local axisEvent
		if not ( self.dir == self.lastDir ) then
      dPadManager(self.axisX)
--      print('moving ' .. self.dir .. ': ' .. posX .. '/' .. self.originX .. ' [' .. self.axisX .. ']')
      axisEvent = { name = "axis", axis = { number = startAxis }, normalizedValue = 0 }
      Runtime:dispatchEvent( axisEvent )
      axisEvent = { name = "axis", axis = { number = startAxis }, normalizedValue = self.axisX }
      Runtime:dispatchEvent( axisEvent )
    end
  
    self.lastDir = self.dir
    self.originX = posX

		return true
	end

	function moveRect:activate()
		moveRect:addEventListener( "touch", moveRect )
	end

	function moveRect:deactivate()
		stage:setFocus( nil, moveRect.eventID )
		moveRect:removeEventListener( "touch", moveRect )
	end
  

  
	function jumpRect:touch( event )
		local phase = event.phase
    local key = "buttonA"
		if phase == "began" then
      buttonManager(-1)
			if event.id then stage:setFocus( event.target, event.id ) end
			local keyEvent = { name = "key", phase = "down", keyName = key or "none" }
			Runtime:dispatchEvent( keyEvent )
		elseif phase=="ended" or phase == "canceled" then
      buttonManager(0)
			if event.id then stage:setFocus( nil, event.id ) end
			local keyEvent = { name = "key", phase = "up", keyName = key or "none" }
			Runtime:dispatchEvent( keyEvent )
		end
		return true
	end

	function jumpRect.activate()
		jumpRect:addEventListener( "touch" )
	end

	function jumpRect.deactivate()
		jumpRect:removeEventListener( "touch" )
	end

  dPadManager(0)
  buttonManager(0)

	moveRect:activate()
	jumpRect.activate()
  
  
  return instance
  
end

--[[



function M.newStick( startAxis, innerRadius, outerRadius )

	startAxis = startAxis or 1
	innerRadius, outerRadius = innerRadius or 64, outerRadius or 96
	local instance = display.newGroup()

	local outerArea
	if type( outerRadius ) == "number" then
		outerArea = display.newCircle( instance, 0,0, outerRadius )
		outerArea.strokeWidth = 8
		outerArea:setFillColor( 0.2, 0.2, 0.2, 0.9 )
		outerArea:setStrokeColor( 1, 1, 1, 1 )
	else
		outerArea = display.newImage( outerRadius, 192, 192)
    outerArea.x = 128
    outerArea.y = display.contentHeight - 128
		outerRadius = ( outerArea.contentWidth + outerArea.contentHeight ) * 0.25
	end

	local joystick
	if type( innerRadius ) == "number" then
		joystick = display.newCircle( instance, 0,0, innerRadius )
		joystick:setFillColor( 0.4, 0.4, 0.4, 0.3 )
		joystick.strokeWidth = 4
		joystick:setStrokeColor( 1, 0, 0.25, 0.5 )
	else
		joystick = display.newImage( instance, innerRadius, 0, 0 )
		innerRadius = ( joystick.contentWidth + joystick.contentHeight ) * 0.25
	end

	-- Where should joystick motion be stopped?
	local stopRadius = outerRadius - innerRadius

	function joystick:touch( event )
		local phase = event.phase
		if phase=="began" or ( phase=="moved" and self.isFocus ) then
			if phase == "began" then
				stage:setFocus( event.target, event.id )
				self.eventID = event.id
				self.isFocus = true
			end
			local parent = self.parent
			local posX, posY = parent:contentToLocal( event.x, event.y )
			local angle = -math.atan2( posY, posX )
			local distance = math.sqrt( (posX*posX) + (posY*posY) )

			if ( distance >= stopRadius ) then
        --system.vibrate() -- can we use haptic here to give a sense of joystick edge?

				distance = stopRadius
				self.x = distance * math.cos(angle)
				self.y = -distance * math.sin(angle)
			else
				self.x = posX
				self.y = posY
			end
		else
			self.x = 0
			self.y = 0
			stage:setFocus( nil, event.id )
			self.isFocus = false
		end
		
		instance.axisX = self.x / stopRadius
		instance.axisY = self.y / stopRadius
		local axisEvent
		if not ( self.y == ( self._y or 0 ) ) then
			axisEvent = { name = "axis", axis = { number = startAxis }, normalizedValue = instance.axisX }
			Runtime:dispatchEvent( axisEvent )
		end
		if not ( self.x == ( self._x or 0 ) ) then
			axisEvent = { name = "axis", axis = { number = startAxis+1 }, normalizedValue = instance.axisY }
			Runtime:dispatchEvent( axisEvent )
		end
		self._x, self._y = self.x, self.y
		return true
	end

	function instance:activate()
		self:addEventListener( "touch", joystick )
		self.axisX = 0
		self.axisY = 0
	end

	function instance:deactivate()
		stage:setFocus( nil, joystick.eventID )
		joystick.x, joystick.y = outerArea.x, outerArea.y
		self:removeEventListener( "touch", self.joystick )
		self.axisX = 0
		self.axisY = 0
	end

	instance:activate()
	return instance
end

]]--
return M
