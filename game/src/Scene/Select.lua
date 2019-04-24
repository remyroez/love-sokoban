
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- エイリアス
local lg = love.graphics

-- レベル選択
local Select = Scene:addState('select', Scene)

-- ステート開始
function Select:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    -- ＢＧＭ再生
    self.sounds.outgame:play()
end

-- 描画
function Select:draw()
    -- クリア
    lg.clear(.42, .75, .89)

    local cleared = self.cleared[self.selectedLevel]

    -- 選択しているレベル
    lg.setColor(self.colors.white)
    lg.printf("SELECT LEVEL", self.font32, 0, self.height * 0.25 - self.font32:getHeight() * 0.5, self.width, 'center')

    local middle = (self.height - self.font64:getHeight()) * 0.5
    lg.printf(#self.levels, self.font64, self.width * 0.5 + self.font64:getWidth('/'), middle, self.width, 'left')

    lg.setColor(1, 1, 1, 0.5)
    lg.printf('/', self.font64, 0, middle, self.width, 'center')

    if cleared then
        -- クリア済み
        lg.setColor(0, 1, 0)
    else
        -- 未クリア
        lg.setColor(self.colors.white)
    end
    lg.printf(self.selectedLevel, self.font64, -self.font64:getWidth('/'), middle, self.width * 0.5, 'right')

    -- クリア済み表示
    if cleared then
        lg.setColor(0, 1, 0)
        lg.printf("BEST", self.font32, 0, self.height * 0.7, self.width, 'center')
        lg.printf(cleared, self.font64, 0, self.height * 0.7 + self.font32:getHeight(), self.width, 'center')
    end
end

-- キー入力
function Select:keypressed(key, scancode, isrepeat)
    if key == 'return' then
        -- ゲームへ
        self.sounds.outgame:stop()
        self:gotoState 'game'

    elseif key == 'left' then
        -- 前のレベル
        self.selectedLevel = self.selectedLevel - 1
        if self.selectedLevel < 1 then
            self.selectedLevel = #self.levels
        end

    elseif key == 'right' then
        -- 次のレベル
        self.selectedLevel = self.selectedLevel + 1
        if self.selectedLevel > #self.levels then
            self.selectedLevel = 1
        end
    end
end
