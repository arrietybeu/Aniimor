-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsMode\\Component\\GrabEggsSeasonInfoComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local GrabEggsSeasonInfoComponent = Class.LightClass("GrabEggsSeasonInfoComponent", UIComponent)
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")

GrabEggsSeasonInfoComponent.messages = {
	[MessageName.GRAB_EGG_REWARD_BOX_CHANGED] = {
		"onRewardBoxChanged",
		true
	},
	[MessageName.GRAB_EGG_RANK_CHANGED] = {
		"onRankChanged",
		true
	},
	[MessageName.GRAB_EGG_RANK_PROGRESS_CHANGED] = {
		"onRankProgressChanged",
		true
	}
}

function GrabEggsSeasonInfoComponent:findObjects()
	self.container = self.view.seasonInfoUContainer
end

function GrabEggsSeasonInfoComponent:findContainerObjects()
	local objectReference = self.container.content.transform:GetComponent("ObjectReference")

	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.btnSeasonRankUButton = objectReference:GetRefValue("btnSeasonRankUButton")
	self.rankIconUImage = objectReference:GetRefValue("rankIconUImage")
	self.rankLevelUSDFText = objectReference:GetRefValue("rankLevelUSDFText")
	self.rankProgressUList = objectReference:GetRefValue("rankProgressUList")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.numUSDFText = objectReference:GetRefValue("numUSDFText")

	if self.btnSeasonRankUButton then
		self.btnSeasonRankUButton.interactable = true

		function self.btnSeasonRankUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_SEASON_RANK_MAIN)
		end

		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.GRAB_EGG_MODE_SEASON_RANK, self.btnSeasonRankUButton, function()
			if self.model:hasClaimableRankReward() then
				return RedDotConst.RedDotStyle.REWARD
			end

			return RedDotConst.RedDotStyle.NONE
		end)
	end

	if self.rankProgressUList then
		function self.rankProgressUList.luaRenderItem(button, _, data)
			button:TryChangePage("Stage", data.filled and 1 or 0)
		end
	end

	self.slotButtons = {}

	function self.listRewardUList.luaRenderItem(button, index, data)
		self.slotButtons[index] = button

		self:renderBoxSlot(button, index, data)
	end
end

function GrabEggsSeasonInfoComponent:onDestroy()
	self:killBoxTimer()

	self.currentSlots = nil
	self.slotButtons = nil

	UIComponent.onDestroy(self)
end

function GrabEggsSeasonInfoComponent:initView()
	self.isContainerLoading = false
end

function GrabEggsSeasonInfoComponent:initContainer(callback)
	if self.isContainerLoading then
		return
	end

	if self.container:CheckURLLoaded() then
		if callback then
			callback()
		end

		return
	end

	self.isContainerLoading = true

	self.container:LoadDefaultUrlManually(function()
		self.isContainerLoading = false

		self:findContainerObjects()
		self.container:SetActive(true)

		if callback then
			callback()
		end
	end)
end

function GrabEggsSeasonInfoComponent:refresh()
	self:initContainer(function()
		self:refreshSeasonInfo()
		self:refreshRankInfo()
		self:refreshRankRewardRedDot()
		self:refreshBoxList()
	end)
end

function GrabEggsSeasonInfoComponent:refreshSeasonInfo()
	local info = self.model:getSeasonDisplayInfo()

	if not info then
		return
	end

	ClientTextUtils.setText(self.numUSDFText, info.numText)
	ClientTextUtils.setText(self.txtNameUSDFText, info.name)
end

function GrabEggsSeasonInfoComponent:refreshRankInfo()
	local info = self.model:getRankDisplayInfo()

	if not info then
		return
	end

	if self.rankLevelUSDFText then
		ClientTextUtils.setText(self.rankLevelUSDFText, self.model:getDisplayRoman(info.bigRank, info.smallRank))
	end

	if self.rankIconUImage then
		self.rankIconUImage.url = info.icon
	end

	if self.rankProgressUList then
		local rankProgress = {}

		for index = 1, info.upNumber do
			rankProgress[index] = {
				filled = index <= info.eggStar
			}
		end

		self.rankProgressUList:SetList(rankProgress)
	end
end

function GrabEggsSeasonInfoComponent:refreshRankRewardRedDot()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.GRAB_EGG_MODE_SEASON_RANK)
end

function GrabEggsSeasonInfoComponent:clearAllSlotRedDots()
	if not self.currentSlots then
		return
	end

	for i = 1, #self.currentSlots do
		local path = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_REWARD_BOX_ITEM, i)

		pg.global.setRedDot(path, nil, false, RedDotConst.RedDotStyle.NONE)
	end
end

function GrabEggsSeasonInfoComponent:refreshBoxList()
	self.slotButtons = {}
	self.currentSlots = self.model:buildBoxSlotList()

	self.listRewardUList:SetList(self.currentSlots)
	self:resetBoxTimer()
end

function GrabEggsSeasonInfoComponent:resetBoxTimer(slots)
	self:killBoxTimer()

	if not self:hasCountingDownSlot() then
		return
	end

	self.boxtimer = self:startTimer(function()
		self:tickCountDown()
	end, 1, true)
end

function GrabEggsSeasonInfoComponent:hasCountingDownSlot()
	if not self.currentSlots then
		return false
	end

	for _, slot in pairs(self.currentSlots) do
		if slot.id and not slot.isReady then
			return true
		end
	end

	return false
end

function GrabEggsSeasonInfoComponent:tickCountDown()
	if not self.currentSlots then
		return
	end

	local stillCounting = false

	for i, slot in ipairs(self.currentSlots) do
		if slot.id and not slot.isReady then
			local box = pg.me.rewardBoxList and pg.me.rewardBoxList[i]

			if box and box.id ~= 0 then
				local remainSec = math.max(0, (box.timestamp or 0) - Time.secondCache)

				slot.remainSec = remainSec
				slot.isReady = remainSec <= 0

				local btn = self.slotButtons[i - 1]

				if btn then
					self:updateSlotCountDown(btn, slot, i - 1)
				end

				if not slot.isReady then
					stillCounting = true
				end
			end
		end
	end

	if not stillCounting then
		self:killBoxTimer()
	end
end

function GrabEggsSeasonInfoComponent:updateSlotCountDown(button, data, index)
	if data.isReady then
		button:TryChangePage("Stage", 3)

		if index then
			local redDotPath = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_REWARD_BOX_ITEM, index)

			pg.global.setRedDot(redDotPath, button, true, RedDotConst.RedDotStyle.REWARD)
		end

		function button.luaClick()
			pg.me:serverMsg("RPC_CS_OpenRobEggLevelRewardBox", data.rewardId)
		end

		return
	end

	local oc = button:GetComponent("ObjectReference")
	local sliderNmlUSlider = oc:GetRefValue("sliderNmlUSlider")

	if sliderNmlUSlider then
		sliderNmlUSlider.value = 1 - data.remainSec / data.totalSec
	end
end

function GrabEggsSeasonInfoComponent:killBoxTimer()
	if self.boxtimer then
		self:killTimer(self.boxtimer)

		self.boxtimer = nil
	end
end

function GrabEggsSeasonInfoComponent:renderBoxSlot(button, index, data)
	local redDotPath = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_REWARD_BOX_ITEM, index)

	pg.global.setRedDot(redDotPath, button, data.isReady == true, RedDotConst.RedDotStyle.REWARD)

	if data.isLocked then
		button:TryChangePage("Stage", 0)

		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_SEASONINFO_POPUP)
		end

		return
	end

	if data.isFull then
		button:TryChangePage("Stage", 4)

		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_SEASONINFO_POPUP)
		end

		return
	end

	if data.isEmpty then
		button:TryChangePage("Stage", 1)

		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_SEASONINFO_POPUP)
		end

		return
	end

	local oc = button:GetComponent("ObjectReference")
	local iconUImage = oc:GetRefValue("iconUImage")

	iconUImage.url = data.icon

	if data.isReady then
		button:TryChangePage("Stage", 3)

		function button.luaClick()
			pg.me:serverMsg("RPC_CS_OpenRobEggLevelRewardBox", data.rewardId)
		end
	else
		button:TryChangePage("Stage", 2)
		self:updateSlotCountDown(button, data, index)

		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_GRAB_EGGS_SEASONINFO_POPUP)
		end
	end
end

function GrabEggsSeasonInfoComponent:onRewardBoxChanged()
	if not self.container:CheckURLLoaded() then
		return
	end

	self:refreshRankInfo()
	self:refreshBoxList()
end

function GrabEggsSeasonInfoComponent:onRankChanged()
	if not self.container:CheckURLLoaded() then
		return
	end

	self:refreshRankInfo()
	self:refreshRankRewardRedDot()
	self:refreshBoxList()
end

function GrabEggsSeasonInfoComponent:onRankProgressChanged()
	if not self.container:CheckURLLoaded() then
		return
	end

	self:refreshRankInfo()
	self:refreshRankRewardRedDot()
end

return GrabEggsSeasonInfoComponent
