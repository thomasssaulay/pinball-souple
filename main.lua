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
    world:setContactFilter(contactFilter)

    score = 0

    entities = {}

    require("setup.table1")

end

function love.update(dt)

    if dt > 0.040 then
        return
    end

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

    -- UPDATE PORTALS COOLDOWN
    for _, v in pairs(entities.portals) do
        if (v.data.cooldown > 0) then
            v.data.cooldown = v.data.cooldown - dt
        end
    end

    -- NUDGE FROM LEFT
    if love.keyboard.isDown("up") then
        for _, ball in pairs(entities.balls) do
            ball.body:applyForce(NUDGE_FORCE, 0)
        end
    end
    -- NUDGE FROM RIGHT
    if love.keyboard.isDown("down") then
        for _, ball in pairs(entities.balls) do
            ball.body:applyForce(-NUDGE_FORCE, 0)
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

    -- BALL DESTRUCTIONS & SPEED LIMITATION
    for i, ball in ipairs(entities.balls) do

        if ball.data.toDestroy then
            -- entities.balls[i].body.release()
            -- entities.balls[i].body.destroy()
            -- table.remove(entities.balls, i)
            entities.balls[i] = nil
        else

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
            if ball.data.toTeleport ~= nil then
                ball.body:setPosition(ball.data.toTeleport.x, ball.data.toTeleport.y)
                ball.data.toTeleport = nil
            end

        end
    end

    debugText = debugText .. "FPS :: " .. love.timer.getFPS()
    debugText = debugText .. "\nSCORE :: " .. score
    debugText = debugText .. "\nBALLS :: " .. #entities.balls
    debugText = debugText .. "\nPORTAL 1 COOLDOWN :: " .. entities.portals[1].data.cooldown

    world:update(dt)

end

function love.draw()

    if platformCheck == "/" then
        love.graphics.translate(gameWidth / 2, gameHeight / 2)
        love.graphics.rotate(math.pi / 2)
        love.graphics.translate(-gameHeight / 2, -560)
    end

    love.graphics.setColor(0.28, 0.63, 0.05)
    for i, ground in pairs(entities.grounds) do
        love.graphics.polygon("fill", ground.body:getWorldPoints(ground.shape:getPoints()))
        if i == 8 then
            local sprite = love.graphics.newImage("assets/sprites/left_arch.png")
            local x, y = ground.body:getWorldPoints(ground.shape:getPoints())
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(sprite, x, y, 0, 1, 1, 0, 0)
        end
        if i == 9 then
            local sprite = love.graphics.newImage("assets/sprites/left_arch.png")
            local x, y = ground.body:getWorldPoints(ground.shape:getPoints())
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(sprite, x + sprite:getWidth(), y, 0, -1, 1, 0, 0)
        end

    end

    love.graphics.setColor(0.76, 0.18, 0.05)
    for _, ball in pairs(entities.balls) do
        love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
    end

    love.graphics.setColor(0.20, 0.20, 0.20)
    love.graphics.polygon("fill", entities.block1.body:getWorldPoints(entities.block1.shape:getPoints()))

    for _, flip in pairs(entities.flippers) do
        love.graphics.polygon("fill", flip.body:getWorldPoints(flip.shape:getPoints()))
        love.graphics.setColor(1, 1, 1)
        local d = flip.fixture:getUserData()
        local x, y = flip.body:getPosition()
        local a = flip.body:getAngle()
        -- if d.orientation == "left" then
        --     love.graphics.draw(d.sprite, x, y, a, 1, 1, d.sprite:getWidth() / 2, d.sprite:getHeight() / 2)
        -- else
        --     love.graphics.draw(d.sprite, x, y, a, -1, 1, d.sprite:getWidth() / 2, d.sprite:getHeight() / 2)
        -- end
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
    for _, trigg in pairs(entities.triggers) do
        local d = trigg.fixture:getUserData()
        if d.active then
            love.graphics.setColor(0.76, 0.18, 0.9)
        else
            love.graphics.setColor(0.76, 0.18, 0.4)
        end
        love.graphics.circle("fill", trigg.body:getX(), trigg.body:getY(), trigg.shape:getRadius())
    end
    for _, kick in pairs(entities.kickers) do
        love.graphics.setColor(0.28, 0.63, 0.05)
        love.graphics.polygon("fill", kick.body:getWorldPoints(kick.shape:getPoints()))
        love.graphics.setColor(0.58, 0.1, 0.1)
        love.graphics.polygon("fill", kick.body_string:getWorldPoints(kick.shape_string:getPoints()))
    end
    love.graphics.setColor(0.0, 0.75, 0.75)
    love.graphics.polygon("fill", entities.slingshot.body:getWorldPoints(entities.slingshot.shape:getPoints()))
    for _, portal in pairs(entities.portals) do
        love.graphics.circle("fill", portal.body:getX(), portal.body:getY(), portal.shape:getRadius())
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(debugText, 20, 20)
end

function love.keypressed(key)
    if (key == "escape") then
        love.event.quit()
    end
    if (key == "b") then
        createBall(gameWidth - 30, gameHeight - 96)
    end
    if (key == "space") then
        strainSlingshot()
    end
    if (key == "n") then
        for i, b in ipairs(entities.balls) do
            print(b.data.toDestroy)
        end
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
    if (key == "space") then
        releaseSlingshot()
    end
end
