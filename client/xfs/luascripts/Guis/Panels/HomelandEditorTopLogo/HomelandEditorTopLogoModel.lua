-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandEditorTopLogo\\HomelandEditorTopLogoModel.lua

local Time = require("Core.Common.Time")
local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local HomelandEditorTopLogoModel = Class.LightClass("HomelandEditorTopLogoModel", UIModel)

function HomelandEditorTopLogoModel:ctor()
	UIModel.ctor(self)
end

return HomelandEditorTopLogoModel
