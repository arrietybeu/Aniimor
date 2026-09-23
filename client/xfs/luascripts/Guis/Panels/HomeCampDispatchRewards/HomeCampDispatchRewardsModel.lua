-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampDispatchRewards\\HomeCampDispatchRewardsModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampDispatchRewardsModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeCampDispatchRewardsModel = Class.LightClass("HomeCampDispatchRewardsModel", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeCampUtils = require("Utils.HomeCampUtils")

function HomeCampDispatchRewardsModel:setDispatchRewardsParams(params)
	params = type(params) == "table" and params or {}
	self.m_petIds = params.petIds or {}
	self.m_multiplies = params.multiplies or 1
	self.m_dropId = params.reward or 0
	self.m_dispatchId = params.dispatchId or 0
end

function HomeCampDispatchRewardsModel:getDispatchPetsAndRewards()
	if not self.m_petIds or #self.m_petIds <= 0 then
		return {}
	end

	if not self.m_dropId or self.m_dropId <= 0 then
		return {}
	end

	if not self.m_dispatchId or self.m_dispatchId <= 0 then
		return {}
	end

	local retPetsInfo = HomeCampUtils.getCampPetsOffLineInfo(self.m_petIds)
	local ret = {}
	local preDispatchRewardIdNumsListDict = HomeCampUtils.getPreDispatchRewardIdNumsListDict()

	for index, v in ipairs(retPetsInfo) do
		local idNumsList = preDispatchRewardIdNumsListDict[index] or {}
		local rewardItems = LuaUIUtils.getDisplayPreDispatchRewardItems(idNumsList, self.m_multiplies or 1) or {}

		table.insert(ret, {
			petInfo = v,
			rewardItems = rewardItems
		})
	end

	return ret
end

return HomeCampDispatchRewardsModel
