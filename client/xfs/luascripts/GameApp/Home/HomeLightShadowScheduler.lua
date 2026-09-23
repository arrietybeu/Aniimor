-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeLightShadowScheduler.lua

local Class = require("Core.Framework.Class")
local HomeObjectData = require("Data.home_object_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeLightShadowScheduler = Class.LiteClass("HomeLightShadowScheduler")

HomeLightShadowScheduler.LIGHT_SUB_TYPE = 411

function HomeLightShadowScheduler:ctor()
	self.lights = {}
	self.tempList = {}
	self.lastPx = nil
	self.lastPz = nil
	self.dirty = false
end

function HomeLightShadowScheduler:register(ornamentId, ent)
	if not ornamentId or ornamentId == 0 then
		return
	end

	local cfg = HomeObjectData[ent.homeTemplateId]

	if not cfg or cfg.subType ~= HomeLightShadowScheduler.LIGHT_SUB_TYPE then
		return
	end

	local modelGo = ent.eModel and ent.eModel.itemModel

	if not modelGo then
		return
	end

	local minIntensity = HomelandConfigData.shadowLightMinIntensity or 20

	if not pg.global.homelandMgr:HasManagedPointLight(modelGo, minIntensity) then
		return
	end

	local originalShadowMask = pg.global.homelandMgr:GetOrnamentLightShadowMask(modelGo, minIntensity)
	local pos = ent:getPosition()

	self.lights[ornamentId] = {
		sqrDist = 0,
		band = 0,
		ent = ent,
		modelGo = modelGo,
		minIntensity = minIntensity,
		originalShadowMask = originalShadowMask,
		priority = cfg.shadowLightPriority or 0,
		px = pos and pos[1] or 0,
		pz = pos and pos[3] or 0
	}
	self.dirty = true
end

function HomeLightShadowScheduler:unregister(ornamentId)
	local info = self.lights[ornamentId]

	if info then
		self:restoreShadow(info)

		self.lights[ornamentId] = nil
		self.dirty = true
	end
end

function HomeLightShadowScheduler:onLightMoved(ornamentId)
	local info = self.lights[ornamentId]

	if info then
		local pos = info.ent:getPosition()

		if pos then
			info.px, info.pz = pos[1], pos[3]
		end

		self.dirty = true
	end
end

function HomeLightShadowScheduler:markDirty()
	self.dirty = true
end

function HomeLightShadowScheduler:getPlatformConfig()
	local setting = pg.game.setting
	local platform = setting.curPlatform
	local q = setting:getVideoQuality()

	if setting.isConsolePlatform and setting:isConsolePlatform() then
		platform, q = setting:getVideoSettingPlatformAndIndex(q)
	end

	local countCfg = HomelandConfigData.shadowLightMaxCount
	local distCfg = HomelandConfigData.shadowLightDistance
	local countArr = countCfg and countCfg[platform]
	local distArr = distCfg and distCfg[platform]
	local maxCount = countArr and (countArr[q] or countArr[#countArr]) or 8
	local distance = distArr and (distArr[q] or distArr[#distArr]) or 30

	return maxCount, distance
end

function HomeLightShadowScheduler.compareLights(a, b)
	if a.band ~= b.band then
		return a.band < b.band
	end

	if a.priority ~= b.priority then
		return a.priority > b.priority
	end

	return a.sqrDist < b.sqrDist
end

function HomeLightShadowScheduler:update(playerPos)
	if not playerPos then
		return
	end

	if next(self.lights) == nil then
		return
	end

	if not pg.game.setting:getCommonVideoSettingValue("supportPunctualShadow") then
		return
	end

	local px, pz = playerPos[1], playerPos[3]

	if not self.dirty and self.lastPx then
		local moveThreshold = HomelandConfigData.shadowLightMoveThreshold or 0.5
		local ddx, ddz = px - self.lastPx, pz - self.lastPz

		if ddx * ddx + ddz * ddz < moveThreshold * moveThreshold then
			return
		end
	end

	self.dirty = false
	self.lastPx, self.lastPz = px, pz

	local maxCount, distance = self:getPlatformConfig()
	local sqrThreshold = distance * distance
	local bandWidth = HomelandConfigData.shadowLightBandWidth or 8
	local candidates = self.tempList

	table.clear(candidates)

	for _, info in pairs(self.lights) do
		local ent = info.ent
		local isOpen = ent.isOrnamentSwitchOpen and ent:isOrnamentSwitchOpen()

		if isOpen then
			local dx, dz = info.px - px, info.pz - pz
			local sqrDist = dx * dx + dz * dz

			if sqrThreshold < sqrDist then
				self:applyShadow(info, false)
			else
				info.sqrDist = sqrDist
				info.band = math.floor(math.sqrt(sqrDist) / bandWidth)
				candidates[#candidates + 1] = info
			end
		else
			self:applyShadow(info, false)
		end
	end

	local n = #candidates

	if n <= maxCount then
		for i = 1, n do
			self:applyShadow(candidates[i], true)
		end

		return
	end

	table.sort(candidates, HomeLightShadowScheduler.compareLights)

	for i = 1, n do
		self:applyShadow(candidates[i], i <= maxCount)
	end
end

function HomeLightShadowScheduler:applyShadow(info, enable)
	if info.shadowOn == enable then
		return
	end

	local minIntensity = info.minIntensity or HomelandConfigData.shadowLightMinIntensity or 20

	pg.global.homelandMgr:SetOrnamentLightShadow(info.modelGo, enable, minIntensity)

	info.shadowOn = enable
end

function HomeLightShadowScheduler:restoreShadow(info)
	if not info then
		return
	end

	local minIntensity = info.minIntensity or HomelandConfigData.shadowLightMinIntensity or 20

	pg.global.homelandMgr:RestoreOrnamentLightShadow(info.modelGo, info.originalShadowMask or 0, minIntensity)

	info.shadowOn = nil
end

function HomeLightShadowScheduler:clear()
	for _, info in pairs(self.lights) do
		self:restoreShadow(info)
	end

	table.clear(self.lights)
	table.clear(self.tempList)

	self.lastPx = nil
	self.lastPz = nil
	self.dirty = false
end

return HomeLightShadowScheduler
