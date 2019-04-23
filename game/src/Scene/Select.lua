
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- エイリアス
local lg = love.graphics

-- レベル選択
local Select = Scene:addState('select', Scene)

-- 読み込み
function Select:load()
end

-- 更新
function Select:update(dt)
end

-- 描画
function Select:draw()
    -- 選択しているレベル
    lg.setColor(1, 1, 1)
    lg.printf("LEVEL: " .. self.selectedLevel, 0, self.height * 0.5, self.width, 'center')
end

-- キー入力
function Select:keypressed(key, scancode, isrepeat)
    if key == 'return' then
        -- ゲームへ
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
