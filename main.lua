function love.load()
    -- io.output(io.stdout)
    io.stdout:setvbuf("no")

    debugText = ""

    require("entities.create")
    require("entities.event")
    require("entities.globals")
    require("GPIO")

    gameWidth, gameHeight = love.graphics.getDimensions()

    platformCheck = package.config:sub(1, 1)

    if platformCheck == "/" then
        -- RASPI 

        love.window.setMode(800, 480)
        -- blinkTimer = 0
        -- leftIsDown, rightIsDown, led = false, false, false
        -- GPIO.setMode(17, "output")
        -- GPIO.setMode(18, "pullup")
        -- GPIO.setMode(19, "pullup")
        -- GPIO.set(17, false)
    end

    love.physics.setMeter(PIXEL_PER_METER)
    world = love.physics.newWorld(0, GRAVITY * PIXEL_PER_METER, true)
    world:setCallbacks(beginContact)
    -- world:setContactFilter(contactFilter)

    score = 0

    entities = {}

    entities.grounds = {}
    for i = 1, 6 do
        entities.grounds[i] = {}
    end
    entities.grounds[1].body = love.physics.newBody(world, gameWidth / 2, gameHeight - 10 / 2)
    entities.grounds[1].shape = love.physics.newRectangleShape(gameWidth, 10)
    entities.grounds[1].fixture = love.physics.newFixture(entities.grounds[1].body, entities.grounds[1].shape)

    entities.grounds[2].body = love.physics.newBody(world, gameWidth / 2, 10 / 2)
    entities.grounds[2].shape = love.physics.newRectangleShape(gameWidth, 10)
    entities.grounds[2].fixture = love.physics.newFixture(entities.grounds[2].body, entities.grounds[2].shape)

    entities.grounds[3].body = love.physics.newBody(world, 10 / 2, gameHeight / 2)
    entities.grounds[3].shape = love.physics.newRectangleShape(10, gameHeight)
    entities.grounds[3].fixture = love.physics.newFixture(entities.grounds[3].body, entities.grounds[3].shape)

    entities.grounds[4].body = love.physics.newBody(world, gameWidth - 10 / 2, gameHeight / 2)
    entities.grounds[4].shape = love.physics.newRectangleShape(10, gameHeight)
    entities.grounds[4].fixture = love.physics.newFixture(entities.grounds[4].body, entities.grounds[4].shape)

    entities.grounds[5].body = love.physics.newBody(world, 45, gameHeight - 50)
    entities.grounds[5].shape = love.physics.newRectangleShape(10, gameHeight / 4)
    entities.grounds[5].fixture = love.physics.newFixture(entities.grounds[5].body, entities.grounds[5].shape)

    entities.grounds[6].body = love.physics.newBody(world, gameWidth - 45, gameHeight - 50)
    entities.grounds[6].shape = love.physics.newRectangleShape(10, gameHeight / 4)
    entities.grounds[6].fixture = love.physics.newFixture(entities.grounds[6].body, entities.grounds[6].shape)

    entities.block1 = {}
    entities.block1.body = love.physics.newBody(world, 120, 350)
    entities.block1.body:setAngle(4)
    entities.block1.shape = love.physics.newRectangleShape(0, 0, 150, 25)
    entities.block1.fixture = love.physics.newFixture(entities.block1.body, entities.block1.shape, 5)

    -- entities.block2 = {}
    -- entities.block2.body = love.physics.newBody(world, 300, 400)
    -- entities.block2.shape = love.physics.newRectangleShape(0, 0, 100, 50)
    -- entities.block2.fixture = love.physics.newFixture(entities.block2.body, entities.block2.shape, 2)

    entities.flippers = {}
    local anchorBody = love.physics.newBody(world, 0, 0)
    createFlipper({
        x = 120,
        y = gameHeight - 100,
        orientation = "left"
    }, anchorBody)
    createFlipper({
        x = gameWidth - 120,
        y = gameHeight - 100,
        orientation = "right"
    }, anchorBody)
    entities.balls = {}

    entities.bumpers = {}
    createBumper(gameWidth / 2 - 100, 150, 20)
    createBumper(gameWidth / 2 + 100, 150, 20)
    createBumper(gameWidth / 2, 200, 20)
    createBumper(gameWidth / 2 - 50, 300, 30)
    createBumper(gameWidth / 2 + 50, 300, 30)
    createBumper(gameWidth / 2 - 150, 500, 20, gameWidth / 2 + 150, 400)

    entities.kickers = {}
    createKicker(gameWidth - 60, gameHeight / 2 + 200, "left")
    createKicker(60, gameHeight / 2 + 200, "right")

    love.graphics.setBackgroundColor(0.41, 0.53, 0.97)
end

function love.update(dt)
    world:update(dt)

    debugText = ""

    -- if platformCheck == "/" then
    --     -- RASPI
    --     if blinkTimer >= 1 then
    --         blinkTimer = 0
    --         led = not led
    --         if led then
    --             GPIO.set(17, true)
    --         else
    --             GPIO.set(17, false)
    --         end
    --     else
    --         blinkTimer = blinkTimer + dt
    --     end

    --     if not GPIO.get(18) then
    --         if not leftIsDown then
    --             leftIsDown = true
    --             moveLeftFlippers()
    --         end
    --     else
    --         if leftIsDown then
    --             leftIsDown = false
    --             releaseLeftFlippers()
    --         end
    --     end

    --     if not GPIO.get(19) then
    --         if not rightIsDown then
    --             rightIsDown = true
    --             moveRightFlippers()
    --         end
    --     else
    --         if rightIsDown then
    --             rightIsDown = false
    --             releaseRightFlippers()
    --         end
    --     end

    -- end

    -- UPDATE BUMPER COOLDOWN
    for _, v in pairs(entities.bumpers) do
        if (v.hitCooldown > 0) then
            v.hitCooldown = v.hitCooldown - dt
        end
    end

    -- NUDGE FROM LEFT
    if love.keyboard.isDown("up") then
        for _, ball in pairs(entities.balls) do
            ball.body:applyForce(50, 0)
        end
    end
    -- NUDGE FROM RIGHT
    if love.keyboard.isDown("down") then
        for _, ball in pairs(entities.balls) do
            ball.body:applyForce(-50, 0)
        end
    end

    -- Handle flipper interaction
    for _, flip in pairs(entities.flippers) do
        if flip.torque then
            flip.body:applyTorque(flip.torque)
        end
    end

    -- UPDATE MOVING BUMPER VEL
    for _, bump in pairs(entities.bumpers) do
        if bump.data.toX ~= nil and bump.data.toY ~= nil then
            local x, y = bump.body:getPosition()

            local dist = 0
            local ACCURACY = 0.50
            if bump.data.yoyo then
                dist = math.sqrt((bump.data.toX - x) ^ 2 + (bump.data.toY - y) ^ 2)
            else
                dist = math.sqrt((bump.data.fromX - x) ^ 2 + (bump.data.fromY - y) ^ 2)
            end

            if dist < ACCURACY then
                bump.data.yoyo = not bump.data.yoyo
            end

            local a = 0
            if bump.data.yoyo then
                a = getAngleBetween(x, y, bump.data.toX, bump.data.toY)
            else
                a = getAngleBetween(x, y, bump.data.fromX, bump.data.fromY)
            end

            local vx = -math.cos(a) * bump.data.speed
            local vy = -math.sin(a) * bump.data.speed

            bump.body:setLinearVelocity(vx, vy)
        end
    end

    debugText = debugText .. "FPS :: " .. love.timer.getFPS()
    for i, ball in ipairs(entities.balls) do
        local vx, vy = ball.body:getLinearVelocity()
        if vx > MAX_BALL_SPEED or vx < -MAX_BALL_SPEED or vy > MAX_BALL_SPEED or vy < -MAX_BALL_SPEED then
            if vx > MAX_BALL_SPEED then
                vx = MAX_BALL_SPEED
            elseif vx < -MAX_BALL_SPEED then
                vx = -MAX_BALL_SPEED
            end
            if vy > MAX_BALL_SPEED then
                vy = MAX_BALL_SPEED
            elseif vy < -MAX_BALL_SPEED then
                vy = -MAX_BALL_SPEED
            end
            ball.body:setLinearVelocity(vx, vy)
        end
    end
    debugText = debugText .. "\nSCORE :: " .. score

end

function love.draw()

    if platformCheck == "/" then
        love.graphics.translate(gameWidth / 2, gameHeight / 2)
        love.graphics.rotate(-math.pi / 2)
        love.graphics.translate(-gameHeight / 2, -gameWidth / 2)
    end

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

    for _, flip in pairs(entities.flippers) do
        love.graphics.polygon("fill", flip.body:getWorldPoints(flip.shape:getPoints()))
    end

    love.graphics.setColor(0.76, 0.18, 0.05)
    for _, bump in pairs(entities.bumpers) do

        love.graphics.circle("fill", bump.body:getX(), bump.body:getY(), bump.shape:getRadius())
        -- local bumper = self.bumpers[tag]
        -- if (bump) then
        -- local scaleX = bump.flipX
        -- local scaleY = bump.flipY
        -- draw larger after a hit
        -- if (bump.hitCooldown > 0) then
        --     scaleX = bump.flipX * 1.1
        --     scaleY = bump.flipY * 1.1
        -- end
        -- love.graphics.draw(bumper.image, x, y, 0, scaleX, scaleY, bumper.ox, bumper.oy)
        -- end
    end
    for _, kick in pairs(entities.kickers) do
        love.graphics.setColor(0.28, 0.63, 0.05)
        love.graphics.polygon("fill", kick.body:getWorldPoints(kick.shape:getPoints()))
        love.graphics.setColor(0.58, 0.1, 0.1)
        love.graphics.polygon("fill", kick.body_string:getWorldPoints(kick.shape_string:getPoints()))
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(debugText, 20, 20)
end

function love.keypressed(key)
    if (key == "escape") then
        love.event.quit()
    elseif (key == "space") then
        createBall(240 - 5 + math.random(0, 10), 50)
    end
    if (key == "left") then
        moveLeftFlippers()
    end
    if (key == "right") then
        moveRightFlippers()
    end
end

function love.keyreleased(key)
    if (key == "left") then
        releaseLeftFlippers()
    end
    if (key == "right") then
        releaseRightFlippers()
    end
end
