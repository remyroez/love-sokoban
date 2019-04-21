
local class = require 'middleclass'

-- モジュール
local Rectangle = require 'Rectangle'

-- レイヤークラス
local Layer = class 'Layer'
Layer:include(Rectangle)

-- 初期化
function Layer:initialize(unitWidth, unitHeight, numHorizontal, numVertical)
    -- 変数
    self.sprites = sprites
    self.unitWidth = unitWidth or 128
    self.unitHeight = unitHeight or 128
    self.numHorizontal = numHorizontal or 10
    self.numVertical = numVertical or 10

    -- マスの準備
    self.squares = {}

    -- モジュールの初期化
    Rectangle.initialize(self, 0, 0, self:pixelWidth(), self:pixelHeight())
end

-- 更新
function Layer:update(dt)
end

-- 描画
function Layer:draw()
    for y = 1, self.numVertical do
        for x = 1, self.numHorizontal do
            local square = self:getSquare(x, y)
            if square then
                square:draw()
            end
        end
    end
end

-- ピクセル座標に変換する
function Layer:toPixelPosition(x, y)
    return x * self.unitWidth, y * self.unitHeight
end

-- レベル座標に変換する
function Layer:toLevelPosition(x, y)
    return math.floor(x / self.unitWidth) + 1, math.floor(y / self.unitHeight) + 1
end

-- 幅
function Layer:pixelWidth()
    return self.unitWidth * self.numHorizontal
end

-- 高さ
function Layer:pixelHeight()
    return self.unitHeight * self.numVertical
end

-- マスを取得
function Layer:getSquare(x, y)
    if self.squares[y] == nil then
        self.squares[y] = {}
    end
    return self.squares[y][x]
end

-- マスを設定
function Layer:setSquare(x, y, it)
    if self.squares[y] == nil then
        self.squares[y] = {}
    end
    self.squares[y][x] = it
end

return Layer
