-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NpcDuelStart\\NpcDuelStartView.lua

local logger = require("Core.Log.LoggerManager").getLogger("NpcDuelStartView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local NpcDuelStartView = Class.LightClass("NpcDuelStartView", UIView)

function NpcDuelStartView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnBackText = objectReference:GetRefValue("btnBackText")
	self.textPlayerNameUSDFText = objectReference:GetRefValue("textPlayerNameUSDFText")
	self.listLeftUList = objectReference:GetRefValue("listLeftUList")
	self.listRightUList = objectReference:GetRefValue("listRightUList")
	self.btnSwitchUSelector = objectReference:GetRefValue("btnSwitchUSelector")
	self.petManagementUButton = objectReference:GetRefValue("petManagementUButton")
	self.titleTowerObjectReference = objectReference:GetRefValue("titleTowerObjectReference")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.rightTagUSDFText = objectReference:GetRefValue("rightTagUSDFText")
	self.RawImgURawImage = objectReference:GetRefValue("RawImgURawImage")
	self.buttonStartUButton = objectReference:GetRefValue("buttonStartUButton")
	self.palyerNameObjectReference = objectReference:GetRefValue("palyerNameObjectReference")
	self.curatorNameObjectReference = objectReference:GetRefValue("curatorNameObjectReference")
	self.buttonStartUSDFText = objectReference:GetRefValue("buttonStartUSDFText")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.uIPbBattleRoomMain2UComponent = objectReference:GetRefValue("uIPbBattleRoomMain2UComponent")
	self.loadingVenueNameUSDFText = objectReference:GetRefValue("loadingVenueNameUSDFText")
	self.loadingVenueSubUSDFText = objectReference:GetRefValue("loadingVenueSubUSDFText")
	self.textTeamUSDFText = objectReference:GetRefValue("textTeamUSDFText")
	self.blackMaskTransform = objectReference:GetRefValue("blackMaskTransform")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.spaceBuffObjectReference = objectReference:GetRefValue("spaceBuffObjectReference")
	self.rewardTransform = objectReference:GetRefValue("rewardTransform")
	self.panelTimeObjectReference = objectReference:GetRefValue("panelTimeObjectReference")

	self:initLeft(self.palyerNameObjectReference)
	self:initRight(self.curatorNameObjectReference)
	self:initBuff()
	self:initPlaneTime()
end

function NpcDuelStartView:initLeft(objectReference)
	self.left = {}
	self.left.textPlayerNameUSDFText = objectReference:GetRefValue("textPlayerNameUSDFText")
	self.left.textPlayerNameSmallTextPlus = objectReference:GetRefValue("textPlayerNameSmallTextPlus")
	self.left.textTagUSDFText = objectReference:GetRefValue("textTagUSDFText")
	self.left.nationLevelObjectReference = objectReference:GetRefValue("nationLevelObjectReference")
	self.left.iconCuratorUImage = objectReference:GetRefValue("iconCuratorUImage")
end

function NpcDuelStartView:initRight(objectReference)
	self.right = {}
	self.right.textPlayerNameUSDFText = objectReference:GetRefValue("textPlayerNameUSDFText")
	self.right.textPlayerNameSmallTextPlus = objectReference:GetRefValue("textPlayerNameSmallTextPlus")
	self.right.textTagUSDFText = objectReference:GetRefValue("textTagUSDFText")
	self.right.nationLevelObjectReference = objectReference:GetRefValue("nationLevelObjectReference")
	self.right.iconCuratorUImage = objectReference:GetRefValue("iconCuratorUImage")
end

function NpcDuelStartView:initBuff()
	local objectReference = self.spaceBuffObjectReference

	self.buffIconUImage = objectReference:GetRefValue("buffIconUImage")
	self.buffNameUSDFText = objectReference:GetRefValue("buffNameUSDFText")
	self.buffSkillUButton = objectReference:GetRefValue("buffSkillUButton")
end

function NpcDuelStartView:initPlaneTime()
	local objectReference = self.panelTimeObjectReference

	self.txtTitle1USDFText = objectReference:GetRefValue("txtTitle1USDFText")
	self.txtTimeUSDFText = objectReference:GetRefValue("txtTimeUSDFText")
	self.txtTitle2USDFText = objectReference:GetRefValue("txtTitle2USDFText")
	self.txtSubUSDFText = objectReference:GetRefValue("txtSubUSDFText")
end

function NpcDuelStartView:registerObjects()
	return
end

function NpcDuelStartView:initView()
	return
end

return NpcDuelStartView
