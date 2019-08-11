debug = false

updatetime = 0
paddleSize = 200

function love.load(arg)
    leftPaddle = {
        img = getCirclePaddle(paddleSize, {r = 0, g = 0, b = 1}),
        x = 0,
        y = love.graphics.getHeight() / 2
    }
    rightPaddle = {
        img = getCirclePaddle(paddleSize, {r = 1, g = 0, b = 0}),
        x = love.graphics.getWidth(),
        y = love.graphics.getHeight() / 2
    }
end

function love.update(dt)
    updatetime = dt
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

    love.graphics.draw(leftPaddle.img, leftPaddle.x, leftPaddle.y, 0, 1, 1,
                       leftPaddle.img:getWidth() / 2,
                       leftPaddle.img:getHeight() / 2)

    love.graphics.draw(rightPaddle.img, rightPaddle.x, rightPaddle.y, 0, 1, 1,
                       rightPaddle.img:getWidth() / 2,
                       rightPaddle.img:getHeight() / 2)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    local isLeft = true
    if (x > (love.graphics.getWidth() / 2)) then
        isLeft = false
    end

    if (isLeft and leftPaddle.touchid == nil) then
        leftPaddle.x = x
        leftPaddle.y = y
        leftPaddle.touchid = id
    elseif (not isLeft and rightPaddle.touchid == nil) then
        rightPaddle.x = x
        rightPaddle.y = y
        rightPaddle.touchid = id
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if (leftPaddle.touchid == id and x <= love.graphics.getWidth() / 2) then
        leftPaddle.x = x
        leftPaddle.y = y
    elseif (rightPaddle.touchid == id and x > love.graphics.getWidth() / 2) then
        rightPaddle.x = x
        rightPaddle.y = y
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
