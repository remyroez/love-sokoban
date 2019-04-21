
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- ブート
local Boot = Scene:addState('boot', Scene)

-- 読み込み
function Boot:load()
    -- スプライトシートの読み込み
    self.sprite = sbss:new('assets/spritesheet.xml')
end

-- 更新
function Boot:update()
    -- ゲームへ
    self:gotoState 'game'
end
