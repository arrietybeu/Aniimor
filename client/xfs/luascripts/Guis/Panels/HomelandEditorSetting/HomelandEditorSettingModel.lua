-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandEditorSetting\\HomelandEditorSettingModel.lua

local Time = require("Core.Common.Time")
local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local HomelandEditorSettingModel = Class.LightClass("HomelandEditorSettingModel", UIModel)

function HomelandEditorSettingModel:ctor()
	UIModel.ctor(self)
end

return HomelandEditorSettingModel
