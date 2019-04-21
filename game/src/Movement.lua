
-- 移動モジュール
local Movement = {}

-- 初期化
function Movement:initialize(x, y)
    -- 現在の座標
    self.x = x or self.x or 0
    self.y = y or self.y or 0

    -- 移動先
    self.movement = {
        x = 0,
        y = 0,
        startX = self.x,
        startY = self.y,
        endX = self.x,
        endY = self.y,
        duration = 0,
        moving = false,
        timer = 0,
    }
end

-- 移動中かどうか返す
function Movement:isMoving()
    return self.movement.moving
end

-- 更新
function Movement:updateMovement(dt)
    local move = self.movement

    -- 移動処理
    if move.moving then
        -- タイマーカウントアップ
        move.timer = move.timer + dt

        -- 現在の地点
        local lerp = move.timer / move.duration

        -- 期間を過ぎたら移動終了
        if move.timer >= move.duration then
            lerp = 1
            move.moving = false
        end

        -- 座標更新
        self.x = move.startX + move.x * lerp
        self.y = move.startY + move.y * lerp
    end
end

-- 移動の開始
function Movement:startMovement(x, y, duration)
    local move = self.movement

    -- 初期設定
    move.duration = duration or 0
    move.x = x or 0
    move.y = y or 0
    move.startX = self.x
    move.startY = self.y
    move.endX = move.startX + move.x
    move.endY = move.startY + move.y
    move.timer = 0

    if move.duration == 0 then
        -- 移動時間がないなら、すぐ設定
        self.x = move.endX
        self.y = move.endY
        move.moving = false
    else
        -- 移動先を設定
        move.moving = true
    end
end

return Movement
