
local class = require 'middleclass'
local stateful = require 'stateful'

-- シーン
local Scene = class 'Scene'
Scene:include(stateful)

-- シーン: 初期化
function Scene:initialize()
end

-- シーン: 読み込み
function Scene:load()
end

-- シーン: 更新
function Scene:update(dt)
end

-- シーン: 描画
function Scene:draw()
end

-- シーン: キー入力
function Scene:keypressed(key, scancode, isrepeat)
end

-- シーン: マウス入力
function Scene:mousepressed(x, y, button, istouch, presses)
end

return Scene
