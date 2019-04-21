
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- ブート
local Boot = Scene:addState('boot', Scene)

-- ブート: 読み込み
function Boot:load()
    -- スプライトシートの読み込み
    self.sprite = sbss:new('assets/spritesheet.xml')

    -- ゲームへ
    self:gotoState 'game'
end
