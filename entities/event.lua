-- Filter which objects collide with each other.
function contactFilter(a, b)
    local ball, ballDef, solid, solidDef = separateSolids(a, b)

    -- Not a ball collision.
    if (not ball) then
        return true
    end

    -- Gates restrict the ball movement from certain directions
    if (solidDef.type == "gate") then
        local xvel, yvel = ball:getLinearVelocity()
        if (solidDef.action == "left" and xvel < 0) then
            return false
        end
        if (solidDef.action == "right" and xvel > 0) then
            return false
        end
    end

    return true
end

function beginContact(a, b, c)
    local ball, ballDef, solid, solidDef = separateSolids(a, b)

    -- Not a ball collision.
    if not ball then
        return true
    end

    if solidDef.type == "bumper" or solidDef.type == "kicker" or solidDef.type == "trigger" or solidDef.type == "portal" then
        score = score + solidDef.score
    end

    -- -- Tagged collisions
    -- if (solidDef.tag and pinball.tagContact) then
    --     local isActive = ball:isActive()
    --     local isCool = ballDef.cooldown < 0
    --     if (isActive and isCool) then
    --         ballDef.cooldown = solidDef.cooldown and tonumber(solidDef.cooldown) or pinball.cfg.ballCooldown
    --         pinball.tagContact(solidDef.tag, ballDef.id)
    --     end
    -- end

    -- Triggers
    -- if (solidDef.type == "trigger") then
    --     if (solidDef.action == "slingshot") then
    --         ball:setLinearVelocity(0, -1000)
    --     end
    -- end

    -- triggers
    if solidDef.type == "trigger" then
        solidDef.active = not solidDef.active
        checkAllTriggers()
    end

    -- portals
    if (solidDef.type == "portal") then
        if solidDef.cooldown <= 0 then
            for _, portals in ipairs(entities.portals) do
                solidDef.cooldown = PORTAL_COOLDOWN
            end
            ball:setLinearVelocity(0, 0)
            ballDef.toTeleport = {
                x = solidDef.destination.x,
                y = solidDef.destination.y + 32
            }
        else
            print("COOLDOWN...")
        end
    end

    -- ball drain
    if (solidDef.type == "drain") then
        -- ball:setUserData({
        --     toDestroy = true
        -- })
        ballDef.toDestroy = true
    end
end

function checkAllTriggers()
    local nt = 0
    for i, t in ipairs(entities.triggers) do
        if t.data.active then
            nt = nt + 1
        end
    end
    if nt == (#entities.triggers) then
        score = score + ALL_TRIGGERS_SCORE
        for _, t in ipairs(entities.triggers) do
            t.data.active = false
        end
    end
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

function strainSlingshot()
    -- entities.slingshot.torque = -10000000
    entities.slingshot.body:applyLinearImpulse(0, -SLINGSHOT_FORCE)
    -- print()
end

function releaseSlingshot()

end
