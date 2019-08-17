debug = false
screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()
drawParticles = true

updatetime = 0
paddleSize = {w = 50, h = 400}
puckSize = 75
wallThickness = 10
centerLineThickness = 10
goalSize = 300
paddleOffset = 200
gameSettings = {time = 3 * 60, started = false, timeLeft = 3 * 60}

world = nil

objects = {}

score = {left = 0, right = 0}

function love.load(arg)
    setScale()

    world = love.physics.newWorld(0, 0)

    createPaddles()
    createPuck()
    createWalls()
end

function love.update(dt)
    updatetime = dt

    world:update(dt)
    puck.pSystem:setPosition(puck.body:getX(), puck.body:getY())
    puck.pSystem:update(dt)

    if (puck.body:getX() < 0) then
        resetPuck()
        score.right = score.right + 1
    elseif (puck.body:getX() > screenWidth) then
        resetPuck()
        score.left = score.left + 1
    end

    if gameSettings.started then
        gameSettings.timeLeft = gameSettings.timeLeft - dt

        if (gameSettings.timeLeft < 0) then
            if score.left > score.right then
                gameSettings.winner = "Blue Wins!"
            elseif score.right > score.left then
                gameSettings.winner = "Red Wins!"
            elseif score.right == score.left then
                gameSettings.winner = "Tie Game"
            end

            gameSettings.started = false
            gameSettings.timeLeft = gameSettings.time
            resetPuck()
            score.left = 0
            score.right = 0
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'd' and not isrepeat then
        debug = not debug
    end

    if love.keyboard.isDown('escape') then
        love.event.push('quit')
    elseif love.keyboard.isDown('r') then
        resetPuck()
        score.left = 0
        score.right = 0
    elseif love.keyboard.isDown('p') then
        drawParticles = not drawParticles
    end
end

function love.draw()
    -- center line
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", love.graphics.getWidth() / 2 -
                                (centerLineThickness / 2), 0,
                            centerLineThickness, love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1)

    -- puck and paddles
    for i, o in ipairs(objects) do
        love.graphics.draw(o.img, o.body:getX(), o.body:getY(), 0, 1, 1,
                           o.img:getWidth() / 2, o.img:getHeight() / 2)
    end

    -- draw particle systems
    if (drawParticles) then
        love.graphics.draw(puck.pSystem, 0, 0)
    end

    -- scores and timer
    love.graphics.setColor(0, 0, 1)
    love.graphics.printf(tostring(score.left), 10, 50 * sy,
                         (screenWidth - 20) / (10 * sx), "left", 0, 10 * sx,
                         10 * sy)
    love.graphics.setColor(1, 0, 0)
    love.graphics.printf(tostring(score.right), 10, 50 * sy,
                         (screenWidth - 20) / (10 * sx), "right", 0, 10 * sx,
                         10 * sy)
    love.graphics.setColor(1, 1, 0)
    love.graphics.printf(SecondsToClock(gameSettings.timeLeft), 10, 50 * sy,
                         (screenWidth - 20) / (10 * sx), "center", 0, 10 * sx,
                         10 * sy)

    -- winner message
    if (not gameSettings.started and
        not (gameSettings.winner == nil or gameSettings.winner == '')) then
        love.graphics.setColor(0, 1, 0)
        love.graphics.printf(gameSettings.winner, 10, screenHeight / 2,
                             (screenWidth - 20) / (10 * sx), "center", 0,
                             10 * sx, 10 * sy)
        love.graphics.setColor(1, 1, 1)
    end

    if debug then
        drawDebug()
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if not gameSettings.started then
        gameSettings.started = true
        gameSettings.winner = nil
    end

    -- prevent puck from being stuck in x direction, and start motion after resetting puck
    if math.abs(puck.body:getLinearVelocity()) < 2 then
        local v = 500
        if math.random(0, 1) < 0.5 then
            v = v * -1
        end
        puck.body:setLinearVelocity(v, 0)
    end

    local isLeft = true
    if (x > (screenWidth / 2)) then
        isLeft = false
    end

    if (isLeft and leftPaddle.touchid == nil) then
        leftPaddle.touchid = id
        leftPaddle.joint:setTarget(paddleOffset, y)
    elseif (not isLeft and rightPaddle.touchid == nil) then
        rightPaddle.touchid = id
        rightPaddle.joint:setTarget(screenWidth - paddleOffset, y)
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if (leftPaddle.touchid == id and x <= screenWidth / 2) then
        leftPaddle.joint:setTarget(paddleOffset, y)
    elseif (rightPaddle.touchid == id and x > screenWidth / 2) then
        rightPaddle.joint:setTarget(screenWidth - paddleOffset, y)
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

function getPaddle(size, color)
    local paddle = love.graphics.newCanvas(size.w, size.h)
    love.graphics.setCanvas(paddle)
    love.graphics.setColor(color.r, color.g, color.b, 1)
    love.graphics.rectangle("fill", 0, 0, size.w, size.h, 0, 1, 1, size.w / 2,
                            size.h / 2)
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
end

function setScale()
    local width, height = love.graphics.getDimensions()
    sx = width / 1920
    sy = height / 1080
    paddleSize.w = paddleSize.w * sx
    paddleSize.h = paddleSize.h * sy
    wallThickness = wallThickness * sx
    puckSize = puckSize * sx
    centerLineThickness = centerLineThickness * sx
    goalSize = goalSize * sy
    paddleOffset = paddleOffset * sx
end

function createPaddles()
    leftPaddle = {
        img = getPaddle(paddleSize, {r = 0, g = 0, b = 1}),
        touchid = nil
    }
    leftPaddle.body = love.physics.newBody(world, paddleOffset,
                                           screenHeight / 2, "dynamic")
    leftPaddle.shape = love.physics
                           .newRectangleShape(paddleSize.w, paddleSize.h)
    leftPaddle.fixture = love.physics.newFixture(leftPaddle.body,
                                                 leftPaddle.shape)
    leftPaddle.joint = love.physics.newMouseJoint(leftPaddle.body, paddleOffset,
                                                  screenHeight / 2)
    rightPaddle = {
        img = getPaddle(paddleSize, {r = 1, g = 0, b = 0}),
        touchid = nil
    }
    rightPaddle.body = love.physics.newBody(world, screenWidth - paddleOffset,
                                            screenHeight / 2, "dynamic")
    rightPaddle.shape = love.physics.newRectangleShape(paddleSize.w,
                                                       paddleSize.h)
    rightPaddle.fixture = love.physics.newFixture(rightPaddle.body,
                                                  rightPaddle.shape)
    rightPaddle.joint = love.physics.newMouseJoint(rightPaddle.body,
                                                   screenWidth - paddleOffset,
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

    local pSystem = love.graphics.newParticleSystem(puck.img, puckSize)
    pSystem:setParticleLifetime(0.2, 0.5)
    pSystem:setLinearAcceleration(-100, -100, 100, 100)
    pSystem:setColors(1, 1, 0, 255, 1, 1, 1, 255)
    pSystem:setSizes(1.0, 0.01)
    pSystem:setEmissionRate(60)
    puck.pSystem = pSystem

    table.insert(objects, puck)
end

function resetPuck()
    puck.body:setLinearVelocity(0, 0)
    puck.body:setX(screenWidth / 2)
    puck.body:setY(screenHeight / 2)
end

function SecondsToClock(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00"
    else
        mins = string.format("%02.f", math.floor(seconds / 60))
        secs = string.format("%02.f", math.floor(seconds - mins * 60))
        return mins .. ":" .. secs
    end
end

function drawDebug()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("DT: " .. tostring(updatetime), 10, 10)
    love.graphics.print("FPS: " .. tostring(1.0 / updatetime), 10, 20)
    love.graphics.print(
        "Screen " .. tostring(love.graphics.getWidth()) .. "x" ..
            tostring(love.graphics.getHeight()) .. " scale " .. tostring(sx) ..
            "x" .. tostring(sy), 10, 30)
    love.graphics.print("Puck " .. tostring(puck.body:getX()) .. ", " ..
                            tostring(puck.body:getY()) .. "   v: " ..
                            puck.body:getLinearVelocity(), 10, 40)
    love.graphics.print("Score " .. tostring(score.left) .. ":" ..
                            tostring(score.right), 10, 50)
    love.graphics.print("Game " .. tostring(gameSettings.timeLeft), 10, 60)

    for _, body in pairs(world:getBodies()) do
        for _, fixture in pairs(body:getFixtures()) do
            local shape = fixture:getShape()

            if shape:typeOf("CircleShape") then
                local cx, cy = body:getWorldPoints(shape:getPoint())
                love.graphics.circle("fill", cx, cy, shape:getRadius())
            elseif shape:typeOf("PolygonShape") then
                love.graphics.polygon("fill",
                                      body:getWorldPoints(shape:getPoints()))
            else
                love.graphics.line(body:getWorldPoints(shape:getPoints()))
            end
        end
    end
end
