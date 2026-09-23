-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopDesign\\Component\\WorkShopHairDesignComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearanceData = require("Data.appearance_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local WorkShopHairDesignComponent = Class.LightClass("WorkShopHairDesignComponent", UIComponent)

function WorkShopHairDesignComponent:findObjects()
	return
end

function WorkShopHairDesignComponent:initView()
	self:addListener()
end

function WorkShopHairDesignComponent:addListener()
	function self.view.hairDyeUButton.luaClick()
		self:onClickHairDye()
	end

	function self.view.hairBoneUButton.luaClick()
		self:onClickHairCut()
	end

	self.view.hairBoneUButton:SetActiveFastest(false)
end

function WorkShopHairDesignComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function WorkShopHairDesignComponent:onClickHairDye()
	self:onOpenHairPanel(AvatarUtils.HAIR_DESIGN_TYPE.COLOR)
end

function WorkShopHairDesignComponent:onClickHairCut()
	self:onOpenHairPanel(AvatarUtils.HAIR_DESIGN_TYPE.SETTING)
end

function WorkShopHairDesignComponent:onOpenHairPanel(designType)
	if self.selectedHairId == nil then
		pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_HAIR_WARN"), 3)

		return
	end

	if not LuaUIUtils.isHairSuitClaimed(pg.me, self.selectedHairId) then
		pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_HAIR_NOT_OWNED"), 3)

		return
	end

	local info = {
		isDesignMode = true,
		avatarType = AvatarUtils.AVATAR_TYPE.HAIR,
		presetKey = pg.game.avatar:getPresetKey(pg.me),
		hairId = self.selectedHairId,
		designType = designType
	}

	pg.global.ui:open(UIConst.UI_ID_AVATAR, info)
end

function WorkShopHairDesignComponent:onEnterPage()
	self.view.rootComponent:TryChangePage("Design", "Hair")
	self:refreshHairList()
end

function WorkShopHairDesignComponent:onOptionSelectedChanged(data)
	if not data then
		return
	end

	self.selectedHairId = data.id
end

function WorkShopHairDesignComponent:onOptionClicked(slotData, oldData, data)
	if pg.global.avatarMgr and pg.global.avatarMgr.globalStack then
		pg.global.avatarMgr.globalStack:Clear()
	end

	pg.game.avatar.optionSelectedData = data

	AvatarUtils.equipHairSuit(self.ctrl.presetKey, data.id, not data.claimed, function(params)
		self:changeHair(params)
	end)

	if data.claimed then
		AvatarUtils.applyHairPresetOrRuntimeDefault(data.id, CallbackHandler(self, "refreshHairByCustom"))
	end
end

function WorkShopHairDesignComponent:refreshHairByCustom()
	AvatarUtils.refreshHairByCustom()
end

function WorkShopHairDesignComponent:onFilterSelectedChanged(slotData, filterFunc)
	self:refreshHairList(slotData.id, filterFunc)
end

function WorkShopHairDesignComponent:onFilterClicked(slotData, filterFunc)
	self:refreshHairList(slotData.id, filterFunc)
end

function WorkShopHairDesignComponent:onSearchChanged(slotData, filterFunc)
	self:refreshHairList(slotData.id, filterFunc)
end

function WorkShopHairDesignComponent:resolveTargetHairSuitId()
	local selected = pg.game.avatar.optionSelectedData

	if selected and selected.id then
		if AvatarHairSuitData[selected.id] then
			return selected.id
		end

		local partData = AppearanceData[selected.id]

		if partData and partData.hairId then
			return partData.hairId
		end
	end

	local entity = self.model.avatarScene:getCurEntity()

	return LuaUIUtils.tryGetEntityHairSuitId(entity)
end

function WorkShopHairDesignComponent:refreshHairList(forceFirstSuitId, filterFunc)
	local presetData = pg.game.avatar:getAvatarPresetData(self.ctrl.presetKey) or {}
	local targetHairId = forceFirstSuitId or self:resolveTargetHairSuitId()
	local optionList = self.model:getHairSuitList(presetData.body, targetHairId, filterFunc)

	self.ctrl.slotOptionComponent.slotRootTransform.gameObject:SetActiveEx(false)
	self.ctrl.slotOptionComponent.optionUList:SetList(optionList)

	if targetHairId then
		for index, v in ipairs(optionList) do
			if v.id == targetHairId or v.itemId == targetHairId then
				self.ctrl.slotOptionComponent.optionUList:SelectItem(index - 1)

				return
			end
		end
	end

	self.ctrl.slotOptionComponent.optionUList:SelectItem(0)
end

function WorkShopHairDesignComponent:changeHair(param)
	self:refreshHairListEquipState()
end

function WorkShopHairDesignComponent:refreshHairListEquipState()
	local data = self.ctrl.slotOptionComponent.optionUList.itemData
	local hairSuitId = LuaUIUtils.tryGetEntityHairSuitId(self.model.avatarScene:getCurEntity())

	for _, v in pairs(data) do
		if v.state ~= LuaUIUtils.SELECT_STATE.NULL then
			v.equipped = v.id == hairSuitId
			v.state = v.equipped and LuaUIUtils.SELECT_STATE.ROLE_WEAR or v.claimed and LuaUIUtils.SELECT_STATE.HAVE or LuaUIUtils.SELECT_STATE.LOCKED
		end
	end

	self.ctrl.slotOptionComponent.optionUList:RefreshList()
end

return WorkShopHairDesignComponent
