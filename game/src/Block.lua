
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

    -- タイプ
    self:setType()

    -- スプライトのサイズを取得
    local sw, sh = self:getSpriteSize(self:getCurrentSpriteName())

    -- 矩形モジュールの初期化
    Rectangle.initialize(self, x, y, w or sw, h or sh)
end

-- 更新
function Block:update(dt)
end

-- 描画
function Block:draw()
    self:drawSprite(self:getCurrentSpriteName(), self.x, self.y)
end

-- タイプの設定
function Block:setType(type)
    self.type = type or 'brick'
    return self
end

-- 現在のスプライト名を返す
function Block:getCurrentSpriteName()
    return spriteNames[self.type]
end

-- スプライトバッチへ追加
function Block:addCurrentSpriteToBatch(spriteBatch)
    self:addSpriteToBatch(spriteBatch, self:getCurrentSpriteName(), self.x, self.y)
end

return Block
