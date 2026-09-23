-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankBase\\Component\\Display\\RankBaseBuffDisplay.lua

local BossRushBuffData = require("Data.bossrush_buff_data")
local RankBaseBuffDisplay = {}

function RankBaseBuffDisplay.renderBattleBuffLayout(objectReference, _, battleBuffInfo)
	if battleBuffInfo == nil or battleBuffInfo.selectBuff == nil then
		return false
	end

	local listPetUList = objectReference:GetRefValue("listPetUList")

	listPetUList.luaRenderItem = RankBaseBuffDisplay.renderBattleBuffIcon
	listPetUList.luaClick = nil
	listPetUList.luaSelectedChanged = nil

	listPetUList:SetList(RankBaseBuffDisplay.createBattleBuffList(battleBuffInfo))

	return true
end

function RankBaseBuffDisplay.createBattleBuffList(battleBuffInfo)
	local buffList = {}

	for gainType, buffId in pairs(battleBuffInfo.selectBuff) do
		buffList[#buffList + 1] = {
			tIndex = 0,
			buffId = buffId,
			gainType = gainType
		}
	end

	table.sort(buffList, RankBaseBuffDisplay.compareBattleBuff)

	return buffList
end

function RankBaseBuffDisplay.compareBattleBuff(left, right)
	return left.gainType < right.gainType
end

function RankBaseBuffDisplay.renderBattleBuffIcon(button, _, buffItem)
	local objectReference = button:GetComponent("ObjectReference")
	local iconBuffUImage = objectReference:GetRefValue("iconBuffUImage")
	local buffData = BossRushBuffData[buffItem.buffId]

	iconBuffUImage.url = buffData.buffIcon
end

return RankBaseBuffDisplay
