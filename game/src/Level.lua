
local class = require 'middleclass'

-- クラス
local Layer = require 'Layer'
local Ground = require 'Ground'
local Block = require 'Block'
local Crate = require 'Crate'

-- モジュール
local Rectangle = require 'Rectangle'

-- エイリアス
local lg = love.graphics

-- レベルクラス
local Level = class 'Level'
Level:include(Rectangle)

-- レイヤー名
local layerNames = {
    'ground',
    'block',
    --'entity'
}

-- 初期化
function Level:initialize(sprites, unitWidth, unitHeight, numHorizontal, numVertical)
    -- デフォルト値
    self.unitWidth = unitWidth or 128
    self.unitHeight = unitHeight or 128
    self.numHorizontal = numHorizontal or 10
    self.numVertical = numVertical or 10

    -- 変数
    self.sprites = sprites
    self.layers = {
        ground = Layer(lg.newSpriteBatch(self.sprites.spriteSheet, self.numHorizontal * self.numVertical * 2), self.unitWidth, self.unitHeight, self.numHorizontal, self.numVertical),
        block = Layer(lg.newSpriteBatch(self.sprites.spriteSheet, self.numHorizontal * self.numVertical), self.unitWidth, self.unitHeight, self.numHorizontal, self.numVertical),
        entity = Layer(nil, unitWidth, unitHeight, numHorizontal, numVertical)
    }

    -- モジュールの初期化
    Rectangle.initialize(self, 0, 0, self:pixelWidth(), self:pixelHeight())
end

-- 更新
function Level:update(dt)
    for name, layer in pairs(self.layers) do
        layer:update(dt)
    end
end

-- 描画
function Level:draw()
    -- 静的なレイヤーを描画
    for i, name in ipairs(layerNames) do
        self.layers[name]:draw()
    end

    -- エンティティレイヤーを描画
    self:getLayer('entity'):draw()
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

-- 全てのマスをクリア
function Level:clearSquares()
    for name, layer in pairs(self.layers) do
        layer:clearSquares()
    end
end

-- マスを取得
function Level:getSquare(x, y, z)
    return self:getLayer(z):getSquare(x, y)
end

-- マスを設定
function Level:setSquare(x, y, z, it)
    return self:getLayer(z):setSquare(x, y, it)
end

-- スプライトバッチのビルド
function Level:buildSpriteBatch()
    -- 各レイヤーのスプライトバッチのビルド
    for name, layer in pairs(self.layers) do
        layer:buildSpriteBatch()
    end
end

-- レベルのロード
function Level:loadLevel(data)
    self:clearSquares()

    data = data or {
        width = 8,
        height = 8,
        groundFill = {
            type = 'stone'
        },
        ground = {
        },
        block = {
            {
                x = 0,
                y = 2,
                type = 'brick',
            },
            {
                x = 0,
                y = 3,
                type = 'brick',
            },
            {
                x = 0,
                y = 4,
                type = 'brick',
            },
        },
        entity = {

        }
    }
    
    for y = 1, self.numVertical do
        for x = 1, self.numHorizontal do
            self:setSquare(x, y, 'ground', Ground(self.sprites, self:toPixelPosition(x - 1, y - 1)))
        end
    end

    -- テスト配置
    self:setSquare(2, 2, 'block', Block(self.sprites, self:toPixelPosition(1, 1)))
    self:setSquare(4, 5, 'entity', Crate(self.sprites, self:toPixelPosition(3, 4)))

    -- スプライトバッチのビルド
    self:buildSpriteBatch()
end

return Level
