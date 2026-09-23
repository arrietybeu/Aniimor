-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GuideMode\\GuideModeCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("GuideModeCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local SettingFuncListData = require("Data.setting_func_list_data")
local GuideModeCtrl = Class.LightClass("GuideModeCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

GuideModeCtrl.messages = {}

local BtnState = {
	BackAndNext = 3,
	Back = 2,
	Confirm = 1,
	Next = 0,
	BackAndConfirm = 4
}

function GuideModeCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.curState = 0

	local guideModelIDs = info.guideModeIDs

	self.curGuideIds = guideModelIDs or {
		1
	}
	self.curIndex = 1
	self.curModeIdSel = {}

	self:setBtnState()
end

function GuideModeCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		if self.curIndex > 1 then
			self.curIndex = self.curIndex - 1

			self:setBtnState()
			self:setLeftInfo()
			self.view.listTabUList:RefreshList()
		end
	end

	function self.view.listTabUList.luaRenderItem(button, index, data)
		local coms = self.view:getTabItemComs(button)
		local confData = self.model:getModeHelpContent(data.id)

		if confData then
			coms.recommend.gameObject:SetActiveEx(index == 0)
			ClientTextUtils.setText(coms.name, pg.getLocalizationText(confData.text))
			button:TryChangePage("button", self.curModeIdSel[self.curIndex] == data.id and 5 or 0)

			button.isSelected = self.curModeIdSel[self.curIndex] == data.id

			function button.luaClick()
				self:setHelpModelSelect(data.id, button)
			end
		end
	end

	function self.view.btnNextUButton.luaClick(btn)
		if self.curIndex < #self.curGuideIds then
			self.curIndex = self.curIndex + 1

			self:setBtnState()
			self:setLeftInfo()
		end
	end

	function self.view.btnStartUButton.luaClick(btn)
		self:dismiss()
	end

	ClientTextUtils.setText(self.view.txtBackName, pg.getGameString("LAST_STEP"))
	ClientTextUtils.setText(self.view.txtNextName, pg.getGameString("NEXT_STEP"))
	ClientTextUtils.setText(self.view.txtConfirmName, pg.getGameString("CONSOLE_BAR_CONFIRM"))
	ClientTextUtils.setText(self.view.txtTips, pg.getGameString("CAN_CHANGE_IN_SET"))
end

function GuideModeCtrl:setBtnState()
	local guideCount = #self.curGuideIds

	if guideCount == 1 then
		self.curState = BtnState.Confirm
	elseif self.curIndex == guideCount then
		self.curState = BtnState.BackAndConfirm
	elseif guideCount == 2 then
		self.curState = BtnState.Next
	else
		self.curState = BtnState.BackAndNext
	end
end

function GuideModeCtrl:setHelpModelSelect(helpId, button)
	local confData = self.model:getModeHelpContent(helpId)

	if not confData then
		return
	end

	self.curModeIdSel[self.curIndex] = helpId
	self.curState = self.curIndex < self.model:maxGuide() and 1 or 2

	if button then
		button:TryChangePage("button", self.curModeIdSel[self.curIndex] == helpId and 5 or 0)

		button.isSelected = self.curModeIdSel[self.curIndex] == helpId
	end

	self:setRightInfo(self.curModeIdSel[self.curIndex])

	for j, value in ipairs(confData.functionDefaultValue) do
		if type(value) == "table" then
			local settingConf = SettingFuncListData[value[1]]

			if not settingConf then
				return
			end

			local funcType = settingConf.funcType

			ClientSettingUtils.setValue(funcType, value[2], settingConf.funcParam)
			ClientSettingUtils.setRelationValue(funcType, value[2])

			local logKey = funcType

			if settingConf.funcParam and settingConf.funcParam[1] then
				logKey = logKey .. settingConf.funcParam[1]
			end

			ClientSettingUtils.setLog(logKey, value[2])
		end
	end
end

function GuideModeCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function GuideModeCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:setLeftInfo()
end

function GuideModeCtrl:onShow()
	return
end

function GuideModeCtrl:onHide()
	return
end

function GuideModeCtrl:dismiss()
	UICtrl.dismiss(self)
end

function GuideModeCtrl:setLeftInfo()
	self.view.rootCom:TryChangePage("State", self.curState)

	local modelID = self.curGuideIds[self.curIndex]
	local helpIds = self.model:getModeType(modelID)

	if helpIds and next(helpIds) then
		self.view.listTabUList:SetList(helpIds)

		local curHelpId = self.curModeIdSel[self.curIndex]

		if not curHelpId then
			self.view.listTabUList:SelectItem(0)

			curHelpId = helpIds[1].id

			self:setHelpModelSelect(curHelpId)
		end

		self:setRightInfo(curHelpId)
	end

	local modeData = self.model:getModeData(modelID)

	ClientTextUtils.setText(self.view.modeTitle, pg.getLocalizationText(modeData.name))
end

function GuideModeCtrl:setRightInfo(curHelpId)
	local confData = self.model:getModeHelpContent(curHelpId)

	if confData then
		ClientTextUtils.setText(self.view.txtSamllTitle, pg.getLocalizationText(confData.text))
		ClientTextUtils.setText(self.view.txtDetailsUBaseText, pg.getLocalizationText(confData.textDec))
		self.view.imgPicUImage.gameObject:SetActiveEx(confData.pic)
		self.view.videoPlayer.gameObject:SetActiveEx(confData.video)

		if confData.pic then
			self.view.imgPicUImage.url = confData.pic
		elseif confData.video then
			self.view.videoPlayer.resID = confData.video
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("cfg not find : " .. curModeId)
		end
	end
end

return GuideModeCtrl
