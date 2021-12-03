function love.load()
	io.stdout:setvbuf("no")
	local GPIO = require('periphery').GPIO
	
    local gpio_out = GPIO("/dev/gpiochip0", 17, "out")
    gpio_out:write(true)
    gpio_out:close()

	gameWidth, gameHeight = love.graphics.getDimensions()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	-- world:setCallbacks(beginContact)
	-- world:setContactFilter(contactFilter)

	entities = {}
	pin7 = nil

	entities.grounds = {}
	for i=1,4 do
		entities.grounds[i] = {}
	end
	entities.grounds[1].body = love.physics.newBody(world, gameWidth/2, gameHeight-10/2)
	entities.grounds[1].shape = love.physics.newRectangleShape(gameWidth, 10)
	entities.grounds[1].fixture = love.physics.newFixture(entities.grounds[1].body, entities.grounds[1].shape)

	entities.grounds[2].body = love.physics.newBody(world, gameWidth/2, 10/2)
	entities.grounds[2].shape = love.physics.newRectangleShape(gameWidth, 10)
	entities.grounds[2].fixture = love.physics.newFixture(entities.grounds[2].body, entities.grounds[2].shape)

	entities.grounds[3].body = love.physics.newBody(world, 10/2, gameHeight/2)
	entities.grounds[3].shape = love.physics.newRectangleShape(10, gameHeight)
	entities.grounds[3].fixture = love.physics.newFixture(entities.grounds[3].body, entities.grounds[3].shape)

	entities.grounds[4].body = love.physics.newBody(world, gameWidth-10/2, gameHeight/2)
	entities.grounds[4].shape = love.physics.newRectangleShape(10, gameHeight)
	entities.grounds[4].fixture = love.physics.newFixture(entities.grounds[4].body, entities.grounds[4].shape)

	entities.block1 = {}
	entities.block1.body = love.physics.newBody(world, 200, 250)
	entities.block1.shape = love.physics.newRectangleShape(0, 0, 150, 100)
	entities.block1.fixture = love.physics.newFixture(entities.block1.body, entities.block1.shape, 5)

	entities.block2 = {}
	entities.block2.body = love.physics.newBody(world, 300, 400)
	entities.block2.shape = love.physics.newRectangleShape(0, 0, 100, 50)
	entities.block2.fixture = love.physics.newFixture(entities.block2.body, entities.block2.shape, 2)

	entities.flippers = {}
	local anchorBody = love.physics.newBody(world, 0, 0)
	createFlipper({x=100, y=gameHeight - 100, orientation="left"}, anchorBody)
	createFlipper({x=gameWidth - 100, y=gameHeight - 100, orientation="right"}, anchorBody)
	entities.balls = {}

	love.graphics.setBackgroundColor(0.41, 0.53, 0.97)
end

function love.update(dt)
	world:update(dt)

	-- LATER :: NUDGE
	if love.keyboard.isDown("up") then
		for _,ball in pairs(entities.balls) do
			ball.body:applyForce(400, 0)
		end
	end

    -- Handle flipper interaction
    for _, flip in pairs(entities.flippers) do
    	if (flip.torque) then
    		flip.body:applyTorque(flip.torque)
    	end
    end
end


function love.draw()
	love.graphics.setColor(0.28, 0.63, 0.05)
	for _, wall in pairs(entities.grounds) do
		love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
	end

	love.graphics.setColor(0.76, 0.18, 0.05)
	for _, ball in pairs(entities.balls) do
		love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
	end

	love.graphics.setColor(0.20, 0.20, 0.20) 
	love.graphics.polygon("fill", entities.block1.body:getWorldPoints(entities.block1.shape:getPoints()))
	love.graphics.polygon("fill", entities.block2.body:getWorldPoints(entities.block2.shape:getPoints()))

	for _, flip in pairs(entities.flippers) do
		love.graphics.polygon("fill", flip.body:getWorldPoints(flip.shape:getPoints()))
	end

end

function love.keypressed(key)
	if (key == "escape") then
		love.event.quit()
	elseif (key == "space") then
		createBall(120,50)
	end
	if (key == "left") then moveLeftFlippers() end
	if (key == "right") then moveRightFlippers() end
end

function love.keyreleased(key)
	if (key == "left") then releaseLeftFlippers() end
	if (key == "right") then releaseRightFlippers() end
end

function createFlipper (data, anchorBody)
	local w = 120
	local h = 32
	local vertices = {}
	local pivot = {}

	if data.orientation == "right" then 
		vertices = {
			[1]=59.4,
			[2]=15.84,
			[3]=59.4,
			[4]=-15.84,
			[5]=-59.4,
			[6]=-7.92,
			[7]=-59.4,
			[8]=7.92,
		}
		pivot = {
			["y"]=0,
			["x"]=59.4
		}
	else
		vertices ={
			[1]=59.4,
			[2]=7.92,
			[3]=59.4,
			[4]=-7.92,
			[5]=-59.4,
			[6]=-15.84,
			[7]=-59.4,
			[8]=15.84
		}
		pivot = {
			["y"]=0,
			["x"]=-59.4
		}
	end

	local flip = { }
	flip.data = data
	flip.body = love.physics.newBody(world, data.x, data.y, "dynamic")
	flip.shape = love.physics.newPolygonShape(unpack(vertices))
	flip.fixture = love.physics.newFixture(flip.body, flip.shape, 1.5)
	flip.fixture:setRestitution(0)
	-- flip.fixture:setUserData(flip.data)
    -- Revolute Joint + Motor
    flip.joint = love.physics.newRevoluteJoint(anchorBody, flip.body, data.x + pivot.x, data.y + pivot.y, false)
    --flip.joint:setMotorSpeed(200)
    --flip.joint:setMotorEnabled(true)
    -- Limit movement
    local limitA = data.orientation == "left" and 5 or 30
    local limitB = data.orientation == "right" and 5 or 30
    flip.joint:setLimits(math.rad(-limitA), math.rad(limitB))
    flip.joint:setLimitsEnabled(true)
    flip.orientation = data.orientation
    flip.pivot = pivot
    local polyW, polyH = getPolySize(vertices)
    flip.origin = {x=polyW/2, y=polyH/2}

    --- add to entities
    table.insert(entities.flippers, flip)
end

function createBall (x, y)
	local ball = { }
	ball.data = {
		type="ball",
		id=string.format("%x", os.time()),
		cooldown=0
	}
	ball.body = love.physics.newBody(world, x, y, "dynamic")
	ball.body:setBullet(true)
	ball.shape = love.physics.newCircleShape(16)
	ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
	ball.fixture:setUserData(ball.data)
	ball.fixture:setRestitution(0.2)
	table.insert(entities.balls, ball)
end



function getPolySize (vertices)
	local minx, maxx, miny, maxy = vertices[1], vertices[1], vertices[2], vertices[2]
	for i = 1, #vertices - 1, 2 do
		minx = math.min(minx, vertices[i])
		maxx = math.max(maxx, vertices[i])
		miny = math.min(miny, vertices[i+1])
		maxy = math.max(maxy, vertices[i+1])
	end

	return maxx-minx, maxy-miny
end


-- Filter which objects collide with each other.
function contactFilter (a, b)
	local ball, ballDef, solid, solidDef = separateSolids(a, b)

    -- Not a ball collision.
    if (not ball) then
    	return true
    end

    -- Gates restrict the ball movement from certain directions
    if (solidDef.type == "gate") then
    	local xvel, yvel = ball:getLinearVelocity()
    	if (solidDef.action == "left" and xvel < 0) then return false end
    	if (solidDef.action == "right" and xvel > 0) then return false end
    end

    return true
end

function beginContact (a, b, c)
	local ball, ballDef, solid, solidDef = separateSolids(a, b)

    -- Not a ball collision.
    if (not ball) then
    	return true
    end

    -- Tagged collisions
    if (solidDef.tag and pinball.tagContact) then
    	local isActive = ball:isActive()
    	local isCool = ballDef.cooldown < 0
    	if (isActive and isCool) then
    		ballDef.cooldown = solidDef.cooldown and tonumber(solidDef.cooldown) or pinball.cfg.ballCooldown
    		pinball.tagContact(solidDef.tag, ballDef.id)
    	end
    end

    -- Triggers
    if (solidDef.type == "trigger") then
    	if (solidDef.action == "slingshot") then
    		ball:setLinearVelocity(0, -1000)
    	end
    end

    -- Ball drained
    if (solidDef.type == "drain") then
    	ball:setUserData({action="destroy"})
    end
end

-- Separate balls from solids.
-- Returns [ball body], [ball definition], [solid body], [solid definition]
function separateSolids (a, b)
	local aa=a:getUserData() or { }
	local bb=b:getUserData() or { }
	if (aa.type == "ball") then
		return a:getBody(), aa, b:getBody(), bb
	elseif (bb.type == "ball") then
		return b:getBody(), bb, a:getBody(), aa
	end
end


function moveLeftFlippers()
	for _, flip in pairs(entities.flippers) do
		if (flip.orientation == "left") then
			flip.torque = -2000000
		end
	end
end

function releaseLeftFlippers()
	for _, flip in pairs(entities.flippers) do
		if (flip.orientation == "left") then
			flip.body:applyTorque(2000000)
			flip.torque = nil
		end
	end
end

function moveRightFlippers()
	for _, flip in pairs(entities.flippers) do
		if (flip.orientation == "right") then
			flip.torque = 2000000
		end
	end
end

function releaseRightFlippers()
	for _, flip in pairs(entities.flippers) do
		if (flip.orientation == "right") then
			flip.body:applyTorque(-2000000)
			flip.torque = nil
		end
	end
end