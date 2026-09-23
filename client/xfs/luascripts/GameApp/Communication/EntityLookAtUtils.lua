-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\EntityLookAtUtils.lua

local NpcDialogueData = require("Data.npc_dialogue_data")
local M = {}
local operateCnt = 0
local operateQueue = {}
local PRIORITY = {
	MANUAL = 2,
	AUTO = 1
}
local lookAtEntitySet = {}
local currentLookAtSet = {}
local lastManualFadeTime = 0.5

local function _setLookAtEntity(srcEnt, destEnt, priority)
	if srcEnt == nil or destEnt == nil then
		return
	end

	local set = lookAtEntitySet[srcEnt.id]

	if set == nil then
		set = {}
		lookAtEntitySet[srcEnt.id] = set
	end

	set[priority] = destEnt.id
end

local function _removeLookAtEntity(srcEnt, priority)
	if srcEnt == nil then
		return
	end

	local set = lookAtEntitySet[srcEnt.id]

	if set ~= nil then
		set[priority] = nil
	end
end

function M.setLookAtDialogue(srcEnt, destEnt)
	if srcEnt == nil or destEnt == nil then
		return
	end

	_setLookAtEntity(srcEnt, destEnt, PRIORITY.AUTO)

	operateCnt = operateCnt + 1
	operateQueue[operateCnt] = srcEnt.id
end

function M.removeLookAtDialogue(srcEnt)
	_removeLookAtEntity(srcEnt, PRIORITY.AUTO)

	operateCnt = operateCnt + 1
	operateQueue[operateCnt] = srcEnt.id
end

function M.setLookAtManual(srcEnt, destEnt)
	if srcEnt == nil or destEnt == nil then
		return
	end

	_setLookAtEntity(srcEnt, destEnt, PRIORITY.MANUAL)

	operateCnt = operateCnt + 1
	operateQueue[operateCnt] = srcEnt.id
end

function M.removeLookAtManual(srcEnt, fadeTime)
	if srcEnt == nil then
		return
	end

	if fadeTime ~= nil then
		lastManualFadeTime = fadeTime
	end

	_removeLookAtEntity(srcEnt, PRIORITY.MANUAL)

	operateCnt = operateCnt + 1
	operateQueue[operateCnt] = srcEnt.id
end

function M.clearAutoPriority()
	for src_id, slot in pairs(lookAtEntitySet) do
		if slot[PRIORITY.AUTO] ~= nil then
			slot[PRIORITY.AUTO] = nil
			operateCnt = operateCnt + 1
			operateQueue[operateCnt] = src_id
		end
	end
end

function M.clearManualPriority()
	for src_id, slot in pairs(lookAtEntitySet) do
		if slot[PRIORITY.MANUAL] ~= nil then
			slot[PRIORITY.MANUAL] = nil
			operateCnt = operateCnt + 1
			operateQueue[operateCnt] = src_id
		end
	end
end

function M.clearAll()
	local fadeTime = lastManualFadeTime

	for src_id, _ in pairs(currentLookAtSet) do
		if src_id ~= nil then
			local srcEnt = pg.getEntity(src_id)

			if srcEnt ~= nil and srcEnt.cancelLookAtRole ~= nil then
				srcEnt:cancelLookAtRole(fadeTime)
			end
		end
	end

	currentLookAtSet = {}
	lookAtEntitySet = {}
	operateQueue = {}
	operateCnt = 0
end

function M.doModifyLookAt()
	local cnt = operateCnt

	operateCnt = 0

	local fadeTime = lastManualFadeTime

	for i = 1, cnt do
		local src_id = operateQueue[i]

		operateQueue[i] = nil

		local old_dest_id = currentLookAtSet[src_id]
		local destSet = lookAtEntitySet[src_id]
		local dest_id

		if destSet ~= nil then
			dest_id = destSet[PRIORITY.MANUAL]

			if dest_id == nil then
				dest_id = destSet[PRIORITY.AUTO]
			end
		end

		if old_dest_id ~= dest_id then
			currentLookAtSet[src_id] = dest_id

			local srcEnt = pg.getEntity(src_id)

			if srcEnt ~= nil then
				local destEntity = pg.getEntity(dest_id)

				if destEntity ~= nil then
					if srcEnt.lookAtRole then
						srcEnt:lookAtRole(destEntity)
					end
				elseif srcEnt.cancelLookAtRole then
					srcEnt:cancelLookAtRole(fadeTime)
				end
			end
		end
	end
end

function M.getLookAtEntity(srcEnt)
	if srcEnt == nil then
		return nil
	end

	return currentLookAtSet[srcEnt.id]
end

function M.checkNow()
	local entitySet = {}

	for src_id, descSet in pairs(lookAtEntitySet) do
		local t = {}

		for pri, dest_id in pairs(descSet) do
			table.insert(t, string.format("['%s'] = %s", pri, dest_id))
		end

		table.insert(entitySet, string.format("['%s'] = {%s}", src_id, table.concat(t, ", ")))
	end

	local currSet = {}

	for src_id, dest_id in pairs(currentLookAtSet) do
		table.insert(currSet, string.format("['%s'] = %s", src_id, dest_id))
	end

	print(string.format("EntityLookAtUtils\ncurrentLookAtSet = {\n%s\n}\nlookAtEntitySet{\n%s\n}", table.concat(currSet, ",\n"), table.concat(entitySet, ", \n")))
end

return M
