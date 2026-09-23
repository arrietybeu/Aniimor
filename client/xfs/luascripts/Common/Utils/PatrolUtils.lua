-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\PatrolUtils.lua

local ACTION_TYPE = require("Common.Const.PatrolConst").ACTION_TYPE
local PatrolUtils = {}
local actionMap = false

function PatrolUtils.createAction(agent, data)
	if not actionMap then
		actionMap = {
			[ACTION_TYPE.Random] = require("Common.AI.BehaviacAgent.Patrol.PatrolRandomAction"),
			[ACTION_TYPE.Wait] = require("Common.AI.BehaviacAgent.Patrol.PatrolWaitAction"),
			[ACTION_TYPE.PlayAnim] = require("Common.AI.BehaviacAgent.Patrol.PatrolAction"),
			[ACTION_TYPE.ShowBubble] = require("Common.AI.BehaviacAgent.Patrol.PatrolAction"),
			[ACTION_TYPE.Sequence] = require("Common.AI.BehaviacAgent.Patrol.PatrolSequenceAction"),
			[ACTION_TYPE.State] = require("Common.AI.BehaviacAgent.Patrol.PatrolStateAction"),
			[ACTION_TYPE.TemplateRef] = require("Common.AI.BehaviacAgent.Patrol.PatrolTemplateAction"),
			[ACTION_TYPE.MoveMode] = require("Common.AI.BehaviacAgent.Patrol.PatrolMoveModeAction"),
			[ACTION_TYPE.PlayAnimGroup] = require("Common.AI.BehaviacAgent.Patrol.PatrolAction")
		}
	end

	return actionMap[data.actionType].new(agent, data)
end

return PatrolUtils
