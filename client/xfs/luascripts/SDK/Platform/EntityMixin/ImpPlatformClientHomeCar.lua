-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientHomeCar.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local UIConst = require("Const.UIConst")

function M:getRawHomeCarName()
	if not self.basicInfo then
		return ""
	end

	return self.basicInfo.name or ""
end

function M:getHomeOwnerPlayerInfo()
	return pg.game.chat and pg.game.chat.getPlayerInfo and pg.game.chat:getPlayerInfo(self.playerUID) or nil
end

function M:refreshHomeCarNameConsumers()
	self:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.COMBAT, "refreshName", true)

	if self.carGroup and self.carGroup.boardEntity and self.carGroup.boardEntity.onBasicInfoChanged then
		self.carGroup.boardEntity:onBasicInfoChanged(self.basicInfo)
	end
end

function M:bindRemoteHomeCarName(rawName)
	local displayName = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.HomeCarName,
		uid = self.playerUID,
		playerInfo = M.getHomeOwnerPlayerInfo(self),
		rawText = rawName
	})

	return displayName
end

function M:getName(rawName)
	if not rawName or rawName == "" then
		return rawName
	end

	if self:isSelfHomeCar() then
		return rawName
	end

	return M.bindRemoteHomeCarName(self, rawName)
end

return M
