
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- エイリアス
local lg = love.graphics

-- タイトル
local Title = Scene:addState('title', Scene)

-- 読み込み
function Title:load()
end

-- 更新
function Title:update(dt)
end

-- ステート開始
function Title:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    -- ＢＧＭ再生
    self.sounds.outgame:play()
end

-- 描画
function Title:draw()
    -- クリア
    lg.clear(.42, .75, .89)

    -- タイトル
    lg.setColor(1, 1, 1)
    lg.printf("SOKOBAN", self.font128, 0, self.height * 0.3, self.width, 'center')

    -- キー入力待ち描画
    --lg.setColor(1.0, 0, 0.25)
    lg.printf("PRESS ANY KEY", self.font32, 0, self.height * 0.6, self.width, 'center')
end

-- キー入力
function Title:keypressed(key, scancode, isrepeat)
    -- レベル選択へ
    self:gotoState 'select'
end

-- マウス入力
function Title:mousepressed(x, y, button, istouch, presses)
    -- レベル選択へ
    self:gotoState 'select'
end
