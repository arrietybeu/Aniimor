-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformMapCtrl.lua

local M = {}

function M:handleCancelOnLocationInfo()
	local isPS = pg.global.platform:isPS()

	if isPS then
		self:closeCurrentLocationInfo()
	end

	return isPS
end

function M:shouldHideLocationInfoCloseBtn()
	local isPS = pg.global.platform:isPS()
	local closeBtn = self.currentLocationInfoCloseBtn

	if isPS and NotNil(closeBtn) then
		closeBtn.gameObject:SetActiveEx(false)
	end
end

return M
