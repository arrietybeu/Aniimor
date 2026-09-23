-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\HomeCampConst.lua

local HomeCampConst = {}

HomeCampConst.INITIAL_OWNER_EPOCH = 1
HomeCampConst.DEFAULT_TENANT_KEY = "default"
HomeCampConst.DEFAULT_BUCKET_COUNT = 128
HomeCampConst.DISPLAY_CODE_VERSION = 2
HomeCampConst.IDSTR_LENGTH = 8
HomeCampConst.DISPLAY_SEQ_BATCH_SIZE = 100
HomeCampConst.LINEUID_SEQ_BATCH_SIZE = 100
HomeCampConst.DEFAULT_MAX_LOGIN = 6
HomeCampConst.DEFAULT_MAX_ENTER = 10
HomeCampConst.RECOMMEND_BAND = {
	{
		name = "high",
		quota = 4,
		minLogin = 5
	},
	{
		name = "mid",
		quota = 7,
		minLogin = 3
	},
	{
		name = "low",
		quota = 7,
		minLogin = 1
	},
	{
		name = "empty",
		quota = 2,
		minLogin = 0,
		maxQuota = 4
	}
}
HomeCampConst.HEARTBEAT_CHECK_INTERVAL = 60
HomeCampConst.HEARTBEAT_TIMEOUT = 300
HomeCampConst.ENTER_HEARTBEAT_INTERVAL = 120
HomeCampConst.ENTER_HEARTBEAT_TIMEOUT = 600
HomeCampConst.ENTER_HEARTBEAT_CHECK_INTERVAL = 120
HomeCampConst.OFFLINE_CHECK_INTERVAL = 60
HomeCampConst.DIRECTORY_SYNC_INTERVAL = 30
HomeCampConst.MONGO_FLUSH_INTERVAL = 5
HomeCampConst.BUCKET_SNAPSHOT_INTERVAL = 30
HomeCampConst.LINEUID_VER_BITS = 4
HomeCampConst.LINEUID_AREA_BITS = 8
HomeCampConst.LINEUID_BUCKET_BITS = 8
HomeCampConst.LINEUID_SEQ_BITS = 32
HomeCampConst.LINEUID_VERSION = 1
HomeCampConst.MAX_LINE_ID_SEQ = 2^HomeCampConst.LINEUID_SEQ_BITS
HomeCampConst.SOFT_LIMIT_LINE_ID_SEQ = math.floor(HomeCampConst.MAX_LINE_ID_SEQ * 0.9)
HomeCampConst.LINEUID_SEQ_SHIFT = 0
HomeCampConst.LINEUID_BUCKET_SHIFT = 32
HomeCampConst.LINEUID_AREA_SHIFT = 40
HomeCampConst.LINEUID_VER_SHIFT = 48
HomeCampConst.LINEUID_SEQ_MASK = 4294967295
HomeCampConst.LINEUID_BUCKET_MASK = 255
HomeCampConst.LINEUID_AREA_MASK = 255
HomeCampConst.LINEUID_VER_MASK = 15
HomeCampConst.MONGO_COLLECTION_LINE_META = "homecamp_line_meta"
HomeCampConst.MONGO_COLLECTION_BUCKET_RECOVERY = "homecamp_bucket_recovery"
HomeCampConst.MONGO_COLLECTION_ALLOC = "homecamp_alloc"
HomeCampConst.MONGO_COLLECTION_AUDIT = "homecamp_line_audit"
HomeCampConst.PERM_ALLOW_MEMBER_INVITE = 1
HomeCampConst.PERM_ALLOW_DECORATION_EDIT = 2
HomeCampConst.PERM_ALLOW_RANDOM_JOIN = 4
HomeCampConst.PERM_VALID_MASK = 7
HomeCampConst.DEFAULT_PRIVATE_PERMISSIONS = 3
HomeCampConst.INVITE_CARD_EXPIRE_SECONDS = 300
HomeCampConst.INVITE_CLEANUP_INTERVAL = 60
HomeCampConst.INVITE_MAX_PER_INVITER = 10
HomeCampConst.LINE_STATUS_ACTIVE = "active"
HomeCampConst.LINE_STATUS_LOCKED = "locked"
HomeCampConst.LINE_STATUS_MIGRATING_OUT = "migrating_out"
HomeCampConst.LINE_STATUS_DEPRECATED = "deprecated"
HomeCampConst.INITIAL_MIGRATION_EPOCH = 1
HomeCampConst.MONGO_COLLECTION_PRIVATE_LINE_INDEX = "homecamp_private_line_index"
HomeCampConst.PRIVATE_LINE_MIGRATE_MODE_LOGIN = "login"
HomeCampConst.PRIVATE_LINE_MIGRATE_MODE_ENTER = "enter"
HomeCampConst.TERMINAL_LINE_MONGO_CLEANUP_INTERVAL = 300
HomeCampConst.TERMINAL_LINE_MONGO_CLEANUP_BATCH = 50
HomeCampConst.PUBLIC_LINE_EMPTY_LIFETIME_TIMEOUT = 600
HomeCampConst.PUBLIC_LINE_DESTROY_DELAY = 10
HomeCampConst.BUCKET_TICK_INTERVAL = 10
HomeCampConst.SERVICE_TICK_SUB_INTERVAL = 1
HomeCampConst.STAT_LOG_INTERVAL = 300
HomeCampConst.STAT_DETAIL_LOG_INTERVAL = 900
HomeCampConst.STAT_TOP_LINE_LIMIT = 5
HomeCampConst.MAX_TRY_LOGIN_CUR_CAMP = 3
HomeCampConst.TRY_LOGIN_CUR_CAMP_INTERVAL = 10

return HomeCampConst
