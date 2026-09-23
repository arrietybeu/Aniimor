-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Items\\TopTipArea\\BossBaseInfoComp.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BuffUIUtils = require("Utils.BuffUIUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("BossBaseInfoComp")
local BossBaseInfoComp = Class.LightClass("BossBaseInfoComp")

function BossBaseInfoComp:ctor(owner)
	self.owner = owner
	self.curSpecialStateBuff = nil
end

function BossBaseInfoComp:onBind(objectReference)
	self.txtName = objectReference:GetRefValue("txtName")
	self.levelTxtName = objectReference:GetRefValue("levelTxtName")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.nameBossWidget = objectReference:GetRefValue("nameBossUWidget")
	self.elementsList = objectReference:GetRefValue("elementsList")

	function self.elementsList.luaRenderItem(button, index, data)
		if data.elementName then
			LuaUIUtils.setElementButtonNew(button, data.elementName)
		end
	end

	ClientTextUtils.setText(self.titleUSDFText, pg.getGameString("LEVEL_LITE"))
end

function BossBaseInfoComp:initTargetInfo()
	local target = self.owner.curTarget
	local npcInfo = target:getConfigData()
	local shinyName = ""

	if Utils.isLabelShiny(target.label) then
		shinyName = pg.getGameString("SHINY")
	end

	if Utils.isLabelBoss(target.label) then
		local fullName = ClientTextUtils.concatByLanguage(pg.getLocalizationText(shinyName), pg.getLocalizationText(npcInfo.BossShowName or ""))

		ClientTextUtils.setText(self.txtName, fullName)
		self.owner.rootComponent:TryChangePage("Enemy", "Boss")
	elseif Utils.isLabelElite(target.label) then
		local fullName = ClientTextUtils.concatByLanguage(pg.getLocalizationText(shinyName), pg.getLocalizationText(npcInfo.EliteShowName or ""))

		ClientTextUtils.setText(self.txtName, fullName)
		self.owner.rootComponent:TryChangePage("Enemy", "Elite")
	elseif pg.space:isNpcDuel() then
		local fullName = pg.me:npcDuelGetCurPetName()

		ClientTextUtils.setText(self.txtName, fullName)
		self.owner.rootComponent:TryChangePage("Enemy", "Boss")
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("BossBaseInfoComp:initTargetInfo current target label", target.label)
		end

		self.owner:refreshVisible()
	end

	if target.gender == Const.GENDER_TYPE_MALE then
		self.owner.rootComponent:TryChangePage("Gender", 0)
	elseif target.gender == Const.GENDER_TYPE_FEMALE then
		self.owner.rootComponent:TryChangePage("Gender", 1)
	else
		self.owner.rootComponent:TryChangePage("Gender", 2)
	end

	if npcInfo.bossType ~= nil then
		if npcInfo.bossType == 1 then
			self.owner.rootComponent:TryChangePage("BossType", 1)
		elseif npcInfo.bossType == 2 then
			self.owner.rootComponent:TryChangePage("BossType", 2)
		else
			self.owner.rootComponent:TryChangePage("BossType", 0)
		end
	end

	self:refreshBossThreatLevel(target, not ToBool(target:getConfigData().hideBloodLevel))
end

function BossBaseInfoComp:refreshLevel()
	if not self.owner.curTarget or not self.levelTxtName then
		return
	end

	local level = self.owner.curTarget.level

	if not level then
		return
	end

	ClientTextUtils.setText(self.levelTxtName, level)
end

function BossBaseInfoComp:refreshBossThreatLevel(target, forceVisible)
	if not self.owner.rootComponent or not self.levelTxtName then
		return
	end

	local level = target and target.level

	if not forceVisible or not level then
		LuaUIUtils.setUIViewVisible(self.levelTxtName, false)
		self.owner.rootComponent:TryChangePage("BattleWarning", 0)

		return
	end

	ClientTextUtils.setText(self.levelTxtName, level)
	LuaUIUtils.setUIViewVisible(self.levelTxtName, true)

	local threatState = LuaUIUtils.getThreatLevelState(level)

	self.owner.rootComponent:TryChangePage("Threat", threatState)

	if threatState == "dangerous" then
		self.owner.rootComponent:TryChangePage("BattleWarning", 1)
	elseif threatState == "veryDangerous" then
		self.owner.rootComponent:TryChangePage("BattleWarning", 2)
	else
		self.owner.rootComponent:TryChangePage("BattleWarning", 0)
	end
end

function BossBaseInfoComp:refreshElementInfo()
	if not self.owner.m_isCreated then
		return
	end

	if self.owner.curTarget then
		self.elementsList:SetList(LuaUIUtils.getTargetElementsInfos(self.owner.curTarget.elementTypes))
	end
end

function BossBaseInfoComp:onEntElementChange(entInfo)
	if not self.owner.m_isCreated then
		return
	end

	local entId = entInfo.entId

	if self.owner.curTarget and self.owner.curTarget.id == entId then
		self:refreshElementInfo()
	end
end

function BossBaseInfoComp:reset()
	self.curSpecialStateBuff = nil

	if self.nameBossWidget then
		self.nameBossWidget:SetActive(true)
		self:setVisible(true)
	end
end

function BossBaseInfoComp:setVisible(visible)
	if self.nameBossWidget then
		self.nameBossWidget:SetActiveQuickly(visible)
	end
end

function BossBaseInfoComp:isHidden()
	return self.nameBossWidget ~= nil and self.nameBossWidget.renderOpacity < 1
end

function BossBaseInfoComp:destroy()
	self:reset()
end

return BossBaseInfoComp
