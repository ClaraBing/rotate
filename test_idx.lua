require 'image'

local function rotate(theta)
    local w, h = torch.random(50,1200), torch.random(10,900)
    -- Find output img size
    local side = math.max(math.abs(w*math.sin(theta)) + math.abs(h*math.cos(theta)), math.abs(w*math.cos(theta)) + math.abs(h*math.sin(theta)))
    local full_side = math.ceil(math.sqrt(2) * side)
    local w_start, h_start = torch.floor((full_side-w)/2), torch.floor((full_side-h)/2)
    local w_end, h_end =  torch.floor((full_side+w)/2), torch.floor((full_side+h)/2)
    if w_start+w-1 > full_side or h_start+h-1 > full_side or w_start == 0 or h_start == 0 then
        print('w: ' .. w .. ' / h: ' .. h .. ' / full_side: ' .. full_side )
    end
end

-- local img = image.load('000000.JPEG')
-- for i=4,12,4 do
for iter = 1,200000 do
    for i=-3,3 do
        rotate(i*math.pi/8)
    -- image.save('rand_'..i..'_'..iter..'.jpg', rotated)
    end
end
-- end
