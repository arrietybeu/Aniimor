-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ExampleDict.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local class = require("Core.Framework.Class")
local ExampleDict = class.LiteClass("ExampleDict", CustomDict)

return ExampleDict
