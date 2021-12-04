function createFlipper(data, anchorBody)
    local w = 120
    local h = 32
    local vertices = {}
    local pivot = {}

    if data.orientation == "right" then
        vertices = {
            [1] = 59.4,
            [2] = 15.84,
            [3] = 59.4,
            [4] = -15.84,
            [5] = -59.4,
            [6] = -7.92,
            [7] = -59.4,
            [8] = 7.92
        }
        pivot = {
            ["y"] = 0,
            ["x"] = 59.4
        }
    else
        vertices = {
            [1] = 59.4,
            [2] = 7.92,
            [3] = 59.4,
            [4] = -7.92,
            [5] = -59.4,
            [6] = -15.84,
            [7] = -59.4,
            [8] = 15.84
        }
        pivot = {
            ["y"] = 0,
            ["x"] = -59.4
        }
    end

    local flip = {}
    flip.data = data
    flip.body = love.physics.newBody(world, data.x, data.y, "dynamic")
    flip.shape = love.physics.newPolygonShape(unpack(vertices))
    flip.fixture = love.physics.newFixture(flip.body, flip.shape, 1.5)
    flip.fixture:setRestitution(0)
    -- flip.fixture:setUserData(flip.data)
    -- Revolute Joint + Motor
    flip.joint = love.physics.newRevoluteJoint(anchorBody, flip.body, data.x + pivot.x, data.y + pivot.y, false)
    -- flip.joint:setMotorSpeed(200)
    -- flip.joint:setMotorEnabled(true)
    -- Limit movement
    local limitA = data.orientation == "left" and 5 or 30
    local limitB = data.orientation == "right" and 5 or 30
    flip.joint:setLimits(math.rad(-limitA), math.rad(limitB))
    flip.joint:setLimitsEnabled(true)
    flip.orientation = data.orientation
    flip.pivot = pivot
    local polyW, polyH = getPolySize(vertices)
    flip.origin = {
        x = polyW / 2,
        y = polyH / 2
    }

    --- add to entities
    table.insert(entities.flippers, flip)
end

function createBall(x, y)
    local ball = {}
    ball.data = {
        type = "ball",
        id = string.format("%x", os.time()),
        cooldown = 0
    }
    ball.body = love.physics.newBody(world, x, y, "dynamic")
    ball.body:setBullet(true)
    ball.shape = love.physics.newCircleShape(16)
    ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1)
    ball.fixture:setUserData(ball.data)
    ball.fixture:setRestitution(0.2)
    table.insert(entities.balls, ball)
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
