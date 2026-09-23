-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchSurveyCompleted\\PetDispatchSurveyCompletedModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetDispatchSurveyCompletedModel = Class.LightClass("PetDispatchSurveyCompletedModel", UIModel)

function PetDispatchSurveyCompletedModel:ctor()
	self.clueId = nil
	self.state = nil
	self.mode = "single"
	self.eventId = nil
	self.photoId = nil
	self.rewards = {}
end

function PetDispatchSurveyCompletedModel:refresh(info)
	info = info or {}
	self.clueId = info.clueId or self.clueId
	self.state = info.state or self.state
	self.photoId = info.photoId or self.photoId
	self.rewards = info.rewards or self.rewards or {}
end

return PetDispatchSurveyCompletedModel
