
-- アニメーションモジュール
local Animation = {}

-- 初期化
function Animation:initialize(...)
    self.animation = {}
    self:resetAnimations(...)
end

-- 現在のアニメーションを返す
function Animation:resetAnimations(animations, index, duration)
    local anim = self.animation
    anim.animations = animations or {}
    self:resetAnimationIndex(index)
    self:resetAnimationDuration(duration or anim.duration)
    anim.timer = anim.duration
end

-- アニメーションのインデックスを設定する
function Animation:resetAnimationIndex(index)
    self.animation.index = index or 1
end

-- アニメーションの間隔を設定する
function Animation:resetAnimationDuration(duration)
    self.animation.duration = duration or 0.1
end

-- 現在のアニメーションを返す
function Animation:getCurrentAnimation()
    return self.animation.animations[self.animation.index]
end

-- 更新
function Animation:updateAnimation(dt)
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
