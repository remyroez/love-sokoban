
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
    self.state.camera:setFollowLerp(0.2)
    self.state.camera:setFollowLead(10)
    --self.state.camera:setFollowStyle('NO_DEADZONE')

    self.state.scaleLevel = 2
    self.state.camera.scale = scales[self.state.scaleLevel]

    -- レベル作成
    self.state.level = Level(self.sprite)

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

    -- トップバー
    lg.setColor(0, 0, 0, 0.75)
    lg.rectangle("fill", 0, 0, self.width, self.height * 0.1)

    -- ステップ数
    lg.setColor(1, 1, 1)
    local text = "STEP: " .. self.state.level.step
    if self.cleared[self.selectedLevel] then
        text = text .. ' / ' .. self.cleared[self.selectedLevel]
    end
    lg.printf(text, self.width * 0.01, self.height * 0.025, self.width, 'left')
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
        self:gotoState 'game'

    elseif key == 'end' then
        -- レベル選択に戻る
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
