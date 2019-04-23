
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- クラス
local Player = require 'Player'
local Crate = require 'Crate'
local Block = require 'Block'
local Ground = require 'Ground'
local Level = require 'Level'

-- エイリアス
local lg = love.graphics

-- ゲーム
local Game = Scene:addState('game', Scene)

-- 読み込み
function Game:load()
    self.level = Level(self.sprite)
    self.level:loadLevel {
        '  XXX   ',
        '  X.X   ',
        '  X XXXX',
        'XXX* *.X',
        'X. *@XXX',
        'XXXX*X  ',
        '   X.X  ',
        '   XXX  ',
    }
    --[[
    {
        '    XXXXX             ',
        '    X   X             ',
        '    X*  X             ',
        '  XXX  *XXX           ',
        '  X  *  * X           ',
        'XXX X XXX X     XXXXXX',
        'X   X XXX XXXXXXX  ..X',
        'X *  *             ..X',
        'XXXXX XXXX X@XXXX  ..X',
        '    X      XXX  XXXXXX',
        '    XXXXXXXX          ',
    }
    ]]

    self.level:gotoState 'play'

    self.state.drawRectangle = false
end

-- 更新
function Game:update(dt)
    self.level:update(dt)
    --self.player:update(dt)
end

-- 描画
function Game:draw()
    -- レベル描画
    self.level:draw()

    -- 矩形の描画
    if self.state.drawRectangle then
        self.level:drawRectangle()
    end

    -- トップバー
    lg.setColor(0, 0, 0, 0.75)
    lg.rectangle("fill", 0, 0, self.width, self.height * 0.1)

    -- ステップ数
    lg.setColor(1, 1, 1)
    lg.printf("STEP: " .. self.level.step, self.width * 0.01, self.height * 0.025, self.width, 'left')
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    if self.level:cleared() then
        if key == 'enter' then
        end
    else
        self.level:keypressed(key, scancode, isrepeat)
    end
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
    self.level:mousepressed(key, scancode, isrepeat)
end
