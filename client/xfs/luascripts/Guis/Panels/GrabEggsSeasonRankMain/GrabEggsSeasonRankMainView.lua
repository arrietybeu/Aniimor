-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsSeasonRankMain\\GrabEggsSeasonRankMainView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggsSeasonRankMainView = Class.LightClass("GrabEggsSeasonRankMainView", UIView)

function GrabEggsSeasonRankMainView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = self.widget
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnOverviewUButton = objectReference:GetRefValue("btnOverviewUButton")
	self.btnRewardOverviewUButton = objectReference:GetRefValue("btnRewardOverviewUButton")
	self.btnRewardOverviewUSDFText = objectReference:GetRefValue("btnRewardOverviewUSDFText")
	self.seasonTimeUWidget = objectReference:GetRefValue("seasonTimeUWidget")
	self.seasonNameUSDFText = objectReference:GetRefValue("seasonNameUSDFText")
	self.seasonTimeUSDFText = objectReference:GetRefValue("seasonTimeUSDFText")
	self.rankNameUSDFText = objectReference:GetRefValue("rankNameUSDFText")
	self.rankIconUImage = objectReference:GetRefValue("rankIconUImage")
	self.iconBoardUImage = objectReference:GetRefValue("iconBoardUImage")
	self.rankLevelUSDFText = objectReference:GetRefValue("rankLevelUSDFText")
	self.eggNumUSDFText = objectReference:GetRefValue("eggNumUSDFText")
	self.scoreNumUSDFText = objectReference:GetRefValue("scoreNumUSDFText")
	self.scoreUProgress = objectReference:GetRefValue("scoreUProgress")
	self.eggUList = objectReference:GetRefValue("eggUList")
	self.descUList = objectReference:GetRefValue("descUList")
	self.currentRewardUList = objectReference:GetRefValue("currentRewardUList")
	self.reward1UWidget = objectReference:GetRefValue("reward1UWidget")
	self.reward1TitleUSDFText = objectReference:GetRefValue("reward1TitleUSDFText")
	self.title1NameUSDFText = objectReference:GetRefValue("title1NameUSDFText")
	self.reward1UList = objectReference:GetRefValue("reward1UList")
	self.reward1PointNumUSDFText = objectReference:GetRefValue("reward1PointNumUSDFText")
	self.reward2UWidget = objectReference:GetRefValue("reward2UWidget")
	self.reward2TitleUSDFText = objectReference:GetRefValue("reward2TitleUSDFText")
	self.title2NameUSDFText = objectReference:GetRefValue("title2NameUSDFText")
	self.reward2UList = objectReference:GetRefValue("reward2UList")
	self.reward2PointNumUSDFText = objectReference:GetRefValue("reward2PointNumUSDFText")
	self.panelLineUWidget = objectReference:GetRefValue("panelLineUWidget")
	self.rewardPopupUWidget = objectReference:GetRefValue("rewardPopupUWidget")
	self.rewardPopupCloseUButton = objectReference:GetRefValue("rewardPopupCloseUButton")
	self.rewardPopupTitleUSDFText = objectReference:GetRefValue("rewardPopupTitleUSDFText")
	self.rewardPopupUList = objectReference:GetRefValue("rewardPopupUList")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.rankScoretextUSDFText = objectReference:GetRefValue("rankScoretextUSDFText")
	self.VIPtextUSDFText = objectReference:GetRefValue("VIPtextUSDFText")
	self.NowRewardtextUSDFText = objectReference:GetRefValue("NowRewardtextUSDFText")
	self.btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
	self.rankDetailtxtNameUSDFText = objectReference:GetRefValue("rankDetailtxtNameUSDFText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.cutLineUWidget = objectReference:GetRefValue("cutLineUWidget")
	self.listTab3thUList = objectReference:GetRefValue("listTab3thUList")
end

function GrabEggsSeasonRankMainView:registerObjects()
	return
end

function GrabEggsSeasonRankMainView:initView()
	return
end

return GrabEggsSeasonRankMainView
