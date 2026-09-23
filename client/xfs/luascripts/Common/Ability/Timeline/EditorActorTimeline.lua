-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Timeline\\EditorActorTimeline.lua

local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local EditorActionTimeline = require("Common.Ability.Timeline.EditorActionTimeline")
local ActorTimeline = require("Common.Ability.Timeline.ActorTimeline")
local CombatLogger = require("Common.Ability.CombatLogger")
local EditorActorTimeline = Class.LiteClass("EditorActorTimeline", ActorTimeline)
local pg = pg
local ToBool = ToBool

function EditorActorTimeline:ctor(owner)
	self.owner = owner
	self.baseTimeline = EditorActionTimeline(owner, AbilityConst.ACTION_TIMELINE_LAYER_BASE)
	self.additiveTimeline = EditorActionTimeline(owner, AbilityConst.ACTION_TIMELINE_LAYER_ADDITIVE)
	self.parallelTimelines = {}
end

return EditorActorTimeline
