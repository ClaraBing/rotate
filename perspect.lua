require 'image'

-- Perspective change from coordinates
local function coor(img, src, dst)
    -- Obtain 3x3 transformation matrix
    local A, B = torch.FloatTensor(8,8), torch.FloatTensor(8)
    local w, h = img:size(3), img:size(2)
    for i = 1,4 do
        A[i][1], A[i][2], A[i][3] = src[i][1], src[i][2], 1
        A[i][4], A[i][5], A[i][6] = 0,0,0
        A[i][7], A[i][8] = -src[i][1]*dst[i][1], -src[i][2]*dst[i][1]
        A[i+4][1], A[i+4][2], A[i+4][3] = 0,0,0
        A[i+4][4], A[i+4][5], A[i+4][6] = src[i][1], src[i][2], 1
        A[i+4][7], A[i+4][8] = -src[i][1]*dst[i][2], -src[i][2]*dst[i][2]
        B[i] = dst[i][1]
        B[i+4] = dst[i][2]
    end
    local X = torch.gesv(B, A):reshape(8)
    local M = torch.inverse(torch.cat(X, torch.FloatTensor({1})):reshape(3,3))
    
    -- Calculate src coor for sampling
    local src_xmin, src_xmax = torch.min(src[{{},{1}}]), torch.max(src[{{},{1}}])
    local src_ymin, src_ymax = torch.min(src[{{},{2}}]), torch.max(src[{{},{2}}])
    local xmin, xmax = torch.min(dst[{{},{1}}]), torch.max(dst[{{},{1}}])
    local ymin, ymax = torch.min(dst[{{},{2}}]), torch.max(dst[{{},{2}}])
    local dst_h, dst_w = xmax-xmin+1, ymax-ymin+1
    local dst_homo = torch.FloatTensor(3,dst_w*dst_h)
    for dx = 0,dst_h-1 do
        for dy = 0,dst_w-1 do
            dst_homo[1][1+dy + dx*dst_w] = xmin+dx
            dst_homo[2][1+dy + dx*dst_w] = ymin+dy
            dst_homo[3][1+dy + dx*dst_w] = 1
        end
    end
    local src_homo = M * dst_homo
    local src_coor = torch.Tensor(2, dst_w*dst_h)
    src_coor[1] = torch.cdiv(src_homo[1], src_homo[3])
    src_coor[2] = torch.cdiv(src_homo[2], src_homo[3])
    src_coor = torch.round(src_coor)

    -- Set result image
    local result = torch.FloatTensor(3, dst_h, dst_w):zero() + 0.6
    for dx = 0,dst_h-1 do
        for dy = 0,dst_w-1 do
            local src_x, src_y = src_coor[1][1+dy + dx*dst_w], src_coor[2][1+dy + dx*dst_w]
            if src_x>=src_xmin and src_x<=src_xmax and src_y>=src_ymin and src_y<=src_ymax then
                local val = img[{{}, {src_x-src_xmin+1}, {src_y-src_ymin+1}}]
                result[{{},{dx+1},{dy+1}}] = val -- img[{{}, {src_x-src_xmin+1}, {src_y-src_ymin+1}}]
            end
        end
    end

    return result
end


local img = image.load('000000.JPEG')
local w, h = img:size(3), img:size(2)
-- In this example, the 4 vertices of the image are arranged counter-clockwise, starting from the bottom left; (0,0) is the image center.
local src = torch.IntTensor(4,2)
src[1][1], src[1][2] = 1+torch.floor(-h/2), 1+torch.floor(-w/2)
src[2][1], src[2][2] = torch.floor(h/2), 1+torch.floor(-w/2)
src[3][1], src[3][2] = torch.floor(h/2), torch.floor(w/2)
src[4][1], src[4][2] = 1+torch.floor(-h/2), torch.floor(w/2)
local dst = torch.IntTensor(4,2)
dst[1][1], dst[1][2] = src[1][1], torch.floor(src[1][2]/2)
dst[2][1], dst[2][2] = src[2][1], src[2][2]
dst[3][1], dst[3][2] = torch.floor(src[3][1]/2), src[3][2]
dst[4][1], dst[4][2] = torch.floor(src[4][1]/2), torch.floor(src[4][2]/2)

local warped = coor(img, src, dst)
image.save('coor_test.jpg', warped)
