
local folderOfThisFile = (...):match("(.-)[^%/%.]+$")
local Scene = require(folderOfThisFile .. 'Scene')

-- クラス
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
end

-- ステート開始
function Game:enteredState(...)
    -- 親
    Scene.enteredState(self, ...)

    -- レベル読み込み
    self.state.level:loadLevel(self.levels[self.selectedLevel])
    self.state.level:gotoState 'play'
end

-- 更新
function Game:update(dt)
    -- レベル更新
    self.state.level:update(dt)

    -- カメラ更新
    self.state.camera:update(dt)
    self.state.camera:follow(self.state.level:getPlayerPosition())
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

    -- トップバー
    lg.setColor(.42, .75, .89, .75)
    --lg.rectangle("fill", 0, 0, self.width, self.state.level:cleared() and self.height or font:getHeight())

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
        lg.printf('LEVEL', self.font128, 0, self.height * 0.5 - self.font128:getHeight(), self.width, 'center')
        lg.printf('CLEAR', self.font128, 0, self.height * 0.5, self.width, 'center')
        lg.printf("PRESS ANY KEY", self.font32, 0, self.height * 0.9 - self.font32:getHeight() * 0.5, self.width, 'center')
    end
end

-- キー入力
function Game:keypressed(key, scancode, isrepeat)
    if self.state.level:cleared() then
        -- レベルクリア
        if key == 'return' then
            -- 次のレベル
            self.cleared[self.selectedLevel] = self.state.level.step
            self.selectedLevel = self.selectedLevel + 1
            if self.selectedLevel > #self.levels then
                self.selectedLevel = 1
            end

            self.sounds.ok:play()
            self.sounds.clear:stop()
            self:gotoState 'select'
        end

    elseif key == 'pagedown' then
        -- ズームアウト
        self.state.scaleLevel = self.state.scaleLevel + 1
        if self.state.scaleLevel > #scales then
            self.state.scaleLevel = #scales
        end
        self.state.camera.scale = scales[self.state.scaleLevel]

    elseif key == 'pageup' then
        -- ズームイン
        self.state.scaleLevel = self.state.scaleLevel - 1
        if self.state.scaleLevel < 1 then
            self.state.scaleLevel = 1
        end
        self.state.camera.scale = scales[self.state.scaleLevel]

    elseif key == 'home' then
        -- やりなおし
        self.sounds.ok:seek(0)
        self.sounds.ok:play()
        self:gotoState 'game'

    elseif key == 'end' then
        -- レベル選択に戻る
        self.sounds.cancel:seek(0)
        self.sounds.cancel:play()
        self.sounds.ingame:stop()
        self:gotoState 'select'

    else
        -- レベル入力
        self.state.level:keypressed(key, scancode, isrepeat)
    end
end

-- マウス入力
function Game:mousepressed(x, y, button, istouch, presses)
    self.state.level:mousepressed(key, scancode, isrepeat)
end
