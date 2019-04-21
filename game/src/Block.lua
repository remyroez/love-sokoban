
local class = require 'middleclass'

-- モジュール
local Sprite = require 'Sprite'
local Rectangle = require 'Rectangle'

-- ブロッククラス
local Block = class 'Block'
Block:include(Sprite)
Block:include(Rectangle)

-- スプライト名
local spriteNames = {
    brick = 'block_01.png',
    brick2 = 'block_02.png',
    stone = 'block_03.png',
    adobe = 'block_04.png',
}

-- 初期化
function Block:initialize(sprite, x, y, w, h)
    -- モジュールの初期化
    Sprite.initialize(self, sprite)
    Rectangle.initialize(self, x, y, w, h)

    -- タイプ
    self.type = 'brick'
end

-- 更新
function Block:update(dt)
end

-- 描画
function Block:draw()
    self:drawSprite(self:getCurrentSpriteName(), self.x, self.y)
end

-- 現在のスプライト名を返す
function Block:getCurrentSpriteName()
    return spriteNames[self.type]
end

return Block
