-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientFriendQueryConfig.lua

local ClientFriendQueryConfig = {
	queryPlayerInfo = {
		"playerName",
		"uid",
		"level",
		"starTitle",
		"online",
		"loginTime",
		"lastLogoutTime",
		"teamId",
		"teamMembers",
		"matchStatus",
		"showPetInfo",
		"headIcon",
		"headFrame",
		"userName",
		"homelandKey",
		"homelandHasTillableFacility",
		"avatarPresetKey",
		"avatarConfig",
		"curShow",
		"showSignature",
		"teamDungeonSceneId",
		"isWholeTitle",
		"showTitles",
		"showTitleExtra",
		"cardBackground",
		"fashionScore",
		"voiceSignature",
		"badgeShowMap",
		"chatBubble",
		"stableAttributesStr",
		"profilePhotographyStudioUid"
	},
	queryFriendTillableStateList = {
		"homelandHasTillableFacility"
	},
	queryDungeonInvitePlayerStateList = {
		"teamId",
		"teamMembers",
		"matchStatus",
		"teamDungeonSceneId"
	},
	queryBasicPlayerInfoList = {
		"uid",
		"playerName",
		"level",
		"headIcon",
		"headFrame"
	},
	queryPlayerInfoByFuzzyName = {
		"playerName",
		"level",
		"online",
		"starTitle",
		"loginTime",
		"lastLogoutTime",
		"teamId",
		"teamMembers",
		"matchStatus",
		"showPetInfo",
		"headIcon",
		"headFrame",
		"userName",
		"homelandKey",
		"avatarPresetKey",
		"avatarConfig",
		"curShow",
		"stableAttributesStr"
	}
}

return ClientFriendQueryConfig
