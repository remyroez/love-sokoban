
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- クラス
local Timer = require 'Timer'
local Camera = require 'Camera'
local Level = require 'Level'

-- エイリアス
local lg = love.graphics

-- ゲーム
local Game = Scene:addState('game', Scene)

-- スケール
local scales = {
    1,
    0.5,
    0.25,
    0.1
}

-- 読み込み
function Game:load()
    -- タイマー
    self.state.timer = Timer()

    -- カメラ
    self.state.camera = Camera()
    --self.state.camera:setFollowLerp(0.2)
    --self.state.camera:setFollowLead(10)
    self.state.camera:setFollowStyle('NO_DEADZONE')

    self.state.scaleLevel = 2
    self.state.camera.scale = scales[self.state.scaleLevel]

    -- レベル作成
    self.state.level = Level(self.sprite, self.sounds)

    -- 矩形
    self.state.drawRectangle = false

    -- 表示フラグ
    self.state.visiblePressAnyKey = true
end

-- ステート開始
function Game:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    -- レベル読み込み
    self.state.level:loadLevel(self.levels[self.selectedLevel])
    self.state.level.onClear = function ()
        self.state.clearedScale = 0
        self.state.timer:tween(
            1,
            self.state,
            { clearedScale = 1 },
            'out-elastic',
            function ()
                self.state.visiblePressAnyKey = true
                self.state.action = false
            end,
            'start'
        )
        self.state.action = true
    end
    self.state.level:gotoState 'play'

    -- タイマーに処理をセット
    self.state.timer:every(0.5, function() self.state.visiblePressAnyKey = not self.state.visiblePressAnyKey end)

    -- クリアスケール
    self.state.clearedScale = 0

    -- 開始演出
    self.state.alpha = 1
    self.state.camera.scale = 0
    self.state.camera.rotation = 0
    self.state.timer:tween(
        1,
        self.state.camera,
        { scale = scales[self.state.scaleLevel], rotation = math.pi * 2 },
        'out-elastic',
        function ()
            self.state.camera.rotation = 0
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

-- ステート終了
function Game:exitedState(...)
    self.state.timer:destroy()
end

-- 更新
function Game:update(dt)
    -- レベル更新
    self.state.level:update(dt)

    -- カメラ更新
    self.state.camera:update(dt)
    self.state.camera:follow(self.state.level:getPlayerPosition())

    -- タイマー更新
    self.state.timer:update(dt)
end

-- 描画
function Game:draw()
    -- クリア
    lg.clear(self.colors.bg)

    -- カメラ描画アタッチ
    self.state.camera:attach()

    -- レベル描画
    self.state.level:draw()

    -- 矩形の描画
    if self.state.drawRectangle then
        self.state.level:drawRectangle()
    end

    -- カメラ描画デタッチ
    self.state.camera:detach()

    -- カメラ描画
    self.state.camera:draw()

    local font = self.font64

    -- レベル表示
    lg.setColor(self.colors.white)
    lg.printf(' LEVEL ' .. self.selectedLevel, self.font16, 0, 0, self.width, 'left')

    -- ステップ数
    local h = 0--font:getHeight()
    if self.cleared[self.selectedLevel] then
        -- 過去のクリア時のステップ数と比較する
        if self.state.level.step > self.cleared[self.selectedLevel] then
            -- 超えたので、赤
            lg.setColor(1, 0, 0)
        else
            -- 超えてないので、緑
            lg.setColor(0, 1, 0)
        end

        -- 現在のステップ数
        lg.printf(self.state.level.step, font, -16, h, self.width * 0.5, 'right')

        -- 過去のクリア時のステップ数
        lg.setColor(1, 1, 1, 0.5)
        lg.printf('/', self.font32, 0, (self.font64:getHeight() - self.font32:getHeight()) * 0.5, self.width, 'center')
        lg.setColor(self.colors.white)
        lg.printf(self.cleared[self.selectedLevel], font, self.width * 0.5 + 16, h, self.width, 'left')
    else
        -- 未クリア時
        lg.setColor(self.colors.white)
        lg.printf(self.state.level.step, font, 0, h, self.width, 'center')
    end

    -- クリア表示
    if self.state.level:cleared() then
        lg.setColor(self.colors.white)
        lg.push()
        lg.translate(self.width * 0.5, self.height * 0.5)
        lg.scale(self.state.clearedScale)
        lg.printf('LEVEL', self.font128, -self.font128:getWidth('LEVEL') * 0.5, -self.font128:getHeight(), self.width, 'left')
        lg.printf('CLEAR', self.font128, -self.font128:getWidth('LEVEL') * 0.5, 0, self.width, 'left')
        lg.pop()
        if self.state.visiblePressAnyKey and not self.state.action then
            lg.printf("PRESS ANY KEY", self.font32, 0, self.height * 0.9 - self.font32:getHeight() * 0.5, self.width, 'center')
        end
    end

    -- フェード
    if self.state.alpha > 0 then
        lg.setColor(.42, .75, .89, self.state.alpha)
        lg.rectangle("fill", 0, 0, self.width, self.height)
    end
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    if self.state.action then
        -- アクション中
    elseif self.state.level:cleared() then
        -- レベルクリア
        if key == 'return' then
            -- ＳＥ
            self.sounds.ok:play()

            -- 演出
            self.state.alpha = 0
            --self.state.camera.scale = scales[self.state.scaleLevel]
            self.state.camera.rotation = 0
            self.state.timer:tween(
                2,
                self.state.camera,
                { scale = 0, rotation = -math.pi * 2 },
                'in-out-cubic',
                function ()
                    -- 次のレベル
                    self.cleared[self.selectedLevel] = self.state.level.step
                    self.selectedLevel = self.selectedLevel + 1
                    if self.selectedLevel > #self.levels then
                        self.selectedLevel = 1
                    end
                    self.state.camera.rotation = 0
                    self.state.action = false
                    self.sounds.clear:stop()
                    self:gotoState 'select'
                end,
                'start'
            )
            self.state.timer:tween(
                1.5,
                self.state,
                { alpha = 1 },
                'in-out-cubic',
                'alpha'
            )
            self.state.action = true
        end

    elseif key == 'backspace' then
        -- アンドゥ
        self.state.level:undo(0.1)

    elseif key == 'pagedown' then
        -- ズームアウト
        self.state.scaleLevel = self.state.scaleLevel + 1
        if self.state.scaleLevel > #scales then
            self.state.scaleLevel = #scales
        else
            self.sounds.zoom:seek(0)
            self.sounds.zoom:play()
        end
        self.state.timer:tween(0.25, self.state.camera, { scale = scales[self.state.scaleLevel] }, 'in-out-cubic', 'zoom')

    elseif key == 'pageup' then
        -- ズームイン
        self.state.scaleLevel = self.state.scaleLevel - 1
        if self.state.scaleLevel < 1 then
            self.state.scaleLevel = 1
        else
            self.sounds.zoom:seek(0)
            self.sounds.zoom:play()
        end
        self.state.timer:tween(0.25, self.state.camera, { scale = scales[self.state.scaleLevel] }, 'in-out-cubic', 'zoom')

    elseif key == 'home' then
        -- やりなおし
        self.sounds.ok:seek(0)
        self.sounds.ok:play()
        self:gotoState 'game'

    elseif key == 'end' then
        -- レベル選択に戻る
        self.sounds.cancel:seek(0)
        self.sounds.cancel:play()

        self.state.alpha = 0
        --self.state.camera.scale = scales[self.state.scaleLevel]
        self.state.camera.rotation = 0
        self.state.timer:tween(
            1,
            self.state.camera,
            { scale = 0, rotation = -math.pi * 2 },
            'in-out-cubic',
            function ()
                self.state.camera.rotation = 0
                self.state.action = false
                self.sounds.ingame:stop()
                self:gotoState 'select'
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
        self.state.action = true

    else
        -- レベル入力
        self.state.level:keypressed(key, scancode, isrepeat)
    end
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
    self.state.level:mousepressed(key, scancode, isrepeat)
end
