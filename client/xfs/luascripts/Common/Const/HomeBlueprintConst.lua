-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\HomeBlueprintConst.lua

local HomeBlueprintConst = {}

HomeBlueprintConst.SOURCE_TYPE = {
	UPLOADED = 1,
	SAVED_OTHER = 3,
	SYSTEM = 2
}
HomeBlueprintConst.BLUEPRINT_KIND = {
	COMBINATION = 1,
	PLAN = 2
}
HomeBlueprintConst.MONGO_COLLECTION_PUBLIC = "home_blueprint_public"
HomeBlueprintConst.MONGO_COLLECTION_SAVED = "home_blueprint_saved"
HomeBlueprintConst.MONGO_COLLECTION_ALLOC = "home_blueprint_alloc"
HomeBlueprintConst.DEFAULT_CONFIG = {
	blueprintCodeLength = 8,
	maxBlueprintDescLength = 100,
	maxBlueprintNameLength = 20,
	maxBlueprintCoverImageCount = 4,
	maxFurniturePerBlueprint = 100,
	maxSavedOtherBlueprintCount = 10,
	maxUploadBlueprintCount = 10
}
HomeBlueprintConst.MAX_PAGE_LIMIT = 50

return HomeBlueprintConst
