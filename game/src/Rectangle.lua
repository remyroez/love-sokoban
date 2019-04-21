
-- 矩形モジュール
local Rectangle = {}

-- 初期化
function Rectangle:initialize(x, y, w, h)
    self.x = x or self.x or 0
    self.y = y or self.y or 0
    self.width = w or self.width or 0
    self.height = h or self.height or 0
end

-- 矩形の描画
function Rectangle:drawRectangle()
    love.graphics.rectangle('line', self:left(), self:top(), self:right() - self:left(), self:bottom() - self:top())
end

-- 左端の座標
function Rectangle:left()
    return self.x - self.width / 2
end

-- 上端の座標
function Rectangle:top()
    return self.y - self.height / 2
end

-- 右端の座標
function Rectangle:right()
    return self:left() + self.width
end

-- 下端の座標
function Rectangle:bottom()
    return self:top() + self.height
end

return Rectangle
