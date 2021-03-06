
local class = require 'middleclass'
local stateful = require 'stateful'

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
Level:include(stateful)
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

-- 逆方向
local reverseDirections = {
    up = 'down',
    down = 'up',
    left = 'right',
    right = 'left'
}

-- 方向チェック用
local directionChecks = {
    up = 1,
    down = 1,
    left = 1,
    right = 1
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
function Level:initialize(sprites, sounds, unitWidth, unitHeight, numHorizontal, numVertical)
    -- デフォルト値
    self.unitWidth = unitWidth or 128
    self.unitHeight = unitHeight or 128
    self.numHorizontal = numHorizontal or 10
    self.numVertical = numVertical or 10

    self.players = {}
    self.crates = {}
    self.speed = 0.1
    self.step = 0

    -- 変数
    self.sprites = sprites
    self.sounds = sounds or {}
    self.layers = {
        ground = Layer(lg.newSpriteBatch(self.sprites.spriteSheet, self.numHorizontal * self.numVertical * 2), self.unitWidth, self.unitHeight, self.numHorizontal, self.numVertical),
        block = Layer(lg.newSpriteBatch(self.sprites.spriteSheet, self.numHorizontal * self.numVertical), self.unitWidth, self.unitHeight, self.numHorizontal, self.numVertical),
        entity = Layer(nil, unitWidth, unitHeight, numHorizontal, numVertical)
    }
    self.onClear = nil

    self.undos = {}

    -- モジュールの初期化
    Rectangle.initialize(self, math.ceil(self.unitWidth / 2), math.ceil(self.unitHeight / 2), self:pixelWidth(), self:pixelHeight())
end

-- 更新
function Level:update(dt)
end

-- 描画
function Level:draw()
    self:drawLayers()
end

-- キー入力
function Level:keypressed(key, scancode, isrepeat)
end

-- マウス入力
function Level:mousepressed(x, y, button, istouch, presses)
end

-- クリア済みかどうか
function Level:cleared()
    return false
end

-- クリア判定
function Level:checkClear()
    local clear = true
    for _, crate in ipairs(self.crates) do
        if not crate:movable() then
            -- 移動中ならしてない
            clear = false
            break
        elseif not crate.fit then
            -- 一致してないならしてない
            clear = false
            break
        else
            -- 一致した
        end
    end
    return clear
end

-- プレイヤー座標を返す
function Level:getPlayerPosition()
    local x, y = 0, 0

    if #self.players > 0 then
        for _, player in ipairs(self.players) do
            x = x + player.x
            y = y + player.y
        end

        x = x / #self.players
        y = y / #self.players
    end

    return x, y
end

-- プレイヤー操作
function Level:controlPlayers()
    -- 移動したかどうか
    local moved = false

    -- 速度
    local rate = 1
    local dash = false

    -- 各方向
    for _, direction in ipairs(directions) do
        -- キー入力
        if lk.isDown(direction) then
            -- 速度
            if lk.isDown('lshift') or lk.isDown('rshift') then
                -- ダッシュ
                rate = 0.5
                dash = true
            elseif lk.isDown('lctrl') or lk.isDown('rctrl') then
                -- ゆっくり
                rate = 2
            end
            -- 各プレイヤー移動
            for _, player in ipairs(self.players) do
                if player:movable() then
                    moved = self:movePlayer(player, direction, self.speed * rate, not dash) or moved
                end
            end
        end
    end

    -- 移動したらステップをカウントアップ
    if moved then
        self.step = self.step + 1
    elseif lk.isDown('backspace') then
        local ok = true
        for _, player in ipairs(self.players) do
            if not player:movable() then
                ok = false
                break
            end
        end
        if ok then
            self:undo(self.speed * rate)
        end
    end
end

-- プレイヤー移動処理
function Level:movePlayer(player, direction, duration, push)
    duration = duration or 0.25
    push = push == nil and true or push

    local action = {}

    -- 移動したかどうか
    local moved = false

    if not player then
        -- プレイヤーが無効

    elseif not directionChecks[direction] then
        -- 方向が無効

    else
        -- 移動元座標の取得
        local fromX, fromY = self:toLevelPosition(player.x, player.y)

        -- 移動量の取得
        local moveX, moveY = directionalOffset(direction)

        -- 移動先座標の計算
        local toX, toY = fromX + moveX, fromY + moveY

        local ok = false

        if self:getSquare(toX, toY, 'block') then
            -- ブロックには乗れない
            ok = false
        else
            -- 移動先のエンティティを押し出す
            local entityOk = true
            local entity = self:getSquare(toX, toY, 'entity')
            if entity then
                if not push then
                    -- 押さない
                    entityOk = false
                elseif not entity:movable() then
                    -- エンティティは動かせない
                    entityOk = false
                elseif self:getSquare(toX + moveX, toY + moveY, 'block') then
                    -- エンティティの移動先にブロック
                    entityOk = false
                elseif self:moveSquare(toX, toY, toX + moveX, toY + moveY, 'entity') then
                    -- エンティティを移動できた
                    entity:move(direction, moveX * self.unitWidth, moveY * self.unitHeight, duration)

                    -- ＳＥ
                    self.sounds.push:seek(0)
                    self.sounds.push:play()

                    local beforeFit = entity.fit

                    -- 移動先のマークが一致した
                    local ground = self:getSquare(toX + moveX, toY + moveY, 'ground')
                    if ground then
                        entity:setFit(ground.mark ~= nil and ground.mark == entity.type)
                    end

                    table.insert(
                        action,
                        {
                            target = entity,
                            fromX = toX,
                            fromY = toY,
                            toX = toX + moveX,
                            toY = toY + moveY,
                            direction = direction,
                            moveX = moveX * self.unitWidth,
                            moveY = moveY * self.unitHeight,
                            layer = 'entity',
                            fit = beforeFit
                        }
                    )
                else
                    -- エンティティを移動できなかった
                    entityOk = false
                end
            end
            -- エンティティの移動
            if not entityOk then
                -- 移動先に問題があった
                ok = false
            elseif self:moveSquare(fromX, fromY, toX, toY, 'entity') then
                -- エンティティを移動させた
                ok = true
            else
                -- 移動できなかった
                ok = false
            end
        end
        -- プレイヤーの移動
        if ok then
            -- 移動
            player:move(direction, moveX * self.unitWidth, moveY * self.unitHeight, duration)
            table.insert(
                action,
                {
                    target = player,
                    fromX = fromX,
                    fromY = fromY,
                    toX = toX,
                    toY = toY,
                    direction = direction,
                    moveX = moveX * self.unitWidth,
                    moveY = moveY * self.unitHeight,
                    layer = 'entity'
                }
            )
            moved = true
        else
            -- 方向転換のみ
            player:resetDirection(direction)
        end
    end

    -- アンドゥリストに入れる
    if moved then
        table.insert(self.undos, action)
    end

    return moved
end

-- アンドゥ
function Level:undo(duration)
    duration = duration or 0.25

    -- アクションが無ければ何もしない
    if #self.undos == 0 then
        return
    end

    -- 最後のアクションを取り出す
    local actions = self.undos[#self.undos]
    table.remove(self.undos)

    for i = 1, #actions do
        local action = actions[#actions + 1 - i]
        print(tostring(action), i, #actions + 1 - i)
        self:moveSquare(action.toX, action.toY, action.fromX, action.fromY, action.layer)
        action.target:move(
            action.direction,
            -action.moveX,
            -action.moveY,
            duration
        )
        if action.fit ~= nil then
            action.target:setFit(action.fit)
        end
    end

    self.step = self.step - 1
end

-- 各レイヤー更新
function Level:updateLayers(dt)
    for name, layer in pairs(self.layers) do
        layer:update(dt)
    end
end

-- 各レイヤー描画
function Level:drawLayers()
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

    self.step = 0
    self.undos = {}

    -- ダミーデータ
    data = data or {}

    -- ステージのマス目
    local numHorizontal = 0
    local numVertical = 0

    self.players = {}
    self.crates = {}

    local crateType = 'wood'
    local groundType = 'stone'
    local blockType = 'brick'

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
                self:setSquare(j, i, 'ground', Ground(self.sprites, x, y)):setType(groundType)
            elseif cell == '.' then
                -- マーク付き地面
                self:setSquare(j, i, 'ground', Ground(self.sprites, x, y)):setType(groundType, crateType)
            else
                -- エンティティ
                local set = true
                if cell == 'X' then
                    -- ブロック
                    self:setSquare(j, i, 'block', Block(self.sprites, x, y)):setType(blockType)
                elseif cell == '*' or cell == '&' then
                    -- 箱
                    local crate = self:setSquare(j, i, 'entity', Crate(self.sprites, x, y)):setType(crateType, cell == '&')
                    crate.onMoved = function ()
                    end
                    crate.onFit = function ()
                        self.sounds.fit:seek(0)
                        self.sounds.fit:play()
                    end
                    crate:gotoState 'place'
                    table.insert(self.crates, crate)
                elseif cell == '@' then
                    -- プレイヤー
                    local player = self:setSquare(j, i, 'entity', Player(self.sprites, x, y, self.unitWidth, self.unitHeight))
                    player:gotoState('stand', 'down')
                    table.insert(self.players, player)
                else
                    -- 空
                    set = false
                end

                -- 地面
                if not set then
                    -- 何も置かなかったので、地面も置かない
                elseif cell == '&' then
                    self:setSquare(j, i, 'ground', Ground(self.sprites, x, y)):setType(groundType, crateType)
                else
                    self:setSquare(j, i, 'ground', Ground(self.sprites, x, y)):setType(groundType)
                end
            end
        end
    end

    -- リサイズ
    self:resize(numHorizontal, numVertical)

    -- スプライトバッチのビルド
    self:buildSpriteBatch()
end

-- プレイステート
local Play = Level:addState 'play'

-- プレイ: ステート開始
function Play:enteredState(...)
    self.sounds.ingame:play()
end

-- プレイ: ステート終了
function Play:exitedState(...)
    self.sounds.ingame:stop()
end

-- プレイ: 更新
function Play:update(dt)
    -- プレイヤー操作
    self:controlPlayers()

    -- 各レイヤー更新
    self:updateLayers(dt)

    -- クリア判定
    if self:checkClear() then
        self:gotoState 'clear'
    end
end

-- クリアステート
local Clear = Level:addState 'clear'

-- プレイ: ステート開始
function Clear:enteredState(...)
    self.sounds.clear:play()
    if type(self.onClear) == 'function' then
        self.onClear()
    end
end

-- クリア: 更新
function Clear:update(dt)
    -- 各レイヤー更新
    self:updateLayers(dt)
end

-- クリア: クリア済みかどうか
function Clear:cleared()
    return true
end

return Level
