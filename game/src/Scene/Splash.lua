
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- クラス
local o_ten_one = require 'o-ten-one'

-- エイリアス
local lg = love.graphics

-- スプラッシュスクリーン
local Splash = Scene:addState('splash', Scene)

-- 読み込み
function Splash:load()
    self.state.splash = o_ten_one{ base_folder = 'lib' }
    self.state.splash.onDone = function ()
        self:gotoState 'title'
    end
end

-- 更新
function Splash:update(dt)
    self.state.splash:update(dt)
end

-- 描画
function Splash:draw()
    self.state.splash:draw()
end

-- キー入力
function Splash:keypressed(key, scancode, isrepeat)
    self.state.splash:skip()
end
