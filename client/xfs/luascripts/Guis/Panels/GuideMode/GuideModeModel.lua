-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GuideMode\\GuideModeModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GuideModeData = require("Data.guide_mode_data")
local GuideModeContentData = require("Data.guide_mode_content_data")
local GuideModeModel = Class.LightClass("GuideModeModel", UIModel)

function GuideModeModel:getGuideTypeList()
	local list = {}

	for k, id in pairs(GuideModeData) do
		list[#list + 1] = {
			typeId = id
		}
	end

	return list
end

function GuideModeModel:getModeType(typeId)
	local data = GuideModeData[typeId]

	if not data then
		return
	end

	self.helpIds = {}

	for _, helpId in ipairs(data.helpId) do
		self.helpIds[#self.helpIds + 1] = {
			id = helpId
		}
	end

	return self.helpIds
end

function GuideModeModel:getModeData(id)
	return GuideModeData[id] or {}
end

function GuideModeModel:getModeHelpContent(id)
	return GuideModeContentData[id] or {}
end

function GuideModeModel:maxGuide()
	return #GuideModeData
end

return GuideModeModel
