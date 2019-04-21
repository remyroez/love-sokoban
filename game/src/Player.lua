
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

    -- 現在のスプライト
    self.direction = 'right'
    Animation.initialize(self, self:currentSpriteNameTable())

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
    Animation.update(self, dt)
end

-- 描画
function Player:draw()
    self:drawSprite(self:getCurrentAnimation(), self.x, self.y)
    --self:drawRectangle()
end

-- 更新
function Player:currentSpriteNameTable()
    return spriteNames[self.direction]
end

return Player
