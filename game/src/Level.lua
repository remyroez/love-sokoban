
local class = require 'middleclass'

-- クラス
local Layer = require 'Layer'
local Ground = require 'Ground'
local Block = require 'Block'
local Crate = require 'Crate'

-- モジュール
local Rectangle = require 'Rectangle'

-- レベルクラス
local Level = class 'Level'
Level:include(Rectangle)

-- レイヤー名
local layerNames = {
    'ground',
    'entity'
}

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
        ground = Layer(self.sprites.spriteSheet, unitWidth, unitHeight, numHorizontal, numVertical),
        entity = Layer(self.sprites.spriteSheet, unitWidth, unitHeight, numHorizontal, numVertical)
    }

    -- マスの準備
    for y = 1, numVertical do
        for x = 1, numHorizontal do
            self:setSquare(x, y, 'ground', Ground(self.sprites, self:toPixelPosition(x - 1, y - 1)))
        end
    end

    -- テスト配置
    self:setSquare(2, 2, 'entity', Block(self.sprites, self:toPixelPosition(1, 1)))
    self:setSquare(4, 5, 'entity', Crate(self.sprites, self:toPixelPosition(3, 4)))

    -- モジュールの初期化
    Rectangle.initialize(self, 0, 0, self:pixelWidth(), self:pixelHeight())

    -- スプライトバッチのビルド
    self:buildSpriteBatch()
end

-- 更新
function Level:update(dt)
    for name, layer in pairs(self.layers) do
        layer:update(dt)
    end
end

-- 描画
function Level:draw()
    for i, name in ipairs(layerNames) do
        self.layers[name]:draw()
    end
end

-- レイヤーを返す
function Level:getLayer(z)
    return self.layers[z or 'ground']
end

-- ピクセル座標に変換する
function Level:toPixelPosition(x, y, z)
    return self:getLayer(z):toPixelPosition(x, y)
end

-- レベル座標に変換する
function Level:toLevelPosition(x, y, z)
    return self:getLayer(z):toLevelPosition(x, y)
end

-- ピクセル幅
function Level:pixelWidth(z)
    return self:getLayer(z):pixelWidth()
end

-- ピクセル高さ
function Level:pixelHeight(z)
    return self:getLayer(z):pixelHeight()
end

-- マスを取得
function Level:getSquare(x, y, z)
    return self:getLayer(z):getSquare(x, y)
end

-- マスを設定
function Level:setSquare(x, y, z, it)
    self:getLayer(z):setSquare(x, y, it)
end

-- スプライトバッチのビルド
function Level:buildSpriteBatch()
    -- 各レイヤーのスプライトバッチのビルド
    for name, layer in pairs(self.layers) do
        layer:buildSpriteBatch()
    end
end

return Level
