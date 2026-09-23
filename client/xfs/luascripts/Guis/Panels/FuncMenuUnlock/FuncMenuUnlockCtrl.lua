-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FuncMenuUnlock\\FuncMenuUnlockCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FuncMenuData = require("Data.func_menu_data")
local FuncMenuListData = require("Data.func_menu_list_data")
local FuncMenuBottomListData = require("Data.func_menu_common_use_data")
local GuidenceItemData = require("Data.guidence_item_data")
local GuidenceSubItemData = require("Data.guidence_sub_item_data")
local FuncMenuUnlockCtrl = Class.LightClass("FuncMenuUnlockCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")

FuncMenuUnlockCtrl.messages = {}
FuncMenuUnlockCtrl.FuncMode = {
	Normal = 0,
	Other = 2,
	RightList = 1
}
FuncMenuUnlockCtrl.SpecialFunc = {
	"PETRESEARCH",
	"PETBALL",
	"SPECIALTRAIN",
	"PLAYERENHANCEMENT",
	"MAP"
}

function FuncMenuUnlockCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info

	self:initUI()
end

function FuncMenuUnlockCtrl:addListener()
	function self.view.btnBgUButton.luaClick()
		if self.info.helpId then
			self.view.uIPbFunctionUnlockUComponent:TryChangePage("State", 1)
		else
			self:close()
			self:tryOpenFuncMenu()
		end
	end

	function self.view.previousUButton.luaClick()
		self.detailIndex = math.max(self.detailIndex - 1, 1)

		self:refreshFuncDetail(self.detailIndex)
	end

	function self.view.nextUButton.luaClick()
		self.detailIndex = math.min(self.detailIndex + 1, self.detailIndexMax)

		self:refreshFuncDetail(self.detailIndex)
	end

	function self.view.btnSaveUButton.luaClick()
		self:close()
		self:tryOpenFuncMenu()
	end
end

function FuncMenuUnlockCtrl:checkCanOpen(showNotice, info)
	if info and info.entrance then
		if info.entrance[1] == FuncMenuUnlockCtrl.FuncMode.Normal then
			return FuncMenuListData[info.entrance[2]] ~= nil
		elseif info.entrance[1] == FuncMenuUnlockCtrl.FuncMode.RightList then
			return FuncMenuBottomListData[info.entrance[2]] ~= nil
		end
	end

	return UICtrl.checkCanOpen(self, showNotice, info)
end

function FuncMenuUnlockCtrl:tryOpenFuncMenu()
	if self.info.entrance and (self.info.entrance[1] == FuncMenuUnlockCtrl.FuncMode.Normal or self.info.entrance[1] == FuncMenuUnlockCtrl.FuncMode.RightList) then
		pg.global.ui.funcMenu:open({
			unlockFuncId = self.info.entrance[2],
			guideGroupId = self.info.guideGroupId,
			dialogueGraphId = self.info.dialogueGraphId
		})
	end
end

function FuncMenuUnlockCtrl:initUI()
	if self.info.helpId then
		self:initFuncDetail()
		self:refreshFuncDetail(self.detailIndex)
	end

	if self.info.entrance then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU) then
			pg.global.ui.funcMenu:closePanel()
		end

		self.view.uIPbFunctionUnlockUComponent:TryChangePage("State", 0)

		if self.info.entrance[1] == FuncMenuUnlockCtrl.FuncMode.Normal then
			self:renderFuncButton(self.view.funMenuItemUComponent, FuncMenuListData[self.info.entrance[2]])
		elseif self.info.entrance[1] == FuncMenuUnlockCtrl.FuncMode.RightList then
			self:renderFuncButton(self.view.funMenuItemUComponent, FuncMenuBottomListData[self.info.entrance[2]])
		end

		local length = self.view.newAnimation.clip.length

		self:startTimer(function()
			if self.info.helpId then
				self:showFuncDetail()
			else
				self.view.btnSaveUButton.luaClick()
			end
		end, length)
	else
		self.view.funcMenuDetailUButton:SetActive(false)
		self.view.uIPbFunctionUnlockUComponent:TryChangePage("State", 1)
	end

	ClientTextUtils.setText(self.view.btnSaveNameUText, pg.getGameString("COMPLETE"))
end

function FuncMenuUnlockCtrl:renderFuncButton(button, data)
	if not data then
		return
	end

	local useSpecialIcon = table.contains(self.SpecialFunc, data.functionName)

	button:TryChangePage("IconType", useSpecialIcon and 1 or 0)

	if useSpecialIcon then
		self.view.bigIconUImage.url = data.img
	else
		self.view.iconUImage.url = data.img
	end

	local funcName = pg.getLocalizationText(data.name)

	ClientTextUtils.setText(self.view.nameUBaseText, funcName)
	ClientTextUtils.setText(self.view.funcDetailNameUBaseText, funcName)
end

function FuncMenuUnlockCtrl:initFuncDetail()
	self.detailIndex = 1
	self.detailIndexMax = 1

	local helpCfg = GuidenceItemData[self.info.helpId]

	if not helpCfg then
		return
	end

	local helpIds = helpCfg.helpId

	self.detailIndexMax = #helpIds

	local data = {}

	for _, helpId in ipairs(helpIds) do
		table.insert(data, {
			tIndex = 0,
			helpId = helpId
		})
	end

	self.view.detailUList:SetList(data)
end

function FuncMenuUnlockCtrl:refreshFuncDetail(index)
	local helpCfg = GuidenceItemData[self.info.helpId]

	if not helpCfg then
		return
	end

	self.view.detailUList:SelectItem(index - 1)

	local helpId = helpCfg.helpId[index]
	local helpData = GuidenceSubItemData[helpId]

	if not helpData then
		return
	end

	self.view.previousUButton.interactable = index ~= 1
	self.view.nextUButton.interactable = index ~= self.detailIndexMax

	self.view.uIPbFunctionUnlockUComponent:TryChangePage("Type", helpData.pic and 0 or 1)
	self.view.uIPbFunctionUnlockUComponent:TryChangePage("Save", index == #helpCfg.helpId and 1 or 0)

	if helpData.pic then
		self.view.guideUImage.url = helpData.pic
	end

	self.view.guideUVideoPlayer:SetActive(false)

	if helpData.video then
		self.view.guideUVideoPlayer:SetActive(true)

		self.view.guideUVideoPlayer.resID = helpData.video
	end

	ClientTextUtils.setText(self.view.funcDetailNameUBaseText, pg.getLocalizationText(helpCfg.name))
	ClientTextUtils.setText(self.view.funcDetailContentUBaseText, pg.getLocalizationText(helpData.text))
end

function FuncMenuUnlockCtrl:showFuncDetail()
	self.view.uIPbFunctionUnlockUComponent:TryChangePage("State", 1)
end

function FuncMenuUnlockCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function FuncMenuUnlockCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function FuncMenuUnlockCtrl:onShow()
	return
end

function FuncMenuUnlockCtrl:onHide()
	return
end

return FuncMenuUnlockCtrl
