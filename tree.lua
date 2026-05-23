local Tree = {}
Tree.size = 384
Tree.list = {}

local MAP_W, MAP_H
local PATH_W = 640
local SEG_GAP = 384

local y1_top, y1_bot
local y2_top, y2_bot
local y3_top, y3_bot
local y4_top, y4_bot
local VR_x1, VL_x2

local function isOnPath(cx, cy)
    -- Segment 1 : de la gauche jusqu'au virage droit
    if cy >= y1_top and cy <= y1_bot
        and cx >= 0 and cx <= VR_x1 + PATH_W then return true end
    -- Virage droit (entre seg1 et seg2)
    if cx >= VR_x1 and cx <= MAP_W
        and cy >= y1_bot and cy <= y2_top then return true end
    -- Segment 2 : du virage gauche jusqu'à la droite
    if cy >= y2_top and cy <= y2_bot
        and cx >= VL_x2 - PATH_W and cx <= MAP_W then return true end
    -- Virage gauche (entre seg2 et seg3)
    if cx >= 0 and cx <= VL_x2
        and cy >= y2_bot and cy <= y3_top then return true end
    -- Segment 3 : de la gauche jusqu'au virage droit
    if cy >= y3_top and cy <= y3_bot
        and cx >= 0 and cx <= VR_x1 + PATH_W then return true end
    -- Virage droit (entre seg3 et seg4)
    if cx >= VR_x1 and cx <= MAP_W
        and cy >= y3_bot and cy <= y4_top then return true end
    -- Segment 4 : du virage gauche jusqu'à la droite
    if cy >= y4_top and cy <= y4_bot
        and cx >= VL_x2 - PATH_W and cx <= MAP_W then return true end
    return false
end

local function generatePath()
    local trees = {}
    local s = Tree.size
    local half = s / 2

    -- Passe 1 : grille normale
    local ty = 0
    while ty < MAP_H do
        local tx = -s  -- commence un arbre avant le bord gauche
        while tx < MAP_W + s do  -- finit un arbre après le bord droit
            local cx = tx + half
            local cy = ty + half
            if not isOnPath(cx, cy) then
                table.insert(trees, { x = tx, y = ty })
            end
            tx = tx + s
        end
        ty = ty + s
    end

    -- Passe 2 : grille décalée
    ty = -half
    while ty < MAP_H do
        local tx = -s - half
        while tx < MAP_W + s do
            local cx = tx + half
            local cy = ty + half
            if not isOnPath(cx, cy) then
                table.insert(trees, { x = tx, y = ty })
            end
            tx = tx + s
        end
        ty = ty + s
    end

    return trees
end

function Tree.load(imageTree, imageMap)
    Tree.image = imageTree
    Tree.scaleX = Tree.size / imageTree:getWidth()
    Tree.scaleY = Tree.size / imageTree:getHeight()

    MAP_W = imageMap:getWidth() * 2
    MAP_H = imageMap:getHeight() * 2

    local totalH = 4 * PATH_W + 3 * SEG_GAP
    local startY = math.floor((MAP_H - totalH) / 2)

    y1_top = startY
    y1_bot = y1_top + PATH_W
    y2_top = y1_bot + SEG_GAP
    y2_bot = y2_top + PATH_W
    y3_top = y2_bot + SEG_GAP
    y3_bot = y3_top + PATH_W
    y4_top = y3_bot + SEG_GAP
    y4_bot = y4_top + PATH_W

    VR_x1 = MAP_W - PATH_W * 2
    VL_x2 = PATH_W * 2

    Tree.list = generatePath()
end

function Tree.draw()
    table.sort(Tree.list, function(a, b) return a.y < b.y end)
    love.graphics.setColor(1, 1, 1)
    for _, t in ipairs(Tree.list) do
        love.graphics.draw(Tree.image, t.x, t.y, 0, Tree.scaleX, Tree.scaleY)
    end
end

function Tree.checkCollision(player)
    local pr = 40
    for _, t in ipairs(Tree.list) do
        local closestX = math.max(t.x, math.min(player.x, t.x + Tree.size))
        local closestY = math.max(t.y, math.min(player.y, t.y + Tree.size))
        local dx = player.x - closestX
        local dy = player.y - closestY
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist < pr and dist > 0 then
            local overlap = pr - dist
            player.x = player.x + (dx / dist) * overlap
            player.y = player.y + (dy / dist) * overlap
        end
    end
end

return Tree