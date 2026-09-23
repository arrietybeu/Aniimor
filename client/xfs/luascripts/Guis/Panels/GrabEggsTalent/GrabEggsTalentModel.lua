-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsTalent\\GrabEggsTalentModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsTalentModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local TalentTreeData = require("Data.rob_egg_talent_data")
local ItemConst = require("Common.Const.ItemConst")
local SLOTS_PER_LINE = 3
local LINE_COUNT = 3
local NODE_STATE = {
	DISABLED_BROADCAST = "disabled-broadcast",
	UNLOCKABLE = "unlockable",
	UNLOCKED = "unlocked",
	LOCKED = "locked"
}
local FAIL_REASON = {
	ITEM = "item",
	COIN = "coin",
	STATE = "state"
}
local GrabEggsTalentModel = Class.LightClass("GrabEggsTalentModel", UIModel)

GrabEggsTalentModel.NODE_STATE = NODE_STATE
GrabEggsTalentModel.FAIL_REASON = FAIL_REASON
GrabEggsTalentModel.SLOTS_PER_LINE = SLOTS_PER_LINE
GrabEggsTalentModel.LINE_COUNT = LINE_COUNT

function GrabEggsTalentModel:ctor()
	self._redDotRead = {}

	self:_buildIndex()
end

function GrabEggsTalentModel:_isUnlocked(id)
	return pg.me ~= nil and pg.me:getTalentIsUnlockByTalentId(id)
end

function GrabEggsTalentModel:_buildIndex()
	self._nodesByLine = {}
	self._nodeByPos = {}
	self._maxRow = 0

	for id, cfg in pairs(TalentTreeData) do
		local lineId = cfg.type
		local row = cfg.position and cfg.position[1] or 1

		self._nodesByLine[lineId] = self._nodesByLine[lineId] or {}

		table.insert(self._nodesByLine[lineId], id)

		if row > self._maxRow then
			self._maxRow = row
		end

		local lineCol = (cfg.position[2] - 1) % SLOTS_PER_LINE + 1

		self._nodeByPos[lineId] = self._nodeByPos[lineId] or {}
		self._nodeByPos[lineId][row] = self._nodeByPos[lineId][row] or {}
		self._nodeByPos[lineId][row][lineCol] = id
	end
end

function GrabEggsTalentModel:_isNodeAt(lineId, row, lineCol)
	local byLine = self._nodeByPos[lineId]

	if not byLine then
		return false
	end

	local byRow = byLine[row]

	if not byRow then
		return false
	end

	return byRow[lineCol] ~= nil
end

function GrabEggsTalentModel:_routeStyle(lineId, pRow, pLineCol, nRow, nLineCol)
	if nRow - pRow <= 1 then
		return "A"
	end

	local nColClean, pColClean = true, true

	for midRow = pRow + 1, nRow - 1 do
		if self:_isNodeAt(lineId, midRow, nLineCol) then
			nColClean = false
		end

		if self:_isNodeAt(lineId, midRow, pLineCol) then
			pColClean = false
		end
	end

	if nColClean then
		return "A"
	end

	if pColClean then
		return "B"
	end

	return "A"
end

function GrabEggsTalentModel:getNodeConfig(id)
	return TalentTreeData[id]
end

function GrabEggsTalentModel:isLineOpen(lineId)
	local ids = self._nodesByLine[lineId]

	return ids ~= nil and #ids > 0
end

function GrabEggsTalentModel:getMaxRow()
	return self._maxRow
end

function GrabEggsTalentModel:getRowIndexByTalentId(id)
	local cfg = TalentTreeData[id]

	if not cfg or not cfg.position then
		return nil
	end

	local row = cfg.position[1]
	local lineId = cfg.type
	local lineCol = (cfg.position[2] - 1) % SLOTS_PER_LINE + 1
	local rowIdx = (row - 1) * LINE_COUNT + lineId

	return rowIdx, lineCol
end

function GrabEggsTalentModel:getRows()
	local rows = {}

	for r = 1, self._maxRow do
		for l = 1, LINE_COUNT do
			local slots = {}

			for s = 1, SLOTS_PER_LINE do
				slots[s] = {
					empty = true,
					tIndex = 1
				}
			end

			rows[(r - 1) * LINE_COUNT + l] = {
				lineId = l,
				row = r,
				slots = slots
			}
		end
	end

	for id, cfg in pairs(TalentTreeData) do
		local pos = cfg.position

		if pos then
			local row, globalCol = pos[1], pos[2]
			local lineId = cfg.type
			local lineCol = (globalCol - 1) % SLOTS_PER_LINE + 1
			local rowIdx = (row - 1) * LINE_COUNT + lineId
			local prereq = cfg.prerequisite

			rows[rowIdx].slots[lineCol] = {
				id = id,
				row = row,
				col = lineCol,
				config = cfg,
				state = self:getNodeState(id),
				tIndex = cfg.Rarity or 1,
				hasPrereq = prereq ~= nil and #prereq > 0,
				prereqMet = self:_arePrerequisitesMet(cfg)
			}
		end
	end

	for id, cfg in pairs(TalentTreeData) do
		local pos = cfg.position
		local prereq = cfg.prerequisite

		if pos and prereq then
			local nRow = pos[1]
			local nLineCol = (pos[2] - 1) % SLOTS_PER_LINE + 1
			local lineId = cfg.type

			for _, preId in ipairs(prereq) do
				local preCfg = TalentTreeData[preId]

				if preCfg and preCfg.position then
					local pRow = preCfg.position[1]
					local pLineCol = (preCfg.position[2] - 1) % SLOTS_PER_LINE + 1

					if nRow - pRow > 1 then
						local style = self:_routeStyle(lineId, pRow, pLineCol, nRow, nLineCol)
						local throughCol = style == "B" and pLineCol or nLineCol
						local preUnlocked = self:_isUnlocked(preId)

						for midRow = pRow + 1, nRow - 1 do
							local midSlot = rows[(midRow - 1) * LINE_COUNT + lineId].slots[throughCol]

							if midSlot.empty then
								midSlot.tIndex = 0
								midSlot.lineThrough = true
								midSlot.lineThroughUnlocked = preUnlocked
							end
						end
					end
				end
			end
		end
	end

	return rows
end

function GrabEggsTalentModel:getNodeState(id)
	local cfg = TalentTreeData[id]

	if not cfg then
		return NODE_STATE.LOCKED
	end

	if cfg.isBroadcast == 1 then
		return NODE_STATE.DISABLED_BROADCAST
	end

	if self:_isUnlocked(id) then
		return NODE_STATE.UNLOCKED
	end

	if self:_arePrerequisitesMet(cfg) then
		return NODE_STATE.UNLOCKABLE
	end

	return NODE_STATE.LOCKED
end

function GrabEggsTalentModel:_arePrerequisitesMet(cfg)
	local preList = cfg.prerequisite

	if not preList or #preList == 0 then
		return true
	end

	for _, preId in ipairs(preList) do
		if not self:_isUnlocked(preId) then
			return false
		end
	end

	return true
end

function GrabEggsTalentModel:canUnlock(id)
	local state = self:getNodeState(id)

	if state ~= NODE_STATE.UNLOCKABLE then
		return false, FAIL_REASON.STATE
	end

	local cfg = TalentTreeData[id]

	if (cfg.baseCost or 0) > pg.me:getMoneyNum(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG) then
		return false, FAIL_REASON.COIN
	end

	for _, pair in ipairs(cfg.itemCost or EMPTY_TABLE) do
		local itemId, count = pair[1], pair[2]

		if count > pg.me:getItemCountById(itemId) then
			return false, FAIL_REASON.ITEM
		end
	end

	return true, nil
end

function GrabEggsTalentModel:tryUnlock(id)
	local ok, reason = self:canUnlock(id)

	if not ok then
		return false, reason
	end

	pg.me:serverMsg("RPC_CS_UnlockRobEggTalent", id)

	self._redDotRead[id] = nil

	return true, nil
end

local LINE_KEY = {
	{
		[1] = "leftLine02",
		[2] = "leftLine01"
	},
	{
		"midLine01",
		"midLine02",
		"midLine03"
	},
	{
		[2] = "rightLine01",
		[3] = "rightLine02"
	}
}
local LINE_KEYS = {
	"leftLine01",
	"leftLine02",
	"midLine01",
	"midLine02",
	"midLine03",
	"rightLine01",
	"rightLine02"
}

GrabEggsTalentModel.LINE_KEYS = LINE_KEYS

function GrabEggsTalentModel:getRowLines(lineId, row)
	local result = {}

	for _, key in ipairs(LINE_KEYS) do
		result[key] = {
			show = false
		}
	end

	for id, cfg in pairs(TalentTreeData) do
		if cfg.type == lineId and cfg.position and cfg.prerequisite then
			local nRow = cfg.position[1]
			local nLineCol = (cfg.position[2] - 1) % SLOTS_PER_LINE + 1

			for _, preId in ipairs(cfg.prerequisite) do
				local preCfg = TalentTreeData[preId]

				if preCfg and preCfg.position then
					local pRow = preCfg.position[1]
					local pLineCol = (preCfg.position[2] - 1) % SLOTS_PER_LINE + 1
					local preUnlocked = self:_isUnlocked(preId)
					local style = self:_routeStyle(lineId, pRow, pLineCol, nRow, nLineCol)
					local key

					if pRow == row then
						local childCol = style == "B" and nRow - pRow > 1 and pLineCol or nLineCol

						key = LINE_KEY[pLineCol] and LINE_KEY[pLineCol][childCol]
					elseif pRow < row and row < nRow then
						if style == "B" then
							local childCol = row == nRow - 1 and nLineCol or pLineCol

							key = LINE_KEY[pLineCol] and LINE_KEY[pLineCol][childCol]
						else
							key = LINE_KEY[nLineCol] and LINE_KEY[nLineCol][nLineCol]
						end
					end

					if key then
						result[key] = {
							show = true,
							unlocked = preUnlocked
						}
					end
				end
			end
		end
	end

	return result
end

function GrabEggsTalentModel:getLineProgress(lineId)
	local ids = self._nodesByLine[lineId] or {}
	local total = #ids
	local unlocked = 0

	for _, id in ipairs(ids) do
		if self:_isUnlocked(id) then
			unlocked = unlocked + 1
		end
	end

	return {
		unlocked = unlocked,
		total = total
	}
end

function GrabEggsTalentModel:nodeShowRedDot(id)
	if self._redDotRead[id] then
		return false
	end

	local ok = self:canUnlock(id)

	return ok
end

function GrabEggsTalentModel:lineHasRedDot(lineId)
	if not self:isLineOpen(lineId) then
		return false
	end

	for _, id in ipairs(self._nodesByLine[lineId] or EMPTY_TABLE) do
		if self:nodeShowRedDot(id) then
			return true
		end
	end

	return false
end

function GrabEggsTalentModel:markNodeRedDotRead(id)
	self._redDotRead[id] = true
end

function GrabEggsTalentModel:getCoinCount()
	return pg.me:getMoneyNum(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG)
end

function GrabEggsTalentModel:getItemCount(itemId)
	return pg.me:getItemCountById(itemId)
end

return GrabEggsTalentModel
