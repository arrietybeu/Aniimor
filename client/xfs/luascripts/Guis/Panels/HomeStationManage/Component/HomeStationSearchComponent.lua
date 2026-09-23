-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeStationManage\\Component\\HomeStationSearchComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeStationSearchComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local UIUtils = CS.FunPlus.WorldX.Utils.UIUtils
local lume = require("Core.Common.lume")
local HomeCampData = require("Data.home_camp_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local HomeCampConst = require("Common.Const.HomeCampConst")
local GlobalData = require("Core.Client.GlobalData")
local TimerManager = require("Core.Timer.TimerManager")
local HomeStationSearchComponent = Class.LightClass("HomeStationSearchComponent", UIComponent)
local TabType = {
	All = 1,
	Friend = 0
}
local DefaultCampNum = 20

function HomeStationSearchComponent:onCtor(info)
	self.choosePage = TabType.Friend
	self.searchText = ""
	self.friendCampListData = {}
	self.allCampListData = {}
	self.reportMark = true
end

function HomeStationSearchComponent:findObjects()
	return
end

function HomeStationSearchComponent:initView()
	self.uWidget:LoadDefaultUrlManually(function()
		self:onContentLoaded()
		self:addListener()
		self:refreshPageInfo()
	end)
end

function HomeStationSearchComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.listStationUList = objectReference:GetRefValue("listStationUList")
	self.btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
	self.btnRefreshUButton = objectReference:GetRefValue("btnRefreshUButton")
	self.inputFieldUTMPInputField = objectReference:GetRefValue("inputFieldUTMPInputField")
	self.listAllCampUList = objectReference:GetRefValue("listAllCampUList")
	self.emptyUWidget = objectReference:GetRefValue("emptyUWidget")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
	self.btnCreateUButton = objectReference:GetRefValue("btnCreateUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnPasteUButton = objectReference:GetRefValue("btnPasteUButton")
end

function HomeStationSearchComponent:addListener()
	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("HOMECAR_CREATE_PRIVATE_STATION"))
	ClientTextUtils.setText(self.txtEmptyUSDFText, pg.getGameString("HOMECAR_STATION_EMPTY"))

	function self.btnCreateUButton.luaClick()
		pg.me:teleportToCreatePrivateCampPosition(function()
			if self.ctrl then
				self.ctrl:close()
			end
		end)
	end

	function self.btnSearchUButton.luaClick()
		self.searchText = self.inputFieldUTMPInputField.text or ""

		self:refreshCampList()
	end

	function self.btnPasteUButton.luaClick()
		local clipboardText = UIUtils.ClipboardReader()

		if not string.isNilOrEmpty(clipboardText) then
			self.inputFieldUTMPInputField.text = clipboardText
		end
	end

	function self.btnRefreshUButton.luaClick()
		local inputText = self.inputFieldUTMPInputField.text

		if string.isNilOrEmpty(inputText) then
			self.searchText = ""
		else
			self.searchText = inputText
		end

		self:refreshCampList()
	end

	function self.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")

		ClientTextUtils.setText(textUBaseText, pg.getGameString(data.name))

		if data.icon then
			iconUImage.url = data.icon
		end

		function button.luaClick()
			if data.clickFunc then
				self[data.clickFunc](self)
			end
		end
	end

	function self.listStationUList.luaRenderItem(button, index, data)
		self:rendererFriendCampInfo(button, index, data)
	end

	function self.listAllCampUList.luaRenderItem(button, index, data)
		self:rendererAllCampInfo(button, index, data)
	end

	self:setupGamepadNav()
end

function HomeStationSearchComponent:setupGamepadNav()
	local input = self.inputFieldUTMPInputField

	if not input then
		return
	end

	logger:info("[StationSearchNav] setupGamepadNav: relying on prefab isVirtual=true")

	function input.luaOnSelect()
		local navMgr = CS.XGUI.Navigation.NavManager.Instance
		local r = navMgr and navMgr:FocusItem(input)

		logger:info(string.format("[StationSearchNav] luaOnSelect: FocusItem=%s", tostring(r)))
	end

	function input.luaOnDeSelect()
		logger:info("[StationSearchNav] luaOnDeSelect")
		self:scheduleFocusListFirstItem()
	end

	if self.ctrl and self.ctrl.bindHotKeyPerform then
		self.ctrl:bindHotKeyPerform("Raw/GamepadRightStickPress", function()
			local editing = input.allowInput

			logger:info(string.format("[StationSearchNav] RS pressed, allowInput=%s", tostring(editing)))

			if editing then
				input:DeSelect()
				self:scheduleFocusListFirstItem()

				return true
			end

			return false
		end, nil, "HomeStationSearch_InputCancelRS")
		logger:info("[StationSearchNav] RS hotkey bound")
	end
end

function HomeStationSearchComponent:scheduleFocusListFirstItem()
	if self._focusListTimer then
		TimerManager.removeTimer(self._focusListTimer)

		self._focusListTimer = nil
	end

	if not pg.game.input:isUsingGamepad() then
		return
	end

	self._focusListTimer = TimerManager.addNextFrameCb(function()
		self._focusListTimer = nil

		self:focusListFirstItem()
	end)
end

function HomeStationSearchComponent:focusListFirstItem()
	if not self.listAllCampUList then
		logger:info("[StationSearchNav] focusListFirstItem: no list")

		return
	end

	if self.choosePage ~= TabType.All then
		logger:info(string.format("[StationSearchNav] focusListFirstItem: skip choosePage=%s", tostring(self.choosePage)))

		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return
	end

	local ok, btn = self.listAllCampUList:TryGetChildAt(0)

	logger:info(string.format("[StationSearchNav] focusListFirstItem: TryGetChildAt(0)=%s, btn=%s", tostring(ok), tostring(btn)))

	if ok and btn then
		local r = navMgr:FocusItem(btn)

		logger:info(string.format("[StationSearchNav] focusListFirstItem: FocusItem=%s", tostring(r)))

		if not r then
			navMgr:TryFocusFirstAvailable()
		end
	else
		navMgr:TryFocusFirstAvailable()
	end
end

function HomeStationSearchComponent:isSelfCamp(campId, spaceKey)
	if not campId or not spaceKey then
		return false
	end

	local selfCampId = pg.me.curCampStaticId

	if not selfCampId or selfCampId == 0 or campId ~= selfCampId then
		return false
	end

	local selfKey = pg.me:getSelfHomeCampKey()

	return selfKey == spaceKey
end

function HomeStationSearchComponent:getCampDisplayText(campId, displayCode)
	local campCfg = campId and HomeCampData[campId]
	local campName = campCfg and pg.getLocalizationText(campCfg.name)

	return pg.getFormatText("{0}-{1}", campName, displayCode)
end

function HomeStationSearchComponent:onDestroy()
	if self._focusListTimer then
		TimerManager.removeTimer(self._focusListTimer)

		self._focusListTimer = nil
	end

	if self.inputFieldUTMPInputField then
		self.inputFieldUTMPInputField.luaOnSelect = nil
		self.inputFieldUTMPInputField.luaOnDeSelect = nil
	end

	UIComponent.onDestroy(self)
end

function HomeStationSearchComponent:refreshPageInfo()
	if not self.uWidget:CheckURLLoaded() then
		return
	end

	self.isPlayerManager = HomeLandUtils.isHomeCampManager() or false

	local tabList = self:getTabList()

	self.listTabUList:SetList(tabList)

	local selectIndex = self.choosePage or 0
	local res, button = self.listTabUList:TryGetChildAt(selectIndex)

	if res then
		button:OnClickSimulate()
	end
end

function HomeStationSearchComponent:getTabList()
	local tabList = {}

	table.insert(tabList, {
		icon = "$UI_Img_Home_PostStation_TabIcon_FriendStations.png",
		name = "HOMECAR_FRIEND_STATION",
		clickFunc = "clickFriendStation"
	})
	table.insert(tabList, {
		icon = "$UI_Img_Home_PostStation_TabIcon_AllStations.png",
		name = "HOMECAR_ALL_STATION",
		clickFunc = "clickAllStation"
	})

	return tabList
end

function HomeStationSearchComponent:clickFriendStation()
	self.reportMark = true
	self.choosePage = TabType.Friend

	self.uWidget.content:TryChangePage("Type", 0)
	self:refreshFriendCamps()
end

function HomeStationSearchComponent:clickAllStation()
	self.reportMark = true
	self.choosePage = TabType.All

	self.uWidget.content:TryChangePage("Type", 1)

	self.searchText = ""

	if self.inputFieldUTMPInputField then
		self.inputFieldUTMPInputField.text = ""
	end

	self:refreshCampList()
end

function HomeStationSearchComponent:checkAndReportCampListLog(type, listData)
	if not self.reportMark then
		return
	end

	self.reportMark = false

	local camp_list = {}

	for index, data in ipairs(listData) do
		local loginNum = lume.count(data.loginUids or {})

		camp_list[#camp_list + 1] = {
			camp_unique_id = data.displayCode,
			order = index,
			member_num = loginNum
		}
	end

	GlobalData.BILogger:customeLog("search_camp", {
		sub_tab = type,
		camp_list = camp_list
	})
end

function HomeStationSearchComponent:refreshFriendCamps()
	local friendList = pg.game.chat:getFriendList() or {}
	local friendIds = {}

	for _, friendData in pairs(friendList) do
		if friendData.playerId then
			table.insert(friendIds, friendData.playerId)
		end
	end

	if #friendIds == 0 then
		self:setFriendCampInfo({}, {})

		return
	end

	pg.me:queryFriendCampInfo(friendIds, function(friendData, friendCampData)
		if not self.view then
			return
		end

		self:setFriendCampInfo(friendData, friendCampData, true)
	end)
end

function HomeStationSearchComponent:setFriendCampInfo(friendData, friendCampData, checkReport)
	self.friendData = friendData
	self.friendCampData = friendCampData

	local list = {}

	for uid, friendInfo in pairs(friendData) do
		local campKey = friendInfo.homeCampKey
		local campData = campKey and friendCampData[campKey] or nil

		if campData then
			local _, _, sceneId, lineUid = Utils.parseSpaceInstanceServiceKey(campKey)
			local campStaticId = HomeLandUtils.getHomeCampStaticId(sceneId)

			table.insert(list, {
				playerInfo = pg.game.chat:getPlayerInfo(uid),
				friendShipLevel = pg.game.chat:getFriendship(uid),
				intimacy = pg.game.chat:getFriendIntimacy(uid),
				uid = uid,
				loginUids = campData.loginUids,
				lineUid = campData.lineUid,
				homeCampKey = campKey,
				campStaticId = campStaticId,
				displayCode = campData.displayCode,
				ownerUid = campData.ownerUid,
				isPrivate = campData.isPrivate,
				permissions = campData.permissions
			})
		end
	end

	table.sort(list, function(a, b)
		return (a.intimacy or -1) > (b.intimacy or -1)
	end)

	self.friendCampListData = list

	self.listStationUList:SetList(list)
	self:refreshEmptyState()

	if checkReport then
		self:checkAndReportCampListLog("friend", list)
	end
end

function HomeStationSearchComponent:rendererFriendCampInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local playerHeadUWidget = objectReference:GetRefValue("playerHeadUWidget")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")
	local iconIntimacyUImage = objectReference:GetRefValue("iconIntimacyUImage")
	local txtPositonIDUSDFText = objectReference:GetRefValue("txtPositonIDUSDFText")
	local txtMemberUSDFText = objectReference:GetRefValue("txtMemberUSDFText")
	local btnJoinUButton = objectReference:GetRefValue("btnJoinUButton")
	local btnVisitUButton = objectReference:GetRefValue("btnVisitUButton")
	local txtVisitUButton = objectReference:GetRefValue("txtVisitUButton")
	local txtUnlockUSDFText = objectReference:GetRefValue("txtUnlockUSDFText")
	local iconTypeUImage = objectReference:GetRefValue("iconTypeUImage")

	ClientTextUtils.setText(txtUnlockUSDFText, pg.getGameString("HOMELAND_ITEM_LOCKED"))

	local playerInfo = data.playerInfo or {}
	local playerName = playerInfo.playerName or ""
	local _h = HomeStationSearchComponent._platformHooks

	playerName = _h and _h.renderFriendStationPlayerName and _h.renderFriendStationPlayerName(self, button, index, data, playerInfo, playerName) or playerName

	ClientTextUtils.setText(txtNameUSDFText, playerName)
	ClientTextUtils.setText(textLvUSDFText, playerInfo.level)

	if playerHeadUWidget then
		LuaUIUtils.renderPlayerAvatarImages(playerHeadUWidget, {
			avatarIconId = playerInfo.headIcon,
			avatarFrameIconId = playerInfo.headFrame
		})
	end

	local presetData = pg.game.avatar:getAvatarPresetData(playerInfo.avatarPresetKey) or {}
	local templateId = presetData.templateId or 0

	if templateId == 3 then
		button:TryChangePage("Gender", 1)
	elseif templateId == 4 then
		button:TryChangePage("Gender", 0)
	else
		button:TryChangePage("Gender", 2)
	end

	local friendShipLevel = data.friendShipLevel
	local hasFriendship = friendShipLevel and FriendshipLevelData[friendShipLevel]

	if iconIntimacyUImage then
		iconIntimacyUImage:SetActive(hasFriendship ~= nil and hasFriendship ~= false)

		if hasFriendship then
			iconIntimacyUImage.url = FriendshipLevelData[friendShipLevel].levelIcon
		end
	end

	local campId = data.campStaticId
	local isUnlock = campId and ClientUtils.checkHomeCampUnlock(campId)

	button:TryChangePage("Unlock", isUnlock and 0 or 1)
	ClientTextUtils.setText(txtPositonIDUSDFText, self:getCampDisplayText(campId, data.displayCode))

	local maxCampNum = HomeLandUtils.getHomeCampMaxLoginCount(campId)
	local loginNum = lume.count(data.loginUids or {})
	local isFull = maxCampNum <= loginNum

	button:TryChangePage("StationType", data.isPrivate and 0 or 1)

	local stationTypeName = pg.getGameString("HOMECAR_PUBLIC_STATION")

	if data.isPrivate then
		stationTypeName = pg.getGameString("HOMECAR_PRIVATE_STATION")
	end

	if isFull then
		ClientTextUtils.setText(txtMemberUSDFText, stationTypeName .. pg.getFormatText("(<style=Debuff>{0}</style>/{1})", loginNum, maxCampNum))
	else
		ClientTextUtils.setText(txtMemberUSDFText, stationTypeName .. pg.getFormatText("({0}/{1})", loginNum, maxCampNum))
	end

	local isSelf = self:isSelfCamp(campId, data.homeCampKey)
	local notAllowJoin = data.isPrivate and bit.band(data.permissions or 0, HomeCampConst.PERM_ALLOW_RANDOM_JOIN) == 0
	local canJoin = not isFull and not isSelf and not notAllowJoin and campId ~= nil and data.lineUid ~= nil

	btnJoinUButton:SetActive(false)

	btnJoinUButton.interactable = false
	btnJoinUButton.luaClick = nil

	ClientTextUtils.setText(txtVisitUButton, pg.getGameString(canJoin and "HOME_JOIN" or "HOME_VISIT"))

	btnVisitUButton.interactable = canJoin or data.homeCampKey ~= nil

	function btnVisitUButton.luaClick()
		if canJoin then
			if self.isPlayerManager then
				pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_MANAGER_JOIN)
			else
				self:onJoinCamp(campId, data.lineUid)
			end
		elseif data.homeCampKey then
			self:onVisitCamp(data.homeCampKey)
		end
	end
end

function HomeStationSearchComponent:refreshCampList()
	if self.choosePage ~= TabType.All then
		return
	end

	local lineList = {}

	if string.isNilOrEmpty(self.searchText) then
		pg.me:getCampListN(DefaultCampNum, 0, "all", function(result, response)
			if not self.view then
				return
			end

			if result.status and response and response.res then
				for spaceKey, lineInfo in pairs(response.res) do
					if lineInfo then
						lineInfo.campStaticId = lineInfo.staticId

						table.insert(lineList, lineInfo)
					end
				end
			end

			self:setAllCampList(lineList, true)
		end)
	else
		pg.me:findCampByCode(self.searchText, function(result, response)
			if not self.view then
				return
			end

			if result.status and response then
				if response.summary then
					local lineInfo = response.summary

					lineInfo.campStaticId = lineInfo.staticId

					table.insert(lineList, lineInfo)
				end

				self:setAllCampList(lineList)
			end
		end)
	end
end

function HomeStationSearchComponent:setAllCampList(list, checkReport)
	table.sort(list, function(a, b)
		local aNum = lume.count(a.loginUids or {})
		local bNum = lume.count(b.loginUids or {})

		if aNum ~= bNum then
			return bNum < aNum
		end

		return (a.lineUid or 0) < (b.lineUid or 0)
	end)

	self.allCampListData = list

	self.listAllCampUList:SetList(list)
	self:refreshEmptyState()

	if checkReport then
		self:checkAndReportCampListLog("all", list)
	end

	local input = self.inputFieldUTMPInputField

	if not input or not input.allowInput then
		self:scheduleFocusListFirstItem()
	end
end

function HomeStationSearchComponent:rendererAllCampInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtPositonIDUSDFText = objectReference:GetRefValue("txtPositonIDUSDFText")
	local txtMemberUSDFText = objectReference:GetRefValue("txtMemberUSDFText")
	local btnJoinUButton = objectReference:GetRefValue("btnJoinUButton")
	local btnVisitUButton = objectReference:GetRefValue("btnVisitUButton")
	local txtJoinUButton = objectReference:GetRefValue("txtJoinUButton")
	local txtVisitUButton = objectReference:GetRefValue("txtVisitUButton")
	local iconTypeUImage = objectReference:GetRefValue("iconTypeUImage")
	local txtUnlockUSDFText = objectReference:GetRefValue("txtUnlockUSDFText")

	ClientTextUtils.setText(txtVisitUButton, pg.getGameString("HOME_VISIT"))
	ClientTextUtils.setText(txtUnlockUSDFText, pg.getGameString("HOMELAND_ITEM_LOCKED"))

	local campId = data.campStaticId
	local isUnlock = campId and ClientUtils.checkHomeCampUnlock(campId)

	button:TryChangePage("Unlock", isUnlock and 0 or 1)
	ClientTextUtils.setText(txtPositonIDUSDFText, self:getCampDisplayText(campId, data.displayCode))

	local maxCampNum = HomeLandUtils.getHomeCampMaxLoginCount(campId)
	local loginNum = lume.count(data.loginUids or {})
	local isFull = maxCampNum <= loginNum

	button:TryChangePage("StationType", data.isPrivate and 0 or 1)

	local stationTypeName = pg.getGameString("HOMECAR_PUBLIC_STATION")

	if data.isPrivate then
		stationTypeName = pg.getGameString("HOMECAR_PRIVATE_STATION")
	end

	if isFull then
		ClientTextUtils.setText(txtMemberUSDFText, stationTypeName .. pg.getFormatText("(<style=Debuff>{0}</style>/{1})", loginNum, maxCampNum))
	else
		ClientTextUtils.setText(txtMemberUSDFText, stationTypeName .. pg.getFormatText("({0}/{1})", loginNum, maxCampNum))
	end

	local isSelf = self:isSelfCamp(campId, data.spaceKey)
	local notAllowJoin = data.isPrivate and bit.band(data.permissions or 0, HomeCampConst.PERM_ALLOW_RANDOM_JOIN) == 0

	btnJoinUButton.interactable = not isFull and not isSelf and campId ~= nil and data.lineUid ~= nil and not notAllowJoin

	function btnJoinUButton.luaClick()
		if isFull or isSelf or not campId or not data.lineUid then
			return
		end

		if self.isPlayerManager then
			pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_MANAGER_JOIN)
		else
			self:onJoinCamp(campId, data.lineUid)
		end
	end

	local joinText = pg.getGameString("HOME_JOIN")

	if isSelf then
		joinText = pg.getGameString("HOMECAR_MEMBER_JOINED")
	elseif isFull then
		joinText = pg.getGameString("HOMECAR_MEMBER_FULL")
	elseif notAllowJoin then
		joinText = pg.getGameString("HOMECAR_ONLY_INVITE")
	end

	ClientTextUtils.setText(txtJoinUButton, joinText)

	btnVisitUButton.interactable = data.spaceKey ~= nil

	function btnVisitUButton.luaClick()
		if not data.spaceKey then
			return
		end

		self:onVisitCamp(data.spaceKey)
	end
end

function HomeStationSearchComponent:refreshEmptyState()
	local list

	if self.choosePage == TabType.Friend then
		list = self.friendCampListData
	else
		list = self.allCampListData
	end

	local isEmpty = not list or #list == 0

	if self.emptyUWidget then
		self.emptyUWidget:SetActive(isEmpty)
	end
end

function HomeStationSearchComponent:onJoinCamp(campId, lineUid)
	pg.me:changeCamp(campId, lineUid, function()
		if self.ctrl then
			self.ctrl:close()
		end
	end)
end

function HomeStationSearchComponent:onVisitCamp(homeCampKey)
	pg.me:enterHomeCamp(homeCampKey)

	if self.ctrl then
		self.ctrl:close()
	end
end

return HomeStationSearchComponent
