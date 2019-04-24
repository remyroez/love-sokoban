
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- エイリアス
local lg = love.graphics

-- ブート
local Boot = Scene:addState('boot', Scene)

-- 読み込み
function Boot:load()
    -- 画面のサイズ
    local width, height = lg.getDimensions()
    self.width = width
    self.height = height

    -- スプライトシートの読み込み
    self.sprite = sbss:new('assets/spritesheet.xml')

    -- フォント
    local font = 'assets/Kenney Future Square.ttf'
    self.font64 = lg.newFont(font, 64)
    self.font16 = lg.newFont(font, 16)

    -- レベルデータ
    self.levels = love.filesystem.load('assets/levels.lua')()
    self.selectedLevel = 1
    self.cleared = {}
end

-- 更新
function Boot:update()
    -- タイトルへ
    self:gotoState 'title'
end
