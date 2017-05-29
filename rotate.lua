require 'image'

local function rotate(fname, outname, theta)
    local img = image.load(fname, 3, 'float')
    local w, h = img:size(3), img:size(2)
    local side = math.max(math.abs(w*math.sin(theta)) + math.abs(h*math.cos(theta)), math.abs(w*math.cos(theta)) + math.abs(h*math.sin(theta)))
    local full_side = math.sqrt(2) * side
    local img_mean = img:mean(2):mean(3):reshape(3)
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
    -- Save to file
    image.save(outname, rotated)
    return
end

-- rotate('000000.JPEG', '000000_rotated1.JPEG', 1*math.pi/4)
-- rotate('000000.JPEG', '000000_rotated2.JPEG', 2*math.pi/4)
-- rotate('000000.JPEG', '000000_rotated3.JPEG', 3*math.pi/4)
-- rotate('000000.JPEG', '000000_rotated4.JPEG', 4*math.pi/4)
-- rotate('000000.JPEG', '000000_rotated5.JPEG', 5*math.pi/4)
-- rotate('000000.JPEG', '000000_rotated6.JPEG', 6*math.pi/4)
-- rotate('000000.JPEG', '000000_rotated7.JPEG', 7*math.pi/4)
-- rotate('000000.JPEG', '000000_rotated8.JPEG', 8*math.pi/4)
-- rotate('000000.JPEG', '000000_rotated_neg.JPEG', -math.pi/4)
rotate('000000.JPEG', '000000_rotated_neg2.JPEG', -math.pi/3)
