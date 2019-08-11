debug = false

touches = {}

function love.load(arg)

end

function love.update(dt)

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
    love.graphics.setColor(1, 1, 1)

    if debug then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("DT: " .. tostring(updatetime), 0, 0)
        love.graphics.print("FPS: " .. tostring(1.0 / updatetime), 0, 10)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)

end

function love.touchmoved(id, x, y, dx, dy, pressure)

end

function love.touchreleased(id, x, y, dx, dy, pressure)

end

