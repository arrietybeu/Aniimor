-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\CharacterStateConstImp.lua

local CharacterStateConst = {
	[0] = {
		name = "NONE"
	},
	{
		parent = 0,
		name = "LOCOMOTION",
		isStateMachine = true
	},
	{
		parent = 1,
		name = "SPEEDBURST",
		isStateMachine = true
	},
	{
		name = "SPEEDBURSTLOOP",
		parent = 2
	},
	{
		name = "IDLE",
		parent = 1
	},
	{
		name = "RUN",
		parent = 1
	},
	{
		name = "DASH",
		parent = 1
	},
	{
		name = "WALK",
		parent = 1
	},
	{
		name = "SPRINT",
		parent = 1
	},
	{
		name = "TURN",
		parent = 1
	},
	{
		parent = 0,
		name = "AIRING",
		isStateMachine = true
	},
	{
		name = "FALL",
		parent = 10
	},
	{
		name = "GROUNDFALL",
		parent = 10
	},
	{
		name = "JUMP",
		parent = 10
	},
	{
		name = "JUMPINRUN",
		parent = 10
	},
	{
		parent = 0,
		name = "CLIMBING",
		isStateMachine = true
	},
	{
		name = "CLIMBIDLE",
		parent = 15
	},
	{
		name = "CLIMBMOVE",
		parent = 15
	},
	{
		name = "CLIMBON",
		parent = 15
	},
	{
		name = "CLIMBOFF",
		parent = 15
	},
	{
		parent = 0,
		name = "FLYING",
		isStateMachine = true
	},
	{
		name = "FLYHOVER",
		parent = 20
	},
	{
		name = "FLYMOVE",
		parent = 20
	},
	{
		name = "FLYRISE",
		parent = 20
	},
	{
		name = "FLYENDGRAB",
		parent = 20
	},
	{
		name = "FLYSTARTGRAB",
		parent = 20
	},
	{
		parent = 0,
		name = "GLIDING",
		isStateMachine = true
	},
	{
		name = "GLIDEIDLE",
		parent = 26
	},
	{
		name = "GLIDEMOVE",
		parent = 26
	},
	{
		name = "GLIDESTART",
		parent = 26
	},
	{
		parent = 0,
		name = "SWIMMING",
		isStateMachine = true
	},
	{
		name = "SWIMIDLE",
		parent = 30
	},
	{
		name = "SWIMFASTMOVE",
		parent = 30
	},
	{
		name = "SWIMMOVE",
		parent = 30
	},
	{
		name = "SWIMJUMP",
		parent = 30
	},
	{
		parent = 0,
		name = "SNEAK",
		isStateMachine = true
	},
	{
		name = "SNEAKIDLE",
		parent = 35
	},
	{
		name = "SNEAKMOVE",
		parent = 35
	},
	{
		parent = 0,
		name = "MIMICRY",
		isStateMachine = true
	},
	{
		name = "MIMICRYIDLE",
		parent = 38
	},
	{
		parent = 0,
		name = "GROUND",
		isStateMachine = true
	},
	{
		name = "GROUNDIDLE",
		parent = 40
	},
	{
		name = "GROUNDWALK",
		parent = 40
	},
	{
		name = "AIR2GROUND",
		parent = 40
	},
	{
		parent = 0,
		name = "SKATEBOARD",
		isStateMachine = true
	},
	{
		name = "SKATEBOARDMOVE",
		parent = 44
	},
	{
		parent = 0,
		name = "SWIMMIMICRY",
		isStateMachine = true
	},
	{
		name = "SWIMMIMICRYIDLE",
		parent = 46
	},
	{
		parent = 0,
		name = "SPECIALMOVE",
		isStateMachine = true
	},
	{
		name = "SPECIALMOVEFORWARD",
		parent = 48
	},
	{
		name = "SPECIALMOVEIDLE",
		parent = 48
	},
	{
		parent = 0,
		name = "MOUNTING",
		isStateMachine = true
	},
	{
		name = "MOUNT",
		parent = 51
	},
	{
		name = "MOUNTSPECIAL",
		parent = 51
	},
	{
		name = "MOUNTENTER",
		parent = 51
	},
	{
		name = "MOUNTEXIT",
		parent = 51
	},
	{
		parent = 0,
		name = "STORYBEHAVIOR",
		isStateMachine = true
	},
	{
		name = "STORYTURN",
		parent = 56
	},
	{
		parent = 0,
		name = "HIDEMIMICRY",
		isStateMachine = true
	},
	{
		name = "HIDEMIMICRYIDLE",
		parent = 58
	},
	{
		parent = 0,
		name = "STATICSPAWN",
		isStateMachine = true
	},
	{
		name = "STATICSPAWNIDLE",
		parent = 60
	},
	{
		parent = 0,
		name = "PERFORM",
		isStateMachine = true
	},
	{
		name = "PERFORMSTART",
		parent = 62
	},
	{
		name = "PERFORMLOOP",
		parent = 62
	},
	{
		name = "PERFORMEND",
		parent = 62
	},
	{
		name = "LAND",
		parent = 0
	},
	{
		name = "FLYCHARGING",
		parent = 0
	},
	{
		name = "SNEAKIN",
		parent = 0
	},
	{
		name = "SNEAKOUT",
		parent = 0
	},
	{
		name = "SNEAKOUTBYHIT",
		parent = 0
	},
	{
		name = "DEAD",
		parent = 0
	},
	{
		name = "PLAYANIMATIONSCRIPT",
		parent = 0
	},
	{
		name = "GROUNDOUT",
		parent = 0
	},
	{
		name = "GROUNDIN",
		parent = 0
	},
	{
		name = "APPEARDASH",
		parent = 0
	},
	{
		name = "SPECIALDEFENSE",
		parent = 0
	},
	{
		name = "MIMICRYIN",
		parent = 0
	},
	{
		name = "MIMICRYOUT",
		parent = 0
	},
	{
		name = "SWIMMIMICRYIN",
		parent = 0
	},
	{
		name = "SWIMMIMICRYOUT",
		parent = 0
	},
	{
		name = "PATHFINDING",
		parent = 0
	},
	{
		name = "SPECIALMOVEIN",
		parent = 0
	},
	{
		name = "SPECIALMOVEOUT",
		parent = 0
	},
	{
		name = "HIDEMIMICRYIN",
		parent = 0
	},
	{
		name = "HIDEMIMICRYOUT",
		parent = 0
	},
	{
		name = "TAKEROOTIN",
		parent = 0
	},
	{
		name = "TAKEROOT",
		parent = 0
	},
	{
		name = "TAKEROOTOUT",
		parent = 0
	},
	{
		name = "BEGRAB",
		parent = 0
	},
	{
		name = "HOMEWORK",
		parent = 0
	},
	{
		name = "CUSTOMANIMATION",
		parent = 1
	},
	{
		name = "RUNSTOP",
		parent = 1
	},
	{
		name = "SPRINTSTOP",
		parent = 1
	},
	{
		parent = 0,
		name = "CROUCHING",
		isStateMachine = true
	},
	{
		name = "CROUCHIDLE",
		parent = 94
	},
	{
		name = "CROUCHMOVE",
		parent = 94
	},
	{
		name = "CROUCHEXIT",
		parent = 94
	},
	{
		name = "SPEEDBURSTSTART",
		parent = 2
	},
	{
		name = "SPEEDBURSTEND",
		parent = 2
	},
	{
		name = "SPEEDBURSTFALL",
		parent = 2
	},
	{
		name = "SPEEDBURSTJUMP",
		parent = 2
	},
	{
		name = "SPRINTTURN",
		parent = 1
	},
	{
		name = "BOUNCE",
		parent = 10
	},
	{
		name = "CLIMBSLIP",
		parent = 15
	},
	{
		name = "CLIMBDASH",
		parent = 15
	},
	{
		name = "CLIMBSPRINT",
		parent = 15
	},
	{
		name = "FLYDASH",
		parent = 20
	},
	{
		name = "FLYSPRINT",
		parent = 20
	},
	{
		name = "GLIDERISE",
		parent = 26
	},
	{
		name = "SWIMDASH",
		parent = 30
	},
	{
		parent = 0,
		name = "FOURWAY",
		isStateMachine = true
	},
	{
		name = "FOURWAYMOVE",
		parent = 111
	},
	{
		name = "FOURWAYIDLE",
		parent = 111
	},
	{
		parent = 0,
		name = "SKILLMOTION",
		isStateMachine = true
	},
	{
		name = "SKILLMOVE",
		parent = 114
	},
	{
		name = "SKILLJUMP",
		parent = 114
	},
	{
		name = "SKILLJUMPEND",
		parent = 114
	},
	{
		name = "SKILLJUMPFALL",
		parent = 114
	},
	{
		name = "SKILLIDLE",
		parent = 114
	},
	{
		name = "SKILLDASH",
		parent = 114
	},
	{
		parent = 0,
		name = "HOOKSPRINT",
		isStateMachine = true
	},
	{
		name = "HOOKWAIT",
		parent = 121
	},
	{
		name = "HOOKSUCCESS",
		parent = 121
	},
	{
		name = "HOOKSPRINTLOOP",
		parent = 121
	},
	{
		name = "HOOKSUCCESSEND",
		parent = 121
	},
	{
		name = "HOOKFAILLOOP",
		parent = 121
	},
	{
		name = "HOOKFAILEND",
		parent = 121
	},
	{
		name = "HOOKAIM",
		parent = 121
	},
	{
		name = "HOOKSTART",
		parent = 121
	},
	{
		parent = 0,
		name = "SPECIALRIDE",
		isStateMachine = true
	},
	{
		name = "SPECIALRIDECLIMBON",
		parent = 130
	},
	{
		name = "SPECIALRIDEBREAKFAIL",
		parent = 130
	},
	{
		name = "SPECIALRIDEBREAKSUCCESS",
		parent = 130
	},
	{
		name = "SPECIALRIDEIDLE",
		parent = 130
	},
	{
		parent = 0,
		name = "LATERALATTACK",
		isStateMachine = true
	},
	{
		name = "NORMALSTANDATTACK",
		parent = 135
	},
	{
		name = "LEFTSIDEATTACK",
		parent = 135
	},
	{
		name = "RIGHTSIDEATTACK",
		parent = 135
	},
	{
		name = "FRONTSIDEATTACK",
		parent = 135
	},
	{
		name = "BACKSIDEATTACK",
		parent = 135
	},
	{
		parent = 0,
		name = "CLIMBWATERFALL",
		isStateMachine = true
	},
	{
		name = "CLIMBWATERFALLJUMPON",
		parent = 141
	},
	{
		name = "CLIMBWATERFALLIDLE",
		parent = 141
	},
	{
		name = "CLIMBWATERFALLMOVE",
		parent = 141
	},
	{
		name = "CLIMBWATERFALLJUMPOUT",
		parent = 141
	},
	{
		name = "CLIMBWATERFALLJUMPTOP",
		parent = 141
	},
	{
		name = "CLIMBWATERFALLJUMPDASH",
		parent = 141
	},
	{
		name = "SKILL",
		parent = 0
	},
	{
		name = "NORMALATTACK",
		parent = 0
	},
	{
		name = "STRUGGLE",
		parent = 0
	},
	{
		name = "HOOKCANCEL",
		parent = 0
	},
	{
		name = "SKILLGLIDING",
		parent = 0
	},
	{
		name = "SKILLGLIDINGEND",
		parent = 0
	},
	{
		name = "INFLATEDASH",
		parent = 0
	},
	{
		name = "SOCIALANIM",
		parent = 0
	},
	{
		name = "CROUCHTHROWIDLE",
		parent = 94
	},
	{
		name = "CROUCHTHROWMOVE",
		parent = 94
	},
	{
		parent = 0,
		name = "THROWING",
		isStateMachine = true
	},
	{
		name = "THROWWALK",
		parent = 158
	},
	{
		name = "THROWIDLE",
		parent = 158
	},
	{
		parent = 0,
		name = "MAGNESIS",
		isStateMachine = true
	},
	{
		name = "MAGNESISBEGIN",
		parent = 161
	},
	{
		name = "MAGNESISGRABWALK",
		parent = 161
	},
	{
		name = "MAGNESISTHROW",
		parent = 161
	},
	{
		name = "MAGNESISGRABIDLE",
		parent = 161
	},
	{
		parent = 0,
		name = "CLIMBACROSS",
		isStateMachine = true
	},
	{
		name = "CLIMBACROSSSTEPUP",
		parent = 166
	},
	{
		name = "CLIMBACROSSL",
		parent = 166
	},
	{
		name = "CLIMBACROSSH",
		parent = 166
	},
	{
		name = "SKATEBOARDSTART",
		parent = 44
	},
	{
		name = "SKATEBOARDJUMPSTART",
		parent = 44
	},
	{
		name = "SKATEBOARDJUMPFALL",
		parent = 44
	},
	{
		name = "SKATEBOARDJUMPEND",
		parent = 44
	},
	{
		parent = 0,
		name = "DRUMMING",
		isStateMachine = true
	},
	{
		name = "DRUMIDLE",
		parent = 174
	},
	{
		name = "DRUMLEFTHAND",
		parent = 174
	},
	{
		name = "DRUMRIGHTHAND",
		parent = 174
	},
	{
		name = "DRUMLEFTSTOP",
		parent = 174
	},
	{
		name = "DRUMRIGHTSTOP",
		parent = 174
	},
	{
		name = "SKILLEND",
		parent = 114
	},
	{
		name = "SKILLIDLETOMOVE",
		parent = 114
	},
	{
		name = "SKILLMOVETOIDLE",
		parent = 114
	},
	{
		name = "SKILLBEGIN",
		parent = 114
	},
	{
		parent = 0,
		name = "SKILLTHROWING",
		isStateMachine = true
	},
	{
		name = "SKILLTHROWIDLE",
		parent = 184
	},
	{
		name = "SKILLTHROWMOVE",
		parent = 184
	},
	{
		parent = 0,
		name = "WALKINGATTACK",
		isStateMachine = true
	},
	{
		name = "WALKINGATTACKIDLE",
		parent = 187
	},
	{
		name = "WALKINGATTACKMOVE",
		parent = 187
	},
	{
		parent = 0,
		name = "BEGG",
		isStateMachine = true
	},
	{
		name = "BEGGPICK",
		parent = 190
	},
	{
		name = "BEGGIDLE",
		parent = 190
	},
	{
		name = "BEGGRUN",
		parent = 190
	},
	{
		name = "BEGGDROP",
		parent = 190
	},
	{
		name = "BEGGLAND",
		parent = 190
	},
	{
		name = "BEGGFALL",
		parent = 190
	},
	{
		name = "BEGGJUMP",
		parent = 190
	},
	{
		parent = 0,
		name = "FALLEN",
		isStateMachine = true
	},
	{
		name = "FALLENIDLE",
		parent = 198
	},
	{
		name = "FALLENDMOVESTART",
		parent = 198
	},
	{
		name = "FALLENMOVELOOP",
		parent = 198
	},
	{
		name = "FALLENMOVELOOPEND",
		parent = 198
	},
	{
		name = "FALLENSTANDUP",
		parent = 198
	},
	{
		name = "FALLENSTART",
		parent = 198
	},
	{
		name = "FALLENFALL",
		parent = 198
	},
	{
		name = "FALLENFALLTOGROUND",
		parent = 198
	},
	{
		parent = 0,
		name = "AID",
		isStateMachine = true
	},
	{
		name = "AIDSTART",
		parent = 207
	},
	{
		name = "AIDLOOP",
		parent = 207
	},
	{
		name = "AIDEND",
		parent = 207
	},
	{
		parent = 0,
		name = "EGGMODE",
		isStateMachine = true
	},
	{
		name = "EGGMODEIDLE",
		parent = 211
	},
	{
		name = "EGGMODEJUMP",
		parent = 211
	},
	{
		name = "EGGMODEBEATTACHED",
		parent = 211
	},
	{
		parent = 0,
		name = "DIGEGG",
		isStateMachine = true
	},
	{
		name = "DIGEGGSTART",
		parent = 215
	},
	{
		name = "DIGEGGIDLE",
		parent = 215
	},
	{
		name = "DIGEGGACTION",
		parent = 215
	},
	{
		name = "DIGEGGEND",
		parent = 215
	},
	{
		parent = 0,
		name = "CARRY",
		isStateMachine = true
	},
	{
		name = "CARRYSTART",
		parent = 220
	},
	{
		name = "CARRYIDLE",
		parent = 220
	},
	{
		name = "CARRYRUN",
		parent = 220
	},
	{
		name = "CARRYLAND",
		parent = 220
	},
	{
		name = "CARRYFALL",
		parent = 220
	},
	{
		name = "CARRYEND",
		parent = 220
	},
	{
		parent = 0,
		name = "FISHINGCAPTURE",
		isStateMachine = true
	},
	{
		name = "FISHINGCAPTUREIDLE",
		parent = 227
	},
	{
		name = "FISHINGCAPTUREMOVE",
		parent = 227
	},
	{
		name = "REVIVE",
		parent = 0
	},
	{
		name = "NEARDEAD",
		parent = 0
	},
	{
		name = "BEATTACHED",
		parent = 0
	},
	SPECIALRIDEBREAKFAIL = 132,
	SPECIALRIDECLIMBON = 131,
	SPECIALRIDE = 130,
	HOOKSTART = 129,
	HOOKAIM = 128,
	HOOKFAILEND = 127,
	HOOKFAILLOOP = 126,
	HOOKSUCCESSEND = 125,
	HOOKSPRINTLOOP = 124,
	HOOKSUCCESS = 123,
	HOOKWAIT = 122,
	HOOKSPRINT = 121,
	SKILLDASH = 120,
	SKILLIDLE = 119,
	SKILLJUMPFALL = 118,
	SKILLJUMPEND = 117,
	SKILLJUMP = 116,
	SKILLMOVE = 115,
	SKILLMOTION = 114,
	FOURWAYIDLE = 113,
	FOURWAYMOVE = 112,
	FOURWAY = 111,
	SWIMDASH = 110,
	GLIDERISE = 109,
	FLYSPRINT = 108,
	FLYDASH = 107,
	CLIMBSPRINT = 106,
	CLIMBDASH = 105,
	CLIMBSLIP = 104,
	BOUNCE = 103,
	SPRINTTURN = 102,
	SPEEDBURSTJUMP = 101,
	SPEEDBURSTFALL = 100,
	SPEEDBURSTEND = 99,
	SPEEDBURSTSTART = 98,
	CROUCHEXIT = 97,
	CROUCHMOVE = 96,
	CROUCHIDLE = 95,
	CROUCHING = 94,
	SPRINTSTOP = 93,
	RUNSTOP = 92,
	CUSTOMANIMATION = 91,
	HOMEWORK = 90,
	BEGRAB = 89,
	TAKEROOTOUT = 88,
	TAKEROOT = 87,
	TAKEROOTIN = 86,
	HIDEMIMICRYOUT = 85,
	HIDEMIMICRYIN = 84,
	SPECIALMOVEOUT = 83,
	SPECIALMOVEIN = 82,
	PATHFINDING = 81,
	SWIMMIMICRYOUT = 80,
	SWIMMIMICRYIN = 79,
	MIMICRYOUT = 78,
	MIMICRYIN = 77,
	SPECIALDEFENSE = 76,
	APPEARDASH = 75,
	GROUNDIN = 74,
	GROUNDOUT = 73,
	PLAYANIMATIONSCRIPT = 72,
	DEAD = 71,
	SNEAKOUTBYHIT = 70,
	SNEAKOUT = 69,
	SNEAKIN = 68,
	FLYCHARGING = 67,
	LAND = 66,
	PERFORMEND = 65,
	PERFORMLOOP = 64,
	PERFORMSTART = 63,
	PERFORM = 62,
	STATICSPAWNIDLE = 61,
	STATICSPAWN = 60,
	HIDEMIMICRYIDLE = 59,
	HIDEMIMICRY = 58,
	STORYTURN = 57,
	STORYBEHAVIOR = 56,
	MOUNTEXIT = 55,
	MOUNTENTER = 54,
	MOUNTSPECIAL = 53,
	MOUNT = 52,
	MOUNTING = 51,
	SPECIALMOVEIDLE = 50,
	SPECIALMOVEFORWARD = 49,
	SPECIALMOVE = 48,
	SWIMMIMICRYIDLE = 47,
	SWIMMIMICRY = 46,
	SKATEBOARDMOVE = 45,
	SKATEBOARD = 44,
	AIR2GROUND = 43,
	GROUNDWALK = 42,
	GROUNDIDLE = 41,
	GROUND = 40,
	MIMICRYIDLE = 39,
	MIMICRY = 38,
	SNEAKMOVE = 37,
	SNEAKIDLE = 36,
	SNEAK = 35,
	SWIMJUMP = 34,
	SWIMMOVE = 33,
	SWIMFASTMOVE = 32,
	SWIMIDLE = 31,
	SWIMMING = 30,
	GLIDESTART = 29,
	GLIDEMOVE = 28,
	GLIDEIDLE = 27,
	GLIDING = 26,
	FLYSTARTGRAB = 25,
	FLYENDGRAB = 24,
	FLYRISE = 23,
	FLYMOVE = 22,
	FLYHOVER = 21,
	FLYING = 20,
	CLIMBOFF = 19,
	CLIMBON = 18,
	CLIMBMOVE = 17,
	CLIMBIDLE = 16,
	CLIMBING = 15,
	JUMPINRUN = 14,
	JUMP = 13,
	CLIMBACROSS = 166,
	CLIMBACROSSSTEPUP = 167,
	CLIMBACROSSL = 168,
	CLIMBACROSSH = 169,
	SKATEBOARDSTART = 170,
	SKATEBOARDJUMPSTART = 171,
	SKATEBOARDJUMPFALL = 172,
	SKATEBOARDJUMPEND = 173,
	DRUMMING = 174,
	DRUMIDLE = 175,
	DRUMLEFTHAND = 176,
	DRUMRIGHTHAND = 177,
	DRUMLEFTSTOP = 178,
	DIGEGGEND = 219,
	CARRY = 220,
	CARRYSTART = 221,
	CARRYIDLE = 222,
	CARRYRUN = 223,
	CARRYLAND = 224,
	CARRYFALL = 225,
	CARRYEND = 226,
	FISHINGCAPTURE = 227,
	FISHINGCAPTUREIDLE = 228,
	FISHINGCAPTUREMOVE = 229,
	REVIVE = 230,
	NEARDEAD = 231,
	BEATTACHED = 232,
	DIGEGGACTION = 218,
	DIGEGGIDLE = 217,
	DIGEGGSTART = 216,
	DIGEGG = 215,
	EGGMODEBEATTACHED = 214,
	EGGMODEJUMP = 213,
	EGGMODEIDLE = 212,
	EGGMODE = 211,
	AIDEND = 210,
	AIDLOOP = 209,
	AIDSTART = 208,
	AID = 207,
	FALLENFALLTOGROUND = 206,
	FALLENFALL = 205,
	FALLENSTART = 204,
	FALLENSTANDUP = 203,
	FALLENMOVELOOPEND = 202,
	FALLENMOVELOOP = 201,
	FALLENDMOVESTART = 200,
	FALLENIDLE = 199,
	FALLEN = 198,
	BEGGJUMP = 197,
	BEGGFALL = 196,
	BEGGLAND = 195,
	BEGGDROP = 194,
	BEGGRUN = 193,
	BEGGIDLE = 192,
	BEGGPICK = 191,
	BEGG = 190,
	WALKINGATTACKMOVE = 189,
	WALKINGATTACKIDLE = 188,
	WALKINGATTACK = 187,
	SKILLTHROWMOVE = 186,
	SKILLTHROWIDLE = 185,
	SKILLTHROWING = 184,
	SKILLBEGIN = 183,
	SKILLMOVETOIDLE = 182,
	SKILLIDLETOMOVE = 181,
	SKILLEND = 180,
	DRUMRIGHTSTOP = 179,
	GROUNDFALL = 12,
	FALL = 11,
	AIRING = 10,
	TURN = 9,
	SPRINT = 8,
	WALK = 7,
	DASH = 6,
	RUN = 5,
	IDLE = 4,
	SPEEDBURSTLOOP = 3,
	SPEEDBURST = 2,
	LOCOMOTION = 1,
	NONE = 0,
	MAGNESISGRABIDLE = 165,
	MAGNESISTHROW = 164,
	MAGNESISGRABWALK = 163,
	MAGNESISBEGIN = 162,
	MAGNESIS = 161,
	THROWIDLE = 160,
	THROWWALK = 159,
	THROWING = 158,
	CROUCHTHROWMOVE = 157,
	CROUCHTHROWIDLE = 156,
	SOCIALANIM = 155,
	INFLATEDASH = 154,
	SKILLGLIDINGEND = 153,
	SKILLGLIDING = 152,
	HOOKCANCEL = 151,
	STRUGGLE = 150,
	NORMALATTACK = 149,
	SKILL = 148,
	CLIMBWATERFALLJUMPDASH = 147,
	CLIMBWATERFALLJUMPTOP = 146,
	CLIMBWATERFALLJUMPOUT = 145,
	CLIMBWATERFALLMOVE = 144,
	CLIMBWATERFALLIDLE = 143,
	CLIMBWATERFALLJUMPON = 142,
	CLIMBWATERFALL = 141,
	BACKSIDEATTACK = 140,
	FRONTSIDEATTACK = 139,
	RIGHTSIDEATTACK = 138,
	LEFTSIDEATTACK = 137,
	NORMALSTANDATTACK = 136,
	LATERALATTACK = 135,
	SPECIALRIDEIDLE = 134,
	SPECIALRIDEBREAKSUCCESS = 133
}

return CharacterStateConst
