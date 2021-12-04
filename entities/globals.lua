function getPolySize(vertices)
    local minx, maxx, miny, maxy = vertices[1], vertices[1], vertices[2], vertices[2]
    for i = 1, #vertices - 1, 2 do
        minx = math.min(minx, vertices[i])
        maxx = math.max(maxx, vertices[i])
        miny = math.min(miny, vertices[i + 1])
        maxy = math.max(maxy, vertices[i + 1])
    end

    return maxx - minx, maxy - miny
end

-- Separate balls from solids.
-- Returns [ball body], [ball definition], [solid body], [solid definition]
function separateSolids(a, b)
    local aa = a:getUserData() or {}
    local bb = b:getUserData() or {}
    if (aa.type == "ball") then
        return a:getBody(), aa, b:getBody(), bb
    elseif (bb.type == "ball") then
        return b:getBody(), bb, a:getBody(), aa
    end
end
