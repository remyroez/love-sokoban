
-- 矩形モジュール
local Rectangle = {}

-- 初期化
function Rectangle:initialize(x, y, w, h)
    self.x = x or 0
    self.y = y or 0
    self.w = w or 100
    self.h = h or 100
end

-- 矩形の描画
function Rectangle:drawRectangle()
    love.graphics.rectangle('line', self:left(), self:top(), self:right() - self:left(), self:bottom() - self:top())
end

-- 左端の座標
function Rectangle:left()
    return self.x - self.w / 2
end

-- 上端の座標
function Rectangle:top()
    return self.y - self.h / 2
end

-- 右端の座標
function Rectangle:right()
    return self:left() + self.w
end

-- 下端の座標
function Rectangle:bottom()
    return self:top() + self.h
end

return Rectangle
