
local folderOfThisFile = (...) .. '.'

local Scene = require(folderOfThisFile .. 'Scene')

require(folderOfThisFile .. 'Boot')
require(folderOfThisFile .. 'Game')

return Scene
