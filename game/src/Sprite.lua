
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

-- スプライトの描画
function Sprite:drawSprite(name, x, y)
    local quad = self:getSprite(name)
    local _, __, w, h = quad:getViewport()
    self.spriteSheet:draw(name, x - w / 2, y - h / 2)
end

return Sprite
