-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankBase\\Component\\Display\\RankBaseMemberDisplay.lua

local RankBasePetDisplay = require("Guis.Panels.RankBase.Component.Display.RankBasePetDisplay")
local RankBasePlayerDisplay = require("Guis.Panels.RankBase.Component.Display.RankBasePlayerDisplay")
local RankBaseMemberDisplay = {}

function RankBaseMemberDisplay.renderTeamLayout(objectReference, _, teamInfo)
	if teamInfo == nil then
		return false
	end

	RankBaseMemberDisplay.renderMemberLayout(objectReference, RankBaseMemberDisplay.createPlayerMemberList(teamInfo.members, teamInfo.leaderUid), RankBasePlayerDisplay.renderTeamMember, RankBasePlayerDisplay.openTeamMemberInfo)

	return true
end

function RankBaseMemberDisplay.createPlayerMemberList(playerInfos, leaderUid)
	local memberList = {}

	for _, playerInfo in ipairs(playerInfos) do
		memberList[#memberList + 1] = {
			tIndex = 0,
			isLeader = playerInfo.uid == leaderUid,
			playerInfo = playerInfo
		}
	end

	return memberList
end

function RankBaseMemberDisplay.renderPetLayout(objectReference, _, petTeamInfo, petInfoTipPresenter)
	if petTeamInfo == nil then
		return false
	end

	RankBaseMemberDisplay.renderMemberLayout(objectReference, RankBaseMemberDisplay.createPetMemberList(petTeamInfo.pets), RankBasePetDisplay.renderPetMember, nil, petInfoTipPresenter)

	return true
end

function RankBaseMemberDisplay.createPetMemberList(petInfos)
	local memberList = {}

	for _, petInfo in ipairs(petInfos) do
		memberList[#memberList + 1] = {
			tIndex = 0,
			petInfo = petInfo
		}
	end

	return memberList
end

function RankBaseMemberDisplay.renderMemberLayout(objectReference, memberList, renderItem, clickItem, renderContext)
	local listPetUList = objectReference:GetRefValue("listPetUList")

	function listPetUList.luaRenderItem(button, index, data)
		renderItem(button, index, data, renderContext)
	end

	function listPetUList.luaClick(button, data)
		if clickItem == nil then
			return
		end

		clickItem(button, data, renderContext)
	end

	listPetUList.luaSelectedChanged = nil

	listPetUList:SetList(memberList)
end

return RankBaseMemberDisplay
