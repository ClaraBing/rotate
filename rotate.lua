require 'image'

local function rotate(img, theta)
    local w, h = img:size(3), img:size(2)
    local img_mean = img:mean(2):mean(3):reshape(3)

    -- Find output img size
    local side = math.max(math.abs(w*math.sin(theta)) + math.abs(h*math.cos(theta)), math.abs(w*math.cos(theta)) + math.abs(h*math.sin(theta)))
    local full_side = 2 * side -- math.sqrt(2) * side
    -- Padding w/ img mean
    local pad_img = torch.FloatTensor(3, full_side, full_side)
    pad_img[1] = img_mean[1]
    pad_img[2] = img_mean[2]
    pad_img[3] = img_mean[3]

    local w_start, h_start = torch.floor((full_side-w)/2), torch.floor((full_side-h)/2)
    local w_end, h_end =  torch.floor((full_side+w)/2), torch.floor((full_side+h)/2)
    pad_img[{{1,3}, {h_start,h_end-1}, {w_start,w_end-1}}] = img
    -- Rotate
    local rotated = image.rotate(pad_img, theta, 'bilinear')
    -- Crop img only
    local crop_start, crop_end = torch.floor((full_side-side)/2), torch.floor((full_side+side)/2)
    rotated = image.crop(rotated, crop_start, crop_start, crop_end, crop_end) -- Note: the last 2 indices are non-inclusive
    return rotated
end

local function sampleImg(img, interval)
    -- A wrapper for 'rotate'
    -- Input: img: 3*h*w matrix / interval: angle in radius
    local theta = interval * torch.random(-math.pi/(2*interval), math.pi/(2*interval))
    return rotate(img, theta)
end

local img = image.load('000000.JPEG')
for i=4,12,4 do
    for iter = 1,4 do
        rotated = sampleImg(img, math.pi/i)
        image.save('rand_'..i..'_'..iter..'.jpg', rotated)
    end
end
