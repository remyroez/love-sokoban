
local class = require 'middleclass'
local stateful = require 'stateful'

-- モジュール
local Sprite = require 'Sprite'
local Rectangle = require 'Rectangle'
local Animation = require 'Animation'

-- プレイヤークラス
local Player = class 'Player'
Player:include(stateful)
Player:include(Sprite)
Player:include(Rectangle)
Player:include(Animation)

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

    self:resetDirection()
    self:resetAnimationDuration(0.2)

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
    --self:updateAnimation(dt)
end

-- 描画
function Player:draw()
    self:drawSprite(self:getCurrentAnimation(), self.x, self.y)
    --self:drawRectangle()
end

-- キー入力
function Player:keypressed(key, scancode, isrepeat)
end

-- 現在の方向のスプライト名テーブルを返す
function Player:currentSpriteNameTable()
    return spriteNames[self.direction]
end

-- 方向を設定する
function Player:resetDirection(direction, index)
    self.direction = direction or 'down'
    self:resetAnimations(self:currentSpriteNameTable(), index or 2)
end

-- 立つステート
local Stand = Player:addState 'stand'

-- 立つ: ステート開始
function Stand:enteredState(direction)
    self:resetDirection(direction)
end

-- キー入力
function Stand:keypressed(key, scancode, isrepeat)
    if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
        self:gotoState('walk', key)
    end
end

-- 歩くステート
local Walk = Player:addState 'walk'

-- 歩く: ステート開始
function Walk:enteredState(direction)
    self:resetDirection(direction)
end

-- 歩く: 更新
function Walk:update(dt)
    self:updateAnimation(dt)
end

return Player
