-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FissureInfo\\FissureInfoCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("FissureInfoCtrl")
local FissureInfoCtrl = Class.LightClass("FissureInfoCtrl", UICtrl)

function FissureInfoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	info = info or {}
	self.curLevelId = info.levelId or pg.me.curLevelId

	self:initView()
	self:_initLists()
end

function FissureInfoCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.btnBackUButton.luaClick()
		self:resumeGameTime()
		self:close()
	end
end

function FissureInfoCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshAll()
	self:pauseGameTime()
end

function FissureInfoCtrl:initView()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("Rift_Mutation"))
end

function FissureInfoCtrl:_initLists()
	function self.view.listUList.luaRenderItem(button, index, data)
		self:_renderMutationItem(button, index, data)
	end
end

function FissureInfoCtrl:_renderMutationItem(button, index, data)
	local objRef = button:GetComponent("ObjectReference")
	local buffCfg = data.config or {}
	local icon = objRef:GetRefValue("iconImagePro")
	local title = objRef:GetRefValue("titleUSDFText")

	icon.url = buffCfg.buffIcon

	ClientTextUtils.setTextWithId(title, buffCfg.buffName)

	local scrollRect = objRef:GetRefValue("scrollRectUScrollRect")
	local contentOR = scrollRect.content:GetComponent("ObjectReference")

	if NotNil(contentOR) then
		local detail = contentOR:GetRefValue("textInfoUSDFText")

		if NotNil(detail) then
			ClientTextUtils.setTextWithId(detail, buffCfg.desc or buffCfg.descShort)
		end
	end

	CS.XGUI.LayoutMgr.ForceRebuildLayoutImmediate(button)
end

function FissureInfoCtrl:refreshAll()
	if not self.curLevelId then
		logger:warn("[FissureInfo] open without levelId")

		return
	end

	local mutations = self.model:getMutations(self.curLevelId)

	if #mutations == 0 then
		logger:warn("[FissureInfo] no mutation for level", tostring(self.curLevelId))
	end

	self.view.listUList:SetList(mutations)
end

function FissureInfoCtrl:pauseGameTime()
	if not pg.me:isInTeam() and pg.space then
		pg.space:pauseGameByType(Const.GameTimeScaleType.FISSURE_INFO, -1)

		self.isGameTimeStopped = true
	end
end

function FissureInfoCtrl:resumeGameTime()
	if self.isGameTimeStopped and pg.space then
		pg.space:resumeGameByType(Const.GameTimeScaleType.FISSURE_INFO)

		self.isGameTimeStopped = nil
	end
end

function FissureInfoCtrl:onDestroy()
	self:resumeGameTime()
	UICtrl.onDestroy(self)
end

return FissureInfoCtrl
