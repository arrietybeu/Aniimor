-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityChooseBallPopup\\PetFertilityChooseBallPopupModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PetFertilityChooseBallPopupModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetFertilityChooseBallModel = require("Guis.Panels.PetFertilityChooseBall.PetFertilityChooseBallModel")
local PetFertilityChooseBallPopupModel = Class.LightClass("PetFertilityChooseBallPopupModel", UIModel)
local CaptureUtils = require("Common.Utils.CaptureUtils")

function PetFertilityChooseBallPopupModel:setup(eggItemId, currentItemId, suggestItemId, onlyRecommend)
	self.eggItemId = eggItemId or 0
	self.currentItemId = currentItemId
	self.suggestItemId = suggestItemId
	self._cubeModel = PetFertilityChooseBallModel.new()
	self.cubeList = {}

	if not onlyRecommend then
		local curInfo = currentItemId and self._cubeModel:getCubeInfoById(currentItemId, self.eggItemId)

		if curInfo then
			curInfo.itemId = currentItemId
			curInfo.isRecommend = currentItemId == suggestItemId
			self.cubeList[#self.cubeList + 1] = curInfo
		end
	end

	local suggestInfo = suggestItemId and self._cubeModel:getCubeInfoById(suggestItemId, self.eggItemId)

	if suggestInfo then
		suggestInfo.itemId = suggestItemId
		suggestInfo.isRecommend = true

		local cubeBallCfg = CaptureUtils.getFetilityCubeCfg(suggestItemId)

		suggestInfo.suggestDesc = cubeBallCfg and cubeBallCfg.suggestDesc

		local preCubeIndex = #self.cubeList or -1
		local preCubeInfo = self.cubeList[preCubeIndex]

		if preCubeInfo then
			preCubeInfo.suggestDesc = cubeBallCfg and cubeBallCfg.suggestDesc
		end

		self.cubeList[#self.cubeList + 1] = suggestInfo
	end

	self.selectedItemId = onlyRecommend and suggestItemId or currentItemId
end

function PetFertilityChooseBallPopupModel:getCubeList()
	return self.cubeList or {}
end

function PetFertilityChooseBallPopupModel:getSelectedItemId()
	return self.selectedItemId
end

function PetFertilityChooseBallPopupModel:setSelectedItemId(itemId)
	self.selectedItemId = itemId
end

function PetFertilityChooseBallPopupModel:getCubeInfoById(itemId)
	if not itemId then
		return nil
	end

	for _, info in ipairs(self.cubeList or EMPTY_TABLE) do
		if info.itemId == itemId then
			return info
		end
	end

	return nil
end

function PetFertilityChooseBallPopupModel:getSelectedInfo()
	return self:getCubeInfoById(self.selectedItemId)
end

function PetFertilityChooseBallPopupModel:isSuggestSelected()
	return self.selectedItemId ~= nil and self.selectedItemId == self.suggestItemId
end

return PetFertilityChooseBallPopupModel
