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
    flip.fixture:setUserData(flip.data)
    -- Revolute Joint + Motor
    flip.joint = love.physics.newRevoluteJoint(anchorBody, flip.body, data.x + pivot.x, data.y + pivot.y, false)
    flip.joint:setMotorSpeed(200)
    flip.joint:setMotorEnabled(true)
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
    ball.fixture:setRestitution(BALL_BOUNCE)
    table.insert(entities.balls, ball)
end

function createBumper(x, y, r, toX, toY)
    local kickforce = r / 10
    local bumperForces = {
        min = 1,
        max = 4
    }
    local bump = {}
    bump.data = {
        type = "bumper",
        id = string.format("%x", os.time()),
        score = 10 * r,
        fromX = x,
        fromY = y,
        toX = toX,
        toY = toY,
        speed = 100,
        yoyo = true
    }
    bump.hitCooldown = 0.1
    bump.body = love.physics.newBody(world, x, y, "kinematic")
    bump.shape = love.physics.newCircleShape(r)
    bump.fixture = love.physics.newFixture(bump.body, bump.shape, 1)
    bump.fixture:setUserData(bump.data)
    kickforce = clamp(bumperForces, kickforce)
    bump.fixture:setRestitution(kickforce / 2)
    table.insert(entities.bumpers, bump)
end

function createKicker(x, y, orientation)
    local kick = {}
    kick.data = {
        type = "kicker",
        id = string.format("%x", os.time()),
        orientation = orientation,
        score = 500
    }
    kick.hitCooldown = 0.1
    local vertices, vertices_string
    if orientation == "right" then
        vertices = {
            [1] = 28,
            [2] = 45,
            [3] = -18,
            [4] = -52,
            [5] = -28,
            [6] = 24,
            [7] = 28,
            [8] = 45
        }
        vertices_string = {
            [1] = -18,
            [2] = -48,
            [3] = 28,
            [4] = 41,
            [5] = 30,
            [6] = 41,
            [7] = -16,
            [8] = -48
        }
    else
        vertices = {
            [1] = -28,
            [2] = 45,
            [3] = 18,
            [4] = -52,
            [5] = 28,
            [6] = 24,
            [7] = -28,
            [8] = 45
        }
        vertices_string = {
            [1] = 18,
            [2] = -48,
            [3] = -28,
            [4] = 41,
            [5] = -30,
            [6] = 41,
            [7] = 16,
            [8] = -48
        }
    end
    kick.body = love.physics.newBody(world, x, y, "kinematic")
    kick.shape = love.physics.newChainShape(false, unpack(vertices))
    kick.fixture = love.physics.newFixture(kick.body, kick.shape, 1)
    kick.body_string = love.physics.newBody(world, x, y, "kinematic")
    kick.shape_string = love.physics.newChainShape(false, unpack(vertices_string))
    kick.fixture_string = love.physics.newFixture(kick.body, kick.shape, 1)
    kick.fixture_string:setRestitution(1)
    kick.fixture:setUserData(kick.data)
    table.insert(entities.kickers, kick)
end

function moveLeftFlippers()
    for _, flip in pairs(entities.flippers) do
        if (flip.orientation == "left") then
            flip.torque = -FLIPPER_TORQUE
        end
    end
end

function releaseLeftFlippers()
    for _, flip in pairs(entities.flippers) do
        if (flip.orientation == "left") then
            flip.body:applyTorque(FLIPPER_TORQUE)
            flip.torque = nil
        end
    end
end

function moveRightFlippers()
    for _, flip in pairs(entities.flippers) do
        if (flip.orientation == "right") then
            flip.torque = FLIPPER_TORQUE
        end
    end
end

function releaseRightFlippers()
    for _, flip in pairs(entities.flippers) do
        if (flip.orientation == "right") then
            flip.body:applyTorque(-FLIPPER_TORQUE)
            flip.torque = nil
        end
    end
end
