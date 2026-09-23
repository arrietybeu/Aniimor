-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityV0\\VitalityV0Model.lua

local logger = require("Core.Log.LoggerManager").getLogger("VitalityV0Model")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local VitalityV0Model = Class.LightClass("VitalityV0Model", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")
local CurrencyConsumeData = require("Data.currency_consume_data")

function VitalityV0Model:getVitalityDataList()
	local res = {}

	for k, v in pairs(CurrencyConsumeData) do
		local item = {
			id = k,
			title = pg.getLocalizationText(v.name),
			goTo = v.goTo,
			guideId = v.guideId
		}

		self:parseConsume(item)
		self:parseRewardList(item)

		res[#res + 1] = item
	end

	return res
end

function VitalityV0Model:parseConsume(data)
	local cData = CurrencyConsumeData[data.id]

	if cData.eventParam == nil then
		return
	end

	local consumes = {}

	for i, v in ipairs(cData.eventParam) do
		consumes[i] = LuaUIUtils.getItemInfoById(v[1])
		consumes[i].num = v[2]
	end

	data.consumes = consumes
end

function VitalityV0Model:parseRewardList(data)
	local cData = CurrencyConsumeData[data.id]

	if cData.rewardDisplay == nil then
		return
	end

	local rewards = {}

	for i, v in ipairs(cData.rewardDisplay) do
		rewards[i] = LuaUIUtils.getItemInfoById(v[1])
		rewards[i].num = v[2]
	end

	data.rewards = rewards
end

return VitalityV0Model
