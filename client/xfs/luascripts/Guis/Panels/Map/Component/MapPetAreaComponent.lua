-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\MapPetAreaComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local MapBlockConfigData = require("Data.map_block_config_data")
local WeatherData = require("Data.weather_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MapAreaConfigData = require("Data.map_area_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MapAreaToSmallArea = require("Data.map_area_to_small_area")
local MapSmallAreaIdToIndex = require("Data.map_small_area_id_to_index")
local Utils = require("Common.Utils.Utils")
local MeteorologyData = require("Data.meteorology_data")
local Time = require("Core.Common.Time")
local RedDotConst = require("Const.RedDotConst")
local ClientConst = require("Const.ClientConst")
local MapHelper = require("GameApp.Map.MapHelper")
local MapUtils = require("Guis.Utils.MapUtils")
local ClientUtils = require("Utils.ClientUtils")
local HotkeyConst = require("Const.HotkeyConst")
local MapPetAreaComponent = Class.LightClass("MapPetAreaComponent", UIComponent)

function MapPetAreaComponent:onCtor(info)
	self.lastNotReachTipAreaId = nil
	self.lastNotReachTipTime = 0
end

function MapPetAreaComponent:destroy()
	if self.weatherTaskContainer then
		MapUtils.renderWeatherIcon(nil, self.weatherTaskContainer, nil, true)

		self.weatherTaskContainer = nil
	end
end

function MapPetAreaComponent:RefreshWeatherTime(muteTime)
	local currentTime = LuaUIUtils.timeStampToUtcString(Time.secondCache, UIConst.TargetTimeType.Short)

	if muteTime then
		currentTime = ""
	end

	local weatherText = self.weatherText .. "  " .. currentTime

	ClientTextUtils.setText(self.txtNameUBaseText, weatherText)
end

function MapPetAreaComponent:RefreshWeather()
	if not self.lastSmallAreaId then
		return
	end

	local smallAreaId = self.lastSmallAreaId
	local showRedPoint = false
	local meteorologyId = MapHelper.getAreaMeteorology(smallAreaId)

	if self.weatherTransform then
		MapUtils.renderWeatherIcon(nil, self.weatherTaskContainer, nil, true)

		self.weatherTaskContainer = {}

		MapUtils.renderWeatherIcon(smallAreaId, self.weatherTaskContainer, self.weatherTransform)
	end

	local areaWeatherInfo = MapHelper.getAreaWeatherForecast(smallAreaId)

	if areaWeatherInfo then
		local weatherData, weatherInfoToday, weatherState = self.model:getWeatherData(smallAreaId)
		local firstWeatherInfo = areaWeatherInfo[1]

		if firstWeatherInfo then
			local weatherData = WeatherData[firstWeatherInfo.weatherId]
			local weatherPicture = weatherData.picture
			local weatherName = weatherData.name

			if meteorologyId ~= 0 then
				weatherPicture = MeteorologyData[meteorologyId].picture
				weatherName = MeteorologyData[meteorologyId].name
			end

			self.imgPicUImage.url = weatherPicture

			local curWeatherName = ClientTextUtils.getLocalizationText(weatherName)
			local timeTex = LuaUIUtils.timePeriodToUtcString(weatherInfoToday.weatherInfo.time, UIConst.TargetTimeType.Short)

			ClientTextUtils.setText(self.textWeatherTextPlus, curWeatherName .. " | " .. timeTex)
		end

		if meteorologyId > 0 then
			weatherState = 1

			local weatherPets = {}
			local curWeatherInfo = {}
			local pets = MapBlockConfigData[smallAreaId].aurora
			local isActivityRainbow = false
			local flowerStaticId = LeylineFlowerUtils.getStaticIdByBlockId(nil, smallAreaId)
			local activityRainbowData = flowerStaticId and LeylineFlowerUtils.getActivityRainbowPetData(flowerStaticId)

			if activityRainbowData then
				local activityRainbowPetId = Utils.getPuppetPetPrototypeId(activityRainbowData.specialRainbowPetWorld)

				if activityRainbowPetId ~= 0 then
					pets = {
						activityRainbowPetId
					}
					isActivityRainbow = true
				end
			end

			local mapRainbowPets = MapHelper.getAreaRainbowPetTemplates(smallAreaId)

			if mapRainbowPets and next(mapRainbowPets) then
				pets = {}

				local prototypes = {}

				for templateId in pairs(mapRainbowPets) do
					local prototypeId = Utils.getPuppetPetPrototypeId(templateId)

					if prototypeId ~= 0 and not prototypes[prototypeId] then
						prototypes[prototypeId] = true
						pets[#pets + 1] = prototypeId
					end
				end

				table.sort(pets)

				isActivityRainbow = true
			end

			if pets ~= nil then
				showRedPoint = true

				for k, v in pairs(pets) do
					local petData = {}

					petData.smallAreaId = smallAreaId
					petData.petPrototypeId = v

					if LuaUIUtils.checkPetCatch(smallAreaId, v) then
						petData.state = LuaUIUtils.PetInfoState.Catch
					elseif LuaUIUtils.checkPetFind(smallAreaId, v) then
						petData.state = LuaUIUtils.PetInfoState.Find
					elseif LuaUIUtils.checkFriendCatch(smallAreaId, v) then
						petData.state = LuaUIUtils.PetInfoState.FriendCatch
						petData.friendId = LuaUIUtils.getLatestCatchFriendId(smallAreaId, v)
					else
						petData.state = LuaUIUtils.PetInfoState.None
					end

					table.insert(weatherPets, k, petData)
				end
			end

			curWeatherInfo.pets = weatherPets
			weatherInfoToday.weatherInfo = curWeatherInfo
		end

		self.regionalWeather:TryChangePage("RegionalWeather", weatherState)

		if weatherState == 0 then
			ClientTextUtils.setText(self.textUSDFText, pg.getGameString("PET_APPEAR_TIP_1"))
		elseif weatherState == 1 then
			ClientTextUtils.setText(self.textUSDFText, pg.getGameString("PET_APPEAR_TIP_2"))
		elseif weatherState == 2 then
			ClientTextUtils.setText(self.textUSDFText, pg.getGameString("PET_APPEAR_TIP_3"))
		end

		if weatherState == 1 or weatherState == 2 then
			if weatherState == 1 then
				function self.listPetHeadUList.luaRenderItem(item, index, data)
					LuaUIUtils.renderMapPetList(item, index, data, smallAreaId)
				end

				self.listPetHeadUList:SetList(weatherInfoToday.weatherInfo.pets)
			end

			function self.listWeatherUList.luaRenderItem(item, index, data)
				local itemObjectReference = item:GetComponent("ObjectReference")

				if data.tIndex == 1 then
					local title = itemObjectReference:GetRefValue("textTextPlus")

					ClientTextUtils.setText(title, data.title)
					item:TryChangePage("Status", data.isToday and 1 or 0)
				else
					local time = itemObjectReference:GetRefValue("textTextPlus")
					local showTex = LuaUIUtils.timePeriodToUtcString(data.weatherInfo.time, UIConst.TargetTimeType.Short)

					ClientTextUtils.setText(time, showTex)

					local weatherIcon = itemObjectReference:GetRefValue("imageWeatherUImage")
					local iconUrl = WeatherData[data.weatherInfo.weatherId].icon
					local meteorologyId = MapHelper.getAreaMeteorology(data.smallAreaId)

					if data.index == 1 and meteorologyId > 0 then
						iconUrl = MeteorologyData[meteorologyId].icon
					end

					weatherIcon.url = iconUrl

					local headList = itemObjectReference:GetRefValue("listPetHeadUList")

					function headList.luaRenderItem(button, index, data)
						LuaUIUtils.renderMapPetList(button, index, data, smallAreaId)
					end

					headList:SetList(data.weatherInfo.pets)

					local petHeadRectTransform = itemObjectReference:GetRefValue("petHeadRectTransform")

					petHeadRectTransform.gameObject:SetActiveEx(data.weatherInfo.pets ~= nil and #data.weatherInfo.pets > 0)

					if data.index == 1 then
						local weatherButton = item:GetComponent("UButton")

						weatherButton:TryChangePage("Status", 1)

						local uINodeMapWeather1Animation = itemObjectReference:GetRefValue("uINodeMapWeather1Animation")

						UIUtils.PlayAnimation(uINodeMapWeather1Animation, "VX_Node_Map_Weather1_Swipe")
					end
				end
			end

			self.listWeatherUList:SetList(weatherData)
		end
	end

	self.btnfocusUButton.gameObject:SetActiveEx(true)

	function self.btnfocusUButton.luaClick()
		self.showWeatherTips = not self.showWeatherTips

		if self.showWeatherTips then
			self.labelTipsRectTransform.gameObject:SetActiveEx(self.showWeatherTips)

			local tipsData = {}

			for i = 2, 4 do
				local weatherData = WeatherData[i]
				local data = {}

				data.id = i
				data.icon = weatherData.icon
				data.select = false

				if pg.me.weatherSubscription[smallAreaId] then
					for _, id in pairs(pg.me.weatherSubscription[smallAreaId]) do
						if id == i then
							data.select = true

							break
						end
					end
				end

				table.insert(tipsData, i - 1, data)
			end

			function self.listLabelUList.luaRenderItem(button, index, data)
				local objectReference = button:GetComponent("ObjectReference")
				local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
				local iconUImage = objectReference:GetRefValue("iconUImage")

				ClientTextUtils.setTextWithId(txtNameUSDFText, WeatherData[data.id].name)

				iconUImage.url = data.icon

				button:TryChangePage("Status", data.select and 1 or 0)

				function button.luaClick()
					local visible = not data.select

					button:TryChangePage("Status", visible and 1 or 0)

					data.select = visible

					local selectData = {}

					for _, tData in pairs(tipsData) do
						if tData.select then
							table.insert(selectData, tData.id)
						end
					end

					pg.me:serverMsg("RPC_CS_SubscribeWeather", smallAreaId, selectData)
				end
			end

			self.listLabelUList:SetList(tipsData)
			UIUtils.PlayAnimation(self.labelTipsAnimation, "VX_Node_Map_PetArea_Float_Tips_In", function()
				self.listLabelUList:RefreshList()
			end)
		else
			UIUtils.PlayAnimation(self.labelTipsAnimation, "VX_Node_Map_PetArea_Float_Tips_Out", function()
				self.labelTipsRectTransform.gameObject:SetActiveEx(self.showWeatherTips)
			end)
		end

		self.buttonEmptyUButton.gameObject:SetActiveEx(self.showWeatherTips)
	end

	pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_MAP_WEATHER_ICON, self.buttonIconWeatherUButton, showRedPoint, RedDotConst.RedDotStyle.POINT)
	self.iconWeatherRectTransform.gameObject:SetActiveEx(self.model:hasSpecialPetInArea(smallAreaId))
end

function MapPetAreaComponent:closePanel()
	if self.view then
		self.view.petAreaFloatUComponent:SetActive(false)
		self.ctrl:refreshConsoleBarState()
		self:setAreaHighLight(-1)

		if self.weatherTimer ~= nil then
			self.ctrl:killTimer(self.weatherTimer)
		end
	end

	self.smallAreaCfg = nil
	self.smallAreaId = nil
end

function MapPetAreaComponent:setAreaHighLight(smallAreaId)
	if self.ctrl.mapAreaOverlayComponent then
		self.ctrl.mapAreaOverlayComponent:setSelected(smallAreaId)
	end
end

function MapPetAreaComponent:setPetAreaProgressTipInfo(eventData, openWeather, smallAreaIdParam)
	local smallAreaId = 0

	if smallAreaIdParam then
		smallAreaId = smallAreaIdParam
	elseif eventData then
		local x, y
		local curPlatform = ClientUtils.getAdaptionPlatform()

		if curPlatform == UIConst.PLATFORM.Mobile then
			x, y = self.ctrl:getPointerPos(eventData.position)
		elseif curPlatform == UIConst.PLATFORM.Console then
			x, y = self.ctrl:getPointerPos(eventData.position)
		else
			x, y = self.ctrl:getPointerPos(UnityInput.mousePosition)
		end

		local sceneId = pg.game.map:convertSceneId(self.ctrl.sceneId)
		local allChildrenScenes = MapHelper.getAllChildrenScene(sceneId)
		local newX = x
		local newY = y

		for _, sceneId1 in pairs(allChildrenScenes) do
			local mapOffsetUI = MapHelper.getMapOffsetUI(sceneId1)

			if mapOffsetUI then
				newX = x - mapOffsetUI[1]
				newY = y - mapOffsetUI[2]
			end

			smallAreaId = pg.game.map:inWhichBlock(sceneId1, true, {
				x = newX,
				y = newY
			})

			if smallAreaId then
				break
			end
		end
	else
		smallAreaId = pg.game.map.curBlockId
	end

	if smallAreaId ~= nil and self.smallAreaId == smallAreaId then
		return
	end

	self:closePanel()

	if not smallAreaId then
		return
	end

	if not pg.me:getAreaFirstInData(smallAreaId) then
		local now = Time.realSecondCache or 0
		local isDuplicateTip = self.lastNotReachTipAreaId == smallAreaId and now - (self.lastNotReachTipTime or 0) <= 1

		if not isDuplicateTip then
			pg.global.showBubbleMessageRaw(pg.getGameString("PET_AREA_NOT_REACH"))

			self.lastNotReachTipAreaId = smallAreaId
			self.lastNotReachTipTime = now
		end

		return
	end

	pg.game.audio:triggerEvent("SFX_UI_Event_Map_AreaSelect")

	local smallAreaCfg = MapBlockConfigData[smallAreaId]

	if not smallAreaCfg then
		return
	end

	if not smallAreaCfg.desc then
		return
	end

	local areaCfg = MapAreaConfigData[smallAreaCfg.mapAreaId]

	if not areaCfg then
		return
	end

	self.smallAreaCfg = smallAreaCfg
	self.smallAreaId = smallAreaId

	self.ctrl.mapMarkFilterComponent:closePanel()
	self.view.locationInfo.gameObject:SetActiveEx(false)
	self.view.sortFilterUComponent.gameObject:SetActiveEx(false)

	self.chooseListClick = false

	self.view.fakeCustomMarkUButton.gameObject:SetActiveEx(false)
	self.view.petAreaFloatUComponent:SetActive(true)
	self.ctrl:refreshConsoleBarState()
	self:setAreaHighLight(smallAreaId)

	local objectReference = self.view.petAreaFloatUComponent:GetComponent("ObjectReference")

	self.objectReference = objectReference

	local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	local txtLvUBaseText = objectReference:GetRefValue("txtLvUBaseText")

	self.txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	local bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")

	self.petAreaUComponent = objectReference:GetRefValue("petAreaUComponent")
	self.regionalWeather = objectReference:GetRefValue("regionalWeatherUComponent")
	self.scrollRectWeatherUScrollRect = objectReference:GetRefValue("scrollRectWeatherUScrollRect")
	self.listWeatherUList = self.scrollRectWeatherUScrollRect.content:GetComponent("UList")
	self.listPetHeadUList = objectReference:GetRefValue("listPetHeadUList")
	self.listLabelUList = objectReference:GetRefValue("listLabelUList")
	self.labelTipsRectTransform = objectReference:GetRefValue("labelTipsRectTransform")
	self.showWeatherTips = false

	self.labelTipsRectTransform.gameObject:SetActiveEx(false)

	self.btnfocusUButton = objectReference:GetRefValue("btnfocusUButton")
	self.textWeatherTextPlus = objectReference:GetRefValue("textWeatherTextPlus")
	self.txtNameTextPlus = objectReference:GetRefValue("txtNameTextPlus")
	self.imgPicUImage = objectReference:GetRefValue("imgPicUImage")
	self.labelTipsAnimation = objectReference:GetRefValue("labelTipsAnimation")
	self.uINodeMapPetAreaFloatUComponent = objectReference:GetRefValue("uINodeMapPetAreaFloatUComponent")
	self.buttonEmptyUButton = objectReference:GetRefValue("buttonEmptyUButton")

	self.buttonEmptyUButton.gameObject:SetActiveEx(false)

	self.buttonIconWeatherUButton = objectReference:GetRefValue("buttonIconWeatherUButton")
	self.buttonIconMysticUButton = objectReference:GetRefValue("buttonIconMysticUButton")
	self.iconWeatherRectTransform = objectReference:GetRefValue("iconWeatherRectTransform")
	self.petListUList = objectReference:GetRefValue("petListUList")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.dadgeProgressUComponent = objectReference:GetRefValue("dadgeProgressUComponent")
	self.weatherTransform = objectReference:GetRefValue("weatherTransform")
	self.dadgeListUCentralList = objectReference:GetRefValue("dadgeListUCentralList")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.leftBtnUButton = objectReference:GetRefValue("leftBtnUButton")
	self.rightBtnUButton = objectReference:GetRefValue("rightBtnUButton")

	if self.ctrl and self.ctrl.view and self.ctrl.view.consoleBarTransform then
		self.leftBtnUButton:SetHotkeyConsoleBarMultiPaths("CONSOLE_BAR_CYCLE_BADGE_REWARD", 8, {
			"Raw/GamepadLeftShoulder",
			"Raw/GamepadRightShoulder"
		}, nil, nil, self.ctrl.view.consoleBarTransform)
	end

	self.lastSmallAreaId = smallAreaId
	self.weatherText = pg.getLocalizationText(smallAreaCfg.areaName)

	if pg.game.setting:getShowDebugId() then
		self.weatherText = string.format("%s-%s", pg.getLocalizationText(smallAreaCfg.areaName), tostring(smallAreaId))
	end

	self.weatherTimer = self.ctrl:startTimer(function()
		local _, page = self.uINodeMapPetAreaFloatUComponent:TryGetCurrentPage("Tab")

		self:RefreshWeatherTime(page == 0)
	end, 1, true)

	local _, page = self.uINodeMapPetAreaFloatUComponent:TryGetCurrentPage("Tab")

	self:RefreshWeatherTime(page == 0)
	self:RefreshWeather()

	function self.uINodeMapPetAreaFloatUComponent.luaTryChangePage(name, pageIdx)
		if name == "Tab" and pageIdx == 0 then
			self:RefreshWeatherTime(true)
		elseif name == "Tab" and pageIdx == 1 then
			self:RefreshWeatherTime()
		end
	end

	function btnCloseUButton.luaClick()
		self:closePanel()
	end

	function bgCloseUButton.luaClick()
		self:closePanel()
	end

	function self.buttonIconWeatherUButton.luaClick()
		pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_MAP_WEATHER_ICON, self.buttonIconWeatherUButton, false, RedDotConst.RedDotStyle.POINT)
		pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.LastSelectMapPetTab, 1)
	end

	function self.buttonIconMysticUButton.luaClick()
		self.showWeatherTips = false

		self.labelTipsRectTransform.gameObject:SetActiveEx(self.showWeatherTips)
		pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.LastSelectMapPetTab, 0)
	end

	function self.buttonEmptyUButton.luaClick()
		if self.showWeatherTips then
			self.showWeatherTips = false

			UIUtils.PlayAnimation(self.labelTipsAnimation, "VX_Node_Map_PetArea_Float_Tips_Out", function()
				self.labelTipsRectTransform.gameObject:SetActiveEx(self.showWeatherTips)
			end)
			self.buttonEmptyUButton.gameObject:SetActiveEx(false)
		end
	end

	function self.petListUList.luaRenderItem(button, index, data)
		local list = button:GetChild("List"):GetComponent("UList")

		self.petLists[index + 1] = list

		function list.luaRenderItem(button1, index1, data1)
			LuaUIUtils.renderMapPetList(button1, index1, data1, smallAreaId)
		end

		local index_ = index + 1

		function list.luaClick()
			for i, list_ in ipairs(self.petLists) do
				if i ~= index_ then
					list_:DeselectAll()
				end
			end
		end

		list:SetList(data.petInfo)
	end

	local minLv, maxLv = MapHelper.getAreaRecommandLevel(smallAreaId)

	ClientTextUtils.setText(txtLvUBaseText, ClientTextUtils.formatShortLevelRange(minLv, maxLv))
	ClientTextUtils.setText(self.txtNumUSDFText, self:getSmallAreaPetProgressStr(smallAreaId))
	MapUtils.renderDadgeProgress(self.dadgeProgressUComponent.transform:GetComponent("ObjectReference"), smallAreaId, self.petAreaUComponent)
	MapUtils.renderWeatherIcon(nil, self.weatherTaskContainer, nil, true)

	self.weatherTaskContainer = {}

	MapUtils.renderWeatherIcon(smallAreaId, self.weatherTaskContainer, self.weatherTransform)

	local redDot1, redDot2, redDot3 = pg.game.map:getPetAreaRewardStateById(smallAreaId)

	pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_MAP_DISTRIBUTE_TAB_ICON, self.buttonIconMysticUButton, redDot1 or redDot2 or redDot3, RedDotConst.RedDotStyle.REWARD)

	self.petLists = {}

	local curPlatform = ClientUtils.getAdaptionPlatform()

	if curPlatform == UIConst.PLATFORM.Mobile then
		self.petListUList:SetList(LuaUIUtils.getSmallAreaPetData(smallAreaId, {
			4,
			5,
			4,
			5,
			4,
			5,
			4,
			5,
			4,
			5,
			4,
			5
		}))
	else
		self.petListUList:SetList(LuaUIUtils.getSmallAreaPetData(smallAreaId, {
			3,
			4,
			3,
			4,
			3,
			4,
			3,
			4,
			3,
			4,
			3,
			4
		}))
	end

	MapUtils.renderBadgeList(self.dadgeListUCentralList, smallAreaId)

	local stages, _, curFocusStage = MapUtils.getBadgeStageStatus(smallAreaId)

	self.badgeStages = stages
	self.joystickCurIndex = curFocusStage and curFocusStage - 1 or 0

	function self.leftBtnUButton.luaClick()
		if not self.dadgeListUCentralList or not self.dadgeListUCentralList.gameObject.activeSelf then
			return true
		end

		if self.joystickCurIndex <= 0 then
			return true
		end

		self.joystickCurIndex = self.joystickCurIndex - 1

		MapUtils.renderBadgeList(self.dadgeListUCentralList, self.smallAreaId, self.joystickCurIndex)
	end

	function self.rightBtnUButton.luaClick()
		if not self.dadgeListUCentralList or not self.dadgeListUCentralList.gameObject.activeSelf then
			return true
		end

		if not self.badgeStages or self.joystickCurIndex >= #self.badgeStages - 1 then
			return true
		end

		self.joystickCurIndex = self.joystickCurIndex + 1

		MapUtils.renderBadgeList(self.dadgeListUCentralList, self.smallAreaId, self.joystickCurIndex)
	end

	self:refreshCollectionView()
end

function MapPetAreaComponent:refreshCollectionView()
	if not self.smallAreaId or not self.dadgeListUCentralList then
		return
	end

	MapUtils.renderBadgeList(self.dadgeListUCentralList, self.smallAreaId)

	local redDot1, redDot2, redDot3 = pg.game.map:getPetAreaRewardStateById(self.smallAreaId)

	pg.global.setRedDot(RedDotConst.RedDotPath.FUNC_MENU_MAP_DISTRIBUTE_TAB_ICON, self.buttonIconMysticUButton, redDot1 or redDot2 or redDot3, RedDotConst.RedDotStyle.REWARD)
end

function MapPetAreaComponent:getAreaPetProgress(areaId)
	local smallAreas = MapAreaToSmallArea[areaId]

	if not smallAreas then
		return
	end

	local catchCount = 0
	local totalCount = 0

	for _, smallAreaId in ipairs(smallAreas) do
		if MapSmallAreaIdToIndex[smallAreaId] then
			local subCatchCount, subTotalCount = Utils.getBlockCatchedCount(pg.me, smallAreaId)

			catchCount = catchCount + subCatchCount
			totalCount = totalCount + subTotalCount
		end
	end

	return catchCount / totalCount
end

function MapPetAreaComponent:getAreaPetProgressStr(areaId)
	local progress = self:getAreaPetProgress(areaId)

	if progress > 0 then
		progress = math.max(progress, 0.01)
	end

	return string.format("%d%%", progress * 100)
end

function MapPetAreaComponent:getSmallAreaPetProgress(smallAreaId)
	local rate = Utils.getBlockCatchedRate(pg.me, smallAreaId)

	return rate or 0
end

function MapPetAreaComponent:getSmallAreaPetProgressStr(smallAreaId)
	return string.format("%d%%", self:getSmallAreaPetProgress(smallAreaId) * 100)
end

return MapPetAreaComponent
