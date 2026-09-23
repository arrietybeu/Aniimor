-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\TargetEntityInfoItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local PuppetData = require("Data.puppet_data")
local TargetEntityInfoItem = Class.LightClass("TargetEntityInfoItem", BaseQueueItem)

function TargetEntityInfoItem:onInit()
	self:setMaxLimit(1)

	self.uContainer = self.uWidget
end

function TargetEntityInfoItem:onUpdate()
	self:tryPopupItem()
	self:refreshRemainTime()
end

function TargetEntityInfoItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	data.endTime = Time.secondCache + (data.duration or 3)

	self:addRunItem(data)
	self:initUContainer(data)
end

function TargetEntityInfoItem:onClearRunningList(force)
	self:clearRecycleRunningList(force)
end

function TargetEntityInfoItem:refreshRemainTime()
	if not self:isRunning() then
		return
	end

	local data = self.runList[1]

	if Time.secondCache < data.endTime then
		return
	end

	self:recycleToast(data)
end

function TargetEntityInfoItem:hideById(id)
	local param = self:firstRunItem()

	if param and (param.uniqueId == id or not param.uniqueId) then
		self:recycleToast(param)
	end
end

function TargetEntityInfoItem:initUContainer(data)
	if not self.uContainer:CheckURLLoaded() then
		self.uContainer:LoadDefaultUrlManually(self:guardRunCallback(data, function(loadedItem)
			if IsNil(loadedItem) or self.uContainer.content ~= loadedItem then
				return
			end

			if data.removing or not self:isRunning() then
				return
			end

			self:renderItem(loadedItem, data)
		end))
	else
		self:renderItem(self.uContainer.content, data)
	end
end

function TargetEntityInfoItem:renderItem(item, data)
	if IsNil(item) then
		return
	end

	if data.removing then
		return
	end

	if data.timer then
		self:killTimer(data.timer)

		data.timer = nil
	end

	local objectReference = item:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.pets = {
		data.pet
	}
	self.listUList.luaRenderItem = self:guardRunCallback(data, function(button, index, itemData)
		local objectReference = button:GetComponent("ObjectReference")
		local progressUProgress = objectReference:GetRefValue("progressUProgress")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		if itemData == nil then
			return
		end

		local puppetData = PuppetData[itemData.templateId]

		if puppetData then
			local hpRatio = itemData.actorCombatAttribute:getHpRatio()

			progressUProgress.minValue = 0
			progressUProgress.maxValue = 1
			progressUProgress.value = hpRatio
			iconUImage.url = LuaUIUtils.getPetIcon(puppetData.iconName, LuaUIUtils.PET_ICON, puppetData.label)

			if hpRatio >= 0.8 then
				button:TryChangePage("HpStage", 0)
			elseif hpRatio >= 0.2 then
				button:TryChangePage("HpStage", 1)
			else
				button:TryChangePage("HpStage", 2)
			end
		end
	end, item)

	self.listUList:SetList(self.pets)

	data.timer = self:startTimer(self:guardRunCallback(data, function()
		self:refreshEntityInfo(data)
	end, item), 0.5, true)
end

function TargetEntityInfoItem:refreshEntityInfo(data)
	if data == nil or data.removing then
		return
	end

	if not self:isRunning() then
		return
	end

	if IsNil(self.uContainer) or IsNil(self.uContainer.content) or IsNil(self.listUList) then
		return
	end

	local pet = data.pet

	if pet == nil or pet.actorCombatAttribute == nil then
		self:recycleToast(data, true)

		return
	end

	self.listUList:Refresh()
end

function TargetEntityInfoItem:onRecycleStarted(data, target)
	if data.timer then
		self:killTimer(data.timer)

		data.timer = nil
	end
end

return TargetEntityInfoItem
