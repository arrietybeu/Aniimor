-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopDesign\\WorkShopDesignCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local SlotOptionComponent = require("Guis.Panels.AppearanceV2.Component.Common.SlotOptionComponent")
local WorkShopDesignCtrl = Class.LightClass("WorkShopDesignCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local AvatarUtils = require("Guis.Utils.AvatarUtils")

WorkShopDesignCtrl.messages = {
	[MessageName.ON_PART_MODEL_ALL_LOADED] = {
		"onPartModelLoaded",
		true
	}
}

function WorkShopDesignCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	if info.component then
		self.component = info.component.new(self)
	end

	self.slotOptionComponent = SlotOptionComponent(self, self.view.leftPanelTransform)

	self.slotOptionComponent:addListener()

	self.presetKey = pg.game.avatar:getPresetKey(pg.me)

	self.model:initAvatarSceneData()
	self:onEnterPage(info.slotId)
	self:onPartModelLoaded()
	self.view.btnHairTieUButton.gameObject:SetActiveEx(false)
end

function WorkShopDesignCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:closePanel()
	end
end

function WorkShopDesignCtrl:onDestroy()
	self.slotOptionComponent:removeListener()

	self.slotOptionComponent = nil
	self.component = nil

	UICtrl.onDestroy(self)
end

function WorkShopDesignCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.view.leftLayoutBoxUWidget:SetNavGroupDefaultItem(self.view.backgroundSelectorUSelector)
	AvatarUtils.renderPhotographyStudioBackgroundSelector(self.view.backgroundSelectorUSelector)
end

function WorkShopDesignCtrl:refreshConsoleBarState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_WorkShopDesign_CameraZoom", true)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_WorkShopDesign_CameraMove", true)
end

function WorkShopDesignCtrl:onShow()
	self.model.avatarScene:addCameraZoomKeyBinding(self.view.gameObject)
	self.slotOptionComponent:setFilterRule()
	self.slotOptionComponent:reset()
end

function WorkShopDesignCtrl:onHide()
	return
end

function WorkShopDesignCtrl:onVisibleChange(visible)
	if visible then
		self.model.avatarScene:registerGesture(self.uid, {
			maskRayBoxTrans = self.view.maskRayBoxTrans
		})
	else
		self.model.avatarScene:unRegisterGesture(self.uid)
	end
end

function WorkShopDesignCtrl:closePanel()
	self:dismiss()
end

function WorkShopDesignCtrl:onEnterPage(slotId)
	if self.component and self.component.onEnterPage then
		self.component:onEnterPage(slotId)
	end
end

function WorkShopDesignCtrl:onSlotSelectedChanged(data)
	if self.component and self.component.onSlotSelectedChanged then
		self.component:onSlotSelectedChanged(data)
	end
end

function WorkShopDesignCtrl:onSlotClicked(oldData, data)
	if self.component and self.component.onSlotClicked then
		self.component:onSlotClicked(oldData, data)
	end
end

function WorkShopDesignCtrl:onOptionSelectedChanged(data)
	if self.component and self.component.onOptionSelectedChanged then
		self.component:onOptionSelectedChanged(data)
	end
end

function WorkShopDesignCtrl:onOptionClicked(slotData, oldData, data, button)
	if self.component and self.component.onOptionClicked then
		self.component:onOptionClicked(slotData, oldData, data, button)
	end
end

function WorkShopDesignCtrl:onFilterSelectedChanged(slotData, filterFunc)
	if self.component and self.component.onFilterSelectedChanged then
		self.component:onFilterSelectedChanged(slotData, filterFunc)
	end
end

function WorkShopDesignCtrl:onFilterClicked(slotData, filterFunc)
	if self.component and self.component.onFilterClicked then
		self.component:onFilterClicked(slotData, filterFunc)
	end
end

function WorkShopDesignCtrl:onSearchChanged(slotData, filterFunc)
	if self.component and self.component.onSearchChanged then
		self.component:onSearchChanged(slotData, filterFunc)
	end
end

function WorkShopDesignCtrl:onPartModelLoaded()
	if self.component and self.component.onPartModelLoaded then
		self.component:onPartModelLoaded()
	end
end

return WorkShopDesignCtrl
