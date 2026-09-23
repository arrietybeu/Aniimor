-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeEditorOutline.lua

local AddressDataConst = require("Const.AddressDataConst")
local HomeEditorOutline = {}

HomeEditorOutline.OUTLINE_COLOR_SLOT = {
	[AddressDataConst.HOMELAND_OUTLINE_RED] = 1,
	[AddressDataConst.HOMELAND_OUTLINE_GREEN] = 3,
	[AddressDataConst.HOMELAND_OUTLINE_ELECTRIC] = 5,
	[AddressDataConst.HOMELAND_OUTLINE_FIRE] = 6,
	[AddressDataConst.HOMELAND_OUTLINE_ICE] = 7,
	[AddressDataConst.HOMELAND_OUTLINE_LIGHT] = 8
}
HomeEditorOutline.OUTLINE_COLOR_PRIORITY = {
	[AddressDataConst.HOMELAND_OUTLINE_RED] = 2
}
HomeEditorOutline.DEFAULT_COLOR_PRIORITY = 1
HomeEditorOutline.NO_COLOR_SLOT = 0
HomeEditorOutline.entityColors = {}
HomeEditorOutline.colorRefCount = {}
HomeEditorOutline.curColorSlot = HomeEditorOutline.NO_COLOR_SLOT
HomeEditorOutline.isMobileMode = nil

function HomeEditorOutline.checkMobileMode()
	if HomeEditorOutline.isMobileMode == nil then
		HomeEditorOutline.isMobileMode = pg.global.homelandMgr:IsMobileHomeOutline()
	end

	return HomeEditorOutline.isMobileMode
end

function HomeEditorOutline.setEntityOutlineColor(entity, materialId)
	local entityColors = HomeEditorOutline.entityColors
	local lastMaterialId = entityColors[entity]

	if lastMaterialId == materialId then
		return
	end

	entityColors[entity] = materialId

	local colorRefCount = HomeEditorOutline.colorRefCount

	if lastMaterialId then
		local count = (colorRefCount[lastMaterialId] or 1) - 1

		colorRefCount[lastMaterialId] = count > 0 and count or nil
	end

	if materialId then
		colorRefCount[materialId] = (colorRefCount[materialId] or 0) + 1
	end

	HomeEditorOutline.refreshGlobalColor()
end

function HomeEditorOutline.refreshGlobalColor()
	local bestSlot = HomeEditorOutline.NO_COLOR_SLOT
	local bestPriority

	for materialId, _ in pairs(HomeEditorOutline.colorRefCount) do
		local slot = HomeEditorOutline.OUTLINE_COLOR_SLOT[materialId]

		if slot then
			local priority = HomeEditorOutline.OUTLINE_COLOR_PRIORITY[materialId] or HomeEditorOutline.DEFAULT_COLOR_PRIORITY

			if not bestPriority or bestPriority < priority or priority == bestPriority and slot < bestSlot then
				bestPriority = priority
				bestSlot = slot
			end
		end
	end

	if HomeEditorOutline.curColorSlot == bestSlot then
		return
	end

	HomeEditorOutline.curColorSlot = bestSlot

	pg.global.homelandMgr:SetHomeOutlineColorSlot(bestSlot)
end

function HomeEditorOutline.onVolumeLoaded(effectItem)
	if not effectItem or IsNil(effectItem.effectObj) then
		return
	end

	pg.global.homelandMgr:BindHomeOutlineVolume(effectItem.effectObj)
end

function HomeEditorOutline.onVolumeReleased()
	pg.global.homelandMgr:UnbindHomeOutlineVolume()
end

return HomeEditorOutline
