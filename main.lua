debug = true
screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()

updatetime = 0
paddleSize = 200
puckSize = 75
wallThickness = 10
centerLineThickness = 10
goalSize = 300

world = nil

objects = {}

function love.load(arg)
    setScale()

    world = love.physics.newWorld(0, 0)

    createPaddles()
    createPuck()
    createWalls()
    createGoals()
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
    elseif love.keyboard.isDown('r') then
        resetPositions()
    end
end

function love.draw()
    if debug then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("DT: " .. tostring(updatetime), 10, 10)
        love.graphics.print("FPS: " .. tostring(1.0 / updatetime), 10, 20)
        love.graphics.print("Screen " .. tostring(love.graphics.getWidth()) ..
                                "x" .. tostring(love.graphics.getHeight()) ..
                                " scale " .. tostring(sx) .. "x" .. tostring(sy),
                            10, 30)
        love.graphics.print("Puck " .. tostring(puck.body:getX()) .. ", " ..
                                tostring(puck.body:getY()), 10, 40)
    end

    -- center line
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 -
                                (centerLineThickness / 2), 0,
                            centerLineThickness, love.graphics.getHeight())

    -- puck and paddles
    for i, o in ipairs(objects) do
        love.graphics.draw(o.img, o.body:getX(), o.body:getY(), 0, 1, 1,
                           o.img:getWidth() / 2, o.img:getHeight() / 2)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    local isLeft = true
    if (x > (screenWidth / 2)) then
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
    if (leftPaddle.touchid == id and x <= screenWidth / 2) then
        leftPaddle.joint:setTarget(x, y)
    elseif (rightPaddle.touchid == id and x > screenWidth / 2) then
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
        img = getRectangle(screenWidth, wallThickness, {r = 1, g = 1, b = 0})
    }

    wallT.body = love.physics.newBody(world, screenWidth / 2, wallThickness / 2,
                                      "static")
    wallT.shape = love.physics.newRectangleShape(screenWidth, wallThickness)
    wallT.fixture = love.physics.newFixture(wallT.body, wallT.shape)
    table.insert(objects, wallT)

    wallB = {
        img = getRectangle(screenWidth, wallThickness, {r = 1, g = 1, b = 0})
    }
    wallB.body = love.physics.newBody(world, screenWidth / 2,
                                      screenHeight - (wallThickness / 2),
                                      "static")
    wallB.shape = love.physics.newRectangleShape(screenWidth, wallThickness)
    wallB.fixture = love.physics.newFixture(wallB.body, wallB.shape)
    table.insert(objects, wallB)

    local goalWallSegmentHeight = (screenHeight - goalSize) / 2
    wallLT = {
        img = getRectangle(wallThickness, goalWallSegmentHeight,
                           {r = 1, g = 1, b = 0})
    }
    wallLT.body = love.physics.newBody(world, wallThickness / 2,
                                       goalWallSegmentHeight / 2, "static")
    wallLT.shape = love.physics.newRectangleShape(wallThickness,
                                                  goalWallSegmentHeight)
    wallLT.fixture = love.physics.newFixture(wallLT.body, wallLT.shape)
    table.insert(objects, wallLT)

    wallLB = {
        img = getRectangle(wallThickness, goalWallSegmentHeight,
                           {r = 1, g = 1, b = 0})
    }
    wallLB.body = love.physics.newBody(world, wallThickness / 2, screenHeight -
                                           (goalWallSegmentHeight / 2), "static")
    wallLB.shape = love.physics.newRectangleShape(wallThickness,
                                                  goalWallSegmentHeight)
    wallLB.fixture = love.physics.newFixture(wallLB.body, wallLB.shape)
    table.insert(objects, wallLB)

    -- left and right walls with goal holes
    local goalWallSegmentHeight = (screenHeight - goalSize) / 2
    wallRT = {
        img = getRectangle(wallThickness, goalWallSegmentHeight,
                           {r = 1, g = 1, b = 0})
    }
    wallRT.body = love.physics.newBody(world, screenWidth - (wallThickness / 2),
                                       goalWallSegmentHeight / 2, "static")
    wallRT.shape = love.physics.newRectangleShape(wallThickness,
                                                  goalWallSegmentHeight)
    wallRT.fixture = love.physics.newFixture(wallRT.body, wallRT.shape)
    table.insert(objects, wallRT)

    wallRB = {
        img = getRectangle(wallThickness, goalWallSegmentHeight,
                           {r = 1, g = 1, b = 0})
    }
    wallRB.body = love.physics.newBody(world, screenWidth - (wallThickness / 2),
                                       screenHeight -
                                           (goalWallSegmentHeight / 2), "static")
    wallRB.shape = love.physics.newRectangleShape(wallThickness,
                                                  goalWallSegmentHeight)
    wallRB.fixture = love.physics.newFixture(wallRB.body, wallRB.shape)
    table.insert(objects, wallRB)
end

function setScale()
    local width, height = love.graphics.getDimensions()
    sx = width / 1920
    sy = height / 1080
    paddleSize = paddleSize * sx
    wallThickness = wallThickness * sx
    puckSize = puckSize * sx
    centerLineThickness = centerLineThickness * sx
    goalSize = goalSize * sy
end

function createPaddles()
    leftPaddle = {
        img = getCirclePaddle(paddleSize, {r = 0, g = 0, b = 1}),
        touchid = nil
    }
    leftPaddle.body = love.physics.newBody(world, paddleSize * 1.5,
                                           screenHeight / 2, "dynamic")
    leftPaddle.shape = love.physics.newCircleShape(paddleSize / 2)
    leftPaddle.fixture = love.physics.newFixture(leftPaddle.body,
                                                 leftPaddle.shape)
    leftPaddle.joint = love.physics.newMouseJoint(leftPaddle.body,
                                                  paddleSize * 1.5,
                                                  screenHeight / 2)
    rightPaddle = {
        img = getCirclePaddle(paddleSize, {r = 1, g = 0, b = 0}),
        touchid = nil
    }
    rightPaddle.body = love.physics.newBody(world,
                                            screenWidth - (paddleSize * 1.5),
                                            screenHeight / 2, "dynamic")
    rightPaddle.shape = love.physics.newCircleShape(paddleSize / 2)
    rightPaddle.fixture = love.physics.newFixture(rightPaddle.body,
                                                  rightPaddle.shape)
    rightPaddle.joint = love.physics.newMouseJoint(rightPaddle.body,
                                                   screenWidth -
                                                       (paddleSize * 1.5),
                                                   screenHeight / 2)

    table.insert(objects, leftPaddle)
    table.insert(objects, rightPaddle)
end

function createPuck()
    puck = {img = getCirclePaddle(puckSize, {r = 1, g = 1, b = 0})}
    puck.body = love.physics.newBody(world, screenWidth / 2, screenHeight / 2,
                                     "dynamic")
    puck.shape = love.physics.newCircleShape(puckSize / 2)
    puck.fixture = love.physics.newFixture(puck.body, puck.shape)
    puck.fixture:setRestitution(.9)

    table.insert(objects, puck)
end

function createGoals()
    -- leftGoal = {
    --     img = getRectangle(goalSize.w, goalSize.h, {r = 0, g = 0, b = 1})
    -- }
    -- rightGoal = {
    --     img = getRectangle(goalSize.w, goalSize.h, {r = 1, g = 0, b = 0})
    -- }

    -- table.insert(objects, leftGoal)
    -- table.insert(objects, rightGoal)
end

function resetPositions()
    puck.body:setLinearVelocity(0, 0)
    puck.body:setX(screenWidth / 2)
    puck.body:setY(screenHeight / 2)
end
