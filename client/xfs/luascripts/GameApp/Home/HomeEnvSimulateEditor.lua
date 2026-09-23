-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeEnvSimulateEditor.lua

local Class = require("Core.Framework.Class")
local HomelandEnvManager = require("Common.Homeland.HomelandEnvManager")
local OrnamentAllData = require("CustomTypes.OrnamentAllData")
local HomeEnvSimulateEditor = Class.LiteClass("HomeEnvSimulateEditor")
local HomeLinkMap = require("CustomTypes.HomeLinkMap")
local OrnamentSingleData = require("CustomTypes.OrnamentSingleData")
local HomeLinkGroupMap = require("CustomTypes.HomeLinkGroupMap")
local OrnamentEnvMap = require("CustomTypes.OrnamentEnvMap")
local HomeEnvMap = require("CustomTypes.HomeEnvMap")
local Utils = require("Common.Utils.Utils")

function HomeEnvSimulateEditor:ctor(owner)
	self.owner = owner
	self.envManager = HomelandEnvManager.new(true)

	function self.envManager.linkChangeCallback()
		self:onEnvLinkChange()
	end

	self.isValid = false
end

function HomeEnvSimulateEditor:init(space)
	self.ornament = OrnamentAllData.new({})

	for ornamentId, ornamentInfo in pairs(space.ornament) do
		if Utils.getHomeFacilityType(ornamentInfo.homeId) then
			self.ornament[ornamentId] = OrnamentSingleData(ornamentInfo)
		end
	end

	self.homeEnvMap = HomeEnvMap(space.homeEnvMap)
	self.ornamentEnvMap = OrnamentEnvMap(space.ornamentEnvMap)
	self.homeLinkMap = HomeLinkMap(space.homeLinkMap)
	self.homeLinkGroupMap = HomeLinkGroupMap(space.homeLinkGroupMap)

	self.envManager:init(nil, self.ornament, self.homeEnvMap, self.ornamentEnvMap, self.homeLinkMap, self.homeLinkGroupMap)

	self.isValid = true
end

function HomeEnvSimulateEditor:clear()
	self.envManager:clear()

	self.ornament = nil
	self.homeEnvMap = nil
	self.ornamentEnvMap = nil
	self.homeLinkMap = nil
	self.homeLinkGroupMap = nil
	self.isValid = false
end

function HomeEnvSimulateEditor:updateEnvInfo()
	if not self.isValid then
		return
	end

	self.envManager:updateEnvInfo()
end

function HomeEnvSimulateEditor:addOrnament(ornamentId, ornamentInfo)
	if not self.isValid then
		return false
	end

	if Utils.getHomeFacilityType(ornamentInfo.homeId) then
		self.ornament[ornamentId] = ornamentInfo

		self.envManager:onOrnamentAdd(ornamentId, ornamentInfo)
	end
end

function HomeEnvSimulateEditor:removeOrnament(ornamentId)
	if not self.isValid then
		return false
	end

	local ornamentInfo = self.ornament[ornamentId]

	if ornamentInfo then
		self.ornament[ornamentId] = nil

		self.envManager:onOrnamentRemove(ornamentId, ornamentInfo)
	end
end

function HomeEnvSimulateEditor:updateOrnament(ornamentId, ornamentInfo)
	if not self.isValid then
		return false
	end

	if self.ornament[ornamentId] ~= nil then
		self.ornament[ornamentId] = ornamentInfo

		self.envManager:onOrnamentPosChange(ornamentId, ornamentInfo)
	end
end

function HomeEnvSimulateEditor:onEnvLinkChange()
	if self.owner then
		self.owner:onEnvLinkChange()
	end
end

return HomeEnvSimulateEditor
