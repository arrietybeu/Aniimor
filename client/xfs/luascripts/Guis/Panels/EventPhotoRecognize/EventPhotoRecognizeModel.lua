-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventPhotoRecognize\\EventPhotoRecognizeModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("EventPhotoRecognizeModel")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ClientConst = require("Const.ClientConst")
local ActivityConst = require("Common.Const.ActivityConst")
local EventPhotoRecognizeModel = Class.LightClass("EventPhotoRecognizeModel", UIModel)

function EventPhotoRecognizeModel:getPhoto(path)
	if self.photoPath2Sprite and self.photoPath2Sprite[path] then
		return self.photoPath2Sprite[path]
	end

	self.photoPath2Sprite = self.photoPath2Sprite or {}
	self.photoPath2Sprite[path] = pg.global.mobileCameraMgr:GetSpriteByFilePath(path)

	return self.photoPath2Sprite[path]
end

function EventPhotoRecognizeModel:destroyPhoto(path)
	if self.photoPath2Sprite and self.photoPath2Sprite[path] then
		pg.global.mobileCameraMgr:DestroySpriteTexture(self.photoPath2Sprite[path])

		self.photoPath2Sprite[path] = nil
	end
end

function EventPhotoRecognizeModel:getClueList(templateId, targetTemplateId)
	local items = {}
	local info = ClientActivityUtils.getPuppetPhotoClueAllText(templateId)
	local targetInfo = ClientActivityUtils.getPuppetPhotoClueAllText(targetTemplateId)

	if Utils.tableIsEmptyOrNil(info) or Utils.tableIsEmptyOrNil(targetInfo) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("EventPhotoRecognizeModel:getClueList petInfo is empty! photoTemplateId:%s targetTemplateId:%s", templateId, targetTemplateId)
		end

		return items
	end

	for i = ActivityConst.PuppetPhotoClueType.Attr, ActivityConst.PuppetPhotoClueType.Explore do
		local state

		if info[i][2] == targetInfo[i][2] then
			local unlock = pg.me.formResearchClueMap and pg.me.formResearchClueMap[i] or false

			if unlock then
				state = 1
			else
				state = 2
			end
		else
			state = 0
		end

		items[i] = {
			str = info[i][2],
			state = state
		}
	end

	return items
end

return EventPhotoRecognizeModel
