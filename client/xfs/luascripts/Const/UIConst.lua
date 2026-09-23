-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\UIConst.lua

local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AddressDataConst = require("Const.AddressDataConst")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local Const = require("Common.Const.Const")
local AudioConst = require("Const.AudioConst")
local UIConst = {
	UI_ID_PET_MANAGEMENT_RELEASE_REVIEW = 524,
	UI_ID_PET_MANAGEMENT_TIDY_UP = 523,
	UI_ID_PET_RESEARCH_REWARD = 32,
	UI_ID_PET_RESEARCH_ILLUSTRATED_BOOK = 31,
	UI_ID_COMMON_PET_TIP = 30,
	UI_ID_SHOP_MAIN = 29,
	UI_ID_COMMON_OBTAIN = 28,
	UI_ID_BOSS_TITLE = 27,
	UI_ID_PLAYER_ENHANCEMENT = 26,
	UI_ID_PET_BALL = 25,
	UI_ID_SKILL_POPUP = 24,
	UI_ID_QTE = 23,
	UI_ID_REPLACE_SKILL_POPUP = 22,
	UI_ID_MAP = 21,
	UI_ID_BOTTOM_DIALOGUE = 18,
	UI_ID_LOADING = 17,
	UI_ID_AVATAR_LOADING = 12,
	UI_ID_REPORT = 11,
	UI_ID_INVENTORY = 10,
	UI_ID_DAMAGE_NUMBER = 9,
	UI_ID_CRAWL = 19,
	UI_ID_THROW_PANEL = 13,
	UI_ID_CAPTURE_BALL = 8,
	UI_ID_PHOTO = 7,
	UI_ID_HUD_V2 = 2,
	UI_ID_HUD_MOBILE_OPERATE = 5,
	UI_ID_TIPS = 4,
	UI_ID_TOPLOGO = 3,
	UI_ID_LOGIN = 1,
	UI_ID_GRAB_EGGS_MODE = 806,
	UI_ID_GRAB_EGGS_SETTLEMENT_RANK = 805,
	UI_ID_GRAB_EGGS_SETTLEMENT = 804,
	UI_ID_GRAB_EGGS_OPEN_EYES = 803,
	UI_ID_GRAB_EGGS_RESULT = 802,
	UI_ID_GRAB_EGGS_BAG = 801,
	UI_ID_EVENT_AREA_ACTIVITY = 755,
	UI_ID_EVENT_SCHOOL_GUIDE = 754,
	UI_Pb_Event_FriendPanel = 753,
	UI_Pb_Event_ResearchCenter = 752,
	UI_Pb_Event_EcologicalSurvey = 751,
	UI_ID_Event_PetSave_Manual = 750,
	UI_ID_ITEM_COMPOSITE_POPUP_SINGLE = 700,
	UI_ID_VIP_JUMP_SCAN_CODE = 657,
	UI_ID_PHOTO_LIGHT_DIY = 656,
	UI_ID_PHOTOGRAPHY_INVITE = 655,
	UI_ID_PHOTOGRAPHY_STUDIO_EDIT = 654,
	UI_ID_PHOTO_SCAN_CODE = 653,
	UI_ID_PHOTO_DOWNLOAD_TEMPLATE = 652,
	UI_ID_PHOTO_SAVE_TEMPLATE = 651,
	UI_ID_PHOTO_LOGO = 650,
	UI_ID_BOSS_DUNGEON = 600,
	UI_ID_PET_MANAGEMENT_CARRYCONTACT = 552,
	UI_ID_PET_MANAGEMENT_UPSKILL_SUC = 551,
	UI_ID_PET_MANAGEMENT_UPSKILL = 550,
	UI_ID_FRIEND_GIFT_BUY = 534,
	UI_ID_MAIL = 533,
	UI_ID_FRIENDSHIP_UP = 532,
	UI_ID_FRIEND_GIFT = 531,
	UI_ID_PEEP_EXIT = 527,
	UI_ID_MAP_LOCATION = 526,
	UI_ID_PET_MANAGEMENT_RELEASE_REVIEW_CONFIRM = 525,
	UI_ID_CHANGE_NAME = 1114,
	UI_ID_INFO_PLAYER_MAIN = 1113,
	UI_ID_GRAB_EGGS_SEASONINFO_POPUP = 807,
	UI_ID_GRAB_EGGS_TALENT = 808,
	UI_ID_GRAB_EGGS_CALCINATION = 809,
	UI_ID_GRAB_EGGS_COLLECTION = 810,
	UI_ID_GRAB_EGGS_COLLECTION_DETAIL = 811,
	UI_ID_GRAB_EGGS_SEASON_RANK_MAIN = 812,
	UI_ID_GRAB_EGGS_SEASON_RANK_OVERVIEW = 813,
	UI_ID_TEAM_ROOM_DUNGEON_SELECT = 1000,
	UI_ID_RESTRAINT = 1010,
	UI_ID_TARGET_ELEMENT_POPUP = 1011,
	UI_ID_CHAIN_ATTACK_RESPOND = 1012,
	UI_ID_VITALITY = 1020,
	UI_ID_VITALITY_V0 = 1022,
	UI_ID_VITALITY_GOT = 1023,
	UI_ID_VITALITY_REDEEM = 1024,
	UI_ID_TOWER_PAUSE = 1043,
	UI_ID_TOWER_LEVEL_DETAIL = 1044,
	UI_ID_TOWER_SELECT_PET = 1045,
	UI_ID_SCREEN_EFFECT = 1046,
	UI_ID_TOWER_SETTLEMENT = 1047,
	UI_ID_TOWER_SELECT_STYLE = 1048,
	UI_ID_EVENT_PHOTO_RECOGNIZE = 1051,
	UI_ID_EVENT_TASK_PANEL = 1052,
	UI_ID_VOTING_FEATURE = 1110,
	UI_ID_BLACK_CHANGE = 1111,
	UI_ID_BLACK_BG = 1199,
	UI_ID_INFO_PLAYER_CARD = 1112,
	UI_ID_ILLUSTRATED_PET_DETAILS = 33,
	UI_ID_COMMON_ITEM_TIP = 34,
	DEFAULT_CLOSE_AUDIO = "ui_sfx_normal_close",
	DEFAULT_OPEN_AUDIO = "ui_sfx_normal_open",
	INFOS_LAYER = "InfosLayer",
	POPUP_LAYER = "PopupLayer",
	PANEL_LAYER = "PanelLayer",
	SCENE_LAYER = "SceneLayer",
	DAMAGE_NUMBER_SRC_TYPE_BUFF = 3,
	DAMAGE_NUMBER_SRC_TYPE_SKILL = 2,
	DAMAGE_NUMBER_SRC_TYPE_NORMAL_ATK = 1,
	MAX_LIST_NUM = 4,
	NORMAL_PANEL_DEPTH_OFFSET = 13,
	HIGHEST_NORMAL_PANEL_DEPTH = 15000,
	MIDDLE_NORMAL_PANEL_DEPTH = 14000,
	LOWEST_NORMAL_PANEL_DEPTH = 12000,
	UI_PATH_PRE = "Guis.Panels.",
	MIN_SCALE_VALUE = 0.001,
	EPS = 0.001,
	UI_ID_HOME_CAMP_REPORT = 5014,
	UI_ID_ACCUSATION = 5013,
	UI_ID_TAPTAP_STORE_EVALUATE = 9019,
	UI_ID_FEED_GAME_ENTRY = 9021,
	UI_ID_MAP_NOURISH_TRIBUTE = 9016,
	UI_ID_GAME_PREORDER_GUIDE = 9017,
	UI_ID_RESOURCE_CLEAN = 9015,
	UI_ID_TOOLTIP_SKILL_INFO_WITH_TITLE = 9014,
	UI_ID_VIETNAMESE_18_WARNING = 9013,
	UI_ID_TEXT_LINK = 9012,
	UI_ID_COMMON_INPUT = 9011,
	UI_ID_PET_TRANSMOG_BAPTIZE_TIP = 9010,
	UI_ID_PET_TRANSMOG_VIDEO = 9020,
	UI_ID_PET_TRANSMOG_ITEM_GET = 9008,
	UI_ID_PET_TRANSMOG_STAR_UPGRADE = 9007,
	UI_ID_PET_TRANSMOG_REPLACE = 9006,
	UI_ID_PET_TRANSMOG_SCHEME = 9005,
	UI_ID_PET_TRANSMOG = 9004,
	UI_ID_SIMPLE_TEXT_TIP = 9003,
	UI_ID_RESOURCE_DOWNLOAD = 9002,
	UI_ID_AGE_RATING = 9001,
	UI_ID_HEALTH_ADVICE = 9000,
	UI_ID_CREATE_ROLE_TIMELINE = 6000,
	UI_ID_TRADE_MARKET_PET_REMOVE_DETAIL = 5119,
	UI_ID_TRADE_MARKET_PET_SELL_DETAIL = 5118,
	UI_ID_TRADE_MARKET_HISTORY_PET = 5117,
	UI_ID_TRADE_MARKET_HISTORY_GOODS = 5116,
	UI_ID_TRADE_MARKET_SELL_GOODS = 5115,
	UI_ID_TRADE_MARKET_PANIC_BUY = 5114,
	UI_ID_TRADE_MARKET_GOODS_DETAIL = 5113,
	UI_ID_TRADE_MARKET_HISTORY = 5112,
	UI_ID_TRADE_MARKET_PET_BUY_DETAIL = 5111,
	UI_ID_TRADE_MARKET_SELL_PET = 5110,
	UI_ID_SELECT_LANGUAGE = 5101,
	UI_ID_LOGIN_SELECT_SERVER = 5100,
	UI_ID_MONTHLY_CARD_REWARD = 5012,
	UI_ID_MONTHLY_CARD_SELFIE = 5011,
	UI_ID_QUICK_PAYMENT = 5001,
	UI_ID_PLAYER_ENHANCE_LOADING = 4303,
	UI_ID_PLAYER_BADGE_FIRST_UNLOCK = 4302,
	UI_ID_PLAYER_BADGE_OBTAIN = 4301,
	UI_ID_PLAYER_BADGE_DETAIL = 4300,
	UI_ID_FISHING_CAPTURE_TICKET_EXCHANGE = 4212,
	UI_ID_FISHING_CAPTURE_PETAL_SOURCE = 4211,
	UI_ID_LITTLE_FIRE_GARDEN_MANUAL = 4210,
	UI_ID_PET_DISPATCH_START_TIPS = 4202,
	UI_ID_PET_DISPATCH_SURVEY_COMPLETED = 4203,
	UI_ID_PET_DISPATCH_PET_SELECT = 4206,
	UI_ID_PET_DISPATCH_TASK = 4205,
	UI_ID_FRIEND_GROUP_SETUP = 4002,
	UI_ID_FRIEND_SETUP = 4001,
	UI_ID_INVITE_FRIEND = 4000,
	UI_ID_PET_RESONANCE_FINAL_BREAK = 3104,
	UI_ID_PET_RESONANCE_BREAK = 3103,
	UI_ID_PET_RECOMMEND_STRENGTH_POINT = 3102,
	UI_ID_PET_BATCH_STRENGTH_RULE = 3101,
	UI_ID_PET_BATCH_STRENGTH_POINT = 3100,
	UI_ID_INCUBATOR = 3000,
	UI_ID_NPC_DUEL_NAMEIN = 2141,
	UI_ID_NPC_DUEL_START = 2140,
	UI_DEATH_SPECTATE = 2130,
	UI_SPECIAL_ENERGY_BAR = 2121,
	UI_OCTOPUS_GASHAPON = 2120,
	UI_ID_AVATAR_FUSION = 2100,
	UI_ID_FISSURE_INFO = 1701,
	UI_ID_FISSURE_MAIN = 1700,
	UI_ID_NET_LOADING = 2000,
	UI_ID_SEASON_HEAD_TIPS = 1655,
	UI_ID_SEASON_ACHIEVEMENT = 1653,
	UI_ID_SEASON_CALENDAR = 1652,
	UI_ID_SEASON_SHOP = 1651,
	UI_ID_SEASON_LOBBY = 1650,
	UI_ID_Morphling = 1630,
	UI_ID_LOTTERY_HISTORY = 1646,
	UI_ID_LOTTERY_RESULT = 1645,
	UI_ID_LOTTERY_REWARD_SHARE = 1644,
	UI_ID_LOTTERY_REWARD = 1643,
	UI_ID_LOTTERY_SHOP = 1642,
	UI_ID_LOTTERY_OTHER_REWARD = 1641,
	UI_ID_LOTTERY = 1640,
	UI_ID_BP_Get = 1619,
	UI_ID_GIFT_PACK_REWARD = 1618,
	UI_ID_BP_PURCHASE = 1617,
	UI_ID_BP_GIFT = 1616,
	UI_ID_BP_EXCHANGE = 1615,
	UI_ID_BUY_LV = 1614,
	UI_ID_BP_OBTAIN = 1613,
	UI_ID_BP_PERMIT = 1612,
	UI_ID_BP_CORE_REWARD = 1611,
	UI_ID_CASH_SHOP_PENALTY_TIP = 1607,
	UI_ID_CASH_CART = 1606,
	UI_ID_CASH_CONFIRMATION_SCREEN = 1605,
	UI_ID_CASH_ACCESSORY_ADJUST = 1604,
	UI_ID_CASH_FILTER = 1603,
	UI_ID_CASH_SEARCH = 1602,
	UI_ID_CASH_GIFT = 1601,
	UI_ID_CASH_SHOP = 1600,
	UI_ID_FUNC_MENU_EXIT = 1501,
	UI_ID_PAUSE_PANEL = 1500,
	UI_ID_HOME_CAMP_CHOOSE_EXPLORE_AREA = 1422,
	HOME_CAR_CAM_DISPATCH_REWARDS = 1421,
	UI_ID_CAMP_MANAGER = 1420,
	UI_ID_HOME_CAMP_INVITE_CARD = 1408,
	UI_ID_HOMECAMP_STATION_SETTING = 1411,
	UI_ID_HOMECAMP_INVITE_FRIEND = 1410,
	UI_ID_STATION_BUFF_COUNTDOWN = 1407,
	UI_ID_HOME_STATION_MANAGE = 1406,
	UI_ID_HOME_CAR_BUFF_PANEL = 1405,
	UI_ID_CAMP_MOVE_LOADING = 1404,
	UI_ID_CAMP_VISIT = 1403,
	UI_ID_HOME_CAR_CAMP_SWITCH = 1402,
	UI_ID_HOME_CAR_NAME = 1401,
	UI_ID_HOME_CAR_MODIFY = 1400,
	UI_ID_FISHING_CAPTURE_CONTRACT = 1355,
	UI_ID_FISHING_CAPTURE_FAIL_RESULT = 1354,
	UI_ID_FISHING_CAPTURE_HISTORY = 1353,
	UI_ID_FISHING_CAPTURE_PURIFICATION = 1352,
	UI_ID_FISHING_CAPTURE_RESULT = 1351,
	UI_ID_FISHING_CAPTURE_MAIN = 1350,
	UI_ID_CATCH_ROGUE_RESULT = 1302,
	UI_ID_CATCH_ROGUE_PET_BAG = 1301,
	UI_ID_CATCH_ROGUE_ENTRY = 1300,
	UI_ID_RECOMMEND_PET = 1260,
	UI_ID_TOWER_SEASON_WEEKLY_REWARD = 1254,
	UI_ID_TOWER_DAILY_REWARD = 1253,
	UI_ID_TOWER_FAST_TRAIN = 1252,
	UI_ID_TOWER_EVENT_DIALOGUE = 1251,
	UI_ID_TOWER_WEEKLY_REWARD = 1250,
	UI_ID_DIRECT_PURCHASE_TIPS = 1212,
	UI_ID_DIRECT_PURCHASE = 1211,
	UI_ID_BOSS_RUSH_SEASON = 1210,
	UI_ID_BOSS_RUSH_BATTLE_DETAIL_RESULT = 1209,
	UI_ID_COMMON_TIP_INPUT = 1208,
	UI_ID_PET_SELECT_POPUP = 1207,
	UI_ID_BOSS_RUSH_REWARD = 1206,
	UI_ID_BOSS_RUSH_SETTLEMENT = 1205,
	UI_ID_BOSS_RUSH_BUFF_SELECT = 1204,
	UI_ID_BOSS_RUSH_BATTLE_RESULT = 1203,
	UI_ID_BOSS_RUSH_CHALLENGE = 1202,
	UI_ID_BOSS_RUSH_ROUTE = 1201,
	UI_ID_BOSS_RUSH_MAIN = 1200,
	UI_ID_INTERACT_GESTURE = 1120,
	UI_ID_SPACE_FOLLOW_GIVE_CONFIRM = 1119,
	UI_ID_SPACE_FOLLOW_MEMBER = 1118,
	UI_ID_RANK_FILTER = 1124,
	UI_ID_RANK_REWARD = 1123,
	UI_ID_RANK_BASE = 1122,
	UI_ID_FRIEND_INTIMACY_EXPLAIN = 1121,
	UI_ID_FRIEND_INTIMACY = 1117,
	UI_ID_PLAY_FLUTE = 1116,
	UI_ID_COMMON_TEXT_INPUT = 1115,
	UI_ID_QUIZ = 522,
	UI_ID_MULTI_CHOOSE_CHEST = 521,
	UI_ID_CREATE_PLAYER_RENAME = 520,
	UI_ID_ROG_VENTURE_REWARD = 509,
	UI_ID_ROG_EVENT_VENTURE = 508,
	UI_ID_EXCHANGE_ITEM = 507,
	UI_ID_LEVEL_BREAKTHROUGH_TIP = 506,
	UI_ID_LEVEL_BREAKTHROUGH_RESULT = 505,
	UI_ID_LEVEL_BREAKTHROUGH = 504,
	UI_ID_ROG_EVENT_REVIVAL = 503,
	UI_ID_ROG_LEVEL_SELECT = 502,
	UI_ID_ROG_ULTIMATE_UPGRADE = 501,
	UI_ID_ROG_ULTIMATE_UNLOCK = 500,
	UI_ID_PET_INTIMACY = 461,
	UI_ID_HOME_SEASON_PARTY = 460,
	UI_ID_HOME_SEASON_PREPARE = 459,
	UI_ID_HOME_SEASON_DAILY_TASK = 458,
	UI_ID_HOME_SEASON_CELEBRATION_START = 457,
	UI_ID_HOME_SEASON_CELEBRATION_INVITE = 456,
	UI_ID_HOME_SEASON_CELEBRATION_PREPARE = 455,
	UI_ID_HOME_SEASON_COLLECTIONCROP_DECOMPOSE = 454,
	UI_ID_HOME_SEASON_COLLECTIONCROP_DETAIL = 453,
	UI_ID_HOME_SEASON_COLLECTIONCROP = 452,
	UI_ID_HOME_SEASON_INTRO = 451,
	UI_ID_HOME_SEASON_MAIN_PAGE = 450,
	UI_ID_HOME_GASHAPON_RULE = 449,
	UI_ID_HOME_GASHAPON = 448,
	UI_ID_HOME_PET_APPEARANCE_ABILITY = 447,
	UI_ID_HOME_PET_ELEMENT_ABILITY = 446,
	UI_ID_HOME_BOOK_FURNITURE_DETAIL = 445,
	UI_ID_HOME_BOOK_CROP_DETAIL = 444,
	UI_ID_HOME_BOOK_SEASON = 443,
	UI_ID_HOME_BOOK_SCORE_POPUP = 442,
	UI_ID_HOME_BOOK_SCORE_REWARD = 441,
	UI_ID_HOMELAND_FURNITURE_COMPOSE_DETAIL = 440,
	UI_ID_HOMELAND_FURNITURE_DESIGN = 439,
	UI_ID_HOMELAND_AREA_MANAGE = 438,
	UI_ID_HOME_BOOK_FURNITURE_SET = 437,
	UI_ID_HOMELAND_LEVEL_UP_RESULT = 436,
	UI_ID_HOMELAND_PLOT_MANAGEMENT_NEW = 435,
	UI_ID_HOMELAND_PET_MANAGEMENT_NEW = 434,
	UI_ID_HOME_PLANTS_SEND = 433,
	UI_ID_HOME_PLANTS_MANUAL_DETAIL = 432,
	UI_ID_HOME_BOOK = 431,
	UI_ID_HOME_ORDER = 430,
	UI_ID_HOMELAND_MULTI_SELECT = 426,
	UI_ID_HOMELAND_PLAYER_EDITOR_SETTING = 425,
	UI_ID_HOMELAND_CAR_COMP_LEVEL_UP = 424,
	UI_ID_HOMELAND_CAR_LEVEL_UP = 423,
	UI_ID_PROP_SELECT = 422,
	UI_ID_PET_EVOLUTION = 421,
	UI_ID_HOMELAND_MAIN_PAGE = 419,
	UI_ID_HOME_MUSIC_PLAYER = 418,
	UI_ID_HOME_FACILITY_INFO_DETAIL = 417,
	UI_ID_HOMELAND_FURNITURE_STORE = 416,
	UI_ID_HOMELAND_EDITOR_SETTING = 415,
	UI_ID_HOMELAND_EDITOR_TOPLOGO = 414,
	UI_ID_PET_GIFT_TIPS_RECOMMEND = 413,
	UI_ID_HOMELAND_LEVEL_UP = 412,
	UI_ID_HOME_INVENTORY = 411,
	UI_ID_HOME_FACILITY_SET_PET = 410,
	UI_ID_HOME_FACILITY_INFO_TIP = 409,
	UI_ID_HOME_FACILITY_INFO = 408,
	UI_ID_HOMELAND_PET_ACTION = 407,
	UI_ID_HOME_SET_FORMULA = 406,
	UI_ID_HOME_PLATEINFO = 405,
	UI_ID_HOMELAND_MARKET = 404,
	UI_ID_HOMELAND_PET_EDITOR = 403,
	UI_ID_HOMELAND_PLACE_EDITOR = 402,
	UI_ID_HOMELAND_EDITOR = 401,
	UI_ID_PET_INHERITANCE_RESULT = 337,
	UI_ID_PET_INHERITANCE_CHOOSE = 336,
	UI_ID_PET_INHERITANCE_MAIN = 335,
	UI_ID_PLAYER_ASSESS = 334,
	UI_ID_PLAYER_LV_REWARD = 333,
	UI_ID_PET_CARRY_RECOMMEND = 330,
	UI_ID_SHOP_GIFT_RECEIVE = 329,
	UI_ID_LOADING_SHOW = 328,
	UI_ID_PET_CARRY_ASSIST_STRENGTH_RESULT = 327,
	UI_ID_PET_CARRY_ASSIST_STRENGTH = 326,
	UI_ID_PET_CHANGE_FORM_SMALL = 325,
	UI_ID_PET_CHANGE_FORM = 324,
	UI_ID_PET_GIFT_TIPS = 323,
	UI_ID_PET_SELECT_BOX = 322,
	UI_ID_PET_CARRY_STRENGTH_RESULT = 321,
	UI_ID_PET_CARRY_STRENGTH = 320,
	UI_ID_PET_VARIANT_RESULT = 317,
	UI_ID_PET_VARIANT_PROCESS = 316,
	UI_PHOTO_SHOW_TIP = 315,
	UI_ID_PET_TRAINING_NEW = 314,
	UI_ID_PET_EXCHANGE_TIP = 313,
	UI_ID_PET_EXCHANGE_COUNTDOWN = 312,
	UI_ID_PET_EXCHANGE_WAIT = 311,
	UI_ID_PET_EXCHANGE_SELECT = 310,
	UI_ID_QUEST_ARRIVAL_TIP = 307,
	UI_ID_CHARACTER_APPEARANCE = 306,
	UI_ID_GUIDE_MODE = 305,
	UI_ID_NPC_CALL_MULTIPLE = 304,
	UI_ID_TRAIN_PREFERENCE = 303,
	UI_ID_PET_DETAIL = 302,
	UI_ID_MARK_SHARE_BUBBLE = 301,
	UI_ID_BRANCH_LINE = 300,
	UI_ID_KNOWLEDGE_POPUP = 290,
	UI_ID_KNOWLEDGE_Details = 289,
	UI_ID_KNOWLEDGE_Entrance = 288,
	UI_ID_ARK_PARTY_CHOICE = 286,
	UI_ID_SOUND_GAME = 285,
	UI_ID_PETEVENT_SETTLEMENT = 284,
	UI_ID_PETEVENT_PETCHOICE = 283,
	UI_ID_COMMON_PANELLEFT_ITEM_SEL = 282,
	UI_ID_COMMON_PET_PREVIEW = 281,
	UI_ID_GAMEPLAY_PROGRESS = 280,
	UI_ID_ELEMENT_STRENGTHEN_DETAILS = 902,
	UI_ID_CATCHBOSS_NEW = 901,
	UI_ID_CHANGE_AVATAR = 279,
	UI_ID_CATCHBOSS = 278,
	UI_ID_ANNOUNCEMENT = 277,
	UI_ID_QUEST_COURSE = 276,
	UI_ID_SURVEY = 275,
	UI_ID_PET_TRAINING = 274,
	UI_ID_PET_SKILL = 273,
	UI_ID_PET_SKILL_REPLACE_QUICK = 272,
	UI_ID_PET_PROPERTY = 271,
	UI_ID_PVP_FRIEND = 270,
	UI_ID_DIALOGUE_SKIP = 263,
	UI_ID_PET_CONFIRM = 262,
	UI_ID_COMMON_CONFIRM = 261,
	UI_ID_PUZZLE = 260,
	UI_ID_PET_PROP_USE_RESULT = 255,
	UI_ID_INVENTORY_PET_PROP_USE = 254,
	UI_ID_INVENTORY_DECOMPOSE = 253,
	UI_ID_QR_CODE = 252,
	UI_ID_INVENTORY_ITEM_USE = 251,
	UI_ID_RACING_DUNGEON = 240,
	UI_ID_SPECIAL_TRAIN_CHAPTER_TIP_PANEL = 236,
	UI_ID_OPEN_SPECIAL_TRAIN_PANEL = 235,
	UI_ID_WORKSHOP_COVER_PRESET = 234,
	UI_ID_WORKSHOP_SAVE_PRESET = 233,
	UI_ID_WORKSHOP_COSTUME_STAIN = 232,
	UI_ID_WORKSHOP_DESIGN = 231,
	UI_ID_GAMEPAD_MENU_NEW = 230,
	UI_ID_HUD_SCREENSHOT_SHARING = 229,
	UI_ID_SHARE = 228,
	UI_ID_AVATAR_IMPORT_CONFIRM = 227,
	UI_ID_AVATAR_IMPORT = 226,
	UI_ID_APPEARANCE_V2 = 225,
	UI_ID_PLAYER_SKILL_FILTER = 220,
	UI_ID_PLAYER_RENAME = 210,
	UI_ID_PET_OVERVIEW = 203,
	UI_ID_DUNGEON_INVITE = 201,
	UI_ID_FUNC_MENU_UNLOCK = 200,
	UI_ID_NPC_EVENT_CHAIN = 194,
	UI_ID_PIECES_ITEM_PANEL = 193,
	UI_ID_VEHICLE_INTERATION_PANEL = 192,
	UI_ID_TOTEM_WORSHIP = 191,
	UI_ID_ITEM_VIEWER = 190,
	UI_ID_DIALOGUE_ID = 187,
	UI_ID_SHOP_ARK = 186,
	UI_ID_SHOP_TRANS = 185,
	UI_ID_WHITE_SCREEN = 184,
	UI_ID_PET_SELECTION_PANEL_NEW = 183,
	UI_ID_NATURAL_SELECTION_PANEL = 182,
	UI_ID_SCENE_SELECTION_PANEL = 181,
	UI_ID_LIVE_STREAMING = 180,
	UI_ID_BLACK_SCREEN_SKIP_PANEL = 179,
	UI_ID_COMMON_SKIP_PANEL = 178,
	UI_ID_PET_FERTILITY_HATCH_SCENE_HOST = 195,
	UI_ID_PET_FERTILITY_POPUP_CHOOSE_BALL = 188,
	UI_ID_PET_FERTILITY_CHOOSE_BALL = 177,
	UI_ID_PET_FERTILITY_INCUBATE_RESULT = 176,
	UI_ID_PET_FERTILITY_INCUBATE = 175,
	UI_ID_SUBTITLES_PANEL = 174,
	UI_ID_SKIP_PANEL = 173,
	UI_ID_SIMPLE_VIEW = 172,
	UI_ID_MARK_SHARE_VIEW_SIMPLE = 171,
	UI_ID_MARK_SHARE_EDIT = 170,
	UI_ID_MARK_SHARE_VIEW = 169,
	UI_ID_MAP_NOURISH = 168,
	UI_ID_PET_FERTILITY_HATCH_RESULT = 167,
	UI_ID_COMMON_CUSTOM_INFO_TIP = 166,
	UI_ID_PET_FERTILITY_RESULT_POP = 165,
	UI_ID_PET_FERTILITY_RULE = 164,
	UI_ID_PET_FERTILITY_RESULT = 163,
	UI_ID_PET_FERTILITY = 162,
	UI_ID_LOGO_PANEL = 161,
	UI_ID_DEVELOP_HINT_PANEL = 160,
	UI_ID_GUIDE_POPUP_PANEL = 151,
	UI_ID_GUIDE_PANEL = 150,
	UI_ID_GROW_GIFT_SELECT_FILTER = 153,
	UI_ID_GROW_GIFT_SELECT = 152,
	UI_ID_PET_SELECT = 149,
	UI_ID_EVENT = 148,
	UI_ID_PET_RESEARCH_FRONT_PAGE_V2 = 147,
	UI_ID_PET_REPORT = 146,
	UI_ID_PET_RESEARCH_LOADING = 145,
	UI_ID_PET_RESEARCH_PREVIEW_STAR_POPUP = 144,
	UI_ID_PET_RESEARCH_COUNTRY_PAGE = 143,
	UI_ID_TRAIT_POPUP_DETAIL = 142,
	UI_ID_QTE_TIMELINE = 141,
	UI_ID_PET_RESEARCH_FRONT_PAGE = 140,
	UI_ID_PET_RESEARCH_PET_REWARD = 139,
	UI_ID_ACCESS_PET_BOX = 138,
	UI_ID_PET_ACCESSORY_PRESET = 137,
	UI_ID_PET_ACCESSORY = 136,
	UI_ID_LEYLINE_TREE = 135,
	UI_ID_CLUE_SEEK_TIP = 134,
	UI_ID_SHOP_POSTER = 133,
	UI_ID_PLAYER_INFO_CARD = 132,
	UI_ID_QUEST_VLOG = 131,
	UI_ID_AI_ASSISTANT = 130,
	UI_ID_AVATAR_TIP = 129,
	UI_ID_TIME_SWITCH = 128,
	UI_ID_APPEARANCE_PREVIEW = 127,
	UI_ID_PET_FIRST_SHOW = 126,
	UI_ID_PET_TEAM_QUICK_SWITCH = 125,
	UI_ID_ALBUM_SINGLE_PHOTO = 124,
	UI_ID_DRAGON_BUS_BLACK_SCREEN = 123,
	UI_ID_ALBUM = 122,
	UI_ID_QUEST_CHAPTER = 121,
	UI_ID_PHOTO_SHOW = 120,
	UI_ID_AVATAR_PREVIEW = 119,
	UI_ID_COLOR_PICKER = 118,
	UI_ID_DIALOG_REVIEW = 117,
	UI_ID_PLOT_PHONE_CALL = 116,
	UI_ID_CREATE_PLAYER_PANEL = 115,
	UI_ID_PET_SELECTION_PANEL = 114,
	UI_ID_TOWER_FINAL = 113,
	UI_ID_TOWER_DEFEAT = 112,
	UI_ID_PET_RESEARCH_DETAIL_V2 = 111,
	UI_ID_TOWER_STAGE_INFO = 110,
	UI_ID_TOWER_BUFF_DETAIL = 109,
	UI_ID_TOWER_MAIN = 108,
	UI_ID_APPEARANCE_OUTFIT = 107,
	UI_ID_CHAIN_ATTACK = 106,
	UI_ID_PHOTO_IDENTIFY = 105,
	UI_PLAYER_RAISE_STAR = 104,
	UI_ID_PET_SKILL_LEARN = 103,
	UI_ID_TEAM_CHALLENGE_INVITE = 102,
	UI_ID_GAME_INSTANCE = 101,
	UI_ID_PET_LEVEL_UP = 100,
	UI_ID_APPEARANCE = 99,
	UI_ID_NPC_CALL = 98,
	UI_ID_PET_EVOLVE_PET_SHOW = 97,
	UI_ID_REPLACE_FEATURE_POPUP_PVP = 96,
	UI_ID_DEAD_PANEL = 95,
	UI_ID_COMMON_LONG_POPUP = 94,
	UI_ID_PET_EVOLVE_BRANCH_SELECT = 93,
	UI_ID_PET_RESEARCH_PROGRESS_REWARD = 91,
	UI_ID_PET_MANAGEMENT_FILTER = 90,
	UI_ID_PET_MANAGEMENT = 89,
	UI_ID_PET_RESEARCH_COUNTRY_PANEL_GIFT = 87,
	UI_ID_BLACK_SCREEN = 86,
	UI_ID_PET_RESEARCH = 85,
	UI_ID_COUNTRY_Ill_BOOK = 84,
	UI_ID_TEAM_ROOM = 83,
	UI_ID_PVP_FLOATING_WND = 82,
	UI_ID_FRIEND_INVITE_LIST = 81,
	UI_ID_ITEM_VIEW_POPUP = 80,
	UI_ID_DIALOGUE_DIALOG = 79,
	UI_ID_SETTING_KEY_ATTENTION_CONSOLE = 9009,
	UI_ID_SETTING_KEY_ATTENTION = 78,
	UI_ID_SETTING_KEY_REPLACE = 77,
	UI_ID_AVATAR_MAIN = 76,
	UI_ID_PLAYER_CARD = 75,
	UI_ID_ITEM_COMPOSITE_POPUP = 74,
	UI_ID_CHAT = 73,
	UI_ID_PVP_REWARD = 72,
	UI_ID_CHAT_PHOTOGRAPH = 189,
	UI_ID_REPLACE_SKILL_POPUP_PVP = 71,
	UI_ID_PICTURE = 70,
	UI_ID_FUNC_MENU = 69,
	UI_ID_SETTING_OPERATION = 68,
	UI_ID_GAME_CUT_TO_BLACK = 67,
	UI_ID_SETTING = 66,
	UI_ID_PVP_LOADING = 65,
	UI_ID_PVP_CHOSE = 64,
	UI_ID_CONFIG_TOPPING = 63,
	UI_ID_CONFIG = 62,
	UI_ID_PVP_PET_SET = 61,
	UI_ID_PVP_MENU = 60,
	UI_ID_ROG_BUFF_SELECT = 59,
	UI_ID_PVP_BATTLE = 58,
	UI_ID_GAME_COUNT_TIME = 55,
	UI_ID_GAMEPAD_MENU = 54,
	UI_ID_COMMON_BUFF_INFO_TIP = 53,
	UI_ID_AVATAR = 52,
	UI_ID_BOTTOM_PET_CHAT = 49,
	UI_ID_TRAINING = 48,
	UI_ID_BIG_WHITE_BALL = 47,
	UI_ID_HATRED_ARROW_TIP = 46,
	UI_ID_BUFF_TIPS = 45,
	UI_ID_COMMON_SELECT_USE = 44,
	UI_ID_COMMON_USE_CONFIRM = 43,
	UI_ID_HELP = 42,
	UI_ID_MAKE_SKILL = 41,
	UI_ID_VIDEO = 40,
	UI_ID_INTERACT_SECOND = 39,
	UI_ID_INTERACT = 38,
	UI_ID_MAP_AREA_FILTER = 37,
	UI_ID_QUEST_PANEL = 36,
	UI_ID_COMMON_PLAYER_SKILL_TIP = 35
}

UIConst.PLATFORM_CONSOLE = {}
UIConst.WeatherState = {
	sun = 1,
	thunder = 4,
	snow = 3,
	rain = 2
}
UIConst.UI_ADAPTER_VISIBILITY_STATE = {
	UI_HIDE_KEEP_UI_SCENE = 4,
	UI_HIDE_FORCE = 3,
	PANEL_COVERED = 2,
	VISIBLE = 1
}
UIConst.UI_HIDE_KEY = {
	CARRY_ENT = 130003,
	GM_OBSERVE = 130004,
	CLIENT_EVENT = 200000,
	HUD_BREAK_CTRL = 100009,
	CLIENT_UTILS = 100008,
	CUTSCENE = 100007,
	QTE_CTRL = 100001,
	PEEP = 130002,
	TOTEM_PUZZLE = 130001,
	MARK_SHARE_BUBBLE = 130000,
	PET_BALL_BREED = 120000,
	SHARE_SNAPSHOT = 110004,
	CREATE_APPEARANCE = 110003,
	APPEARANCE = 110002,
	PRESET_SNAPSHOT = 110001,
	CREATE_USER_SNAPSHOT = 110000,
	HOME_CAMP_REPORT = 100039,
	SEASON_OPEN_TIP = 100038,
	HOMELAND_AUTO_REVIEW = 100037,
	HOMELAND_REPORT = 100036,
	PET_FERTILITY_CHOOSE_CUBE_SOURCE_JUMP = 100035,
	HOME_SEASON_CELEBRATION = 100034,
	DEAD_PANEL_MINI = 100033,
	BOSS_TITLE_DEAD = 100032,
	PET_TEAM_QUICK_SWITCH = 100031,
	PLAYER_INFO_CARD = 100030,
	AFK = 100029,
	PUPPET_DEATH_CAM_ANIM = 100028,
	SpecialTrain = 100027,
	QUEST_CHAPTER = 100026,
	PiecesItem = 100025,
	GROUP_SING = 100024,
	TOTEM_WORSHIP = 100023,
	HUD_BREAK_CTRL_TEMP = 100022,
	HUD_BREAK_CTRL_BURST = 100021,
	DIALOAGUE_GRAPH = 100020,
	DIE = 100019,
	TAKE_PHOTO = 100018,
	PET_EVOLVE = 100017,
	ULTIMATE = 100016,
	SpecialItem = 100015,
	LEVEL = 100014,
	Skill = 100013,
	Dialogue = 100012,
	MINI_GAME = 100011,
	ARK_CAMP_ACTIVE = 100010
}
UIConst.UI_HIDE_KEY_CONFIGS = {
	[UIConst.UI_HIDE_KEY.TAKE_PHOTO] = {
		keepUIScene = true
	},
	[UIConst.UI_HIDE_KEY.HOMELAND_REPORT] = {
		keepUIScene = true
	},
	[UIConst.UI_HIDE_KEY.HOMELAND_AUTO_REVIEW] = {
		keepUIScene = true
	},
	[UIConst.UI_HIDE_KEY.HOME_CAMP_REPORT] = {
		keepUIScene = true
	},
	[UIConst.UI_HIDE_KEY.CREATE_USER_SNAPSHOT] = {
		keepUIScene = true
	},
	[UIConst.UI_HIDE_KEY.PRESET_SNAPSHOT] = {
		keepUIScene = true
	},
	[UIConst.UI_HIDE_KEY.CREATE_APPEARANCE] = {
		keepUIScene = true
	},
	[UIConst.UI_HIDE_KEY.SHARE_SNAPSHOT] = {
		keepUIScene = true
	}
}
UIConst.FUNC_MENU_HIDE_TIP = {
	TipAreaConst.AREAS.TOP,
	TipAreaConst.AREAS.A1,
	TipAreaConst.AREAS.A1I,
	TipAreaConst.AREAS.A2,
	TipAreaConst.AREAS.CF,
	TipAreaConst.AREAS.C,
	TipAreaConst.AREAS.CI,
	TipAreaConst.AREAS.M,
	TipAreaConst.AREAS.MI,
	TipAreaConst.AREAS.PA2
}
UIConst.UI_CONFIGS = {
	[UIConst.UI_ID_HEALTH_ADVICE] = {
		blockCommonQuit = true,
		module = "cnHealthAdvice",
		resID = "$UI_Pb_Login_Advice.prefab",
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_TOPLOGO] = {
		isPermanent = false,
		needRaycaster = false,
		hideByOutOfView = true
	},
	[UIConst.UI_ID_AGE_RATING] = {
		module = "cnAgeRating",
		resID = "$UI_Pb_Login_AgeRating.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_LOGIN] = {
		blockCommonQuit = true
	},
	[UIConst.UI_ID_MARK_SHARE_VIEW] = {
		gamepadModel = true
	},
	[UIConst.UI_ID_HUD_V2] = {
		syncLoad = true,
		hideByOutOfView = true,
		resID = "$UI_Pb_Hud.prefab",
		module = "hudV2",
		platformSensitive = true,
		orderWidget = 0,
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_FEED_GAME_ENTRY] = {
		resID = "$UI_Pb_Event_TikTok_Game.prefab",
		module = "feedGameEntry",
		orderWidget = 1,
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_HUD_MOBILE_OPERATE] = {
		blockCommonQuit = true,
		resID = "$UI_Pb_Operate_Mobile.prefab",
		module = "mobileOperate",
		platformSensitive = true,
		orderWidget = -2,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_EVENT] = {
		fullScreen = true,
		blackBgDuration = 1,
		resID = "$UI_Pb_Event.prefab",
		module = "event",
		functionID = Const.FUNCTION_IDS.ACTIVITYCENTER,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_SELECT] = {
		fullScreen = true,
		resID = "$UI_Pb_Event_PetSelectPanel.prefab",
		module = "petSelect",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_GROW_GIFT_SELECT] = {
		fullScreen = true,
		resID = "$UI_Pb_Event_GrowthGift_Self.prefab",
		module = "growthGiftSelect",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.GROW_GIFT_SELECT_SCENE,
		uiSceneResId = AddressDataConst.UI_GROW_GIFT_SELECT_SCENE
	},
	[UIConst.UI_ID_GROW_GIFT_SELECT_FILTER] = {
		module = "growthGiftSelectFilter",
		resID = "$UI_Pop_Event_Filter.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_MANAGEMENT] = {
		blockCommonQuit = true,
		keepUISceneOnPanelCovered = true,
		deferUISceneLoad = true,
		blurBg = true,
		initRegister = true,
		addBlackChange = {
			0.1,
			0.3
		},
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_PET_MANAGEMENT_RELEASE_REVIEW] = {
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_PET_MANAGEMENT_FILTER] = {
		initRegister = true
	},
	[UIConst.UI_ID_PLAYER_ENHANCEMENT] = {
		fullScreen = true,
		bgm = "BGM_Panel_PlayerEnhancement",
		resID = "$UI_Pb_Personal_New.prefab",
		blockCommonQuit = true,
		uiSceneName = UISceneConst.PLAYER_ENHANCE_SCENE,
		uiSceneResId = AddressDataConst.UI_SCENE_PLAYER_ENHANCE
	},
	[UIConst.UI_ID_MAP] = {
		blockCommonQuit = true,
		initRegister = 1,
		blackBgDuration = 1,
		disableVirtualMouseToggle = true
	},
	[UIConst.UI_ID_BUFF_TIPS] = {
		initRegister = true
	},
	[UIConst.UI_ID_HATRED_ARROW_TIP] = {
		needRaycaster = false,
		hideByOutOfView = true
	},
	[UIConst.UI_ID_LOADING] = {
		lockCursor = true,
		MutexDisplay = true,
		fullScreen = true,
		forceHideTips = true,
		needRaycaster = false,
		orderWidget = 1000,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_TAPTAP_STORE_EVALUATE] = {
		module = "tapTapStoreEvaluate",
		fullScreen = false,
		resID = "$UI_Popup_Panel_Long_Evaluate.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_LOADING_SHOW] = {
		lockCursor = true
	},
	[UIConst.UI_ID_AVATAR_LOADING] = {
		lockCursor = true,
		uiType = "InfosLayer",
		MutexDisplay = true,
		resID = "$UI_Pb_AvatarLoading.prefab",
		module = "avatarLoading",
		bgm = "None",
		orderWidget = 99,
		blockCommonQuit = true,
		syncLoad = true,
		fullScreen = true,
		isModel = true
	},
	[UIConst.UI_ID_REPORT] = {
		blockCommonQuit = true,
		MutexDisplay = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_CONFIG] = {
		isModel = true,
		orderWidget = 9999
	},
	[UIConst.UI_ID_CONFIG_TOPPING] = {
		orderWidget = 200000,
		hideByOutOfView = true
	},
	[UIConst.UI_PLAYER_RAISE_STAR] = {
		module = "playerStarRaise",
		fullScreen = true,
		resID = "$UI_Pb_Hud_StarRise.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_CHAIN_ATTACK] = {
		resID = "$UI_Pb_QTE.prefab",
		module = "chainAttack",
		orderWidget = -1.5,
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_PHOTO_SHOW_TIP] = {
		module = "photoTip",
		orderWidget = 100,
		resID = "$UI_Pb_PopUp_ShowPhoto.prefab",
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_PET_EVOLUTION] = {
		keepUISceneOnPanelCovered = true,
		resID = "$UI_Pb_PetManagement_Cultivate.prefab",
		module = "petEvolution",
		orderWidget = 100,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_TRAINING_SCENE,
		uiSceneResId = AddressDataConst.UI_PET_MANAGEMENT_TRAINING_SCENE,
		uiSceneVisibleBypassUIHideKeys = {
			[UIConst.UI_HIDE_KEY.PET_EVOLVE] = true
		}
	},
	[UIConst.UI_ID_PET_MANAGEMENT_UPSKILL] = {
		fullScreen = true,
		bgm = "BGM_UI_GrowthInterface",
		resID = "$UI_Pb_PetSkill_ColoredGlaze.prefab",
		module = "petUpSkill",
		uiType = UIConst.PANEL_LAYER,
		addBlackChange = {
			0.1,
			0.3
		}
	},
	[UIConst.UI_ID_PET_MANAGEMENT_UPSKILL_SUC] = {
		module = "petUpSkillSuc",
		resID = "$UI_Pop_PetManage_SkillStrengthen.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_MANAGEMENT_CARRYCONTACT] = {
		fullScreen = true,
		bgm = "BGM_UI_GrowthInterface",
		resID = "$UI_Pb_PetManage_CarryContact.prefab",
		module = "petCarryContact",
		uiType = UIConst.PANEL_LAYER,
		addBlackChange = {
			0.1,
			0.3
		}
	},
	[UIConst.UI_ID_TIPS] = {
		blockCommonQuit = true,
		hideByOutOfView = true,
		orderWidget = 9000,
		resID = "$XGUI_RPanel/Popup/UI_Pb_TipsGene_Frame.prefab"
	},
	[UIConst.UI_ID_COMMON_PET_TIP] = {
		module = "commonPetTip",
		uiType = "InfosLayer",
		keepTextLinkOnOpen = true,
		resID = "$UI_Node_PetInfo_Element_Tips.prefab"
	},
	[UIConst.UI_ID_COMMON_ITEM_TIP] = {
		keepTextLinkOnOpen = true,
		gamepadModel = true,
		gamepadPass = true,
		resID = "$UI_Pb_PropInfoPanel.prefab"
	},
	[UIConst.UI_ID_CLUE_SEEK_TIP] = {
		resID = "$UI_Tips_ItemInfo.prefab",
		gamepadPass = true,
		gamepadModel = true,
		module = "CommonClueSeekTip",
		keepTextLinkOnOpen = true,
		orderWidget = 100,
		ignore = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP] = {
		keepTextLinkOnOpen = true,
		uiType = "InfosLayer",
		resID = "$UI_Node_SkillTree_InfoTip.prefab",
		module = "commonPlayerSkillTip",
		orderWidget = 98,
		ignore = true
	},
	[UIConst.UI_ID_QUEST_PANEL] = {
		blackBgDuration = 1
	},
	[UIConst.UI_ID_COMMON_BUFF_INFO_TIP] = {
		keepTextLinkOnOpen = true
	},
	[UIConst.UI_ID_COMMON_CUSTOM_INFO_TIP] = {
		keepTextLinkOnOpen = true
	},
	[UIConst.UI_ID_ITEM_COMPOSITE_POPUP] = {
		resID = "$UI_Pb_Inventory_Compound.prefab"
	},
	[UIConst.UI_ID_ITEM_COMPOSITE_POPUP_SINGLE] = {
		module = "itemCompositePopupSingle",
		resID = "$UI_Pb_Popup_HomeManufacture.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_RESEARCH_DETAIL_V2] = {
		bgm = "BGM_UI_PetManual",
		fullScreen = 1,
		resID = "$UI_Pb_PetManual_Explore.prefab",
		module = "petResearchDetailV2",
		uiSceneName = UISceneConst.PET_RESEARCH_DETAIL_V3,
		uiSceneResId = AddressDataConst.UI_Handbook_Scene_3Day,
		uiType = UIConst.PANEL_LAYER,
		addBlackChange = {
			0.1,
			0.3
		}
	},
	[UIConst.UI_ID_PET_RESEARCH_PET_REWARD] = {
		fullScreen = true,
		resID = "$UI_Pb_PetManual_ResearchProgress.prefab",
		module = "petResearchPetReward",
		bgm = "BGM_UI_PetManual",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_RESEARCH_FRONT_PAGE] = {
		module = "petResearchFrontPage",
		bgm = "BGM_UI_PetManual",
		resID = "$UI_Pb_ElectronicManual.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_RESEARCH_FRONT_PAGE_V2] = {
		module = "petResearchFrontPageV2",
		bgm = "BGM_UI_PetManual",
		resID = "$UI_Pb_ElectronicManual_New.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_RESEARCH_COUNTRY_PAGE] = {
		fullScreen = true,
		resID = "$UI_Pb_ElectronicManual_NationalCollection.prefab",
		module = "petResearchCountryPage",
		bgm = "BGM_UI_PetManual",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PHOTO] = {
		blockCommonQuit = true,
		noBgmAttenuation = true,
		resID = "$UI_Pb_PhotographNew.prefab"
	},
	[UIConst.UI_ID_ALBUM] = {
		module = "album",
		fullScreen = true,
		resID = "$UI_Pb_PetManual_Album.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_ALBUM_SINGLE_PHOTO] = {
		module = "albumPhoto",
		fullScreen = true,
		resID = "$UI_Pb_PetManual_Album_ViewPhoto.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_FIRST_SHOW] = {
		ignore = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Hud_PetFirst.prefab",
		module = "firstPetShow",
		orderWidget = 100,
		fullScreen = false,
		uiType = UIConst.SCENE_LAYER,
		uiSceneName = UISceneConst.PET_FIRST_MEET,
		uiSceneResId = AddressDataConst.UI_First_Meet_Scene_Prefab,
		hideTipAreas = {
			TipAreaConst.AREAS.C,
			TipAreaConst.AREAS.CF
		}
	},
	[UIConst.UI_ID_PLAYER_RENAME] = {
		module = "playerRename",
		ignore = true,
		resID = "$UI_Pb_Pop_Personal_ToolTip.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_INTERACT_SECOND] = {
		module = "interactSecond",
		hideByOutOfView = true,
		resID = "$UI_Pb_Interaction.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PLAYER_SKILL_FILTER] = {
		module = "playerSkillFilter",
		ignore = true,
		resID = "$UI_Node_Personal_Filter.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_RESEARCH_PREVIEW_STAR_POPUP] = {
		module = "playerResearchStarPreview",
		ignore = true,
		resID = "$UI_Pop_CampCar_LevelRewards.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_RESEARCH_LOADING] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_ElectronicManual_LoadingPage.prefab",
		module = "petResearchLoading",
		orderWidget = 1000,
		ignore = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_PET_RESEARCH] = {
		blockCommonQuit = true,
		blackBgDuration = 1,
		bgm = "BGM_UI_PetManual",
		addBlackChange = {
			0.1,
			0.3
		}
	},
	[UIConst.UI_ID_BOTTOM_DIALOGUE] = {
		blockCommonQuit = true,
		hideTipAreas = {
			TipAreaConst.AREAS.C,
			TipAreaConst.AREAS.CF
		}
	},
	[UIConst.UI_ID_PET_REPORT] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_PetManual_SubmitPetReport.prefab",
		module = "petReport",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_BOSS_DUNGEON] = {
		module = "activeDungeon",
		fullScreen = true,
		resID = "$UI_Pb_GameDungeonInfo.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_FISSURE_MAIN] = {
		fullScreen = true,
		resID = "$UI_Pb_GameMode_Fissure_Main.prefab",
		module = "fissure",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_FISSURE_INFO] = {
		fullScreen = true,
		resID = "$UI_Pb_GameMode_Fissure_Buff_Pop.prefab",
		module = "fissureInfo",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PVP_REWARD] = {
		blockCommonQuit = true,
		uiSceneName = UISceneConst.PVP_REWARD_SCENE,
		uiSceneResId = AddressDataConst.PVP_MAIN_REWARD
	},
	[UIConst.UI_ID_CHAT] = {
		enableMainCamera = true,
		disableVirtualMouseToggle = true,
		MutexDisplay = true,
		fullScreen = true
	},
	[UIConst.UI_ID_PVP_MENU] = {
		blockCommonQuit = true,
		uiSceneName = UISceneConst.PVP_TEAM_SCENE,
		uiSceneResId = AddressDataConst.PVP_MAIN_PET_NAME
	},
	[UIConst.UI_ID_TEAM_ROOM] = {
		hairLayerCount = 8,
		fullScreen = true,
		blockCommonQuit = true,
		addBlackChange = {
			0.1,
			0.3
		},
		uiSceneName = UISceneConst.TEAM_ROOM_SCENE,
		uiSceneResId = AddressDataConst.TeamRoomScene
	},
	[UIConst.UI_ID_PET_TRAINING_NEW] = {
		bgm = "BGM_UI_GrowthInterface",
		keepUISceneOnPanelCovered = true,
		uiSceneName = UISceneConst.PET_MANAGEMENT_TRAINING_SCENE2,
		uiSceneResId = AddressDataConst.UI_PET_MANAGEMENT_TRAINING_SCENE2
	},
	[UIConst.UI_ID_PET_INHERITANCE_MAIN] = {
		fullScreen = true,
		timeStop = 1,
		resID = "$UI_Pb_PetManage_InheritWait.prefab",
		module = "petInheritMain",
		orderWidget = 1000,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_INHERITANCE_MAIN_SCENE,
		uiSceneResId = AddressDataConst.PET_EXCHANGE_WAIT_SCENE_Prefab
	},
	[UIConst.UI_ID_PET_INHERITANCE_CHOOSE] = {
		module = "petInheritChoose",
		resID = "$UI_Pb_PetManage_Inherit_SelPet.prefab",
		timeStop = 1,
		orderWidget = 1000,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_INHERITANCE_CHOOSE_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_PET_INHERITANCE_RESULT] = {
		module = "petInheritResult",
		resID = "$UI_Pop_PetManage_Inherited.prefab",
		timeStop = 1,
		orderWidget = 1000,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_PET_EVOLVE_PET_SHOW] = {
		blockCommonQuit = true,
		resID = "$UI_Pb_Manual_Evolve_PetShowNew.prefab"
	},
	[UIConst.UI_ID_PVP_BATTLE] = {
		resID = "$UI_Pb_PVP.prefab"
	},
	[UIConst.UI_ID_PVP_CHOSE] = {
		blockCommonQuit = true,
		uiSceneName = UISceneConst.PVP_BP_SCENE,
		uiSceneResId = AddressDataConst.PVP_MAIN_CHOSE_BP
	},
	[UIConst.UI_ID_CREATE_PLAYER_PANEL] = {
		fullScreen = false,
		isModel = true,
		resID = "$UI_Pb_Avatar_Naming.prefab",
		module = "createPlayer",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PHOTO_SHOW] = {
		module = "photoShow",
		resID = "$UI_Pb_Photography_VideoDetails.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CHAT_PHOTOGRAPH] = {
		module = "chatPhotograph",
		resID = "$UI_Popup_Chat_Photograph_View.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_TRAIT_POPUP_DETAIL] = {
		module = "traitPopupDetail",
		fullScreen = true,
		resID = "$UI_Pb_Popup_HabitDetails.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_SHOP_MAIN] = {
		orderWidget = 1000,
		fullScreen = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_SHOP_TRANS] = {
		module = "shopTrans",
		orderWidget = 10001,
		resID = "$UI_Pb_Shop_ARKTransition.prefab",
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_SHOP_ARK] = {
		fullScreen = true,
		resID = "$UI_Pb_Shop_ARK.prefab",
		module = "shopARK",
		orderWidget = 1000,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.AFK_SHOP_SCENE
	},
	[UIConst.UI_ID_TOWER_BUFF_DETAIL] = {
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_FUNC_MENU_UNLOCK] = {
		module = "funcMenuUnlock",
		fullScreen = true,
		resID = "$UI_Pb_Function_Unlock.prefab",
		blockCommonQuit = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_DUNGEON_INVITE] = {
		module = "dungeonInvite",
		fullScreen = false,
		resID = "$UI_Node_TeamRoom_InviteFloat.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_OVERVIEW] = {
		module = "petOverview",
		fullScreen = true,
		resID = "$UI_Pb_PetManual_Overview.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PUZZLE] = {
		fullScreen = true,
		resID = "$UI_Pb_Jigsaw.prefab",
		module = "puzzle",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_PLATEINFO] = {
		fullScreen = true,
		resID = "$UI_Pb_Home_PlateInfo.prefab",
		module = "homelandPlateInfo",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_COMMON_CONFIRM] = {
		orderWidget = 2000,
		blockCommonQuit = true,
		resID = "$UI_Pb_Common_Tip_Warn.prefab",
		module = "commonConfirm",
		timeStop = 1,
		enableMainCamera = true,
		syncLoad = true,
		fullScreen = true,
		isModel = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_DIALOGUE_SKIP] = {
		orderWidget = 2000,
		blockCommonQuit = true,
		resID = "$UI_Pb_Dialogue_Skip.prefab",
		module = "dialogueSkip",
		timeStop = 1,
		enableMainCamera = true,
		syncLoad = true,
		fullScreen = true,
		isModel = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_PET_CONFIRM] = {
		resID = "$UI_Pop_PetSave_Confirm.prefab",
		module = "petConfirm",
		orderWidget = 1000,
		ignore = true,
		uiType = UIConst.INFOS_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_FUNC_MENU] = {
		fullScreen = false,
		forceShowTips = true,
		MutexDisplay = false,
		resID = "$UI_Pb_FunMenu_New.prefab",
		blockCommonQuit = true,
		hideTipAreas = UIConst.FUNC_MENU_HIDE_TIP
	},
	[UIConst.UI_ID_CHANGE_AVATAR] = {
		module = "changeAvatar",
		resID = "$UI_Pb_Popup_Menu_ChangeAvatar.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_GAMEPLAY_PROGRESS] = {
		module = "gameplayProgress",
		ignore = true,
		resID = "$UI_Pb_Popup_CommonInterobject_Countdown.prefab",
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_STATION_BUFF_COUNTDOWN] = {
		module = "stationBuffCountDown",
		ignore = true,
		resID = "$UI_Pb_Popup_StationBuff_CountDown.prefab",
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_SOUND_GAME] = {
		module = "soundGame",
		ignore = true,
		resID = "$UI_Pb_Hud_GameMod_Music.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_WORKSHOP_DESIGN] = {
		module = "workShopDesign",
		fullScreen = true,
		resID = "$UI_Pb_Avatar_Design_Entrance.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_WORKSHOP_COSTUME_STAIN] = {
		module = "workShopCostumeStain",
		fullScreen = true,
		resID = "$UI_Pb_Avatar_Dress_Design.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_WORKSHOP_SAVE_PRESET] = {
		module = "workShopSavePreset",
		fullScreen = true,
		resID = "$UI_Pop_Avatar_Design_SaveData.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_WORKSHOP_COVER_PRESET] = {
		module = "workShopCoverPreset",
		fullScreen = true,
		resID = "$UI_Pop_Avatar_Design_CoverData.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_EXCHANGE_SELECT] = {
		fullScreen = true,
		resID = "$UI_Pb_PetExchange_Select.prefab",
		module = "petExchangeSelect",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_PET_EXCHANGE_WAIT] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_PetExchange_Wait.prefab",
		module = "petExchangeWait",
		uiSceneName = UISceneConst.PET_EXCHANGE_WAIT_SCENE,
		uiSceneResId = AddressDataConst.PET_EXCHANGE_WAIT_SCENE_Prefab,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_EXCHANGE_COUNTDOWN] = {
		module = "petExchangeCountdown",
		blockCommonQuit = true,
		resID = "$UI_Pb_Exchange_CountDown.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_EXCHANGE_TIP] = {
		keepTextLinkOnOpen = true,
		gamepadPass = true,
		resID = "$UI_Node_PetExchange_Tips.prefab",
		module = "petExchangeTip",
		ignore = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_VARIANT_PROCESS] = {
		fullScreen = true,
		keepUISceneOnPanelCovered = true,
		resID = "$UI_Pb_MainClose.prefab",
		module = "petVariantProcess",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_VARIANT_PROCESS_SCENE,
		uiSceneResId = AddressDataConst.PET_VARIANT_PROCESS_SCENE
	},
	[UIConst.UI_ID_PET_VARIANT_RESULT] = {
		fullScreen = true,
		resID = "$UI_Pb_Popup_Levelup_New.prefab",
		module = "petVariantResult",
		uiType = UIConst.PANEL_LAYER,
		addBlurBg = {
			1
		}
	},
	[UIConst.UI_ID_PET_GIFT_TIPS] = {
		keepTextLinkOnOpen = true,
		gamepadPass = true,
		resID = "$UI_Node_Tip_PetCharInfo_Home.prefab",
		module = "petGiftTips",
		ignore = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_GIFT_TIPS_RECOMMEND] = {
		keepTextLinkOnOpen = true,
		resID = "$UI_Node_PetCharacter_Tips.prefab",
		module = "petGiftTipsRecommend",
		ignore = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_GUIDE_PANEL] = {
		hideTipAreas = {
			TipAreaConst.AREAS.A1,
			TipAreaConst.AREAS.A2,
			TipAreaConst.AREAS.A1I,
			TipAreaConst.AREAS.B,
			TipAreaConst.AREAS.BI
		}
	},
	[UIConst.UI_ID_PROP_SELECT] = {
		module = "propSelectCom",
		resID = "$UI_Pop_Map_LeylinesTree_AddProp.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CAPTURE_BALL] = {
		resID = "$UI_Node_Hud_BallOpen.prefab",
		module = "captureBall",
		platformSensitive = true,
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_THROW_PANEL] = {
		resID = "$UI_Pb_Hud_Panel_Throw.prefab",
		module = "throwPanel",
		platformSensitive = true,
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_CRAWL] = {
		resID = "$UI_Node_Hud_CrawlPanel.prefab",
		module = "crawl",
		platformSensitive = true,
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_QTE_TIMELINE] = {
		fullScreen = true,
		noBgmAttenuation = true,
		resID = "$UI_Pb_RapidClick.prefab",
		module = "qteTimeline",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_AVATAR] = {
		blockCommonQuit = true
	},
	[UIConst.UI_ID_AVATAR_MAIN] = {
		keepUISceneOnPanelCovered = true,
		resID = "$UI_Pb_Avatar_PinchFace_Entrance.prefab",
		module = "avatarMain",
		hairLayerCount = 8,
		fullScreen = true,
		fullScreenKeepBgm = true,
		uiType = UIConst.PANEL_LAYER,
		addBlackChange = {
			0.1,
			0.3
		},
		uiSceneName = UISceneConst.AVATAR_SCENE,
		uiSceneResId = AddressDataConst.AVATAR_ACCESSORY_RES
	},
	[UIConst.UI_ID_APPEARANCE_PREVIEW] = {
		module = "appearancePreview",
		fullScreen = true,
		resID = "$UI_Pb_Appearance_Preview.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_AVATAR_TIP] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pop_Avatar_PinchFace_Save.prefab",
		module = "avatarTip",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_ACCESSORY] = {
		module = "accessoryPet",
		fullScreen = true,
		resID = "$UI_Pb_Avatar_PetAccessories.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_ACCESSORY_PRESET] = {
		module = "accessoryPetPreset",
		fullScreen = true,
		resID = "$UI_Pb_Avatar_Panel_Outfit.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_ACCESS_PET_BOX] = {
		module = "accessoryPetBox",
		fullScreen = true,
		resID = "$UI_Pb_Avatar_PetBox.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_SKIP_PANEL] = {
		module = "SkipPanel",
		blockCommonQuit = true,
		resID = "$UI_Pb_SkipPanel.prefab",
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_SUBTITLES_PANEL] = {
		syncLoad = true,
		isModel = false,
		resID = "$UI_Pb_Subtitles.prefab",
		module = "SubtitlesPanel",
		ignore = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_ITEM_VIEWER] = {
		fullScreen = true,
		resID = "$UI_Pb_ItemView.prefab",
		module = "itemViewer",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.ITEM_VIEWER_SCENE,
		uiSceneResId = AddressDataConst.ITEM_VIEWER_CONTAINER,
		addBlackChange = {
			0.1,
			0.3
		}
	},
	[UIConst.UI_ID_PIECES_ITEM_PANEL] = {
		module = "PiecesItemTip",
		fullScreen = true,
		resID = "$UI_Pb_FragmentInfo.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_NPC_EVENT_CHAIN] = {
		fullScreen = true,
		orderWidget = 10,
		resID = "$UI_Pb_Npc_ViewEvents.prefab",
		module = "QuestNpcEventChain",
		noBgmAttenuation = true,
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_OPEN_SPECIAL_TRAIN_PANEL] = {
		orderWidget = 10,
		blockCommonQuit = true,
		resID = "$UI_Pb_Train_MainPanel.prefab",
		module = "SpecialTrainNew",
		enableMainCamera = true,
		fullScreen = true,
		uiSceneName = UISceneConst.PET_SPECIAL_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_SPECIAL_TRAIN_SCENE_Prefab,
		uiType = UIConst.PANEL_LAYER,
		functionID = Const.FUNCTION_IDS.SPECIALTRAIN,
		addBlackChange = {
			0.1,
			0.3
		}
	},
	[UIConst.UI_ID_SPECIAL_TRAIN_CHAPTER_TIP_PANEL] = {
		module = "SpecialTrainChapterTip",
		isModel = false,
		resID = "$UI_Pb_Train_ChapterTips.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_INVENTORY_ITEM_USE] = {
		module = "InventoryItemUse",
		fullScreen = true,
		resID = "$UI_Pop_Inventory_ItemUse_New.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_QR_CODE] = {
		module = "QRCode",
		fullScreen = true,
		resID = "$UI_Pb_QRCode.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_INVENTORY_DECOMPOSE] = {
		module = "InventoryDecompose",
		fullScreen = true,
		resID = "$UI_Pop_InventoryRecycle_Confirm.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_INVENTORY_PET_PROP_USE] = {
		fullScreen = true,
		resID = "$UI_Pb_Inventory_UseProp.prefab",
		module = "InventoryPetPropUse",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_PET_PROP_USE_RESULT] = {
		module = "PetPropUseResult",
		fullScreen = true,
		resID = "$UI_Pb_Popup_UseProp.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_INVENTORY] = {
		blurBg = true,
		resID = "$UI_Pb_Inventory_New.prefab",
		blockCommonQuit = true,
		enableMainCamera = true,
		functionID = Const.FUNCTION_IDS.BAG
	},
	[UIConst.UI_ID_ELEMENT_STRENGTHEN_DETAILS] = {
		module = "elementStrengthenDetails",
		resID = "$UI_Pop_ElementStrengthen_Details.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_CHANGE_FORM] = {
		module = "PetChangeForm",
		fullScreen = true,
		resID = "$UI_Pb_Popup_PetRaising.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_CHANGE_FORM_SMALL] = {
		module = "PetChangeFormSmall",
		fullScreen = true,
		resID = "$UI_Pb_Popup_PetRaisingSmall.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PVP_FRIEND] = {
		module = "pvpFriend",
		fullScreen = true,
		resID = "$UI_Pb_Popup_PvpBattle_InviteFriends.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_AI_ASSISTANT] = {
		lockCursor = true,
		blockCommonQuit = true,
		resID = "$UI_Node_Guide_Plot.prefab",
		module = "aiAssistant",
		orderWidget = 10,
		uiType = UIConst.SCENE_LAYER,
		hideTipAreas = {
			TipAreaConst.AREAS.B,
			TipAreaConst.AREAS.BI
		}
	},
	[UIConst.UI_ID_SURVEY] = {
		module = "Survey",
		fullScreen = true,
		resID = "$UI_Pb_Popup_ResearchTime.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_ANNOUNCEMENT] = {
		fullScreen = true,
		blurBg = true,
		resID = "$UI_Pb_Popup_GameAnnouncement.prefab",
		module = "announcement",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CATCHBOSS] = {
		blockCommonQuit = true,
		resID = "$UI_Pb_CatchBoss.prefab",
		module = "catchBoss",
		orderWidget = 10,
		uiType = UIConst.SCENE_LAYER,
		hideTipAreas = {
			TipAreaConst.AREAS.CF
		}
	},
	[UIConst.UI_ID_CATCHBOSS_NEW] = {
		blockCommonQuit = true,
		resID = "$UI_Pb_CatchBoss_New.prefab",
		module = "catchBossNew",
		orderWidget = 10,
		uiType = UIConst.SCENE_LAYER,
		hideTipAreas = {
			TipAreaConst.AREAS.CF
		}
	},
	[UIConst.UI_ID_BRANCH_LINE] = {
		fullScreen = true,
		resID = "$UI_Pb_Popup_MapBranchList.prefab",
		module = "branchLine",
		orderWidget = 10,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PICTURE] = {
		module = "picture",
		blockCommonQuit = true,
		resID = "$UI_Pb_Image.prefab",
		isModel = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_PET_DETAIL] = {
		syncLoad = true,
		fullScreen = true,
		resID = "$UI_Pb_Train_PetDetails.prefab",
		module = "PetDetailTip",
		orderWidget = 30,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_TRAIN_PREFERENCE] = {
		fullScreen = true,
		resID = "$UI_Pb_Train_Preference.prefab",
		module = "TrainPreference",
		orderWidget = 20,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_NPC_CALL_MULTIPLE] = {
		module = "NpcCallMultiple",
		resID = "$UI_Pb_AiCommunicate_PhoneCallMultiple.prefab",
		uiType = UIConst.POPUP_LAYER,
		hideTipAreas = {
			TipAreaConst.EDGE_AREAS.Quest
		}
	},
	[UIConst.UI_ID_VITALITY] = {
		isModel = true,
		resID = "$UI_Pb_Popup_VitalityValue.prefab",
		module = "debugVitality",
		ignore = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_VITALITY_V0] = {
		module = "vitalityV0",
		resID = "$UI_Pb_Pop_EnergySystem.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_VITALITY_GOT] = {
		module = "vitalityGot",
		resID = "$UI_Pb_Pop_EnergySupplement.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_VITALITY_REDEEM] = {
		module = "vitalityRedeem",
		resID = "$UI_Pb_Popup_HomeManufacture.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_GUIDE_MODE] = {
		module = "GuideMode",
		fullScreen = true,
		resID = "$UI_Pb_GuideSettings.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_CHARACTER_APPEARANCE] = {
		module = "QuestCharacterAppearance",
		fullScreen = true,
		resID = "$UI_Pb_NameIn.prefab",
		noBgmAttenuation = true,
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER,
		openAudio = AudioConst.EVENT_CHARACTER_DEBUT
	},
	[UIConst.UI_ID_QUEST_ARRIVAL_TIP] = {
		fullScreen = true,
		resID = "$UI_Pb_Dynamic_Text.prefab",
		module = "QuestArrivalTip",
		enableMainCamera = true,
		ignore = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_DEAD_PANEL] = {
		blockCommonQuit = true,
		resID = "$UI_Pb_Reborn_New.prefab"
	},
	[UIConst.UI_ID_APPEARANCE_V2] = {
		hairLayerCount = 8,
		keepUISceneOnPanelCovered = true,
		blockCommonQuit = true,
		addBlackChange = {
			0.1,
			0.3
		},
		uiSceneName = UISceneConst.AVATAR_SCENE,
		uiSceneResId = AddressDataConst.AVATAR_ACCESSORY_RES,
		uiSceneVisibleBypassUIHideKeys = {
			[UIConst.UI_HIDE_KEY.APPEARANCE] = true
		}
	},
	[UIConst.UI_ID_AVATAR_IMPORT] = {
		module = "avatarImport",
		fullScreen = true,
		resID = "$UI_Node_Avatar_LoadData.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_AVATAR_IMPORT_CONFIRM] = {
		module = "avatarImportConfirm",
		fullScreen = true,
		resID = "$UI_Node_Avatar_LoadData_Confirrm.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_SHARE] = {
		module = "share",
		fullScreen = true,
		resID = "$UI_Node_Photograph_PhotoShow.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HUD_SCREENSHOT_SHARING] = {
		module = "hudScreenshotSharing",
		fullScreen = true,
		resID = "$UI_Popup_Hud_Screenshot_Sharing.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_FERTILITY_INCUBATE] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_PetFertility_Incubate.prefab",
		module = "PetFertilityIncubate",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.SOUL_EGG_EVOLUTION_SCENE,
		uiSceneResId = AddressDataConst.UI_EVOLUTION_LIGHT_SCENE
	},
	[UIConst.UI_ID_PET_FERTILITY_INCUBATE_RESULT] = {
		module = "PetFertilityIncubateResult",
		blockCommonQuit = true,
		resID = "$UI_Pb_PetFertility_Incubate_ResultGet.prefab",
		isModel = false,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.SOUL_EGG_EVOLUTION_SCENE,
		uiSceneResId = AddressDataConst.UI_EVOLUTION_LIGHT_SCENE
	},
	[UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL] = {
		resID = "$UI_Pb_PetFerility_ChooseBall.prefab",
		module = "petFertilityChooseBall",
		orderWidget = 1000,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.SOUL_EGG_EVOLUTION_SCENE,
		uiSceneResId = AddressDataConst.UI_EVOLUTION_LIGHT_SCENE
	},
	[UIConst.UI_ID_PET_FERTILITY_POPUP_CHOOSE_BALL] = {
		module = "petFertilityChooseBallPopup",
		resID = "$UI_Pb_Popup_PetFertility_ChooseBall.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_FERTILITY_HATCH_SCENE_HOST] = {
		module = "petFertilityHatchSceneHost",
		resID = "$UI_Pb_MainClose.prefab",
		isModel = false,
		orderWidget = -2,
		ignore = true,
		uiType = UIConst.SCENE_LAYER,
		uiSceneName = UISceneConst.SOUL_EGG_EVOLUTION_SCENE,
		uiSceneResId = AddressDataConst.UI_EVOLUTION_LIGHT_SCENE
	},
	[UIConst.UI_ID_COMMON_SKIP_PANEL] = {
		isModel = false,
		openAudio = "",
		resID = "$UI_Pb_CommonSkipPanel.prefab",
		module = "CommonSkip",
		blockCommonQuit = true,
		orderWidget = 1000,
		ignore = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_BLACK_SCREEN_SKIP_PANEL] = {
		fullScreen = true,
		forceHideTips = true,
		resID = "$UI_Pb_BlackScreen_Skip.prefab",
		module = "BlackScreenSkip",
		orderWidget = 2000,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_LIVE_STREAMING] = {
		blockCommonQuit = true,
		fullScreen = true,
		resID = "$UI_Pb_LiveStreaming.prefab",
		module = "LiveStreaming",
		orderWidget = 9,
		enableMainCamera = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_DIALOGUE_ID] = {
		blockCommonQuit = true,
		resID = "$UI_Pb_Dialogue_ID.prefab",
		module = "DialogueID",
		orderWidget = 10000,
		ignore = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_PET_FERTILITY] = {
		resID = "$UI_Pb_PetFertility_Incubator.prefab",
		uiSceneName = UISceneConst.PET_BALL_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_BALL_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_ROG_ULTIMATE_UPGRADE] = {
		blockCommonQuit = true,
		fullScreen = false,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_ROG_ULTIMATE_UNLOCK] = {
		blockCommonQuit = true
	},
	[UIConst.UI_ID_PET_SELECTION_PANEL_NEW] = {
		fullScreen = true,
		noBgmAttenuation = true,
		resID = "$UI_Pb_PetSelection_UI.prefab",
		module = "PetSelectionPanelNew",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_SKILL_REPLACE_QUICK] = {
		gamepadModel = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PLAYER_LV_REWARD] = {
		fullScreen = true,
		resID = "$UI_Pb_PersonalLevelUp.prefab",
		module = "playerLvReward",
		bgm = "BGM_Panel_PlayerEnhancement",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PLAYER_ASSESS] = {
		module = "playerAssess",
		fullScreen = true,
		resID = "$UI_Tips_Assessment_Page_Popup.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOMELAND_EDITOR] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Home_Editor.prefab",
		module = "homelandEditor",
		allowNavWithMouse = true,
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER,
		openAudio = AudioConst.EVENT_HOME_ARCHITECTURE_MODEL
	},
	[UIConst.UI_ID_HOMELAND_PLACE_EDITOR] = {
		fullScreen = true,
		resID = "$UI_Pb_Home_Placement.prefab",
		module = "homelandPlacement",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOMELAND_MULTI_SELECT] = {
		fullScreen = true,
		allowNavWithMouse = true,
		resID = "$UI_Pb_Home_MultipleChoice.prefab",
		module = "homelandMultiSelect",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_SET_FORMULA] = {
		fullScreen = true,
		resID = "$UI_Pb_Popup_HomeItemSet.prefab",
		module = "homelandSetFormula",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_FACILITY_INFO] = {
		fullScreen = true,
		resID = "$UI_Pb_Home_ItemInfo.prefab",
		module = "homelandFacilityInfo",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_FACILITY_INFO_TIP] = {
		keepTextLinkOnOpen = true,
		resID = "$UI_Node_HomeItemState.prefab",
		module = "homelandFacilityInfoTip",
		orderWidget = 98,
		ignore = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_HOME_FACILITY_SET_PET] = {
		fullScreen = true,
		resID = "$UI_Pb_PetSelectPanel2.prefab",
		module = "homelandFacilitySelectPet",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_HOME_FACILITY_INFO_DETAIL] = {
		keepTextLinkOnOpen = true,
		resID = "$UI_Node_HomeItemStateDetails.prefab",
		module = "homelandFacilityInfoDetail",
		orderWidget = 98,
		ignore = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_HOME_MUSIC_PLAYER] = {
		fullScreen = false,
		isModel = true,
		resID = "$UI_Pop_Home_MusicPlayer.prefab",
		module = "homeMusicPlayer",
		noBgmAttenuation = true,
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_GASHAPON] = {
		fullScreen = false,
		isModel = true,
		resID = "$UI_Pb_Home_EggMachine.prefab",
		module = "homeGashapon",
		noBgmAttenuation = true,
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_GASHAPON_RULE] = {
		fullScreen = false,
		noBgmAttenuation = true,
		resID = "$UI_Pop_Home_EggMachine.prefab",
		module = "homeGashaponRule",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOMELAND_PET_MANAGEMENT_NEW] = {
		fullScreen = true,
		resID = "$UI_Pb_Home_ManagePet.prefab",
		module = "homelandPetManageNew",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_HOMELAND_PLOT_MANAGEMENT_NEW] = {
		module = "homelandPlotManageNew",
		fullScreen = true,
		resID = "$UI_Pb_Home_ManagePlot.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOMELAND_AREA_MANAGE] = {
		fullScreen = true,
		disableVirtualMouseToggle = true,
		module = "homelandAreaManage",
		resID = AddressDataConst.HOME_UI_PANEL_AREA,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOMELAND_FURNITURE_DESIGN] = {
		module = "homelandFurnitureDesign",
		fullScreen = true,
		resID = "$UI_Pb_Home_FurnitureDesign.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOMELAND_FURNITURE_COMPOSE_DETAIL] = {
		module = "homelandFurnitureComposeDetail",
		fullScreen = true,
		resID = "$UI_Pb_Home_FurnitureCompose.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PVP_PET_SET] = {
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_HOME_INVENTORY] = {
		fullScreen = true,
		resID = "$UI_Pb_Home_WareHouse.prefab",
		module = "homelandInventory",
		uiType = UIConst.PANEL_LAYER,
		openAudio = AudioConst.EVENT_HOME_STOREHOUSE_OPEN
	},
	[UIConst.UI_ID_GAMEPAD_MENU] = {
		fullScreen = true,
		resID = "$UI_Node_Hud_Function_Console.prefab",
		module = "gamepadMenu",
		enableMainCamera = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_GAMEPAD_MENU_NEW] = {
		fullScreen = true,
		isModel = true,
		resID = "$UI_Pb_Hud_Function_Wheel_Console.prefab",
		module = "gamepadMenuNew",
		orderWidget = 8000,
		enableMainCamera = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_HOMELAND_PET_ACTION] = {
		fullScreen = true,
		resID = "$UI_Pb_Home_PetReport_In.prefab",
		module = "homelandPetAct",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOMELAND_LEVEL_UP] = {
		module = "homelandLevelUp",
		fullScreen = true,
		resID = "$UI_Pb_Popup_Home_ItemUpGrade.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOMELAND_EDITOR_TOPLOGO] = {
		syncLoad = true,
		module = "homelandEditorTopLogo",
		orderWidget = -1,
		resID = AddressDataConst.HOME_EDITOR_TOPLOGO_PANEL,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_HOMELAND_EDITOR_SETTING] = {
		fullScreen = true,
		module = "homelandEditorSetting",
		enableMainCamera = true,
		resID = AddressDataConst.HOME_EDITOR_SETTING,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOMELAND_PLAYER_EDITOR_SETTING] = {
		fullScreen = true,
		resID = "$UI_Pop_Home_SettingEdit.prefab",
		module = "homelandPlayerEditorSetting",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOMELAND_FURNITURE_STORE] = {
		addBlackChangeOnClose = true,
		resID = "$UI_Node_Home_FurnitureStore.prefab",
		module = "homelandFurnitureStore",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.FURNITURE_STORE_SCENE,
		uiSceneResId = AddressDataConst.ITEM_VIEWER_CONTAINER,
		addBlackChange = {
			0.1,
			0.5
		}
	},
	[UIConst.UI_ID_HOMELAND_MAIN_PAGE] = {
		fullScreen = true,
		resID = "$UI_Pb_Home_CampingCar_Main.prefab",
		module = "homelandMainPage",
		keepUISceneOnPanelCovered = true,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.HOME_CAR_SCENE,
		uiSceneResId = AddressDataConst.UI_HOME_CAR_SCENE,
		addBlackChange = {
			0.1,
			0.5
		}
	},
	[UIConst.UI_ID_HOMELAND_CAR_LEVEL_UP] = {
		fullScreen = true,
		resID = "$UI_Pb_Home_CampingCar_Expansion.prefab",
		module = "homeCarLevelUp",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.HOME_CAR_SCENE,
		uiSceneResId = AddressDataConst.UI_HOME_CAR_SCENE
	},
	[UIConst.UI_ID_HOMELAND_CAR_COMP_LEVEL_UP] = {
		fullScreen = true,
		resID = "$UI_Pb_Home_CampingCar_Levelup.prefab",
		module = "homeCarLevelUpComp",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.HOME_CAR_SCENE,
		uiSceneResId = AddressDataConst.UI_HOME_CAR_SCENE
	},
	[UIConst.UI_ID_HOME_ORDER] = {
		module = "homeOrder",
		fullScreen = true,
		resID = "$UI_Pb_HomeOrder.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_BOOK] = {
		fullScreen = true,
		keepUISceneOnPanelCovered = true,
		resID = "$UI_Pb_HomeCollection_Main.prefab",
		module = "homeBook",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.FURNITURE_STORE_SCENE,
		uiSceneResId = AddressDataConst.ITEM_VIEWER_CONTAINER
	},
	[UIConst.UI_ID_HOME_SEASON_COLLECTIONCROP] = {
		module = "homelandCollectionCrop",
		fullScreen = true,
		resID = "$UI_Pb_HomeCollection_SeasonMain.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_SEASON_COLLECTIONCROP_DETAIL] = {
		module = "homelandCollectionCropDetail",
		fullScreen = true,
		resID = "$UI_Pb_HomeCollection_SeasonDetails.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_SEASON_COLLECTIONCROP_DECOMPOSE] = {
		module = "homelandCollectionCropDecompose",
		fullScreen = true,
		resID = "$UI_Pop_HomeCollection_Decompose.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_BOOK_FURNITURE_SET] = {
		module = "homeBookFurnitureSet",
		fullScreen = true,
		resID = "$UI_Pb_HomeCollection_FurnitureSet.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_BOOK_SCORE_REWARD] = {
		module = "homeBookScoreReward",
		fullScreen = true,
		resID = "$UI_Pb_HomeCollection_ScoreReward.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_BOOK_SCORE_POPUP] = {
		module = "homeBookScorePopup",
		fullScreen = true,
		resID = "$UI_Pop_HomeCollection_Score.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOME_BOOK_SEASON] = {
		fullScreen = true,
		keepUISceneOnPanelCovered = true,
		resID = "$UI_Pb_HomeCollection_Season.prefab",
		module = "homeBookSeason",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.FURNITURE_STORE_SCENE,
		uiSceneResId = AddressDataConst.ITEM_VIEWER_CONTAINER
	},
	[UIConst.UI_ID_HOME_BOOK_CROP_DETAIL] = {
		module = "homeBookCropDetail",
		fullScreen = true,
		resID = "$UI_Pb_HomeCollection_DetailsCrop.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_BOOK_FURNITURE_DETAIL] = {
		module = "homeBookFurnitureDetail",
		fullScreen = true,
		resID = "$UI_Pb_HomeCollection_DetailsSuit.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_PET_ELEMENT_ABILITY] = {
		module = "homePetElementAbility",
		resID = "$UI_Pop_Home_PetElementAbility.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOME_PET_APPEARANCE_ABILITY] = {
		module = "homePetAppearanceAbility",
		resID = "$UI_Pop_Home_PetAppearanceAbility.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_INTIMACY] = {
		isModel = true,
		resID = "$UI_Pb_Popup_PetIntimacy.prefab",
		module = "petIntimacy",
		orderWidget = 2001,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_HOME_PLANTS_MANUAL_DETAIL] = {
		module = "homePlantsManualDetail",
		resID = "$UI_Pb_Home_PokedexDetails.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_PLANTS_SEND] = {
		module = "homePlantsSend",
		resID = "$UI_Pb_HomeCollection_Friendl_Popup.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOMECAMP_INVITE_FRIEND] = {
		module = "homeCampInviteFriend",
		resID = "$UI_Pop_Home_Station_InviteFriend.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOMECAMP_STATION_SETTING] = {
		module = "homeCampStationSetting",
		resID = "$UI_Pop_Home_StationSetting.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOME_SEASON_MAIN_PAGE] = {
		module = "homelandSeasonMainPage",
		fullScreen = true,
		resID = AddressDataConst.HOME_ID_SEASON_MAIN_PAGE,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_SEASON_INTRO] = {
		module = "homelandSeasonIntro",
		fullScreen = true,
		resID = AddressDataConst.HOME_ID_SEASON_INTRO,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOME_SEASON_CELEBRATION_PREPARE] = {
		module = "homelandSeasonCelebrationPrepare",
		resID = "$UI_Pop_Home_SeasonalEvent_HarvestInvite.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_SEASON_CELEBRATION_INVITE] = {
		module = "homelandSeasonCelebrationInvite",
		resID = "$UI_Pb_Chat_Friendl_Popup.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOME_SEASON_CELEBRATION_START] = {
		module = "homelandSeasonCelebrationStart",
		resID = "$UI_Pb_Hud_HomeSeasonalEvent_Tips.prefab",
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_HOME_SEASON_DAILY_TASK] = {
		module = "homelandSeasonDailyTask",
		fullScreen = true,
		resID = "$UI_Pb_Home_SeasonalEvent_Daily.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_SEASON_PREPARE] = {
		module = "homelandSeasonPrepare",
		fullScreen = true,
		resID = "$UI_Pb_Home_SeasonalEvent_Prepare.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_SEASON_PARTY] = {
		module = "homelandSeasonParty",
		resID = "$UI_Pop_Home_SeasonalEvent_Harvest.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_TOWER_STAGE_INFO] = {
		resID = "$UI_Pb_Tower_PairView.prefab"
	},
	[UIConst.UI_ID_TOWER_PAUSE] = {
		fullScreen = true,
		resID = "$UI_Pb_PausePanel.prefab",
		module = "towerPause",
		enableMainCamera = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PAUSE_PANEL] = {
		fullScreen = true,
		resID = "$UI_Pb_PausePanel.prefab",
		module = "pausePanel",
		enableMainCamera = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_FUNC_MENU_EXIT] = {
		fullScreen = true,
		resID = "$UI_Pop_FunMenu_Exit.prefab",
		module = "funMenuExit",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_CASH_SHOP] = {
		fullScreen = true,
		keepUISceneOnPanelCovered = true,
		resID = "$UI_Pb_CashShop.prefab",
		module = "cashShop",
		hairLayerCount = 8,
		mobileHighQuality = true,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.CASH_SCENE,
		addBlackChange = {
			0.1,
			0.3
		},
		uiSceneResId = AddressDataConst.CASH_SHOP_SCENE
	},
	[UIConst.UI_ID_CASH_GIFT] = {
		module = "cashGift",
		resID = "$UI_Pop_GiftDetails.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CASH_SEARCH] = {
		module = "cashSearch",
		resID = "$UI_Node_CashShop_SearchAppearance.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CASH_FILTER] = {
		module = "cashFilter",
		resID = "$UI_Node_CashShop_FilterSort.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CASH_ACCESSORY_ADJUST] = {
		module = "cashShopAccessoryAdjust",
		resID = "$UI_Pb_CashShop_Accessory.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_CASH_CONFIRMATION_SCREEN] = {
		module = "cashConfirmationScreen",
		resID = "$UI_Pb_Confirmation_Screen.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CASH_CART] = {
		module = "cashCart",
		resID = "$UI_Pop_ManageCart.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CASH_SHOP_PENALTY_TIP] = {
		module = "cashShopPenaltyTip",
		resID = "$UI_Node_TextInfo.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_LOTTERY] = {
		fullScreen = true,
		resID = "$UI_Pb_Event_Lottery_Panel.prefab",
		module = "lottery",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.LOTTERY_SCENE
	},
	[UIConst.UI_ID_LOTTERY_OTHER_REWARD] = {
		module = "lotteryOtherReward",
		resID = "$UI_Pb_Popup_Event_Lottery.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_LOTTERY_SHOP] = {
		module = "lotteryShop",
		fullScreen = true,
		resID = "$UI_Pb_Event_Lottery_Shop.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_LOTTERY_REWARD] = {
		module = "lotteryReward",
		resID = "$UI_Pop_Event_Lottery_Reward.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_LOTTERY_REWARD_SHARE] = {
		module = "lotteryRewardShare",
		resID = "$UI_Pop_Event_Lottery_Reward_Share.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_LOTTERY_RESULT] = {
		module = "lotteryResult",
		resID = "$UI_Pb_Event_Lottery_Result.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_LOTTERY_HISTORY] = {
		module = "lotteryHistory",
		resID = "$UI_Pop_Lottery_History.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_BP_PERMIT] = {
		resID = "$UI_Pb_BP_Permit.prefab",
		module = "battlePass",
		keepUISceneOnPanelCovered = true,
		fullScreen = true,
		functionID = Const.FUNCTION_IDS.BATTLEPASS,
		addBlackChange = {
			0.1,
			0.1
		},
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.BP_SCENE,
		uiSceneResId = AddressDataConst.BATTLE_PASS_RES
	},
	[UIConst.UI_ID_BP_EXCHANGE] = {
		module = "bpExchange",
		resID = "$UI_Pb_BP_CashShop_Exchange.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_BP_CORE_REWARD] = {
		module = "coreReward",
		resID = "$UI_Pb_BP_CoreReward.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_BP_OBTAIN] = {
		module = "bpObtain",
		resID = "$UI_Pb_BP_ObtainPanel.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_BUY_LV] = {
		module = "bpBuyLv",
		resID = "$UI_Pop_PurchaseLevel.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_BP_GIFT] = {
		module = "bpGift",
		resID = "$UI_Pop_BP_Gift.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_BP_PURCHASE] = {
		fullScreen = true,
		resID = "$UI_Pb_BP_PurchasePage.prefab",
		module = "bpPurchase",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.BP_PURCHASE_SCENE,
		uiSceneResId = AddressDataConst.BATTLE_PASS_RES2
	},
	[UIConst.UI_ID_GIFT_PACK_REWARD] = {
		module = "giftPackReward",
		resID = "$UI_Pop_GiftPack.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_BP_Get] = {
		module = "bpGet",
		resID = "$UI_Pb_Event_Get.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_Morphling] = {
		module = "Morphling",
		ignore = true,
		resID = "$UI_Pb_Hud_Morphling.prefab",
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_SEASON_LOBBY] = {
		module = "SeasonLobby",
		fullScreen = true,
		resID = "$UI_Pb_Event_Season.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_SEASON_SHOP] = {
		module = "seasonShop",
		fullScreen = true,
		resID = "$UI_Pb_Event_Season_Shop.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_SEASON_CALENDAR] = {
		fullScreen = true,
		blurBg = true,
		resID = "$UI_Pop_Event_Season_Overview.prefab",
		module = "seasonCalendar",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_SEASON_ACHIEVEMENT] = {
		module = "seasonAchievement",
		fullScreen = true,
		resID = "$UI_Pb_Event_Season_Achievement.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_SEASON_HEAD_TIPS] = {
		module = "SeasonHeadTips",
		fullScreen = true,
		resID = "$UI_Pop_Event_Season_Tips2.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_TOWER_LEVEL_DETAIL] = {
		module = "towerLevelDetail",
		resID = "$UI_Pb_Tower_LevelDetail_Frame.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_TOWER_WEEKLY_REWARD] = {
		module = "towerWeeklyReward",
		resID = "$UI_Pb_Tower_WeeklyRewards.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_TOWER_SELECT_PET] = {
		resID = "$UI_Pb_Tower_Team_Modification.prefab",
		module = "towerSelectPet",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_TOWER_SETTLEMENT] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Tower_Settlement.prefab",
		module = "towerSettlement",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_TOWER_SELECT_STYLE] = {
		module = "towerSelectStyle",
		fullScreen = true,
		resID = "$UI_Pb_Tower_StylePreselection.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_QUEST_VLOG] = {
		fullScreen = true,
		noBgmAttenuation = true,
		resID = "$UI_Pb_VlogShow.prefab",
		module = "QuestVlog",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_MAP_AREA_FILTER] = {
		module = "MapAreaFilter",
		gamepadModel = true,
		resID = "$UI_Popup_Quest_Place_Filtrate.prefab",
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_TOWER_EVENT_DIALOGUE] = {
		module = "towerEventDialogue",
		blockCommonQuit = true,
		resID = "$UI_Pb_Tower_Event_Dialogue.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_TOWER_FAST_TRAIN] = {
		module = "towerFastTrain",
		fullScreen = true,
		resID = "$UI_Pb_Tower_Training_Pop.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_TOWER_DAILY_REWARD] = {
		module = "towerDailyReward",
		fullScreen = true,
		resID = "$UI_Pb_Tower_DailyRewards.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_TOWER_SEASON_WEEKLY_REWARD] = {
		module = "towerSeasonWeeklyReward",
		resID = "$UI_Pb_Tower_WeeklyRewards_New_All.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_RECOMMEND_PET] = {
		module = "recommendPet",
		fullScreen = true,
		resID = "$UI_Pb_Popup_Recommend_Aniimo.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_CARRY_STRENGTH] = {
		fullScreen = true,
		resID = "$UI_Pb_PetManage_CarryStrengthen.prefab",
		module = "petCarryStrength",
		bgm = "BGM_UI_GrowthInterface",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_TRAINING_SCENE2,
		uiSceneResId = AddressDataConst.UI_PET_MANAGEMENT_TRAINING_SCENE2
	},
	[UIConst.UI_ID_PET_CARRY_STRENGTH_RESULT] = {
		module = "petCarryStrengthResult",
		fullScreen = true,
		resID = "$UI_Pop_PetManage_CarryStrengthen.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOMELAND_LEVEL_UP_RESULT] = {
		module = "homelandLevelUpResult",
		fullScreen = true,
		resID = "$UI_Pop_Home_LevelUp_Result.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_CARRY_ASSIST_STRENGTH] = {
		fullScreen = true,
		resID = "$UI_Pb_PetManage_CarryJewel_Compound.prefab",
		module = "petCarryAssistStrength",
		bgm = "BGM_UI_GrowthInterface",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_TRAINING_SCENE2,
		uiSceneResId = AddressDataConst.UI_PET_MANAGEMENT_TRAINING_SCENE2
	},
	[UIConst.UI_ID_PET_CARRY_ASSIST_STRENGTH_RESULT] = {
		module = "petCarryAssistStrengthResult",
		fullScreen = true,
		resID = "$UI_Pop_PetManage_CarryJewelCompound.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_CARRY_RECOMMEND] = {
		module = "petRecommendBatchCarry",
		fullScreen = false,
		resID = "$UI_Pop_PetManagement_RecommendBatch.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_SELECT_BOX] = {
		fullScreen = true,
		resID = "$UI_Pop_PetManage_CarryPetBox.prefab",
		module = "petSelectBox",
		uiType = UIConst.POPUP_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_PLAYER_INFO_CARD] = {
		isModel = false,
		fullScreen = true,
		resID = "$UI_Pb_PlayerInfoCard_Panel.prefab",
		module = "PlayerInfo",
		enableMainCamera = true,
		uiType = UIConst.POPUP_LAYER,
		uiSceneName = UISceneConst.MODEL_SCENE,
		uiSceneResId = AddressDataConst.UI_Model_Scene
	},
	[UIConst.UI_ID_INFO_PLAYER_CARD] = {
		module = "infoPlayerCard",
		gamepadModel = true,
		resID = "$UI_Pb_InfoPlayer_Card_Panel.prefab",
		isModel = false,
		blockCommonQuit = true,
		enableMainCamera = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_INFO_PLAYER_MAIN] = {
		blockCommonQuit = true,
		keepUISceneOnPanelCovered = true,
		resID = "$UI_Pb_InfoPlayer_Main.prefab",
		module = "infoPlayerMain",
		enableMainCamera = true,
		hairLayerCount = 8,
		fullScreen = true,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.AVATAR_SCENE,
		uiSceneResId = AddressDataConst.AVATAR_ACCESSORY_RES
	},
	[UIConst.UI_ID_CHANGE_NAME] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Popup_Menu_ChangeName.prefab",
		module = "changeName",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_COMMON_TEXT_INPUT] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Popup_Menu_InputText.prefab",
		module = "commonTextInput",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_COMMON_TIP_INPUT] = {
		fullScreen = false,
		isModel = true,
		resID = "$UI_Pb_Tips_Input.prefab",
		module = "commonTipInput",
		blockCommonQuit = true,
		orderWidget = 3000,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PLAY_FLUTE] = {
		module = "playFlute",
		resID = "$UI_Pb_SocialEncounter_SocialEncounter_Dizi.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_SELECT_POPUP] = {
		fullScreen = true,
		resID = "$UI_Pb_Chat_Pet_Share_Popup.prefab",
		module = "petSelectPopup",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab
	},
	[UIConst.UI_ID_FRIEND_INTIMACY] = {
		module = "friendIntimacy",
		resID = "$UI_Popup_ChatFriend_Intimacy.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_FRIEND_INTIMACY_EXPLAIN] = {
		module = "FriendIntimacyExplain",
		fullScreen = true,
		resID = "$UI_Pop_Likability_Gain_Explain.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_RANK_BASE] = {
		module = "RankBase",
		fullScreen = true,
		resID = "$UI_Pb_Ranking.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_RANK_REWARD] = {
		module = "RankReward",
		resID = "$UI_Pop_Ranking_Reward.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_RANK_FILTER] = {
		module = "RankFilter",
		resID = "$UI_Pop_Ranking_Filter.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_SPACE_FOLLOW_MEMBER] = {
		syncLoad = true,
		isModel = true,
		resID = "$UI_Popup_ChatFriend_Select.prefab",
		module = "spaceFollowMember",
		fullScreen = true,
		orderWidget = 2000,
		enableMainCamera = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_SPACE_FOLLOW_GIVE_CONFIRM] = {
		syncLoad = true,
		isModel = true,
		resID = "$UI_Popup_ChatFriend_Confurm.prefab",
		module = "spaceFollowGiveConfirm",
		fullScreen = true,
		orderWidget = 2001,
		enableMainCamera = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_INTERACT_GESTURE] = {
		module = "interactGesture",
		isModel = false,
		resID = "$UI_Pb_EmoticonPanel.prefab",
		blockCommonQuit = true,
		orderWidget = 20000,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_SCREEN_EFFECT] = {
		module = "screenEffect",
		resID = "$UI_Pb_Screen_Effect.prefab",
		initRegister = 1,
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_EXCHANGE_ITEM] = {
		module = "exchangeItem",
		resID = "$UI_Pb_Popup_HomeManufacture.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_ROG_VENTURE_REWARD] = {
		module = "rogVentureReward",
		resID = "$UI_Pb_Tower_Venture_Reward.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_SHOP_GIFT_RECEIVE] = {
		module = "shopGiftReceive",
		fullScreen = false,
		resID = "$UI_Pb_CashShop_ReceiveGift.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_GRAB_EGGS_MODE] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_GameMod_GrabEggs_Copy.prefab",
		module = "grabEggsMode",
		addBlackChange = {
			0.4,
			0.3
		},
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_GRAB_EGGS_BAG] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_BagSortPanel.prefab",
		module = "grabEggBag",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_GRAB_EGGS_RESULT] = {
		module = "grabEggResult",
		fullScreen = true,
		resID = "$UI_Pb_GarbEggs_Result.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_GRAB_EGGS_OPEN_EYES] = {
		module = "grabEggOpenEyes",
		fullScreen = true,
		resID = "$UI_Pb_ShiftingEgg_OpenEye.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_GRAB_EGGS_SETTLEMENT] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_GrabEggs_Settlement.prefab",
		module = "grabEggSettlement",
		addBlackChange = {
			0.1,
			0.3
		},
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_GRAB_EGGS_SETTLEMENT_RANK] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_GarbEggs_Season_Rank_Settlement.prefab",
		module = "grabEggSettlementRank",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_GRAB_EGGS_SEASONINFO_POPUP] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pop_Season_Rank_Details.prefab",
		module = "grabEggsSeasonInfo",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_GRAB_EGGS_TALENT] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_GarbEggs_TalentTree_Main.prefab",
		module = "grabEggsTalent",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_TEAM_ROOM_DUNGEON_SELECT] = {
		module = "teamRoomDungeonSelect",
		blockCommonQuit = true,
		resID = "$UI_Popup_TeamRoom_PlayingMethod_Select.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_GRAB_EGGS_CALCINATION] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_GarbEggs_Calcination_Collectibles.prefab",
		module = "grabEggsCalcination",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.CALCINATION_SCENE,
		uiSceneResId = AddressDataConst.UI_CALCINATION_SCENE
	},
	[UIConst.UI_ID_GRAB_EGGS_COLLECTION] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_GrabEggs_Collection_Show.prefab",
		module = "grabEggsCollection",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.ILLUSTRATED_GUIDE_SCENE,
		uiSceneResId = AddressDataConst.UI_ILLUSTRATED_GUIDE_SCENE
	},
	[UIConst.UI_ID_GRAB_EGGS_COLLECTION_DETAIL] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_GrabEggs_Collection_Show_Detail_Exhibition.prefab",
		module = "grabEggsCollectionDetail",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.ILLUSTRATED_GUIDE_C_SCENE,
		uiSceneResId = AddressDataConst.UI_ILLUSTRATED_GUIDE_C_SCENE
	},
	[UIConst.UI_ID_GRAB_EGGS_SEASON_RANK_MAIN] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_GarbEggs_Season_Rank_Main.prefab",
		module = "grabEggsSeasonRankMain",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_GRAB_EGGS_SEASON_RANK_OVERVIEW] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_GarbEggs_Season_Rank_Reward.prefab",
		module = "grabEggsSeasonRankOverview",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CREATE_PLAYER_RENAME] = {
		module = "createPlayerRename",
		blockCommonQuit = true,
		resID = "$UI_Pb_InputName.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_ROG_BUFF_SELECT] = {
		blockCommonQuit = true,
		hideTipAreas = {
			TipAreaConst.AREAS.CF
		}
	},
	[UIConst.UI_ID_RACING_DUNGEON] = {
		blockCommonQuit = true,
		ignore = true
	},
	[UIConst.UI_ID_BLACK_CHANGE] = {
		isPermanent = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_BlackChange.prefab",
		module = "blackChange",
		hideByOutOfView = true,
		orderWidget = 99999,
		ignore = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_BLACK_BG] = {
		isPermanent = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_BlackBg.prefab",
		module = "blackBg",
		orderWidget = 99999,
		ignore = true,
		syncLoad = true,
		needRaycaster = false,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_VOTING_FEATURE] = {
		uiType = "InfosLayer",
		resID = "$UI_Pb_VotingFeature.prefab",
		module = "votingFeature",
		orderWidget = 10001,
		ignore = true
	},
	[UIConst.UI_ID_FRIEND_GIFT] = {
		module = "friendGift",
		fullScreen = true,
		resID = "$UI_Popup_ChatPanel_Gift.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_FRIEND_GIFT_BUY] = {
		module = "friendGiftBuy",
		resID = "$UI_Pb_Pop_Chat_Buy.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_FRIENDSHIP_UP] = {
		fullScreen = true,
		resID = "$UI_Pop_LikabilityUp.prefab",
		module = "friendshipUp",
		uiType = UIConst.POPUP_LAYER,
		uiSceneName = UISceneConst.MODEL_SCENE,
		uiSceneResId = AddressDataConst.UI_Model_Scene
	},
	[UIConst.UI_ID_MAIL] = {
		module = "chatMail",
		fullScreen = true,
		resID = "$UI_Pb_Email_System.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PHOTO_LOGO] = {
		isModel = false,
		resID = "$UI_Pb_PhotoLogo.prefab",
		module = "photoLogo",
		ignore = true,
		uiType = UIConst.POPUP_LAYER,
		hideTipAreas = {
			TipAreaConst.AREAS.C
		}
	},
	[UIConst.UI_ID_PHOTO_SAVE_TEMPLATE] = {
		module = "photoSaveTemplate",
		resID = "$UI_Pb_Popup_SaveAsTemplate.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PHOTO_DOWNLOAD_TEMPLATE] = {
		module = "photoDownloadTemplate",
		resID = "$UI_Pb_Template_Information.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PHOTO_SCAN_CODE] = {
		module = "photoScanCode",
		resID = "$UI_Pb_Template_Information_Use.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PHOTOGRAPHY_STUDIO_EDIT] = {
		fullScreen = false,
		isModel = false,
		resID = "$UI_Pb_Photographic_Studio.prefab",
		module = "PhotographyStudioEdit",
		blockCommonQuit = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PHOTOGRAPHY_INVITE] = {
		module = "PhotographyStudioInvite",
		resID = "$UI_Pb_Pop_Photograph_Friend_Invite.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PHOTO_LIGHT_DIY] = {
		module = "photoLightDiy",
		isModel = false,
		resID = "$UI_Popup_Photograph_Diy.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_VIP_JUMP_SCAN_CODE] = {
		module = "vipJumpScanCode",
		resID = "$UI_Pb_Template_Information_Use.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HELP] = {
		syncLoad = true,
		enableMainCamera = true
	},
	[UIConst.UI_ID_NET_LOADING] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Loading_Reconnect.prefab",
		module = "netLoading",
		orderWidget = 1900,
		enableMainCamera = true,
		isModel = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_COMMON_USE_CONFIRM] = {
		fullScreen = false,
		hideTipAreas = {
			TipAreaConst.AREAS.CF
		}
	},
	[UIConst.UI_ID_TOWER_DEFEAT] = {
		blockCommonQuit = true
	},
	[UIConst.UI_ID_NPC_CALL] = {
		blockCommonQuit = true
	},
	[UIConst.UI_ID_BIG_WHITE_BALL] = {
		blockCommonQuit = true
	},
	[UIConst.UI_ID_QUIZ] = {
		blockCommonQuit = true,
		forceShowTips = true,
		hideTipAreas = {
			TipAreaConst.AREAS.CF
		},
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_MAP_LOCATION] = {
		syncLoad = true
	},
	[UIConst.UI_ID_ROG_EVENT_REVIVAL] = {
		enableMainCamera = true
	},
	[UIConst.UI_ID_PEEP_EXIT] = {
		module = "peepExit",
		ignore = true,
		resID = "$UI_Pb_Hud_Frame_Exit.prefab",
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_RESOURCE_DOWNLOAD] = {
		module = "resourceDownload",
		resID = "$UI_Pb_Popup_ResourceDownload.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_RESOURCE_CLEAN] = {
		module = "resourceClean",
		resID = "$UI_Pb_Popup_ResourceClean.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_GAME_PREORDER_GUIDE] = {
		module = "gamePreorderGuide",
		resID = "$UI_Pb_Popup_Abroad_Download.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_MAP_NOURISH_TRIBUTE] = {
		fullScreen = true,
		resID = "$UI_Pb_Map_Tribute.prefab",
		module = "nourishTribute",
		orderWidget = 1001,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_EVENT_PHOTO_RECOGNIZE] = {
		fullScreen = true,
		resID = "$UI_Pb_Event_PhotoRecognition.prefab",
		module = "eventPhotoRecognize",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_EVENT_TASK_PANEL] = {
		module = "eventTaskPanel",
		fullScreen = false,
		resID = "$UI_Pop_Event_EarthVeins_Tasks.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_TARGET_ELEMENT_POPUP] = {
		fullScreen = true,
		isModel = true,
		resID = "$UI_Pb_Popup_ElementTarget.prefab",
		module = "targetElementPopup",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CHAIN_ATTACK_RESPOND] = {
		fullScreen = false,
		blockCommonQuit = true,
		resID = "$UI_Node_Hud_Coordination.prefab",
		module = "chainAttackRespond",
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_BOSS_RUSH_MAIN] = {
		resID = "$UI_Pb_BossMod_Main.prefab",
		module = "bossRushMain",
		bgm = "BGM_TowerMultiplayer_Menu",
		keepUISceneOnPanelCovered = true,
		fullScreen = true,
		noBgmAttenuation = true,
		addBlackChange = {
			0.1,
			0.3
		},
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.BOSS_RUSH_SCENE,
		uiSceneResId = AddressDataConst.UI_BOSS_RUSH_SCENE
	},
	[UIConst.UI_ID_BOSS_RUSH_CHALLENGE] = {
		fullScreen = false,
		bgm = "BGM_TowerMultiplayer_Menu",
		resID = "$UI_Pb_BossMod_BossChallenge.prefab",
		module = "bossRushChallenge",
		noBgmAttenuation = true,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.BOSS_RUSH_SCENE,
		uiSceneResId = AddressDataConst.UI_BOSS_RUSH_SCENE
	},
	[UIConst.UI_ID_BOSS_RUSH_BATTLE_RESULT] = {
		fullScreen = true,
		resID = "$UI_Pb_BossMod_ChallengeResult.prefab",
		module = "bossRushBattleResult",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_BOSS_RUSH_BATTLE_DETAIL_RESULT] = {
		fullScreen = true,
		resID = "$UI_Pb_BossMod_ResultCard.prefab",
		module = "bossRushBattleDetailResult",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_BOSS_RUSH_SETTLEMENT] = {
		fullScreen = true,
		resID = "$UI_Pb_BossMod_ChallengeExitResult.prefab",
		module = "bossRushSettlement",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_BOSS_RUSH_SEASON] = {
		fullScreen = false,
		bgm = "BGM_TowerMultiplayer_Menu",
		resID = "$UI_Pb_Season_Schedule.prefab",
		module = "bossRushSeason",
		noBgmAttenuation = true,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.BOSS_RUSH_SCENE,
		uiSceneResId = AddressDataConst.UI_BOSS_RUSH_SCENE
	},
	[UIConst.UI_ID_BOSS_RUSH_BUFF_SELECT] = {
		module = "bossRushBuffSelect",
		fullScreen = true,
		resID = "$UI_Pb_BossMod_BuffPanel.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_BOSS_RUSH_ROUTE] = {
		fullScreen = true,
		resID = "$UI_Pop_BossMod_ChallengeRoute.prefab",
		module = "bossRushRoute",
		enableMainCamera = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_BOSS_RUSH_REWARD] = {
		fullScreen = true,
		resID = "$UI_Pop_BossMod_RewardPanel.prefab",
		module = "bossRushReward",
		enableMainCamera = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_DIRECT_PURCHASE] = {
		module = "directPurchase",
		resID = "$UI_Pb_Popup_DirectPurchase.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_DIRECT_PURCHASE_TIPS] = {
		keepTextLinkOnOpen = true,
		gamepadPass = true,
		resID = "$UI_Node_DirectPurchase_Tips.prefab",
		module = "directPurchaseTips",
		ignore = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_COMMON_PET_PREVIEW] = {
		module = "petPreview",
		fullScreen = false,
		resID = "$UI_Node_PetView.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CATCH_ROGUE_ENTRY] = {
		module = "catchRogueEntry",
		fullScreen = true,
		resID = "$UI_Pb_Tower_CatchPet.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_COMMON_PANELLEFT_ITEM_SEL] = {
		module = "commonLeftItemSel",
		fullScreen = false,
		resID = "$UI_Node_PanelLeft_ItemSel.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CATCH_ROGUE_PET_BAG] = {
		module = "catchRoguePetBag",
		fullScreen = true,
		resID = "$UI_Pb_PetCatchBag.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_CATCH_ROGUE_RESULT] = {
		module = "catchRogueResult",
		fullScreen = true,
		resID = "$UI_Pb_Tower_CatchPetResult.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_FISHING_CAPTURE_MAIN] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Event_GameDungeonInfo_BossCatch.prefab",
		module = "fishingCapture",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_FISHING_CAPTURE_RESULT] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Event_BossCatch_Result_Suc.prefab",
		module = "fishingCaptureResult",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_FISHING_CAPTURE_PURIFICATION] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Even_BossCatch_Purification.prefab",
		module = "fishingCapturePurification",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_FISHING_CAPTURE_HISTORY] = {
		module = "fishingCaptureHistory",
		resID = "$UI_Pop_BossCatch_History.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_FISHING_CAPTURE_FAIL_RESULT] = {
		module = "fishingCaptureFailResult",
		blockCommonQuit = true,
		resID = "$UI_Pb_Event_BossCatch_Result.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_FISHING_CAPTURE_CONTRACT] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Even_BossCatch_Contract.prefab",
		module = "fishingCaptureContract",
		noBgmAttenuation = true,
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PETEVENT_PETCHOICE] = {
		module = "vitalityPetChoice",
		fullScreen = true,
		resID = "$UI_Pb_PetEvent_PetChoice.prefab",
		blockCommonQuit = true,
		enableMainCamera = true,
		addBlackChange = {
			0.1,
			0.3
		},
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PETEVENT_SETTLEMENT] = {
		module = "vitalitySettlement",
		resID = "$UI_Pb_Event_Settlement.prefab",
		blockCommonQuit = true,
		enableMainCamera = true,
		fullScreen = true,
		addBlackChange = {
			0.1,
			0.3
		},
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.VITALITY_SCENE,
		uiSceneResId = AddressDataConst.AVATAR_SCENE_VITALITY_CONTEST_LS
	},
	[UIConst.UI_ID_AVATAR_FUSION] = {
		module = "avatarFusion",
		blockCommonQuit = true,
		resID = "$UI_Pb_Avatar_Fusion.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_ARK_PARTY_CHOICE] = {
		fullScreen = true,
		resID = "$UI_Node_Event_ArkParty.prefab",
		module = "arkPartyChoice",
		enableMainCamera = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_Event_PetSave_Manual] = {
		module = "eventPetSaveManual",
		fullScreen = true,
		resID = "$UI_Pb_Event_ManualDetail.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_Pb_Event_EcologicalSurvey] = {
		module = "eventEcoTraceTask",
		fullScreen = true,
		resID = "$UI_Pb_Event_EcologicalSurvey.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_Pb_Event_ResearchCenter] = {
		module = "eventEcoTraceResearch",
		fullScreen = true,
		resID = "$UI_Pb_Event_ResearchCenterNew.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_Pb_Event_FriendPanel] = {
		module = "eventFriend",
		fullScreen = false,
		resID = "$UI_Pb_Event_FriendPanel.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOME_CAR_MODIFY] = {
		blockCommonQuit = true,
		fullScreen = true,
		module = "homeCarModify",
		resID = AddressDataConst.HOME_CAR_MODIFY_UI,
		uiSceneName = UISceneConst.HOME_CAR_SCENE,
		uiSceneResId = AddressDataConst.UI_HOME_CAR_SCENE,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_CAR_NAME] = {
		module = "homeCarName",
		blockCommonQuit = true,
		resID = AddressDataConst.HOME_CAR_NAME_UI,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_CAR_BUFF_PANEL] = {
		module = "homeCarBuffPanel",
		resID = "$UI_Pop_CampCar_BuffPanel.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_CAR_CAMP_SWITCH] = {
		module = "homeCarCampSwitch",
		fullScreen = true,
		resID = AddressDataConst.HOME_CAR_CAMP_SWITCH_UI,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_HOME_STATION_MANAGE] = {
		module = "homeStationManage",
		fullScreen = true,
		resID = "$UI_Pb_Home_Station.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_CAMP_VISIT] = {
		module = "homeCampVisit",
		resID = AddressDataConst.HOME_CAR_CAMP_VISIT_UI,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_CAMP_MOVE_LOADING] = {
		module = "homeCampMoveLoading",
		MutexDisplay = true,
		blockCommonQuit = true,
		fullScreen = true,
		orderWidget = 1001,
		resID = AddressDataConst.HOME_CAR_CAMP_MOVE_LOADING,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_CAMP_MANAGER] = {
		fullScreen = true,
		module = "homeCampManager",
		resID = AddressDataConst.HOME_CAR_CAMP_MANAGER,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.HOME_CAMP_RVPETS_SCENE,
		uiSceneResId = AddressDataConst.HOME_CAMP_RVPETS_SCENE_Prefab
	},
	[UIConst.HOME_CAR_CAM_DISPATCH_REWARDS] = {
		fullScreen = true,
		module = "homeCampDispatchRewards",
		orderWidget = 999,
		resID = AddressDataConst.HOME_CAR_CAM_DISPATCH_REWARDS,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOME_CAMP_CHOOSE_EXPLORE_AREA] = {
		fullScreen = false,
		resID = "$UI_Pop_Home_Delegation_ChooseArea.prefab",
		module = "homeCampChooseExploreArea",
		uiType = UIConst.POPUP_LAYER,
		uiSceneName = UISceneConst.HOME_CAMP_RVPETS_SCENE,
		uiSceneResId = AddressDataConst.HOME_CAMP_RVPETS_SCENE_Prefab
	},
	[UIConst.UI_ID_ROG_LEVEL_SELECT] = {
		resID = "$UI_Pb_Tower_SelectLevelNew.prefab"
	},
	[UIConst.UI_ID_INCUBATOR] = {
		module = "incubator",
		fullScreen = false,
		resID = "$UI_Pop_Home_Incubator.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_EVENT_SCHOOL_GUIDE] = {
		fullScreen = true,
		blackBgDuration = 1,
		resID = "$UI_Pb_Event_SchoolGuide.prefab",
		module = "schoolGuide",
		functionID = Const.FUNCTION_IDS.SCHOOLGUIDE,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_INVITE_FRIEND] = {
		module = "inviteFriend",
		fullScreen = false,
		resID = "$UI_Popup_Invite_Friend.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_FRIEND_SETUP] = {
		module = "friendSetup",
		fullScreen = false,
		resID = "$UI_Popup_ChatPanel_Friend_SetUp.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_FRIEND_GROUP_SETUP] = {
		module = "friendGroupSetup",
		fullScreen = false,
		resID = "$UI_Popup_ChatPanel_Friend_GroupManagement.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_QUEST_CHAPTER] = {
		MutexDisplay = false,
		resID = "$UI_Pb_Quest_ChapterAppearEmptyPanel.prefab"
	},
	[UIConst.UI_ID_PET_BATCH_STRENGTH_POINT] = {
		module = "petBatchStrengthPoint",
		fullScreen = false,
		resID = "$UI_Pop_PetManagement_TalentPanel.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_BATCH_STRENGTH_RULE] = {
		module = "petBatchSPointsRule",
		fullScreen = false,
		resID = "$UI_Pb_PetManagement_TalentInfoPanel.prefab",
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_PET_RECOMMEND_STRENGTH_POINT] = {
		module = "petRecommendBatchAddPPoint",
		fullScreen = false,
		resID = "$UI_Pop_PetManagement_AddInfoPanel.prefab",
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_EVENT_AREA_ACTIVITY] = {
		module = "areaActivity",
		fullScreen = true,
		resID = "$UI_Pb_Event_WaterArea_TaskList.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PET_RESONANCE_BREAK] = {
		module = "starUpBreak",
		fullScreen = true,
		resID = "$UI_Pb_PetManagement_SceneStarUpgrade.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_SIMPLE_TEXT_TIP] = {
		keepTextLinkOnOpen = true,
		gamepadPass = true,
		module = "simpleTextTip",
		orderWidget = 10,
		ignore = true,
		resID = AddressDataConst.UI_SIMPLE_TEXT_TIP,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_TOOLTIP_SKILL_INFO_WITH_TITLE] = {
		keepTextLinkOnOpen = true,
		gamepadPass = true,
		module = "tooltipSkillInfoWithTitle",
		orderWidget = 2000,
		ignore = true,
		resID = AddressDataConst.UI_TOOLTIP_SKILL_INFO_WITH_TITLE,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_PET_RESONANCE_FINAL_BREAK] = {
		module = "starUpFinalBreak",
		fullScreen = true,
		resID = "$UI_Pb_PetManagement_Cultivate_SceneStarUpgradeBig.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_GUIDE_POPUP_PANEL] = {
		blockCommonQuit = true
	},
	[UIConst.UI_OCTOPUS_GASHAPON] = {
		fullScreen = false,
		resID = "$UI_Node_Hud_Octopus_Gashapon.prefab",
		module = "octopusGashapon",
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_SPECIAL_ENERGY_BAR] = {
		fullScreen = false,
		blockCommonQuit = true,
		resID = "$UI_Node_Hud_Special_Energy.prefab",
		module = "specialEnergyBar",
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_PET_DISPATCH_TASK] = {
		module = "petDispatchTask",
		fullScreen = false,
		resID = "$UI_Pb_Event_ThemeMonth_ChooseSurvey_New.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_DISPATCH_PET_SELECT] = {
		module = "petDispatchPetSelect",
		fullScreen = false,
		resID = "$UI_Pb_Event_ThemeMonth_List.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_DISPATCH_SURVEY_COMPLETED] = {
		module = "petDispatchSurveyCompleted",
		fullScreen = false,
		resID = "$UI_Pop_Event_ThemeMonth_SurveyCompleted.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_DISPATCH_START_TIPS] = {
		module = "petDispatchStartTips",
		fullScreen = false,
		resID = "$UI_Pb_Event_ThemeMonth_Dispatch.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_LITTLE_FIRE_GARDEN_MANUAL] = {
		module = "littleFireGardenManual",
		fullScreen = false,
		resID = "$UI_Pop_Event_TikTok.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_FISHING_CAPTURE_PETAL_SOURCE] = {
		module = "fishingCapturePetalSource",
		fullScreen = true,
		resID = "$UI_Pb_Event_BossCatchReward.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_FISHING_CAPTURE_TICKET_EXCHANGE] = {
		module = "fishingCaptureTicketExchange",
		fullScreen = true,
		resID = "$UI_Pb_Even_BossCatch_Create.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_DEATH_SPECTATE] = {
		fullScreen = true,
		resID = "$UI_Pb_GrabEggs_Spectate.prefab",
		module = "spectate",
		ignore = true,
		uiType = UIConst.SCENE_LAYER
	},
	[UIConst.UI_ID_QUICK_PAYMENT] = {
		fullScreen = false,
		blockCommonQuit = true,
		resID = "$UI_Pop_QuickPayment.prefab",
		module = "quickPayment",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_MONTHLY_CARD_SELFIE] = {
		module = "monthlyCardSelfie",
		fullScreen = true,
		resID = "$UI_Pop_MonthlyCard_Selfie.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_MONTHLY_CARD_REWARD] = {
		module = "monthlyCardReward",
		fullScreen = false,
		resID = "$UI_Pop_MonthlyCard_Reward.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_NPC_DUEL_START] = {
		fullScreen = true,
		resID = "$UI_Pb_BattleRoom_Main2.prefab",
		module = "npcDuelStart",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.NPC_DUEL_START_PREVIEW_SCENE,
		uiSceneResId = AddressDataConst.NPC_DUEL_START_SCENE_Prefab
	},
	[UIConst.UI_ID_NPC_DUEL_NAMEIN] = {
		fullScreen = false,
		blockCommonQuit = true,
		resID = "$UI_Pb_BattleRoom_NameIn.prefab",
		module = "npcDuelNameIn",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_HOME_CAMP_INVITE_CARD] = {
		syncLoad = true,
		orderWidget = 2000,
		resID = "$UI_Pop_Home_Station_Invite.prefab",
		module = "homeCampInviteCard",
		isModel = true,
		enableMainCamera = true,
		fullScreen = true,
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PLAYER_BADGE_DETAIL] = {
		module = "badgeDetail",
		fullScreen = false,
		resID = "$UI_Node_Personal_Badge_Details.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_PLAYER_BADGE_OBTAIN] = {
		forceHideOtherUI = true,
		resID = "$UI_Node_Personal_Badge_Popup.prefab",
		module = "badgeObtain",
		enableMainCamera = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PLAYER_BADGE_FIRST_UNLOCK] = {
		module = "badgeUnlockShow",
		resID = "$UI_Node_Personal_Badge_FristAcquire.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PLAYER_ENHANCE_LOADING] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Personal_LoadingPage.prefab",
		module = "playerEnhanceLoading",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_LOGIN_SELECT_SERVER] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Login_SelectServer.prefab",
		module = "loginSelectServer",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_SELECT_LANGUAGE] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$XGUI_RPanel/Popup/UI_Pb_SelectLanguage.prefab",
		module = "selectLanguage",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_TRANSMOG] = {
		fullScreen = true,
		hairLayerCount = 8,
		resID = "$UI_Pb_PetBaptize.prefab",
		module = "petTransmog",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.PET_TRANSMOG_SCENE,
		uiSceneResId = AddressDataConst.REFINING_SCENE
	},
	[UIConst.UI_ID_PET_TRANSMOG_SCHEME] = {
		module = "petTransmogScheme",
		fullScreen = false,
		resID = "$UI_Pop_PetBaptize_TempPlan.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_TRANSMOG_REPLACE] = {
		module = "petTransmogReplace",
		fullScreen = false,
		resID = "$UI_Pop_PetBaptize_PlanChange.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_TRANSMOG_STAR_UPGRADE] = {
		module = "petTransmogStarUpgrade",
		fullScreen = false,
		resID = "$UI_Pop_PetBaptize_StarUpgrade.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_TRANSMOG_ITEM_GET] = {
		module = "petTransmogItemGet",
		fullScreen = false,
		resID = "$UI_Pop_PetBaptize_ItemGet.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_TRANSMOG_VIDEO] = {
		module = "petTransmogVideo",
		fullScreen = false,
		resID = "$UI_Pb_PetBaptize_Video.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_PET_TRANSMOG_BAPTIZE_TIP] = {
		fullScreen = false,
		gamepadPass = true,
		resID = "$UI_Tips_PetBaptize.prefab",
		module = "petTransmogBaptizeTip",
		keepTextLinkOnOpen = true,
		orderWidget = 10,
		ignore = true,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_COMMON_INPUT] = {
		fullScreen = false,
		isModel = true,
		resID = "$UI_Pb_Common_Input.prefab",
		module = "commonInput",
		blockCommonQuit = true,
		orderWidget = 3000,
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_TEXT_LINK] = {
		fullScreen = true,
		isModel = true,
		resID = "$UI_Pb_TextLink.prefab",
		module = "textLink",
		enableMainCamera = true,
		orderWidget = 1800,
		disableTextLinkHotkey = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_VIETNAMESE_18_WARNING] = {
		isPermanent = true,
		resID = "$UI_Pb_Vietnamese_18Warning.prefab",
		module = "vietnamese18Warning",
		orderWidget = 100000,
		ignore = true,
		uiType = UIConst.INFOS_LAYER
	},
	[UIConst.UI_ID_SETTING_KEY_ATTENTION] = {
		module = "settingKeyAttention",
		isModel = true,
		resID = "$UI_Pb_Pop_Setting_Attention_Console.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_SETTING_KEY_ATTENTION_CONSOLE] = {
		module = "settingKeyAttentionConsole",
		isModel = true,
		resID = "$UI_Pb_Pop_Setting_Attention_Console.prefab",
		uiType = UIConst.POPUP_LAYER
	},
	[UIConst.UI_ID_LEYLINE_TREE] = {
		fullScreen = true
	},
	[UIConst.UI_ID_ACCUSATION] = {
		module = "accusation",
		resID = "$UI_Pb_Popup_Report.prefab",
		uiType = UIConst.POPUP_LAYER,
		hideTipAreas = {
			TipAreaConst.EDGE_AREAS.QuestArea,
			TipAreaConst.AREAS.CF
		}
	},
	[UIConst.UI_ID_HOME_CAMP_REPORT] = {
		module = "homeCampReport",
		resID = "$UI_Pb_Popup_Report_1.prefab",
		uiType = UIConst.POPUP_LAYER,
		hideTipAreas = {
			TipAreaConst.EDGE_AREAS.QuestArea,
			TipAreaConst.AREAS.CF
		}
	},
	[UIConst.UI_ID_PET_LEVEL_UP] = {
		gamepadModel = true
	},
	[UIConst.UI_ID_DAMAGE_NUMBER] = {
		needRaycaster = false
	},
	[UIConst.UI_ID_DEVELOP_HINT_PANEL] = {
		needRaycaster = false
	},
	[UIConst.UI_ID_TRADE_MARKET_SELL_PET] = {
		fullScreen = true,
		hairLayerCount = 8,
		resID = "$UI_Pb_CashShop_AuctionHouse_SellPet.prefab",
		module = "tradeMarketSellPet",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_TRADE_MARKET_PET_BUY_DETAIL] = {
		fullScreen = true,
		hairLayerCount = 8,
		resID = "$UI_Pb_CashShop_AuctionHouse_PetDetail.prefab",
		module = "tradeMarketPetBuyDetail",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.CASH_SCENE,
		uiSceneResId = AddressDataConst.CASH_SHOP_SCENE
	},
	[UIConst.UI_ID_TRADE_MARKET_HISTORY] = {
		fullScreen = true,
		hairLayerCount = 8,
		resID = "$UI_Pb_CashShop_AuctionHouse_History.prefab",
		module = "tradeMarketHistory",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_TRADE_MARKET_GOODS_DETAIL] = {
		fullScreen = true,
		hairLayerCount = 8,
		resID = "$UI_Pb_CashShop_AuctionHouse_GoodsDetail.prefab",
		module = "tradeMarketGoodsDetail",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.CASH_SCENE,
		uiSceneResId = AddressDataConst.CASH_SHOP_SCENE
	},
	[UIConst.UI_ID_TRADE_MARKET_PANIC_BUY] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pop_AuctionHouse_PanicBuying.prefab",
		module = "tradeMarketPanicBuy",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_TRADE_MARKET_SELL_GOODS] = {
		module = "tradeMarketSellGoods",
		fullScreen = true,
		resID = "$UI_Pb_CashShop_AuctionHouse_SellProps.prefab",
		uiType = UIConst.PANEL_LAYER
	},
	[UIConst.UI_ID_CREATE_ROLE_TIMELINE] = {
		fullScreen = true,
		blockCommonQuit = true,
		resID = "$UI_Pb_Avatar_Video.prefab",
		module = "createRoleTimeline",
		hairLayerCount = 8,
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.AVATAR_CREATE_ROLE_SCENE,
		uiSceneResId = AddressDataConst.AVATAR_CREATE_ROLE_SCENE
	},
	[UIConst.UI_ID_TRADE_MARKET_HISTORY_GOODS] = {
		fullScreen = true,
		hairLayerCount = 8,
		resID = "$UI_Pb_CashShop_AuctionHouse_HistoryPropsDetail.prefab",
		module = "tradeMarketHistoryGoods",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.CASH_SCENE,
		uiSceneResId = AddressDataConst.CASH_SHOP_SCENE
	},
	[UIConst.UI_ID_TRADE_MARKET_HISTORY_PET] = {
		fullScreen = true,
		hairLayerCount = 8,
		resID = "$UI_Pb_CashShop_AuctionHouse_HistoryPetDetail.prefab",
		module = "tradeMarketHistoryPet",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.CASH_SCENE,
		uiSceneResId = AddressDataConst.CASH_SHOP_SCENE
	},
	[UIConst.UI_ID_TRADE_MARKET_PET_SELL_DETAIL] = {
		fullScreen = true,
		hairLayerCount = 8,
		resID = "$UI_Pb_CashShop_AuctionHouse_PetDetail.prefab",
		module = "tradeMarketPetSellDetail",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.CASH_SCENE,
		uiSceneResId = AddressDataConst.CASH_SHOP_SCENE
	},
	[UIConst.UI_ID_TRADE_MARKET_PET_REMOVE_DETAIL] = {
		fullScreen = true,
		hairLayerCount = 8,
		resID = "$UI_Pb_CashShop_AuctionHouse_PetDetail.prefab",
		module = "tradeMarketPetRemoveDetail",
		uiType = UIConst.PANEL_LAYER,
		uiSceneName = UISceneConst.CASH_SCENE,
		uiSceneResId = AddressDataConst.CASH_SHOP_SCENE
	}
}
UIConst.PLATFORM = {
	Mobile = bit.lshift(1, 0),
	Standalone = bit.lshift(1, 1),
	Console = bit.lshift(1, 2)
}
UIConst.UIState = {
	Loading = 1,
	None = 0,
	Loaded = 2
}
UIConst.UI_HIDE_DEFAULT_WHITELIST = {}
UIConst.RICH_TEXT_LINK_TYPE = {
	SOURCE = "source",
	SURVEY = "webSurvey",
	WEB = "web",
	APPEAR_HELP = "appearHelp",
	HELP = "help",
	ITEM = "item"
}
UIConst.RICH_TEXT_LINK_TYPE_EX = {
	BANSHU = 100
}
UIConst.UI_HIDE_FORCE_WHITELIST = {}
UIConst.DEFAULT_CLOSE_WHITELIST = {
	[UIConst.UI_ID_TIPS] = true
}
UIConst.DIALOGUE_UI_SET = {
	[UIConst.UI_ID_NPC_CALL] = true,
	[UIConst.UI_ID_AI_ASSISTANT] = true,
	[UIConst.UI_ID_BLACK_SCREEN] = true,
	[UIConst.UI_ID_DIALOG_REVIEW] = true,
	[UIConst.UI_ID_PLOT_PHONE_CALL] = true,
	[UIConst.UI_ID_BOTTOM_DIALOGUE] = true,
	[UIConst.UI_ID_WHITE_SCREEN] = true
}
UIConst.DIALOGUE_MODULE_PATH_PREFIX = "Guis.Panels.DialogueModule."
UIConst.UI_MODULE_PREFIX_PARSER = {
	[UIConst.UI_ID_NPC_CALL] = UIConst.DIALOGUE_MODULE_PATH_PREFIX,
	[UIConst.UI_ID_AI_ASSISTANT] = UIConst.DIALOGUE_MODULE_PATH_PREFIX,
	[UIConst.UI_ID_DIALOG_REVIEW] = UIConst.DIALOGUE_MODULE_PATH_PREFIX,
	[UIConst.UI_ID_BOTTOM_DIALOGUE] = UIConst.DIALOGUE_MODULE_PATH_PREFIX
}
UIConst.LEVEL_HIDE_UI_WHITE_LIST = {
	UIConst.UI_ID_SKIP_PANEL
}
UIConst.QUALITY = {
	BLUE = 3,
	GREEN = 2,
	WHITE = 1,
	ORANGE = 6,
	PURPLE = 4
}
UIConst.QUALITY_TO_NAME = {
	"white",
	"green",
	"blue",
	"purple",
	"orange",
	"orange"
}
UIConst.BossMechanismIconType = {
	Stage = 3,
	MinMax = 2,
	Slider = 1
}
UIConst.ITEM_STATE = {
	EXCHANGE = 2,
	FULL = 1,
	LACK = 0
}
UIConst.ITEM_INFO_STATE = {
	PROP = 0,
	SHOP = 1
}
UIConst.ITEM_STATE_COLOR = {
	[UIConst.ITEM_STATE.LACK] = "Item_Lack",
	[UIConst.ITEM_STATE.FULL] = "Item_Full",
	[UIConst.ITEM_STATE.EXCHANGE] = "Item_ExChange"
}
UIConst.DAMAGE_UI_TYPE_DESC = {
	WEAK = "Light",
	NON_CRITICAL = "Basic",
	CRITICAL = "Critical",
	NON_BREAK = "nonbreak",
	BREAK = "break",
	NULL = "null",
	ENEMY = "enemy",
	PLAYER_PET = "playerPet",
	PLAYER = "player",
	NORMAL_DISPLAY = "normal",
	FROM_EQUIPMENT = "FROM_EQUIPMENT",
	POWERFUL_STRIKE = "POWERFUL_STRIKE",
	DOT_DISPLAY = "DOT",
	DAMAGE = "damage",
	HEAL = "heal",
	EXCELLENT = "Heavy",
	NORMAL = "Normal"
}
UIConst.LOAD_STATE = {
	LOADED = 2,
	LOADING = 1,
	NONE = 0
}
UIConst.CD_LIMIT = 0.5
UIConst.UI_BREAK_CTRL_HIDE_WHITELIST = {
	[UIConst.UI_ID_CHAIN_ATTACK] = true,
	[UIConst.UI_ID_DAMAGE_NUMBER] = true
}
UIConst.SKILL_STATE = {
	LACK_ENERGY = 1,
	NORMAL = 0
}
UIConst.PET_SCENE_POSTITION = Vector3.New(10000, 0, 10000)
UIConst.PET_BALL_DROPPED_ITEM_TYPE = {
	BREED = 3,
	EXERCISE = 2,
	FOOD = 1
}
UIConst.NAME_STATE = {
	DIALOGUE = 2,
	DIALOGUE_GRAPH = 4,
	None = 0,
	COMBAT = 1
}
UIConst.HEALTH_STATE = {
	TEAM_ONLY = 5,
	NONE = -1,
	PET_BLOOD = 4,
	BLOOD = 3,
	NAME_BLOOD = 2,
	NAME_INFO = 1,
	NAME = 0
}
UIConst.TOPLOGO_NPC_STATE = {
	HIDE = "Hide",
	CLOSE = "Close",
	FAR = "Far"
}
UIConst.GIFT_TYPE = {
	BATTLE = 2,
	HOME = 1
}
UIConst.GIFT_SHOW_TYPE = {
	GIFT = 1,
	ABILITY = 2
}
UIConst.TOPLOGO_NPC_DIS = {
	HIDE = 0,
	FAR = 1,
	NEAR = 2
}
UIConst.PHOTO_TYPE = {
	TIP = 2,
	BUBBLE = 1,
	HIDDEN = 5,
	IDENTIFY = 4,
	DESC = 3
}
UIConst.LET_GO_STATE = {
	stop = 3,
	go = 2,
	back = 1
}
UIConst.QUESTION_MARK_TYPE = {
	GRAY = "Gray",
	ORANGE = "Orange",
	RED = "Red"
}
UIConst.TOPLOGO_VISIBLE_KEY = {
	PET_REPORT = 1,
	DEFAULT = 0,
	GROUP_SING = 3,
	MAIN_PET = 10,
	DIALOGUE_GRAPH_PLAYERHUB = 11,
	PHOTO_PANEL = 12,
	DIALOGUE_GRAPH = 6,
	DIALOGUE = 4,
	CAPACITY_LIMIT = 9,
	RIDING_VEHICLE = 8,
	HOME_WORK_STATE = 7,
	PET_FERTILITY = 5,
	PHOTO = 2
}
UIConst.MENU_EXIT_BTN_TYPE = {
	ReturnLogin = 4,
	ExitGame = 3,
	Unknown = 2,
	Cancel = 1,
	Confirm = 0
}
UIConst.TOPLOGO_COMPONENT = {
	QUEST = "quest",
	TEAM_MATE = "teamMate",
	TEAM_SPEECH = "teamSpeech",
	FOCUS = "focus",
	PET_EXCHANGE = "petExchange",
	SOCIAL = "social",
	PET_CHAT = "petChat",
	FACILITY = "facility",
	NPC = "npc",
	WORK_STATE = "workState",
	COMBAT = "combat",
	CHAT = "chat",
	VLOG = "vlog",
	CALL_FRIENDS = "callFriends",
	GRAB_EGG_STATE = "grabEgg",
	PET_LEVEL_UP = "petLevelUp",
	ALERT = "alert",
	BUBBLE = "bubble",
	BATTLE_ROOM = "battleRoom",
	PLAYERHUB = "playerHub",
	WATER_STORAGE = "waterStorage",
	INTERACT_SIGN = "interactSign",
	ACTION_STATE = "actionState",
	SPACE_FOLLOW = "spaceFollow",
	PLAYER_CHAT = "playerChat",
	ICON = "icon",
	PET_FERTILITY = "petFertility",
	PHOTO = "photo"
}
UIConst.QUESTION_MARK_TIMEOUT = 4
UIConst.HUD_MODE = {
	CATCH_ROGUE = 9,
	BOSS_RUSH = 8,
	IN_TEAM = 7,
	BOSS_DUNGEON = 6,
	COURSE = 5,
	HOMELAND = 4,
	TEMPLE = 3,
	ROGUE_DUNGEON = 2,
	BATTLE_HUD = 1,
	HUD = 0,
	NPC_DUEL = 11,
	PHOTO = 10
}
UIConst.HUD_LEFT_PANEL_TYPE = {
	[UIConst.HUD_MODE.HUD] = 1,
	[UIConst.HUD_MODE.IN_TEAM] = 1,
	[UIConst.HUD_MODE.HOMELAND] = 0,
	[UIConst.HUD_MODE.PHOTO] = 0,
	[UIConst.HUD_MODE.ROGUE_DUNGEON] = 2,
	[UIConst.HUD_MODE.TEMPLE] = 2,
	[UIConst.HUD_MODE.COURSE] = 2,
	[UIConst.HUD_MODE.BOSS_DUNGEON] = 2,
	[UIConst.HUD_MODE.BOSS_RUSH] = 2,
	[UIConst.HUD_MODE.CATCH_ROGUE] = 2
}
UIConst.MAP_CONST = {
	MAX_INTEGER = 999999999,
	MINIMAP_UI_RADIUS = 240,
	MINIMAP_AIM_CIRCLE_SCALE_COE = 0.5,
	PRELOAD_MAP_AIM_CIRCLE_COUNT = 5,
	MINIMAP_ICON_SCALE_COE = 0.7,
	PRELOAD_MAP_TRACK_MARK_COUNT = 5,
	PRELOAD_MAP_MARK_COUNT = 3,
	GAMEPAD_MOVE_PIXELS_PER_FRAME_AT_60_FPS = 40,
	FIXED_MAP_RECT_HEIGHT = 2700,
	FIXED_MAP_RECT_WIDTH = 4800,
	FIXED_MAP_HEIGHT = 4000,
	FIXED_MAP_WIDTH = 4000,
	MAX_CUSTOM_MARK_COUNT = 100,
	VALID_SCENE = {
		100,
		3000
	},
	SIZE_DELTA = {
		{
			1,
			1,
			1
		},
		{
			1,
			1,
			1
		},
		{
			0.82,
			0.82,
			1
		},
		{
			0.7,
			0.7,
			1
		},
		{
			0.6,
			0.6,
			1
		},
		{
			0.6,
			0.6,
			1
		}
	}
}
UIConst.StopGameTimeUI = {
	UIConst.UI_ID_PLAYER_ENHANCEMENT,
	UIConst.UI_ID_INVENTORY,
	UIConst.UI_ID_PET_RESEARCH_ILLUSTRATED_BOOK,
	UIConst.UI_ID_MAP,
	UIConst.UI_ID_PET_BALL,
	UIConst.UI_ID_HELP,
	UIConst.UI_ID_QUEST_PANEL,
	UIConst.UI_ID_COMMON_OBTAIN,
	UIConst.UI_ID_PET_RESEARCH,
	UIConst.UI_ID_PET_MANAGEMENT,
	UIConst.UI_ID_PVP_MENU,
	UIConst.UI_ID_PVP_CHOSE,
	UIConst.UI_PLAYER_RAISE_STAR,
	UIConst.UI_ID_APPEARANCE,
	UIConst.UI_ID_TRAIT_POPUP_DETAIL,
	UIConst.UI_ID_PET_FERTILITY,
	UIConst.UI_ID_PET_FERTILITY_RESULT,
	UIConst.UI_ID_PET_FERTILITY_RULE,
	UIConst.UI_ID_PET_FERTILITY_RESULT_POP,
	UIConst.UI_ID_TIME_SWITCH,
	UIConst.UI_ID_PET_REPORT,
	UIConst.UI_ID_TOWER_PAUSE,
	UIConst.UI_ID_TOWER_SETTLEMENT,
	UIConst.UI_ID_FUNC_MENU_UNLOCK,
	UIConst.UI_ID_SHOP_MAIN,
	UIConst.UI_ID_CATCH_ROGUE_PET_BAG,
	UIConst.UI_ID_TOWER_DEFEAT,
	UIConst.UI_ID_CATCH_ROGUE_RESULT,
	UIConst.UI_ID_BOSS_RUSH_MAIN,
	UIConst.UI_ID_NPC_DUEL_START,
	UIConst.UI_ID_COMMON_CONFIRM,
	UIConst.UI_ID_DIALOGUE_SKIP,
	UIConst.UI_ID_CASH_SHOP
}
UIConst.FuncMenuId = {
	TimeDungeon = 141
}
UIConst.UITipPriority = {
	Edge_Challenge = 831,
	Tip_Max = 999,
	Mid_Lower_AI_Helper = 557,
	Mid_Lower_Under_Tip = 601,
	Edge_Quest = 830
}
UIConst.TopLogoEnterRange = 40
UIConst.TopLogoLodNearRange = 20
UIConst.TopLogoBorderRange = 5
UIConst.TopLogoViewportCullMinDist = 8
UIConst.TipMutBlackList = {
	UIConst.UI_ID_DIALOGUE_DIALOG
}
UIConst.BossCombatState = {
	Normal = 0,
	Leaving = 2,
	InBattle = 1
}
UIConst.RogueCloseUI = {
	UIConst.UI_ID_OPEN_SPECIAL_TRAIN_PANEL,
	UIConst.UI_ID_FUNC_MENU,
	UIConst.UI_ID_ROG_LEVEL_SELECT,
	UIConst.UI_ID_TOWER_LEVEL_DETAIL,
	UIConst.UI_ID_EVENT
}
UIConst.DungeonCloseUI = {
	UIConst.UI_ID_GAME_INSTANCE,
	UIConst.UI_ID_TEAM_ROOM
}
UIConst.AppearanceMask = {
	CLOTHES = 2,
	ACCESSORY = 1,
	MAKEUP = 4,
	HAIR = 3
}
UIConst.HANDBOOK_PAGE_IDX = {
	FORM = 6,
	DISTRIBUTE = 5,
	ALBUM = 4,
	TOPIC = 3,
	EVOLUTION = 2,
	ABILITY = 1,
	SURVEY = 0,
	SURVEY_FORM = 11,
	INTERACT = 10
}
UIConst.HOMECAR_MODE_IDX = {
	MODIFYTOP = 5,
	MODIFYSHAPE = 4,
	DECORATION = 3,
	UPGRADE = 2,
	MAINPAGE = 1
}
UIConst.HOME_DESIGN_MODE = {
	SHAREDESIGN = 3,
	SYSTEMDESIGN = 2,
	MYDESIGN = 1,
	CREATE = 4
}
UIConst.HOME_COMPOSE_MODE = {
	PLAN = 2,
	COMBINATION = 1
}
UIConst.HOME_PLANTS_SEND_MODE = {
	GIFT = 1,
	HELP = 2
}
UIConst.CUSTOM_TEXT_REPLACE_PATTERN = {
	PLAYER_GENDER = "#playerGender#",
	PLAYER_NAME = "#playerName#",
	PLAYER_CHOOSE_TWIN_NAME = "#chosenTwinName#"
}
UIConst.PARSE_REPLACE_TEXT_MAP = {
	PLAYER_GENDER = "parsePlayerGender",
	PLAYER_NAME = "parsePlayerName",
	PLAYER_CHOOSE_TWIN_NAME = "parseChosenTwinPuppetName"
}
UIConst.INTERACT_TEXT_REPLACE_PATTERN = "#npcName#"
UIConst.SKILL_TYPE = {
	PASSIVE = 2,
	COMBATS = 1,
	SPECIAL = 4,
	EXPLORE = 3
}
UIConst.UI_HIDE_MATE_KEY = {
	QUSET_CHAPTER = "QuestChapter",
	CATCH_MODE = "CatchMode",
	ENABLE_FORCE_CHANGE_COMBAT_PET = "enableForceChangeCombatPet"
}
UIConst.DAMAGE_NUMBER_TYPE = {
	NUMBER_EP = 14,
	NUMBER_HIGH_POWERFUL = 13,
	NUMBER_HIGH_BREAK = 12,
	NUMBER_HIGH = 11,
	NUMBER_NORMAL_POWERFUL = 10,
	NUMBER_NORMAL_BREAK = 9,
	NUMBER_NORMAL = 8,
	NUMBER_LOW_POWERFUL = 7,
	NUMBER_LOW_BREAK = 6,
	NUMBER_LOW = 5,
	EXECUTE = 4,
	STATUS = 3,
	PUPPET_NUMBER = 2,
	PLAYER_NUMBER = 1,
	BOSS_CATCH3 = 18,
	BOSS_CATCH2 = 17,
	BOSS_CATCH1 = 16,
	NUMBER_RECOVER = 15
}
UIConst.INVENTORY_CARD = {
	CARD_SLOT_IDX = 2,
	CARD_IDX = 1,
	CARD_EMPTY_IDX = 0
}
UIConst.RTM_RTCROOM_TYPE = {
	VIDEO_ROOM = 2,
	VOICE_ROOM = 1,
	INVALID_ROOM = 0
}
UIConst.RTM_RTCP2P_TYPE = {
	VIDEO = 2,
	VOICE = 1,
	INVALID = 0
}
UIConst.RTM_RTCP2PEVENT = {
	CLOSE = 2,
	NoAnswer = 5,
	REFUSE = 4,
	ACCEPT = 3,
	CANCEL = 1
}
UIConst.RTM_RTCADMIN_COMMAND = {
	DISMISS_ADMINISTRATOR = 1,
	APPOINT_ADMINISTRATOR = 0,
	CLOSE_OTHERS_MICRO_CAMERA = 7,
	CLOSE_OTHERS_MICRO_PHONE = 6,
	ALLOW_SENDING_VIDEO = 5,
	FORBID_SENDING_VIDEO = 4,
	ALLOW_SENDING_AUDIO = 3,
	FORBID_SENDING_AUDIO = 2
}
UIConst.QUEST_COURSE_BLACK_LIST = {
	UIConst.UI_ID_FUNC_MENU
}
UIConst.RESIST_STATE = {
	HEAVY = 2,
	NONE = 1,
	LIGHT = 0
}
UIConst.PET_LIST_PET_STATE = {
	DEAD = 1,
	CD = 2,
	NORMAL = 0
}
UIConst.PET_CROWN_STATE = {
	GOLD = 2,
	SILVER = 1,
	NONE = 0
}
UIConst.EVENT_TAB_TYPE = {
	SCHOOL_GUIDE = 3,
	DAILY = 2,
	ACTIVITY = 1
}
UIConst.EVENT_WEEKWISH_PAGE_STATE = {
	EGG_APPEAR = 2,
	PRAYERS = 1,
	BEGIN = 0,
	EGG_GET = 3
}
UIConst.DESCRIPTION_ITEM_TYPE = {
	TAB_NAME = 5,
	ORDER_TEXT = 4,
	NORMAL_TEXT = 3,
	SUB_TITLE = 2,
	TITLE = 1
}
UIConst.DESCRIPTION_ITEM_TYPE_2_TINDEX = {
	[UIConst.DESCRIPTION_ITEM_TYPE.SUB_TITLE] = 0,
	[UIConst.DESCRIPTION_ITEM_TYPE.ORDER_TEXT] = 1,
	[UIConst.DESCRIPTION_ITEM_TYPE.NORMAL_TEXT] = 2
}
UIConst.DESCRIPTION_POP_UP_TYPE = {
	HAVE_TAB = 2,
	HAVE_BTN = 1,
	NO_BTN = 0,
	TAB_BTN = 3
}
UIConst.NEW_PET_BATTLE_TYPE = {
	BREAK = "BREAK",
	DPS = "DPS",
	HEAL = "HEAL",
	SUP = "SUP",
	ENERGY = "ENERGY"
}
UIConst.PET_FUNCTION_TEXT_MAP = {
	[UIConst.NEW_PET_BATTLE_TYPE.DPS] = "petFunctionTextDPS",
	[UIConst.NEW_PET_BATTLE_TYPE.SUP] = "petFunctionTextSUP",
	[UIConst.NEW_PET_BATTLE_TYPE.HEAL] = "petFunctionTextHEAL",
	[UIConst.NEW_PET_BATTLE_TYPE.BREAK] = "petFunctionTextBREAK",
	[UIConst.NEW_PET_BATTLE_TYPE.ENERGY] = "petFunctionTextENERGY"
}
UIConst.PET_FUNCTION_PAGE_INDEX_MAP = {
	[UIConst.NEW_PET_BATTLE_TYPE.DPS] = 4,
	[UIConst.NEW_PET_BATTLE_TYPE.SUP] = 0,
	[UIConst.NEW_PET_BATTLE_TYPE.HEAL] = 3,
	[UIConst.NEW_PET_BATTLE_TYPE.BREAK] = 2,
	[UIConst.NEW_PET_BATTLE_TYPE.ENERGY] = 1
}
UIConst.GRAB_EGG_BAG_TYPE = {
	NEARBY_ITEM = 7,
	PLAYER_BAG = 5,
	DEATH_BOX_MONSTER = 4,
	DEATH_BOX_PLAYER = 3,
	RESOURCE_BOX = 2,
	INVENTORY = 1,
	EMPTY = 0
}
UIConst.GRAB_EGG_ITEM_USE_TYPE = {
	CALCINATION = 8,
	SAFE_BOX = 7,
	REPAIR = 6,
	SPLIT = 5,
	DISCARD = 4,
	USE = 3,
	UNLOAD = 2,
	EQUIP = 1,
	CARRY = 0
}
UIConst.TOPLOGO_TEAM_MATE_STATE = {
	NEAR_DEAD = 0,
	AID = 2,
	FALLEN = 1
}
UIConst.BLOOD_BREAK_STATE = {
	STATE_BREAK = 0,
	STATE_BREAK_RECOVER = 1
}
UIConst.USE_BOSS_TITLE_V2 = true
UIConst.ROGUE_FROM_TYPE = {
	CATCH_ROGUE = 0,
	BOSS_RUSH = 1
}
UIConst.PET_SLOT_DISPLAY_TYPE = {
	TradeMarketPet = 3,
	TradeMarketPetOverview = 4,
	Normal = 1,
	Homeland = 2
}
UIConst.PET_SLOT_SUB_DISPLAY_TYPE = {
	Normal = 1,
	Homeland_Camp = 2
}
UIConst.HOMECAR_UPGRADE_TYPE = {
	Decoration = 2,
	HomeCar = 1
}
UIConst.AIR_WALL_TIP_TYPE = {
	A3Text = 1,
	None = 0,
	Dialogue = 1
}
UIConst.AIR_WALL_TIP_ID = {
	GRAB_EGG_PVP_AIR_WALL = 300401
}
UIConst.HOME_CAMP_UITYPE = {
	MANAGER = 0,
	DISPATCH = 1
}
UIConst.HOME_CAMP_DISPATCH_STATE = {
	Finished = 3,
	Dispatching = 2,
	UnDispatch = 0
}
UIConst.HOME_CAMP_MANAGER_PAGE_TYPE = {
	DispatchMgr = 1,
	CampMgr = 0
}
UIConst.HOME_CAMP_PETS_SLOT_MAXCNT = 3
UIConst.BLACK_SCREEN_ID = 161
UIConst.EvolveStatus = {
	CAN_EVOLVE_NOT_FIRST = 2,
	CAN_EVOLVE_FIRST = 1,
	CANNOT_EVOLVE = 0
}
UIConst.TimeType = {
	OneTime = 3,
	Short = 2,
	Full = 1
}
UIConst.TargetTimeType = {
	Short = 2,
	MonthDay = 3,
	Long = 1
}
UIConst.IOS_REVIEW_LOCK_FUNC = {
	service = 1,
	ACTIVITYCENTER = 1
}
UIConst.PetMgrTabType = {
	BATTLE = 0,
	EXPLORE = 1
}
UIConst.PetMgrTabType2Name = {
	[0] = "BATTLE",
	"EXPLORE"
}
UIConst.EventEcoTraceState = {
	UnLock = 0,
	Active = 2,
	Researching = 1
}
UIConst.STARCOMP_POS = {
	BEFORE = "before",
	MAX = "max",
	AFTER = "after",
	PETINFO = "petInfo"
}
UIConst.DISPLAY_RESIST_TIME = 3
UIConst.GlazeType = {
	Upgraded = 2,
	None = 0,
	Upgrade = 1
}
UIConst.GlazeSkillPos = {
	Before = "before",
	After = "after"
}
UIConst.SkillAtkType = {
	Physics = 1,
	Assist = 0,
	Magic = 2
}
UIConst.SkillAtkType2UITag = {
	[UIConst.SkillAtkType.Assist] = 2,
	[UIConst.SkillAtkType.Physics] = 0,
	[UIConst.SkillAtkType.Magic] = 1
}
UIConst.SkillAtkTypeTagStrKey = {
	[UIConst.SkillAtkType.Assist] = "PETSKILL_ASSIST",
	[UIConst.SkillAtkType.Physics] = "PETSKILL_PHYSICS",
	[UIConst.SkillAtkType.Magic] = "PETSKILL_MAGIC"
}
UIConst.DEFAULT_BLACK_CHANGE = {
	0.3,
	0.5
}
UIConst.CONSOLE_UI_SCENE_CAMERA_DELAY_FRAMES = 4
UIConst.UI_SCENE_PRESENTATION_MIN_WAIT_FRAMES = 2
UIConst.UI_SCENE_PRESENTATION_TIMEOUT_SECONDS = 0.5
UIConst.BLUR_BG_INCLUDE_UI = 0
UIConst.BLUR_BG_ONLY_SCENE = 1
UIConst.Pet_ProperDetail_SubDesType = {
	ElementResist = 3,
	ElementRestrain = 2,
	Info = 1,
	None = 0
}
UIConst.BLUR_TIMING = {
	AFTER_SHOW = 2,
	BEFORE_OPEN = 1,
	COMPONENT_DEFAULT = 0,
	MANUAL_RECAPTURE = 4,
	DELAY = 3
}
UIConst.BLUR_DEFAULT_TIMEOUT_FRAMES = 3
UIConst.BLUR_TARGET = {
	AUTO = 3,
	INCLUDE_UI = 2,
	SCENE_ONLY = 1,
	FOLLOW_PREFAB = 0
}
UIConst.UI_BLUR_CONFIGS = {
	[UIConst.UI_ID_EVENT] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.SCENE_ONLY
	},
	[UIConst.UI_ID_FRIENDSHIP_UP] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.INCLUDE_UI
	},
	[UIConst.UI_ID_PET_MANAGEMENT] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.AUTO
	},
	[UIConst.UI_ID_PET_MANAGEMENT_RELEASE_REVIEW] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.INCLUDE_UI
	},
	[UIConst.UI_ID_PET_PROPERTY] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.INCLUDE_UI
	},
	[UIConst.UI_ID_TOWER_WEEKLY_REWARD] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.INCLUDE_UI
	},
	[UIConst.UI_ID_PIECES_ITEM_PANEL] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.INCLUDE_UI
	},
	[UIConst.UI_ID_PET_EXCHANGE_SELECT] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.INCLUDE_UI
	},
	[UIConst.UI_ID_ITEM_VIEWER] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.INCLUDE_UI
	},
	[UIConst.UI_ID_SEASON_CALENDAR] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.INCLUDE_UI
	},
	[UIConst.UI_ID_HOME_SEASON_COLLECTIONCROP_DECOMPOSE] = {
		timing = UIConst.BLUR_TIMING.BEFORE_OPEN,
		target = UIConst.BLUR_TARGET.INCLUDE_UI
	}
}
UIConst.GAMEPAD_ONLY_SETTING_FUNC_TYPES = {
	holdToEnterCatchMode = true,
	gamepadCursorSpeed = true,
	gyroscopeRatio = true,
	rumbleRatio = true,
	gamepadRightStickDeadzone = true,
	gamepadLeftStickDeadzone = true,
	invertVerticalLook = true,
	invertHorizontalLook = true
}
UIConst.NON_GAMEPAD_ONLY_SETTING_FUNC_TYPES = {
	invertHorizontalLookMouse = true,
	invertVerticalLookMouse = true
}
UIConst.GAMEPAD_STICK_DEADZONE_MIN = 0.01
UIConst.GAMEPAD_STICK_DEADZONE_MAX = 90
UIConst.SAFE_AREA_MIN_INSET_SCREEN_RATIO = 1.7777777777777777
UIConst.SAFE_AREA_MIN_INSET_SCREEN_RATIO_TOLERANCE = 0.01
UIConst.SAFE_AREA_MIN_INSET_CHECK_INTERVAL = 0.2
UIConst.SAFE_AREA_MIN_INSET_STARTUP_REFRESH_COUNT = 30
UIConst.SAFE_AREA_MIN_INSET_SCREEN_CHANGE_REFRESH_COUNT = 2

return UIConst
