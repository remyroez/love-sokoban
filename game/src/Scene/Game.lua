
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

local Player = require 'Player'
local Crate = require 'Crate'
local Block = require 'Block'
local Ground = require 'Ground'
local Level = require 'Level'

-- ゲーム
local Game = Scene:addState('game', Scene)

-- ゲーム: 読み込み
function Game:load()
    self.player = Player(self.sprite, 300, 300, 128, 128)
    self.player:gotoState('stand')

    self.crate = Crate(self.sprite, 100, 100)
    self.crate:gotoState('place')

    self.block = Block(self.sprite, 500, 200)

    --self.ground = Ground(self.sprite, 500, 400)
    
    self.level = Level(self.sprite)

    self.state.drawRectangle = false
end

-- ゲーム: 更新
function Game:update(dt)
    self.level:update(dt)
    self.player:update(dt)
    self.crate:update(dt)
end

-- ゲーム: 描画
function Game:draw()
    self.level:draw()
    self.player:draw()
    self.crate:draw()
    self.block:draw()

    -- 矩形の描画
    if self.state.drawRectangle then
        self.player:drawRectangle()
        self.crate:drawRectangle()
        self.block:drawRectangle()
        self.level:drawRectangle()
    end
end

-- ゲーム: キー入力
function Game:keypressed(key, scancode, isrepeat)
    --self.player:keypressed(key, scancode, isrepeat)
    self.crate:move(key)
end

-- ゲーム: マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
end
