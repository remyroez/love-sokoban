
local folderOfThisFile = (...) .. '.'

local Scene = require(folderOfThisFile .. 'Scene')

require(folderOfThisFile .. 'Boot')
require(folderOfThisFile .. 'Game')
require(folderOfThisFile .. 'Select')

return Scene
