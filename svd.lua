require 'image'

local function perspect(fname, outname, targetCoor)
    -- fname/outname: strings of input/output file names
    -- targetCoor: 4*2 tensor containing (x,y) coor of the target image
    local img = image.load(fname, 3, 'float')
    local img_mean = img:mean(2):mean(3):reshape(3)
    local w, h = img:size(3), img:size(2)
    local f = 2*(w+h)

    -- Ah = 0 -> (A^T * A)h = 0 -> SVD: (A^T * A) = UD(U^T) -> h := last col of U
    local srcCoor = torch.Tensor({{0,0}, {w,0}, {w,h}, {0,h}})
    local A = torch.Tensor(8, 9)
    for i=1,4 do
        A[2*i-1] = torch.Tensor({srcCoor[i][1],srcCoor[i][2],1, 0,0,0,
            -srcCoor[i][1]*targetCoor[i][1], -srcCoor[i][2]*targetCoor[i][1], -targetCoor[i][1]})
        A[2*i] = torch.Tensor({0,0,0, srcCoor[i][1],srcCoor[i][2],1,
            -srcCoor[i][1]*targetCoor[i][2], -srcCoor[i][2]*targetCoor[i][2], -targetCoor[i][1]})
    end
    local ATA = A:transpose(2,1) * A
    local U = torch.svd(ATA)
    -- H (the homography) is the last column of U
    local H = torch.Tensor(3,3)
    H[1] = U[{{9},{1,3}}]
    H[2] = U[{{9},{4,6}}]
    H[3] = U[{{9},{7,9}}]

    local orig_coor = torch.Tensor(3, w*h)
    for 
    local tmp_new_coor = H*image.save('rand_4_1.jpg', rotated)

    local HI = torch.inverse(H)

    -- Find coor on the original image
    local sample_orig_coor = 
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

perspect('000000.JPEG', '000000_ps1_inf.JPEG', 1*math.pi/4, 0, 0)
-- perspect('000000.JPEG', '000000_ps2_round.JPEG', 0, 1*math.pi/4, 0)
-- perspect('000000.JPEG', '000000_ps3_round.JPEG', math.pi/4, math.pi/3, 0)
-- perspect('000000.JPEG', '000000_ps4_round.JPEG', 0,0,1*math.pi/3)
-- rotate('000000.JPEG', '000000_rotated2.JPEG', 2*math.pi/4)
-- rotate('000000.JPEG', '000000_rotated3.JPEG', 3*math.pi/4)
