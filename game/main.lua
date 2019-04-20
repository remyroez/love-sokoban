
-- グローバルに影響があるライブラリ
require 'autobatch'
require 'sbss'

-- シーンクラス
local Scene = require 'Scene'

-- シーン
local scene

-- 読み込み
function love.load()
    -- シーンの作成とロード
    scene = Scene()
    scene:load()
end

-- 更新
function love.update(dt)
    -- シーンの更新
    scene:update(dt)
end

-- 描画
function love.draw()
    -- 画面のリセット
    love.graphics.reset()

    -- シーンの描画
    scene:draw()
end

-- キー入力
function love.keypressed(key, scancode, isrepeat)
    if key == 'escape' then
        -- 終了
        love.event.quit()
    elseif key == 'f5' then
        -- リスタート
        love.event.quit('restart')
    else
        -- シーンに処理を渡す
        scene:keypressed(key, scancode, isrepeat)
    end
end

-- マウス入力
function love.mousepressed(...)
    -- シーンに処理を渡す
    scene:mousepressed(...)
end
