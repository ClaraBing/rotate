require 'image'

local function perspect(fname, outname, x,y,z)
    local img = image.load(fname, 3, 'float')
    local img_mean = img:mean(2):mean(3):reshape(3)
    local w, h = img:size(3), img:size(2)
    local f = 2*(w+h)

    -- Calculate the camera projection mtrx:  K * [R | T]
    local sinx, cosx, siny, cosy, sinz, cosz = math.sin(x), math.cos(x), math.sin(y), math.cos(y), math.sin(z), math.cos(z)
    local RT = torch.Tensor({
        {cosz*cosy, cosz*siny*sinx-sinz*cosx, cosz*siny*cosx+sinz*sinx, 0},
        {sinz*cosy, sinz*siny*sinx+cosz*cosx, sinz*siny*cosx-cosz*sinx, 0},
        {-siny, cosy*sinx, cosy*cosx, f}
    })
    local K = torch.Tensor({{f,0,0},{0,f,0},{0,0,1}})

    -- Set homogeneous 3D coordinates
    local orig_homo_coor = torch.Tensor(4, w*h)
    local offset_w, offset_h = math.ceil(w/2), math.ceil(h/2)
    local w_idx = torch.range(1,w) - offset_w
    local h_idx = torch.range(1,h) - offset_h
    for i = 1, w do
        orig_homo_coor[{{1}, {(i-1)*h+1, i*h}}] = w_idx[i]
        orig_homo_coor[{{2}, {(i-1)*h+1, i*h}}] = h_idx
    end
    orig_homo_coor[3] = 0
    orig_homo_coor[4] = 1

    -- Calculate resulting 2D coordinates
    local new_homo_coor = K*RT * orig_homo_coor
    local img_coor = torch.Tensor(2, w*h)
    img_coor[1] = torch.cdiv(new_homo_coor[1], new_homo_coor[3])
    img_coor[2] = torch.cdiv(new_homo_coor[2], new_homo_coor[3])
    img_coor:apply(torch.round)

    -- Set new img pixels
    local new_size = math.max(torch.max(img_coor[1])- torch.min(img_coor[1])+1, torch.max(img_coor[2])- torch.min(img_coor[2])+1)
    local new_offset_w, new_offset_h = torch.min(img_coor[1]), torch.min(img_coor[2])
    local new_img = torch.FloatTensor(3, new_size, new_size)
    new_img[1] = img_mean[1]
    new_img[2] = img_mean[2]
    new_img[3] = img_mean[3]
    for i = 1, w*h do
        local pixel_val = img[{{},{orig_homo_coor[2][i]+offset_h},{orig_homo_coor[1][i]+offset_w}}]
        new_img[{{},{img_coor[2][i]-new_offset_h+1},{img_coor[1][i]-new_offset_w+1}}] = pixel_val
        -- new_img[{{},{img_coor[i][2]-new_offset_h+1},{img_coor[i][1]-new_offset_w+1}}] = img[{{},{orig_homo_coor[i][2]+offset_h},{orig_homo_coor[i][1]+offset_w}}]
    end

    -- Save to file
    image.save(outname, new_img)
    return
end

perspect('000000.JPEG', '000000_ps1_round.JPEG', 1*math.pi/4, 0, 0)
perspect('000000.JPEG', '000000_ps2_round.JPEG', 0, 1*math.pi/4, 0)
perspect('000000.JPEG', '000000_ps3_round.JPEG', math.pi/4, math.pi/3, 0)
perspect('000000.JPEG', '000000_ps4_round.JPEG', 0,0,1*math.pi/3)
-- rotate('000000.JPEG', '000000_rotated2.JPEG', 2*math.pi/4)
-- rotate('000000.JPEG', '000000_rotated3.JPEG', 3*math.pi/4)
