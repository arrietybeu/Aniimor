-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\PlatformShellConst.lua

local PlatformShellConst = {}

PlatformShellConst.TokenType = {
	InviteQuickSpaceFollow = "InviteQuickSpaceFollow",
	ReuquestSpaceFollow = "ReuquestSpaceFollow",
	InviteSpaceFollow = "InviteSpaceFollow",
	InviteEnterPhotoWorld = "InviteEnterPhotoWorld",
	InviteExchangePet = "InviteExchangePet",
	RequestEnterWorld = "RequestEnterWorld",
	InviteEnterWorld = "InviteEnterWorld",
	RequestJoinTeam = "RequestJoinTeam",
	InviteJoinTeam = "InviteJoinTeam",
	JoinGameByShell = "JoinGameByShell",
	RequestHomeCamp = "RequestHomeCamp",
	InviteHomeCamp = "InviteHomeCamp"
}
PlatformShellConst.KnownTokenTypes = {}

for _, tokenType in pairs(PlatformShellConst.TokenType) do
	PlatformShellConst.KnownTokenTypes[tokenType] = true
end

PlatformShellConst.InGameDestinationQueryMode = "ingame_enter_world_invite"
PlatformShellConst.InGameEnterWorldDestinationQueryMode = "ingame_enter_world"
PlatformShellConst.OpenTargetTokenTypes = {
	[PlatformShellConst.TokenType.JoinGameByShell] = true
}

function PlatformShellConst.isOpenTargetTokenType(tokenType)
	return PlatformShellConst.OpenTargetTokenTypes[tostring(tokenType or "")] == true
end

function PlatformShellConst.makeTokenKey(tokenType, targetKey)
	return string.format("%s:%s", tostring(tokenType or ""), tostring(targetKey or ""))
end

return PlatformShellConst
