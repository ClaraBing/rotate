require 'image'

local function rotate(fname, theta)
    local img = image.load(fname, 3)
    local rotated = image.rotate(img, theta, 'bilinear')
    image.save('out.jpg', rotated)
    return
end

rotate('000000.JPEG', 0.7854)
