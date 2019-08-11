debug = true

updatetime = 0
paddleSize = 200
puckSize = 75
wallThickness = 10

world = nil

objects = {}

function love.load(arg)
    world = love.physics.newWorld(0, 0)

    leftPaddle = {
        img = getCirclePaddle(paddleSize, {r = 0, g = 0, b = 1}),
        touchid = nil
    }
    leftPaddle.body = love.physics.newBody(world, paddleSize * 1.5,
                                           love.graphics.getHeight() / 2,
                                           "dynamic")
    leftPaddle.shape = love.physics.newCircleShape(paddleSize / 2)
    leftPaddle.fixture = love.physics.newFixture(leftPaddle.body,
                                                 leftPaddle.shape)
    leftPaddle.joint = love.physics.newMouseJoint(leftPaddle.body,
                                                  paddleSize * 1.5,
                                                  love.graphics.getHeight() / 2)
    rightPaddle = {
        img = getCirclePaddle(paddleSize, {r = 1, g = 0, b = 0}),
        touchid = nil
    }
    rightPaddle.body = love.physics.newBody(world, love.graphics.getWidth() -
                                                (paddleSize * 1.5),
                                            love.graphics.getHeight() / 2,
                                            "dynamic")
    rightPaddle.shape = love.physics.newCircleShape(paddleSize / 2)
    rightPaddle.fixture = love.physics.newFixture(rightPaddle.body,
                                                  rightPaddle.shape)
    rightPaddle.joint = love.physics.newMouseJoint(rightPaddle.body,
                                                   love.graphics.getWidth() -
                                                       (paddleSize * 1.5),
                                                   love.graphics.getHeight() / 2)

    puck = {img = getCirclePaddle(puckSize, {r = 1, g = 1, b = 0})}
    puck.body = love.physics.newBody(world, love.graphics.getWidth() / 2,
                                     love.graphics.getHeight() / 2, "dynamic")
    puck.shape = love.physics.newCircleShape(puckSize / 2)
    puck.fixture = love.physics.newFixture(puck.body, puck.shape)
    puck.fixture:setRestitution(.9)

    table.insert(objects, leftPaddle)
    table.insert(objects, rightPaddle)
    table.insert(objects, puck)

    createWalls()
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
        love.graphics.print("DT: " .. tostring(updatetime), 10, 10)
        love.graphics.print("FPS: " .. tostring(1.0 / updatetime), 10, 20)
        love.graphics.print("Screen " .. tostring(love.graphics.getWidth()) ..
                                "x" .. tostring(love.graphics.getHeight()), 10,
                            30)
    end

    -- center line
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - 10, 0, 20,
                            love.graphics.getHeight())

    -- puck and paddles
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

function getRectangle(width, height, color)
    local rect = love.graphics.newCanvas(width, height)
    love.graphics.setCanvas(rect)
    love.graphics.setColor(color.r, color.g, color.b)
    love.graphics.rectangle("fill", 0, 0, width, height)
    love.graphics.setCanvas()
    return rect
end

function createWalls()
    wallT = {
        img = getRectangle(love.graphics.getWidth(), wallThickness,
                           {r = 1, g = 1, b = 0})
    }
    wallT.body = love.physics.newBody(world, love.graphics.getWidth() / 2,
                                      wallThickness / 2, "static")
    wallT.shape = love.physics.newRectangleShape(love.graphics.getWidth(),
                                                 wallThickness)
    wallT.fixture = love.physics.newFixture(wallT.body, wallT.shape)
    table.insert(objects, wallT)

    wallB = {
        img = getRectangle(love.graphics.getWidth(), wallThickness,
                           {r = 1, g = 1, b = 0})
    }
    wallB.body = love.physics.newBody(world, love.graphics.getWidth() / 2,
                                      love.graphics.getHeight() -
                                          (wallThickness / 2), "static")
    wallB.shape = love.physics.newRectangleShape(love.graphics.getWidth(),
                                                 wallThickness)
    wallB.fixture = love.physics.newFixture(wallB.body, wallB.shape)
    table.insert(objects, wallB)

    wallL = {
        img = getRectangle(wallThickness, love.graphics.getHeight(),
                           {r = 1, g = 1, b = 0})
    }
    wallL.body = love.physics.newBody(world, wallThickness / 2,
                                      love.graphics.getHeight() / 2, "static")
    wallL.shape = love.physics.newRectangleShape(wallThickness,
                                                 love.graphics.getHeight())
    wallL.fixture = love.physics.newFixture(wallL.body, wallL.shape)
    table.insert(objects, wallL)

    wallR = {
        img = getRectangle(wallThickness, love.graphics.getHeight(),
                           {r = 1, g = 1, b = 0})
    }
    wallR.body = love.physics.newBody(world, love.graphics.getWidth() -
                                          (wallThickness / 2),
                                      love.graphics.getHeight() / 2, "static")
    wallR.shape = love.physics.newRectangleShape(wallThickness,
                                                 love.graphics.getHeight())
    wallR.fixture = love.physics.newFixture(wallR.body, wallR.shape)
    table.insert(objects, wallR)
end
