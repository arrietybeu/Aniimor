-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\ActorConst.lua

local ActorConst = {
	ACTOR_RELATION_SELF = 1,
	ACTOR_RELATION_PARTNER = 3,
	ACTOR_RELATION_ENEMY = 2
}

ActorConst.ACTOR_RELATION_PARSER = {
	self = ActorConst.ACTOR_RELATION_SELF,
	enemy = ActorConst.ACTOR_RELATION_ENEMY,
	partner = ActorConst.ACTOR_RELATION_PARTNER
}

return ActorConst
