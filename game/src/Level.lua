
local class = require 'middleclass'

local Layer = require 'Layer'
local Ground = require 'Ground'
local Block = require 'Block'

-- モジュール
local Rectangle = require 'Rectangle'

-- レベルクラス
local Level = class 'Level'
Level:include(Rectangle)

-- 初期化
function Level:initialize(sprites, unitWidth, unitHeight, numHorizontal, numVertical)
    -- デフォルト値
    unitWidth = unitWidth or 128
    unitHeight = unitHeight or 128
    numHorizontal = numHorizontal or 10
    numVertical = numVertical or 10

    -- 変数
    self.sprites = sprites
    self.layers = {
        ground = Layer(unitWidth, unitHeight, numHorizontal, numVertical),
        entity = Layer(unitWidth, unitHeight, numHorizontal, numVertical)
    }

    -- マスの準備
    for y = 1, numVertical do
        for x = 1, numHorizontal do
            self:setSquare(x, y, 'ground', Ground(self.sprites, self:toPixelPosition(x - 1, y - 1)))
        end
    end

    self:setSquare(1, 1, 'entity', Block(self.sprites, self:toPixelPosition(0, 0)))

    -- モジュールの初期化
    Rectangle.initialize(self, 0, 0, self:pixelWidth(), self:pixelHeight())
end

-- 更新
function Level:update(dt)
end

-- 描画
function Level:draw()
    self.layers.ground:draw()
    self.layers.entity:draw()
end

-- ピクセル座標に変換する
function Level:toPixelPosition(x, y)
    return self.layers.ground:toPixelPosition(x, y)
end

-- レベル座標に変換する
function Level:toLevelPosition(x, y)
    return self.layers.ground:toLevelPosition(x, y)
end

-- 幅
function Level:pixelWidth()
    return self.layers.ground:pixelWidth()
end

-- 高さ
function Level:pixelHeight()
    return self.layers.ground:pixelHeight()
end

-- マスを取得
function Level:getSquare(x, y, z)
    return self.layers[z]:getSquare(x, y)
end

-- マスを設定
function Level:setSquare(x, y, z, it)
    self.layers[z]:setSquare(x, y, it)
end

return Level
