-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Login\\Component\\LoginRepairComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local GameStrings = require("Data.gamestrings_data")
local ClientUtils = require("Utils.ClientUtils")
local LoginRepairComponent = Class.LightClass("LoginRepairComponent", UIComponent)
local logger = LoggerManager.getLogger("LoginRepairComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")

function LoginRepairComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.yesUButton = self.objectReference:GetRefValue("yesUButton")
	self.tipUText = self.objectReference:GetRefValue("tipUText")
	self.stateRepair = ""
	self.i18nTextIsCheck = "确定要检测并修复客户端？"
	self.i18nTextRunCheck = "修复检测中，请等待"
	self.i18nTextRunRepair = "修复执行中，请等待"
	self.i18nTextRepairTitle = "修复提示"
	self.i18nTextRepairDesc = "是否执行修复? 需下载文件数/字节数: "
end

function LoginRepairComponent:initView()
	self:addListener()
end

function LoginRepairComponent:addListener()
	function self.yesUButton.luaClick()
		self:onClickYesRepair()
	end
end

function LoginRepairComponent:onClickYesRepair()
	if self.stateRepair ~= "" then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("LoginRepairComponent: waiting=" .. self.stateRepair)
		end

		return
	end

	self.stateRepair = "check"

	ClientTextUtils.setText(self.tipUText, self.i18nTextRunCheck)
	CS.FunPlus.WorldX.Utils.LuaUtils.PatchStartCheckRepairInfo(function(totalFiles, totalBytes, humanBytes)
		self:onCallbackCheck(totalFiles, totalBytes, humanBytes)
	end)
end

function LoginRepairComponent:onCallbackCheck(totalFiles, totalBytes, humanBytes)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("LoginRepairComponent: onCallbackCheck files=" .. tostring(totalFiles) .. ", bytes=" .. tostring(totalBytes) .. ", humanBytes=" .. humanBytes)
	end

	local title = self.i18nTextRepairTitle
	local desc = self.i18nTextRepairDesc .. tostring(totalFiles) .. "/" .. tostring(totalBytes) .. "(" .. humanBytes .. ")"

	pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), desc, function()
		self:yesRunRepair()
	end, false, function()
		self:cancelRunRepair()
	end)
end

function LoginRepairComponent:yesRunRepair()
	self.stateRepair = "repair"

	ClientTextUtils.setText(self.tipUText, self.i18nTextRunRepair)
	CS.FunPlus.WorldX.Utils.LuaUtils.PatchStartRunRepair(function(msg)
		self:onCallbackRepair(msg)
	end, function(tip)
		self:onUpdateRepair(tip)
	end)
end

function LoginRepairComponent:cancelRunRepair()
	self.stateRepair = ""

	ClientTextUtils.setText(self.tipUText, self.i18nTextIsCheck)
end

function LoginRepairComponent:onUpdateRepair(tip)
	ClientTextUtils.setText(self.tipUText, tip)
end

function LoginRepairComponent:onCallbackRepair(msg)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("LoginRepairComponent: onCallbackRepair msg=" .. msg)
	end

	self.stateRepair = ""

	ClientTextUtils.setText(self.tipUText, self.i18nTextIsCheck)
end

return LoginRepairComponent
