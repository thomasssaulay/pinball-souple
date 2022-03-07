-- TABLE SETUP
entities.grounds = {}
for i = 1, 9 do
    entities.grounds[i] = {}
end
-- PINBALL BORDERS
entities.grounds[1].body = love.physics.newBody(world, gameWidth / 2, gameHeight)
entities.grounds[1].shape = love.physics.newRectangleShape(gameWidth, 10)
entities.grounds[1].fixture = love.physics.newFixture(entities.grounds[1].body, entities.grounds[1].shape)
entities.grounds[1].fixture:setUserData({
    type = "drain"
})
entities.grounds[2].body = love.physics.newBody(world, gameWidth / 2, 10 / 2)
entities.grounds[2].shape = love.physics.newRectangleShape(gameWidth, 10)
entities.grounds[2].fixture = love.physics.newFixture(entities.grounds[2].body, entities.grounds[2].shape)
entities.grounds[3].body = love.physics.newBody(world, 10 / 2, gameHeight / 2)
entities.grounds[3].shape = love.physics.newRectangleShape(10, gameHeight)
entities.grounds[3].fixture = love.physics.newFixture(entities.grounds[3].body, entities.grounds[3].shape)
entities.grounds[4].body = love.physics.newBody(world, gameWidth - 10 / 2, gameHeight / 2)
entities.grounds[4].shape = love.physics.newRectangleShape(10, gameHeight)
entities.grounds[4].fixture = love.physics.newFixture(entities.grounds[4].body, entities.grounds[4].shape)

-- left flipper rounder border
entities.grounds[5].body = love.physics.newBody(world, 54, gameHeight - 128)
entities.grounds[5].shape = love.physics.newRectangleShape(10, 128)
entities.grounds[5].fixture = love.physics.newFixture(entities.grounds[5].body, entities.grounds[5].shape)
entities.grounds[5].body:setAngle(-math.rad(55))
-- right flipper rounder border
entities.grounds[6].body = love.physics.newBody(world, gameWidth - 54 - PLUNGER_RAMP_OFFSET, gameHeight - 128)
entities.grounds[6].shape = love.physics.newRectangleShape(10, 128)
entities.grounds[6].fixture = love.physics.newFixture(entities.grounds[6].body, entities.grounds[6].shape)
entities.grounds[6].body:setAngle(math.rad(55))

-- right pluger ramp
entities.grounds[7].body = love.physics.newBody(world, gameWidth - PLUNGER_RAMP_OFFSET, (gameHeight + 196) / 2)
entities.grounds[7].shape = love.physics.newRectangleShape(10, gameHeight - 196)
entities.grounds[7].fixture = love.physics.newFixture(entities.grounds[7].body, entities.grounds[7].shape)

-- top arc
local vertices_top_left_arc = {
    [1] = 11,
    [2] = 12,
    [3] = 11,
    [4] = 187,
    [5] = 16,
    [6] = 187,
    [7] = 16,
    [8] = 176.82,
    [9] = 21.53,
    [10] = 156.43,
    [11] = 32.45,
    [12] = 136.8,
    [13] = 48.49,
    [14] = 118.41,
    [15] = 69.26,
    [16] = 101.71,
    [17] = 94.25,
    [18] = 87.11,
    [19] = 122.84,
    [20] = 74.98,
    [21] = 154.32,
    [22] = 65.61,
    [23] = 187.93,
    [24] = 59.23,
    [25] = 222.83,
    [26] = 56,
    [27] = 240,
    [28] = 56,
    [29] = 240,
    [30] = 12
}
local vertices_top_right_arc = {
    [1] = 11,
    [2] = 12,
    [3] = 11,
    [4] = 56,
    [5] = 28.17,
    [6] = 56,
    [7] = 63.07,
    [8] = 59.23,
    [9] = 96.68,
    [10] = 65.61,
    [11] = 128.16,
    [12] = 74.98,
    [13] = 156.75,
    [14] = 87.11,
    [15] = 181.74,
    [16] = 101.71,
    [17] = 202.51,
    [18] = 118.41,
    [19] = 218.52,
    [20] = 136.8,
    [21] = 229.47,
    [22] = 156.43,
    [23] = 235,
    [24] = 176.82,
    [25] = 235,
    [26] = 187,
    [27] = 240,
    [28] = 187,
    [29] = 240,
    [30] = 12,
    [31] = 11,
    [32] = 12
}

entities.grounds[8].body = love.physics.newBody(world, -6, -12)
entities.grounds[8].shape = love.physics.newChainShape(false, unpack(vertices_top_left_arc))
entities.grounds[8].fixture = love.physics.newFixture(entities.grounds[8].body, entities.grounds[8].shape)
entities.grounds[9].body = love.physics.newBody(world, 235, -12)
entities.grounds[9].shape = love.physics.newChainShape(false, unpack(vertices_top_right_arc))
entities.grounds[9].fixture = love.physics.newFixture(entities.grounds[9].body, entities.grounds[9].shape)

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
    x = 150,
    y = gameHeight - 80,
    orientation = "left"
}, anchorBody)
createFlipper({
    x = gameWidth - 150 - PLUNGER_RAMP_OFFSET,
    y = gameHeight - 80,
    orientation = "right"
}, anchorBody)
entities.balls = {}

entities.triggers = {}
createTrigger(gameWidth / 2, 200)
createTrigger(gameWidth / 2 - 50, 200)
createTrigger(gameWidth / 2 + 50, 200)

entities.bumpers = {}
createBumper(gameWidth / 2 - 100, 150, 20)
createBumper(gameWidth / 2 + 100, 150, 20)
-- createBumper(gameWidth / 2, 200, 20)
createBumper(gameWidth / 2 - 50, 300, 30)
createBumper(gameWidth / 2 + 50, 300, 30)
createBumper(gameWidth / 2 - 150, 500, 20, gameWidth / 2 + 150 - PLUNGER_RAMP_OFFSET, 400)

entities.kickers = {}
createKicker(gameWidth - 100 - PLUNGER_RAMP_OFFSET, gameHeight / 2 + 200, "left")
createKicker(100, gameHeight / 2 + 200, "right")

entities.slingshot = createSlingshot(gameWidth - 30, gameHeight - 32)

entities.portals = {}
createPortals(gameWidth / 2 - 75, gameHeight / 2 + 50, gameWidth / 2 + 75, gameHeight / 2 + 50)

love.graphics.setBackgroundColor(0.41, 0.53, 0.97)
