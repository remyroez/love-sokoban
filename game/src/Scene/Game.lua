
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

    self.level = Level(self.sprite)
    self.level:loadLevel()

    self.state.drawRectangle = false
end

-- ゲーム: 更新
function Game:update(dt)
    self.level:update(dt)
    self.player:update(dt)
end

-- ゲーム: 描画
function Game:draw()
    self.level:draw()
    self.player:draw()

    -- 矩形の描画
    if self.state.drawRectangle then
        self.player:drawRectangle()
        self.level:drawRectangle()
    end
end

-- ゲーム: キー入力
function Game:keypressed(key, scancode, isrepeat)
    self.player:keypressed(key, scancode, isrepeat)
end

-- ゲーム: マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
end
