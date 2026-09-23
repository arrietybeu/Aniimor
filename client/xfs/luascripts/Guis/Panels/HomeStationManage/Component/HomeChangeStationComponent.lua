-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeStationManage\\Component\\HomeChangeStationComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeChangeStationComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local HomeCampData = require("Data.home_camp_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeCarPlateData = require("Data.home_car_plate_data")
local Const = require("Common.Const.Const")
local SceneData = require("Data.scene_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeCampUtils = require("Utils.HomeCampUtils")
local HomeChangeStationComponent = Class.LightClass("HomeChangeStationComponent", UIComponent)

function HomeChangeStationComponent:onCtor(info)
	self.inStationManage = info and info.inStationManage or false
	self.normalPlate = self:getCurStationPlate()
	self.curPlate = nil

	local campInfo = pg.me:getPlayerHomeCampInfo()
	local campLineInfo = campInfo.lineInfo or {}

	self.isManager = campLineInfo.ownerUid == pg.me.uid
	self.isPrivate = campLineInfo.isPrivate or false
end

function HomeChangeStationComponent:findObjects()
	return
end

function HomeChangeStationComponent:initView()
	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
		self:refreshPageInfo()
	end)
end

function HomeChangeStationComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.tabList = objectReference:GetRefValue("tabList")
	self.campList = objectReference:GetRefValue("campList")
	self.confirmBtn = objectReference:GetRefValue("confirmBtn")
	self.btnSpecify = objectReference:GetRefValue("btnSpecify")
	self.rewardList = objectReference:GetRefValue("rewardList")
	self.txtName = objectReference:GetRefValue("txtName")
	self.txtDetails = objectReference:GetRefValue("txtDetails")
	self.backBtn = objectReference:GetRefValue("backBtn")
	self.txtRewardUSDFText = objectReference:GetRefValue("txtRewardUSDFText")
	self.topBackUWidget = objectReference:GetRefValue("topBackUWidget")
	self.listTabPlotUList = objectReference:GetRefValue("listTabPlotUList")
	self.backgroundUImage = objectReference:GetRefValue("backgroundUImage")

	self.listTabPlotUList:SetActive(true)
	self.topBackUWidget:SetActive(not self.inStationManage)
	self.btnSpecify:SetActive(not self.inStationManage)
end

function HomeChangeStationComponent:addListener()
	function self.backBtn.luaClick()
		self.ctrl:close()
	end

	function self.confirmBtn.luaClick()
		if self.isPrivate then
			if self.isManager then
				local campData = HomeCampData[self.campId]
				local nameText = pg.getLocalizationText(campData.name)

				pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getFormatText(pg.getGameString("HOMECAR_MIGRATION_STATION_MANAGER"), nameText), function()
					self:confirm()
				end)
			else
				pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("HOMECAR_MIGRATION_STATION_PLAYER"), function()
					self:confirm()
				end)
			end
		else
			self:confirm()
		end
	end

	function self.listTabPlotUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local imgMaskLockUImage = objectReference:GetRefValue("imgMaskLockUImage")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")

		ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(data.plateName))

		if data.plateIcon then
			iconUImage.url = data.plateIcon
		end

		local isUnLocked = self:isPlateLocked(data.plateCondition, data.plateId)

		button:TryChangePage("Unlock", isUnLocked and 0 or 1)

		button.interactable = isUnLocked
		button.navForceNonInteractable = not isUnLocked
		button.buttonType = isUnLocked and CS.XGUI.EButtonType.Radio or CS.XGUI.EButtonType.Default

		function button.luaClick()
			if isUnLocked then
				self:refreshCampList(data)
			else
				pg.global.ui.tips:showTextTip(pg.getGameString("HOMECAR_REGION_NOT_UNLOCKED"))
			end
		end
	end

	function self.campList.luaRenderItem(button, index, data)
		self:rendererCampItem(button, index, data)
	end

	function self.rewardList.luaRenderItem(button, index, data)
		self:rendererRewardItem(button, index, data)
	end

	function self.btnSpecify.luaClick()
		self:onSpecifyBtnClick()
	end
end

function HomeChangeStationComponent:getCurStationPlate()
	local curCampId = pg.me.curCampStaticId

	if curCampId and curCampId ~= 0 then
		local campData = HomeCampData[curCampId] or {}

		return campData.plateId or 1
	else
		return 1
	end
end

function HomeChangeStationComponent:isPlateLocked(plateCondition, plateId)
	if not plateCondition then
		return true
	end

	return ClientUtils.checkCondition(plateCondition)
end

function HomeChangeStationComponent:refreshPageInfo()
	if self.uWidget and not self.uWidget:CheckURLLoaded() then
		return
	end

	local campId = pg.me.curCampStaticId or 0

	if campId == 0 then
		campId = HomelandConfigData.unlockDefaultCampId or 84222580
	end

	self.curPlate = nil

	self:refreshPlateList()
	self:selectCamp(campId, true)
end

function HomeChangeStationComponent:refreshCampList(data, force)
	if not data then
		return
	end

	if not force and data.plateId == self.curPlate then
		return
	end

	self.curPlate = data.plateId

	local campList = {}

	for campId, campData in pairs(HomeCampData) do
		if campData.plateId == self.curPlate then
			campList[#campList + 1] = {
				campId = campId
			}
		end
	end

	table.sort(campList, function(a, b)
		return a.campId < b.campId
	end)

	local curCampId = pg.me.curCampStaticId
	local targetCampId

	if curCampId and curCampId ~= 0 then
		local curCampData = HomeCampData[curCampId]

		if curCampData and curCampData.plateId == self.curPlate then
			targetCampId = curCampId
		end
	end

	if not targetCampId and campList[1] then
		targetCampId = campList[1].campId
	end

	if targetCampId then
		self:selectCamp(targetCampId, true)
	end

	self.campList:SetList(campList)

	if data.backgroundImage then
		self.backgroundImage.url = data.backgroundImage
	end
end

function HomeChangeStationComponent:refreshPlateList()
	local plateList = {}

	for plateId, plateData in pairs(HomeCarPlateData) do
		plateList[#plateList + 1] = {
			plateId = plateId,
			plateName = plateData.name,
			plateIcon = plateData.icon,
			plateCondition = plateData.condition,
			backgroundImage = plateData.backgroundImage
		}
	end

	table.sort(plateList, function(a, b)
		return a.plateId < b.plateId
	end)
	self.listTabPlotUList:SetList(plateList)

	local res, button = self.listTabPlotUList:TryGetChildAt(0)

	if res then
		button:OnClickSimulate()
	end
end

function HomeChangeStationComponent:rendererCampItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local icon = objectReference:GetRefValue("icon")
	local name = objectReference:GetRefValue("name")
	local iconNow = objectReference:GetRefValue("iconNow")
	local campData = HomeCampData[data.campId]

	ClientTextUtils.setText(name, pg.getLocalizationText(campData.name))

	icon.url = campData.image

	button:TryChangePage("Move", index % 4)

	if data.campId == self.campId then
		button.isSelected = true
	else
		button.isSelected = false
	end

	if data.campId == pg.me.curCampStaticId then
		iconNow:SetActive(true)
	else
		iconNow:SetActive(false)
	end

	if ClientUtils.checkHomeCampUnlock(data.campId) then
		button:TryChangePage("Unlock", 1)
		button:TryChangePage("Unlock", 0)
	else
		button:TryChangePage("Unlock", 0)
		button:TryChangePage("Unlock", 1)
	end

	function button.luaClick()
		self:selectCamp(data.campId)
	end
end

function HomeChangeStationComponent:selectCamp(campId, skipListRefresh)
	if ClientUtils.checkHomeCampUnlock(campId) then
		self.btnSpecify.interactable = true
		self.confirmBtn.interactable = true
	else
		self.btnSpecify.interactable = false
		self.confirmBtn.interactable = false
	end

	local objRef = self.confirmBtn:GetComponent("ObjectReference")
	local nameUText = objRef:GetRefValue("txtNameUText")

	if campId == pg.me.curCampStaticId then
		self.confirmBtn.interactable = false

		ClientTextUtils.setText(nameUText, pg.getGameString("CURRENT_CAMP"))
	else
		ClientTextUtils.setText(nameUText, pg.getGameString("HOME_JOIN"))
	end

	self.campId = campId

	if not skipListRefresh then
		self.campList:RefreshList(true)
	end

	self:refreshCampInfo(self.campId)
end

function HomeChangeStationComponent:refreshRewardList(campId)
	local campData = HomeCampData[campId]
	local rewardList = {}

	for i, itemId in pairs(campData.rewardItemList) do
		rewardList[#rewardList + 1] = {
			id = itemId,
			unkownInfoText = pg.getGameString("HOME_CAMP_UNKOWN_REWARD_TIP")
		}
	end

	HomeCampUtils.trySetUnknownDispatchItem(rewardList, true)
	self.rewardList:SetList(rewardList)
	ClientTextUtils.setText(self.txtRewardUSDFText, pg.getFormatText(pg.getGameString("HOMECAMP_SPECIALTY_NEARBY"), pg.getLocalizationText(campData.name)))
end

function HomeChangeStationComponent:rendererRewardItem(button, index, data)
	LuaUIUtils.renderRewardItem(button, data)
end

function HomeChangeStationComponent:refreshCampInfo(campId)
	local campData = HomeCampData[campId]

	ClientTextUtils.setText(self.txtName, pg.getLocalizationText(campData.name))
	ClientTextUtils.setText(self.txtDetails, pg.getLocalizationText(campData.desc))
	self:refreshRewardList(campId)
end

function HomeChangeStationComponent:onSpecifyBtnClick()
	pg.global.ui.homeCampVisit:open({
		isSwitch = true,
		campId = self.campId
	})
end

function HomeChangeStationComponent:confirm()
	pg.me:changeCamp(self.campId, 0, function()
		self.ctrl:close()
	end)
end

function HomeChangeStationComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return HomeChangeStationComponent
