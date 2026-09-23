-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\MapLeftTopTipsComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local PuppetData = require("Data.puppet_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local MapUtils = require("Guis.Utils.MapUtils")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local MapHelper = require("GameApp.Map.MapHelper")
local PetData = require("Data.pet_data")
local MapMarkResourceData = require("Data.map_mark_resource_data")
local MapLeftTopTipsComponent = Class.LightClass("MapLeftTopTipsComponent", UIComponent)
local FuncType = {
	EcoTrace = 2,
	LeylineFlowerPlenty = 1,
	HomeDelegationFinish = 3
}
local FuncRenderConfig = {
	[FuncType.LeylineFlowerPlenty] = {
		showCountDown = true,
		state = 0
	},
	[FuncType.EcoTrace] = {
		showCountDown = true,
		state = 0
	},
	[FuncType.HomeDelegationFinish] = {
		showCountDown = false,
		state = 1
	}
}
local IconRefKeyByState = {
	[0] = "iconPetUImage",
	"iconPoiUImage"
}

function MapLeftTopTipsComponent:initView()
	function self.view.petAppearListUList.luaRenderItem(button, _, data)
		self:renderFuncItem(button, data)
	end

	self:refreshFuncInfoList()
end

function MapLeftTopTipsComponent:getAllFuncInfos()
	local infos = {}

	self:addLeylineFlowerPlentyInfos(infos)
	self:addEcoTraceInfo(infos)
	self:addHomeDelegationFinishInfo(infos)
	self:sortFuncInfos(infos)

	return infos
end

function MapLeftTopTipsComponent:refreshFuncInfoList()
	local infos = self:getAllFuncInfos()

	LuaUIUtils.setUIVisible(self.view.petAppearListUList, #infos > 0)
	self.view.petAppearListUList:SetList(infos)
end

function MapLeftTopTipsComponent:getMapPoiIconUrl(markId)
	local markInfo = self.ctrl:getMarkInfo(markId)

	if not markInfo then
		return
	end

	if not string.isNilOrEmpty(markInfo.replaceIcon) then
		return markInfo.replaceIcon
	end

	local resourceConfig = MapMarkResourceData[markInfo.markConfigId]
	local sceneResourceConfig = resourceConfig and (resourceConfig[self.ctrl.sceneId] or resourceConfig[0])

	return sceneResourceConfig and sceneResourceConfig.icon
end

function MapLeftTopTipsComponent:sortFuncInfos(infos)
	table.sort(infos, function(a, b)
		local aEndTs = a.endTs or math.huge
		local bEndTs = b.endTs or math.huge

		if aEndTs == bEndTs then
			return a.funcType < b.funcType
		end

		return aEndTs < bEndTs
	end)
end

function MapLeftTopTipsComponent:addEcoTraceInfo(infos)
	local activityData = ClientActivityUtils.getEcoTraceActivityData()
	local ecoTraceSearchMarkId = activityData and activityData.ecoTraceSearchMarkId or 0

	if ecoTraceSearchMarkId == 0 then
		return
	end

	local petId = ClientActivityUtils.getEcoTracePetId()
	local petData = PetData[petId]

	if not petData then
		return
	end

	local iconName = petData.iconName

	infos[#infos + 1] = {
		funcType = FuncType.EcoTrace,
		iconUrl = LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON),
		content = pg.getFormatText(pg.getGameString("ECOLOGICAL_SEARCH_TIME_TIP"), pg.getLocalizationText(petData.name)),
		endTs = activityData.ecoTraceSearchPetRecycleTm or 0,
		markId = ecoTraceSearchMarkId
	}
end

function MapLeftTopTipsComponent:addLeylineFlowerPlentyInfos(infos)
	local curScenePlentyInfos = pg.me:getSpaceOwnerSceneLeylineFlowerInfoMap() or pg.me.leylineFlowerInfoMap:getRawTable()

	if not curScenePlentyInfos then
		return
	end

	for markId, flowerInfo in pairs(curScenePlentyInfos) do
		if flowerInfo.flowerState == LeylineFlowerConst.FLOWER_STATE.Blooming then
			local createId = pg.me:getCurFlowerCreateId(markId)
			local plentyInfo = MapHelper.getLeylineFlowerPlentyInfo(markId, createId)

			if plentyInfo then
				local puppetData = PuppetData[plentyInfo.puppetId1]
				local iconName = puppetData and puppetData.iconName or nil

				infos[#infos + 1] = {
					funcType = FuncType.LeylineFlowerPlenty,
					iconUrl = LuaUIUtils.getPetIcon(iconName, LuaUIUtils.PET_ICON),
					content = pg.getLocalizationText(plentyInfo.familyName),
					endTs = pg.me:getCurFlowerEndTs(markId) or Time.secondCache,
					markId = markId
				}
			end
		end
	end
end

function MapLeftTopTipsComponent:addHomeDelegationFinishInfo(infos)
	local dispatchInfo = pg.me and pg.me.campDispatchInfo
	local campId = dispatchInfo and dispatchInfo.campId or 0

	if not dispatchInfo or campId == 0 or not pg.me:isCampDispatchFinished() then
		return
	end

	local iconUrl = self:getMapPoiIconUrl(campId)

	if string.isNilOrEmpty(iconUrl) then
		return
	end

	infos[#infos + 1] = {
		funcType = FuncType.HomeDelegationFinish,
		iconUrl = iconUrl,
		content = pg.getGameString("HOME_CAMP_DISPATCH_FINISH_MAP_NOTICE"),
		markId = campId
	}
end

function MapLeftTopTipsComponent:renderFuncItem(button, data)
	local renderConfig = FuncRenderConfig[data.funcType]

	if not renderConfig then
		return
	end

	button:TryChangePage("State", renderConfig.state)
	button:TryChangePage("CountDown", renderConfig.showCountDown and 1 or 0)

	button.luaClick = nil
	button.name = data.markId or data.funcType

	local objectReference = button:GetComponent("ObjectReference")
	local iconRefKey = IconRefKeyByState[renderConfig.state]
	local iconUImage = objectReference:GetRefValue(iconRefKey)
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

	iconUImage.url = data.iconUrl

	ClientTextUtils.setText(txtTitleUSDFText, data.content)

	if renderConfig.showCountDown then
		local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")

		LuaUIUtils.setCountDownTime(countDownUCountDown, data.endTs, UIConst.TimeType.Short, nil, true)
	end

	self:bindMapMarkClick(button, data.markId)
end

function MapLeftTopTipsComponent:bindMapMarkClick(button, markId)
	function button.luaClick()
		local ctrl = self.ctrl
		local mark = ctrl.markCaches and ctrl.markCaches[markId]
		local markInfo = ctrl:getMarkInfo(markId)

		if not markInfo or not markInfo.markType then
			return
		end

		local markName = mark and mark.markName or string.format("mark_%s_%s", markInfo.markType, markId)

		ctrl:focusMark({
			markName,
			nil,
			true
		})
	end
end

function MapLeftTopTipsComponent:refreshLeylineFlowerMark(flowerId)
	if not self.ctrl.markCaches then
		return
	end

	local markInst = self.ctrl.markCaches[flowerId]

	if not markInst then
		return
	end

	local resObj = markInst.resObj

	if not resObj then
		return
	end

	local flowerState = pg.me:getCurFlowerState(flowerId)
	local imgPath = MapUtils.getLeylineFlowerMarkIcon(markInst.markConfigId, self.ctrl.sceneId, markInst.markStatus, flowerState)
	local flowerInfo = pg.me:getCurFlowerInfo(flowerId)
	local createId = pg.me:getCurFlowerCreateId(flowerId)
	local plentyInfo = MapHelper.getLeylineFlowerPlentyInfo(flowerId, createId)
	local radius = pg.game.map:calRadius(self.ctrl.sceneId, plentyInfo and plentyInfo.radius or 0)
	local showCircle = pg.me:shouldShowPlentyCircle(flowerId)
	local qualityPage

	if showCircle then
		qualityPage = (flowerInfo.bloomQuality or 0) - 1
	end

	MapUtils.renderLeylineFlowerMark(resObj, imgPath, showCircle, qualityPage, radius, self.ctrl.currentZoom)
	pg.game.map:storeExtraSharedInfoToMarkId(flowerId, "imgPath", imgPath)
	pg.game.map:storeExtraSharedInfoToMarkId(flowerId, "locationImgPath", imgPath)

	if self.ctrl.markBubbleComponent then
		self.ctrl.markBubbleComponent:refreshLeylineFlowerMark(flowerId, imgPath)
	end
end

function MapLeftTopTipsComponent:onFlowerStateChanged(info)
	local flowerId = info and info.leylineFlowerId

	if not flowerId then
		return
	end

	self:refreshLeylineFlowerMark(flowerId)
	self:refreshFuncInfoList()
end

function MapLeftTopTipsComponent:onPlentyCircleChanged(info)
	local flowerId = info and info.leylineFlowerId

	if not flowerId then
		return
	end

	self:refreshLeylineFlowerMark(flowerId)
end

function MapLeftTopTipsComponent:onHomeCampDispatchStateChanged()
	self:refreshFuncInfoList()
end

return MapLeftTopTipsComponent
