
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

local Player = require 'Player'

-- ゲーム
local Game = Scene:addState('game', Scene)

-- ゲーム: 読み込み
function Game:load()
    self.player = Player(self.sprite, 300, 300, 84, 100)
end

-- ゲーム: 更新
function Game:update(dt)
end

-- ゲーム: 描画
function Game:draw()
    self.player:draw()
end

-- ゲーム: キー入力
function Game:keypressed(key, scancode, isrepeat)
end

-- ゲーム: マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
end
