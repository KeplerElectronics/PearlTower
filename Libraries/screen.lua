local screen = {}

function screen.init(width, height)
    screen.width = width
    screen.height = height
    screen.canvas = love.graphics.newCanvas(width, height)
    screen.transform = love.math.newTransform()
end

return screen
