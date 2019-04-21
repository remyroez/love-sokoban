
local class = require 'middleclass'
local stateful = require 'stateful'

-- 現在のステートを返す
local function _getCurrentState(self)
    return self.__stateStack[#self.__stateStack]
end

-- ステート名を返す
local function _getStateName(self, target)
    for name,state in pairs(self.class.static.states) do
        if state == target then return name end
    end
end

-- 現在のステート名を返す
local function _getCurrentStateName(self)
    return _getStateName(self, _getCurrentState(self))
end

-- シーン
local Scene = class 'Scene'
Scene:include(stateful)

-- シーン: 初期化
function Scene:initialize()
    self.stateObjects = {}
end

-- シーン: 読み込み
function Scene:load()
end

-- シーン: 更新
function Scene:update(dt)
end

-- シーン: 描画
function Scene:draw()
end

-- シーン: ステート開始
function Scene:enteredState(...)
    -- 現在のステート名
    local name = _getCurrentStateName(self)

    -- 現在のステート用テーブルが無ければ準備, load を呼ぶ
    if self.stateObjects[name] == nil then
        self.stateObjects[name] = {}
        self:load()
    end

    -- テーブルを state にセット
    self.state = self.stateObjects[name]
end

-- シーン: ステート終了
function Scene:exitedState(...)
end

-- シーン: ステートプッシュ
function Scene:pushedState(...)
end

-- シーン: ステートポップ
function Scene:poppedState(...)
end

-- シーン: ステート停止
function Scene:pausedState(...)
end

-- シーン: ステート再開
function Scene:continuedState(...)
end

-- シーン: キー入力
function Scene:keypressed(key, scancode, isrepeat)
end

-- シーン: マウス入力
function Scene:mousepressed(x, y, button, istouch, presses)
end

return Scene
