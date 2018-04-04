-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

 local physics = require( "physics" )
 physics.start()
 physics.setGravity( 0, 0 )


 math.randomseed( os.time() )


 local sheetOptions =
 {
      frames =
      {
           {  -- 1) asteroid 1
              x = 0,
              y = 0,
              width = 102,
              height = 85
          },
          {  -- 2) asteroid 2
             x = 0,
             y = 85,
             width = 100,
             height = 97
          },
          {  --3) asteroid 3
             x = 0,
             y = 168,
             width = 100,
             height = 97
         },
         {  -- 4) ship
           x = 0,
           y = 265,
           width = 98,
           height = 79
       },
       { --5) laser
          x = 98,
         y = 265,
         width = 14,
         height = 40
       },
   },
}
local objectSheet = graphics.newImageSheet( "gameObject.png", sheetOptions )

-- Initialize variables
local lives = 3
local score = 0
local died = false

local asteroidsTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText

-- Set up diplay groups
local backGroup = display.newGroup()  -- Display GROUP FOR THE BACKGROUND
local mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
local uigroup = display.newGroup()   -- Display group for UI on=bjects like the store

-- Load the background
local background = display.newImageRect
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImageRect( mainGroup, objectSheet, 4, 98, 79 )
ship.x = display.contentCenterX
ship.Y = display.contentHeight - 100
physics.addBody( ship, { radius=30, isSensor=true } )
ship.myName = "ship"

-- Display lives and score
livesText = display.newText( uiGroup, "Lives; " .. lives, 200, 80, native.systemFont, 36 )
scoreText = display.newText( uiGroup, "Score " .. score, 400, 80, native.systemFont, 36 )

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )


local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end


local function createAsteroid()

    local newAsteroid = display.newImageRect( mainGroup, objectSheet, 1, 102, 85 )
    table.insert( asteroidsTable, newAsteroid )
     physics.addBody( newAsteroid, "dynamic", { radius=40, bounce=0.8 } )
     newAsteroid.myName = "asteroid"

     local whereFrom = math.random( 3 )

     if ( whereFrom == 1 ) then
         -- From the left
         newAsteroid.x = -60
         newAsteroid.Y = math.random( 500 )
         newAsteroid:setLinearVelocity( math.random( 40,120 ), math.random( 20,60 ) )
     elseif ( whereFrom == 2 ) then
         -- From the top
         newAsteroid.x = math.random( display.contentWidth )
         newAsteroid.y = -60
         newAsteroid:setLinearVelocity( math.random( -40,40 ), math.random( 40,120) )
    elseif ( whereFrom == 3 ) then
        -- From the right
        newAsteroid.x = display.content
        newAsteroid.y = math.random( 500 )
        newAsteroid:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
    end

    newAsteroid:applyTorque( math.random( -6,6 ) )
end


local function fireLaser()

    local newLaser = display.newImageRect( mainGroup, objectSheet, 5, 14, 40 )
    phsyics.addBody( newLaser, "dynamic", {isSensor=truw } )
    newLaser.isBullet = true
    newLaser.myName = "laser"

    newLaser.x = ship.x
    newLaser.y = ship.y
    newlaser:toBack()

    transition.to( newLaser, { y=-40, time=500,
        onComplete = function() display.remove( newLaser ) end
    } )
end

ship:addEventListener( "tap", fireLaser )


local function dragShip( event )

    local ship = event.target
    local phase = event.phase

    if ( "began" == phase ) then
        -- Set touch focus on the ship
        display.currentStage:setFocus( ship )
        -- Store initial offset position
        ship.touchOffsetX = event.x - ship.x

    elseif ( "moved" == phase ) then
        -- Move the ship to the new touch position
        ship.x = event.x - ship.touchOffsetX
    end
  elseif ( "ended" == phase or "cancelled" == phase ) then
      -- Release touch focus on the ship
      display.currentStage:setFocus( nil )
  end

  return true -- Prevents touch propagation to underlying objects
end

ship:addEventListener( "touch", dragShip)
