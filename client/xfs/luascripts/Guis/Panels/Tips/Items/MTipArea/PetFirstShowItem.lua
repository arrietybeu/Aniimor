-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\MTipArea\\PetFirstShowItem.lua

local Class = require("Core.Framework.Class")
local BaseQueueItem = require("Guis.Panels.Tips.Items.BaseQueueItem")
local UIConst = require("Const.UIConst")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local PetFirstShowItem = Class.LightClass("PetFirstShowItem", BaseQueueItem)

function PetFirstShowItem:onInit()
	self:setMaxLimit(1)
end

function PetFirstShowItem:pushData(data)
	self:enqueue(data)
end

function PetFirstShowItem:onUpdate()
	self:tryPopupItem()
end

function PetFirstShowItem:tryPopupItem()
	if self:isQueueEmpty() or self:isReachTheLimit() then
		return
	end

	local data = self:dequeue()

	self:addRunItem(data)
	self:_refreshFlag(true)

	if IS_MOBILE then
		data.lowMode = true
		data.ignoreUIScene = true

		pg.global.ui.firstPetShow:open(data, nil, function()
			self:removeItem(data)
			self:checkTipStateOnClose()
		end)
	else
		pg.global.ui.firstPetShow:open(data, nil, function()
			self:removeItem(data)
			self:checkTipStateOnClose()
		end, {
			ignoreDisableMainCamera = true
		})
	end
end

function PetFirstShowItem:onClearRunningList(force)
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_FIRST_SHOW) then
		pg.global.ui.firstPetShow:close()
	else
		self:_refreshFlag(false)
	end
end

function PetFirstShowItem:checkTipStateOnClose()
	self:_refreshFlag(not self:isQueueEmpty())
end

function PetFirstShowItem:_refreshFlag(needHide)
	if self._lastNeedHide == needHide then
		return
	end

	self._lastNeedHide = needHide

	if needHide then
		pg.global.ui.tips:hideAllAreasWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_PetFirstShow, {
			TipAreaConst.AREAS.M,
			TipAreaConst.AREAS.B,
			TipAreaConst.AREAS.BI,
			TipAreaConst.AREAS.A1I
		})
		self:_setHudLUActive(false)
	else
		pg.global.ui.tips:showAllAreasWithFlag(TipAreaConst.UITipAreaFlag.AreaFlag_PetFirstShow)
		self:_setHudLUActive(true)
	end
end

function PetFirstShowItem:_setHudLUActive(show)
	local inOfflineScene = ClientUtils.isInDouYinOfflineScene()

	if not inOfflineScene then
		pg.global.ui.hudV2:setLeftVisible(show)
	end
end

function PetFirstShowItem:GMPushData(data)
	local newPets = {}

	for i = 1, 5 do
		local pData = PetData[1001200]
		local p = {
			lv = 1,
			gender = 0,
			label = 1,
			spLabel = "测试LB",
			isBoss = true,
			isRare = true,
			templateId = 1001200,
			headIconName = pData.iconName,
			name = pData.BossShowName,
			spCode = LuaUIUtils.SP_CODE.SP_FEATURE
		}

		newPets[i] = p
	end

	data.newPets = newPets
end

return PetFirstShowItem
