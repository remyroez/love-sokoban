
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- クラス
local Timer = require 'Timer'

-- エイリアス
local lg = love.graphics

-- タイトル
local Title = Scene:addState('title', Scene)

-- 読み込み
function Title:load()
    -- タイマー
    self.state.timer = Timer()

    -- 表示フラグ
    self.state.visiblePressAnyKey = true

    -- アクション中
    self.state.action = false
end

-- ステート開始
function Title:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    -- ＢＧＭ再生
    self.sounds.outgame:play()

    -- タイマーに処理をセット
    self.state.timer:every(0.5, function() self.state.visiblePressAnyKey = not self.state.visiblePressAnyKey end)

    -- 開始演出
    self.state.alpha = 0
    self.state.scale = 0
    self.state.rotation = 0
    self.state.timer:tween(
        1,
        self.state,
        { scale = 1, rotation = math.pi * 2 },
        'out-elastic',
        function ()
            self.state.visiblePressAnyKey = true
            self.state.rotation = 0
            self.state.action = false
        end,
        'start'
    )
    self.state.timer:tween(
        0.75,
        self.state,
        { alpha = 1 },
        'in-out-cubic',
        'alpha'
    )
end

-- ステート終了
function Title:exitedState(...)
    self.state.timer:destroy()
end

-- 更新
function Title:update(dt)
    self.state.timer:update(dt)
end

-- 描画
function Title:draw()
    -- クリア
    lg.clear(self.colors.bg)

    -- タイトル
    lg.setColor(1, 1, 1, self.state.alpha)
    lg.push()
    lg.translate(self.width * 0.5, self.height * 0.3)
    lg.scale(self.state.scale)
    lg.rotate(self.state.rotation)
    lg.printf('SOKOBAN', self.font128, -self.font128:getWidth('SOKOBAN') * 0.5, -self.font128:getHeight() * 0.5, self.width, 'left')
    lg.pop()

    -- キー入力待ち描画
    if self.state.visiblePressAnyKey and not self.state.action then
        lg.printf("PRESS ANY KEY", self.font32, 0, self.height * 0.7, self.width, 'center')
    end
end

-- キー入力
function Title:keypressed(key, scancode, isrepeat)
    -- ＳＥ
    self.sounds.ok:play()

    -- 演出
    self.state.alpha = 1
    self.state.scale = 1
    self.state.rotation = 0
    self.state.timer:tween(
        1,
        self.state,
        { scale = 0, rotation = -math.pi * 2 },
        'in-out-cubic',
        function ()
            -- レベル選択へ
            self:gotoState 'select'
            self.state.rotation = 0
            self.state.action = false
        end,
        'start'
    )
    self.state.timer:tween(
        0.75,
        self.state,
        { alpha = 0 },
        'in-out-cubic',
        'alpha'
    )
    self.state.action = true
end
