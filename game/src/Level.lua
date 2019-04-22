
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
local lk = love.keyboard

-- レベルクラス
local Level = class 'Level'
Level:include(Rectangle)

-- レイヤー名
local layerNames = {
    'ground',
    'block',
    --'entity'
}

-- 方向
local directions = {
    'up',
    'down',
    'left',
    'right'
}

-- 方向に応じたオフセット値を返す
local function directionalOffset(direction, x, y)
    x = x or 1
    y = y or 1
    if direction == 'up' then
        return 0, -y
    elseif direction == 'down' then
        return 0, y
    elseif direction == 'left' then
        return -x, 0
    elseif direction == 'right' then
        return x, 0
    end
end

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
    -- プレイヤーの移動
    if self.player and self.player:movable() then
        for _, direction in ipairs(directions) do
            if lk.isDown(direction) then
                self:movePlayer(direction)
            end
        end
    end

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
end

-- マウス入力
function Level:mousepressed(x, y, button, istouch, presses)
end

-- マウス入力
function Level:movePlayer(key)
    if self.player and self.player:movable() and (key == 'up' or key == 'down' or key == 'left' or key == 'right') then
        local fromX, fromY = self:toLevelPosition(self.player.x, self.player.y)
        local moveX, moveY = directionalOffset(key)
        local toX, toY = fromX + moveX, fromY + moveY
        local ok = ok
        if self:getSquare(toX, toY, 'block') then
            -- ブロックには乗れない
            ok = false
        else
            local entityOk = true
            local entity = self:getSquare(toX, toY, 'entity')
            if entity then
                if not entity:movable() then
                    -- エンティティは動かせない
                    entityOk = false
                elseif self:getSquare(toX + moveX, toY + moveY, 'block') then
                    -- エンティティの移動先にブロック
                    entityOk = false
                elseif self:moveSquare(toX, toY, toX + moveX, toY + moveY, 'entity') then
                    -- エンティティを移動できた
                    entity:move(key, moveX * self.unitWidth, moveY * self.unitHeight)
                else
                    -- エンティティを移動できなかった
                    entityOk = false
                end
            end
            if not entityOk then
                -- 移動先に問題があった
                ok = false
            elseif self:moveSquare(fromX, fromY, toX, toY, 'entity') then
                -- 問題ない
                ok = true
            else
                -- 移動できなかった
                ok = false
            end
        end
        -- 移動、または方向転換
        if ok then
            self.player:move(key, moveX * self.unitWidth, moveY * self.unitHeight)
        else
            self.player:resetDirection(key)
        end
    end
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

-- マスを移動
function Level:moveSquare(fromX, fromY, toX, toY, z)
    return self:getLayer(z):moveSquare(fromX, fromY, toX, toY)
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
                    local crate = self:setSquare(j, i, 'entity', Crate(self.sprites, x, y))
                    crate:gotoState 'place'
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
