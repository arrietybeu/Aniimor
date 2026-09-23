-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\InterlinkGuideHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SysConfigData = require("Data.sys_config_data")
local InterlinkGuideHandler = Class.LightClass("InterlinkGuideHandler", GuideHandlerBase)

function InterlinkGuideHandler:getOwnedRefKeys()
	return {
		"bossRushUContainer"
	}
end

function InterlinkGuideHandler:getOwnedContainers()
	return {
		"bossRushUContainer"
	}
end

function InterlinkGuideHandler:onFindObjects(objectReference)
	self.bossRushUContainer = objectReference:GetRefValue("bossRushUContainer")
end

function InterlinkGuideHandler:onRefresh()
	if self.bossRushUContainer then
		self.bossRushUContainer:SetActive(true)

		if self.bossRushUContainer:CheckURLLoaded() then
			self:_refreshBossRush()
		else
			self.bossRushUContainer:LoadDefaultUrlManually(function()
				self:_refreshBossRush()
			end)
		end
	end
end

function InterlinkGuideHandler:onExit()
	if self.bossRushUContainer then
		self.bossRushUContainer:SetActive(false)
	end
end

function InterlinkGuideHandler:_refreshBossRush()
	local objectReference = self.bossRushUContainer.content:GetComponent("ObjectReference")
	local bossRushUWidget = objectReference:GetRefValue("bossRushUWidget")
	local bossRushTitleTxt = objectReference:GetRefValue("bossRushTitleTxt")
	local bossRushTxt = objectReference:GetRefValue("bossRushTxt")

	if bossRushUWidget then
		bossRushUWidget:SetActive(true)
	end

	if bossRushTitleTxt then
		ClientTextUtils.setText(bossRushTitleTxt, pg.getGameString(""))
	end

	if bossRushTxt then
		local totalStar = SysConfigData.BossRushMaxStarSideBoss * 2 + SysConfigData.BossRushMaxStarSideBoss * SysConfigData.BossRushStarMultiplierMidBoss * 1

		ClientTextUtils.setText(bossRushTxt, string.format("%s/%s", pg.me.curBossRushCycBestGrades, totalStar))
	end
end

return InterlinkGuideHandler
