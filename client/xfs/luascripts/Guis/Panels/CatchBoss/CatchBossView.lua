-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchBoss\\CatchBossView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchBossView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TimerManager = require("Core.Timer.TimerManager")
local UIUtils = CS.FunPlus.WorldX.Utils.UIUtils
local CatchBossView = Class.LightClass("CatchBossView", UIView)

function CatchBossView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnUnsnapUButton = self.objectReference:GetRefValue("btnUnsnapUButton")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.sightUWidget = self.objectReference:GetRefValue("sightUWidget")
	self.bossInfoUComponent = self.objectReference:GetRefValue("bossInfoUComponent")
	self.txtLvUBaseText = self.objectReference:GetRefValue("txtLvUBaseText")
	self.txtNameUBaseText = self.objectReference:GetRefValue("txtNameUBaseText")
	self.listElementUList = self.objectReference:GetRefValue("listElementUList")
	self.listTagUList = self.objectReference:GetRefValue("listTagUList")
end

function CatchBossView:registerObjects()
	return
end

function CatchBossView:initView()
	return
end

function CatchBossView:tickPos()
	if self.bossEntId then
		local bossEnt = pg.getEntity(self.bossEntId)

		if bossEnt then
			local uiPos = UIUtils.WorldToUIPosition(bossEnt:getPosition() + Vector3(0, bossEnt.eModel.height * 0.5, 0))

			self.sightUWidget.position = uiPos
		end
	end
end

function CatchBossView:showSight(bossEntId)
	self.bossEntId = bossEntId
end

function CatchBossView:onDestroy()
	if self.tickPosTimer then
		TimerManager.delFrameCb(self.tickPosTimer)
	end

	self.bossEntId = nil
end

return CatchBossView
