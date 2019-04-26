
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
        outgame = la.newSource('assets/Retro Polka.ogg', 'static'),
        ingame = la.newSource('assets/Retro Reggae.ogg', 'static'),
        clear = la.newSource('assets/Polka ident.ogg', 'static'),
        ok = la.newSource('assets/threeTone2.ogg', 'static'),
        cancel = la.newSource('assets/twoTone2.ogg', 'static'),
        cursor = la.newSource('assets/phaseJump5.ogg', 'static'),
        fit = la.newSource('assets/powerUp2.ogg', 'static'),
        zoom = la.newSource('assets/lowRandom.ogg', 'static'),
        push = la.newSource('assets/hurt2.ogg', 'static'),
    }

    -- ループ設定
    self.sounds.outgame:setLooping(true)
    self.sounds.ingame:setLooping(true)

    -- 音量の調整
    self.sounds.outgame:setVolume(0.5)
    self.sounds.ingame:setVolume(0.5)
    self.sounds.clear:setVolume(0.5)
    self.sounds.push:setVolume(0.5)

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
    -- スプラッシュスクリーンへ
    self:gotoState 'splash'
end
