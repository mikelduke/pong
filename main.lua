debug = true

updatetime = 0
paddleSize = 200
puckSize = 75

world = nil

objects = {}

function love.load(arg)
    world = love.physics.newWorld(0, 0)

    leftPaddle = {
        img = getCirclePaddle(paddleSize, {r = 0, g = 0, b = 1}),
        touchid = nil
    }
    leftPaddle.body = love.physics.newBody(world, 0,
                                           love.graphics.getHeight() / 2,
                                           "dynamic")
    leftPaddle.shape = love.physics.newCircleShape(paddleSize / 2)
    leftPaddle.fixture = love.physics.newFixture(leftPaddle.body,
                                                 leftPaddle.shape)
    leftPaddle.joint = love.physics.newMouseJoint(leftPaddle.body, 0,
                                                  love.graphics.getHeight() / 2)
    rightPaddle = {
        img = getCirclePaddle(paddleSize, {r = 1, g = 0, b = 0}),
        touchid = nil
    }
    rightPaddle.body = love.physics.newBody(world, love.graphics.getWidth(),
                                            love.graphics.getHeight() / 2,
                                            "dynamic")
    rightPaddle.shape = love.physics.newCircleShape(paddleSize / 2)
    rightPaddle.fixture = love.physics.newFixture(rightPaddle.body,
                                                  rightPaddle.shape)
    rightPaddle.joint = love.physics.newMouseJoint(rightPaddle.body,
                                                   love.graphics.getWidth(),
                                                   love.graphics.getHeight() / 2)

    puck = {img = getCirclePaddle(puckSize, {r = 1, g = 1, b = 0})}
    puck.body = love.physics.newBody(world, love.graphics.getWidth() / 2,
                                     love.graphics.getHeight() / 2, "dynamic")
    puck.shape = love.physics.newCircleShape(puckSize / 2)
    puck.fixture = love.physics.newFixture(puck.body, puck.shape)

    table.insert(objects, leftPaddle)
    table.insert(objects, rightPaddle)
    table.insert(objects, puck)
end

function love.update(dt)
    updatetime = dt

    world:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'd' and not isrepeat then
        debug = not debug
    end

    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    end
end

function love.draw()
    if debug then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("DT: " .. tostring(updatetime), 0, 0)
        love.graphics.print("FPS: " .. tostring(1.0 / updatetime), 0, 10)
        love.graphics.print("Screen " .. tostring(love.graphics.getWidth()) ..
                                "x" .. tostring(love.graphics.getHeight()), 0,
                            20)
    end

    -- center line
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 10, 0, 20,
                            love.graphics.getHeight())

    -- love.graphics.draw(leftPaddle.img, leftPaddle.body:getX(),
    --                    leftPaddle.body:getY(), 0, 1, 1,
    --                    leftPaddle.img:getWidth() / 2,
    --                    leftPaddle.img:getHeight() / 2)

    -- love.graphics.draw(rightPaddle.img, rightPaddle.body:getX(),
    --                    rightPaddle.body:getY(), 0, 1, 1,
    --                    rightPaddle.img:getWidth() / 2,
    --                    rightPaddle.img:getHeight() / 2)

    -- love.graphics.draw(puck.img, puck.x, puck.y, 0, 1, 1,
    --                    puck.img:getWidth() / 2, puck.img:getHeight() / 2)

    for i, o in ipairs(objects) do
        love.graphics.draw(o.img, o.body:getX(), o.body:getY(), 0, 1, 1,
                           o.img:getWidth() / 2, o.img:getHeight() / 2)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    local isLeft = true
    if (x > (love.graphics.getWidth() / 2)) then
        isLeft = false
    end

    if (isLeft and leftPaddle.touchid == nil) then
        leftPaddle.touchid = id
        leftPaddle.joint:setTarget(x, y)
    elseif (not isLeft and rightPaddle.touchid == nil) then
        rightPaddle.touchid = id
        rightPaddle.joint:setTarget(x, y)
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if (leftPaddle.touchid == id and x <= love.graphics.getWidth() / 2) then
        leftPaddle.joint:setTarget(x, y)
    elseif (rightPaddle.touchid == id and x > love.graphics.getWidth() / 2) then
        rightPaddle.joint:setTarget(x, y)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if (leftPaddle.touchid == id) then
        leftPaddle.touchid = nil
    elseif (rightPaddle.touchid == id) then
        rightPaddle.touchid = nil
    end
end

function getCirclePaddle(size, color)
    local paddle = love.graphics.newCanvas(size, size)
    love.graphics.setCanvas(paddle)
    love.graphics.setColor(color.r, color.g, color.b, 1)

    love.graphics.circle("fill", size / 2, size / 2, size / 2)

    love.graphics.setCanvas()
    return paddle
end
