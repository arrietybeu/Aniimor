-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\StarUpBreak\\StarUpBreakCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("StarUpBreakCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local StarUpBreakCtrl = Class.LightClass("StarUpBreakCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local TimerManager = require("Core.Timer.TimerManager")
local math_floor = math.floor
local string_format = string.format

StarUpBreakCtrl.messages = {}

function StarUpBreakCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.view.btnCloseUButton.luaClick()
		if self.m_isBlock then
			return
		end

		self:close()
	end

	function self.view.listAttributeUList.luaRenderItem(button, index, data)
		self:m_onRenderItem(button, index, data)
	end

	self.onCloseFunc = info.onCloseFunc

	self:refresh(info)
end

function StarUpBreakCtrl:addListener()
	return
end

function StarUpBreakCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.delayTimer then
		TimerManager.removeTimer(self.delayTimer)
	end

	self.delayTimer = nil

	if self.onCloseFunc then
		self.onCloseFunc()
	end
end

function StarUpBreakCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.m_isBlock = true

	if self.delayTimer then
		TimerManager.removeTimer(self.delayTimer)

		self.delayTimer = nil
	end

	self.delayTimer = TimerManager.addTimer(1, function()
		self.m_isBlock = false
	end)
end

function StarUpBreakCtrl:onShow()
	return
end

function StarUpBreakCtrl:onHide()
	return
end

function StarUpBreakCtrl:refresh(info)
	local stage = info.stage or 0

	self.m_isReachedMaxed = PetManagementUtils.isMaxedResonance(info.stage, info.level)

	if stage <= 0 then
		self:close()

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("StarUpBreakCtrl Close cause 1个参数 %s", stage)
		end

		return
	end

	ClientTextUtils.setText(self.view.txtBreakUSDFText, PetManagementUtils.getBreakStageL10nDesc(stage))
	self.view.starGradeUWidget:TryChangePage("Grade", stage - 1)

	local extraStr = pg.getGameString("PET_RESONANCE_UPSTAGE_GAIN1")
	local nowResonanceCfg = PetManagementUtils.getPetResonanceCfg(stage, info.level)
	local gainStr = nowResonanceCfg and nowResonanceCfg.upStageBonusDesc or ""

	if self.m_isReachedMaxed then
		gainStr = "PET_STARUP_REACHED_MAXED"

		ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString(gainStr or ""))
	else
		ClientTextUtils.setText(self.view.txtTipsUSDFText, ClientTextUtils.concatByLanguage(extraStr, pg.getLocalizationText(gainStr or "")))
	end

	self.view.listAttributeUList:SetList(info.attributeList or {})
end

function StarUpBreakCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function StarUpBreakCtrl:m_onRenderItem(button, index, data)
	if not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local rootUComp = objectReference:GetRefValue("rootUComp")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local textNumUSDFText = objectReference:GetRefValue("textNumUSDFText")
	local textAddUSDFText = objectReference:GetRefValue("textAddUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.l10nName or "")
	ClientTextUtils.setText(textNumUSDFText, data.newVDispTxt or "")
	ClientTextUtils.setText(textAddUSDFText, data.newVDispTxt or "")
	rootUComp:TryChangePage("State", 0)
end

return StarUpBreakCtrl
