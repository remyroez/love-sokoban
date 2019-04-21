
local class = require 'middleclass'
local stateful = require 'stateful'

-- モジュール
local Sprite = require 'Sprite'
local Rectangle = require 'Rectangle'
local Movement = require 'Movement'

-- 箱クラス
local Crate = class 'Crate'
Crate:include(stateful)
Crate:include(Sprite)
Crate:include(Rectangle)
Crate:include(Movement)

-- スプライト名
local spriteNames = {
    wood = {
        default = 'crate_02.png',
        fit = 'crate_12.png',
    },
    red = {
        default = 'crate_03.png',
        fit = 'crate_13.png',
    },
    blue = {
        default = 'crate_04.png',
        fit = 'crate_14.png',
    },
    green = {
        default = 'crate_05.png',
        fit = 'crate_15.png',
    },
    metal = {
        default = 'crate_06.png',
        fit = 'crate_16.png',
    },
}

-- 初期化
function Crate:initialize(sprite, x, y, w, h)
    -- モジュールの初期化
    Sprite.initialize(self, sprite)
    Rectangle.initialize(self, x, y, w, h)
    Movement.initialize(self)

    self.type = 'metal'
    self.fit = false

    -- 初期座標
    self.begin_x = self.x
    self.begin_y = self.y
end

-- 座標のリセット
function Crate:reset()
    self.x = self.begin_x
    self.y = self.begin_y
end

-- 更新
function Crate:update(dt)
end

-- 描画
function Crate:draw()
    self:drawSprite(self:getCurrentSpriteName(), self.x, self.y)
end

-- 現在のスプライト名を返す
function Crate:getCurrentSpriteName()
    return spriteNames[self.type][self.fit and 'fit' or 'default']
end

-- 設置ステート
local Place = Crate:addState 'place'

-- 設置: ステート開始
function Place:enteredState()
end

-- 設置: キー入力
function Place:move(direction)
    self:pushState('move', direction, 100, 100, 1)
end

-- 移動ステート
local Move = Crate:addState 'move'

-- 移動: ステート開始
function Move:enteredState(direction, x, y, duration)
    self:startMovement(x, y, duration or 1)
end

-- 移動: 更新
function Move:update(dt)
    self:updateMovement(dt)

    if not self:isMoving() then
        self.fit = true
        self:popState()
    end
end

return Crate
