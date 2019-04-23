
local class = require 'middleclass'
local stateful = require 'stateful'

-- モジュール
local Sprite = require 'Sprite'
local Rectangle = require 'Rectangle'
local Animation = require 'Animation'
local Movement = require 'Movement'

-- プレイヤークラス
local Player = class 'Player'
Player:include(stateful)
Player:include(Sprite)
Player:include(Rectangle)
Player:include(Animation)
Player:include(Movement)

-- 各方向のスプライト名
local spriteNames = {
    left = {
        'player_19.png',
        'player_18.png',
        'player_20.png',
        'player_18.png',
    },
    right = {
        'player_16.png',
        'player_15.png',
        'player_17.png',
        'player_15.png',
    },
    up = {
        'player_07.png',
        'player_06.png',
        'player_08.png',
        'player_06.png',
    },
    down = {
        'player_04.png',
        'player_03.png',
        'player_05.png',
        'player_03.png',
    }
}

-- 初期化
function Player:initialize(sprite, x, y, w, h)
    -- モジュールの初期化
    Sprite.initialize(self, sprite)
    Rectangle.initialize(self, x, y, w, h)
    Animation.initialize(self)
    Movement.initialize(self)

    self:resetDirection()
    self:resetAnimationDuration(0.25 / 4)

    -- 初期座標
    self.begin_x = self.x
    self.begin_y = self.y
end

-- 座標のリセット
function Player:reset()
    self.x = self.begin_x
    self.y = self.begin_y
end

-- 更新
function Player:update(dt)
end

-- 描画
function Player:draw()
    self:drawSprite(self:getCurrentAnimation(), self.x, self.y)
end

-- 移動
function Player:move(direction)
end

-- 移動できるかどうか返す
function Player:movable()
    return false
end

-- 現在の方向のスプライト名テーブルを返す
function Player:currentSpriteNameTable()
    return spriteNames[self.direction]
end

-- 方向を設定する
function Player:resetDirection(direction, index)
    self.direction = direction or self.direction or 'down'
    self:resetAnimations(self:currentSpriteNameTable(), index or 2)
    self.dirty = true
end

-- スプライトバッチへ追加
function Player:addCurrentSpriteToBatch(spriteBatch)
    self:addSpriteToBatch(spriteBatch, self:getCurrentAnimation(), self.x, self.y)
end

-- 立つステート
local Stand = Player:addState 'stand'

-- 立つ: ステート開始
function Stand:enteredState(direction)
    self:resetDirection(direction)
    self.dirty = true
end

-- 立つ: 移動
function Stand:move(direction, mx, my, duration)
    local x, y = mx, my
    if direction == 'up' then
        y = y or -self.height
    elseif direction == 'down' then
        y = y or self.height
    elseif direction == 'left' then
        x = x or -self.width
    elseif direction == 'right' then
        x = x or self.width
    end
    self:gotoState('walk', direction, x, y, duration or 0.25)
end

-- 立つ: 移動できるかどうか返す
function Stand:movable()
    return true
end

-- 立つ: 更新
function Stand:update(dt)
    self.dirty = false
end

-- 歩くステート
local Walk = Player:addState 'walk'

-- 歩く: ステート開始
function Walk:enteredState(direction, x, y, duration)
    self:resetDirection(direction)
    self:startMovement(x, y, duration or 1)
    self.dirty = true
end

-- 歩く: 更新
function Walk:update(dt)
    self:updateAnimation(dt)
    self:updateMovement(dt)
    self.dirty = true

    if not self:isMoving() then
        self:gotoState 'stand'
    end
end

return Player
