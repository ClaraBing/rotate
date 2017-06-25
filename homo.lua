require 'image'

local function perspect(fname, outname, x,y,z)
    local img = image.load(fname, 3, 'float')
    local img_mean = img:mean(2):mean(3):reshape(3)
    local w, h = img:size(3), img:size(2)
    local f = w+h

    local t = os.clock()
    -- Calculate the camera projection mtrx:  K * [R | T]
    local sinx, cosx, siny, cosy, sinz, cosz = math.sin(x), math.cos(x), math.sin(y), math.cos(y), math.sin(z), math.cos(z)
    local R = torch.Tensor({
        {cosz*cosy, cosz*siny*sinx-sinz*cosx, cosz*siny*cosx+sinz*sinx},
        {sinz*cosy, sinz*siny*sinx+cosz*cosx, sinz*siny*cosx-cosz*sinx},
        {-siny, cosy*sinx, cosy*cosx}
    })
    local RT = torch.Tensor({ -- R transpose (i.e. R inverse)
        {cosz*cosy, sinz*cosy,  -siny},
        {cosz*siny*sinx-sinz*cosx, sinz*siny*sinx+cosz*cosx, cosy*sinx},
        {cosz*siny*cosx+sinz*sinx, sinz*siny*cosx-cosz*sinx, cosy*cosx}
    })
    print('R:')
    print(R)
    print('RT:')
    print(RT)
    local K = torch.Tensor({{f,0,0},{0,f,0},{0,0,1}})
    local KI = torch.Tensor({{1/f,0,0},{0,1/f,0},{0,0,1}})
    print('Prep time: ' .. os.clock()-t)

    t = os.clock()
    -- Set homogeneous 3D coordinates
    local orig_homo_coor = torch.Tensor(3, w*h)
    local offset_w, offset_h = math.ceil(w/2), math.ceil(h/2)
    local w_idx = torch.range(1,w) - offset_w
    local h_idx = torch.range(1,h) - offset_h
    for i = 1, w do
        orig_homo_coor[{{1}, {(i-1)*h+1, i*h}}] = w_idx[i]
        orig_homo_coor[{{2}, {(i-1)*h+1, i*h}}] = h_idx
    end
    orig_homo_coor[3] = 1
    -- print('orig_homo_coor:')
    -- print(orig_homo_coor)
    print('Init orig_homo_coor: ' .. os.clock()-t)

    t = os.clock()
    -- Map orig X to X' to determine a rough range
    local new_homo_coor = K*RT*KI * orig_homo_coor
    print(new_homo_coor)
    print('Direct_w_range: ' .. torch.max(new_homo_coor[1])-torch.min(new_homo_coor[1]))
    print('Direct_h_range: ' .. torch.max(new_homo_coor[2])-torch.min(new_homo_coor[2]))
    local img_coor = torch.Tensor(2, w*h)
    img_coor[1] = torch.cdiv(new_homo_coor[1], new_homo_coor[3])
    img_coor[2] = torch.cdiv(new_homo_coor[2], new_homo_coor[3])
    img_coor:apply(torch.round)
    local new_minX, new_maxX, new_minY, new_maxY = torch.min(img_coor[1]), torch.max(img_coor[1]), torch.min(img_coor[2]), torch.max(img_coor[2])
    print('new_minX: ' .. new_minX .. ' / new_maxX: ' .. new_maxX)
    print('new_minY: ' .. new_minY .. ' / new_maxY: ' .. new_maxY)
    local new_w, new_h = new_maxX-new_minX+1, new_maxY-new_minY+1
    print('new_w: ' .. new_w .. ' / new_h: ' .. new_h)
    local new_homo_range = torch.Tensor(3, new_w * new_h)
    w_idx = torch.range(new_minX, new_maxX)
    h_idx = torch.range(new_minY, new_maxY)
    for i = 1, new_w do
        new_homo_range[{{1}, {(i-1)*new_h+1, i*new_h}}] = w_idx[i]
        new_homo_range[{{2}, {(i-1)*new_h+1, i*new_h}}] = h_idx
    end
    new_homo_range[3] = 1
    print('Map orig to new: ' .. os.clock()-t)

    t = os.clock()
    -- Map X' back to the original image for sampling pixels
    local sample_homo_coor = K*R*KI * new_homo_range
    local sample_orig_coor = torch.Tensor(2, new_w * new_h)
    sample_orig_coor[1] = torch.cdiv(sample_homo_coor[1], sample_homo_coor[3])
    sample_orig_coor[2] = torch.cdiv(sample_homo_coor[2], sample_homo_coor[3])
    sample_orig_coor:apply(torch.round)
    print('Map new to orig: ' .. os.clock()-t)

    t = os.clock()
    -- Set new img pixels
    local new_size = math.max(new_w, new_h)
    -- print('new_size: ' .. new_size)
    local new_img = torch.FloatTensor(3, new_size, new_size)
    new_img[1] = img_mean[1]
    new_img[2] = img_mean[2]
    new_img[3] = img_mean[3]
    for i = 1, new_w do
        for j = 1, new_h do
            local sampled_x, sampled_y = sample_orig_coor[1][(i-1)*new_h+j]+offset_w, sample_orig_coor[2][(i-1)*new_h+j]+offset_h
            -- print(sampled_x .. ' ' .. sampled_y)
            if sampled_x > 0 and sampled_x <= w and sampled_y > 0 and sampled_y <= h then
                local img_w, img_h = new_homo_range[1][(i-1)*new_h+j]-new_minX+1, new_homo_range[2][(i-1)*new_h+j]-new_minY+1
                local pixel = img[{{}, {sampled_y}, {sampled_x}}]
                -- print(img_h .. ' ' .. img_w)
                new_img[{{},{img_h},{img_w}}] = pixel -- img[{{}, {sampled_y}, {sampled_x}}]
            end
        end
    end
    print('Set new pixels: ' .. os.clock()-t)

    t = os.clock()
    -- Save to file
    image.save(outname, new_img)
    print('Save to file: ' .. os.clock()-t)
    print('Image saved to ' .. outname)
    return
end

t = os.clock()
perspect('000000.JPEG', '000000_ps1_inf_trans.JPEG', 1*math.pi/4, 0, 0)
print('Time: ' .. os.clock()-t .. '\n')
t = os.clock()
perspect('000000.JPEG', '000000_ps2_inf_trans.JPEG', 0, 1*math.pi/4, 0)
print('Time: ' .. os.clock()-t .. '\n')
t = os.clock()
perspect('000000.JPEG', '000000_ps3_inf_trans.JPEG', math.pi/4, math.pi/3, 0)
print('Time: ' .. os.clock()-t .. '\n')
t = os.clock()
perspect('000000.JPEG', '000000_ps4_inf_trans.JPEG', 0,0,1*math.pi/3)
print('Time: ' .. os.clock()-t .. '\n')
