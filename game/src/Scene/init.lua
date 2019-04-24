
local folderOfThisFile = (...) .. '.'

local Scene = require(folderOfThisFile .. 'Scene')

require(folderOfThisFile .. 'Boot')
require(folderOfThisFile .. 'Title')
require(folderOfThisFile .. 'Select')
require(folderOfThisFile .. 'Game')

return Scene
