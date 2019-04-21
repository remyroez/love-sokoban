
local class = require 'middleclass'

-- モジュール
local Rectangle = require 'Rectangle'

-- エイリアス
local lg = love.graphics

-- レイヤークラス
local Layer = class 'Layer'
Layer:include(Rectangle)

-- 初期化
function Layer:initialize(spriteBatch, unitWidth, unitHeight, numHorizontal, numVertical)
    -- 変数
    self.spriteBatch = spriteBatch
    self.unitWidth = unitWidth or 128
    self.unitHeight = unitHeight or 128
    self.numHorizontal = numHorizontal or 10
    self.numVertical = numVertical or 10

    -- マスの準備
    self.squares = {}

    -- モジュールの初期化
    Rectangle.initialize(self, 0, 0, self:pixelWidth(), self:pixelHeight())

    -- 変更フラグ
    self.dirty = false
end

-- 更新
function Layer:update(dt)
    -- すべてのマスの更新
    for y = 1, self.numVertical do
        for x = 1, self.numHorizontal do
            local square = self:getSquare(x, y)
            if square then
                square:update(dt)
                self.dirty = square.dirty or self.dirty
            end
        end
    end

    -- 内容に変化があればスプライトバッチをリビルド
    if self.dirty then
        self:buildSpriteBatch()
        self.dirty = false
    end
end

-- 描画
function Layer:draw()
    if self.spriteBatch then
        -- スプライトバッチがあればそれで描画
        lg.draw(self.spriteBatch, self.x, self.y)
    else
        -- 無ければ個別に描画
        for y = 1, self.numVertical do
            for x = 1, self.numHorizontal do
                local square = self:getSquare(x, y)
                if square then
                    square:draw()
                end
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

-- ピクセル幅
function Layer:pixelWidth()
    return self.unitWidth * self.numHorizontal
end

-- ピクセル高さ
function Layer:pixelHeight()
    return self.unitHeight * self.numVertical
end

-- 全てのマスをクリア
function Layer:clearSquares()
    self.squares = {}

    -- スプライトバッチのクリア
    if self.spriteBatch then
        self.spriteBatch:clear()
    end
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
    self.dirty = true
    return self.squares[y][x]
end

-- スプライトバッチのビルド
function Layer:buildSpriteBatch()
    if self.spriteBatch then
        -- スプライトバッチのクリア
        self.spriteBatch:clear()

        -- 各マスをスプライトバッチに追加
        for y = 1, self.numVertical do
            for x = 1, self.numHorizontal do
                local square = self:getSquare(x, y)
                if square then
                    square:addCurrentSpriteToBatch(self.spriteBatch)
                end
            end
        end
    end
end

return Layer
