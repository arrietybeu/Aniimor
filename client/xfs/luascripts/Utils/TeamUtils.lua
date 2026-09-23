-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\TeamUtils.lua

local AppearanceCustomOne = require("CustomTypes.AppearanceCustomOne")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PetData = require("Data.pet_data")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local TeamFuncData = require("Data.team_func_data")
local Utils = require("Common.Utils.Utils")
local TeamUtils = {}

TeamUtils.TEAM_FORMATION_EFFECT = "Eff_UI_TeamFormation"
TeamUtils.teamMemberTooltipEffectInfos = setmetatable({}, {
	__mode = "k"
})

local COME_TO_PLAYER_NEAR_DISTANCE = 5
local COME_TO_PLAYER_NEAR_DISTANCE_SQR = COME_TO_PLAYER_NEAR_DISTANCE * COME_TO_PLAYER_NEAR_DISTANCE

function TeamUtils.isPlayerWithinMeetRange(playerId)
	local targetEnt = pg.getEntityByUid(playerId)

	if not targetEnt or not pg.me or not pg.me.getPosition then
		return false
	end

	local myPos = pg.me:getPosition()
	local targetPos = targetEnt.getPosition and targetEnt:getPosition() or nil

	if not myPos or not targetPos then
		return false
	end

	return Vector3.HoriSqrDistance(myPos, targetPos) <= COME_TO_PLAYER_NEAR_DISTANCE_SQR
end

function TeamUtils.addFriend(subButton, playerId)
	pg.game.chat:applyFriend(playerId, pg.game.chat.AddFriendSource.Team)
end

function TeamUtils.changeTeamLeader(subButton, playerId)
	pg.me:changeTeamLeader(playerId)
end

function TeamUtils.kickTeamMember(subButton, playerId)
	pg.me:kickTeamMember(playerId)
end

function TeamUtils.disbandTeam(subButton, playerId)
	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("DISBAND_TEAM"), function()
		pg.me:disbandTeam()
	end)
end

function TeamUtils.enterWorld(subButton, playerId)
	if LuaUIUtils.checkInOtherPlayerWorld() then
		pg.global.ui.tips:showTextTip(pg.getGameString("ALREADY_IN_OTHER_PLAYER_WORLD"))

		return
	end

	pg.me:requestEnterWorld(playerId)
end

function TeamUtils.leaveLeaderWorld(subButton, playerId)
	pg.me:leaveLeaderWorld()
end

function TeamUtils.leaveTeam(subButton, playerId)
	pg.me:leaveTeam()
end

function TeamUtils.applyTeamDungeon()
	pg.me:applyTeamDungeon(2001)
end

function TeamUtils.prepareTeamDungeon()
	pg.me:prepareTeamDungeon()
end

function TeamUtils.startTeamDungeon()
	pg.me:startTeamDungeon()
end

function TeamUtils.removeSpaceFollowMember(subButton, playerId)
	pg.me:kickSpaceFollow(playerId)
end

function TeamUtils.quitSpaceFollow(subButton, playerId)
	pg.me:exitSpaceFollow()
end

function TeamUtils.showPlayerCard(subButton, playerId)
	local param = {
		openType = ClientConst.PlayerInfoOpenType.Chat,
		playerId = playerId,
		openSource = pg.game.chat.AddFriendSource.Team
	}

	LuaUIUtils.openInfoPlayerCard(param)
end

function TeamUtils.comeToPlayer(subButton, playerId)
	local ent = pg.getEntityByUid(playerId)

	if ent and TeamUtils.isPlayerWithinMeetRange(playerId) then
		pg.global.ui.tips:showTextTip(pg.getGameString("PLAYER_WITHIN_RANGE"))

		return
	end

	pg.me:requestEnterWorld(playerId)
end

function TeamUtils.comeToMe(subButton, playerId)
	pg.me:handleRemoteInviteSinglePlayer(playerId, Const.InviteWorldType.NORMAL_INVITE)
end

function TeamUtils.getTeamRoomScenePlayerModel(playerId)
	local teamRoom = pg.global and pg.global.ui and pg.global.ui.teamRoom
	local uiScene = teamRoom and teamRoom.uiScene

	if uiScene and uiScene.getPlayerModelByUid then
		return uiScene:getPlayerModelByUid(playerId)
	end

	return nil
end

function TeamUtils.stopTeamMemberTooltipEffect(button)
	local effectInfo = button and TeamUtils.teamMemberTooltipEffectInfos[button]

	if effectInfo then
		if effectInfo.model and effectInfo.model.stopEffectById then
			effectInfo.model:stopEffectById(effectInfo.effectId)
		end

		TeamUtils.teamMemberTooltipEffectInfos[button] = nil
	end
end

function TeamUtils.playTeamMemberTooltipEffect(button, playerId)
	TeamUtils.stopTeamMemberTooltipEffect(button)

	local playerModel = TeamUtils.getTeamRoomScenePlayerModel(playerId)

	if playerModel and playerModel.eModel then
		local effectId = playerModel:playEffectOn(TeamUtils.TEAM_FORMATION_EFFECT, nil, playerModel.eModel.transform)

		if effectId then
			TeamUtils.teamMemberTooltipEffectInfos[button] = {
				model = playerModel,
				effectId = effectId
			}
		end
	end
end

function TeamUtils.handleTeamMemberTooltip(button, playerId, playerButton, enabled)
	local cachedFuncData

	button.tooltipMode = 0

	TeamUtils.stopTeamMemberTooltipEffect(button)

	if enabled == false then
		button:ClosePopup()

		button.luaTooltipPopup = nil
		button.luaRenderTooltip = nil
		button.luaClick = nil

		if NotNil(playerButton) then
			playerButton:TryChangePage("Selected", 0)
		end

		button:SetActive(false)

		return
	end

	button:SetActive(true)

	function button.luaTooltipPopup(button2, isOpen)
		if NotNil(playerButton) then
			playerButton:TryChangePage("Selected", isOpen and 1 or 0)
		end
	end

	function button.luaRenderTooltip(button2, popup)
		TeamUtils.renderPlayerToolTip(button2, popup, playerId, cachedFuncData)

		cachedFuncData = nil
	end

	function button.luaClick()
		cachedFuncData = nil

		local data = TeamUtils.getTeamFuncData(playerId)

		if #data == 0 then
			pg.global.showBubbleMessageRaw(pg.getGameString("NO_TEAM_INTERACT_FUNC"))
		elseif pg.me.uid ~= playerId then
			cachedFuncData = data

			button:OpenTooltip()
		end
	end
end

function TeamUtils.renderPlayerToolTip(button, popup, playerId, cachedData)
	local objectReference = popup:GetComponent("ObjectReference")
	local listUList = objectReference:GetRefValue("listUList")

	function listUList.luaRenderItem(subButton, index, subData)
		local listObjectReference = subButton:GetComponent("ObjectReference")
		local icon = listObjectReference:GetRefValue("icon")
		local txtName = listObjectReference:GetRefValue("txtName")

		ClientTextUtils.setText(txtName, pg.getLocalizationText(subData.label))
		icon:SetActive(subData.icon ~= nil)

		if subData.icon then
			icon.url = subData.icon
		end

		function subButton.luaClick()
			button:ClosePopup()
			TeamUtils[subData.func](subButton, playerId)
		end
	end

	local data = cachedData or TeamUtils.getTeamFuncData(playerId)

	table.sort(data, function(a, b)
		return a.sort < b.sort
	end)
	listUList:SetList(data)

	local closePopupBind = KeyBindingPro.GetOrAddKeyBindingByName(listUList.gameObject, "closePopupBind")

	closePopupBind.actionPath = "Common/Cancel"
	closePopupBind.isVirtual = true
	closePopupBind.priority = 1000

	function closePopupBind.luaTrigger(inputInfo)
		if not pg.game.input:isUsingGamepad() or not pg.game.input.hudShowVirtualMouseCursor or button.isTooltipOpen then
			return true
		end

		if inputInfo.phase == "Canceled" then
			button:ClosePopup()
		end
	end
end

function TeamUtils.getTeamFuncData(playerId)
	local data = {}
	local sceneId = Utils.isSpacePhase(pg.me.space.sceneId) and Utils.getPhaseMainSceneId(pg.me.space.sceneId) or pg.me.space.sceneId
	local curDungeon = pg.me:getCurTeamInfo().dungeonSceneId or sceneId

	for _, func in ipairs(TeamFuncData) do
		local noShowContains = func.noShowSceneId and #func.noShowSceneId > 0 and table.contains(func.noShowSceneId, sceneId)
		local showContains = func.showSceneId and #func.showSceneId > 0 and table.contains(func.showSceneId, sceneId) or not func.showSceneId or #func.showSceneId == 0

		if not noShowContains and showContains and TeamUtils[func.checkFunc] and TeamUtils[func.func] and TeamUtils[func.checkFunc](playerId) then
			data[#data + 1] = {
				label = func.label,
				func = func.func,
				sort = func.sort,
				icon = func.icon
			}
		end
	end

	return data
end

function TeamUtils.checkShowPlayerInfo(playerId)
	return pg.me.uid ~= playerId
end

function TeamUtils.checkIsFriend(playerId)
	return pg.me.uid ~= playerId and not pg.game.chat:checkFriendList(playerId)
end

function TeamUtils.checkTeamLeader(playerId)
	return pg.me:isTeamLeader()
end

function TeamUtils.checkNotTeamLeader(playerId)
	return not pg.me:isTeamLeader()
end

function TeamUtils.checkCanKickTeamMember(playerId)
	return pg.me:isTeamLeader() and pg.me:isMatchStatusInit()
end

function TeamUtils.checkCanDisbandTeam(playerId)
	return pg.me:isTeamLeader() and pg.me:isMatchStatusInit()
end

function TeamUtils.checkCanLeaveTeam(playerId)
	return pg.me.uid == playerId or not pg.me:isTeamLeader()
end

function TeamUtils.checkInLeaderWorld(playerId)
	return pg.me:isUidTeamLeader(playerId) and pg.me:isMatchStatusInit() and pg.me.inLeaderWorld
end

function TeamUtils.checkCanEnterWorld(playerId)
	return pg.me:isUidTeamLeader(playerId) and pg.me:isMatchStatusInit() and not pg.me.inLeaderWorld
end

function TeamUtils.checkCanQuitSpaceFollow(playerId)
	if pg.me and pg.me.space then
		local myLeader = pg.me.space:getSpaceFollowLeader(pg.me.uid)
		local playerLeader = pg.me.space:getSpaceFollowLeader(playerId)

		if not string.isNilOrEmpty(myLeader) and not string.isNilOrEmpty(playerLeader) and myLeader == playerLeader then
			return true
		end
	end

	return false
end

function TeamUtils.checkCanKickSpaceFollowMember(playerId)
	if pg.me and pg.me.space then
		local myLeader = pg.me.space:getSpaceFollowLeader(pg.me.uid)
		local playerLeader = pg.me.space:getSpaceFollowLeader(playerId)

		if not string.isNilOrEmpty(myLeader) and not string.isNilOrEmpty(playerLeader) and myLeader == playerLeader and myLeader == pg.me.uid then
			return true
		end
	end

	return false
end

function TeamUtils.checkCanComeToPlayer(playerId)
	if playerId == pg.me.uid then
		return false
	end

	local ent = pg.getEntityByUid(playerId)

	return ent ~= nil or pg.me:isUidTeamLeader(playerId)
end

function TeamUtils.checkCanComeToMe(playerId)
	if playerId == pg.me.uid then
		return false
	end

	local ent = pg.getEntityByUid(playerId)

	return ent ~= nil or pg.me:isTeamLeader()
end

return TeamUtils
