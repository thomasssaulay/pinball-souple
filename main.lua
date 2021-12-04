function love.load()
    -- io.output(io.stdout)
    io.stdout:setvbuf("no")

    debugText = ""
    blinkTimer = 0
    leftIsDown, rightIsDown, led = false, false, false

    require("entities.create")
    require("entities.event")
    require("entities.globals")
    require("GPIO")

    platformCheck = package.config:sub(1, 1)

    if platformCheck == "/" then
        -- RASPI

        GPIO.setMode(17, "output")
        GPIO.setMode(18, "pulldown")
        GPIO.setMode(19, "pulldown")
        GPIO.set(17, false)

    end

    gameWidth, gameHeight = love.graphics.getDimensions()
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81 * 64, true)
    -- world:setCallbacks(beginContact)
    -- world:setContactFilter(contactFilter)

    entities = {}

    entities.grounds = {}
    for i = 1, 4 do
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
    createFlipper({
        x = 100,
        y = gameHeight - 100,
        orientation = "left"
    }, anchorBody)
    createFlipper({
        x = gameWidth - 100,
        y = gameHeight - 100,
        orientation = "right"
    }, anchorBody)
    entities.balls = {}

    love.graphics.setBackgroundColor(0.41, 0.53, 0.97)
end

function love.update(dt)
    world:update(dt)

    debugText = ""

    if platformCheck == "/" then
        -- RASPI
        if blinkTimer >= 1 then
            blinkTimer = 0
            led = not led
            if led then
                GPIO.set(17, true)
            else
                GPIO.set(17, false)
            end
        else
            blinkTimer = blinkTimer + dt
        end

        if GPIO.get(18) then
            if not leftIsDown then
                leftIsDown = true
                moveLeftFlippers()
            end
        else
            if leftIsDown then
                leftIsDown = false
                releaseLeftFlippers()
            end
        end
        if GPIO.get(19) then
            if not leftIsDown then
                leftIsDown = true
                moveLeftFlippers()
            end
        else
            if leftIsDown then
                leftIsDown = false
                releaseLeftFlippers()
            end
        end

    end

    debugText = debugText .. "FPS :: " .. love.timer.getFPS()

    -- NUDGE FROM LEFT
    if love.keyboard.isDown("up") then
        for _, ball in pairs(entities.balls) do
            ball.body:applyForce(400, 0)
        end
    end
    -- NUDGE FROM RIGHT
    if love.keyboard.isDown("down") then
        for _, ball in pairs(entities.balls) do
            ball.body:applyForce(-400, 0)
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
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(debugText, 20, 20)

end

function love.keypressed(key)
    if (key == "escape") then
        love.event.quit()
    elseif (key == "space") then
        createBall(240, 50)
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
