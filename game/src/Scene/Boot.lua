
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- エイリアス
local lg = love.graphics
local la = love.audio

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

    -- サウンド
    self.sounds = {
        outgame = la.newSource('assets/Retro Polka.ogg', 'stream'),
        ingame = la.newSource('assets/Retro Reggae.ogg', 'stream'),
        clear = la.newSource('assets/Polka ident.ogg', 'static'),
        fit = la.newSource('assets/phaseJump5.ogg', 'static'),
    }
    self.sounds.outgame:setLooping(true)
    self.sounds.ingame:setLooping(true)

    -- フォント
    local font = 'assets/Kenney Future Square.ttf'
    self.font128 = lg.newFont(font, 128)
    self.font64 = lg.newFont(font, 64)
    self.font32 = lg.newFont(font, 32)
    self.font16 = lg.newFont(font, 16)

    -- レベルデータ
    self.levels = love.filesystem.load('assets/levels.lua')()
    self.selectedLevel = 1
    self.cleared = {}

    -- カラー
    self.colors = {
        bg =     {.42, .75, .89},
        white =  {  1,   1,   1},
        blue =   {.15, .67, .88},
        pink =   {.91, .29,  .6},
        shadow = {0, 0, 0, .33}
    }
end

-- 更新
function Boot:update()
    -- タイトルへ
    self:gotoState 'title'
end
