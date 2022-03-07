function createFlipper(data, anchorBody)
    -- local w = 120
    -- local h = 32
    local vertices = {}
    local pivot = {}

    data.sprite = love.graphics.newImage("assets/sprites/flipper.png")

    if data.orientation == "right" then
        vertices = {
            [1] = 40,
            [2] = 10,
            [3] = 40,
            [4] = -10,
            [5] = -40,
            [6] = -5,
            [7] = -40,
            [8] = 5
        }
        pivot = {
            ["y"] = 0,
            ["x"] = 40
        }
    else
        vertices = {
            [1] = 40,
            [2] = 5,
            [3] = 40,
            [4] = -5,
            [5] = -40,
            [6] = -10,
            [7] = -40,
            [8] = 10
        }
        pivot = {
            ["y"] = 0,
            ["x"] = -40
        }
    end

    local flip = {}
    flip.data = data
    flip.body = love.physics.newBody(world, data.x, data.y, "dynamic")
    flip.shape = love.physics.newPolygonShape(unpack(vertices))
    flip.fixture = love.physics.newFixture(flip.body, flip.shape, 1.5)
    flip.fixture:setRestitution(0)
    flip.fixture:setUserData(flip.data)

    flip.joint = love.physics.newRevoluteJoint(anchorBody, flip.body, data.x + pivot.x, data.y + pivot.y, false)
    -- flip.joint:setMotorSpeed(200)
    -- flip.joint:setMotorEnabled(true)

    local limitA = data.orientation == "left" and 10 or 30
    local limitB = data.orientation == "right" and 10 or 30
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
        cooldown = 0,
        toTeleport = nil,
        toDestroy = false
    }
    ball.body = love.physics.newBody(world, x, y, "dynamic")
    ball.body:setBullet(true)
    ball.shape = love.physics.newCircleShape(BALL_SIZE)
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

function createTrigger(x, y)
    local trigg = {}
    trigg.data = {
        type = "trigger",
        id = string.format("%x", os.time()),
        score = 250,
        active = false
    }
    trigg.body = love.physics.newBody(world, x, y)
    trigg.shape = love.physics.newCircleShape(16)
    trigg.fixture = love.physics.newFixture(trigg.body, trigg.shape, 1)
    trigg.fixture:setUserData(trigg.data)
    trigg.fixture:setSensor(true)
    table.insert(entities.triggers, trigg)
end
function createSlingshot(x, y)
    local sling = {}
    sling.data = {
        type = "slingshot",
        id = string.format("%x", os.time()),
        cooldown = 500,
        active = false
    }
    sling.body = love.physics.newBody(world, x, y, "dynamic")
    sling.body:setFixedRotation(true)
    sling.shape = love.physics.newRectangleShape(32, 16)
    sling.fixture = love.physics.newFixture(sling.body, sling.shape, 1)
    sling.fixture:setUserData(sling.data)

    local anchorBody = love.physics.newBody(world, x, y + 32)
    -- sling.joint = love.physics.newRevoluteJoint(anchorBody, sling.body, x, y + 16, false)
    -- local xa, ya = anchorBody:getPosition()
    sling.joint = love.physics.newRopeJoint(anchorBody, sling.body, x, y + 32, x, y, SLINGSHOT_LENGTH, true)
    -- sling.joint:setLimits(math.rad(0), math.rad(5))
    -- sling.joint:setLimitsEnabled(true)

    return sling
end
function createPortals(x1, y1, x2, y2)
    local portal1 = {}
    local portal2 = {}
    portal1.data = {
        type = "portal",
        id = string.format("%x", os.time()),
        score = 250,
        destination = {
            x = x2,
            y = y2
        },
        cooldown = 0
    }
    portal1.body = love.physics.newBody(world, x1, y1)
    portal1.shape = love.physics.newCircleShape(16)
    portal1.fixture = love.physics.newFixture(portal1.body, portal1.shape, 1)
    portal1.fixture:setUserData(portal1.data)
    portal1.fixture:setSensor(true)

    portal2.data = {
        type = "portal",
        id = string.format("%x", os.time()),
        score = 250,
        destination = {
            x = x1,
            y = y1
        },
        cooldown = 0
    }
    portal2.body = love.physics.newBody(world, x2, y2)
    portal2.shape = love.physics.newCircleShape(16)
    portal2.fixture = love.physics.newFixture(portal2.body, portal2.shape, 1)
    portal2.fixture:setUserData(portal2.data)
    portal2.fixture:setSensor(true)

    table.insert(entities.portals, portal1)
    table.insert(entities.portals, portal2)
end
