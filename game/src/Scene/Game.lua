
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- ゲーム
local Game = Scene:addState('game', Scene)

-- ゲーム: 読み込み
function Game:load()
end

-- ゲーム: 更新
function Game:update(dt)
end

-- ゲーム: 描画
function Game:draw()
end

-- ゲーム: キー入力
function Game:keypressed(key, scancode, isrepeat)
end

-- ゲーム: マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
end
