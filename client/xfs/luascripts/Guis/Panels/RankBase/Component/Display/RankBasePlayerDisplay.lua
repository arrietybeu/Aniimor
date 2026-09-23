-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankBase\\Component\\Display\\RankBasePlayerDisplay.lua

local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RankBasePlayerDisplay = {}

function RankBasePlayerDisplay.renderPlayerInfo(objectReference, rankData, playerInfo, getRenderPlayerName)
	local playerHeadUWidget = objectReference:GetRefValue("playerHeadUWidget")
	local txtPlayerNameUSDFText = objectReference:GetRefValue("txtPlayerNameUSDFText")
	local btnPlayerHeadUButton = objectReference:GetRefValue("btnPlayerHeadUButton")

	RankBasePlayerDisplay.resetPlayerButton(btnPlayerHeadUButton)

	if rankData.MemberId == pg.me.uid then
		playerInfo = pg.me
	end

	if not playerInfo then
		LuaUIUtils.renderPlayerAvatarImages(playerHeadUWidget, {
			showAvatarFrame = false,
			showAvatar = false
		})
		ClientTextUtils.setText(txtPlayerNameUSDFText, "")

		return false
	end

	local cardPlayerInfo = RankBasePlayerDisplay.getPlayerCardInfo(playerInfo)

	LuaUIUtils.renderPlayerAvatarImages(playerHeadUWidget, {
		avatarIconId = playerInfo.headIcon,
		avatarFrameIconId = playerInfo.headFrame
	})

	local playerName = getRenderPlayerName(rankData, cardPlayerInfo, playerInfo.name or playerInfo.playerName)

	ClientTextUtils.setText(txtPlayerNameUSDFText, playerName)

	function btnPlayerHeadUButton.luaClick()
		RankBasePlayerDisplay.openPlayerInfo(playerInfo)
	end

	return true
end

function RankBasePlayerDisplay.openPlayerInfo(playerInfo)
	LuaUIUtils.openInfoPlayerCard({
		openType = ClientConst.PlayerInfoOpenType.Rank,
		playerId = playerInfo.uid,
		playerInfo = RankBasePlayerDisplay.getPlayerCardInfo(playerInfo),
		openSource = pg.game.chat.AddFriendSource.PlayerCard
	})
end

function RankBasePlayerDisplay.getPlayerCardInfo(playerInfo)
	if playerInfo.uid ~= pg.me.uid then
		local cachedPlayerInfo = pg.game.chat:getPlayerInfo(playerInfo.uid)

		if cachedPlayerInfo then
			return cachedPlayerInfo
		end
	end

	return {
		uid = playerInfo.uid,
		playerName = playerInfo.name,
		level = playerInfo.level,
		headIcon = playerInfo.headIcon,
		headFrame = playerInfo.headFrame,
		starTitle = playerInfo.starTitle
	}
end

function RankBasePlayerDisplay.resetPlayerButton(button)
	button.luaClick = nil
	button.luaRenderTooltip = nil
	button.luaTooltipPopup = nil
	button.enabledTooltip = false
	button.draggable = false
end

function RankBasePlayerDisplay.renderTeamMember(button, _, memberData)
	RankBasePlayerDisplay.resetPlayerButton(button)

	local playerInfo = memberData.playerInfo
	local itemObjectReference = button:GetComponent("ObjectReference")
	local playerHeadUWidget = itemObjectReference:GetRefValue("playerHeadUWidget")
	local captainUWidget = itemObjectReference:GetRefValue("captainUWidget")

	LuaUIUtils.renderPlayerAvatarImages(playerHeadUWidget, {
		avatarIconId = playerInfo.headIcon,
		avatarFrameIconId = playerInfo.headFrame
	})
	captainUWidget:SetActive(memberData.isLeader)
end

function RankBasePlayerDisplay.openTeamMemberInfo(_, memberData)
	RankBasePlayerDisplay.openPlayerInfo(memberData.playerInfo)
end

return RankBasePlayerDisplay
