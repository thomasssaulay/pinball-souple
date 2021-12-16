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

    if solidDef.type == "bumper" or solidDef.type == "kicker" then
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
    if (solidDef.type == "trigger") then
        if (solidDef.action == "slingshot") then
            ball:setLinearVelocity(0, -1000)
        end
    end

    -- Ball drained
    if (solidDef.type == "drain") then
        ball:setUserData({
            action = "destroy"
        })
    end
end
