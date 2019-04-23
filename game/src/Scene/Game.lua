
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- クラス
local Level = require 'Level'

-- エイリアス
local lg = love.graphics

-- ゲーム
local Game = Scene:addState('game', Scene)

-- 読み込み
function Game:load()
    -- レベル作成
    self.state.level = Level(self.sprite)

    -- 矩形
    self.state.drawRectangle = false
end

-- ステート開始
function Game:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    -- レベル読み込み
    self.state.level:loadLevel(self.levels[self.selectedLevel])
    self.state.level:gotoState 'play'
end

-- 更新
function Game:update(dt)
    self.state.level:update(dt)
end

-- 描画
function Game:draw()
    -- レベル描画
    self.state.level:draw()

    -- 矩形の描画
    if self.state.drawRectangle then
        self.state.level:drawRectangle()
    end

    -- トップバー
    lg.setColor(0, 0, 0, 0.75)
    lg.rectangle("fill", 0, 0, self.width, self.height * 0.1)

    -- ステップ数
    lg.setColor(1, 1, 1)
    local text = "STEP: " .. self.state.level.step
    if self.cleared[self.selectedLevel] then
        text = text .. ' / ' .. self.cleared[self.selectedLevel]
    end
    lg.printf(text, self.width * 0.01, self.height * 0.025, self.width, 'left')
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    if self.state.level:cleared() then
        -- レベルクリア
        if key == 'return' then
            -- 次のレベル
            self.cleared[self.selectedLevel] = self.state.level.step
            self.selectedLevel = self.selectedLevel + 1
            if self.selectedLevel > #self.levels then
                self.selectedLevel = 1
            end

            self:gotoState 'select'
        end

    elseif key == 'home' then
        -- やりなおし
        self:gotoState 'game'

    elseif key == 'end' then
        -- レベル選択に戻る
        self:gotoState 'select'

    else
        -- レベル入力
        self.state.level:keypressed(key, scancode, isrepeat)
    end
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
    self.state.level:mousepressed(key, scancode, isrepeat)
end
