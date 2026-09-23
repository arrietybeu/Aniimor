-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\BallTargetSB.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local UIConst = require("Const.UIConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local BallTargetSB = Class.LightClass("BallTargetSB", LevelItem)

function BallTargetSB:ctor(sandbox, spawnInfo, syncInfo)
	BallTargetSB.super.ctor(self, sandbox, spawnInfo, syncInfo)

	self.hitCount = syncInfo.hitCount or 0
	self.targetHits = syncInfo.targetHits or 1
	self.isUIShowing = false
end

function BallTargetSB:onInit()
	BallTargetSB.super.onInit(self)

	if self.state == 1 then
		self:actuallyShowUI()
	else
		self:actuallyHideUI()
	end
end

function BallTargetSB:setSyncInfo(syncInfo, isInit)
	if syncInfo.targetHits ~= nil then
		self.targetHits = syncInfo.targetHits
	end

	if syncInfo.hitCount ~= nil then
		local oldHitCount = self.hitCount or 0

		self.hitCount = syncInfo.hitCount

		if self.isUIShowing then
			self:updateProgress()
		end
	end

	BallTargetSB.super.setSyncInfo(self, syncInfo, isInit)
end

function BallTargetSB:onValueChange(fieldName, value, isInit)
	if fieldName == "state" then
		if isInit == 1 then
			self.hitCount = 0

			self:actuallyShowUI()

			if self.isUIShowing then
				pg.global.ui.gameplayProgress:setCount(0)
			end
		elseif isInit == 2 then
			self:actuallyHideUI()
			pg.global.ui.tips:showA1Tips({
				text = "开始投球淘金热！"
			})
		else
			self:actuallyHideUI()
		end
	end

	BallTargetSB.super.onValueChange(self, fieldName, value, isInit)
end

function BallTargetSB:actuallyShowUI()
	if self.isUIShowing then
		return
	end

	pg.global.ui.gameplayProgress:initProgress(self.hitCount, self.targetHits, "投球目标", function()
		return
	end, self)
	pg.global.ui:open(UIConst.UI_ID_GAMEPLAY_PROGRESS)

	self.isUIShowing = true
end

function BallTargetSB:actuallyHideUI()
	if not self.isUIShowing then
		return
	end

	pg.global.ui:close(UIConst.UI_ID_GAMEPLAY_PROGRESS)

	self.isUIShowing = false
end

function BallTargetSB:updateProgress()
	if self.isUIShowing then
		pg.global.ui.gameplayProgress:setCount(self.hitCount)
	end
end

return BallTargetSB
