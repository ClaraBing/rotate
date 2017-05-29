require 'image'

local function rotate(fname, theta)
    local img = image.load(fname, 3, 'float')
    local w, h = img:size(3), img:size(2)
    local side = w*math.sin(theta) + math.abs(h*math.cos(theta))
    local img_mean = img:mean(2):mean(3):reshape(3)
    print('img mean:')
    print(img_mean)
    print('img size:', h, w)
    print('padded size:', side)
    local pad_img = torch.FloatTensor(3, side, side)
    pad_img[1] = img_mean[1]
    pad_img[2] = img_mean[2]
    pad_img[3] = img_mean[3]
    local w_start, h_start = torch.floor((side-w)/2), torch.floor((side-h)/2)
    local w_end, h_end =  torch.floor((side+w)/2), torch.floor((side+h)/2)
    print(w_start, h_start)
    print(w_end, h_end)
    pad_img[{{1,3}, {h_start,h_end-1}, {w_start,w_end-1}}] = img
    local rotated = image.rotate(pad_img, theta, 'bilinear')
    image.save('out.jpg', rotated)
    return
end

rotate('000000.JPEG', 0.7854)
