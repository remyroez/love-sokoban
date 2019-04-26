
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- クラス
local Timer = require 'Timer'

-- エイリアス
local lg = love.graphics

-- レベル選択
local Select = Scene:addState('select', Scene)

-- 読み込み
function Select:load()
    -- タイマー
    self.state.timer = Timer()
end

-- ステート開始
function Select:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    -- ＢＧＭ再生
    self.sounds.outgame:play()

    -- 開始演出
    self.state.alpha = 1
    self.state.timer:tween(
        0.1,
        self.state,
        { alpha = 0 },
        'in-out-cubic',
        function () self.state.action = false end,
        'alpha'
    )
    self.state.action = true

    self.state.offset = 0
end

-- ステート終了
function Select:exitedState(...)
    self.state.timer:destroy()
end

-- 更新
function Select:update(dt)
    self.state.timer:update(dt)
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
    lg.printf('/', self.font32, 0, (self.height - self.font32:getHeight()) * 0.5, self.width, 'center')

    if cleared then
        -- クリア済み
        lg.setColor(0, 1, 0)
    else
        -- 未クリア
        lg.setColor(self.colors.white)
    end
    lg.printf(self.selectedLevel, self.font64, -self.font64:getWidth('/') + self.state.offset, middle, self.width * 0.5, 'right')

    -- クリア済み表示
    if cleared then
        local h = self.height * 0.7 + self.state.offset
        lg.setColor(0, 1, 0)
        lg.printf("BEST", self.font32, 0, h, self.width, 'center')
        lg.printf(cleared, self.font64, 0, h + self.font32:getHeight(), self.width, 'center')
    end

    -- フェード
    if self.state.alpha > 0 then
        lg.setColor(.42, .75, .89, self.state.alpha)
        lg.rectangle("fill", 0, 0, self.width, self.height)
    end
end

-- キー入力
function Select:keypressed(key, scancode, isrepeat)
    if self.state.action then
        -- 演出中
    elseif key == 'return' then
        -- ゲームへ
        self.sounds.ok:seek(0)
        self.sounds.ok:play()

        self.state.alpha = 0
        self.state.timer:tween(
            0.1,
            self.state,
            { alpha = 1 },
            'in-out-cubic',
            function ()
                self.sounds.outgame:stop()
                self:gotoState 'game'
                self.state.action = false
            end,
            'alpha'
        )
        self.state.action = true

    elseif key == 'left' then
        -- 前のレベル
        self.selectedLevel = self.selectedLevel - 1
        if self.selectedLevel < 1 then
            self.selectedLevel = #self.levels
        end
        self.sounds.cursor:seek(0)
        self.sounds.cursor:play()

        self.state.offset = 64
        self.state.timer:tween(
            0.2,
            self.state,
            { offset = 0 },
            'out-elastic',
            'select'
        )

    elseif key == 'right' then
        -- 次のレベル
        self.selectedLevel = self.selectedLevel + 1
        if self.selectedLevel > #self.levels then
            self.selectedLevel = 1
        end
        self.sounds.cursor:seek(0)
        self.sounds.cursor:play()

        self.state.offset = -64
        self.state.timer:tween(
            0.2,
            self.state,
            { offset = 0 },
            'out-elastic',
            'select'
        )
    end
end
