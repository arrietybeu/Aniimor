-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampVisit\\HomeCampVisitCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampVisitCtrl")
local lume = require("Core.Common.lume")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeCampData = require("Data.home_camp_data")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local AvatarPresetData = require("Data.avatar_preset_data")
local Utils = require("Common.Utils.Utils")
local AddressDataConst = require("Const.AddressDataConst")
local NoticeDef = require("Common.NoticeDef")
local TimerManager = require("Core.Timer.TimerManager")
local HomeCampVisitCtrl = Class.LightClass("HomeCampVisitCtrl", UICtrl)

HomeCampVisitCtrl.messages = {}

local VisitType = {
	Visit = 1,
	Switch = 2
}
local TabType = {
	All = 2,
	Friend = 1
}
local DefaultCampNum = 20

function HomeCampVisitCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomeCampVisitCtrl:addListener()
	function self.view.closeBtn.luaClick()
		self:close()
	end

	function self.view.friendBtn.luaClick()
		self:selectTab(TabType.Friend)
	end

	function self.view.allBtn.luaClick()
		self:selectTab(TabType.All)
	end

	function self.view.friendCampList.luaRenderItem(item, index, data)
		self:rendererFriendCampInfo(item, index, data)
	end

	function self.view.allCampList.luaRenderItem(item, index, data)
		self:rendererAllCampInfo(item, index, data)
	end

	function self.view.btnSearch.luaClick()
		self:onSearchBtnClick()
	end

	function self.view.btnRefresh.luaClick()
		self:onRefreshBtnClick()
	end

	self:setupGamepadNav()
end

function HomeCampVisitCtrl:setupGamepadNav()
	local input = self.view.inputField

	if not input then
		return
	end

	logger:info("[CampVisitNav] setupGamepadNav: relying on prefab isVirtual=true")

	function input.luaOnSelect()
		local navMgr = CS.XGUI.Navigation.NavManager.Instance
		local r = navMgr and navMgr:FocusItem(input)

		logger:info(string.format("[CampVisitNav] luaOnSelect: FocusItem=%s", tostring(r)))
	end

	function input.luaOnDeSelect()
		logger:info("[CampVisitNav] luaOnDeSelect")
		self:scheduleFocusListFirstItem()
	end

	if self.bindHotKeyPerform then
		self:bindHotKeyPerform("Raw/GamepadRightStickPress", function()
			local editing = input.allowInput

			logger:info(string.format("[CampVisitNav] RS pressed, allowInput=%s", tostring(editing)))

			if editing then
				input:DeSelect()
				self:scheduleFocusListFirstItem()

				return true
			end

			return false
		end, nil, "HomeCampVisit_InputCancelRS")
		logger:info("[CampVisitNav] RS hotkey bound")
	end
end

function HomeCampVisitCtrl:scheduleFocusListFirstItem()
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

function HomeCampVisitCtrl:focusListFirstItem()
	if not self.view or not self.view.allCampList then
		logger:info("[CampVisitNav] focusListFirstItem: no list")

		return
	end

	if self.tabType ~= TabType.All then
		logger:info(string.format("[CampVisitNav] focusListFirstItem: skip tabType=%s", tostring(self.tabType)))

		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return
	end

	local ok, btn = self.view.allCampList:TryGetChildAt(0)

	logger:info(string.format("[CampVisitNav] focusListFirstItem: TryGetChildAt(0)=%s, btn=%s", tostring(ok), tostring(btn)))

	if ok and btn then
		local r = navMgr:FocusItem(btn)

		logger:info(string.format("[CampVisitNav] focusListFirstItem: FocusItem=%s", tostring(r)))

		if not r then
			navMgr:TryFocusFirstAvailable()
		end
	else
		navMgr:TryFocusFirstAvailable()
	end
end

function HomeCampVisitCtrl:onDestroy()
	if self._focusListTimer then
		TimerManager.removeTimer(self._focusListTimer)

		self._focusListTimer = nil
	end

	if self.view and self.view.inputField then
		self.view.inputField.luaOnSelect = nil
		self.view.inputField.luaOnDeSelect = nil
	end

	UICtrl.onDestroy(self)
end

function HomeCampVisitCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.campId = info.campId
	self.isFromMap = info.isFromMap
	self.isSwitch = info.isSwitch
	self.isPlayerManager = HomeLandUtils.isHomeCampManager() or false

	if self.isSwitch then
		self.visitType = VisitType.Switch
	else
		self.visitType = VisitType.Visit
	end

	local campData = HomeCampData[self.campId]

	self.maxCampNum = #campData.carId

	ClientTextUtils.setText(self.view.titleTxt, pg.getLocalizationText(campData.name))
	ClientTextUtils.setText(self.view.txtNameFriendUSDFText, pg.getGameString("HOMECAR_FRIEND_STATION"))
	ClientTextUtils.setText(self.view.txtNameAllUSDFText, pg.getGameString("HOMECAR_ALL_STATION"))
	self:selectTab(TabType.Friend)
end

function HomeCampVisitCtrl:onShow()
	return
end

function HomeCampVisitCtrl:onHide()
	return
end

function HomeCampVisitCtrl:selectTab(tabType)
	self.tabType = tabType

	if tabType == TabType.Friend then
		self.view.widget:TryChangePage("Type", "Friend")
		self:refreshFriendCamps()
	else
		self.view.widget:TryChangePage("Type", "All")
		self:refreshAllCamps()
	end

	self:refreshTabBtnState()
end

function HomeCampVisitCtrl:refreshTabBtnState()
	if self.tabType == TabType.Friend then
		self.view.friendBtn.isSelected = true
		self.view.allBtn.isSelected = false
	else
		self.view.friendBtn.isSelected = false
		self.view.allBtn.isSelected = true
	end
end

function HomeCampVisitCtrl:refreshFriendCamps()
	self:refreshFriendCampList()
end

function HomeCampVisitCtrl:refreshFriendCampList()
	self.friendList = pg.game.chat:getFriendList()
	self.friendIds = {}

	for _, friendData in pairs(self.friendList) do
		table.insert(self.friendIds, friendData.playerId)
	end

	pg.me:queryFriendCampInfo(self.friendIds, function(friendData, friendCampData)
		self:setFriendCampInfo(friendData, friendCampData)
	end)
end

function HomeCampVisitCtrl:setFriendCampInfo(friendData, friendCampData)
	self.friendData = friendData
	self.friendCampData = friendCampData

	local friendCampListData = {}

	for uid, friendInfo in pairs(friendData) do
		local campKey = friendInfo.homeCampKey
		local campData = friendCampData[campKey]

		if campData then
			local _, _, sceneId, lineUid = Utils.parseSpaceInstanceServiceKey(campKey)
			local campStaticId = HomeLandUtils.getHomeCampStaticId(sceneId)

			if campStaticId == self.campId then
				table.insert(friendCampListData, {
					playerInfo = pg.game.chat:getPlayerInfo(uid),
					friendShipLevel = pg.game.chat:getFriendship(uid),
					intimacy = pg.game.chat:getFriendIntimacy(uid),
					uid = uid,
					loginUids = campData.loginUids,
					lineUid = campData.lineUid,
					homeCampKey = campKey,
					displayCode = campData.displayCode,
					isPrivate = campData.isPrivate
				})
			end
		end
	end

	local function sortFunc(a, b)
		return (a.intimacy or -1) > (b.intimacy or -1)
	end

	table.sort(friendCampListData, sortFunc)

	self.friendCampListData = friendCampListData

	self.view.friendCampList:SetList(friendCampListData)
	self:refreshEmptyState()
end

function HomeCampVisitCtrl:rendererFriendCampInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")
	local imgAvatarUImage = objectReference:GetRefValue("imgAvatarUImage")
	local avatarUButton = objectReference:GetRefValue("avatarUButton")
	local imageIconUImage = objectReference:GetRefValue("imageIconUImage")
	local visitBtn = objectReference:GetRefValue("visitBtn")
	local lineText = objectReference:GetRefValue("lineText")
	local numText = objectReference:GetRefValue("numText")
	local iconPeopleUImage = objectReference:GetRefValue("iconPeopleUImage")
	local playerInfo = data.playerInfo
	local playerName = LuaUIUtils.getPlayerDisplayName(data.uid, playerInfo.playerName or "", true)
	local _h = HomeCampVisitCtrl._platformHooks

	playerName = _h and _h.rendererFriendCampName and _h.rendererFriendCampName(self, button, index, data, playerName) or playerName

	ClientTextUtils.setText(txtNameUSDFText, playerName)
	ClientTextUtils.setText(textLvUSDFText, playerInfo.level)

	local headIcon = playerInfo.headIcon or 1

	imgAvatarUImage.url = PlayerHeadIconData[headIcon] and PlayerHeadIconData[headIcon].res or ""

	local state = playerInfo.online and 0 or 1

	avatarUButton:TryChangePage("State", state + 1)

	local friendShipLevel = data.friendShipLevel
	local presetData = pg.game.avatar:getAvatarPresetData(playerInfo.avatarPresetKey) or {}
	local templateId = presetData.templateId or 0

	if templateId == 3 then
		button:TryChangePage("Gender", 1)
	elseif templateId == 4 then
		button:TryChangePage("Gender", 0)
	else
		button:TryChangePage("Gender", 2)
	end

	local hasFriendship = friendShipLevel and FriendshipLevelData[friendShipLevel]

	imageIconUImage:SetActive(hasFriendship)

	if hasFriendship then
		local friendshipIcon = FriendshipLevelData[friendShipLevel].levelIcon

		imageIconUImage.url = friendshipIcon
	end

	ClientTextUtils.setText(lineText, data.displayCode)

	local loginNum = lume.count(data.loginUids)
	local stationTypeName = pg.getGameString("HOMECAR_PUBLIC_STATION")

	if data.isPrivate then
		stationTypeName = pg.getGameString("HOMECAR_PRIVATE_STATION")
		iconPeopleUImage.url = AddressDataConst.HOME_CAMP_PRIVATE_ICON
	else
		iconPeopleUImage.url = AddressDataConst.HOME_CAMP_PUBLIC_ICON
	end

	if self.isSwitch then
		if loginNum >= self.maxCampNum then
			ClientTextUtils.setText(numText, stationTypeName .. pg.getFormatText("(<style=Debuff>{0}</style>/{1})", loginNum, self.maxCampNum))

			visitBtn.interactable = false
		else
			ClientTextUtils.setText(numText, stationTypeName .. pg.getFormatText("({0}/{1})", loginNum, self.maxCampNum))

			visitBtn.interactable = true
		end
	else
		ClientTextUtils.setText(numText, stationTypeName .. pg.getFormatText("{0}/{1}", loginNum, self.maxCampNum))

		visitBtn.interactable = true
	end

	function visitBtn.luaClick()
		self:onInteractBtnClick(data.lineUid, data.homeCampKey, playerInfo.uid)
	end

	if _h and _h.rendererFriendCampVisitButton then
		_h.rendererFriendCampVisitButton(self, button, index, data, visitBtn)
	end

	local txtNameUText = visitBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	if self.isSwitch then
		ClientTextUtils.setText(txtNameUText, pg.getGameString("HOME_JOIN"))
	else
		ClientTextUtils.setText(txtNameUText, pg.getGameString("HOME_VISIT"))
	end
end

function HomeCampVisitCtrl:rendererAllCampInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local visitBtn = objectReference:GetRefValue("visitBtn")
	local lineText = objectReference:GetRefValue("lineText")
	local numText = objectReference:GetRefValue("numText")
	local iconPeopleUImage = objectReference:GetRefValue("iconPeopleUImage")

	ClientTextUtils.setText(lineText, data.displayCode)

	local loginNum = lume.count(data.loginUids)
	local stationTypeName = pg.getGameString("HOMECAR_PUBLIC_STATION")

	if data.isPrivate then
		stationTypeName = pg.getGameString("HOMECAR_PRIVATE_STATION")
		iconPeopleUImage.url = AddressDataConst.HOME_CAMP_PRIVATE_ICON
	else
		iconPeopleUImage.url = AddressDataConst.HOME_CAMP_PUBLIC_ICON
	end

	if self.isSwitch then
		if loginNum >= self.maxCampNum then
			ClientTextUtils.setText(numText, stationTypeName .. pg.getFormatText("(<style=Debuff>{0}</style>/{1})", loginNum, self.maxCampNum))

			visitBtn.interactable = false
		else
			ClientTextUtils.setText(numText, stationTypeName .. pg.getFormatText("({0}/{1})", loginNum, self.maxCampNum))

			visitBtn.interactable = true
		end
	else
		ClientTextUtils.setText(numText, stationTypeName .. pg.getFormatText("{0}/{1}", loginNum, self.maxCampNum))

		visitBtn.interactable = true
	end

	function visitBtn.luaClick()
		self:onInteractBtnClick(data.lineUid, data.spaceKey, data.ownerUid)
	end

	local txtNameUText = visitBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	if self.isSwitch then
		ClientTextUtils.setText(txtNameUText, pg.getGameString("HOME_JOIN"))
	else
		ClientTextUtils.setText(txtNameUText, pg.getGameString("HOME_VISIT"))
	end
end

function HomeCampVisitCtrl:refreshAllCamps()
	self.searchText = ""

	self:refreshCampList()
end

function HomeCampVisitCtrl:refreshCampList()
	if string.isNilOrEmpty(self.searchText) then
		pg.me:getCampListN(DefaultCampNum, self.campId, "all", function(result, response)
			if not self.view then
				return
			end

			self.response = response

			if result.status and response.res then
				local spaceKey2LineInfo = response.res

				self:setAllCampList(spaceKey2LineInfo)
			else
				self:setAllCampList({})
			end
		end)
	else
		pg.me:findCampByCode(self.searchText, function(result, response)
			if not self.view then
				return
			end

			if result.status and response and response.summary then
				local spaceKey2LineInfo = {
					response.summary
				}

				self:setAllCampList(spaceKey2LineInfo)
			else
				self:setAllCampList({})
			end
		end)
	end
end

function HomeCampVisitCtrl:refreshEmptyState()
	if self.tabType == TabType.Friend then
		if #self.friendCampListData == 0 then
			self.view.emptyUWidget:SetActive(true)
		else
			self.view.emptyUWidget:SetActive(false)
		end
	elseif #self.allCampListData == 0 then
		self.view.emptyUWidget:SetActive(true)
	else
		self.view.emptyUWidget:SetActive(false)
	end
end

function HomeCampVisitCtrl:setAllCampList(allCampsInfo)
	self.allCampsInfo = allCampsInfo

	local allCampList = {}

	for spaceKey, lineInfo in pairs(allCampsInfo) do
		if not lineInfo.spaceKey and type(spaceKey) == "string" then
			lineInfo.spaceKey = spaceKey
		end

		table.insert(allCampList, lineInfo)
	end

	table.sort(allCampList, function(a, b)
		local aNum = lume.count(a.loginUids)
		local bNum = lume.count(b.loginUids)

		if aNum ~= bNum then
			return bNum < aNum
		end

		return (a.lineUid or 0) < (b.lineUid or 0)
	end)

	self.allCampListData = allCampList

	self.view.allCampList:SetList(allCampList)
	self:refreshEmptyState()

	local input = self.view.inputField

	if not input or not input.allowInput then
		self:scheduleFocusListFirstItem()
	end
end

function HomeCampVisitCtrl:onSearchBtnClick()
	self.searchText = self.view.inputField.text

	self:refreshCampList()
end

function HomeCampVisitCtrl:onRefreshBtnClick()
	if string.isNilOrEmpty(self.view.inputField.text) then
		self.searchText = ""
	end

	self:refreshCampList()
end

function HomeCampVisitCtrl:onInteractBtnClick(lineUid, homeCampKey, uid)
	if self.visitType == VisitType.Switch then
		if self.isPlayerManager then
			pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_MANAGER_JOIN)
		else
			pg.me:changeCamp(self.campId, lineUid, function()
				self:close()
			end)
		end
	else
		pg.me:enterHomeCamp(homeCampKey, uid)

		if self.isFromMap then
			pg.global.ui.map:closePanel(true)
		end

		self:close()
	end
end

return HomeCampVisitCtrl
