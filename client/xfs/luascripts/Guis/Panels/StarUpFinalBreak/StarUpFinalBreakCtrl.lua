-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\StarUpFinalBreak\\StarUpFinalBreakCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("StarUpFinalBreakCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local StarUpFinalBreakCtrl = Class.LightClass("StarUpFinalBreakCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")

StarUpFinalBreakCtrl.messages = {}

local SLQTimerDelaySecs = {
	0,
	1,
	2
}

function StarUpFinalBreakCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	function self.view.listObtainUList.luaRenderItem(button, index, data)
		self:m_renderItem(button, index, data)
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	self.onCloseFunc = info.onCloseFunc

	self:refresh(info)
end

function StarUpFinalBreakCtrl:addListener()
	return
end

function StarUpFinalBreakCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.onCloseFunc then
		self.onCloseFunc()
	end
end

function StarUpFinalBreakCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function StarUpFinalBreakCtrl:onShow()
	return
end

function StarUpFinalBreakCtrl:onHide()
	return
end

function StarUpFinalBreakCtrl:refresh(info)
	local stage = info.stage or 0

	self.m_isReachedMaxed = PetManagementUtils.isMaxedResonance(info.stage, info.level)

	if stage <= 0 then
		self:close()

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("StarUpFinalBreakCtrl Close cause 1个参数 %s", stage)
		end

		return
	end

	self.slqTimerIds = {}

	for index, delaySecond in ipairs(SLQTimerDelaySecs) do
		self.slqTimerIds[index] = self:startTimer(function()
			local mIndex = index - 1

			self.view.rootUComp:TryChangePage("State", mIndex)
		end, delaySecond)
	end

	local extraStr = pg.getGameString("PET_RESONANCE_UPSTAGE_GAIN2")
	local nowResonanceCfg = PetManagementUtils.getPetResonanceCfg(stage, info.level)
	local gainStr = nowResonanceCfg and nowResonanceCfg.upStageBonusDesc or ""

	ClientTextUtils.setText(self.view.txtTipsUSDFText, ClientTextUtils.concatByLanguage(extraStr, pg.getLocalizationText(gainStr or "")))

	local obtainList = {
		{
			desc = gainStr or ""
		}
	}

	if self.m_isReachedMaxed then
		obtainList = {
			{
				desc = "PET_STARUP_REACHED_MAXED"
			}
		}
	end

	self.view.listObtainUList:SetList(obtainList)
end

function StarUpFinalBreakCtrl:m_renderItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.desc) or "")
end

return StarUpFinalBreakCtrl
