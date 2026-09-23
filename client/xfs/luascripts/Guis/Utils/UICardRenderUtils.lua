-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\UICardRenderUtils.lua

local ClientTextUtils = require("Utils.ClientTextUtils")
local TeamUtils = require("Utils.TeamUtils")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ShowTitleUtils = require("Utils.ShowTitleUtils")
local Const = require("Common.Const.Const")
local ShowTitleData = require("Data.show_title_data")
local UICardRenderUtils = {}

function UICardRenderUtils.getShowTitleText(showTitles, showTitleExtra, isWholeTitle, resolvedFriendName)
	return ShowTitleUtils.getShowTitleText(showTitles, showTitleExtra, isWholeTitle, resolvedFriendName)
end

function UICardRenderUtils.getShowTitleBackgroundUrl(showTitles, isWholeTitle)
	local backgroundId = showTitles and showTitles[Const.SHOW_TITLE_TYPE.Background]
	local wholeTitleId = showTitles and showTitles[Const.SHOW_TITLE_TYPE.Whole]
	local backgroundData = backgroundId and ShowTitleData[backgroundId]
	local wholeTitleData = wholeTitleId and ShowTitleData[wholeTitleId]
	local backgroundUrl = backgroundData and backgroundData.bgRes

	if isWholeTitle and wholeTitleData and not string.isNilOrEmpty(wholeTitleData.bgRes) then
		backgroundUrl = wholeTitleData.bgRes
	end

	return backgroundUrl
end

function UICardRenderUtils.renderShowTitle(topTitleUWidget, showTitles, showTitleExtra, isWholeTitle, resolvedFriendName)
	if not topTitleUWidget then
		return
	end

	local titleText = UICardRenderUtils.getShowTitleText(showTitles, showTitleExtra, isWholeTitle, resolvedFriendName)
	local hasTitle = not string.isNilOrEmpty(titleText)

	topTitleUWidget:SetActive(hasTitle)

	if not hasTitle then
		return
	end

	local objectReference = topTitleUWidget:GetComponent("ObjectReference")
	local baseUImage = objectReference:GetRefValue("baseUImage")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

	ClientTextUtils.setText(txtTitleUSDFText, titleText)

	local backgroundUrl = UICardRenderUtils.getShowTitleBackgroundUrl(showTitles, isWholeTitle)

	if baseUImage then
		baseUImage:SetActive(not string.isNilOrEmpty(backgroundUrl))

		if not string.isNilOrEmpty(backgroundUrl) then
			baseUImage.url = backgroundUrl
		end
	end
end

function UICardRenderUtils.render1Plus3RoomCard(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local uINodeTeamRoomCenterItemUComponent = objectReference:GetRefValue("uINodeTeamRoomCenterItemUComponent")
	local listPetInfoUList = objectReference:GetRefValue("listPetInfoUList")
	local playerNameUBaseText = objectReference:GetRefValue("playerNameUBaseText")
	local topTitleUWidget = objectReference:GetRefValue("topTitleUWidget")
	local btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	local skillInfoUComponent = objectReference:GetRefValue("skillInfoUComponent")
	local toolTipBtnUButton = objectReference:GetRefValue("toolTipBtnUButton")
	local panelPetInfo = objectReference:GetRefValue("panelPetInfo")
	local infoPetInfo = objectReference:GetRefValue("infoPetInfo")

	panelPetInfo:SetActive(true)
	infoPetInfo:SetActive(false)

	local playerName = data.playerName
	local hooks = UICardRenderUtils._platformHooks

	playerName = hooks and hooks.getRender1Plus3RoomPlayerName and hooks.getRender1Plus3RoomPlayerName(UICardRenderUtils, data, playerName) or playerName

	ClientTextUtils.setText(playerNameUBaseText, playerName)
	UICardRenderUtils.renderShowTitle(topTitleUWidget, data.showTitles, data.showTitleExtra, data.isWholeTitle)

	if hooks and hooks.render1Plus3RoomOnlineID then
		hooks.render1Plus3RoomOnlineID(UICardRenderUtils, objectReference, data)
	end

	if not data.isLeader then
		if data.isReady then
			button:TryChangePage("MemberState", 2)
		else
			button:TryChangePage("MemberState", 3)
		end
	else
		button:TryChangePage("MemberState", 0)
	end

	if data.isSelf then
		button:TryChangePage("Belong", 0)
	else
		button:TryChangePage("Belong", 1)
	end

	UICardRenderUtils.render1Plus3Pet(panelPetInfo, data)
	TeamUtils.handleTeamMemberTooltip(toolTipBtnUButton, data.uid, button)
	pg.game.speech:handlePlayerVoiceState(button, data)

	function toolTipBtnUButton.luaNavFocused()
		TeamUtils.playTeamMemberTooltipEffect(toolTipBtnUButton, data.uid)

		if data.onNavFocused then
			data.onNavFocused(data.uid)
		end
	end

	function toolTipBtnUButton.luaNavUnfocused()
		TeamUtils.stopTeamMemberTooltipEffect(toolTipBtnUButton)

		if data.onNavUnfocused then
			data.onNavUnfocused(data.uid)
		end
	end
end

function UICardRenderUtils.render1Plus3Pet(panel, data)
	local oc = panel:GetComponent("ObjectReference")
	local petPrimary = oc:GetRefValue("petPrimary")
	local petMinor1 = oc:GetRefValue("petMinor1")
	local petMinor2 = oc:GetRefValue("petMinor2")
	local petMinor3 = oc:GetRefValue("petMinor3")
	local btnSwitch = oc:GetRefValue("btnSwitch")

	LuaUIUtils.setUIVisible(btnSwitch, data.isSelf)

	local otherPetItems = {
		petMinor1,
		petMinor2,
		petMinor3
	}
	local petList = data.petList
	local p1Data = petList[1]

	if p1Data.empty then
		petPrimary:TryChangePage("Empty", 1)
	else
		petPrimary:TryChangePage("Empty", 0)

		local pOc = petPrimary:GetComponent("ObjectReference")
		local petNameUBaseText = pOc:GetRefValue("petNameUBaseText")
		local iconUImage = pOc:GetRefValue("iconUImage")
		local txtLvNumUBaseText = pOc:GetRefValue("txtLvNumUBaseText")
		local txtCpNumUBaseText = pOc:GetRefValue("txtCpNumUBaseText")
		local txtCpUBaseText = pOc:GetRefValue("txtCpUBaseText")
		local petDisplayName = p1Data.name
		local petNameHooks = UICardRenderUtils._platformHooks

		if petNameHooks and petNameHooks.getRender1Plus3PrimaryPetName then
			petDisplayName = petNameHooks.getRender1Plus3PrimaryPetName(UICardRenderUtils, data, p1Data)
		end

		ClientTextUtils.setText(petNameUBaseText, petDisplayName)

		iconUImage.url = p1Data.icon

		ClientTextUtils.setText(txtLvNumUBaseText, tostring(p1Data.level))
		txtCpNumUBaseText:SetActiveFastest(p1Data.cp ~= 0)
		txtCpUBaseText:SetActiveFastest(p1Data.cp ~= 0)
		ClientTextUtils.setText(txtCpNumUBaseText, tostring(p1Data.cp))

		local elementUButton = pOc:GetRefValue("elementUButton")

		LuaUIUtils.setElementButtonNew(elementUButton, p1Data.mainElementType)
	end

	for i, item in ipairs(otherPetItems) do
		local piData = petList[i + 1]

		if piData == nil or piData.empty then
			item:TryChangePage("Empty", 1)
		else
			item:TryChangePage("Empty", 0)

			local pOc = item:GetComponent("ObjectReference")
			local iconUImage = pOc:GetRefValue("iconUImage")
			local iconSkillUImage = pOc:GetRefValue("iconSkillUImage")
			local hasCoreAbilityId = piData.coreAbilityId and piData.coreAbilityId ~= 0 or false

			iconSkillUImage:SetActive(hasCoreAbilityId)

			if hasCoreAbilityId then
				iconSkillUImage.url = LuaUIUtils.getSkillIconByAbilityId(piData.coreAbilityId)
			end

			item:TryChangePage("SkillEmpty", hasCoreAbilityId and 0 or 1)

			iconUImage.url = piData.icon
		end
	end

	function btnSwitch.luaClick()
		if data.switchPetsFunc then
			data.switchPetsFunc()
		end
	end
end

return UICardRenderUtils
