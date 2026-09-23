-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformAccountLinkingService.lua

local logger = require("SDK.Platform.PlatformLogger")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformAccountLinkingService = {}

PlatformAccountLinkingService.AgeGroup = {
	Unknown = 0,
	Adult = 3,
	Teen = 2,
	Child = 1
}
PlatformAccountLinkingService.state = {
	restrictPersonalData = false,
	userAgeGroup = 0,
	ownerUserId = "",
	initialized = false
}

function PlatformAccountLinkingService.isPlatformSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported() == true
end

function PlatformAccountLinkingService.isRuntimeReady()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsRuntimeInitialized and PlatformBridgeLuaFacade.IsRuntimeInitialized() == true
end

function PlatformAccountLinkingService.getSignedInUserId()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetSignedInUserId then
		return ""
	end

	local userId = PlatformBridgeLuaFacade.GetSignedInUserId()

	if string.isNilOrEmpty(userId) then
		return ""
	end

	return tostring(userId)
end

function PlatformAccountLinkingService.resetUserBoundState(clearOwner)
	PlatformAccountLinkingService.state.userAgeGroup = PlatformAccountLinkingService.AgeGroup.Unknown
	PlatformAccountLinkingService.state.restrictPersonalData = false

	if clearOwner ~= false then
		PlatformAccountLinkingService.state.ownerUserId = ""
	end
end

function PlatformAccountLinkingService.bindSignedInUser()
	local userId = PlatformAccountLinkingService.getSignedInUserId()

	if string.isNilOrEmpty(userId) then
		PlatformAccountLinkingService.resetUserBoundState()

		return false
	end

	if PlatformAccountLinkingService.state.ownerUserId ~= userId then
		PlatformAccountLinkingService.resetUserBoundState(false)

		PlatformAccountLinkingService.state.ownerUserId = userId
	end

	return true
end

function PlatformAccountLinkingService:isSupported()
	return PlatformAccountLinkingService.isPlatformSupported()
end

function PlatformAccountLinkingService:init(runtimeReady)
	if PlatformAccountLinkingService.state.initialized then
		if not PlatformAccountLinkingService.bindSignedInUser() then
			return false
		end

		self:evaluateCurrentUserCompliance()

		return true
	end

	if not self:isSupported() then
		return false
	end

	if runtimeReady ~= true and not PlatformAccountLinkingService.isRuntimeReady() then
		return false
	end

	if not PlatformAccountLinkingService.bindSignedInUser() then
		return false
	end

	PlatformAccountLinkingService.state.initialized = true

	self:evaluateCurrentUserCompliance()
	logger:info("PlatformAccountLinkingService 已启动。")

	return true
end

function PlatformAccountLinkingService:shutdown()
	PlatformAccountLinkingService.state.initialized = false

	PlatformAccountLinkingService.resetUserBoundState()
end

function PlatformAccountLinkingService:checkAgeGroup()
	if not self:isSupported() or not PlatformAccountLinkingService.isRuntimeReady() or not PlatformAccountLinkingService.bindSignedInUser() then
		PlatformAccountLinkingService.state.userAgeGroup = PlatformAccountLinkingService.AgeGroup.Unknown
		PlatformAccountLinkingService.state.restrictPersonalData = false

		return PlatformAccountLinkingService.state.userAgeGroup
	end

	local ageGroup = PlatformAccountLinkingService.AgeGroup.Unknown

	if PlatformBridgeLuaFacade.GetUserAgeGroup then
		ageGroup = tonumber(PlatformBridgeLuaFacade.GetUserAgeGroup()) or PlatformAccountLinkingService.AgeGroup.Unknown
	end

	PlatformAccountLinkingService.state.userAgeGroup = ageGroup
	PlatformAccountLinkingService.state.restrictPersonalData = ageGroup == PlatformAccountLinkingService.AgeGroup.Child or ageGroup == PlatformAccountLinkingService.AgeGroup.Teen

	return PlatformAccountLinkingService.state.userAgeGroup
end

function PlatformAccountLinkingService:evaluateCurrentUserCompliance()
	if not PlatformAccountLinkingService.bindSignedInUser() then
		return false
	end

	local ageGroup = self:checkAgeGroup()

	logger:info("PlatformAccountLinkingService 合规状态已刷新 ageGroup=%s restrictPersonalData=%s", tostring(ageGroup), tostring(PlatformAccountLinkingService.state.restrictPersonalData))

	return true
end

return PlatformAccountLinkingService
