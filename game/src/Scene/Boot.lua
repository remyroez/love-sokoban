
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- ブート
local Boot = Scene:addState('boot', Scene)

-- 読み込み
function Boot:load()
    -- 画面のサイズ
    local width, height = love.graphics.getDimensions()
    self.width = width
    self.height = height

    -- スプライトシートの読み込み
    self.sprite = sbss:new('assets/spritesheet.xml')

    -- レベルデータ
    self.levels = love.filesystem.load('assets/levels.lua')()
    self.selectedLevel = 1
    self.cleared = {}
end

-- 更新
function Boot:update()
    -- レベル選択へ
    self:gotoState 'select'
end
