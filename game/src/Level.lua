
local class = require 'middleclass'

-- クラス
local Layer = require 'Layer'
local Ground = require 'Ground'
local Block = require 'Block'
local Crate = require 'Crate'
local Player = require 'Player'

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
    self.player = nil

    -- 変数
    self.sprites = sprites
    self.layers = {
        ground = Layer(lg.newSpriteBatch(self.sprites.spriteSheet, self.numHorizontal * self.numVertical * 2), self.unitWidth, self.unitHeight, self.numHorizontal, self.numVertical),
        block = Layer(lg.newSpriteBatch(self.sprites.spriteSheet, self.numHorizontal * self.numVertical), self.unitWidth, self.unitHeight, self.numHorizontal, self.numVertical),
        entity = Layer(nil, unitWidth, unitHeight, numHorizontal, numVertical)
    }

    -- モジュールの初期化
    Rectangle.initialize(self, math.ceil(self.unitWidth / 2), math.ceil(self.unitHeight / 2), self:pixelWidth(), self:pixelHeight())
end

-- 更新
function Level:update(dt)
    for name, layer in pairs(self.layers) do
        layer:update(dt)
    end
end

-- 描画
function Level:draw()
    lg.push()
    lg.scale(0.25, 0.25)
    lg.translate(self.x, self.y)

    -- 静的なレイヤーを描画
    for i, name in ipairs(layerNames) do
        self.layers[name]:draw()
    end

    -- エンティティレイヤーを描画
    self:getLayer('entity'):draw()

    lg.pop()
end

-- キー入力
function Level:keypressed(key, scancode, isrepeat)
    if self.player then
        self.player:move(key)
    end
end

-- マウス入力
function Level:mousepressed(x, y, button, istouch, presses)
end

-- レイヤーを返す
function Level:getLayer(z)
    return self.layers[z or 'ground']
end

-- サイズの変更
function Level:resize(numHorizontal, numVertical)
    for name, layer in pairs(self.layers) do
        layer:resize(numHorizontal, numVertical)
    end
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
    -- マスのクリア
    self:clearSquares()

    -- ダミーデータ
    data = data or {
        '    XXXXX             ',
        '    X   X             ',
        '    X*  X             ',
        '  XXX  *XXX           ',
        '  X  *  * X           ',
        'XXX X XXX X     XXXXXX',
        'X   X XXX XXXXXXX  ..X',
        'X *  *             ..X',
        'XXXXX XXXX X@XXXX  ..X',
        '    X      XXX  XXXXXX',
        '    XXXXXXXX          ',
    }

    -- ステージのマス目
    local numHorizontal = 0
    local numVertical = 0
    local player

    for i, line in ipairs(data) do
        numVertical = i
        local length = string.len(line)
        if numHorizontal < length then
            numHorizontal = length
        end
        for j = 1, length do
            local x, y = self:toPixelPosition(j - 1, i - 1)
            local cell = string.sub(line, j, j)
            if cell == ' ' then
                -- 地面
                self:setSquare(j, i, 'ground', Ground(self.sprites, x, y))
            elseif cell == '.' then
                -- マーク付き地面
                self:setSquare(j, i, 'ground', Ground(self.sprites, x, y)):setType('stone', 'wood')
            else
                -- 地面
                self:setSquare(j, i, 'ground', Ground(self.sprites, x, y))
                if cell == 'X' then
                    -- ブロック
                    self:setSquare(j, i, 'block', Block(self.sprites, x, y))
                elseif cell == '*' then
                    -- 箱
                    self:setSquare(j, i, 'entity', Crate(self.sprites, x, y))
                elseif cell == '@' then
                    -- プレイヤー
                    player = self:setSquare(j, i, 'entity', Player(self.sprites, x, y, 128, 128))
                end
            end
        end
    end

    -- プレイヤーを保持
    self.player = player
    self.player:gotoState('stand', 'down')
    print(self.player.x, self.player.y)

    -- リサイズ
    self:resize(numHorizontal, numVertical)

    -- スプライトバッチのビルド
    self:buildSpriteBatch()
end

return Level
