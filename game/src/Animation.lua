
-- アニメーションモジュール
local Animation = {}

-- 初期化
function Animation:initialize(animations, duration)
    self.animation = {}
    self:resetAnimations(animations, duration)
end

-- 現在のアニメーションを返す
function Animation:resetAnimations(animations, duration)
    local anim = self.animation
    anim.animations = animations or {}
    anim.index = 1
    anim.duration = duration or 0.1
    anim.timer = anim.duration
end

-- 現在のアニメーションを返す
function Animation:getCurrentAnimation()
    return self.animation.animations[self.animation.index]
end

-- 更新
function Animation:update(dt)
    local anim = self.animation

    -- タイマーを減らす
    anim.timer = anim.timer - dt
    if anim.timer < 0 then
        -- ０未満になったらリセット
        anim.timer = anim.timer + anim.duration

        -- インデックスをインクリメント
        anim.index = anim.index + 1

        -- インデックスをループ
        if anim.index > #anim.animations then
            anim.index = 1
        end
    end
end

return Animation
