
local class = require 'middleclass'

-- モジュール
local Sprite = require 'Sprite'
local Rectangle = require 'Rectangle'

-- 地面クラス
local Ground = class 'Ground'
Ground:include(Sprite)
Ground:include(Rectangle)

-- スプライト名
local spriteNames = {
    ground = {
        green = 'ground_03.png',
        stone = 'ground_04.png',
        soil = 'ground_05.png',
    },
    mark = {
        wood = 'environment_02.png',
        red = 'environment_05.png',
        blue = 'environment_08.png',
        green = 'environment_10.png',
        stone = 'environment_14.png',
    }
}

-- 初期化
function Ground:initialize(sprite, x, y, w, h)
    -- モジュールの初期化
    Sprite.initialize(self, sprite)

    -- タイプ
    self:setType('stone')

    -- 地面スプライトのサイズを取得
    local sw, sh = self:getSpriteSize(self:getGroundSpriteName())

    -- 矩形モジュールの初期化
    Rectangle.initialize(self, x, y, w or sw, h or sh)
end

-- 更新
function Ground:update(dt)
end

-- 描画
function Ground:draw()
    -- 地面の描画
    self:drawSprite(self:getGroundSpriteName(), self.x, self.y)

    -- マークの描画
    if self.mark then
        self:drawSprite(self:getMarkSpriteName(), self.x, self.y)
    end
end

-- タイプの設定
function Ground:setType(type, mark)
    self.type = type or 'stone'
    self.mark = mark
    return self
end

-- 地面のスプライト名を返す
function Ground:getGroundSpriteName()
    return spriteNames.ground[self.type]
end

-- マークのスプライト名を返す
function Ground:getMarkSpriteName()
    return spriteNames.mark[self.mark]
end

-- スプライトバッチへ追加
function Ground:addCurrentSpriteToBatch(spriteBatch)
    -- 地面の描画
    self:addSpriteToBatch(spriteBatch, self:getGroundSpriteName(), self.x, self.y)

    -- マークの描画
    if self.mark then
        self:addSpriteToBatch(spriteBatch, self:getMarkSpriteName(), self.x, self.y)
    end
end

return Ground
