
-- スプライトモジュール
local Sprite = {}

-- 初期化
function Sprite:initialize(sprite)
    -- スプライトシート
    self.spriteSheet = sprite
end

-- スプライトの取得
function Sprite:getSprite(name)
    return self.spriteSheet.quad[name]
end

-- スプライトのサイズの取得
function Sprite:getSpriteSize(name)
    local quad = self:getSprite(name)
    local _, __, w, h = quad:getViewport()
    return w, h
end

-- スプライトの描画
function Sprite:drawSprite(name, x, y)
    local w, h = self:getSpriteSize(name)
    self.spriteSheet:draw(name, math.ceil(x - w / 2), math.ceil(y - h / 2))
end

-- スプライトバッチへ追加
function Sprite:addSpriteToBatch(spriteBatch, name, x, y)
    local w, h = self:getSpriteSize(name)
    spriteBatch:add(self:getSprite(name), math.ceil(x - w / 2), math.ceil(y - h / 2))
end

return Sprite
