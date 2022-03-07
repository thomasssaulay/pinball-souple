--[[
    CONSTANTS DEFINITION
 ]] --
MAX_BALL_SPEED = 1400 -- 1200
BALL_BOUNCE = 0.05 -- 0.2
BALL_SIZE = 12
GRAVITY = 12 -- 9.81 -- 18
PIXEL_PER_METER = 64
FLIPPER_TORQUE = 500000 -- 1000000
NUDGE_FORCE = 50
SLINGSHOT_FORCE = 500
SLINGSHOT_LENGTH = 64
PORTAL_COOLDOWN = 5

ALL_TRIGGERS_SCORE = 2000

PLUNGER_RAMP_OFFSET = 48

--[[
    GLOBAL FUNCTIONS 
]] --
function getPolySize(vertices)
    local minx, maxx, miny, maxy = vertices[1], vertices[1], vertices[2], vertices[2]
    for i = 1, #vertices - 1, 2 do
        minx = math.min(minx, vertices[i])
        maxx = math.max(maxx, vertices[i])
        miny = math.min(miny, vertices[i + 1])
        maxy = math.max(maxy, vertices[i + 1])
    end

    return maxx - minx, maxy - miny
end

function separateSolids(a, b)
    local aa = a:getUserData() or {}
    local bb = b:getUserData() or {}
    if (aa.type == "ball") then
        return a:getBody(), aa, b:getBody(), bb
    elseif (bb.type == "ball") then
        return b:getBody(), bb, a:getBody(), aa
    end
end

function clamp(min, value, max)
    if (type(min) == "table") then
        max = min.max
        min = min.min
    end
    return math.max(min, math.min(max, value))
end

function getAngleBetween(x, y, toX, toY)
    return math.atan2(toY - y, toX - x) + math.pi
end
