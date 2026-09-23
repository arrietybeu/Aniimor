-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Config\\Config.lua

local Config = {
	Custom = {
		_Engine_PushAckDict = {
			NameSpace = "Core.CustomTypes._Engine_PushAckDict",
			__ValueType__ = "int",
			__IntTypeKey__ = false,
			Properties = {}
		},
		Ability = {
			NameSpace = "CustomTypes.Ability",
			Properties = {
				abilityId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				abilityTag = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				abilityLevel = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				cdEndTime = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				epCost = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				spCost = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				isSubAbility = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				},
				isDestroyed = {
					"boolean",
					false,
					"ServerOnly",
					"NPER"
				},
				actorId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				itemSkillCanCastCount = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				srcAbilityIdBySteal = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				storeType = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				combatContextId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				overrideEpCost = {
					"int",
					-1,
					"AllClients",
					"NPER"
				},
				markAbilityDelayCd = {
					"boolean",
					false,
					"ServerOnly",
					"NPER"
				}
			}
		},
		AbilityInfo = {
			NameSpace = "CustomTypes.AbilityInfo",
			Properties = {
				abilityId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				abilityLv = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				cdDuration = {
					"double",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		AbilityLoadingInfo = {
			NameSpace = "CustomTypes.AbilityLoadingInfo",
			Properties = {
				cd = {
					"double",
					0,
					"ServerOnly",
					"NPER"
				},
				lastTime = {
					"double",
					0,
					"OwnClient",
					"NPER"
				},
				cnt = {
					"double",
					0,
					"OwnClient",
					"NPER"
				},
				maxCnt = {
					"double",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		AbilityLoadingMap = {
			NameSpace = "CustomTypes.AbilityLoadingMap",
			__ValueType__ = "AbilityLoadingInfo",
			__IntTypeKey__ = true,
			Properties = {
				nextLoadingAbilityId = {
					"double",
					0,
					"ServerOnly",
					"NPER"
				},
				nextLoadingTime = {
					"double",
					0,
					"ServerOnly",
					"NPER"
				},
				timerId = {
					"double",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		AbilityMap = {
			NameSpace = "CustomTypes.AbilityMap",
			__ValueType__ = "Ability",
			__IntTypeKey__ = true,
			Properties = {}
		},
		AbilityPresetInfo = {
			NameSpace = "CustomTypes.AbilityPresetInfo",
			__ValueType__ = "int",
			__IntTypeKey__ = true,
			Properties = {
				name = {
					"string",
					"",
					"OwnClient",
					"PER"
				}
			}
		},
		AbilityPresetMap = {
			NameSpace = "CustomTypes.AbilityPresetMap",
			__ValueType__ = "AbilityPresetInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		AppearanceUnitDesignList = {
			NameSpace = "CustomTypes.AppearanceUnitDesignList",
			__ValueType__ = "AppearanceUnitDesign",
			__IntTypeKey__ = true
		},
		AssistCarryList = {
			NameSpace = "CustomTypes.AssistCarryList",
			__ValueType__ = "AssistCarryInfo",
			__IntTypeKey__ = true
		},
		AcceptedQuestData = {
			NameSpace = "CustomTypes.AcceptedQuestData",
			Properties = {
				configId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				state = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				acceptTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				objectives = {
					"QuestObjectivesMap",
					{},
					"OwnClient",
					"PER"
				},
				runCond = {
					"QuestObjectivesMap",
					{},
					"OwnClient",
					"PER"
				},
				runState = {
					"boolean",
					true,
					"OwnClient",
					"PER"
				}
			}
		},
		AcceptedQuestDataMap = {
			NameSpace = "CustomTypes.AcceptedQuestDataMap",
			__ValueType__ = "AcceptedQuestData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ActivityPetSaveData = {
			NameSpace = "CustomTypes.ActivityPetSaveData",
			__ValueType__ = "ActivityPetSaveWeekSumyData",
			__IntTypeKey__ = true,
			Properties = {
				pshase = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				lastPshase = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				subActId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				savePetInfo = {
					"PetSimplelInfo",
					{},
					"OwnClient",
					"PER"
				},
				saveTimes = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		ActivityPetSaveWeekSumyData = {
			NameSpace = "CustomTypes.ActivityPetSaveWeekSumyData",
			Properties = {
				subActId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				pets = {
					"PetSimpleMap",
					{},
					"OwnClient",
					"PER"
				},
				received = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		ActivityTaskInfo = {
			NameSpace = "CustomTypes.ActivityTaskInfo",
			Properties = {
				taskId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				state = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				time = {
					"double",
					0,
					"OwnClient",
					"PER"
				},
				sparam = {
					"string",
					"",
					"OwnClient",
					"PER"
				}
			}
		},
		ActivityTaskInfoMap = {
			NameSpace = "CustomTypes.ActivityTaskInfoMap",
			__ValueType__ = "ActivityTaskInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ActorPartInfo = {
			NameSpace = "CustomTypes.ActorPartInfo",
			Properties = {
				actorPartIdx = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				visible = {
					"boolean",
					true,
					"AllClients",
					"NPER"
				},
				lockable = {
					"boolean",
					true,
					"AllClients",
					"NPER"
				},
				hittable = {
					"boolean",
					true,
					"AllClients",
					"NPER"
				}
			}
		},
		ActorPartsMap = {
			NameSpace = "CustomTypes.ActorPartsMap",
			__ValueType__ = "ActorPartInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		AdventureInfo = {
			NameSpace = "CustomTypes.AdventureInfo",
			Properties = {
				adventureSandboxId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				adventureWaitTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				blockId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				sceneId = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		AdventureMap = {
			NameSpace = "CustomTypes.AdventureMap",
			__ValueType__ = "AdventureInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		AllSandboxData = {
			NameSpace = "CustomTypes.AllSandboxData",
			__ValueType__ = "SingleSandboxData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		AppearanceCustom = {
			NameSpace = "CustomTypes.AppearanceCustom",
			__ValueType__ = "AppearanceCustomOne",
			__IntTypeKey__ = true,
			Properties = {
				index = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		AppearanceCustomOne = {
			NameSpace = "CustomTypes.AppearanceCustomOne",
			__ValueType__ = "AppearanceJewelryInfo",
			__IntTypeKey__ = true,
			Properties = {
				customName = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				isShowBag = {
					"boolean",
					true,
					"AllClients",
					"PER"
				},
				customShow = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				clothesDesigns = {
					"AppearanceUnitDesignMap",
					{},
					"AllClients",
					"PER"
				},
				hairInfo = {
					"IntStringMap",
					{},
					"AllClients",
					"PER"
				},
				makeUpInfo = {
					"IntStringMap",
					{},
					"AllClients",
					"PER"
				},
				suitId = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		AppearanceHairCustom = {
			NameSpace = "CustomTypes.AppearanceHairCustom",
			__ValueType__ = "AppearanceCustom",
			__IntTypeKey__ = true,
			Properties = {}
		},
		AppearanceInfo = {
			NameSpace = "CustomTypes.AppearanceInfo",
			__ValueType__ = "AppearanceUnit",
			__IntTypeKey__ = true,
			Properties = {}
		},
		AppearanceJewelryInfo = {
			NameSpace = "CustomTypes.AppearanceJewelryInfo",
			Properties = {
				configId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				attachBone = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				posX = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				posY = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				posZ = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				rotX = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				rotY = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				rotZ = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				scale = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				colorJewelryId = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		AppearanceUnit = {
			NameSpace = "CustomTypes.AppearanceUnit",
			Properties = {
				createdTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				expiredTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				designList = {
					"AppearanceUnitDesignList",
					{},
					"OwnClient",
					"PER"
				},
				designIndex = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				jewelryUnlockInfo = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		AppearanceUnitDesign = {
			NameSpace = "CustomTypes.AppearanceUnitDesign",
			Properties = {
				isChange = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				name = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				stainMatMap = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				decalMatMap = {
					"string",
					"",
					"AllClients",
					"PER"
				}
			}
		},
		AppearanceUnitDesignMap = {
			NameSpace = "CustomTypes.AppearanceUnitDesignMap",
			__ValueType__ = "AppearanceUnitDesign",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ArkChestRefreshInfo = {
			NameSpace = "CustomTypes.ArkChestRefreshInfo",
			Properties = {
				configId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				chestIds = {
					"IntList",
					{},
					"ServerOnly",
					"PER"
				},
				posIds = {
					"IntList",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		ArkChestRefreshMap = {
			NameSpace = "CustomTypes.ArkChestRefreshMap",
			__ValueType__ = "ArkChestRefreshInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ArkScreenInfo = {
			NameSpace = "CustomTypes.ArkScreenInfo",
			Properties = {
				screenId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				contentId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				contentIndex = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				contentBeginTime = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				sourceScreenId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				sourceContentScreenId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				isInSpecial = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				}
			}
		},
		ArkScreenInfoMap = {
			NameSpace = "CustomTypes.ArkScreenInfoMap",
			__ValueType__ = "ArkScreenInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		AssistCarryInfo = {
			NameSpace = "CustomTypes.AssistCarryInfo",
			Properties = {
				itemId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				totalExp = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				talentList = {
					"TalentList",
					{},
					"OwnClient",
					"PER"
				},
				ownerCoreCarryPos = {
					"ItemPos",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		BadgeInfo = {
			NameSpace = "CustomTypes.BadgeInfo",
			Properties = {
				curQuality = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				randomQuality = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				isRevert = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				isPlayAnim = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				isOpen = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				upNums = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		BadgeInfoMap = {
			NameSpace = "CustomTypes.BadgeInfoMap",
			__ValueType__ = "BadgeInfo",
			__IntTypeKey__ = true,
			Properties = {
				moneySum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				moneyUsed = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				isHaveData = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		BadgeUnlockInfo = {
			NameSpace = "CustomTypes.BadgeUnlockInfo",
			Properties = {
				unlockTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				unlockLevel = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				unlockStarTitle = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		BaseAttributeList = {
			NameSpace = "CustomTypes.BaseAttributeList",
			__ValueType__ = "double",
			__IntTypeKey__ = true
		},
		BasePropertyList = {
			NameSpace = "CustomTypes.BasePropertyList",
			__ValueType__ = "BaseProperty",
			__IntTypeKey__ = true
		},
		BoolList = {
			NameSpace = "CustomTypes.BoolList",
			__ValueType__ = "boolean",
			__IntTypeKey__ = true
		},
		BuffDataList = {
			NameSpace = "CustomTypes.BuffDataList",
			__ValueType__ = "BuffData",
			__IntTypeKey__ = true
		},
		CapturePuppetInfos = {
			NameSpace = "CustomTypes.CapturePuppetInfos",
			__ValueType__ = "CapturePuppetInfo",
			__IntTypeKey__ = true
		},
		CatchPetInfoList = {
			NameSpace = "CustomTypes.CatchPetInfoList",
			__ValueType__ = "CatchPetInfo",
			__IntTypeKey__ = true
		},
		BadgeUnlockInfoMap = {
			NameSpace = "CustomTypes.BadgeUnlockInfoMap",
			__ValueType__ = "BadgeUnlockInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		BanNpcFuncInfo = {
			NameSpace = "CustomTypes.BanNpcFuncInfo",
			__ValueType__ = "IntBoolMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		BasePrimaryPropertys = {
			NameSpace = "CustomTypes.BasePrimaryPropertys",
			Properties = {
				potentialPointSum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				usedPotentialPointSum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				propertyStrengPoint = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				extraStrengPoint = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"PER"
				},
				propertyStrengMax = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				isAutoAddStrengPoint = {
					"boolean",
					true,
					"OwnClient",
					"PER"
				},
				firstCreate = {
					"boolean",
					true,
					"OwnClient",
					"PER"
				}
			}
		},
		BaseProperty = {
			NameSpace = "CustomTypes.BaseProperty",
			Properties = {
				speciesPoint = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				enhancedCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				iLvEv = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				iLvEx = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				iLvLn = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				indLv = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				totalByUp = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				total = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		BatchDialogueInfo = {
			NameSpace = "CustomTypes.BatchDialogueInfo",
			Properties = {
				curIndex = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				dialogueList = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				isFinished = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		BatchDialogueMap = {
			NameSpace = "CustomTypes.BatchDialogueMap",
			__ValueType__ = "BatchDialogueInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		BehaviorStatusMap = {
			NameSpace = "CustomTypes.BehaviorStatusMap",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		BlockCatchedPetMap = {
			NameSpace = "CustomTypes.BlockCatchedPetMap",
			__ValueType__ = "CatchedPetMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		BlockPetRecordMap = {
			NameSpace = "CustomTypes.BlockPetRecordMap",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		BossRushTeammemberInfo = {
			NameSpace = "CustomTypes.BossRushTeammemberInfo",
			Properties = {
				playerId = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				levelIsReady = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				levelBatPetList = {
					"PetSimpleListMap",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		BossRushTeammemberInfoMap = {
			NameSpace = "CustomTypes.BossRushTeammemberInfoMap",
			__ValueType__ = "BossRushTeammemberInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		BuffData = {
			NameSpace = "CustomTypes.BuffData",
			Properties = {
				instanceId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				srcEntityId = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				srcAbilityId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				srcAbilityStoreType = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				srcCombatContextId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				castingCombatContextId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				duration = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				expiredTime = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				layer = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				level = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				templateId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				isPermanent = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				},
				isTeamBuff = {
					"boolean",
					false,
					"OwnClient",
					"NPER"
				},
				isApplyToPlayer = {
					"boolean",
					false,
					"ServerOnly",
					"NPER"
				},
				destroyReason = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				freezeBuffStartTime = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				specialType = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				category = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		CampCarDispatchInfo = {
			NameSpace = "CustomTypes.CampCarDispatchInfo",
			Properties = {
				campId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				dispId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				endTs = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				isFinished = {
					"boolean",
					false,
					"AllClients",
					"PER"
				},
				startTs = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				finishTs = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		CampCarSyncInfo = {
			NameSpace = "CustomTypes.CampCarSyncInfo",
			Properties = {
				likeCnt = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				furnitureComfortValue = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				petComfortValue = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				CampCarLoadValue = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		CampLineInfo = {
			NameSpace = "CustomTypes.CampLineInfo",
			Properties = {
				lineUid = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				staticId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				areaId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				bucketId = {
					"int",
					-1,
					"AllClients",
					"NPER"
				},
				sceneId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				displayCode = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				loginCount = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				enterCount = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				isPrivate = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				},
				ownerUid = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				ownerEpoch = {
					"int",
					0,
					"AllClients",
					"NPER"
				}
			}
		},
		CampScanEffect = {
			NameSpace = "CustomTypes.CampScanEffect",
			Properties = {
				timerId = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		CampScanMap = {
			NameSpace = "CustomTypes.CampScanMap",
			__ValueType__ = "CampScanEffect",
			__IntTypeKey__ = true,
			Properties = {}
		},
		CapturePuppetInfo = {
			NameSpace = "CustomTypes.CapturePuppetInfo",
			Properties = {
				entId = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				fromBehind = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				},
				isCamouflage = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				},
				captureSuccess = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				}
			}
		},
		CaptureSessionInfo = {
			NameSpace = "CustomTypes.CaptureSessionInfo",
			Properties = {
				id = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				state = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				createTime = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				guaranteeTimer = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				ballUid = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				ballCfgId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				ballItemId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				ballEntId = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				puppetInfos = {
					"CapturePuppetInfos",
					{},
					"AllClients",
					"NPER"
				},
				settleType = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				baseCaptureTimelinePhase = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				catchType = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				luckyresult = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				luckyRewardItems = {
					"IntIntMap",
					{},
					"ServerOnly",
					"NPER"
				},
				luckyEnergyLevel = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		CaptureSessionMap = {
			NameSpace = "CustomTypes.CaptureSessionMap",
			__ValueType__ = "CaptureSessionInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		CatchPetInfo = {
			NameSpace = "CustomTypes.CatchPetInfo",
			Properties = {
				petId = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				level = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				label = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				templateId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				reportTypes = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				ratingIndex = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				followList = {
					"StringList",
					{},
					"OwnClient",
					"PER"
				},
				moneyNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		CatchReportInfo = {
			NameSpace = "CustomTypes.CatchReportInfo",
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				moneyNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				itemRewardMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		CatchReportMap = {
			NameSpace = "CustomTypes.CatchReportMap",
			__ValueType__ = "CatchReportInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		CatchRogueInfo = {
			NameSpace = "CustomTypes.CatchRogueInfo",
			Properties = {
				petList = {
					"StringList",
					{},
					"OwnClient",
					"PER"
				},
				ballList = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				ballCountMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				gameId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				gameSettled = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				levelId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				levelTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				levelSettled = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				},
				floorId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				floorSuccess = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				savedPetMap = {
					"CatchRoguePetMap",
					{},
					"OwnClient",
					"PER"
				},
				savedPuppetMap = {
					"CatchRoguePuppetMap",
					{},
					"OwnClient",
					"PER"
				},
				puppetRandomAddOn = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				purchaseTimeCnt = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				purchaseReviveCnt = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				statCntEnterGame = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				statCntFinishGame = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				statCntBallUsed = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				catchedPetIds = {
					"StringList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		CustomAbilityIds = {
			NameSpace = "CustomTypes.CustomAbilityIds",
			__ValueType__ = "CustomAbilityIdsOne",
			__IntTypeKey__ = true
		},
		DoubleList = {
			NameSpace = "CustomTypes.DoubleList",
			__ValueType__ = "double",
			__IntTypeKey__ = true
		},
		CatchRoguePetInfo = {
			NameSpace = "CustomTypes.CatchRoguePetInfo",
			Properties = {
				hpRatio = {
					"double",
					1,
					"OwnClient",
					"PER"
				},
				epRatio = {
					"double",
					1,
					"ServerOnly",
					"PER"
				},
				spRatio = {
					"double",
					1,
					"ServerOnly",
					"PER"
				}
			}
		},
		CatchRoguePetMap = {
			NameSpace = "CustomTypes.CatchRoguePetMap",
			__ValueType__ = "CatchRoguePetInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		CatchRoguePuppetInfo = {
			NameSpace = "CustomTypes.CatchRoguePuppetInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				level = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				label = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				position = {
					"ScenePos",
					{},
					"ServerOnly",
					"PER"
				},
				hpRatio = {
					"double",
					1,
					"OwnClient",
					"PER"
				},
				addOnId = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		CatchRoguePuppetMap = {
			NameSpace = "CustomTypes.CatchRoguePuppetMap",
			__ValueType__ = "CatchRoguePuppetInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		CatchedPetInfo = {
			NameSpace = "CustomTypes.CatchedPetInfo",
			Properties = {
				isCatched = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				updateTs = {
					"double",
					0,
					"OwnClient",
					"PER"
				},
				weatherId = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		CatchedPetMap = {
			NameSpace = "CustomTypes.CatchedPetMap",
			__ValueType__ = "CatchedPetInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ChainAttackInfo = {
			NameSpace = "CustomTypes.ChainAttackInfo",
			Properties = {
				lastLockedActorId = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				maxChainCnt = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				totalDamage = {
					"double",
					0,
					"OwnClient",
					"NPER"
				},
				inExtreme = {
					"boolean",
					false,
					"OwnClient",
					"NPER"
				},
				inPlayerTeamChain = {
					"boolean",
					false,
					"OwnClient",
					"NPER"
				},
				isResponded = {
					"boolean",
					false,
					"OwnClient",
					"NPER"
				},
				pushedResponse = {
					"boolean",
					false,
					"OwnClient",
					"NPER"
				},
				curResponderId = {
					"string",
					"",
					"OwnClient",
					"NPER"
				},
				teamChainPetList = {
					"StringList",
					{},
					"OwnClient",
					"NPER"
				}
			}
		},
		CharacterInfo = {
			NameSpace = "CustomTypes.CharacterInfo",
			Properties = {
				curCharacter = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				characterList = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		ClassMergeInfo = {
			NameSpace = "CustomTypes.ClassMergeInfo",
			Properties = {
				mergeKey = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				LastWeekTs = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		ClassMergeMap = {
			NameSpace = "CustomTypes.ClassMergeMap",
			__ValueType__ = "ClassMergeInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		CompletedTargetMap = {
			NameSpace = "CustomTypes.CompletedTargetMap",
			__ValueType__ = "IntBoolMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		CoolDownInfo = {
			NameSpace = "CustomTypes.CoolDownInfo",
			__ValueType__ = "double",
			__IntTypeKey__ = true,
			Properties = {}
		},
		CoolDownMap = {
			NameSpace = "CustomTypes.CoolDownMap",
			__ValueType__ = "CoolDownInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		CoreCarryInfo = {
			NameSpace = "CustomTypes.CoreCarryInfo",
			Properties = {
				itemId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				totalExp = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				talentList = {
					"TalentList",
					{},
					"OwnClient",
					"PER"
				},
				ownerPetId = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				assistCarryPosList = {
					"ItemPosList",
					{},
					"OwnClient",
					"PER"
				},
				assistCarryTypeList = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				certifiedBaseFormPet = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		CustomAbilityIdsOne = {
			NameSpace = "CustomTypes.CustomAbilityIdsOne",
			Properties = {
				abilityIds = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				name = {
					"string",
					"",
					"OwnClient",
					"PER"
				}
			}
		},
		CustomMapMarkInfo = {
			NameSpace = "CustomTypes.CustomMapMarkInfo",
			Properties = {
				markIconIndex = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				pos = {
					"Position",
					{},
					"OwnClient",
					"PER"
				},
				name = {
					"string",
					"",
					"OwnClient",
					"PER"
				}
			}
		},
		CustomMapMarkInnerMap = {
			NameSpace = "CustomTypes.CustomMapMarkInnerMap",
			__ValueType__ = "CustomMapMarkInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		CustomMapMarkMap = {
			NameSpace = "CustomTypes.CustomMapMarkMap",
			__ValueType__ = "CustomMapMarkInnerMap",
			__IntTypeKey__ = true,
			Properties = {
				genId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		DailyAcquisitionData = {
			NameSpace = "CustomTypes.DailyAcquisitionData",
			Properties = {
				dayKey = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				petCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				eggCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				revision = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				ackRevision = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				pendingSnapshots = {
					"StringStringMap",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		DisplayFormPetLabelByCountryMap = {
			NameSpace = "CustomTypes.DisplayFormPetLabelByCountryMap",
			__ValueType__ = "DisplayFormPetLabelCountryMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		DisplayFormPetLabelCountryMap = {
			NameSpace = "CustomTypes.DisplayFormPetLabelCountryMap",
			__ValueType__ = "DisplayFormPetLabelInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		DisplayFormPetLabelInfo = {
			NameSpace = "CustomTypes.DisplayFormPetLabelInfo",
			Properties = {
				label = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				shinyStyle = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		DisplayFormPetLabelMap = {
			NameSpace = "CustomTypes.DisplayFormPetLabelMap",
			__ValueType__ = "DisplayFormPetLabelInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		DisplayPetFormByCountryMap = {
			NameSpace = "CustomTypes.DisplayPetFormByCountryMap",
			__ValueType__ = "DisplayPetFormCountryMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		DisplayPetFormCountryMap = {
			NameSpace = "CustomTypes.DisplayPetFormCountryMap",
			__ValueType__ = "DisplayPetFormInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		DisplayPetFormInfo = {
			NameSpace = "CustomTypes.DisplayPetFormInfo",
			Properties = {
				petPrototypeId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				label = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				shinyStyle = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		DisplayPetFormMap = {
			NameSpace = "CustomTypes.DisplayPetFormMap",
			__ValueType__ = "DisplayPetFormInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		EnvData = {
			NameSpace = "CustomTypes.EnvData",
			Properties = {
				destroyed = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		ExampleList = {
			NameSpace = "CustomTypes.ExampleList",
			__ValueType__ = "int",
			__IntTypeKey__ = true
		},
		FCSettleRecordList = {
			NameSpace = "CustomTypes.FCSettleRecordList",
			__ValueType__ = "FCSettleRecord",
			__IntTypeKey__ = true
		},
		FairPvpPresetList = {
			NameSpace = "CustomTypes.FairPvpPresetList",
			__ValueType__ = "FairPvpPreset",
			__IntTypeKey__ = true
		},
		GachaDrawItemRecordList = {
			NameSpace = "CustomTypes.GachaDrawItemRecordList",
			__ValueType__ = "GachaDrawItemRecord",
			__IntTypeKey__ = true
		},
		GachaDrawRecordList = {
			NameSpace = "CustomTypes.GachaDrawRecordList",
			__ValueType__ = "GachaDrawRecord",
			__IntTypeKey__ = true
		},
		EquipShowData = {
			NameSpace = "CustomTypes.EquipShowData",
			Properties = {
				equipId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				curDura = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				maxDura = {
					"double",
					0,
					"AllClients",
					"NPER"
				}
			}
		},
		EquipShowDataMap = {
			NameSpace = "CustomTypes.EquipShowDataMap",
			__ValueType__ = "EquipShowData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		EventMap = {
			NameSpace = "CustomTypes.EventMap",
			Properties = {
				sysEventTriggerCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				sysEventTriggerGroupCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		ExampleDict = {
			NameSpace = "CustomTypes.ExampleDict",
			__ValueType__ = "int",
			__IntTypeKey__ = true,
			Properties = {}
		},
		FCSettleRecord = {
			NameSpace = "CustomTypes.FCSettleRecord",
			Properties = {
				settleTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				phaseId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				ballUsedMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				petTemplateId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				rewards = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				isByLevelRandom = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		FairPvpPreset = {
			NameSpace = "CustomTypes.FairPvpPreset",
			Properties = {
				fairPvpTeamName = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				fairPvpTeamList = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		FishingCaptureInfo = {
			NameSpace = "CustomTypes.FishingCaptureInfo",
			Properties = {
				progressValue = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				layerCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				bestBattleGrade = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				bestBattleTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				totalThrowCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				levelRewardCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				captureSuccess = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				sessionBattleGrade = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				sessionCaptureBonus = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				sessionBallUsedMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				settleRewardSent = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				},
				energyConvertRewardSent = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				}
			}
		},
		FlowerBloomSessionSaveInfo = {
			NameSpace = "CustomTypes.FlowerBloomSessionSaveInfo",
			Properties = {
				createId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				totalCreated = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				nourishCostItems = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				isleylineFlowerUP = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				},
				puppetSaveInfoList = {
					"PuppetSaveInfoList",
					{},
					"ServerOnly",
					"PER"
				},
				stageCreateCount = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		FlowerBloomSessionSaveMap = {
			NameSpace = "CustomTypes.FlowerBloomSessionSaveMap",
			__ValueType__ = "FlowerBloomSessionSaveInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		FlowerHoldInfo = {
			NameSpace = "CustomTypes.FlowerHoldInfo",
			Properties = {
				state = {
					"int",
					1,
					"ServerOnly",
					"PER"
				},
				startTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				catchCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				energyGain = {
					"double",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		FlowerHoldMap = {
			NameSpace = "CustomTypes.FlowerHoldMap",
			__ValueType__ = "FlowerHoldInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		FormationInfo = {
			NameSpace = "CustomTypes.FormationInfo",
			Properties = {
				customName = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				formation = {
					"StringList",
					{},
					"OwnClient",
					"PER"
				},
				exploreFormation = {
					"StringList",
					{},
					"OwnClient",
					"PER"
				},
				isCustomed = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				isNew = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		FriendInteractAction = {
			NameSpace = "CustomTypes.FriendInteractAction",
			Properties = {
				actionId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				start_ts = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				requestUid = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				acceptUid = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				actionTimer = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		GachaBase = {
			NameSpace = "CustomTypes.GachaBase",
			Properties = {
				gachaId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				drawCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				pityCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				claimedTimesRewardNums = {
					"IntBoolMap",
					{},
					"OwnClient",
					"PER"
				},
				itemRecords = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				drawRecords = {
					"GachaDrawRecordList",
					{},
					"OwnClient",
					"PER"
				},
				dailyShareCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				curCanShareCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				dailyClaimedShareRewardCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				gachaFirstTenPull = {
					"boolean",
					true,
					"OwnClient",
					"PER"
				}
			}
		},
		GachaBaseMap = {
			NameSpace = "CustomTypes.GachaBaseMap",
			__ValueType__ = "GachaBase",
			__IntTypeKey__ = true,
			Properties = {}
		},
		GachaDrawItemRecord = {
			NameSpace = "CustomTypes.GachaDrawItemRecord",
			Properties = {
				poolRecordId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				poolId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				itemId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				itemNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				isPity = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				isDecompose = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				decomposeRewardId = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		GachaDrawRecord = {
			NameSpace = "CustomTypes.GachaDrawRecord",
			Properties = {
				drawTimes = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				drawTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				itemRecords = {
					"GachaDrawItemRecordList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		GamePlayIdMap = {
			NameSpace = "CustomTypes.GamePlayIdMap",
			__ValueType__ = "StringBooleanMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		GamePlaySubTargetData = {
			NameSpace = "CustomTypes.GamePlaySubTargetData",
			Properties = {
				subTargetId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				isFinish = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				}
			}
		},
		GamePlaySubTargetMap = {
			NameSpace = "CustomTypes.GamePlaySubTargetMap",
			__ValueType__ = "GamePlaySubTargetData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		GamePlayTargetData = {
			NameSpace = "CustomTypes.GamePlayTargetData",
			Properties = {
				gamePlayId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				subTargetProcess = {
					"GamePlaySubTargetMap",
					{},
					"OwnClient",
					"PER"
				},
				isFinish = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		GamePlayTargetMap = {
			NameSpace = "CustomTypes.GamePlayTargetMap",
			__ValueType__ = "GamePlayTargetData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		GmTriggerValue = {
			NameSpace = "CustomTypes.GmTriggerValue",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		GuideCourseInfo = {
			NameSpace = "CustomTypes.GuideCourseInfo",
			Properties = {
				passCnt = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				rewardFlag = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				beginTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		GuideCourseMap = {
			NameSpace = "CustomTypes.GuideCourseMap",
			__ValueType__ = "GuideCourseInfo",
			__IntTypeKey__ = true,
			Properties = {
				courseCompleteCnt = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				levelAwardFlags = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		GuidenceItemList = {
			NameSpace = "CustomTypes.GuidenceItemList",
			__ValueType__ = "GuidenceItem",
			__IntTypeKey__ = true
		},
		HomeBlueprintGroupInfoList = {
			NameSpace = "CustomTypes.HomeBlueprintGroupInfoList",
			__ValueType__ = "HomeBlueprintGroupInfo",
			__IntTypeKey__ = true
		},
		HomeFoodSlotList = {
			NameSpace = "CustomTypes.HomeFoodSlotList",
			__ValueType__ = "HomeFoodSlotInfo",
			__IntTypeKey__ = true
		},
		GuideCourseMapMap = {
			NameSpace = "CustomTypes.GuideCourseMapMap",
			__ValueType__ = "GuideCourseMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		GuidenceItem = {
			NameSpace = "CustomTypes.GuidenceItem",
			Properties = {
				guidenceId = {
					"int",
					-1,
					"OwnClient",
					"PER"
				},
				timeStamp = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		GuidenceMap = {
			NameSpace = "CustomTypes.GuidenceMap",
			__ValueType__ = "GuidenceItemList",
			__IntTypeKey__ = true,
			Properties = {}
		},
		GuidenceUnlockedEventMap = {
			NameSpace = "CustomTypes.GuidenceUnlockedEventMap",
			__ValueType__ = "int",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HatchItemSnapshot = {
			NameSpace = "CustomTypes.HatchItemSnapshot",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				objID = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				useTimes = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				extraProp = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				owner = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				schemaVersion = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				invId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				payload = {
					"string",
					"",
					"ServerOnly",
					"PER"
				}
			}
		},
		HatchSlotInfo = {
			NameSpace = "CustomTypes.HatchSlotInfo",
			Properties = {
				item = {
					"HatchItemSnapshot",
					{},
					"OwnClient",
					"PER"
				},
				endTs = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				tempStatus = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				speedUpTime = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		HatchSlotMap = {
			NameSpace = "CustomTypes.HatchSlotMap",
			__ValueType__ = "HatchSlotInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HatredInfo = {
			NameSpace = "CustomTypes.HatredInfo",
			Properties = {
				actorId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				hatredValue = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				time = {
					"int",
					0,
					"AllClients",
					"NPER"
				}
			}
		},
		HatredMap = {
			NameSpace = "CustomTypes.HatredMap",
			__ValueType__ = "HatredInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomeAreaStatInfo = {
			NameSpace = "CustomTypes.HomeAreaStatInfo",
			Properties = {
				loadValue = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				comfortValue = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomeAreaStats = {
			NameSpace = "CustomTypes.HomeAreaStats",
			__ValueType__ = "HomeAreaStatInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomeBasicInfo = {
			NameSpace = "CustomTypes.HomeBasicInfo",
			Properties = {
				upgradeEndTs = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				level = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				name = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				carShapeInfo = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				carCompsLevel = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				unlockedHomeCampIds = {
					"StringBoolMap",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		HomeBlueprintGroupInfo = {
			NameSpace = "CustomTypes.HomeBlueprintGroupInfo",
			Properties = {
				blueprintId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				areaId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				yawAngle = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				ornamentIds = {
					"IntList",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		HomeCampPendingSwitch = {
			NameSpace = "CustomTypes.HomeCampPendingSwitch",
			Properties = {
				fromAreaId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				fromBucketId = {
					"int",
					-1,
					"ServerOnly",
					"PER"
				},
				oldTargetEnterAreaId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				oldTargetEnterBucketId = {
					"int",
					-1,
					"ServerOnly",
					"PER"
				},
				targetStaticId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				targetLineUid = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				targetAreaId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				targetBucketId = {
					"int",
					-1,
					"ServerOnly",
					"PER"
				},
				attemptCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				lastAttemptTs = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		HomeComfortStats = {
			NameSpace = "CustomTypes.HomeComfortStats",
			Properties = {
				furnitureComfortValue = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				petComfortValue = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				comfortValue = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomeEnvInfo = {
			NameSpace = "CustomTypes.HomeEnvInfo",
			Properties = {
				ornaments = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				envProduce = {
					"double",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomeEnvMap = {
			NameSpace = "CustomTypes.HomeEnvMap",
			__ValueType__ = "HomeEnvInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomeEventInfo = {
			NameSpace = "CustomTypes.HomeEventInfo",
			Properties = {
				textId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				targetIds = {
					"StringList",
					{},
					"AllClients",
					"PER"
				},
				createTs = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				solvedTs = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomeEventMap = {
			NameSpace = "CustomTypes.HomeEventMap",
			__ValueType__ = "HomeEventInfo",
			__IntTypeKey__ = false,
			Properties = {
				eventInsIdsByTimeAsc = {
					"StringList",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		HomeFoodSlotInfo = {
			NameSpace = "CustomTypes.HomeFoodSlotInfo",
			Properties = {
				itemId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				itemNum = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomeHandbookItemInfo = {
			NameSpace = "CustomTypes.HomeHandbookItemInfo",
			Properties = {
				firstTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		HomeHandbookItemMap = {
			NameSpace = "CustomTypes.HomeHandbookItemMap",
			__ValueType__ = "HomeHandbookItemInfo",
			__IntTypeKey__ = true,
			Properties = {
				homeHandbookScore = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				homeHandbookCategoryCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				homeHandbookSeasonCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		HomeLinkGroupInfo = {
			NameSpace = "CustomTypes.HomeLinkGroupInfo",
			Properties = {
				mainOrnaments = {
					"IntList",
					{},
					"AllClients",
					"PER"
				},
				subOrnaments = {
					"IntList",
					{},
					"AllClients",
					"PER"
				},
				totalCost = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				totalProduce = {
					"double",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomeLinkGroupMap = {
			NameSpace = "CustomTypes.HomeLinkGroupMap",
			__ValueType__ = "HomeLinkGroupInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomeLinkInfo = {
			NameSpace = "CustomTypes.HomeLinkInfo",
			Properties = {
				groupId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				linkIds = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		HomeLinkMap = {
			NameSpace = "CustomTypes.HomeLinkMap",
			__ValueType__ = "HomeLinkInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomeOrderInfo = {
			NameSpace = "CustomTypes.HomeOrderInfo",
			Properties = {
				orderId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				orderType = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				rewardRate = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				orderStatus = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				desId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				insId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				canRefresh = {
					"boolean",
					true,
					"OwnClient",
					"PER"
				},
				isPinned = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		HomeOrderList = {
			NameSpace = "CustomTypes.HomeOrderList",
			__ValueType__ = "HomeOrderInfo",
			__IntTypeKey__ = true
		},
		HomePetAllData = {
			NameSpace = "CustomTypes.HomePetAllData",
			__ValueType__ = "HomePetSingleData",
			__IntTypeKey__ = false,
			Properties = {}
		},
		HomePetBoxInfo = {
			NameSpace = "CustomTypes.HomePetBoxInfo",
			__ValueType__ = "string",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomePetBoxMap = {
			NameSpace = "CustomTypes.HomePetBoxMap",
			__ValueType__ = "HomePetBoxInfo",
			__IntTypeKey__ = true,
			Properties = {
				petPositionMap = {
					"StringIntMapMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		HomePetRestData = {
			NameSpace = "CustomTypes.HomePetRestData",
			__ValueType__ = "HomePetRestSingleData",
			__IntTypeKey__ = false,
			Properties = {}
		},
		HomePetRestSingleData = {
			NameSpace = "CustomTypes.HomePetRestSingleData",
			Properties = {
				pos = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomePetSingleData = {
			NameSpace = "CustomTypes.HomePetSingleData",
			Properties = {
				pos3 = {
					"IntList",
					{},
					"ServerOnly",
					"PER"
				},
				yawAngle = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				areaId = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomeVoucherProduceInfo = {
			NameSpace = "CustomTypes.HomeVoucherProduceInfo",
			Properties = {
				progress = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				lastSettleTs = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				collectorCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				active = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				},
				produceRate = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				collectLimit = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		HomelandAllocationInfo = {
			NameSpace = "CustomTypes.HomelandAllocationInfo",
			Properties = {
				ornamentId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				posIndex = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				opId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				startTs = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				workload = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				fitTalent = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				manual = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				},
				extraIntParam = {
					"int",
					0,
					"AllClients",
					"NPER"
				}
			}
		},
		HomelandAllocationMap = {
			NameSpace = "CustomTypes.HomelandAllocationMap",
			__ValueType__ = "HomelandAllocationInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		HomelandHatchInfo = {
			NameSpace = "CustomTypes.HomelandHatchInfo",
			Properties = {
				item = {
					"HatchItemSnapshot",
					{},
					"ServerOnly",
					"PER"
				},
				status = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				baseDuration = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				startTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				totalFixedReduction = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				totalTimeReductionRate = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				accumulatedProgress = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				lastRateChangeTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				currentEnvFactor = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				endTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				todayFondleByPlayerCount = {
					"StringIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				todayTotalFondleCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				itemSpeedUpCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				homeCarSpeedUpFactor = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				fixedReductionMap = {
					"IntDoubleMap",
					{},
					"ServerOnly",
					"PER"
				},
				timeReductionRateMap = {
					"IntDoubleMap",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		HomelandHatchMap = {
			NameSpace = "CustomTypes.HomelandHatchMap",
			__ValueType__ = "HomelandHatchInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomelandHighPriceStore = {
			NameSpace = "CustomTypes.HomelandHighPriceStore",
			__ValueType__ = "HomelandHighPriceStoreInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomelandHighPriceStoreInfo = {
			NameSpace = "CustomTypes.HomelandHighPriceStoreInfo",
			Properties = {
				materials = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				priceMultiple = {
					"double",
					0,
					"OwnClient",
					"PER"
				},
				highPriceCountToday = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		HomelandLeisureStateInfo = {
			NameSpace = "CustomTypes.HomelandLeisureStateInfo",
			Properties = {
				leisureId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				vehicleOrnamentId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				vehicleSeatIndex = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				startTs = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				revision = {
					"int",
					0,
					"AllClients",
					"NPER"
				}
			}
		},
		HomelandLeisureStateMap = {
			NameSpace = "CustomTypes.HomelandLeisureStateMap",
			__ValueType__ = "HomelandLeisureStateInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		HomelandOrderInfo = {
			NameSpace = "CustomTypes.HomelandOrderInfo",
			Properties = {
				updateTs = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				highPriceStore = {
					"HomelandHighPriceStore",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		HomelandProduceExtraStateInfo = {
			NameSpace = "CustomTypes.HomelandProduceExtraStateInfo",
			Properties = {
				value = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomelandProduceExtraStateMap = {
			NameSpace = "CustomTypes.HomelandProduceExtraStateMap",
			__ValueType__ = "HomelandProduceExtraStateInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomelandProduceFacilityInfo = {
			NameSpace = "CustomTypes.HomelandProduceFacilityInfo",
			Properties = {
				formulaId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				randomType = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				facilityState = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				facilityStateInfo = {
					"HomelandProduceFacilityStateInfo",
					{},
					"AllClients",
					"PER"
				},
				extraStateMap = {
					"HomelandProduceExtraStateMap",
					{},
					"AllClients",
					"PER"
				},
				timerStateMap = {
					"HomelandTimerStateMap",
					{},
					"AllClients",
					"PER"
				},
				timerStateMark = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				outputMap = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				specialOutputMap = {
					"HomelandSpecialOutputMap",
					{},
					"AllClients",
					"PER"
				},
				disable = {
					"boolean",
					false,
					"AllClients",
					"PER"
				},
				envParam = {
					"int",
					1,
					"AllClients",
					"PER"
				},
				envWorkRatio = {
					"double",
					1,
					"AllClients",
					"PER"
				},
				baseEnvWorkRatio = {
					"double",
					1,
					"AllClients",
					"PER"
				},
				tilled = {
					"boolean",
					false,
					"AllClients",
					"PER"
				},
				tillStateInfo = {
					"HomelandTillStateInfo",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		HomelandProduceFacilityMap = {
			NameSpace = "CustomTypes.HomelandProduceFacilityMap",
			__ValueType__ = "HomelandProduceFacilityInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomelandProduceFacilityStateInfo = {
			NameSpace = "CustomTypes.HomelandProduceFacilityStateInfo",
			Properties = {
				ptype = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				totalValue = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				curValue = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				startTs = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				ringBufferIdx = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		HomelandSpecialOutputInfo = {
			NameSpace = "CustomTypes.HomelandSpecialOutputInfo",
			Properties = {
				num = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				mode = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomelandSpecialOutputMap = {
			NameSpace = "CustomTypes.HomelandSpecialOutputMap",
			__ValueType__ = "HomelandSpecialOutputInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomelandSyncInfo = {
			NameSpace = "CustomTypes.HomelandSyncInfo",
			Properties = {
				visitors = {
					"StringList",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		HomelandTillStateInfo = {
			NameSpace = "CustomTypes.HomelandTillStateInfo",
			Properties = {
				curValue = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				totalValue = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomelandTimerStateInfo = {
			NameSpace = "CustomTypes.HomelandTimerStateInfo",
			Properties = {
				totalValue = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				curValue = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				stateCount = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		HomelandTimerStateMap = {
			NameSpace = "CustomTypes.HomelandTimerStateMap",
			__ValueType__ = "HomelandTimerStateInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		HomelandTransportData = {
			NameSpace = "CustomTypes.HomelandTransportData",
			__ValueType__ = "HomelandTransportInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		HomelandTransportInfo = {
			NameSpace = "CustomTypes.HomelandTransportInfo",
			Properties = {
				ornamentId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				itemInfo = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		IntIntList = {
			NameSpace = "CustomTypes.IntIntList",
			__ValueType__ = "IntList",
			__IntTypeKey__ = true
		},
		IntList = {
			NameSpace = "CustomTypes.IntList",
			__ValueType__ = "int",
			__IntTypeKey__ = true
		},
		IDIPRewardMailMap = {
			NameSpace = "CustomTypes.IDIPRewardMailMap",
			__ValueType__ = "StringList",
			__IntTypeKey__ = false,
			Properties = {}
		},
		InitialQuestData = {
			NameSpace = "CustomTypes.InitialQuestData",
			Properties = {
				configId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				state = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				claimCond = {
					"QuestObjectivesMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		InitialQuestDataMap = {
			NameSpace = "CustomTypes.InitialQuestDataMap",
			__ValueType__ = "InitialQuestData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntBoolListMap = {
			NameSpace = "CustomTypes.IntBoolListMap",
			__ValueType__ = "BoolList",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntBoolMap = {
			NameSpace = "CustomTypes.IntBoolMap",
			__ValueType__ = "boolean",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntDoubleListMap = {
			NameSpace = "CustomTypes.IntDoubleListMap",
			__ValueType__ = "DoubleList",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntDoubleMap = {
			NameSpace = "CustomTypes.IntDoubleMap",
			__ValueType__ = "double",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntIntBoolMap = {
			NameSpace = "CustomTypes.IntIntBoolMap",
			__ValueType__ = "IntBoolMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntIntDoubleMap = {
			NameSpace = "CustomTypes.IntIntDoubleMap",
			__ValueType__ = "IntDoubleMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntIntListMap = {
			NameSpace = "CustomTypes.IntIntListMap",
			__ValueType__ = "IntList",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntIntMap = {
			NameSpace = "CustomTypes.IntIntMap",
			__ValueType__ = "int",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntIntMapMap = {
			NameSpace = "CustomTypes.IntIntMapMap",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntStringBoolMap = {
			NameSpace = "CustomTypes.IntStringBoolMap",
			__ValueType__ = "StringBoolMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntStringMap = {
			NameSpace = "CustomTypes.IntStringMap",
			__ValueType__ = "string",
			__IntTypeKey__ = true,
			Properties = {}
		},
		IntStringMapMap = {
			NameSpace = "CustomTypes.IntStringMapMap",
			__ValueType__ = "StringIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		InteractAction = {
			NameSpace = "CustomTypes.InteractAction",
			Properties = {
				interactId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				end_ts = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				entityId = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				interrupt = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				},
				actionTimer = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		BallItem = {
			NameSpace = "CustomTypes.InventoryItem.BallItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				vaildStartTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				vaildEndTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		BallItemBag = {
			NameSpace = "CustomTypes.InventoryItem.BallItemBag",
			__ValueType__ = "BallItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				allowMultiPile = {
					"boolean",
					true,
					"OwnClient",
					"NPER"
				}
			}
		},
		CommonItem = {
			NameSpace = "CustomTypes.InventoryItem.CommonItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				objID = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				useTimes = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				extraProp = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				owner = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				vaildStartTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				vaildEndTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		CommonItemBag = {
			NameSpace = "CustomTypes.InventoryItem.CommonItemBag",
			__ValueType__ = "CommonItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				allowMultiPile = {
					"boolean",
					true,
					"OwnClient",
					"NPER"
				}
			}
		},
		FragmentItem = {
			NameSpace = "CustomTypes.InventoryItem.FragmentItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				objID = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				useTimes = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				extraProp = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				owner = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				vaildStartTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				vaildEndTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		FragmentItemBag = {
			NameSpace = "CustomTypes.InventoryItem.FragmentItemBag",
			__ValueType__ = "FragmentItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				allowMultiPile = {
					"boolean",
					true,
					"OwnClient",
					"NPER"
				}
			}
		},
		HomelandFurnitureItem = {
			NameSpace = "CustomTypes.InventoryItem.HomelandFurnitureItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				vaildStartTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				vaildEndTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		HomelandFurnitureItemBag = {
			NameSpace = "CustomTypes.InventoryItem.HomelandFurnitureItemBag",
			__ValueType__ = "HomelandFurnitureItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				allowMultiPile = {
					"boolean",
					true,
					"OwnClient",
					"NPER"
				}
			}
		},
		HomelandItem = {
			NameSpace = "CustomTypes.InventoryItem.HomelandItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				vaildStartTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				vaildEndTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		HomelandItemBag = {
			NameSpace = "CustomTypes.InventoryItem.HomelandItemBag",
			__ValueType__ = "HomelandItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				allowMultiPile = {
					"boolean",
					true,
					"OwnClient",
					"NPER"
				}
			}
		},
		PetItem = {
			NameSpace = "CustomTypes.InventoryItem.PetItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				vaildStartTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				vaildEndTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		PetItemBag = {
			NameSpace = "CustomTypes.InventoryItem.PetItemBag",
			__ValueType__ = "PetItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				allowMultiPile = {
					"boolean",
					true,
					"OwnClient",
					"NPER"
				}
			}
		},
		ItemDecomposeRecordList = {
			NameSpace = "CustomTypes.ItemDecomposeRecordList",
			__ValueType__ = "ItemDecomposeRecord",
			__IntTypeKey__ = true
		},
		ItemPos = {
			NameSpace = "CustomTypes.ItemPos",
			__ValueType__ = "int",
			__IntTypeKey__ = true
		},
		ItemPosList = {
			NameSpace = "CustomTypes.ItemPosList",
			__ValueType__ = "ItemPos",
			__IntTypeKey__ = true
		},
		PetJewelryItem = {
			NameSpace = "CustomTypes.InventoryItem.PetJewelryItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PetJewelryItemBag = {
			NameSpace = "CustomTypes.InventoryItem.PetJewelryItemBag",
			__ValueType__ = "PetJewelryItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		PlayerItem = {
			NameSpace = "CustomTypes.InventoryItem.PlayerItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				objID = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				useTimes = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				extraProp = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				vaildStartTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				vaildEndTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		PlayerItemBag = {
			NameSpace = "CustomTypes.InventoryItem.PlayerItemBag",
			__ValueType__ = "PlayerItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				allowMultiPile = {
					"boolean",
					true,
					"OwnClient",
					"NPER"
				}
			}
		},
		ReservedItem = {
			NameSpace = "CustomTypes.InventoryItem.ReservedItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				objID = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				useTimes = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				extraProp = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				owner = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				vaildStartTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				vaildEndTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		ReservedItemBag = {
			NameSpace = "CustomTypes.InventoryItem.ReservedItemBag",
			__ValueType__ = "ReservedItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				allowMultiPile = {
					"boolean",
					true,
					"OwnClient",
					"NPER"
				}
			}
		},
		RobEggItem = {
			NameSpace = "CustomTypes.InventoryItem.RobEggItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				objID = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				useTimes = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				extraProp = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				owner = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				vaildStartTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				vaildEndTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		RobEggItemBag = {
			NameSpace = "CustomTypes.InventoryItem.RobEggItemBag",
			__ValueType__ = "RobEggItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				allowMultiPile = {
					"boolean",
					true,
					"OwnClient",
					"NPER"
				}
			}
		},
		TaskItem = {
			NameSpace = "CustomTypes.InventoryItem.TaskItem",
			Properties = {
				genID = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				useTimes = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				vaildStartTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				vaildEndTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		TaskItemBag = {
			NameSpace = "CustomTypes.InventoryItem.TaskItemBag",
			__ValueType__ = "TaskItem",
			__IntTypeKey__ = true,
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				capacity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				overflowMode = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				allowMultiPile = {
					"boolean",
					true,
					"OwnClient",
					"NPER"
				}
			}
		},
		ItemCountBind = {
			NameSpace = "CustomTypes.ItemCountBind",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ItemCountBindMap = {
			NameSpace = "CustomTypes.ItemCountBindMap",
			__ValueType__ = "ItemCountBind",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ItemDecomposeRecord = {
			NameSpace = "CustomTypes.ItemDecomposeRecord",
			Properties = {
				operationId = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				decomposeTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				itemId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				itemCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				rewardItems = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		ItemProperties = {
			NameSpace = "CustomTypes.ItemProperties",
			__ValueType__ = "OriginMap",
			__IntTypeKey__ = false,
			Properties = {}
		},
		LearnAbilityMap = {
			NameSpace = "CustomTypes.LearnAbilityMap",
			__ValueType__ = "AbilityInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		LearnAbilityTypeMap = {
			NameSpace = "CustomTypes.LearnAbilityTypeMap",
			__ValueType__ = "LearnAbilityMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		LevelItemMap = {
			NameSpace = "CustomTypes.LevelItemMap",
			__ValueType__ = "StringIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		LeylineFlowerInfo = {
			NameSpace = "CustomTypes.LeylineFlowerInfo",
			Properties = {
				flowerState = {
					"int",
					1,
					"AllClients",
					"PER"
				},
				captureProgressCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				bloomType = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				stateStartTime = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				nourishCostItems = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				bloomCatchCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				bloomEnergyMultiplier = {
					"double",
					1,
					"ServerOnly",
					"PER"
				},
				rainbowEnergy = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				seasonRainbowEnergyMap = {
					"IntDoubleMap",
					{},
					"AllClients",
					"PER"
				},
				rainbowStage = {
					"int",
					1,
					"AllClients",
					"PER"
				},
				lastCatchPuppetId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				plentyTableId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				activityFixEvoRatio = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				bloomTriggerReason = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				bloomRainbowEnergyGain = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				bloomRainbowPetId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				bloomShinyPetMap = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				pendingCaptureBloomCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				pendingCaptureBloomLastPuppetId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				bloomQuality = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		LeylineFlowerInfoMap = {
			NameSpace = "CustomTypes.LeylineFlowerInfoMap",
			__ValueType__ = "LeylineFlowerInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		LeylinePuppetSaveInfo = {
			NameSpace = "CustomTypes.LeylinePuppetSaveInfo",
			Properties = {
				leylineMarkId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				puppetSaveInfoList = {
					"PuppetSaveInfoList",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		LeylinePuppetSaveMap = {
			NameSpace = "CustomTypes.LeylinePuppetSaveMap",
			__ValueType__ = "LeylinePuppetSaveInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		LeylineTreeInfo = {
			NameSpace = "CustomTypes.LeylineTreeInfo",
			Properties = {
				leylineTreeLevel = {
					"int",
					-1,
					"OwnClient",
					"PER"
				},
				leylineTreePoint = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				activePointList = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				activePointStatus = {
					"IntBoolMap",
					{},
					"ServerOnly",
					"PER"
				},
				activePointUseCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				changeMeteorologyCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				changeMeteorologyCD = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				levelRewardStatus = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				pendPoi = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				pendMeteo = {
					"TreeMeteoInfoMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		LeylineTreeInfoMap = {
			NameSpace = "CustomTypes.LeylineTreeInfoMap",
			__ValueType__ = "LeylineTreeInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		LootBoxItem = {
			NameSpace = "CustomTypes.LootBoxItem",
			Properties = {
				id = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				itemid = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				count = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				tag = {
					"LootBoxItemTag",
					{},
					"AllClients",
					"NPER"
				},
				discoverys = {
					"StringIntMap",
					{},
					"AllClients",
					"NPER"
				},
				props = {
					"ItemProperties",
					{},
					"AllClients",
					"NPER"
				},
				entityId = {
					"string",
					"",
					"AllClients",
					"NPER"
				}
			}
		},
		LootBoxItemTag = {
			NameSpace = "CustomTypes.LootBoxItemTag",
			Properties = {
				ownerUid = {
					"string",
					"",
					"AllClients",
					"NPER"
				}
			}
		},
		MapMarkStatusInfo = {
			NameSpace = "CustomTypes.MapMarkStatusInfo",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		MapMarkStatusMap = {
			NameSpace = "CustomTypes.MapMarkStatusMap",
			__ValueType__ = "MapMarkStatusInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		NpcDuelBotPetList = {
			NameSpace = "CustomTypes.NpcDuelBotPetList",
			__ValueType__ = "NpcDuelBotPetInfo",
			__IntTypeKey__ = true
		},
		MediaMarkerData = {
			NameSpace = "CustomTypes.MediaMarkerData",
			Properties = {
				createTs = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				posIndex = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				pos = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				sceneId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				encourageDays = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				isPermanent = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				setting = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		MediaMarkerMap = {
			NameSpace = "CustomTypes.MediaMarkerMap",
			__ValueType__ = "MediaMarkerData",
			__IntTypeKey__ = false,
			Properties = {}
		},
		MediaMarkerOpData = {
			NameSpace = "CustomTypes.MediaMarkerOpData",
			__ValueType__ = "StringList",
			__IntTypeKey__ = false,
			Properties = {}
		},
		MeteorologyInfo = {
			NameSpace = "CustomTypes.MeteorologyInfo",
			Properties = {
				startTime = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				endTime = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				meteorologyId = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		MeteorologyInfoMap = {
			NameSpace = "CustomTypes.MeteorologyInfoMap",
			__ValueType__ = "MeteorologyInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		MiniGamePlayerInfo = {
			NameSpace = "CustomTypes.MiniGamePlayerInfo",
			Properties = {
				isAI = {
					"boolean",
					true,
					"AllClients",
					"NPER"
				},
				rewardId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				handWrestlingScore = {
					"double",
					0,
					"AllClients",
					"NPER"
				}
			}
		},
		MiniGamePlayerMap = {
			NameSpace = "CustomTypes.MiniGamePlayerMap",
			__ValueType__ = "MiniGamePlayerInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		MmoItemCdMap = {
			NameSpace = "CustomTypes.MmoItemCdMap",
			__ValueType__ = "int",
			__IntTypeKey__ = true,
			Properties = {}
		},
		MmoItemCoolDownMap = {
			NameSpace = "CustomTypes.MmoItemCoolDownMap",
			__ValueType__ = "MmoItemCdMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		MultiInteractAction = {
			NameSpace = "CustomTypes.MultiInteractAction",
			Properties = {
				actionId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				start_ts = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				creatorId = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				memberIds = {
					"StringList",
					{},
					"AllClients",
					"NPER"
				},
				petPrototypeId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				actionTimer = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		NpcDuelBasicInfo = {
			NameSpace = "CustomTypes.NpcDuelBasicInfo",
			Properties = {
				variantIdMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				variantPassCountMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				variantTryCountMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				npcDuelPassAllMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		NpcDuelBotInfo = {
			NameSpace = "CustomTypes.NpcDuelBotInfo",
			Properties = {
				npcBotId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				avatarId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				petList = {
					"NpcDuelBotPetList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		NpcDuelBotPetInfo = {
			NameSpace = "CustomTypes.NpcDuelBotPetInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				level = {
					"int",
					1,
					"OwnClient",
					"PER"
				},
				label = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				botTemplateId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				cp = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		NpcDuelShowedPetList = {
			NameSpace = "CustomTypes.NpcDuelShowedPetList",
			__ValueType__ = "IntIntListMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		OSSPhotoRecordMap = {
			NameSpace = "CustomTypes.OSSPhotoRecordMap",
			__ValueType__ = "PhotoRecordInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		OriginMap = {
			NameSpace = "CustomTypes.OriginMap",
			__ValueType__ = "string",
			__IntTypeKey__ = false,
			Properties = {}
		},
		OrnamentAllData = {
			NameSpace = "CustomTypes.OrnamentAllData",
			__ValueType__ = "OrnamentSingleData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		OrnamentBuildAttachData = {
			NameSpace = "CustomTypes.OrnamentBuildAttachData",
			__ValueType__ = "OrnamentBuildAttachSingleData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		OrnamentBuildAttachSingleData = {
			NameSpace = "CustomTypes.OrnamentBuildAttachSingleData",
			Properties = {
				parentId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				slotId = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		OrnamentBuildExtraData = {
			NameSpace = "CustomTypes.OrnamentBuildExtraData",
			Properties = {
				attachData = {
					"OrnamentBuildAttachData",
					{},
					"AllClients",
					"PER"
				},
				linkData = {
					"OrnamentBuildLinkData",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		OrnamentBuildLinkData = {
			NameSpace = "CustomTypes.OrnamentBuildLinkData",
			__ValueType__ = "OrnamentBuildLinkSingleData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		OrnamentBuildLinkSingleData = {
			NameSpace = "CustomTypes.OrnamentBuildLinkSingleData",
			__ValueType__ = "int",
			__IntTypeKey__ = true,
			Properties = {}
		},
		OrnamentEnvInfo = {
			NameSpace = "CustomTypes.OrnamentEnvInfo",
			Properties = {
				refEnvFacilityInfo = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				electricCost = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				light = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				temperature = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		OrnamentEnvMap = {
			NameSpace = "CustomTypes.OrnamentEnvMap",
			__ValueType__ = "OrnamentEnvInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		OrnamentSingleData = {
			NameSpace = "CustomTypes.OrnamentSingleData",
			Properties = {
				homeId = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				posX = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				posY = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				posZ = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				rotX = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				rotY = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				rotZ = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				scaleX = {
					"int",
					1000,
					"ServerOnly",
					"NPER"
				},
				scaleY = {
					"int",
					1000,
					"ServerOnly",
					"NPER"
				},
				scaleZ = {
					"int",
					1000,
					"ServerOnly",
					"NPER"
				},
				trashId = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				electricMode = {
					"boolean",
					false,
					"ServerOnly",
					"NPER"
				},
				areaId = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		OrnamentTrashAllData = {
			NameSpace = "CustomTypes.OrnamentTrashAllData",
			__ValueType__ = "OrnamentTrashSingleData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		OrnamentTrashSingleData = {
			NameSpace = "CustomTypes.OrnamentTrashSingleData",
			Properties = {
				ornamentId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				trashState = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		PartnerInfoList = {
			NameSpace = "CustomTypes.PartnerInfoList",
			__ValueType__ = "PartnerInfo",
			__IntTypeKey__ = true
		},
		PetBallExpActionList = {
			NameSpace = "CustomTypes.PetBallExpActionList",
			__ValueType__ = "PetBallExpActionInfo",
			__IntTypeKey__ = true
		},
		PVPPetTeamInfo = {
			NameSpace = "CustomTypes.PVPPetTeamInfo",
			__ValueType__ = "PVPPetTeamMemberInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PVPPetTeamMemberInfo = {
			NameSpace = "CustomTypes.PVPPetTeamMemberInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				characterId = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PartnerInfo = {
			NameSpace = "CustomTypes.PartnerInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				curHp = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				maxHp = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				isAlive = {
					"boolean",
					true,
					"AllClients",
					"NPER"
				},
				shieldPoint = {
					"double",
					0,
					"AllClients",
					"NPER"
				}
			}
		},
		PasserByInfo = {
			NameSpace = "CustomTypes.PasserByInfo",
			Properties = {
				displayInfo = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				enterTime = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				leaveTime = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				exitMode = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				result = {
					"IntList",
					{},
					"AllClients",
					"NPER"
				},
				isRewarded = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				},
				totalDamage = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				totalHeal = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				petCombatMap = {
					"PetCombatMap",
					{},
					"AllClients",
					"NPER"
				},
				petPrepareList = {
					"PetIdList",
					{},
					"AllClients",
					"NPER"
				}
			}
		},
		PasserByMap = {
			NameSpace = "CustomTypes.PasserByMap",
			__ValueType__ = "PasserByInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PayCountData = {
			NameSpace = "CustomTypes.PayCountData",
			Properties = {
				buys = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				lastTs = {
					"double",
					0,
					"OwnClient",
					"PER"
				},
				monthCardBegTs = {
					"double",
					0,
					"OwnClient",
					"PER"
				},
				monthCardExpireTs = {
					"double",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PayCountMap = {
			NameSpace = "CustomTypes.PayCountMap",
			__ValueType__ = "PayCountData",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PersistEntityInfo = {
			NameSpace = "CustomTypes.PersistEntityInfo",
			Properties = {
				position = {
					"DoubleList",
					{},
					"ServerOnly",
					"PER"
				},
				rotation = {
					"DoubleList",
					{},
					"ServerOnly",
					"PER"
				},
				survivalTime = {
					"double",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		PersistEntityInfoMap = {
			NameSpace = "CustomTypes.PersistEntityInfoMap",
			__ValueType__ = "PersistEntityInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetBallActionInfo = {
			NameSpace = "CustomTypes.PetBallActionInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				itemId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				finishCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				lastCalcTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				posIndex = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PetBallActionMap = {
			NameSpace = "CustomTypes.PetBallActionMap",
			__ValueType__ = "PetBallActionInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetBallExpActionInfo = {
			NameSpace = "CustomTypes.PetBallExpActionInfo",
			Properties = {
				itemId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				itemCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				finishCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PetBallInfo = {
			NameSpace = "CustomTypes.PetBallInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				createTime = {
					"double",
					0,
					"OwnClient",
					"PER"
				},
				customName = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				petId = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				subPetId = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				actions = {
					"PetBallActionMap",
					{},
					"OwnClient",
					"PER"
				},
				productions = {
					"PetBallProductionMap",
					{},
					"OwnClient",
					"PER"
				},
				expActionList = {
					"PetBallExpActionList",
					{},
					"OwnClient",
					"PER"
				},
				expActionStatus = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				expNextRefreshTs = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PetBallMap = {
			NameSpace = "CustomTypes.PetBallMap",
			__ValueType__ = "PetBallInfo",
			__IntTypeKey__ = false,
			Properties = {
				slotCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				curIndex = {
					"string",
					"",
					"OwnClient",
					"PER"
				}
			}
		},
		PetBallProductionInfo = {
			NameSpace = "CustomTypes.PetBallProductionInfo",
			Properties = {
				targetId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				value = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PetBallProductionMap = {
			NameSpace = "CustomTypes.PetBallProductionMap",
			__ValueType__ = "PetBallProductionInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetBehaviorLearnMap = {
			NameSpace = "CustomTypes.PetBehaviorLearnMap",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetBoxInfo = {
			NameSpace = "CustomTypes.PetBoxInfo",
			__ValueType__ = "string",
			__IntTypeKey__ = true,
			Properties = {
				locked = {
					"boolean",
					false,
					"AllClients",
					"PER"
				},
				slotCount = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				count = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				customName = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				tempStatus = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				isNew = {
					"boolean",
					false,
					"AllClients",
					"PER"
				}
			}
		},
		PetBoxMap = {
			NameSpace = "CustomTypes.PetBoxMap",
			__ValueType__ = "PetBoxInfo",
			__IntTypeKey__ = true,
			Properties = {
				sequence = {
					"IntList",
					{},
					"AllClients",
					"PER"
				},
				curIndex = {
					"int",
					1,
					"AllClients",
					"PER"
				},
				curIndexGenId = {
					"int",
					1,
					"AllClients",
					"PER"
				},
				tempBoxCount = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				curSortType = {
					"int",
					-1,
					"OwnClient",
					"PER"
				},
				curOrderType = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PetCarryRecommendInfo = {
			NameSpace = "CustomTypes.PetCarryRecommendInfo",
			Properties = {
				appliedType = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				appliedItemIds = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				appliedItemGenIds = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PetCarryRecommendInfoMap = {
			NameSpace = "CustomTypes.PetCarryRecommendInfoMap",
			__ValueType__ = "PetCarryRecommendInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PetCombatInfo = {
			NameSpace = "CustomTypes.PetCombatInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				isDead = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				}
			}
		},
		PetCombatMap = {
			NameSpace = "CustomTypes.PetCombatMap",
			__ValueType__ = "PetCombatInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PetCountryInfo = {
			NameSpace = "CustomTypes.PetCountryInfo",
			Properties = {
				totalLevelStar = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				totalLevelRewardStatus = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				collectLevel = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				collectLevelRewardStatus = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				speciesCollectLevel = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				speciesCollectLevelRewardStatus = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				researchReportMap = {
					"ResearchReportMap",
					{},
					"OwnClient",
					"PER"
				},
				stateMaskCountMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"NPER"
				},
				stateMaskFormCountMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"NPER"
				},
				stateMaskSpeciesCountMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"NPER"
				},
				unlocked = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		PetCountryMap = {
			NameSpace = "CustomTypes.PetCountryMap",
			__ValueType__ = "PetCountryInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetCpIndex = {
			NameSpace = "CustomTypes.PetCpIndex",
			Properties = {
				cpMap = {
					"StringIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				cpCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				top4Map = {
					"StringIntMap",
					{},
					"ServerOnly",
					"NPER"
				},
				top4Count = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		PetFeatureUnlockMap = {
			NameSpace = "CustomTypes.PetFeatureUnlockMap",
			__ValueType__ = "IntBoolMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetHandbookCompactState = {
			NameSpace = "CustomTypes.PetHandbookCompactState",
			Properties = {
				targetState = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				researchState = {
					"IntIntMapMap",
					{},
					"ServerOnly",
					"PER"
				},
				traitState = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				evolveState = {
					"PetHandbookEvolveCompactState",
					{},
					"ServerOnly",
					"PER"
				},
				levelRewardState = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		PetIdList = {
			NameSpace = "CustomTypes.PetIdList",
			__ValueType__ = "string",
			__IntTypeKey__ = true
		},
		PetRecordList = {
			NameSpace = "CustomTypes.PetRecordList",
			__ValueType__ = "PetRecordInfo",
			__IntTypeKey__ = true
		},
		PetReleaseRecordList = {
			NameSpace = "CustomTypes.PetReleaseRecordList",
			__ValueType__ = "PetReleaseRecord",
			__IntTypeKey__ = true
		},
		PetSimpleList = {
			NameSpace = "CustomTypes.PetSimpleList",
			__ValueType__ = "PetSimplelInfo",
			__IntTypeKey__ = true
		},
		PetHandbookEvolveCompactState = {
			NameSpace = "CustomTypes.PetHandbookEvolveCompactState",
			Properties = {
				routeState = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				normalState = {
					"IntIntMapMap",
					{},
					"ServerOnly",
					"PER"
				},
				itemState = {
					"IntIntMapMap",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		PetHandbookInfo = {
			NameSpace = "CustomTypes.PetHandbookInfo",
			Properties = {
				completedTargetMap = {
					"CompletedTargetMap",
					{},
					"OwnClient",
					"NPER"
				},
				rewardedTargetMap = {
					"RewardedTargetMap",
					{},
					"OwnClient",
					"NPER"
				},
				stateMask = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				level = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				exp = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				petMaxLevel = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				shinyCollectMask = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				levelRewardStatus = {
					"IntIntMap",
					{},
					"OwnClient",
					"NPER"
				},
				researchPointMap = {
					"ResearchPointMap",
					{},
					"OwnClient",
					"PER"
				},
				avatarNoneResearch = {
					"PetResearchMap",
					{},
					"OwnClient",
					"NPER"
				},
				avatarMaleResearch = {
					"PetResearchMap",
					{},
					"OwnClient",
					"NPER"
				},
				avatarFemaleResearch = {
					"PetResearchMap",
					{},
					"OwnClient",
					"NPER"
				},
				battleResearch = {
					"PetResearchMap",
					{},
					"OwnClient",
					"NPER"
				},
				traitResearchMap = {
					"TraitResearchMap",
					{},
					"OwnClient",
					"NPER"
				},
				evolveResearchMap = {
					"EvolveResearchMap",
					{},
					"OwnClient",
					"NPER"
				},
				bodyEntryResearch = {
					"PetResearchMap",
					{},
					"OwnClient",
					"NPER"
				},
				compactState = {
					"PetHandbookCompactState",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		PetHandbookMap = {
			NameSpace = "CustomTypes.PetHandbookMap",
			__ValueType__ = "PetHandbookInfo",
			__IntTypeKey__ = true,
			Properties = {
				petCountryMap = {
					"PetCountryMap",
					{},
					"OwnClient",
					"PER"
				},
				cachedTraitUnlockdCountMap = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"NPER"
				},
				cachedCountryTotalExpMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"NPER"
				},
				cachedCountryCollectNumMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"NPER"
				},
				cachedCountrySpeciesCollectNumMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"NPER"
				}
			}
		},
		PetIdListMap = {
			NameSpace = "CustomTypes.PetIdListMap",
			__ValueType__ = "PetIdList",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetInfo = {
			NameSpace = "CustomTypes.PetInfo",
			Properties = {
				id = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				uuid = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				templateId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				petPrototypeId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				basePetPrototypeId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				time = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				countId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				cubeItemId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				firstCreate = {
					"boolean",
					true,
					"ServerOnly",
					"PER"
				},
				customName = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				isVariantInteractPet = {
					"boolean",
					false,
					"AllClients",
					"PER"
				},
				stage = {
					"int",
					1,
					"AllClients",
					"PER"
				},
				exp = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				level = {
					"int",
					1,
					"AllClients",
					"PER"
				},
				expFromItem = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				levelOnCreate = {
					"int",
					1,
					"AllClients",
					"PER"
				},
				needBreakthrough = {
					"boolean",
					false,
					"AllClients",
					"PER"
				},
				hpRatio = {
					"double",
					1,
					"AllClients",
					"PER"
				},
				gender = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				nature = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				label = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				bodySizeType = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				shinyStyle = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				shinyEffectReplace = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				bornScale = {
					"double",
					1,
					"AllClients",
					"PER"
				},
				height = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				weight = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				favoriteType = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				isTwinChoice = {
					"boolean",
					false,
					"AllClients",
					"PER"
				},
				isTrial = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				},
				fetter = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				tmpTemplateId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				individuationIds = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				curAbilityMap = {
					"LearnAbilityMap",
					{},
					"OwnClient",
					"PER"
				},
				unlockedAbilityMap = {
					"PetUnlockedAbilityMap",
					{},
					"OwnClient",
					"PER"
				},
				basePropertyList = {
					"BasePropertyList",
					{},
					"OwnClient",
					"PER"
				},
				propertyEnhancedCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				propertyCountByEvent = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				propertyScoreStage = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				exploreAbilityList = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				characterInfo = {
					"CharacterInfo",
					{},
					"OwnClient",
					"PER"
				},
				talentList = {
					"TalentList",
					{},
					"OwnClient",
					"PER"
				},
				triggerMap = {
					"PetTriggerMap",
					{},
					"OwnClient",
					"PER"
				},
				eventMap = {
					"EventMap",
					{},
					"OwnClient",
					"PER"
				},
				curAbilityPreset = {
					"int",
					1,
					"OwnClient",
					"PER"
				},
				exploreRevivePer = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				socialTxnLockId = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				socialTxnLockType = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				resonanceInfo = {
					"ResonanceInfo",
					{},
					"OwnClient",
					"PER"
				},
				botTemplateId = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				isSealed = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		PetJewelryCustom = {
			NameSpace = "CustomTypes.PetJewelryCustom",
			__ValueType__ = "PetJewelryCustomOne",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetJewelryCustomOne = {
			NameSpace = "CustomTypes.PetJewelryCustomOne",
			__ValueType__ = "PetJewelryInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetJewelryInfo = {
			NameSpace = "CustomTypes.PetJewelryInfo",
			__ValueType__ = "AppearanceJewelryInfo",
			__IntTypeKey__ = true,
			Properties = {
				customShow = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				customPet = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				customPresets = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				customName = {
					"string",
					"",
					"OwnClient",
					"PER"
				}
			}
		},
		PetJewelryInfos = {
			NameSpace = "CustomTypes.PetJewelryInfos",
			__ValueType__ = "PetJewelryInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PetJewelryRecord = {
			NameSpace = "CustomTypes.PetJewelryRecord",
			Properties = {
				petId = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				point = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PetJewelryRecords = {
			NameSpace = "CustomTypes.PetJewelryRecords",
			__ValueType__ = "PetJewelryRecord",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetMap = {
			NameSpace = "CustomTypes.PetMap",
			__ValueType__ = "PetInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PetPropResetPaybackMap = {
			NameSpace = "CustomTypes.PetPropResetPaybackMap",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PetPrototypeIdIndex = {
			NameSpace = "CustomTypes.PetPrototypeIdIndex",
			Properties = {
				index = {
					"IntStringBoolMap",
					{},
					"ServerOnly",
					"PER"
				},
				count = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		PetRecordInfo = {
			NameSpace = "CustomTypes.PetRecordInfo",
			Properties = {
				recordTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PetReleaseRecord = {
			NameSpace = "CustomTypes.PetReleaseRecord",
			Properties = {
				originalPetUuid = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				originalPetId = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				releaseTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				templateId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				level = {
					"int",
					1,
					"ServerOnly",
					"PER"
				},
				propertyScoreStage = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				cp = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				basePropertySnapshot = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				petSnapshotData = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				paybackItems = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		PetResearchInfo = {
			NameSpace = "CustomTypes.PetResearchInfo",
			Properties = {
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				isNew = {
					"boolean",
					true,
					"OwnClient",
					"PER"
				}
			}
		},
		PetResearchMap = {
			NameSpace = "CustomTypes.PetResearchMap",
			__ValueType__ = "PetResearchInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetResearchUnlockedMap = {
			NameSpace = "CustomTypes.PetResearchUnlockedMap",
			__ValueType__ = "IntIntMapMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		EvolveResearchInfo = {
			NameSpace = "CustomTypes.PetResearch.EvolveResearchInfo",
			Properties = {
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				normalConditionStatus = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				itemConditionStatus = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		EvolveResearchMap = {
			NameSpace = "CustomTypes.PetResearch.EvolveResearchMap",
			__ValueType__ = "EvolveResearchInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		TraitResearchInfo = {
			NameSpace = "CustomTypes.PetResearch.TraitResearchInfo",
			Properties = {
				status = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				isRewarded = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		TraitResearchMap = {
			NameSpace = "CustomTypes.PetResearch.TraitResearchMap",
			__ValueType__ = "TraitResearchInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetSelectTransmogSchemeMap = {
			NameSpace = "CustomTypes.PetSelectTransmogSchemeMap",
			__ValueType__ = "PetTransmogScheme",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PetShinyStyleHistoryMap = {
			NameSpace = "CustomTypes.PetShinyStyleHistoryMap",
			__ValueType__ = "IntBoolMap",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PetSimpleListMap = {
			NameSpace = "CustomTypes.PetSimpleListMap",
			__ValueType__ = "PetSimpleList",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetSimpleMap = {
			NameSpace = "CustomTypes.PetSimpleMap",
			__ValueType__ = "PetSimplelInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetSimplelInfo = {
			NameSpace = "CustomTypes.PetSimplelInfo",
			Properties = {
				entityId = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				cp = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				templateId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				level = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				label = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				petAppearance = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				name = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				accompanyTime = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				putInHomeTime = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				killPuppetsAct = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				coreAbilityId = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				selectTransmogScheme = {
					"PetTransmogScheme",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		PetSkillUpgradeEntry = {
			NameSpace = "CustomTypes.PetSkillUpgradeEntry",
			Properties = {
				skillId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				done = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		PetSkillUpgradeEntryMap = {
			NameSpace = "CustomTypes.PetSkillUpgradeEntryMap",
			__ValueType__ = "PetSkillUpgradeEntry",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetSkillUpgradeMap = {
			NameSpace = "CustomTypes.PetSkillUpgradeMap",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PetStatsInfo = {
			NameSpace = "CustomTypes.PetStatsInfo",
			Properties = {
				genderCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				raceCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				templateOwned = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				characterCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				scoreLabelCount = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"PER"
				},
				collectOnlyPetCount = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"PER"
				},
				starHist = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"PER"
				},
				skillNumHist = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"PER"
				},
				levelHist = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"PER"
				},
				tmplLevelHist = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"PER"
				},
				talentRarityCount = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"PER"
				},
				individualLevelCount = {
					"IntStringMapMap",
					{},
					"OwnClient",
					"PER"
				},
				skillUpgradeIndividualSkillCount = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"PER"
				},
				coreCarryCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				coreCarryQualityCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				petCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PetTradeDataMap = {
			NameSpace = "CustomTypes.PetTradeDataMap",
			__ValueType__ = "OriginMap",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PetTransmogInfo = {
			NameSpace = "CustomTypes.PetTransmogInfo",
			Properties = {
				transmogUnlockSolts = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				transmogProgress = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				currTransmogScheme = {
					"PetTransmogScheme",
					{},
					"OwnClient",
					"PER"
				},
				selectTransmogScheme = {
					"PetTransmogScheme",
					{},
					"AllClients",
					"PER"
				},
				tempTransmogSchemes = {
					"PetTransmogSchemeMap",
					{},
					"OwnClient",
					"PER"
				},
				customTransmogSchemes = {
					"PetTransmogSchemeMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PetTransmogInfoMap = {
			NameSpace = "CustomTypes.PetTransmogInfoMap",
			__ValueType__ = "PetTransmogInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		PetTransmogScheme = {
			NameSpace = "CustomTypes.PetTransmogScheme",
			Properties = {
				index = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				id = {
					"string",
					"",
					"AllClients",
					"PER"
				},
				createTime = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				holeIds = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				transmogValue = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				transmogGoldenCount = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				holeGoldList = {
					"IntIntMapMap",
					{},
					"ServerOnly",
					"PER"
				},
				lockHolesList = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				useSpecialItemFlag = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		PetTransmogSchemeMap = {
			NameSpace = "CustomTypes.PetTransmogSchemeMap",
			__ValueType__ = "PetTransmogScheme",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PetTriggerMap = {
			NameSpace = "CustomTypes.PetTriggerMap",
			Properties = {
				customCondition = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				completeCustomSet = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PetUnlockedAbilityInfo = {
			NameSpace = "CustomTypes.PetUnlockedAbilityInfo",
			Properties = {
				abilityLv = {
					"int",
					1,
					"OwnClient",
					"NPER"
				},
				cdDuration = {
					"double",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PetUnlockedAbilityMap = {
			NameSpace = "CustomTypes.PetUnlockedAbilityMap",
			__ValueType__ = "PetUnlockedAbilityInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PhotoPresetInfo = {
			NameSpace = "CustomTypes.PhotoPresetInfo",
			Properties = {
				savedIdMap = {
					"StringIntMap",
					{},
					"OwnClient",
					"PER"
				},
				likedIdMap = {
					"StringIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PhotoRecordInfo = {
			NameSpace = "CustomTypes.PhotoRecordInfo",
			Properties = {
				photoId = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				uploadTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				uploadScene = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				uploadPos = {
					"Position",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PhotoRecordMap = {
			NameSpace = "CustomTypes.PhotoRecordMap",
			__ValueType__ = "PhotoRecordInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PhotoStudioMap = {
			NameSpace = "CustomTypes.PhotoStudioMap",
			__ValueType__ = "StringList",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PhysicsInfo = {
			NameSpace = "CustomTypes.PhysicsInfo",
			Properties = {
				rigidBodyState = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		PlayerActivityBase = {
			NameSpace = "CustomTypes.PlayerActivityBase",
			Properties = {
				activeType = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				activityId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				activityPhase = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				activityTasks = {
					"ActivityTaskInfoMap",
					{},
					"OwnClient",
					"PER"
				},
				lastTriggerLoginTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				pendingTriggerLoginTimer = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				totalSignNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				activateTm = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityBattlePass = {
			NameSpace = "CustomTypes.PlayerActivityBattlePass",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				bpGear = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				bpExp = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				bpLevel = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				weeklyNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				buyedMaxBpGear = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				activeMaxBpGear = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				backedItem = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				openGearType = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				bpAddAttriEntys = {
					"IntStringMap",
					{},
					"ServerOnly",
					"PER"
				},
				addBpExpTotalWeekly = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				unlockCycleReward = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				cycleRewardShowMaxlv = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				receiveNromalRewardNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				cycleRewardRecvMaxLvFree = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				cycleRewardRecvMaxLvAdvance = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityBindAccount = {
			NameSpace = "CustomTypes.PlayerActivityBindAccount",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"ServerOnly",
					"PER"
				},
				receivedBindAwardMap = {
					"IntBoolMap",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		PlayerActivityCrossPlatform = {
			NameSpace = "CustomTypes.PlayerActivityCrossPlatform",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityDailyActive = {
			NameSpace = "CustomTypes.PlayerActivityDailyActive",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				leastRefrshTime = {
					"double",
					0,
					"OwnClient",
					"PER"
				},
				dailyActiveScore = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityEcoTrace = {
			NameSpace = "CustomTypes.PlayerActivityEcoTrace",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				ecoTraceUpdateTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				ecoTracePetId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				ecoTraceSearchCnt = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				ecoTraceSearchCostCnt = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				ecoTraceSearchMarkId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				ecoTraceSearchPetRecycleTm = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				ecoTraceSearchProjStage = {
					"int",
					1,
					"OwnClient",
					"PER"
				},
				ecoTraceSearchProjCompTaskNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				ecoTraceSearchStageRecord = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				ecoTraceSearchTaskNumRecord = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityFirstCharge = {
			NameSpace = "CustomTypes.PlayerActivityFirstCharge",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityFishingCapture = {
			NameSpace = "CustomTypes.PlayerActivityFishingCapture",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				rewardStatistics = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				irisRewardReceived = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				cubeExchangeCountMap = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				curPhase = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				totalIrisNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityGrowthGift = {
			NameSpace = "CustomTypes.PlayerActivityGrowthGift",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				selectedPetId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				receivedPetFlag = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				collectSocre = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				recvCollectAllWards = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				collectUnlockPetIds = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityGuidePreheat = {
			NameSpace = "CustomTypes.PlayerActivityGuidePreheat",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				preheated = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				activityIdWhenPreheat = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				sendedNoticeMailActId = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityJourneyTrial = {
			NameSpace = "CustomTypes.PlayerActivityJourneyTrial",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				testid = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PrepareFormationList = {
			NameSpace = "CustomTypes.PrepareFormationList",
			__ValueType__ = "FormationInfo",
			__IntTypeKey__ = true
		},
		PuppetSaveInfoList = {
			NameSpace = "CustomTypes.PuppetSaveInfoList",
			__ValueType__ = "PuppetSaveInfo",
			__IntTypeKey__ = true
		},
		PlayerActivityLeylineTreeUp = {
			NameSpace = "CustomTypes.PlayerActivityLeylineTreeUp",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				upTimesDaily = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				upTimesDailys = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityLittleFirePerson = {
			NameSpace = "CustomTypes.PlayerActivityLittleFirePerson",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				notesPerson = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				notesGlobal = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				noteGetTimesDailyBySpark = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				litFireManInteractDailyTimes = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityLongTermSign = {
			NameSpace = "CustomTypes.PlayerActivityLongTermSign",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityPetDispatch = {
			NameSpace = "CustomTypes.PlayerActivityPetDispatch",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				goldAdveRewarded = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				noramlAdveRewardNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				rewardAllRecvedTm = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				clueUnlockTms = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityPetHatch = {
			NameSpace = "CustomTypes.PlayerActivityPetHatch",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				totalAccelHatchTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityPreheatsMap = {
			NameSpace = "CustomTypes.PlayerActivityPreheatsMap",
			__ValueType__ = "PlayerActivityGuidePreheat",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PlayerActivityRechargeRebate = {
			NameSpace = "CustomTypes.PlayerActivityRechargeRebate",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				rechargeSum = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivityRedNote = {
			NameSpace = "CustomTypes.PlayerActivityRedNote",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivitySeasonAchieve = {
			NameSpace = "CustomTypes.PlayerActivitySeasonAchieve",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				seasonAchivePoints = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivitySignNewbie = {
			NameSpace = "CustomTypes.PlayerActivitySignNewbie",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				activityBegTime = {
					"double",
					0,
					"OwnClient",
					"PER"
				},
				activityEndTime = {
					"double",
					0,
					"OwnClient",
					"PER"
				},
				leastSignTime = {
					"double",
					0,
					"OwnClient",
					"PER"
				},
				totalSignNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				continueTotalSignNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				opened = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerActivitySignVersion = {
			NameSpace = "CustomTypes.PlayerActivitySignVersion",
			Properties = {
				activityBase = {
					"PlayerActivityBase",
					{},
					"OwnClient",
					"PER"
				},
				activityBegTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				leastSignTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				totalSignNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				continueTotalSignNum = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerBossRushCycleData = {
			NameSpace = "CustomTypes.PlayerBossRushCycleData",
			Properties = {
				cycleId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				bossGrade = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				bossScore = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				bossBestGrade = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				bossBestScore = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerBossRushSeasonData = {
			NameSpace = "CustomTypes.PlayerBossRushSeasonData",
			__ValueType__ = "PlayerBossRushCycleData",
			__IntTypeKey__ = true,
			Properties = {
				seasonId = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PlayerLootBag = {
			NameSpace = "CustomTypes.PlayerLootBag",
			__ValueType__ = "RobEggLootItemMap",
			__IntTypeKey__ = false,
			Properties = {}
		},
		Position = {
			NameSpace = "CustomTypes.Position",
			__ValueType__ = "double",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PuppetCaptureSaveInfo = {
			NameSpace = "CustomTypes.PuppetCaptureSaveInfo",
			Properties = {
				saveUpdateTs = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				captureCount = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		PuppetCaptureSaveMap = {
			NameSpace = "CustomTypes.PuppetCaptureSaveMap",
			__ValueType__ = "PuppetCaptureSaveInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PuppetPetInfoSaveInfo = {
			NameSpace = "CustomTypes.PuppetPetInfoSaveInfo",
			Properties = {
				saveUpdateTs = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				level = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				gender = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				nature = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				label = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				shinyStyle = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				individuationIds = {
					"IntIntMap",
					{},
					"AllClients",
					"PER"
				},
				bornScale = {
					"double",
					1,
					"AllClients",
					"PER"
				},
				height = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				weight = {
					"double",
					0,
					"AllClients",
					"PER"
				},
				basePropertyList = {
					"BasePropertyList",
					{},
					"AllClients",
					"PER"
				},
				bodyEntries = {
					"IntList",
					{},
					"AllClients",
					"PER"
				}
			}
		},
		PuppetPetInfoSaveMap = {
			NameSpace = "CustomTypes.PuppetPetInfoSaveMap",
			__ValueType__ = "PuppetPetInfoSaveInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PuppetSaveInfo = {
			NameSpace = "CustomTypes.PuppetSaveInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				level = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				forceLabel = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				position = {
					"IntList",
					{},
					"ServerOnly",
					"PER"
				},
				createPlentyTalentEffect = {
					"IntList",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		PvpCommonInfo = {
			NameSpace = "CustomTypes.PvpCommonInfo",
			Properties = {
				pvpTotalCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				pvpWinCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PvpCommonMap = {
			NameSpace = "CustomTypes.PvpCommonMap",
			__ValueType__ = "PvpCommonInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		PvpPetInfo = {
			NameSpace = "CustomTypes.PvpPetInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				abilityPresetMap = {
					"AbilityPresetMap",
					{},
					"OwnClient",
					"PER"
				},
				curAbilityPreset = {
					"int",
					1,
					"OwnClient",
					"PER"
				},
				curCharacter = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		PvpPetInfoMap = {
			NameSpace = "CustomTypes.PvpPetInfoMap",
			__ValueType__ = "PvpPetInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		QuestActionMap = {
			NameSpace = "CustomTypes.QuestActionMap",
			__ValueType__ = "IntList",
			__IntTypeKey__ = true,
			Properties = {}
		},
		QuestCloseConditionData = {
			NameSpace = "CustomTypes.QuestCloseConditionData",
			Properties = {
				closeCond = {
					"QuestObjectivesMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		QuestCloseConditionDataMap = {
			NameSpace = "CustomTypes.QuestCloseConditionDataMap",
			__ValueType__ = "QuestCloseConditionData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		QuestCompleteActionData = {
			NameSpace = "CustomTypes.QuestCompleteActionData",
			Properties = {
				comActionObjcvs = {
					"QuestObjectivesMap",
					{},
					"OwnClient",
					"PER"
				},
				comEventSequenceIndex = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				lastComActionsTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		RainbowPetSaveInfoList = {
			NameSpace = "CustomTypes.RainbowPetSaveInfoList",
			__ValueType__ = "RainbowPetSaveInfo",
			__IntTypeKey__ = true
		},
		ReTriggerEventList = {
			NameSpace = "CustomTypes.ReTriggerEventList",
			__ValueType__ = "ReTriggerEventInfo",
			__IntTypeKey__ = true
		},
		RobEggDataList = {
			NameSpace = "CustomTypes.RobEggDataList",
			__ValueType__ = "RobEggData",
			__IntTypeKey__ = true
		},
		QuestCompleteActionDataMap = {
			NameSpace = "CustomTypes.QuestCompleteActionDataMap",
			__ValueType__ = "QuestCompleteActionData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		QuestObjective = {
			NameSpace = "CustomTypes.QuestObjective",
			Properties = {
				currentCnt = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				isComplete = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		QuestObjectivesMap = {
			NameSpace = "CustomTypes.QuestObjectivesMap",
			__ValueType__ = "QuestObjective",
			__IntTypeKey__ = true,
			Properties = {}
		},
		QuizData = {
			NameSpace = "CustomTypes.QuizData",
			Properties = {
				quizId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				completeSequence = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				optionsOrder = {
					"IntIntListMap",
					{},
					"ServerOnly",
					"PER"
				},
				finishedSum = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				rightSum = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		QuizDataMap = {
			NameSpace = "CustomTypes.QuizDataMap",
			__ValueType__ = "QuizData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RainbowPetSaveInfo = {
			NameSpace = "CustomTypes.RainbowPetSaveInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				spawnPointId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				staticId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				level = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				forceLabel = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				createPlentyTalentEffect = {
					"IntList",
					{},
					"ServerOnly",
					"PER"
				},
				originFlag = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		RandomShop = {
			NameSpace = "CustomTypes.RandomShop",
			Properties = {
				randomShopBase = {
					"RandomShopBase",
					{},
					"OwnClient",
					"PER"
				},
				posUlockFlag = {
					"IntBoolMap",
					{},
					"OwnClient",
					"PER"
				},
				refreshCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				buyCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				goodsList = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				topTier = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				pity = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				hasBuyPos = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		RandomShopBase = {
			NameSpace = "CustomTypes.RandomShopBase",
			Properties = {
				shopId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				shopType = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		ReTriggerEventInfo = {
			NameSpace = "CustomTypes.ReTriggerEventInfo",
			Properties = {
				eventId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				triggerName = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				triggerParam = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				context = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				subName = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				subId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				subEvents = {
					"string",
					"",
					"ServerOnly",
					"PER"
				},
				currentIndex = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				totalCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				reTriggerCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		RecentDungeonPlaymateInfo = {
			NameSpace = "CustomTypes.RecentDungeonPlaymateInfo",
			Properties = {
				teamTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				dungeonSceneId = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				hardLv = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		RecentDungeonPlaymateInfoMap = {
			NameSpace = "CustomTypes.RecentDungeonPlaymateInfoMap",
			__ValueType__ = "RecentDungeonPlaymateInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		ResearchPointInfo = {
			NameSpace = "CustomTypes.ResearchPointInfo",
			Properties = {
				researchCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				researchPoint = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				biParamsList = {
					"IntIntList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		ResearchPointMap = {
			NameSpace = "CustomTypes.ResearchPointMap",
			__ValueType__ = "ResearchPointInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ResearchReportInfo = {
			NameSpace = "CustomTypes.ResearchReportInfo",
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				researchPoint = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		ResearchReportMap = {
			NameSpace = "CustomTypes.ResearchReportMap",
			__ValueType__ = "ResearchReportInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ResonanceInfo = {
			NameSpace = "CustomTypes.ResonanceInfo",
			Properties = {
				resonanceStage = {
					"int",
					1,
					"OwnClient",
					"PER"
				},
				resonanceLevel = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				firstCreate = {
					"boolean",
					true,
					"OwnClient",
					"PER"
				},
				resonanceMap = {
					"IntDoubleMap",
					{},
					"ServerOnly",
					"NPER"
				}
			}
		},
		RewardedTargetMap = {
			NameSpace = "CustomTypes.RewardedTargetMap",
			__ValueType__ = "IntBoolMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RobEggData = {
			NameSpace = "CustomTypes.RobEggData",
			Properties = {
				templateId = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				patternType = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				patternColorType = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		RobEggHatchMap = {
			NameSpace = "CustomTypes.RobEggHatchMap",
			__ValueType__ = "RobEggHatchPoint",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RobEggHatchPoint = {
			NameSpace = "CustomTypes.RobEggHatchPoint",
			Properties = {
				status = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				hatchFinishTime = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				ownerUid = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				eggItemId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				position = {
					"ScenePos",
					{},
					"AllClients",
					"NPER"
				},
				timerId = {
					"int",
					-1,
					"ServerOnly",
					"NPER"
				},
				readBarUid = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				readBarTimerId = {
					"int",
					-1,
					"ServerOnly",
					"NPER"
				}
			}
		},
		RobEggInfo = {
			NameSpace = "CustomTypes.RobEggInfo",
			Properties = {
				finish_time = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				bringEggs = {
					"RobEggDataList",
					{},
					"OwnClient",
					"NPER"
				},
				transEggs = {
					"RobEggDataList",
					{},
					"OwnClient",
					"NPER"
				},
				killed_reason = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				killed_name = {
					"string",
					"",
					"OwnClient",
					"NPER"
				},
				profit = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				hatchPets = {
					"PetMap",
					{},
					"OwnClient",
					"NPER"
				},
				reward = {
					"IntIntMap",
					{},
					"OwnClient",
					"NPER"
				},
				result = {
					"int",
					1,
					"OwnClient",
					"NPER"
				},
				killUser = {
					"RobEggKillUserInfoMap",
					{},
					"OwnClient",
					"NPER"
				},
				killNpc = {
					"RobEggKillNpcInfoMap",
					{},
					"OwnClient",
					"NPER"
				},
				coinFactor = {
					"double",
					0,
					"OwnClient",
					"NPER"
				},
				levelInfo = {
					"RobEggLevelSettleInfo",
					{},
					"OwnClient",
					"NPER"
				},
				levelRewardBoxId = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				sceneId = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		RobEggItemInfo = {
			NameSpace = "CustomTypes.RobEggItemInfo",
			Properties = {
				itemId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				eggPattern = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				eggPatternColor = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		RobEggKillNpcInfo = {
			NameSpace = "CustomTypes.RobEggKillNpcInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				timestamp = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		RobEggKillNpcInfoMap = {
			NameSpace = "CustomTypes.RobEggKillNpcInfoMap",
			__ValueType__ = "RobEggKillNpcInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		RobEggKillUserInfo = {
			NameSpace = "CustomTypes.RobEggKillUserInfo",
			Properties = {
				uid = {
					"string",
					"",
					"OwnClient",
					"NPER"
				},
				name = {
					"string",
					"",
					"OwnClient",
					"NPER"
				},
				level = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				title = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				timestamp = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		RobEggKillUserInfoMap = {
			NameSpace = "CustomTypes.RobEggKillUserInfoMap",
			__ValueType__ = "RobEggKillUserInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		RobEggLevelSettleInfo = {
			NameSpace = "CustomTypes.RobEggLevelSettleInfo",
			Properties = {
				score = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				negative = {
					"boolean",
					false,
					"OwnClient",
					"NPER"
				},
				scoreDetail = {
					"IntIntMap",
					{},
					"OwnClient",
					"NPER"
				},
				eggLv = {
					"IntList",
					{},
					"OwnClient",
					"NPER"
				},
				secEggLv = {
					"IntList",
					{},
					"OwnClient",
					"NPER"
				},
				eggStar = {
					"IntList",
					{},
					"OwnClient",
					"NPER"
				},
				eggScore = {
					"IntList",
					{},
					"OwnClient",
					"NPER"
				},
				performance = {
					"RobEggPerformanceDetail",
					{},
					"OwnClient",
					"NPER"
				},
				hardLv = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				scoreFactor = {
					"int",
					1,
					"OwnClient",
					"NPER"
				},
				protectReason = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		RobEggLootItemList = {
			NameSpace = "CustomTypes.RobEggLootItemList",
			__ValueType__ = "LootBoxItem",
			__IntTypeKey__ = true
		},
		RobEggRewardBoxList = {
			NameSpace = "CustomTypes.RobEggRewardBoxList",
			__ValueType__ = "RobEggRewardBox",
			__IntTypeKey__ = true
		},
		RobEggLootItemMap = {
			NameSpace = "CustomTypes.RobEggLootItemMap",
			__ValueType__ = "LootBoxItem",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RobEggMapMark = {
			NameSpace = "CustomTypes.RobEggMapMark",
			Properties = {
				pos = {
					"ScenePos",
					{},
					"AllClients",
					"NPER"
				},
				timestamp = {
					"int",
					0,
					"AllClients",
					"NPER"
				}
			}
		},
		RobEggMapMarkMap = {
			NameSpace = "CustomTypes.RobEggMapMarkMap",
			__ValueType__ = "RobEggMapMark",
			__IntTypeKey__ = false,
			Properties = {}
		},
		RobEggPerformanceDetail = {
			NameSpace = "CustomTypes.RobEggPerformanceDetail",
			__ValueType__ = "RobEggPerformanceItem",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RobEggPerformanceItem = {
			NameSpace = "CustomTypes.RobEggPerformanceItem",
			Properties = {
				id = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				quality = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				score = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		RobEggResource = {
			NameSpace = "CustomTypes.RobEggResource",
			Properties = {
				actorId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				position = {
					"ScenePos",
					{},
					"AllClients",
					"NPER"
				},
				quality = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				teams = {
					"StringList",
					{},
					"AllClients",
					"NPER"
				}
			}
		},
		RobEggResourceMap = {
			NameSpace = "CustomTypes.RobEggResourceMap",
			__ValueType__ = "RobEggResource",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RobEggRewardBox = {
			NameSpace = "CustomTypes.RobEggRewardBox",
			Properties = {
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				timestamp = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				achievedTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		RobEggShowCase = {
			NameSpace = "CustomTypes.RobEggShowCase",
			__ValueType__ = "ShowCaseAntiqueItem",
			__IntTypeKey__ = true,
			Properties = {
				allPoint = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				rewardRecord = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		RobEggShowCaseMap = {
			NameSpace = "CustomTypes.RobEggShowCaseMap",
			__ValueType__ = "RobEggShowCase",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RobEggSlotItem = {
			NameSpace = "CustomTypes.RobEggSlotItem",
			Properties = {
				genId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				needDiscovery = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				discoveryExpireTime = {
					"int",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		RobEggSlotItemMap = {
			NameSpace = "CustomTypes.RobEggSlotItemMap",
			__ValueType__ = "RobEggSlotItem",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RobEggTransport = {
			NameSpace = "CustomTypes.RobEggTransport",
			Properties = {
				ownerUid = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				ownerName = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				eggItemId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				eggPattern = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				eggPatternColor = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				position = {
					"ScenePos",
					{},
					"AllClients",
					"NPER"
				},
				timerId = {
					"int",
					0,
					"ServerOnly",
					"NPER"
				},
				startTime = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				finishTime = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				robTimerId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				robUid = {
					"string",
					"",
					"AllClients",
					"NPER"
				},
				state = {
					"int",
					0,
					"AllClients",
					"NPER"
				}
			}
		},
		RobEggTransportMap = {
			NameSpace = "CustomTypes.RobEggTransportMap",
			__ValueType__ = "RobEggTransport",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RobEggUserInfoMap = {
			NameSpace = "CustomTypes.RobEggUserInfoMap",
			__ValueType__ = "RobEggInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		RogueBookBossMap = {
			NameSpace = "CustomTypes.RogueBookBossMap",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RogueCombatStatistic = {
			NameSpace = "CustomTypes.RogueCombatStatistic",
			Properties = {
				damage = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				takenDamage = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				heal = {
					"double",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		RogueCombatStatisticInfo = {
			NameSpace = "CustomTypes.RogueCombatStatisticInfo",
			Properties = {
				pet = {
					"RogueCombatStatisticMap",
					{},
					"ServerOnly",
					"PER"
				},
				buff = {
					"RogueCombatStatisticMap",
					{},
					"ServerOnly",
					"PER"
				},
				tempPet = {
					"RogueCombatStatisticMap",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		RogueCombatStatisticMap = {
			NameSpace = "CustomTypes.RogueCombatStatisticMap",
			__ValueType__ = "RogueCombatStatistic",
			__IntTypeKey__ = false,
			Properties = {}
		},
		RogueDiceRollMap = {
			NameSpace = "CustomTypes.RogueDiceRollMap",
			__ValueType__ = "IntBoolMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RogueDiceRollMapMap = {
			NameSpace = "CustomTypes.RogueDiceRollMapMap",
			__ValueType__ = "RogueDiceRollMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RogueDiceStateInfo = {
			NameSpace = "CustomTypes.RogueDiceStateInfo",
			Properties = {
				diceSchemeId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				diceRandomCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				totalRollPoint = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				isDiceFinish = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				isReward = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		RogueDiceStateMap = {
			NameSpace = "CustomTypes.RogueDiceStateMap",
			__ValueType__ = "RogueDiceStateInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		RogueInitSeriesInfo = {
			NameSpace = "CustomTypes.RogueInitSeriesInfo",
			Properties = {
				buffInfo = {
					"IntList",
					{},
					"OwnClient",
					"PER"
				},
				itemInfo = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				realSeries = {
					"int",
					-1,
					"OwnClient",
					"PER"
				}
			}
		},
		RogueInitSeriesMap = {
			NameSpace = "CustomTypes.RogueInitSeriesMap",
			__ValueType__ = "RogueInitSeriesInfo",
			__IntTypeKey__ = true,
			Properties = {
				curSeries = {
					"int",
					-1,
					"OwnClient",
					"PER"
				},
				curRealSeries = {
					"int",
					-1,
					"OwnClient",
					"PER"
				},
				hadInit = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				hadRecordBuff = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				},
				hadNotifySeriesInfo = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				}
			}
		},
		RoguePetMap = {
			NameSpace = "CustomTypes.RoguePetMap",
			__ValueType__ = "IntDoubleMap",
			__IntTypeKey__ = false,
			Properties = {}
		},
		SceneAllData = {
			NameSpace = "CustomTypes.SceneAllData",
			__ValueType__ = "SceneSaveInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		SceneEnvData = {
			NameSpace = "CustomTypes.SceneEnvData",
			__ValueType__ = "EnvData",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ScenePos = {
			NameSpace = "CustomTypes.ScenePos",
			__ValueType__ = "double",
			__IntTypeKey__ = true
		},
		ShieldDataList = {
			NameSpace = "CustomTypes.ShieldDataList",
			__ValueType__ = "ShieldData",
			__IntTypeKey__ = true
		},
		SceneLeylineMarkIdTimes = {
			NameSpace = "CustomTypes.SceneLeylineMarkIdTimes",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ScenePosMap = {
			NameSpace = "CustomTypes.ScenePosMap",
			__ValueType__ = "ScenePos",
			__IntTypeKey__ = true,
			Properties = {}
		},
		SceneSaveInfo = {
			NameSpace = "CustomTypes.SceneSaveInfo",
			Properties = {
				spawnerStatesMap = {
					"IntIntBoolMap",
					{},
					"ServerOnly",
					"PER"
				},
				spawnerRefreshCountMap = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				spawnerNoActives = {
					"IntBoolMap",
					{},
					"ServerOnly",
					"PER"
				},
				spawnerLastResetTsMap = {
					"IntDoubleMap",
					{},
					"ServerOnly",
					"PER"
				},
				spawnerActivationTsMap = {
					"IntDoubleMap",
					{},
					"ServerOnly",
					"PER"
				},
				spawnerEntNextRefTimeMap = {
					"IntIntDoubleMap",
					{},
					"ServerOnly",
					"PER"
				},
				spawnerGroupDeadTimeMap = {
					"IntDoubleMap",
					{},
					"ServerOnly",
					"PER"
				},
				spawnerShinyMap = {
					"SpawnerShinyMap",
					{},
					"ServerOnly",
					"PER"
				},
				finishedSpawner = {
					"IntBoolMap",
					{},
					"ServerOnly",
					"PER"
				},
				ecoTracePuppetSaveList = {
					"PuppetSaveInfoList",
					{},
					"ServerOnly",
					"PER"
				},
				persistEntityInfoMap = {
					"PersistEntityInfoMap",
					{},
					"ServerOnly",
					"PER"
				},
				puppetPetInfoSaveMap = {
					"PuppetPetInfoSaveMap",
					{},
					"ServerOnly",
					"PER"
				},
				puppetCaptureSaveMap = {
					"PuppetCaptureSaveMap",
					{},
					"ServerOnly",
					"PER"
				},
				flowerBloomSessionSaveMap = {
					"FlowerBloomSessionSaveMap",
					{},
					"ServerOnly",
					"PER"
				},
				rainbowPetSaveList = {
					"RainbowPetSaveInfoList",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		SealedPetInfo = {
			NameSpace = "CustomTypes.SealedPetInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				customName = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				gender = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				nature = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				label = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				shinyStyle = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				propertyScoreStage = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				basePropertyList = {
					"BasePropertyList",
					{},
					"OwnClient",
					"PER"
				},
				isSealed = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				hatchTime = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		SealedPetMap = {
			NameSpace = "CustomTypes.SealedPetMap",
			__ValueType__ = "SealedPetInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ShieldData = {
			NameSpace = "CustomTypes.ShieldData",
			Properties = {
				curPoint = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				absorbRate = {
					"double",
					1,
					"ServerOnly",
					"NPER"
				},
				elementType = {
					"double",
					-1,
					"AllClients",
					"NPER"
				},
				buffInsId = {
					"double",
					0,
					"OwnClient",
					"NPER"
				},
				isGeneral = {
					"boolean",
					false,
					"ServerOnly",
					"NPER"
				},
				isDestroyBuff = {
					"boolean",
					false,
					"ServerOnly",
					"NPER"
				},
				templateId = {
					"double",
					0,
					"ServerOnly",
					"NPER"
				}
			}
		},
		ShopMallCart = {
			NameSpace = "CustomTypes.ShopMallCart",
			__ValueType__ = "ShopMallCartItem",
			__IntTypeKey__ = true,
			Properties = {}
		},
		ShopMallCartItem = {
			NameSpace = "CustomTypes.ShopMallCartItem",
			Properties = {
				shopCommodityId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				num = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				time = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		ShowCaseAntiqueItem = {
			NameSpace = "CustomTypes.ShowCaseAntiqueItem",
			Properties = {
				id = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				props = {
					"ItemProperties",
					{},
					"OwnClient",
					"PER"
				},
				active = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		SingleSandboxData = {
			NameSpace = "CustomTypes.SingleSandboxData",
			Properties = {
				state = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				isRewarded = {
					"boolean",
					false,
					"ServerOnly",
					"PER"
				},
				refreshTime = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				levelItem = {
					"LevelItemMap",
					{},
					"OwnClient",
					"PER"
				},
				eventState = {
					"StringBooleanMap",
					{},
					"ServerOnly",
					"PER"
				},
				onceInteractList = {
					"IntBoolMap",
					{},
					"OwnClient",
					"PER"
				},
				version = {
					"string",
					"",
					"ServerOnly",
					"PER"
				}
			}
		},
		SkillNodeInfo = {
			NameSpace = "CustomTypes.SkillNodeInfo",
			Properties = {
				lv = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				buffInstanceId = {
					"int",
					0,
					"OwnClient",
					"NPER"
				},
				skillAttrEntrys = {
					"StringList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		SkillNodeMap = {
			NameSpace = "CustomTypes.SkillNodeMap",
			__ValueType__ = "SkillNodeInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		SlotValue = {
			NameSpace = "CustomTypes.SlotValue",
			Properties = {
				index = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				uuid = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				itemId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				customData = {
					"string",
					"",
					"OwnClient",
					"PER"
				}
			}
		},
		SpawnerShinyInfo = {
			NameSpace = "CustomTypes.SpawnerShinyInfo",
			Properties = {
				resetShinyTime = {
					"double",
					0,
					"ServerOnly",
					"PER"
				},
				shinyInfos = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				},
				shinyStyleInfos = {
					"IntIntMap",
					{},
					"ServerOnly",
					"PER"
				}
			}
		},
		SpawnerShinyMap = {
			NameSpace = "CustomTypes.SpawnerShinyMap",
			__ValueType__ = "SpawnerShinyInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		SpecialTrainData = {
			NameSpace = "CustomTypes.SpecialTrainData",
			Properties = {
				rewardFlags = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				curQuestId = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		SpecialTrainMap = {
			NameSpace = "CustomTypes.SpecialTrainMap",
			__ValueType__ = "SpecialTrainData",
			__IntTypeKey__ = true,
			Properties = {
				isChapterViewed = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				canGetChapterReward = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				isChapterRewarded = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				isInStarTitleQuest = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				isStarTitleQuestViewed = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		SpecialTrainMapMap = {
			NameSpace = "CustomTypes.SpecialTrainMapMap",
			__ValueType__ = "SpecialTrainMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		SpecialTrainTypeInfo = {
			NameSpace = "CustomTypes.SpecialTrainTypeInfo",
			Properties = {
				completeCnt = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				isRewarded = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				}
			}
		},
		SpecialTrainTypeMap = {
			NameSpace = "CustomTypes.SpecialTrainTypeMap",
			__ValueType__ = "SpecialTrainTypeInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		StolenAbilityInfo = {
			NameSpace = "CustomTypes.StolenAbilityInfo",
			Properties = {
				actorType = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				templateId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				stolenAbilityId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				duration = {
					"double",
					0,
					"OwnClient",
					"NPER"
				}
			}
		},
		StolenAbilityRef = {
			NameSpace = "CustomTypes.StolenAbilityRef",
			__ValueType__ = "StolenAbilityInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		StringBoolMap = {
			NameSpace = "CustomTypes.StringBoolMap",
			__ValueType__ = "boolean",
			__IntTypeKey__ = false,
			Properties = {}
		},
		StringBooleanMap = {
			NameSpace = "CustomTypes.StringBooleanMap",
			__ValueType__ = "boolean",
			__IntTypeKey__ = false,
			Properties = {}
		},
		StringDoubleMap = {
			NameSpace = "CustomTypes.StringDoubleMap",
			__ValueType__ = "double",
			__IntTypeKey__ = false,
			Properties = {}
		},
		StringIntMap = {
			NameSpace = "CustomTypes.StringIntMap",
			__ValueType__ = "int",
			__IntTypeKey__ = false,
			Properties = {}
		},
		StringIntMapMap = {
			NameSpace = "CustomTypes.StringIntMapMap",
			__ValueType__ = "IntIntMap",
			__IntTypeKey__ = false,
			Properties = {}
		},
		StringIntMapWithChangeEvent = {
			NameSpace = "CustomTypes.StringIntMapWithChangeEvent",
			__ValueType__ = "int",
			__IntTypeKey__ = false,
			Properties = {}
		},
		StringList = {
			NameSpace = "CustomTypes.StringList",
			__ValueType__ = "string",
			__IntTypeKey__ = true
		},
		StringListList = {
			NameSpace = "CustomTypes.StringListList",
			__ValueType__ = "StringList",
			__IntTypeKey__ = true
		},
		TalentList = {
			NameSpace = "CustomTypes.TalentList",
			__ValueType__ = "TalentInfo",
			__IntTypeKey__ = true
		},
		TeamMemberInfoList = {
			NameSpace = "CustomTypes.TeamMemberInfoList",
			__ValueType__ = "TeamMemberInfo",
			__IntTypeKey__ = true
		},
		UnFairPvpPresetList = {
			NameSpace = "CustomTypes.UnFairPvpPresetList",
			__ValueType__ = "UnFairPvpPreset",
			__IntTypeKey__ = true
		},
		StringItemPosMap = {
			NameSpace = "CustomTypes.StringItemPosMap",
			__ValueType__ = "ItemPos",
			__IntTypeKey__ = false,
			Properties = {}
		},
		StringStringListMap = {
			NameSpace = "CustomTypes.StringStringListMap",
			__ValueType__ = "StringList",
			__IntTypeKey__ = false,
			Properties = {}
		},
		StringStringMap = {
			NameSpace = "CustomTypes.StringStringMap",
			__ValueType__ = "string",
			__IntTypeKey__ = false,
			Properties = {}
		},
		SuperBigEggInfo = {
			NameSpace = "CustomTypes.SuperBigEggInfo",
			Properties = {
				created = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				},
				expireOpenTime = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				entityId = {
					"string",
					"",
					"AllClients",
					"NPER"
				}
			}
		},
		TalentInfo = {
			NameSpace = "CustomTypes.TalentInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				propValues = {
					"DoubleList",
					{},
					"OwnClient",
					"PER"
				},
				scaleFixs = {
					"DoubleList",
					{},
					"OwnClient",
					"PER"
				},
				cp = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		TaskSpawnerClearMap = {
			NameSpace = "CustomTypes.TaskSpawnerClearMap",
			__ValueType__ = "IntIntBoolMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		TaskSpawnerMap = {
			NameSpace = "CustomTypes.TaskSpawnerMap",
			__ValueType__ = "IntIntMapMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		TeamMemberInfo = {
			NameSpace = "CustomTypes.TeamMemberInfo",
			Properties = {
				uid = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				isLeader = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				playerName = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				headIcon = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				pets = {
					"PetSimpleList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		TeamMemberInfoMap = {
			NameSpace = "CustomTypes.TeamMemberInfoMap",
			__ValueType__ = "TeamMemberInfoList",
			__IntTypeKey__ = true,
			Properties = {}
		},
		TideInfo = {
			NameSpace = "CustomTypes.TideInfo",
			Properties = {
				tideType = {
					"int",
					-1,
					"AllClients",
					"PER"
				},
				expiredTime = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		TillHelpInfo = {
			NameSpace = "CustomTypes.TillHelpInfo",
			Properties = {
				count = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				lastTs = {
					"int",
					0,
					"ServerOnly",
					"PER"
				},
				name = {
					"string",
					"",
					"ServerOnly",
					"PER"
				}
			}
		},
		TillHelpInfoMap = {
			NameSpace = "CustomTypes.TillHelpInfoMap",
			__ValueType__ = "TillHelpInfo",
			__IntTypeKey__ = false,
			Properties = {}
		},
		TotemInfo = {
			NameSpace = "CustomTypes.TotemInfo",
			Properties = {
				level = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				exp = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				isMaxLevel = {
					"boolean",
					false,
					"OwnClient",
					"PER"
				},
				rewardFlags = {
					"IntBoolMap",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		TotemMap = {
			NameSpace = "CustomTypes.TotemMap",
			__ValueType__ = "TotemInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		TreeMeteoInfo = {
			NameSpace = "CustomTypes.TreeMeteoInfo",
			Properties = {
				templateId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				pointId = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		TreeMeteoInfoMap = {
			NameSpace = "CustomTypes.TreeMeteoInfoMap",
			__ValueType__ = "TreeMeteoInfo",
			__IntTypeKey__ = true,
			Properties = {}
		},
		TriggerMap = {
			NameSpace = "CustomTypes.TriggerMap",
			Properties = {
				registerCustomSet = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				customCondition = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				customCount = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				completeCustomSet = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				customLastTime = {
					"IntDoubleMap",
					{},
					"OwnClient",
					"PER"
				},
				customTimeCondition = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				dayCustomCondition = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				customVariables = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				npcBehaviorStatus = {
					"BehaviorStatusMap",
					{},
					"OwnClient",
					"PER"
				},
				questClaimTriggers = {
					"TriggerRegMap",
					{},
					"OwnClient",
					"PER"
				},
				questObjectivesTriggers = {
					"TriggerRegMap",
					{},
					"OwnClient",
					"PER"
				},
				questRunTriggers = {
					"TriggerRegMap",
					{},
					"OwnClient",
					"PER"
				},
				questComActionObjTriggers = {
					"TriggerRegMap",
					{},
					"OwnClient",
					"PER"
				},
				questCloseTriggers = {
					"TriggerRegMap",
					{},
					"OwnClient",
					"PER"
				},
				gmTriggerValue = {
					"GmTriggerValue",
					{},
					"OwnClient",
					"NPER"
				},
				triggerCurrentCountInfo = {
					"IntIntMapMap",
					{},
					"OwnClient",
					"PER"
				},
				questTriggerReverseIndex = {
					"TriggerQuestReverseIndexMap",
					{},
					"ServerOnly",
					"NPER"
				}
			}
		},
		TriggerQuestReverseIndexInnerMap = {
			NameSpace = "CustomTypes.TriggerQuestReverseIndexInnerMap",
			__ValueType__ = "IntIntBoolMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		TriggerQuestReverseIndexMap = {
			NameSpace = "CustomTypes.TriggerQuestReverseIndexMap",
			__ValueType__ = "TriggerQuestReverseIndexInnerMap",
			__IntTypeKey__ = true,
			Properties = {
				initialized = {
					"boolean",
					false,
					"ServerOnly",
					"NPER"
				}
			}
		},
		TriggerRegInnerMap = {
			NameSpace = "CustomTypes.TriggerRegInnerMap",
			__ValueType__ = "IntBoolMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		TriggerRegMap = {
			NameSpace = "CustomTypes.TriggerRegMap",
			__ValueType__ = "TriggerRegInnerMap",
			__IntTypeKey__ = true,
			Properties = {}
		},
		UnFairPvpPreset = {
			NameSpace = "CustomTypes.UnFairPvpPreset",
			Properties = {
				unfairPvpTeamName = {
					"string",
					"",
					"OwnClient",
					"PER"
				},
				unfairPvpTeamList = {
					"StringList",
					{},
					"OwnClient",
					"PER"
				}
			}
		},
		UseLimitInfo = {
			NameSpace = "CustomTypes.UseLimitInfo",
			Properties = {
				count = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				lastRemainCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				lastRemainUseCount = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				lastClearTs = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				rewardLimitToastCount = {
					"int",
					0,
					"ServerOnly",
					"PER"
				}
			}
		},
		UseLimitMap = {
			NameSpace = "CustomTypes.UseLimitMap",
			__ValueType__ = "UseLimitInfo",
			__IntTypeKey__ = true,
			Properties = {
				nextRefreshTs = {
					"int",
					0,
					"OwnClient",
					"PER"
				}
			}
		},
		WeatherInfo = {
			NameSpace = "CustomTypes.WeatherInfo",
			Properties = {
				startTime = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				endTime = {
					"int",
					0,
					"AllClients",
					"PER"
				},
				weatherId = {
					"int",
					0,
					"AllClients",
					"PER"
				}
			}
		},
		WeatherInfoList = {
			NameSpace = "CustomTypes.WeatherInfoList",
			__ValueType__ = "WeatherInfo",
			__IntTypeKey__ = true
		},
		WeatherInfoForecast = {
			NameSpace = "CustomTypes.WeatherInfoForecast",
			__ValueType__ = "WeatherInfoList",
			__IntTypeKey__ = true,
			Properties = {}
		},
		WeatherInfoMap = {
			NameSpace = "CustomTypes.WeatherInfoMap",
			__ValueType__ = "WeatherInfo",
			__IntTypeKey__ = true,
			Properties = {}
		}
	},
	ArgTypes = {
		TestInfo = {
			k3 = "boolean",
			k2 = "number",
			k1 = "string"
		},
		Vector3 = {
			z = "number",
			y = "number",
			x = "number"
		}
	},
	Entities = {
		ClientEntity = {
			NameSpace = "Core.Client.ClientEntity",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnServerMsgCallabck = {
					"int",
					"table"
				}
			}
		},
		ClientSpaceBase = {
			NameSpace = "Core.Client.ClientSpaceBase",
			Properties = {}
		},
		Entity = {
			NameSpace = "Core.Common.Entity",
			Properties = {},
			EngineMsg = {
				_Engine_ExRelation_ = {
					"string",
					"int"
				}
			}
		},
		ClientChestVirtualEntity = {
			NameSpace = "Entities.ClientChestVirtualEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientFollowSpriteVirtualEntity = {
			NameSpace = "Entities.ClientFollowSpriteVirtualEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientFollowingPhantomVirtualEntity = {
			NameSpace = "Entities.ClientFollowingPhantomVirtualEntity",
			Properties = {}
		},
		ClientGrabEggSettlementVirtualEntity = {
			NameSpace = "Entities.ClientGrabEggSettlementVirtualEntity",
			Properties = {}
		},
		ClientModelEntity = {
			NameSpace = "Entities.ClientModelEntity",
			Properties = {}
		},
		ClientOfflinePlayer = {
			NameSpace = "Entities.ClientOfflinePlayer",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientOfflinePuppet = {
			NameSpace = "Entities.ClientOfflinePuppet",
			Properties = {}
		},
		ClientOwnClientNpc = {
			NameSpace = "Entities.ClientOwnClientNpc",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientPawnEntity = {
			NameSpace = "Entities.ClientPawnEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientPhotoPetVirtualEntity = {
			NameSpace = "Entities.ClientPhotoPetVirtualEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientReplyFlutePortalEntity = {
			NameSpace = "Entities.ClientReplyFlutePortalEntity",
			Properties = {}
		},
		ClientShadowVirtualEntity = {
			NameSpace = "Entities.ClientShadowVirtualEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientSimpleMoveNpc = {
			NameSpace = "Entities.ClientSimpleMoveNpc",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientSimpleVirtualEntity = {
			NameSpace = "Entities.ClientSimpleVirtualEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientSimpleVirtualEntityWithPhysics = {
			NameSpace = "Entities.ClientSimpleVirtualEntityWithPhysics",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientSimpleVirtualNpc = {
			NameSpace = "Entities.ClientSimpleVirtualNpc",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientSimpleVirtualPet = {
			NameSpace = "Entities.ClientSimpleVirtualPet",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientSimpleVirtualPlayer = {
			NameSpace = "Entities.ClientSimpleVirtualPlayer",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientStudioOrnamentVirtualEntity = {
			NameSpace = "Entities.ClientStudioOrnamentVirtualEntity",
			Properties = {}
		},
		ClientStudioPetVirtualEntity = {
			NameSpace = "Entities.ClientStudioPetVirtualEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientStudioPlayerVirtualEntity = {
			NameSpace = "Entities.ClientStudioPlayerVirtualEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientTempPlayer = {
			NameSpace = "Entities.ClientTempPlayer",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientTempVirtualNpc = {
			NameSpace = "Entities.ClientTempVirtualNpc",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientVirtualEntity = {
			NameSpace = "Entities.ClientVirtualEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientVirtualNpc = {
			NameSpace = "Entities.ClientVirtualNpc",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientVirtualPuppet = {
			NameSpace = "Entities.ClientVirtualPuppet",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientVirtualTarget = {
			NameSpace = "Entities.ClientVirtualTarget",
			Properties = {}
		},
		LoginAgent = {
			NameSpace = "Entities.LoginAgent",
			Properties = {}
		},
		MsNetworkEventCallback = {
			NameSpace = "Entities.MsNetworkEventCallback",
			Properties = {}
		},
		NetworkEventCallback = {
			NameSpace = "Entities.NetworkEventCallback",
			Properties = {}
		},
		ClientBagItem = {
			NameSpace = "Entities.SpaceEntities.BallEntities.ClientBagItem",
			Properties = {}
		},
		ClientBallBase = {
			NameSpace = "Entities.SpaceEntities.BallEntities.ClientBallBase",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnReceiveEventMsg = {
					"string",
					"table"
				}
			}
		},
		ClientBigBall = {
			NameSpace = "Entities.SpaceEntities.BallEntities.ClientBigBall",
			Properties = {}
		},
		ClientCatchBall = {
			NameSpace = "Entities.SpaceEntities.BallEntities.ClientCatchBall",
			Properties = {}
		},
		ClientCatchBallFake = {
			NameSpace = "Entities.SpaceEntities.BallEntities.ClientCatchBallFake",
			Properties = {}
		},
		ClientCatchBallVirtual = {
			NameSpace = "Entities.SpaceEntities.BallEntities.ClientCatchBallVirtual",
			Properties = {}
		},
		ClientFishingCaptureBall = {
			NameSpace = "Entities.SpaceEntities.BallEntities.ClientFishingCaptureBall",
			Properties = {}
		},
		ClientMagicBall = {
			NameSpace = "Entities.SpaceEntities.BallEntities.ClientMagicBall",
			Properties = {}
		},
		ClientMainAuthorityBall = {
			NameSpace = "Entities.SpaceEntities.BallEntities.ClientMainAuthorityBall",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnCaptureAnimStart = {
					"table"
				},
				RPC_SC_OnCaptureAnimEnd = {
					"table"
				}
			}
		},
		ClientTrapBall = {
			NameSpace = "Entities.SpaceEntities.BallEntities.ClientTrapBall",
			Properties = {}
		},
		ClientAirWall = {
			NameSpace = "Entities.SpaceEntities.ClientAirWall",
			Properties = {}
		},
		ClientArkChest = {
			NameSpace = "Entities.SpaceEntities.ClientArkChest",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnUnlockStart = {}
			},
			PropertyCallbacks = {
				changed = {
					status = {
						"number",
						"on_status_changed"
					}
				}
			}
		},
		ClientBattleField = {
			NameSpace = "Entities.SpaceEntities.ClientBattleField",
			Properties = {}
		},
		ClientBossChallengeDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientBossChallengeDungeon",
			Properties = {}
		},
		ClientBossRushDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientBossRushDungeon",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ChallengeResult = {
					"boolean",
					"int"
				}
			},
			PropertyCallbacks = {
				changed = {
					selectedTankEntId = {
						"string",
						"onSelectedTankEntIdChanged"
					},
					battleStartTime = {
						"number",
						"onBattleStartTimeChanged"
					},
					levelScore = {
						"number",
						"onLevelScoreChanged"
					},
					levelGrade = {
						"number",
						"onLevelGradeChanged"
					},
					teamerInfos = {
						"customDict",
						"onTeamerInfosChanged"
					},
					selectBatBuffs = {
						"customDict",
						"onSelectBatBuffsChanged"
					},
					openLevelId = {
						"number",
						"onOpenLevelIdChanged"
					},
					curLevelTeamReviveCount = {
						"number",
						"onCurLevelTeamReviveCountChanged"
					}
				}
			}
		},
		ClientBreakableEntity = {
			NameSpace = "Entities.SpaceEntities.ClientBreakableEntity",
			Properties = {}
		},
		ClientCampCar = {
			NameSpace = "Entities.SpaceEntities.ClientCampCar",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					basicInfo = {
						"customDict",
						"on_basicInfoChanged"
					},
					likeCnt = {
						"number",
						"on_likeCntChanged"
					},
					CampCarLoadValue = {
						"number",
						"on_CampCarLoadValueChanged"
					}
				}
			}
		},
		ClientCarryItem = {
			NameSpace = "Entities.SpaceEntities.ClientCarryItem",
			Properties = {}
		},
		ClientCarryPet = {
			NameSpace = "Entities.SpaceEntities.ClientCarryPet",
			Properties = {}
		},
		ClientCatchRogueDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientCatchRogueDungeon",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ChallengeResult = {
					"boolean",
					"int"
				}
			}
		},
		ClientChest = {
			NameSpace = "Entities.SpaceEntities.ClientChest",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnUnlockStart = {}
			},
			PropertyCallbacks = {
				changed = {
					status = {
						"number",
						"on_status_changed"
					}
				}
			}
		},
		ClientCollectItem = {
			NameSpace = "Entities.SpaceEntities.ClientCollectItem",
			Properties = {}
		},
		ClientCreation = {
			NameSpace = "Entities.SpaceEntities.ClientCreation",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_StartWaterPoolBeAbsorbed = {
					"number",
					"number",
					"number",
					"number",
					"number",
					"number",
					"number",
					"string"
				},
				RPC_SC_CreateStartTimeline = {
					"number"
				}
			},
			PropertyCallbacks = {
				changed = {
					curHp = {
						"number",
						"on_curHp_changed"
					}
				}
			}
		},
		ClientCylinderTrapItem = {
			NameSpace = "Entities.SpaceEntities.ClientCylinderTrapItem",
			Properties = {}
		},
		ClientDittoDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientDittoDungeon",
			Properties = {}
		},
		ClientDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientDungeon",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnResult = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					status = {
						"number",
						"on_status_changed"
					},
					end_ts = {
						"number",
						"on_end_ts_changed"
					},
					result = {
						"boolean",
						"on_result_changed"
					},
					["passerByMap.*.displayInfo"] = {
						"string",
						"on_passerByDisplayInfo"
					},
					["passerByMap.*.petCombatMap.*"] = {
						"customDict",
						"on_passerByPetCombatInfo_changed"
					}
				}
			}
		},
		ClientDungeonBotPlayer = {
			NameSpace = "Entities.SpaceEntities.ClientDungeonBotPlayer",
			TickInterval = 0.1,
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_Portal_Success = {},
				RPC_SC_BossRushGotoGuanka = {
					"int"
				}
			}
		},
		ClientEggShip = {
			NameSpace = "Entities.SpaceEntities.ClientEggShip",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					finishEggTask = {
						"boolean",
						"on_finishEggTask_changed"
					}
				}
			}
		},
		ClientEnvObject = {
			NameSpace = "Entities.SpaceEntities.ClientEnvObject",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnUnlockStart = {}
			},
			PropertyCallbacks = {
				changed = {
					isDestroying = {
						"boolean",
						"on_isDestroying_changed"
					},
					status = {
						"number",
						"on_status_changed"
					}
				}
			}
		},
		ClientEvolutionEntity = {
			NameSpace = "Entities.SpaceEntities.ClientEvolutionEntity",
			Properties = {}
		},
		ClientFertilityCubeEntity = {
			NameSpace = "Entities.SpaceEntities.ClientFertilityCubeEntity",
			Properties = {}
		},
		ClientFishingCaptureDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientFishingCaptureDungeon",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					gamePhase = {
						"number",
						"on_gamePhase_changed"
					},
					phaseEndTs = {
						"number",
						"on_phaseEndTs_changed"
					},
					bossDebuffLayer = {
						"number",
						"on_bossDebuffLayer_changed"
					},
					isPausing = {
						"boolean",
						"on_isPausing_changed"
					}
				}
			}
		},
		ClientGrabEggTransfer = {
			NameSpace = "Entities.SpaceEntities.ClientGrabEggTransfer",
			Properties = {}
		},
		ClientHomeCamp = {
			NameSpace = "Entities.SpaceEntities.ClientHomeCamp",
			Properties = {}
		},
		ClientHomePet = {
			NameSpace = "Entities.SpaceEntities.ClientHomePet",
			Properties = {}
		},
		ClientHomeland = {
			NameSpace = "Entities.SpaceEntities.ClientHomeland",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					basicInfo = {
						"customDict",
						"on_basicInfoChanged"
					},
					homeAreaStats = {
						"customDict",
						"on_homeAreaStats_changed"
					}
				}
			}
		},
		ClientInteractTriggerProxy = {
			NameSpace = "Entities.SpaceEntities.ClientInteractTriggerProxy",
			Properties = {}
		},
		ClientInteractor = {
			NameSpace = "Entities.SpaceEntities.ClientInteractor",
			Properties = {}
		},
		ClientInteractorPetEgg = {
			NameSpace = "Entities.SpaceEntities.ClientInteractorPetEgg",
			Properties = {}
		},
		ClientLeylineFlower = {
			NameSpace = "Entities.SpaceEntities.ClientLeylineFlower",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					flowerState = {
						"number",
						"on_flowerState_changed"
					},
					bloomCatchCount = {
						"number",
						"on_bloomCatchCount_changed"
					}
				}
			}
		},
		ClientLeylineTree = {
			NameSpace = "Entities.SpaceEntities.ClientLeylineTree",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					level = {
						"number",
						"on_level_changed"
					}
				}
			}
		},
		ClientLine = {
			NameSpace = "Entities.SpaceEntities.ClientLine",
			Properties = {}
		},
		ClientMainPlayer = {
			NameSpace = "Entities.SpaceEntities.ClientMainPlayer",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnPlayerException = {},
				RPC_SC_OnTeleportSpaceIn = {
					"string",
					"table",
					"boolean",
					"number",
					"boolean"
				},
				RPC_SC_OnTeleportSpaceOut = {
					"table"
				},
				RPC_SC_DoGmCmdRet = {
					"string",
					"table"
				},
				RPC_SC_ReceivePlayerGmList = {
					"table"
				},
				RPC_SC_GmModifyClientDesignTable = {
					"table"
				},
				RPC_SC_Portal_Success = {},
				RPC_SC_Heartbeat = {
					"float",
					"float",
					"float",
					"float"
				},
				RPC_SC_SetServerTime = {
					"int"
				},
				RPC_SC_PveHeartbeat = {
					"int",
					"int",
					"float",
					"float"
				},
				RPC_SC_WarnClient = {
					"string"
				},
				RPC_SC_WarnClientMessage = {
					"string",
					"string"
				},
				RPC_SC_Notify_Hotfix_Content = {
					"string"
				},
				RPC_SC_BindLocalPlayer = {
					"string",
					"string",
					"string"
				},
				RPC_SC_Notify_CommonSwitch = {
					"table"
				},
				RPC_SC_Notify_ChangeServerOpenTime = {
					"int"
				},
				RPC_SC_OnWorldFurniturePlaced = {
					"table"
				},
				RPC_SC_BpAttack = {
					"number",
					"number"
				},
				RPC_SC_OnBugReportReply = {
					"number",
					"table",
					"string"
				},
				RPC_SC_receiveNotice = {
					"int",
					"table"
				},
				RPC_SC_ResetAllStateByEscape = {},
				RPC_SC_LoseConnectTest = {
					"int",
					"boolean"
				},
				RPC_SC_BanTeleportEffect = {},
				RPC_SC_OpenTelnetDebug = {},
				RPC_SC_NotifyResetPositionInfo = {
					"int",
					"int",
					"int"
				},
				RPC_SC_ChangePlayerNameRet = {
					"int"
				},
				RPC_SC_EnterLeaderSpace = {
					"int",
					"int",
					"int"
				},
				RPC_SC_NotifyScrollingtext = {
					"table"
				},
				RPC_SC_SyncTeamEntityData = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					nourishCount = {
						"number",
						"on_nourishCount_changed"
					},
					dailyNourishCount = {
						"number",
						"on_dailyNourishCount_changed"
					},
					curEp = {
						"number",
						"on_curEp_changed"
					},
					maxEp = {
						"number",
						"on_maxEp_changed"
					},
					maxHp = {
						"number",
						"on_maxHp_changed"
					},
					maxStamina = {
						"number",
						"on_maxStamina_changed"
					},
					curSp = {
						"number",
						"on_curSp_changed"
					},
					["partnerList.*.curHp"] = {
						"number",
						"on_petInfoCurHp_change"
					},
					["partnerList.*.maxHp"] = {
						"number",
						"on_petInfoCurMaxHp_change"
					},
					worldChatGroupId = {
						"string",
						"on_worldChatGroupId_changed"
					},
					classChatGroupId = {
						"string",
						"on_classChatGroupId_changed"
					},
					languageChatGroupId = {
						"string",
						"on_languageChatGroupId_changed"
					},
					isInFluteMatch = {
						"boolean",
						"on_isInFluteMatch_changed"
					},
					["partnerList.*.shieldPoint"] = {
						"number",
						"onPetInfoShieldChange"
					},
					["partnerList.*.isAlive"] = {
						"boolean",
						"onPetInfoAliveChange"
					},
					["pvp2RevealByTarget.*"] = {
						"number",
						"onPvp2RevealByTargetChange"
					},
					isSpecialTrainOpen = {
						"boolean",
						"onIsSpecialTrainOpenChange"
					}
				},
				entryAdded = {
					behatredMap = {
						"customDict",
						"onBeHatredMapAdd"
					},
					pvp2RevealByTarget = {
						"customDict",
						"onPvp2RevealByTargetAdd"
					}
				},
				entryDeleted = {
					behatredMap = {
						"customDict",
						"onBeHatredMapDelete"
					},
					pvp2RevealByTarget = {
						"customDict",
						"onPvp2RevealByTargetDelete"
					}
				}
			}
		},
		ClientMiniGameEntity = {
			NameSpace = "Entities.SpaceEntities.ClientMiniGameEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientMmoItem = {
			NameSpace = "Entities.SpaceEntities.ClientMmoItem",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_LevelItemClientMsg = {
					"string",
					"string",
					"table"
				}
			}
		},
		ClientNpcDuelDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientNpcDuelDungeon",
			Properties = {
				npcDuelBotEntityId = {
					"string",
					"",
					"AllClients",
					"NPER"
				}
			},
			PropertyCallbacks = {
				changed = {
					npcDuelDefeatedBotPetCount = {
						"number",
						"onNpcDuelDefeatedBotPetCountChanged"
					}
				}
			}
		},
		ClientPartUnit = {
			NameSpace = "Entities.SpaceEntities.ClientPartUnit",
			Properties = {}
		},
		ClientPet = {
			NameSpace = "Entities.SpaceEntities.ClientPet",
			TickInterval = 0.1,
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_TestFunc = {
					"number"
				},
				RPC_SC_BeforePetChangeTemplate = {
					"number"
				},
				RPC_SC_AfterPetChangeTemplate = {
					"number"
				},
				PRC_SC_SetPetPos = {
					"table",
					"table"
				},
				RPC_SC_ListenShapeShiftModelRefreshed = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					maxHp = {
						"number",
						"on_maxHp_changed"
					},
					curHp = {
						"number",
						"on_curHp_changed"
					},
					isSummon = {
						"boolean",
						"on_isSummon_changed"
					},
					isInControl = {
						"boolean",
						"onIsInControlChange"
					},
					level = {
						"number",
						"on_level_changed"
					},
					inShapeShift = {
						"boolean",
						"onShapeShiftChange"
					},
					shinyStyle = {
						"number",
						"onShinyStyleChange"
					}
				}
			}
		},
		ClientPetBallEntity = {
			NameSpace = "Entities.SpaceEntities.ClientPetBallEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientPetGhost = {
			NameSpace = "Entities.SpaceEntities.ClientPetGhost",
			TickInterval = 0.1,
			Properties = {},
			PropertyCallbacks = {
				changed = {
					isInControl = {
						"boolean",
						"onIsInControlChange"
					}
				}
			}
		},
		ClientPhase = {
			NameSpace = "Entities.SpaceEntities.ClientPhase",
			Properties = {}
		},
		ClientPlayer = {
			NameSpace = "Entities.SpaceEntities.ClientPlayer",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_PuppetSpeciesInfo = {
					"int",
					"table"
				},
				RPC_SC_NotifyFromTeleportPos = {},
				RPC_SC_PortalClaimPlayers = {
					"number"
				},
				RPC_SC_PortalPreparePlayers = {
					"string"
				}
			},
			PropertyCallbacks = {
				changed = {
					isGhostFollow = {
						"boolean",
						"on_isGhostFollow_changed"
					},
					curHp = {
						"number",
						"on_curHp_changed"
					},
					gameVoteOpen = {
						"number",
						"onGameVoteOpenCallback"
					},
					followLeaderUid = {
						"string",
						"onFollowLeaderUid"
					}
				}
			}
		},
		ClientPlayerGhost = {
			NameSpace = "Entities.SpaceEntities.ClientPlayerGhost",
			TickInterval = 0.1,
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnControlToFollow = {
					"int",
					"table",
					"int",
					"string",
					"string"
				},
				RPC_SC_OnSwithToSingle = {
					"int",
					"table",
					"string"
				},
				RPC_SC_OnSwitchToControll = {
					"int",
					"table",
					"string",
					"string"
				},
				RPC_SC_OnControlToControl = {
					"int",
					"table",
					"int",
					"int",
					"string",
					"string"
				},
				RPC_SC_OnSingleToFollow = {
					"int",
					"table",
					"string"
				}
			}
		},
		ClientPuppet = {
			NameSpace = "Entities.SpaceEntities.ClientPuppet",
			TickInterval = 0.1,
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_BossMechanismIconFlash = {}
			},
			PropertyCallbacks = {
				changed = {
					bornPosition_x = {
						"number",
						"on_bornPosition_x_changed"
					},
					bornPosition_y = {
						"number",
						"on_bornPosition_y_changed"
					},
					bornPosition_z = {
						"number",
						"on_bornPosition_z_changed"
					},
					curHp = {
						"number",
						"on_curHp_changed"
					},
					bossMechanismIconMax = {
						"number",
						"on_bossMechanismIconMax_changed"
					},
					bossMechanismIconProgress = {
						"number",
						"on_bossMechanismIconProgress_changed"
					},
					level = {
						"number",
						"on_level_changed"
					},
					slavesOwnerId = {
						"string",
						"onSlavesOwnerIdChanged"
					}
				}
			}
		},
		ClientPuppetGhost = {
			NameSpace = "Entities.SpaceEntities.ClientPuppetGhost",
			Properties = {}
		},
		ClientPveDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientPveDungeon",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ShowStage = {
					"int",
					"int"
				},
				RPC_SC_ConfirmContinueDungeon = {
					"table"
				}
			}
		},
		ClientPvpBotPlayer = {
			NameSpace = "Entities.SpaceEntities.ClientPvpBotPlayer",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientPvpDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientPvpDungeon",
			Properties = {}
		},
		ClientResPointEntity = {
			NameSpace = "Entities.SpaceEntities.ClientResPointEntity",
			Properties = {}
		},
		ClientResourceBox = {
			NameSpace = "Entities.SpaceEntities.ClientResourceBox",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					isOpened = {
						"boolean",
						"on_isOpened_changed"
					},
					openingUid = {
						"string",
						"onOpeningUidChange"
					},
					openProgress = {
						"number",
						"onOpenProgressChange"
					}
				}
			}
		},
		ClientRobEggCollectItem = {
			NameSpace = "Entities.SpaceEntities.ClientRobEggCollectItem",
			Properties = {}
		},
		ClientRobEggDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientRobEggDungeon",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_BloomDropItems = {
					"table"
				},
				RPC_SC_RobEggWeatherChanged = {
					"int",
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					escapeStage = {
						"number",
						"on_escapeStage_changed"
					}
				}
			}
		},
		ClientRobEggLimitPillar = {
			NameSpace = "Entities.SpaceEntities.ClientRobEggLimitPillar",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					limitPillarState = {
						"number",
						"onLimitPillarStateChange"
					},
					isInitiative = {
						"boolean",
						"onIsInitiativeChange"
					}
				}
			}
		},
		ClientRobEggLimitTimePortal = {
			NameSpace = "Entities.SpaceEntities.ClientRobEggLimitTimePortal",
			Properties = {}
		},
		ClientRobEggUnderGroundPlace = {
			NameSpace = "Entities.SpaceEntities.ClientRobEggUnderGroundPlace",
			Properties = {
				useAfterViewLimitFog = {
					"boolean",
					false,
					"AllClients",
					"NPER"
				}
			},
			PropertyCallbacks = {
				changed = {
					useAfterViewLimitFog = {
						"boolean",
						"on_useAfterViewLimitFog_changed"
					},
					escapeStage = {
						"number",
						"on_escapeStage_changed"
					}
				}
			}
		},
		ClientRobSpaceEgg = {
			NameSpace = "Entities.SpaceEntities.ClientRobSpaceEgg",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_RobEggForceSetPosition = {
					"number",
					"number",
					"number"
				}
			},
			PropertyCallbacks = {
				changed = {
					controller = {
						"string",
						"onControllerChange"
					},
					neverControlled = {
						"boolean",
						"onNeverControlledChange"
					},
					crackLevel = {
						"number",
						"onCrackLevelChange"
					}
				}
			}
		},
		ClientRogueDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientRogueDungeon",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ChallengeResult = {
					"boolean",
					"int"
				},
				RPC_SC_ShowSelectBuff = {
					"table",
					"int",
					"int",
					"int"
				},
				RPC_SC_ShowRandomBuff = {
					"int"
				}
			}
		},
		ClientSingleWorld = {
			NameSpace = "Entities.SpaceEntities.ClientSingleWorld",
			Properties = {}
		},
		ClientSoulEggEvolutionEntity = {
			NameSpace = "Entities.SpaceEntities.ClientSoulEggEvolutionEntity",
			Properties = {}
		},
		ClientSpace = {
			NameSpace = "Entities.SpaceEntities.ClientSpace",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnGameTimeScaleChange = {
					"float",
					"float",
					"int",
					"float"
				},
				RPC_SC_EcsUploadResult = {
					"table"
				},
				RPC_SC_EcsStateChanges = {
					"table"
				},
				RPC_SC_EcsFullState = {
					"table"
				},
				RPC_SC_EcsAuthorityChanged = {
					"table"
				},
				RPC_SC_ShowNoticeMessage = {
					"int"
				},
				RPC_SC_OnRefreshNoticeId = {
					"int",
					"boolean"
				},
				RPC_SC_SetMultiPlayerEnv = {
					"boolean"
				},
				RPC_SC_AddTimeZone = {
					"table"
				},
				RPC_SC_RemoveTimeZone = {
					"int"
				},
				RPC_SC_OnSpaceAuthorityIdChanged = {
					"string"
				},
				RPC_SC_CallCustomEvent = {
					"string",
					"string",
					"table"
				},
				RPC_SC_RemoteSyncAIAction = {
					"string",
					"string",
					"table"
				},
				RPC_SC_SpawnerLeaderInfo = {
					"table",
					"string",
					"table"
				},
				RPC_SC_ActArkCarnPutFireworks = {
					"string",
					"table"
				},
				RPC_SC_SpawnerDestroyFadeOut = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					dungeonId = {
						"number",
						"onDungeonIdChanged"
					},
					observerList = {
						"customDict",
						"on_observerList_changed"
					},
					requestedGameTimeScale = {
						"number",
						"on_requestedGameTimeScale_changed"
					}
				}
			}
		},
		ClientSpellField = {
			NameSpace = "Entities.SpaceEntities.ClientSpellField",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_CreateStartTimeline = {
					"number"
				}
			}
		},
		ClientStaticNpc = {
			NameSpace = "Entities.SpaceEntities.ClientStaticNpc",
			Properties = {}
		},
		ClientTown = {
			NameSpace = "Entities.SpaceEntities.ClientTown",
			Properties = {}
		},
		ClientVirtualAIEntity = {
			NameSpace = "Entities.SpaceEntities.ClientVirtualAIEntity",
			TickInterval = 0.1,
			Properties = {}
		},
		ClientWeeklyDungeon = {
			NameSpace = "Entities.SpaceEntities.ClientWeeklyDungeon",
			Properties = {}
		},
		ClientGamePlayDitto = {
			NameSpace = "Entities.SpaceEntities.GamePlayClass.ClientGamePlayDitto",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					status = {
						"number",
						"on_status_changed"
					},
					puppetIds = {
						"customList",
						"on_puppetIds_changed"
					}
				}
			}
		},
		ClientGamePlayDittoDungeon = {
			NameSpace = "Entities.SpaceEntities.GamePlayClass.ClientGamePlayDittoDungeon",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					status = {
						"number",
						"on_status_changed"
					},
					endTime = {
						"number",
						"on_endTime_changed"
					}
				}
			}
		},
		ClientGamePlayEntity = {
			NameSpace = "Entities.SpaceEntities.GamePlayClass.ClientGamePlayEntity",
			Properties = {}
		},
		ClientGamePlayPetChallenge = {
			NameSpace = "Entities.SpaceEntities.GamePlayClass.ClientGamePlayPetChallenge",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ActiveChallenge = {
					"boolean",
					"float"
				}
			},
			PropertyCallbacks = {
				changed = {
					result = {
						"number",
						"on_result_changed"
					},
					actived = {
						"boolean",
						"on_actived_changed"
					}
				}
			}
		},
		ClientGamePlayRacingTemple = {
			NameSpace = "Entities.SpaceEntities.GamePlayClass.ClientGamePlayRacingTemple",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_StartCountDown = {},
				RPC_SC_FinishRacing = {
					"string",
					"float",
					"float"
				},
				RPC_SC_OnStageChange = {
					"int"
				}
			},
			PropertyCallbacks = {
				changed = {
					status = {
						"number",
						"onStatusChange"
					},
					startTime = {
						"number",
						"onStartTimeChange"
					},
					recordTime = {
						"number",
						"onRecordChange"
					}
				}
			}
		},
		ClientGamePlayRift = {
			NameSpace = "Entities.SpaceEntities.GamePlayClass.ClientGamePlayRift",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					endTime = {
						"number",
						"on_endTime_changed"
					},
					actived = {
						"boolean",
						"on_actived_changed"
					},
					status = {
						"number",
						"on_status_changed"
					},
					riftLevelId = {
						"number",
						"on_riftLevel_changed"
					}
				}
			}
		},
		ClientHomeCar = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomeCar",
			Properties = {}
		},
		ClientHomeCarBench = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomeCarBench",
			Properties = {}
		},
		ClientHomeCarBoard = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomeCarBoard",
			Properties = {}
		},
		ClientHomeCarOrnamentBase = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomeCarOrnamentBase",
			Properties = {}
		},
		ClientHomeCarOrnamentEntity = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomeCarOrnamentEntity",
			Properties = {}
		},
		ClientHomeCarTemplateEntity = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomeCarTemplateEntity",
			Properties = {}
		},
		ClientHomelandDisplayCar = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomelandDisplayCar",
			Properties = {}
		},
		ClientVirtualHomeCar = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientVirtualHomeCar",
			Properties = {}
		},
		ClientVirtualHomeCarDecoration = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientVirtualHomeCarDecoration",
			Properties = {}
		},
		ClientEditorGroupPlaceEntity = {
			NameSpace = "Entities.SpaceEntities.Home.ClientEditorGroupPlaceEntity",
			Properties = {}
		},
		ClientEditorMutiEditGroupEntity = {
			NameSpace = "Entities.SpaceEntities.Home.ClientEditorMutiEditGroupEntity",
			Properties = {}
		},
		ClientEditorTemplateEntity = {
			NameSpace = "Entities.SpaceEntities.Home.ClientEditorTemplateEntity",
			Properties = {}
		},
		ClientEditorTemplateGroupEntity = {
			NameSpace = "Entities.SpaceEntities.Home.ClientEditorTemplateGroupEntity",
			Properties = {}
		},
		ClientHomeBench = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeBench",
			Properties = {}
		},
		ClientHomeEditorTemplateEntity = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeEditorTemplateEntity",
			Properties = {}
		},
		ClientHomeEntity = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeEntity",
			Properties = {}
		},
		ClientHomeEntityBase = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeEntityBase",
			Properties = {}
		},
		ClientHomeEnvObject = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeEnvObject",
			Properties = {}
		},
		ClientHomeFacility = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeFacility",
			Properties = {}
		},
		ClientHomeFacilityHatchBox = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeFacilityHatchBox",
			Properties = {}
		},
		ClientHomeFacilityVehicle = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeFacilityVehicle",
			Properties = {}
		},
		ClientHomeFurnitureStoreEntity = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeFurnitureStoreEntity",
			Properties = {}
		},
		ClientHomeStaticEntity = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeStaticEntity",
			Properties = {}
		},
		ClientHomeStaticNpc = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeStaticNpc",
			Properties = {}
		},
		ClientHomeWishingStar = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeWishingStar",
			Properties = {}
		},
		ClientSpaceFurniture = {
			NameSpace = "Entities.SpaceEntities.SpaceFurniture.ClientSpaceFurniture",
			Properties = {}
		},
		ClientSpaceFurnitureVehicle = {
			NameSpace = "Entities.SpaceEntities.SpaceFurniture.ClientSpaceFurnitureVehicle",
			Properties = {}
		},
		ClientBalloon = {
			NameSpace = "Entities.SpaceEntities.VehicleEntities.ClientBalloon",
			Properties = {}
		},
		ClientBench = {
			NameSpace = "Entities.SpaceEntities.VehicleEntities.ClientBench",
			Properties = {}
		},
		ClientBonfire = {
			NameSpace = "Entities.SpaceEntities.VehicleEntities.ClientBonfire",
			Properties = {}
		},
		ClientBubble = {
			NameSpace = "Entities.SpaceEntities.VehicleEntities.ClientBubble",
			Properties = {}
		},
		ClientDandelion = {
			NameSpace = "Entities.SpaceEntities.VehicleEntities.ClientDandelion",
			Properties = {}
		},
		ClientSeesaw = {
			NameSpace = "Entities.SpaceEntities.VehicleEntities.ClientSeesaw",
			Properties = {}
		},
		ClientSwing = {
			NameSpace = "Entities.SpaceEntities.VehicleEntities.ClientSwing",
			Properties = {}
		},
		ClientVehicle = {
			NameSpace = "Entities.SpaceEntities.VehicleEntities.ClientVehicle",
			Properties = {}
		}
	},
	Components = {
		IAnimationComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IAnimationComponent",
			Properties = {}
		},
		IBaseCombatComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IBaseCombatComponent",
			Properties = {}
		},
		IBaseOpComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IBaseOpComponent",
			Properties = {}
		},
		IBasePropertyComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IBasePropertyComponent",
			Properties = {}
		},
		IBaseStateMachineComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IBaseStateMachineComponent",
			Properties = {},
			ComponentMethod = {
				onInit = true,
				onRelease = true
			}
		},
		IBotPlayerCombatComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IBotPlayerCombatComponent",
			Properties = {}
		},
		IBotPlayerStateMachineComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IBotPlayerStateMachineComponent",
			Properties = {},
			ComponentMethod = {
				onResumeAgent = true,
				onStartAgent = true
			}
		},
		ICameraComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.ICameraComponent",
			Properties = {}
		},
		IClimbComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IClimbComponent",
			Properties = {}
		},
		IFlyComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IFlyComponent",
			Properties = {}
		},
		IGroundComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IGroundComponent",
			Properties = {}
		},
		IHomeLandComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IHomeLandComponent",
			Properties = {}
		},
		IMimicryComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IMimicryComponent",
			Properties = {}
		},
		IMoveComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IMoveComponent",
			Properties = {},
			ComponentMethod = {
				onInit = true,
				onRelease = true
			}
		},
		IParmonPlanComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IParmonPlanComponent",
			Properties = {}
		},
		IPerceptibilityComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IPerceptibilityComponent",
			Properties = {}
		},
		IPetAnimationComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IPetAnimationComponent",
			Properties = {}
		},
		IPetCombatComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IPetCombatComponent",
			Properties = {}
		},
		IPetMoveComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IPetMoveComponent",
			Properties = {}
		},
		IPetStateMachineComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IPetStateMachineComponent",
			Properties = {},
			ComponentMethod = {
				onResumeAgent = true,
				onStartAgent = true
			}
		},
		IPhysicsComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IPhysicsComponent",
			Properties = {}
		},
		IPuppetCombatComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IPuppetCombatComponent",
			Properties = {}
		},
		IPuppetStateMachineComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IPuppetStateMachineComponent",
			Properties = {},
			ComponentMethod = {
				onResumeAgent = true,
				onStartAgent = true
			}
		},
		IResPointComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IResPointComponent",
			Properties = {}
		},
		ISneakComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.ISneakComponent",
			Properties = {}
		},
		IUtilsComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IUtilsComponent",
			Properties = {},
			ComponentMethod = {
				onInit = true,
				onRelease = true
			}
		},
		IVoxelComponent = {
			NameSpace = "Common.AI.BehaviacAgent.Unit.IVoxelComponent",
			Properties = {}
		},
		AIComponent = {
			NameSpace = "Common.Components.AIComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_PauseBtGM = {},
				RPC_SC_ResumeBtGM = {},
				RPC_SC_PauseBt = {
					"int"
				},
				RPC_SC_ResumeBt = {
					"int"
				},
				RPC_SC_AIEvent = {
					"string",
					"table"
				}
			},
			ClientOnlyMsg = {
				RPC_CS_TriggerBlueprint = {
					"string"
				}
			},
			ComponentMethod = {
				EVENT_EnterScene = true,
				EVENT_OnAuthorityChanged = true,
				EVENT_OnAnimatorReady = true,
				EVENT_OnVoxelRegionChanged = true,
				onActionMaskChange = true,
				notifyBuffTagChange = true,
				onLifeRevival = true,
				EVENT_OnLifeDead = true,
				onLeaveCombat = true,
				onEnterCombat = true,
				afterPetChangeTemplate = true,
				beforePetChangeTemplate = true,
				EVENT_OnModelScaleChanged = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_OnExitVehicle = true,
				EVENT_OnEnterVehicle = true,
				onSkeletonUnloaded = true,
				onSkeletonLoaded = true,
				EVENT_ConfigDataChange = true,
				EVENT_OnHideShowEntityDictChange = true,
				Event_OnJoinTeam = true,
				Event_OnLeaveTeam = true,
				onAIStateChange = true,
				onEnterAfkMode = true,
				onExitAfkMode = true,
				onAIPlanFinish = true,
				EVENT_CancelTrapped = true,
				EVENT_BeTrapped = true,
				EVENT_PostReload = true,
				EVENT_onRemoveAbility = true,
				EVENT_onAddAbility = true,
				EVENT_OnEntityBeDetached = true,
				EVENT_OnEntityBeAttached = true,
				EVENT_BeUnStick = true,
				EVENT_BeStick = true,
				EVENT_LoseControlled = true,
				EVENT_Before_BeControlled = true,
				onPetUnSummon = true,
				onPetSummon = true,
				onLeaveSpace = true,
				onEnterSpace = true,
				EVENT_ResetScene = true,
				EVENT_LeaveScene = true
			},
			PropertyCallbacks = {
				changed = {
					isPauseBt = {
						"boolean",
						"on_isPauseBt_changed"
					}
				}
			}
		},
		AIGroupBehaviorComponent = {
			NameSpace = "Common.Components.AIGroupBehaviorComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_CancelTrapped = true,
				EVENT_BeTrapped = true,
				onAIPlanFinish = true,
				onAIStateChange = true,
				onLockTargetChange = true,
				onAIPlanInit = true
			},
			PropertyCallbacks = {
				changed = {
					attackTargetActorId = {
						"number",
						"on_attackTargetActorId_changed"
					}
				}
			}
		},
		AIGroupCombatComponent = {
			NameSpace = "Common.Components.AIGroupCombatComponent",
			Properties = {},
			ComponentMethod = {
				onMultiPlayerEnvChanged = true,
				onLeaveSpace = true,
				onEnterSpace = true,
				onLockTargetChange = true
			}
		},
		AIPlanComponent = {
			NameSpace = "Common.Components.AIPlanComponent",
			Properties = {},
			ComponentMethod = {
				onJoinGroupBehaviourFinish = true,
				onAIStateChangeLater = true,
				onAIDestroyAgent = true,
				onAIResumeAgent = true,
				onAIPauseAgent = true,
				onAIStartAgent = true,
				onAICreateAgent = true,
				onExitGroupBehaviourFinish = true,
				EVENT_OnHit = true,
				notifyBuffTagChange = true,
				EVENT_PostReload = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_OnReachImpulseThreshold = true,
				onAIStateChange = true,
				EVENT_OnEcsStateChange = true,
				EVENT_onAudioBgmEventCallback = true,
				onAIPlanFinish = true
			}
		},
		AIPlanDynamicComponent = {
			NameSpace = "Common.Components.AIPlanDynamicComponent",
			Properties = {},
			ComponentMethod = {
				onJoinGroupBehaviourFinish = true,
				EVENT_OnCharacterStateChange = true,
				onAIDestroyAgent = true,
				onAIResumeAgent = true,
				onAIPauseAgent = true,
				onAIStartAgent = true,
				onAIStateChange = true,
				onExitGroupBehaviourFinish = true
			}
		},
		AbilityComponent = {
			NameSpace = "Common.Components.AbilityComponent",
			Properties = {},
			ComponentMethod = {
				notifyBuffTagChange = true,
				onLeaveSpace = true,
				onEnterSpace = true
			}
		},
		AdditiveAIComponent = {
			NameSpace = "Common.Components.AdditiveAIComponent",
			Properties = {},
			ComponentMethod = {
				onAIStateChange = true,
				EVENT_OnCharacterStateChange = true,
				onAIDestroyAgent = true,
				onAIResumeAgent = true,
				onAIPauseAgent = true,
				onAIStartAgent = true,
				EVENT_PostReload = true
			}
		},
		AutoPathFindComponent = {
			NameSpace = "Common.Components.AutoPathFindComponent",
			Properties = {}
		},
		CharacterController = {
			NameSpace = "Common.Components.CharacterController",
			Properties = {},
			ComponentMethod = {
				EVENT_OnActiveChange = true
			}
		},
		MagicFieldComponentBase = {
			NameSpace = "Common.Components.MagicFieldComponentBase",
			Properties = {},
			ComponentMethod = {
				getCustomClientDict = true
			}
		},
		PerceptibilityComponent = {
			NameSpace = "Common.Components.PerceptibilityComponent",
			Properties = {
				perceivedValuePercent = {
					"double",
					0,
					"AllClients",
					"NPER"
				},
				perceivedActorId = {
					"int",
					0,
					"AllClients",
					"NPER"
				},
				perceivedValue = {
					"int",
					0,
					"AllClients",
					"NPER"
				}
			},
			ServerOnlyMsg = {
				RPC_SC_PausePerceptionGM = {},
				RPC_SC_ResumePerceptionGM = {}
			},
			ComponentMethod = {
				EVENT_CancelTrapped = true,
				EVENT_BeTrapped = true,
				EVENT_PostReload = true,
				onAIResumeAgent = true,
				onAIPauseAgent = true,
				onAIStartAgent = true,
				EVENT_PerceptibilitySearchEntityChanged = true,
				EVENT_OnAuthorityChanged = true,
				onLeaveTrap = true,
				onEnterTrap = true,
				onAIStateChange = true,
				onLeaveSpace = true,
				onEnterSpace = true
			},
			PropertyCallbacks = {
				changed = {
					perceivedValuePercent = {
						"number",
						"on_perceivedValuePercent_changed"
					}
				}
			}
		},
		PerceptibilityResponseComponent = {
			NameSpace = "Common.Components.PerceptibilityResponseComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_onControlPetSwitchToPlayer = true,
				EVENT_onControlPetSwitchToAnotherPet = true
			}
		},
		StaminaComponent = {
			NameSpace = "Common.Components.StaminaComponent",
			Properties = {}
		},
		StateCheckComponent = {
			NameSpace = "Common.Components.StateCheckComponent",
			Properties = {},
			ComponentMethod = {
				onEnterSpace = true,
				onLeaveSpace = true
			}
		},
		ClientAvatarMsCommon = {
			NameSpace = "Core.Client.Components.ClientAvatarMsCommon",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					msAuth = {
						"string",
						"on_msAuth_changed"
					}
				}
			}
		},
		MsServiceComponent = {
			NameSpace = "Core.MicroService.Components.MsServiceComponent",
			Properties = {}
		},
		ClientRealPropertyComponent = {
			NameSpace = "Core.PropertySync.ClientRealPropertyComponent",
			Properties = {},
			EngineMsg = {
				_Engine_onPropertyFrameSync = {
					"string",
					"table"
				}
			}
		},
		RealPropertyComponent = {
			NameSpace = "Core.PropertySync.RealPropertyComponent",
			Properties = {}
		},
		ClientAbilityComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientAbilityComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SyncForceBipRotation = {
					"boolean",
					"float",
					"float",
					"float",
					"float"
				},
				RPC_SC_OnSkillHookWait = {
					"float",
					"float",
					"float"
				},
				RPC_SC_OnSkillHookSuccess = {
					"float",
					"float",
					"float",
					"int"
				},
				RPC_SC_OnSkillHookFail = {},
				RPC_SC_OnSkillHookEnd = {},
				RPC_SC_OnSkillHookExit = {},
				RPC_SC_DoAction = {
					"number",
					"number",
					"table"
				},
				RPC_SC_NotifyReceiveDamage = {
					"string",
					"number",
					"table"
				},
				RPC_SC_SetBasicTimeline = {
					"int",
					"float"
				},
				RPC_SC_SetCombatActionTimeline = {
					"int",
					"float",
					"table"
				},
				RPC_SC_SetHitActionTimeline = {
					"int",
					"float",
					"table"
				},
				RPC_SC_StopActionTimeline = {
					"string",
					"int"
				},
				RPC_SC_JumpToNextTimeline = {
					"string",
					"int",
					"int"
				},
				RPC_SC_ChangeDynamicListMap = {
					"string",
					"table"
				},
				RPC_SC_Octopus_State = {
					"string",
					"boolean",
					"number"
				},
				RPC_SC_StopTimelineByTime = {
					"number",
					"number"
				},
				RPC_SC_OnOldPetBeSwitched = {
					"number"
				},
				RPC_SC_OnSwitchToNewPet = {},
				RPC_SC_ShowDamageNumber = {
					"number",
					"number",
					"number",
					"number",
					"number",
					"table",
					"number",
					"table",
					"number",
					"table"
				},
				RPC_SC_StopCombatActionTimeline = {},
				RPC_SC_SetAttribute = {
					"int",
					"double"
				},
				RPC_SC_CastAbilityByServer = {
					"int",
					"int",
					"int"
				},
				RPC_SC_CastAbilityOnTarget = {
					"int",
					"int",
					"int"
				},
				RPC_SC_CastAbilityOnPosRot = {
					"int",
					"table",
					"table",
					"int"
				},
				RPC_SC_AddProjectile = {
					"table"
				},
				RPC_SC_ProjectileReset = {
					"table"
				},
				RPC_SC_DestroyAllProjectile = {},
				RPC_SC_NotifyStopCharge = {
					"number",
					"number"
				},
				RPC_SC_ForceDisplacement = {
					"table",
					"number",
					"number",
					"boolean",
					"number",
					"number",
					"table"
				},
				RPC_SC_ForceDisplacementSelf = {
					"table",
					"table",
					"number",
					"number",
					"boolean",
					"number"
				},
				RPC_SC_StopForceDisplacement = {},
				RPC_SC_SkillScrollHitTarget = {
					"table",
					"table",
					"table"
				},
				RPC_SC_SetIsMonsterAbilityMode = {
					"boolean"
				},
				RPC_SC_NotifyKeyFrameBackswing = {
					"int"
				},
				RPC_SC_UpdateBuffInheritStates = {
					"table"
				},
				RPC_SC_BuffStartThink = {
					"number",
					"number",
					"number"
				},
				RPC_SC_StopThink = {
					"number"
				},
				RPC_SC_AttackHpZero = {
					"number"
				},
				RPC_SC_AddRandomTimer = {
					"number",
					"table",
					"table"
				},
				RPC_SC_SetAbilityCacheValKey2 = {
					"number",
					"number",
					"string",
					"string",
					"table"
				},
				RPC_SC_SetIsPetShareDmg = {
					"boolean"
				},
				RPC_SC_SetIsPetLinkHeal = {
					"boolean"
				},
				RPC_SC_ShowEpNumber = {
					"number"
				},
				RPC_SC_ShowPetHealEffect = {
					"string"
				},
				RPC_SC_OnPawnMovedDistanceReachThreshold = {},
				RPC_SC_SyncEnableAbilityCheck = {
					"boolean"
				},
				RPC_SC_ContinueTimelineByCombo = {
					"int",
					"int"
				},
				RPC_SC_TeleportBySnapshot = {
					"double",
					"double",
					"double"
				},
				RPC_SC_GenRandomIntForAsyncActions = {
					"number",
					"number",
					"string",
					"number",
					"string"
				},
				RPC_SC_NotifyClientCustomEvent = {
					"string",
					"table"
				},
				RPC_SC_OnTargetAttachToSelf = {
					"int"
				},
				RPC_SC_StopBurrowByHit = {},
				RPC_SC_SetAppearDash = {
					"boolean"
				},
				RPC_SC_OnBuffRefresh = {
					"number"
				},
				RPC_SC_RePressSkillSlot = {
					"number"
				},
				RPC_SC_OnSkillMotionStateChange = {
					"table",
					"string",
					"boolean"
				},
				RPC_SC_LeaveAppearDash = {},
				RPC_SC_KeepChainBurstDamage = {
					"number"
				},
				RPC_SC_OnEnterSpecialRideMode = {
					"int"
				},
				RPC_SC_OnForceLeaveSpecialRideMode = {},
				RPC_SC_ReboundDashHitActor = {
					"number",
					"table"
				},
				RPC_SC_ReboundDashEnd = {},
				RPC_CS_MoveByDirectionEnd = {
					"string",
					"table"
				},
				RPC_SC_AttachToEntity = {
					"number",
					"table",
					"table",
					"number"
				},
				RPC_SC_DetachFromEntity = {
					"number"
				},
				RPC_SC_DoTagReaction = {
					"number",
					"table",
					"number"
				},
				RPC_SC_SyncCombatContextTarget = {
					"number",
					"number"
				},
				RPC_SC_StartWaterBeAbsorb = {
					"table",
					"number",
					"number",
					"string"
				},
				RPC_SC_NotifyPlayAbilityAnimation = {
					"int"
				},
				RPC_SC_DoTeamExtremeChainActions = {
					"int",
					"int",
					"int",
					"int"
				},
				RPC_SC_LaunchProjAroundSelf = {
					"int",
					"table"
				},
				RPC_SC_ForceSetAuthority = {
					"int"
				},
				RPC_SC_FastForwardTimeline = {
					"number",
					"number"
				},
				RPC_SC_DisableReturnAbilityConsumes = {
					"number"
				}
			},
			ComponentMethod = {
				onSkillSwitched = true,
				EVENT_BeTrapped = true,
				onSeamlessPostEnterSpace = true,
				onLeaveSpace = true,
				onPetSummon = true,
				EVENT_OnModelRefreshed = true,
				EVENT_OnEntityBeAttached = true,
				onActionMaskChange = true,
				EVENT_LoseControlled = true,
				onPetUnSummon = true,
				onLeaveCombat = true,
				onEnterCombat = true,
				onEnterSpace = true,
				EVENT_OnModelScaleChanged = true,
				EVENT_OnCharacterStateChange = true,
				onSkeletonUnloaded = true,
				removeBuffEvent = true,
				addBuffEvent = true,
				EVENT_OnEntityCacheValChanged = true,
				onContinuousButtonQteHit = true,
				onTakeDamage = true
			},
			PropertyCallbacks = {
				itemInserted = {
					buffDataList = {
						"customList",
						"onAddBuff"
					},
					shieldDataList = {
						"customList",
						"onShieldDataAdd"
					}
				},
				itemRemoved = {
					buffDataList = {
						"customList",
						"onRemoveBuff"
					},
					shieldDataList = {
						"customList",
						"onShieldDataRemove"
					}
				},
				changed = {
					["buffDataList.*.freezeBuffStartTime"] = {
						"number",
						"onBuffFreezeBuffStartTimeChange"
					},
					["buffDataList.*.expiredTime"] = {
						"number",
						"onBuffExpiredTimeChange"
					},
					["buffDataList.*.layer"] = {
						"number",
						"onBuffLayerChange"
					},
					["abilityMap.*.cdEndTime"] = {
						"number",
						"onAbilityCdChange"
					},
					["abilityMap.*.overrideEpCost"] = {
						"number",
						"onAbilityOverrideEpCostChange"
					},
					breakEndTime = {
						"number",
						"onBreakEndTimeChange"
					},
					breakRecoverTime = {
						"number",
						"onBreakRecoverTimeChange"
					},
					unSummonBuffFreezeTime = {
						"number",
						"onUnSummonBuffFreezeTime"
					},
					buffTag = {
						"number",
						"onBuffTagChange"
					},
					buffImmuneTag = {
						"number",
						"onBuffImmuneTagChange"
					},
					knockState = {
						"number",
						"onKnockStateChange"
					},
					isVisibleByAbility = {
						"boolean",
						"onIsVisibleByAbilityChange"
					},
					enableLockTarget = {
						"boolean",
						"onEnableLockTargetChange"
					},
					breakBuffFreezeTime = {
						"number",
						"onBreakBuffFreezeTimeChange"
					},
					breakRecoverFreezeTime = {
						"number",
						"onBreakRecoverFreezeTimeChange"
					},
					curBp = {
						"number",
						"onCurBpChange"
					},
					maxBp = {
						"number",
						"onMaxBpChange"
					},
					isCamouflage = {
						"boolean",
						"onIsCamouflageChange"
					},
					["shieldDataList.*.curPoint"] = {
						"number",
						"on_shieldPoint_changed"
					},
					projAroundSelfCnt = {
						"number",
						"onProjAroundSelfCnt"
					},
					["abilityLoadingMap.*.cnt"] = {
						"number",
						"onLoadedCntChange"
					}
				},
				entryAdded = {
					abilityMap = {
						"customDict",
						"onAddAbility"
					},
					stolenAbilityMap = {
						"customDict",
						"onAddStolenAbility"
					},
					callFriendsAbilityMap = {
						"customDict",
						"onAddCallFriendAbility"
					},
					abilityFreezeMap = {
						"customDict",
						"onAbilityFreezeAdd"
					},
					switchSkillFreezeTimeMap = {
						"customDict",
						"onSwitchSkillFreezeAdd"
					}
				},
				entryDeleted = {
					abilityMap = {
						"customDict",
						"onRemoveAbility"
					},
					stolenAbilityMap = {
						"customDict",
						"onRemoveStolenAbility"
					},
					abilityFreezeMap = {
						"customDict",
						"onAbilityFreezeRemove"
					},
					switchSkillFreezeTimeMap = {
						"customDict",
						"onSwitchSkillFreezeRemove"
					},
					hatredMap = {
						"customDict",
						"on_hatredMap_deleted"
					}
				}
			}
		},
		ClientActorComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientActorComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_UpdateBodyInfo = {
					"number",
					"number"
				}
			},
			ComponentMethod = {
				onEnterSpace = true
			},
			PropertyCallbacks = {
				changed = {
					camp = {
						"number",
						"onCampChange"
					},
					clientVisible = {
						"boolean",
						"onClientVisibleChange"
					}
				}
			}
		},
		ClientAnimationComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientAnimationComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_PlayAnimClip = {
					"string"
				},
				RPC_SC_SyncAnimation = {
					"int"
				}
			},
			ComponentMethod = {
				EVENT_OnEnterVehicle = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_OnCloseUI = true,
				EVENT_TimeScaleChanged = true,
				EVENT_AddEComponent = true,
				EVENT_OnAuthorityChanged = true,
				EVENT_OnExitVehicle = true,
				onSkeletonLoaded = true
			}
		},
		ClientAnimatorComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_AddEComponent = true
			}
		},
		ClientAoiComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientAoiComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_DispatchSpaceMsg = {
					"string",
					"table"
				}
			},
			ComponentMethod = {
				EVENT_EModelCreate = true,
				onMultiPlayerEnvChanged = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_OnHideShowEntityDictChange = true,
				EVENT_EnterScene = true,
				EVENT_OnAuthorityChanged = true,
				EVENT_ResetScene = true
			}
		},
		ClientAppearanceComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientAppearanceComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_AbilityStateChange = true,
				tick = true,
				EVENT_OnModelRefreshed = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_OnExitVehicle = true,
				EVENT_OnEnterVehicle = true,
				EVENT_OnAnimatorReady = true,
				onLeaveCombat = true,
				onEnterCombat = true
			},
			PropertyCallbacks = {
				entryAdded = {
					colorJewelryIds = {
						"customDict",
						"on_color_accessory_unlock"
					},
					jewelryLastInfos = {
						"customDict",
						"on_jewelryLastInfos_add"
					},
					["curShow.hairInfo"] = {
						"customDict",
						"on_curShow_hairInfo_add"
					},
					["curShow.clothesDesigns"] = {
						"customDict",
						"on_curShow_clothesDesign_add"
					}
				},
				changed = {
					["curShow.*.colorJewelryId"] = {
						"number",
						"on_curShow_color_accessory_changed"
					},
					fashionScore = {
						"number",
						"on_fashion_score_changed"
					},
					appearanceBackgrounds = {
						"customDict",
						"on_appearanceBackgrounds_changed"
					},
					avatarConfig = {
						"string",
						"on_avatar_config_changed"
					},
					["jewelryLastInfos.*"] = {
						"string",
						"on_jewelryLastInfos_changed"
					},
					["curShow.customShow.*"] = {
						"number",
						"on_curShow_customShow_changed"
					},
					["curShow.hairInfo.*"] = {
						"string",
						"on_curShow_hairInfo_changed"
					},
					["curShow.clothesDesigns.*"] = {
						"customDict",
						"on_curShow_clothesDesign_changed"
					},
					["curShow.suitId"] = {
						"number",
						"on_curShow_suitId_changed"
					},
					["curShow.isShowBag"] = {
						"boolean",
						"on_curShow_isShowBag_changed"
					}
				},
				entryDeleted = {
					["curShow.hairInfo"] = {
						"customDict",
						"on_curShow_hairInfo_delete"
					},
					["curShow.clothesDesigns"] = {
						"customDict",
						"on_curShow_clothesDesign_delete"
					}
				}
			}
		},
		ClientAreaHandlerComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientAreaHandlerComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_AddEComponent = true
			}
		},
		ClientAttachComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientAttachComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_AttachByConfigId = {
					"number",
					"number"
				},
				RPC_SC_Detach = {}
			},
			ComponentMethod = {
				EVENT_AddEComponent = true
			},
			PropertyCallbacks = {
				changed = {
					attachToStaticId = {
						"number",
						"on_attachToStaticId_changed"
					},
					attachTargetId = {
						"string",
						"on_attachTargetId_changed"
					}
				}
			}
		},
		ClientAudioComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientAudioComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_EModelCreate = true,
				EVENT_AddEComponent = true,
				EVENT_ContactSurfaceVoxelChanged = true,
				onLeaveCombat = true,
				onEnterCombat = true
			}
		},
		ClientAuthorityComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_NotifyNewAuthorityOwnProps = {
					"string",
					"table"
				},
				RPC_SC_NotifyClearAuthorityOwnProps = {
					"string",
					"table"
				}
			},
			ComponentMethod = {
				EVENT_EModelCreate = true,
				onEnterSpace = true
			},
			PropertyCallbacks = {
				changed = {
					authorityId = {
						"string",
						"on_authorityId_changed"
					}
				}
			}
		},
		ClientBallTimelineComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientBallTimelineComponent",
			Properties = {}
		},
		ClientBeCarryComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientBeCarryComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					moveUser = {
						"string",
						"onMoveUserChanged"
					}
				}
			}
		},
		ClientBossSpecialInteractionComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientBossSpecialInteractionComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnBossEnterSpecialRideMode = {
					"int"
				},
				RPC_SC_OnBossSpecialRideModeSuccess = {
					"int"
				},
				RPC_SC_OnBossSpecialRideModeFailed = {
					"int"
				}
			}
		},
		ClientCallFriendsComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientCallFriendsComponent",
			Properties = {},
			ComponentMethod = {
				tick = true,
				EVENT_IsInControlChange = true
			}
		},
		ClientCombatActorPartComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientCombatActorPartComponent",
			Properties = {},
			ComponentMethod = {
				onLeaveSpace = true,
				onEnterSpace = true,
				onSkeletonLoaded = true
			},
			PropertyCallbacks = {
				changed = {
					["actorParts.*"] = {
						"customDict",
						"on_actorParts_changed"
					}
				}
			}
		},
		ClientCombatEntityComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientCombatEntityComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnPlayerNearDead = {
					"int",
					"int"
				},
				RPC_SC_OnPlayerDead = {
					"int",
					"int",
					"int"
				},
				RPC_SC_ShowReviveBlackScreen = {
					"int",
					"int"
				},
				RPC_SC_OnForceTauntLockTarget = {
					"int"
				},
				RPC_SC_OnKillBoss = {
					"int",
					"int",
					"boolean",
					"table"
				}
			},
			ComponentMethod = {
				onLeaveCombat = true,
				EVENT_OnModelRefreshed = true,
				EVENT_OnHit = true,
				onPetUnSummon = true,
				onPetSummon = true,
				onEnterCombat = true,
				onEnterSpace = true,
				onSkeletonLoaded = true
			},
			PropertyCallbacks = {
				changed = {
					exploreRevivePer = {
						"number",
						"onExploreRevivePerChanged"
					},
					bornScale = {
						"number",
						"onBornScaleChange"
					},
					curLoadLevel = {
						"number",
						"onCurLoadLevelChange"
					},
					combatStatus = {
						"number",
						"on_combatStatus_changed"
					},
					elementType = {
						"number",
						"on_elementType_change"
					},
					life = {
						"number",
						"onLifeChange"
					},
					isInCapture = {
						"boolean",
						"onIsInCaptureChange"
					},
					immuneDamageEndTime = {
						"number",
						"onImmuneDamageEndTimeChanged"
					},
					fallenAidEndTime = {
						"number",
						"onFallenAidEndTimeChange"
					},
					gmMode = {
						"number",
						"on_gmMode_changed"
					},
					isTransparent = {
						"boolean",
						"onIsTransparentChange"
					}
				},
				entryAdded = {
					campScanMap = {
						"customDict",
						"onAddScanEffect"
					}
				},
				entryDeleted = {
					campScanMap = {
						"customDict",
						"onRemoveScanEffect"
					}
				}
			}
		},
		ClientCombatViewComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientCombatViewComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					isInGoHome = {
						"boolean",
						"on_isInGoHome_changed"
					}
				}
			}
		},
		ClientDangerBgmComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientDangerBgmComponent",
			Properties = {},
			ComponentMethod = {
				onLeaveTrap = true,
				onLeaveSpace = true,
				onEnterSpace = true,
				onEnterTrap = true
			}
		},
		ClientDummyCloneComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientDummyCloneComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_RefreshPhysx = true
			}
		},
		ClientDyingComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientDyingComponent",
			Properties = {},
			ComponentMethod = {
				onEnterSpace = true,
				onLeaveSpace = true
			}
		},
		ClientDynamicFeatureComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientDynamicFeatureComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_AddFeature = {
					"string",
					"table"
				},
				RPC_SC_RemoveFeature = {
					"string"
				},
				RPC_SC_FeatureMsg = {
					"string",
					"string",
					"table"
				}
			},
			ComponentMethod = {
				EVENT_LoseControlled = true,
				EVENT_OnModelRefreshed = true,
				EVENT_OnLifterIdChanged = true,
				onTakeDamage = true,
				EVENT_OnCharacterStateChange = true,
				onLeaveSpace = true,
				onEnterSpace = true,
				EVENT_onModelLoaded = true
			}
		},
		ClientDynamicVoxelComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientDynamicVoxelComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_CreateDynamicVoxelObject = {
					"int",
					"string",
					"table",
					"table",
					"int",
					"table",
					"number",
					"table",
					"boolean"
				},
				RPC_SC_DestroyDynamicVoxelObject = {
					"int"
				},
				RPC_SC_UpdateDynamicVoxelObject = {
					"int",
					"table",
					"number",
					"table"
				},
				RPC_SC_SetDynamicVoxelObjectEnable = {
					"int",
					"boolean"
				}
			},
			ComponentMethod = {
				destroy = true
			}
		},
		ClientEModelComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientEModelComponent",
			Properties = {}
		},
		ClientEcologyComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientEcologyComponent",
			Properties = {},
			ComponentMethod = {
				onEnterSpace = true
			},
			PropertyCallbacks = {
				entryAdded = {
					entityTag = {
						"customDict",
						"on_entityTag_entry_added"
					}
				},
				entryDeleted = {
					entityTag = {
						"customDict",
						"on_entityTag_entry_deleted"
					}
				},
				changed = {
					["entityTag.*"] = {
						"number",
						"on_entityTag_item_changed"
					}
				}
			}
		},
		ClientEcsComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientEcsComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ApplyECSElement = {
					"int",
					"float",
					"int"
				},
				RPC_SC_ClearElement = {
					"int",
					"int"
				}
			},
			ComponentMethod = {
				EVENT_BeControlled = true,
				EVENT_PostInitialized = true,
				onPetSummon = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_AddEComponent = true,
				onLeaveSpace = true,
				onEnterSpace = true,
				EVENT_onModelLoaded = true
			}
		},
		ClientEggModeComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientEggModeComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_OnActiveChange = true,
				EVENT_OnModelRefreshed = true,
				EVENT_OnPetControlChanged = true,
				onLeaveSpace = true,
				onLeaveTrap = true,
				onEnterTrap = true,
				onEnterSpace = true
			},
			PropertyCallbacks = {
				changed = {
					equipShowInfo = {
						"customDict",
						"on_equipShowInfo_changed"
					},
					chipSkillId = {
						"number",
						"on_chipSkillId_changed"
					},
					eggManTemplateId = {
						"number",
						"onEggManTemplateIdChange"
					},
					controlEggId = {
						"string",
						"onControlEggIdChange"
					},
					curHighGrassId = {
						"number",
						"onCurHighGrassIdChange"
					}
				}
			}
		},
		ClientEntityCacheValComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientEntityCacheValComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SyncEntityCacheValNumber = {
					"string",
					"number"
				},
				RPC_SC_SyncRemoveEntityCacheVal = {
					"string"
				}
			},
			ComponentMethod = {
				EVENT_EnterScene = true
			}
		},
		ClientFKeyInteractBase = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientFKeyInteractBase",
			Properties = {},
			ComponentMethod = {
				onTriggerEnter = true,
				EVENT_OnActiveChange = true,
				EVENT_OnModelVisibleChange = true,
				onTriggerExit = true
			}
		},
		ClientFloorHeightCheckComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientFloorHeightCheckComponent",
			Properties = {}
		},
		ClientHatchBoxComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientHatchBoxComponent",
			Properties = {},
			ComponentMethod = {
				onSkeletonLoaded = true
			}
		},
		ClientHomeCarPetComp = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientHomeCarPetComp",
			Properties = {},
			ComponentMethod = {
				EVENT_InitInteractionList = true
			}
		},
		ClientInanimateNpcInteractComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientInanimateNpcInteractComponent",
			Properties = {}
		},
		ClientInteractComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientInteractComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnInteractStart = {
					"int",
					"string",
					"int",
					"table"
				},
				RPC_SC_OnInteractInterrupt = {
					"int",
					"string",
					"int",
					"table"
				},
				RPC_SC_OnInteractSuccess = {
					"string",
					"int"
				},
				RPC_SC_AppearanceActionRecommend = {
					"int"
				},
				RPC_SC_PlayAppearanceActionResult = {
					"int",
					"string",
					"int"
				},
				RPC_SC_NotifyRewardByOtherOpenChest = {
					"string"
				}
			},
			PropertyCallbacks = {
				changed = {
					["interactAction.interactId"] = {
						"number",
						"on_interactActionInteractId_changed"
					},
					["npcSpecialInteractsMap.*"] = {
						"customList",
						"on_npcSpecialInteractsMapValue_changed"
					}
				},
				entryAdded = {
					npcSpecialInteractsMap = {
						"customDict",
						"on_npcSpecialInteractsMapEntry_added"
					},
					arkChestActived = {
						"customDict",
						"on_arkChestActivedEntry_added"
					}
				},
				entryDeleted = {
					npcSpecialInteractsMap = {
						"customDict",
						"on_npcSpecialInteractsMapEntry_deleted"
					},
					arkChestActived = {
						"customDict",
						"on_arkChestActivedEntry_deleted"
					}
				}
			}
		},
		ClientInteractionComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientInteractionComponent",
			Properties = {},
			ComponentMethod = {
				onTriggerEnter = true
			}
		},
		ClientLODComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientLODComponent",
			Properties = {}
		},
		ClientLiftComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientLiftComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnStartLift = {
					"int",
					"string",
					"int"
				}
			},
			ComponentMethod = {
				EVENT_AddEComponent = true,
				EVENT_LoseControlled = true,
				EVENT_OnAttachBreak = true
			},
			PropertyCallbacks = {
				changed = {
					lifterId = {
						"string",
						"onLifterIdChange"
					},
					liftEntId = {
						"string",
						"onLiftEntIdChange"
					}
				}
			}
		},
		ClientListenerComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientListenerComponent",
			Properties = {}
		},
		ClientLookAtComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientLookAtComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_BeControlled = true,
				EVENT_LoseControlled = true,
				tick = true,
				notifyBuffTagChange = true,
				EVENT_OnAnimatorReady = true
			}
		},
		ClientMagicFieldComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientMagicFieldComponent",
			Properties = {},
			ComponentMethod = {
				onEnterSpace = true
			}
		},
		ClientMagneticComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientMagneticComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SyncPlayMagnesisEffect = {
					"string"
				},
				RPC_SC_SyncStopMagnesisEffect = {
					"string"
				},
				RPC_SC_OnMagnesisThrow = {
					"table"
				}
			}
		},
		ClientMapComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientMapComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_RefreshMapFogCallback = {
					"int",
					"int",
					"table"
				},
				RPC_SC_OnMapMarkStatusChange = {
					"int",
					"int",
					"int",
					"int",
					"int",
					"boolean"
				},
				RPC_SC_OnPoiResult = {
					"int",
					"int",
					"boolean"
				},
				RPC_SC_HideMapFogUI = {
					"boolean"
				},
				RPC_SC_UnlockAllMapArea = {},
				RPC_SC_GetSpaceLineInfoRes = {
					"table"
				}
			},
			ComponentMethod = {
				onEnterSpace = true,
				onLeaveSpace = true
			},
			PropertyCallbacks = {
				changed = {
					mapMarkStatusMap = {
						"customDict",
						"onMapMarkStatusMap_changed"
					},
					["customMapMarkMap.*.*"] = {
						"customDict",
						"onCustomMapMarkMap_changed"
					},
					["customMapMarkMap.*.*.name"] = {
						"string",
						"onCustomMapMarkMapName_valueChanged"
					},
					["mapFogWholeUnlocked.*"] = {
						"boolean",
						"onMapFogWholeUnlocked_valueChanged"
					}
				},
				entryAdded = {
					["customMapMarkMap.*"] = {
						"customDict",
						"onCustomMapMarkMap_entryAdded"
					}
				},
				entryDeleted = {
					["customMapMarkMap.*"] = {
						"customDict",
						"onCustomMapMarkMap_entryDeleted"
					}
				}
			}
		},
		ClientMapTagComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientMapTagComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_BindMapMarkToEntity = {
					"table"
				},
				RPC_SC_UnBindMapMarkToEntity = {
					"table"
				}
			}
		},
		ClientMiniGameCommonComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientMiniGameCommonComponent",
			Properties = {}
		},
		ClientModelBatchComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientModelBatchComponent",
			Properties = {}
		},
		ClientModelComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientModelComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_OnModelScaleChanged = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_OnModelVisibleChange = true,
				EVENT_ContactVoxelChanged = true,
				EVENT_AddEComponent = true,
				EVENT_OnModelRefreshed = true
			}
		},
		ClientModelTransmogComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientModelTransmogComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_OnModelRefreshed = true,
				EVENT_OnMergeAppearanceData = true,
				EVENT_OnAnimatorReady = true,
				EVENT_OnCharacterStateChange = true
			}
		},
		ClientMotionComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientMotionComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_AbilityStateChange = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_BeControlled = true,
				onAIResumeAgent = true,
				onAIPauseAgent = true,
				EVENT_OnEntityBeDetached = true,
				EVENT_OnEntityBeAttached = true,
				EVENT_BeUnStick = true,
				EVENT_BeStick = true,
				EVENT_LoseControlled = true,
				onAIStartAgent = true,
				EVENT_OnLifeDead = true,
				onEnterSpace = true
			}
		},
		ClientNpcAIReactionComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientNpcAIReactionComponent",
			Properties = {},
			ComponentMethod = {
				onLeaveTrap = true,
				onLeaveSpace = true,
				onEnterSpace = true,
				onEnterTrap = true
			}
		},
		ClientNpcComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientNpcComponent",
			Properties = {}
		},
		ClientNpcInteractComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientNpcInteractComponent",
			Properties = {},
			ComponentMethod = {
				NPCINFO_OnAciveChange = true,
				onEnterCombat = true,
				onEnterSpace = true,
				onLeaveSpace = true
			}
		},
		ClientPetAccessoryComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPetAccessoryComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_MergedFormPeripheralStateChange = true,
				Event_BeforeRefreshModels = true,
				EVENT_IsInControlChange = true,
				Event_AfterRefreshModels = true
			},
			PropertyCallbacks = {
				changed = {
					petJewelryInfo = {
						"customDict",
						"on_petJewelryInfo_Changed"
					}
				}
			}
		},
		ClientPetCombatEntityComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPetCombatEntityComponent",
			Properties = {}
		},
		ClientPetInfoComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPetInfoComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					["individuationIds.*"] = {
						"number",
						"on_individuationIds_changed"
					},
					selectTransmogScheme = {
						"customDict",
						"on_selectTransmogScheme_changed"
					}
				},
				entryAdded = {
					individuationIds = {
						"customDict",
						"on_individuationIds_add"
					}
				},
				entryDeleted = {
					individuationIds = {
						"customDict",
						"on_individuationIds_delete"
					}
				}
			}
		},
		ClientPetInteractComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPetInteractComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_PetInteractAction = {
					"int",
					"table"
				}
			}
		},
		ClientPhotoComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPhotoComponent",
			Properties = {},
			ComponentMethod = {
				onLeaveSpace = true
			},
			PropertyCallbacks = {
				entryAdded = {
					["photoPresetInfo.savedIdMap"] = {
						"customDict",
						"onPhotoPresetInfo_SavedIdMap_EntryAdded"
					},
					["photoPresetInfo.likedIdMap"] = {
						"customDict",
						"onPhotoPresetInfo_LikedIdMap_EntryAdded"
					}
				},
				entryDeleted = {
					["photoPresetInfo.savedIdMap"] = {
						"customDict",
						"onPhotoPresetInfo_SavedIdMap_EntryDeleted"
					},
					["photoPresetInfo.likedIdMap"] = {
						"customDict",
						"onPhotoPresetInfo_LikedIdMap_EntryDeleted"
					}
				}
			}
		},
		ClientPhotoIdentifyComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPhotoIdentifyComponent",
			Properties = {},
			ComponentMethod = {
				onTriggerEnter = true,
				onTriggerExit = true
			}
		},
		ClientPhysicsComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_LeaveScene = true,
				EVENT_OnModelRefreshed = true,
				onHomeEventChanged = true,
				startHomeEventReturnCollision = true,
				EVENT_EnterScene = true,
				EVENT_OnAuthorityChanged = true,
				EVENT_RefreshPhysx = true,
				EVENT_AddEComponent = true,
				EVENT_OnLifterIdChanged = true,
				EVENT_onModelLoaded = true
			},
			PropertyCallbacks = {
				changed = {
					["serverPhysicsInfo.rigidBodyState"] = {
						"number",
						"onServerPhysicsInfoRigidBodyStateChanged"
					},
					areaId = {
						"number",
						"on_areaId_changed"
					}
				}
			}
		},
		ClientPlayerObComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPlayerObComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_PlayerEnterObserveMode = {
					"table"
				},
				RPC_SC_ObservedTargetWillTransfer = {},
				RPC_SC_PlayerExitObserveMode = {}
			}
		},
		ClientPosRotComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPosRotComponent",
			Properties = {}
		},
		ClientPrefabModelComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPrefabModelComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_AddEComponent = true,
				EVENT_OnEnterVehicle = true,
				EVENT_OnExitVehicle = true
			}
		},
		ClientPushComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientPushComponent",
			Properties = {}
		},
		ClientRVOComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientRVOComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_AddEComponent = true,
				onLeaveCombat = true,
				EVENT_OnModelVisibleChange = true,
				EVENT_OnAuthorityChanged = true,
				EVENT_OnEntityBeDetached = true,
				EVENT_OnEntityBeAttached = true,
				EVENT_BeUnStick = true,
				EVENT_BeStick = true,
				EVENT_LoseControlled = true,
				onPetUnSummon = true,
				onPetSummon = true,
				onEnterCombat = true,
				onEnterSpace = true,
				EVENT_onModelLoaded = true,
				onHomelandAIPlanChanged = true,
				EVENT_onControlPlayerSwitchToPet = true,
				EVENT_BeControlled = true,
				removeBuffEvent = true,
				addBuffEvent = true,
				EVENT_onControlPetSwitchToPlayer = true
			}
		},
		ClientResPointComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientResPointComponent",
			Properties = {},
			ComponentMethod = {
				onEnterSpace = true,
				onLeaveSpace = true
			}
		},
		ClientSeatComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientSeatComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_OnModelVisibleChange = true,
				EVENT_onModelLoaded = true
			},
			PropertyCallbacks = {
				changed = {
					entityMap = {
						"customDict",
						"on_entityMap_changed"
					},
					entityCount = {
						"number",
						"on_entityCount_changed"
					}
				}
			}
		},
		ClientShadowComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientShadowComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_AddEComponent = true
			}
		},
		ClientSimpleLookAtComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientSimpleLookAtComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_OnModelRefreshed = true,
				onSeamlessPostEnterSpace = true,
				onTriggerExit = true,
				onTriggerEnter = true,
				onLeaveSpace = true,
				EVENT_OnAnimatorReady = true
			}
		},
		ClientSpecialStateRecoverComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientSpecialStateRecoverComponent",
			Properties = {}
		},
		ClientStaminaComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientStaminaComponent",
			Properties = {},
			ComponentMethod = {
				tick = true,
				onLeaveSpace = true,
				onEnterSpace = true
			}
		},
		ClientStaminaOfflineComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientStaminaOfflineComponent",
			Properties = {}
		},
		ClientStateCheckComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientStateCheckComponent",
			Properties = {},
			ComponentMethod = {
				onActionMaskChange = true,
				notifyBuffTagChange = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_BeControlled = true,
				EVENT_OnSpecialAttackModeChange = true,
				onLeaveSpace = true,
				EVENT_OnHit = true
			}
		},
		ClientSubMagnesisComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientSubMagnesisComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SyncPlayerPlayMagnesisEffect = {
					"string"
				},
				RPC_SC_SyncPlayerStopMagnesisEffect = {
					"string"
				}
			}
		},
		ClientSummonHostComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientSummonHostComponent",
			Properties = {}
		},
		ClientSummonedComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientSummonedComponent",
			Properties = {}
		},
		ClientTeamFollowComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientTeamFollowComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_OnPetStart = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_onControlPlayerSwitchToPet = true,
				EVENT_onControlPetSwitchToAnotherPet = true,
				EVENT_OnMoveInputStateChanged = true,
				EVENT_onControlPetSwitchToPlayer = true,
				onSkeletonLoaded = true
			},
			PropertyCallbacks = {
				changed = {
					followState = {
						"number",
						"on_followState_changed"
					}
				}
			}
		},
		ClientTimeControlComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_EModelCreate = true,
				onLeaveSpace = true,
				onEnterSpace = true,
				EVENT_BeControlled = true
			}
		},
		ClientTopLogoComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_ConfigDataChange = true,
				EVENT_OnHit = true,
				EVENT_OnEnterInteractRange = true,
				EVENT_PerceptibilitySearchEntityChanged = true,
				onLeaveCombat = true,
				onEnterCombat = true,
				onEnterSpace = true,
				onSkeletonLoaded = true
			}
		},
		ClientTrapComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientTrapComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_OnLifeDead = true
			}
		},
		ClientTrapEventComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientTrapEventComponent",
			Properties = {},
			ComponentMethod = {
				onTriggerEnter = true,
				onEnterSpace = true,
				onTriggerExit = true
			}
		},
		ClientVehicleOpComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientVehicleOpComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_UpdateVehicleOp = {
					"table"
				}
			},
			ComponentMethod = {
				EVENT_PostInitialized = true
			}
		},
		ClientVisibleComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientVisibleComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_RefreshVisible = true,
				EVENT_PostInitialized = true,
				onEnterSpace = true
			},
			PropertyCallbacks = {
				changed = {
					isHideNpc = {
						"boolean",
						"on_isHideNpc_changed"
					},
					authorAway = {
						"boolean",
						"on_authorAway_changed"
					}
				}
			}
		},
		ClientVoxelComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientVoxelComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_AddEComponent = true,
				onEnterSpace = true,
				EVENT_OnVoxelRegionChanged = true
			}
		},
		ClientWaterStorageComponent = {
			NameSpace = "Entities.SpaceEntities.CommonComponent.ClientWaterStorageComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_onBindBuffChange = true
			}
		},
		ClientCustomEventComponent = {
			NameSpace = "Entities.SpaceEntities.DynamicComponent.ClientCustomEventComponent",
			Properties = {}
		},
		ClientHomeBaseOrnamentComponent = {
			NameSpace = "Entities.SpaceEntities.HomeBaseComponent.ClientHomeBaseOrnamentComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					["ornamentBinaryData.*"] = {
						"string",
						"on_ornament_binary_changed"
					}
				},
				entryAdded = {
					ornamentBinaryData = {
						"customDict",
						"on_ornament_binary_added"
					},
					ornamentSwitchOpenSet = {
						"customDict",
						"on_ornament_switch_open_added"
					}
				},
				entryDeleted = {
					ornamentBinaryData = {
						"customDict",
						"on_ornament_binary_delete"
					},
					ornamentSwitchOpenSet = {
						"customDict",
						"on_ornament_switch_open_delete"
					}
				}
			}
		},
		ClientHomeBasePetsComponent = {
			NameSpace = "Entities.SpaceEntities.HomeBaseComponent.ClientHomeBasePetsComponent",
			Properties = {}
		},
		ClientCampCarOrnamentComponent = {
			NameSpace = "Entities.SpaceEntities.HomeCampComponent.ClientCampCarOrnamentComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					homeBlueprintGroupInfo = {
						"customList",
						"on_homeBlueprintGroupInfo_changed"
					}
				}
			}
		},
		ClientCampCarPetsComponent = {
			NameSpace = "Entities.SpaceEntities.HomeCampComponent.ClientCampCarPetsComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					["dispatchInfo.isFinished"] = {
						"boolean",
						"onDispatchFinishedChanged"
					}
				}
			}
		},
		ClientHomeCarAppearanceComponent = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomeCarAppearanceComponent",
			Properties = {}
		},
		ClientHomeCarEditorComponent = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomeCarEditorComponent",
			Properties = {}
		},
		ClientHomeCarOrnamentComponent = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomeCarOrnamentComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnOrnamentPositionChanged = {}
			},
			ComponentMethod = {
				EVENT_OnAddExtraDebugInfo = true
			},
			PropertyCallbacks = {
				changed = {
					scaleRatios = {
						"customList",
						"on_scaleRatios_changed"
					}
				}
			}
		},
		ClientHomeCarTemplateEditorComponent = {
			NameSpace = "Entities.SpaceEntities.HomeCar.ClientHomeCarTemplateEditorComponent",
			Properties = {}
		},
		ClientEditorTemplateGroupComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientEditorTemplateGroupComponent",
			Properties = {}
		},
		ClientEntityEditorComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientEntityEditorComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_onEntityPositionChanged = true,
				EVENT_onModelLoaded = true,
				EVENT_OnModelVisibleChange = true,
				EVENT_onEntityScaleChanged = true
			}
		},
		ClientHomeAttachSoundComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeAttachSoundComponent",
			Properties = {}
		},
		ClientHomeEditorComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeEditorComponent",
			Properties = {}
		},
		ClientHomeEditorTopLogoComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeEditorTopLogoComponent",
			Properties = {}
		},
		ClientHomeFacilityHatchBoxComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeFacilityHatchBoxComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_InitInteractionList = true
			}
		},
		ClientHomeLevelUpComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeLevelUpComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_InitInteractionList = true
			}
		},
		ClientHomePetInteractComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomePetInteractComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_InitInteractionList = true
			}
		},
		ClientHomeProduceComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeProduceComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_OnModelVisibleChange = true,
				EVENT_InitInteractionList = true,
				EVENT_onEntityPositionChanged = true,
				EVENT_OnAddExtraDebugInfo = true,
				EVENT_onModelLoaded = true
			}
		},
		ClientHomeStateInteractComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeStateInteractComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_AddEComponent = true,
				EVENT_onModelLoaded = true,
				EVENT_InitInteractionList = true
			}
		},
		ClientHomeTemplateEditorComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeTemplateEditorComponent",
			Properties = {}
		},
		ClientHomeVehicleComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomeVehicleComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_AnimancerAnimUpdate = true,
				EVENT_InitInteractionList = true
			}
		},
		ClientHomelandAIComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomelandAIComponent",
			Properties = {},
			ComponentMethod = {
				onHomelandAIPlanChanged = true,
				EVENT_OnAuthorityChanged = true,
				onHomePettingLeisureFailed = true,
				onHomelandAIRefresh = true
			}
		},
		ClientHomelandComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomelandComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnOrnamentPositionChanged = {}
			},
			ComponentMethod = {
				EVENT_onEntityPositionChanged = true,
				EVENT_OnAddExtraDebugInfo = true,
				EVENT_onModelLoaded = true
			},
			PropertyCallbacks = {
				changed = {
					scaleRatios = {
						"customList",
						"on_scaleRatios_changed"
					}
				}
			}
		},
		ClientHomelandWorkComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientHomelandWorkComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_PetStartRestTeleportEffect = {},
				RPC_SC_PetEndRestTeleportEffect = {}
			},
			ComponentMethod = {
				onEnterSpace = true
			}
		},
		ClientPlayerHomeInteractComponent = {
			NameSpace = "Entities.SpaceEntities.Home.ClientPlayerHomeInteractComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					interactHomePrototypeId = {
						"number",
						"on_interactHomePrototypeId_changed"
					}
				}
			}
		},
		ClientHomelandBgmComponent = {
			NameSpace = "Entities.SpaceEntities.HomelandComponent.ClientHomelandBgmComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					bgmItemId = {
						"number",
						"on_bgmItemId_changed"
					}
				}
			}
		},
		ClientHomelandEnvComponent = {
			NameSpace = "Entities.SpaceEntities.HomelandComponent.ClientHomelandEnvComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					["homeLinkMap.*.groupId"] = {
						"number",
						"on_homeLinkMap_groupId_changed"
					},
					["homeLinkGroupMap.*.totalProduce"] = {
						"number",
						"on_homeLinkGroupMap_totalProduce_changed"
					}
				}
			}
		},
		ClientHomelandEventComponent = {
			NameSpace = "Entities.SpaceEntities.HomelandComponent.ClientHomelandEventComponent",
			Properties = {},
			ComponentMethod = {
				ownerPlayerJoinHomeland = true
			},
			PropertyCallbacks = {
				entryAdded = {
					petHomeEventInsIdMap = {
						"customDict",
						"on_petHomeEventInsIdMap_entry_added"
					}
				},
				entryDeleted = {
					petHomeEventInsIdMap = {
						"customDict",
						"on_petHomeEventInsIdMap_entry_deleted"
					}
				},
				changed = {
					["petHomeEventInsIdMap.*"] = {
						"string",
						"on_petHomeEventInsIdMap_value_changed"
					},
					eventOwnerLoginDone = {
						"boolean",
						"on_eventOwnerLoginDone_changed"
					},
					["homeEventMap.*.solvedTs"] = {
						"number",
						"on_homeEventMap_solvedTs_changed"
					}
				}
			}
		},
		ClientHomelandHatchBoxComponent = {
			NameSpace = "Entities.SpaceEntities.HomelandComponent.ClientHomelandHatchBoxComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_UpdateHatchPetEggInfo = {
					"table"
				},
				RPC_SC_DeleteHatchPetEggInfo = {
					"int"
				}
			},
			ComponentMethod = {
				EVENT_SetHatchBoxesInfo = true
			}
		},
		ClientHomelandOrnamentComponent = {
			NameSpace = "Entities.SpaceEntities.HomelandComponent.ClientHomelandOrnamentComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					homeBlueprintGroupInfo = {
						"customList",
						"on_homeBlueprintGroupInfo_changed"
					}
				}
			}
		},
		ClientHomelandPetsComponent = {
			NameSpace = "Entities.SpaceEntities.HomelandComponent.ClientHomelandPetsComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					["pets.*"] = {
						"customDict",
						"on_pets_changed"
					},
					["petBoxMap.*"] = {
						"customDict",
						"on_petBoxMap_area_changed"
					},
					petExtraNum = {
						"number",
						"on_petExtraNum_changed"
					},
					["pets.*.homeEventInsId"] = {
						"string",
						"on_homeEventInsId_changed"
					},
					foodSlotNextRefreshTs = {
						"number",
						"event_foodSlotNextRefreshTs_changed"
					}
				},
				entryAdded = {
					pets = {
						"customDict",
						"on_pets_added"
					},
					petBoxMap = {
						"customDict",
						"on_petBoxMap_area_added"
					}
				},
				entryDeleted = {
					pets = {
						"customDict",
						"on_pets_delete"
					},
					petBoxMap = {
						"customDict",
						"on_petBoxMap_area_deleted"
					}
				}
			}
		},
		ClientHomelandProduceComponent = {
			NameSpace = "Entities.SpaceEntities.HomelandComponent.ClientHomelandProduceComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_HomelandProduceFinish = {
					"int"
				},
				RPC_SC_HomePettingLeisureFailed = {
					"string"
				}
			},
			ComponentMethod = {
				EVENT_onOrnamentRemove = true,
				EVENT_onOrnamentAdd = true,
				EVENT_onOrnamentChanged = true
			},
			PropertyCallbacks = {
				changed = {
					demoMode = {
						"boolean",
						"on_demoMode_changed"
					},
					["facility.*"] = {
						"customDict",
						"on_facility_changed"
					},
					["facility.*.disable"] = {
						"boolean",
						"on_facility_disable_changed"
					},
					["allocation.*"] = {
						"customDict",
						"on_allocation_changed"
					},
					["leisureState.*"] = {
						"customDict",
						"on_leisureState_changed"
					},
					["transportData.*"] = {
						"customDict",
						"on_transportData_changed"
					},
					["playerAllocation.*"] = {
						"customDict",
						"on_playerAllocation_changed"
					}
				},
				entryAdded = {
					facility = {
						"customDict",
						"on_facility_added"
					},
					allocation = {
						"customDict",
						"on_allocation_added"
					},
					leisureState = {
						"customDict",
						"on_leisureState_added"
					},
					transportData = {
						"customDict",
						"on_transportData_added"
					},
					playerAllocation = {
						"customDict",
						"on_playerAllocation_added"
					}
				},
				entryDeleted = {
					facility = {
						"customDict",
						"on_facility_deleted"
					},
					allocation = {
						"customDict",
						"on_allocation_deleted"
					},
					leisureState = {
						"customDict",
						"on_leisureState_deleted"
					},
					transportData = {
						"customDict",
						"on_transportData_deleted"
					},
					playerAllocation = {
						"customDict",
						"on_playerAllocation_deleted"
					}
				}
			}
		},
		ClientHomelandSeasonComponent = {
			NameSpace = "Entities.SpaceEntities.HomelandComponent.ClientHomelandSeasonComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnHomeSeasonCelebrationEvent = {
					"int",
					"int",
					"int",
					"int"
				}
			},
			PropertyCallbacks = {
				changed = {
					homeSeasonCelebrationState = {
						"number",
						"on_homeSeasonCelebrationState_changed"
					},
					homeSeasonCelebrationEndTs = {
						"number",
						"on_homeSeasonCelebrationEndTs_changed"
					},
					homeSeasonCelebrationStartTs = {
						"number",
						"on_homeSeasonCelebrationStartTs_changed"
					},
					homeSeasonCelebrationFestivalId = {
						"number",
						"on_homeSeasonCelebrationFestivalId_changed"
					},
					homeSeasonCelebrationSessionId = {
						"number",
						"on_homeSeasonCelebrationSessionId_changed"
					}
				}
			}
		},
		ClientHomelandWarehouseComponent = {
			NameSpace = "Entities.SpaceEntities.HomelandComponent.ClientHomelandWarehouseComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					["itemMap.*"] = {
						"number",
						"on_itemMap_changed"
					}
				},
				entryAdded = {
					itemMap = {
						"customDict",
						"on_itemMap_entryAdd"
					}
				},
				entryDeleted = {
					itemMap = {
						"customDict",
						"on_itemMap_entryDeleted"
					}
				}
			}
		},
		ClientHomelandZoneComponent = {
			NameSpace = "Entities.SpaceEntities.HomelandComponent.ClientHomelandZoneComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					["unlockZone.*"] = {
						"boolean",
						"on_zone_changed"
					},
					["unlockArea.*"] = {
						"boolean",
						"on_unlockArea_changed"
					}
				},
				entryAdded = {
					unlockZone = {
						"customDict",
						"on_zone_added"
					},
					unlockArea = {
						"customDict",
						"on_unlockArea_added"
					}
				},
				entryDeleted = {
					unlockZone = {
						"customDict",
						"on_zone_delete"
					}
				}
			}
		},
		ClientAIHelperComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientAIHelperComponent",
			Properties = {},
			ComponentMethod = {
				onLeaveTrap = true,
				onEnterTrap = true,
				onEnterSpace = true,
				onLeaveSpace = true
			}
		},
		ClientAbilityDebugComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientAbilityDebugComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SetAbilityAutoTestPetAiBtName = {
					"string",
					"string"
				},
				RPC_SC_DebugCombatDamage = {
					"table"
				},
				RPC_SC_DebugRecoverEp = {
					"table"
				}
			}
		},
		ClientActionStateComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientActionStateComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					actionState = {
						"number",
						"on_actionState_changed"
					}
				}
			}
		},
		ClientActiveComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientActiveComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_GetActivityData = {
					"table"
				}
			}
		},
		ClientCafeGatheringComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientCafeGatheringComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_NotifyCafeGatheringState = {
					"boolean"
				}
			}
		},
		ClientCaptureComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientCaptureComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SyncCaptureHoldBall = {
					"string",
					"int"
				},
				RPC_SC_SyncCaptureClearBall = {
					"string"
				},
				RPC_SC_OnFireBall = {
					"string",
					"string",
					"table"
				},
				RPC_SC_SyncCatchBallDestroyed = {
					"string"
				}
			},
			ComponentMethod = {
				EVENT_LeaveScene = true,
				onLeaveSpace = true
			},
			PropertyCallbacks = {
				changed = {
					quickCaptureItemId = {
						"number",
						"on_quickCaptureItemId_change"
					}
				},
				itemInserted = {
					debugCatchInfos = {
						"customList",
						"on_debugCatchInfos_itemInserted"
					}
				}
			}
		},
		ClientCaptureMainComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientCaptureMainComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnCaptureSuccess = {
					"table",
					"string"
				},
				RPC_SC_OnCaptureBossMonster = {
					"string",
					"boolean"
				},
				RPC_SC_GroupDropNotify = {
					"int",
					"int",
					"table"
				}
			},
			ComponentMethod = {
				EVENT_LeaveScene = true,
				tick = true,
				EVENT_OnPlayerDead = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_EnterScene = true,
				EVENT_BeControlled = true,
				EVENT_PostInitialized = true,
				EVENT_AddEComponent = true,
				onLeaveSpace = true,
				EVENT_ResetAllStateByEscape = true
			},
			PropertyCallbacks = {
				changed = {
					groupDropEndTsMap = {
						"customDict",
						"on_groupDropEndTsMap_changed"
					}
				}
			}
		},
		ClientChainAttackComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientChainAttackComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ShowBurstDamage = {
					"number"
				},
				RPC_SC_NotifyPlayerTeamChainChance = {
					"string"
				},
				RPC_SC_NotifyTriggerExtremeChain = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					["chainAttackInfo.totalDamage"] = {
						"number",
						"onChainAttackInfoTotalDamageChanged"
					},
					["chainAttackInfo.inExtreme"] = {
						"boolean",
						"onChainAttackInfoInExtremeChanged"
					}
				}
			}
		},
		ClientChatComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientChatComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SendPlayerChat = {
					"string",
					"int",
					"table"
				},
				RPC_SC_SendPlayerText = {
					"string",
					"string"
				},
				RPC_SC_PlayerTyping = {
					"string",
					"int"
				}
			},
			PropertyCallbacks = {
				changed = {
					voiceSignature = {
						"string",
						"on_voiceSignature_changed"
					}
				}
			}
		},
		ClientChestComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientChestComponent",
			Properties = {},
			ComponentMethod = {
				onLeaveTrap = true,
				onEnterTrap = true,
				onEnterSpace = true,
				onLeaveSpace = true
			}
		},
		ClientCombatComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientCombatComponent",
			Properties = {}
		},
		ClientDebugComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientDebugComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OpenClientGmPanel = {},
				RPC_SC_CloseClientGmPanel = {},
				RPC_SC_EnableCombatLogger = {
					"boolean"
				},
				RPC_SC_BlockOtherPlayerAudio = {
					"boolean"
				},
				RPC_SC_DebugGrabEggDangerEntityInfo = {
					"boolean"
				},
				RPC_SC_DisableWeightPush = {
					"boolean"
				},
				RPC_SC_DebugShowEntHates = {
					"int"
				},
				RPC_SC_SyncDebugPlayEffect = {
					"string",
					"float",
					"int"
				},
				RPC_SC_BotServerTestRet = {
					"string",
					"table"
				},
				RPC_SC_AttachGmObserveTarget = {
					"string"
				},
				RPC_SC_DetachGmObserveTarget = {}
			},
			ComponentMethod = {
				onEnterGmObserveMode = true,
				onExitGmObserveMode = true
			}
		},
		ClientDialogueComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientDialogueComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_PlayBatchDialogue = {
					"int",
					"int"
				},
				RPC_SC_GmCloseCurDialogueGraph = {
					"int"
				}
			}
		},
		ClientDispatcherComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientDispatcherComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_DispatchOtherEntityClientMsg = {
					"string",
					"int",
					"table"
				},
				RPC_SC_DispatchOtherEntityPropertySync = {
					"string",
					"table"
				},
				RPC_SC_DispatchOtherEntityPropertyIdSync = {
					"string",
					"table"
				},
				RPC_SC_CreateMultiClientEntity = {
					"boolean",
					"boolean",
					"table",
					"table",
					"table",
					"int"
				},
				RPC_SC_CreateClientEntityInfo = {
					"string",
					"string",
					"int",
					"table",
					"int",
					"int"
				},
				RPC_SC_RequestCreateClientEntityFailed = {
					"string"
				},
				RPC_SC_CreateClientEntity = {
					"string",
					"string",
					"string",
					"boolean"
				},
				RPC_SC_DestroyClientEntity = {
					"string",
					"int"
				},
				RPC_SC_ClientEntityMsg = {
					"string",
					"int",
					"table"
				},
				RPC_SC_SpaceMethod = {
					"int",
					"table"
				}
			},
			ComponentMethod = {
				onLeaveSpace = true
			}
		},
		ClientEducationComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientEducationComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnAddPlayerExp = {
					"int",
					"int",
					"int",
					"int",
					"int"
				},
				RPC_SC_OnPlayerSkillUnlockOrUp = {
					"int",
					"int"
				},
				RPC_SC_CombatPetLearnSkill = {
					"string",
					"int"
				},
				RPC_SC_OnAbilityMapUpdate = {
					"int",
					"boolean"
				}
			},
			PropertyCallbacks = {
				changed = {
					playerName = {
						"string",
						"on_playerName_changed"
					},
					headIcon = {
						"number",
						"on_headIcon_changed"
					},
					headIconDicts = {
						"customDict",
						"on_headIconDicts_changed"
					},
					headFrame = {
						"number",
						"on_headFrame_changed"
					},
					isWholeTitle = {
						"boolean",
						"on_isWholeTitle_changed"
					},
					showTitles = {
						"customDict",
						"on_showTitles_changed"
					},
					showTitleExtra = {
						"customDict",
						"on_showTitleExtra_changed"
					},
					showTitleDicts = {
						"customDict",
						"on_showTitleDicts_changed"
					},
					cardBackground = {
						"number",
						"on_cardBackground_changed"
					},
					cardBackgroundDicts = {
						"customDict",
						"on_cardBackgroundDicts_changed"
					},
					showSignature = {
						"string",
						"on_showSignature_changed"
					},
					headFrameDicts = {
						"customDict",
						"on_headFrameDicts_changed"
					},
					level = {
						"number",
						"on_playerLevel_changed"
					},
					rank = {
						"number",
						"on_playerRank_changed"
					},
					unlockedAbilityMap = {
						"customDict",
						"on_unlockedAbilityMap_changed"
					},
					chatBubble = {
						"number",
						"on_chatBubble_changed"
					},
					chatBubbleDicts = {
						"customDict",
						"on_chatBubbleDicts_changed"
					},
					["tempPets.*.curAbilityMap"] = {
						"customDict",
						"onTempPetCurAbilityMapChanged"
					},
					["tempPets.*.exploreAbilityList"] = {
						"customList",
						"onTempPetsExploreAbilityChange"
					},
					["pets.*.exploreAbilityList"] = {
						"customList",
						"onPetsExploreAbilityChange"
					},
					skillNodeMap = {
						"customDict",
						"on_skillNodeMap_changed"
					},
					starTitle = {
						"number",
						"on_starTitle_changed"
					}
				}
			}
		},
		ClientEffectComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientEffectComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_EnterScene = true,
				EVENT_OnModelRefreshed = true,
				EVENT_OnModelVisibleChange = true,
				EVENT_OnExitVehicle = true,
				EVENT_OnEnterVehicle = true,
				EVENT_OnAnimatorReady = true,
				onSkeletonLoaded = true,
				EVENT_BeControlled = true,
				EVENT_LoseControlled = true,
				EVENT_TimeScaleChanged = true,
				EVENT_AddEComponent = true,
				onEnterSpace = true,
				EVENT_onModelLoaded = true
			}
		},
		ClientEventComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientEventComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_doEventFromServer = {
					"string",
					"table",
					"table"
				},
				RPC_SC_BlackScreen = {
					"number",
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					skillVisibleMap = {
						"customDict",
						"onSkillVisibleChange"
					}
				}
			}
		},
		ClientFluteComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientFluteComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ReceiveFluteNotify = {
					"string",
					"string",
					"table",
					"int",
					"int"
				},
				RPC_SC_SendFluteNotifyResult = {
					"boolean",
					"int",
					"string",
					"int",
					"table"
				},
				RPC_SC_ReplyFluteNotifyResult = {
					"boolean",
					"int",
					"string"
				},
				RPC_SC_AcceptFluteNotifyResult = {
					"boolean",
					"int",
					"string"
				},
				RPC_SC_FluteEnterRequestReceived = {
					"table"
				},
				RPC_SC_OnFluteNotifyClosed = {}
			}
		},
		ClientFriendComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientFriendComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_BindSocialMediaAccount = {
					"boolean",
					"string"
				},
				RPC_SC_UnbindSocialMediaAccount = {
					"boolean",
					"string"
				},
				RPC_SC_SyncPlatformShellInviteToken = {
					"string",
					"string",
					"string",
					"number"
				},
				RPC_SC_PlatformShellInviteDestinationResult = {
					"string",
					"boolean",
					"table"
				},
				RPC_SC_BatchResolveSocialAccounts = {
					"string",
					"boolean",
					"string",
					"table"
				},
				RPC_SC_GetRecommendPlayer = {
					"table"
				},
				RPC_SC_CreateDiscordActivityInviteResult = {
					"boolean",
					"string",
					"string",
					"int",
					"int",
					"int",
					"string"
				},
				RPC_SC_FriendDataChanged = {},
				RPC_SC_FriendPermissionChanged = {
					"string",
					"int"
				},
				RPC_SC_OnChangeVariantFriend = {
					"string",
					"string",
					"boolean"
				},
				RPC_SC_FriendSendGiftLimitChanged = {
					"string",
					"int"
				},
				RPC_SC_ReceiveEnterPhotoWorldRequest = {
					"table",
					"table"
				},
				RPC_SC_SyncPsnBlockStates = {
					"table"
				}
			}
		},
		ClientFunctionUnlockComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientFunctionUnlockComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					functionUnlocks = {
						"customDict",
						"on_functionUnlocks_changed"
					},
					banNpcFuncInfo = {
						"customDict",
						"on_banNpcFuncInfo_changed"
					}
				}
			}
		},
		ClientGhostEyeComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientGhostEyeComponent",
			Properties = {},
			ComponentMethod = {
				onLeaveTrap = true,
				onEnterTrap = true
			}
		},
		ClientGhostEyeDetectedComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientGhostEyeDetectedComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_OnModelRefreshed = true,
				EVENT_onModelLoaded = true
			}
		},
		ClientGlobalSurveyComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientGlobalSurveyComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_StartSurvey = {
					"table"
				}
			}
		},
		ClientGrabEggComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientGrabEggComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ResourceBox = {
					"string",
					"table"
				},
				RPC_SC_RobEggSceneReady = {
					"table"
				},
				RPC_SC_DiscoveryStarted = {
					"string",
					"int",
					"int",
					"float"
				},
				RPC_SC_Discoverying = {
					"string",
					"int",
					"int"
				},
				RPC_SC_DiscoveryFinished = {
					"string",
					"int"
				},
				RPC_SC_DiscoveryInterupted = {
					"string",
					"int"
				},
				RPC_SC_ResourceBoxInfo = {
					"string",
					"table"
				},
				RPC_SC_SearchPlayerInfo = {
					"string",
					"table"
				},
				RPC_SC_ExtractStatus = {
					"boolean",
					"float"
				},
				RPC_SC_GameOver = {
					"number",
					"table"
				},
				RPC_SC_QuitRobEgg = {
					"table"
				},
				RPC_SC_RobEggResetPosition = {},
				RPC_SC_RobEggDungeonFinished = {},
				RPC_SC_StartHatchEgg = {
					"int"
				},
				RPC_SC_HatchEggAttacked = {
					"int"
				},
				RPC_SC_RobberyDone = {
					"int"
				},
				RPC_SC_HatchEggFinished = {
					"int"
				},
				RPC_SC_InteruptReadingBar = {
					"int"
				},
				RPC_SC_StartReadingBar = {
					"int",
					"float"
				},
				RPC_SC_RobEggTaked = {
					"string",
					"table",
					"int"
				},
				RPC_SC_StartTransportEgg = {
					"int",
					"string",
					"int"
				},
				RPC_SC_StartRobEgg = {
					"int",
					"string",
					"number"
				},
				RPC_SC_RobEggSuccess = {
					"int",
					"string",
					"string"
				},
				RPC_SC_TransportEggSucceed = {
					"int",
					"string",
					"boolean"
				},
				RPC_SC_RobEggFailed = {
					"int",
					"string",
					"string"
				},
				RPC_SC_AchieveRobEgg = {
					"string",
					"int",
					"int",
					"int",
					"boolean"
				},
				RPC_SC_SuperEggShieldTimeUp = {},
				RPC_SC_RobEggTipsEvent = {
					"int",
					"table"
				}
			},
			ComponentMethod = {
				EVENT_EnterScene = true,
				onLeaveSpace = true
			},
			PropertyCallbacks = {
				changed = {
					eggLv = {
						"number",
						"on_eggLv_changed"
					},
					secEggLv = {
						"number",
						"on_secEggLv_changed"
					},
					eggStar = {
						"number",
						"on_eggStar_changed"
					},
					eggScore = {
						"number",
						"on_eggScore_changed"
					},
					eggAllScore = {
						"number",
						"on_eggAllScore_changed"
					},
					rankRewardFlag = {
						"customDict",
						"on_rankRewardFlag_changed"
					},
					["rewardBoxList.*.id"] = {
						"number",
						"on_rewardBoxList_id_changed"
					},
					["rewardBoxList.*.timestamp"] = {
						"number",
						"on_rewardBoxList_timestamp_changed"
					},
					refreshCountDaily = {
						"number",
						"on_refreshCountDaily_changed"
					},
					robEggEvtProps = {
						"customDict",
						"on_robEggEvtProps_changed"
					},
					["robEggEvtProps.*"] = {
						"number",
						"on_robEggEvtProps_value_changed"
					},
					safeBoxNum = {
						"number",
						"on_safeBoxNum_changed"
					},
					["slotsInfo.*.genId"] = {
						"number",
						"on_grabEggBagSlot_changed"
					},
					["equipSlotsInfo.*.genId"] = {
						"number",
						"on_grabEggBagEquipSlot_changed"
					},
					curLoad = {
						"number",
						"on_curLoad_changed"
					},
					curLoadBearing = {
						"number",
						"on_curLoadBearing_changed"
					},
					eggGameSuccessTimes = {
						"number",
						"on_eggGameSuccessTimes_changed"
					},
					achievedCoin = {
						"number",
						"on_harvest_changed"
					}
				},
				entryAdded = {
					eggUnlockTalent = {
						"customDict",
						"on_eggUnlockTalent_entry_added"
					},
					robEggEvtProps = {
						"customDict",
						"on_robEggEvtProps_entry_added"
					}
				}
			}
		},
		ClientGuidanceComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientGuidanceComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OpenGuidExitInterface = {},
				RPC_SC_AppearHelp = {
					"int",
					"table"
				},
				RPC_SC_AppearHelpSimple = {
					"int"
				}
			},
			PropertyCallbacks = {
				entryAdded = {
					guidanceCurs = {
						"customDict",
						"RPC_SC_GuidanceCurs_Change"
					},
					guidanceRecords = {
						"customDict",
						"RPC_SC_GuidanceRecords_Add"
					}
				},
				changed = {
					["guidanceRecords.*"] = {
						"number",
						"RPC_SC_GuidanceRecords_Change"
					}
				}
			}
		},
		ClientHornComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientHornComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ReqSendHornResult = {
					"table",
					"boolean",
					"table"
				},
				RPC_SC_OtherRequestEnterSpace = {
					"string",
					"table"
				},
				RPC_SC_HornNotify = {
					"table"
				},
				RPC_SC_AcceptHornNotifyResult = {
					"int",
					"string"
				}
			},
			ComponentMethod = {
				EVENT_PostInitialized = true
			}
		},
		ClientInteractionAnimationComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientInteractionAnimationComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_RequestFriendAction = {
					"string",
					"int"
				},
				RPC_SC_RefuseFriendAction = {
					"string",
					"int"
				}
			},
			ComponentMethod = {
				EVENT_OnAnimatorReady = true,
				EVENT_OnCharacterStateChange = true,
				EVENT_OnModelVisibleChange = true,
				EVENT_OnMoveInputStateChanged = true
			},
			PropertyCallbacks = {
				changed = {
					singleActionState = {
						"number",
						"on_singleActionState_changed"
					},
					friendInteractAction = {
						"customDict",
						"on_friendInteractAction_changed"
					},
					multiInteractAction = {
						"customDict",
						"on_multiInteractAction_changed"
					},
					actionShowIds = {
						"customDict",
						"on_actionShowIds_changed"
					}
				}
			}
		},
		ClientInventoryComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientInventoryComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnUpdateItemCanUseTime = {
					"int",
					"int"
				},
				RPC_SC_OnChangeMoney = {
					"int",
					"double",
					"double",
					"int",
					"int"
				},
				RPC_SC_OnNotifyItems = {
					"table",
					"int",
					"table"
				},
				RPC_SC_OnNotifyItemsBatch = {
					"table",
					"int"
				},
				RPC_SC_OnItemCompound = {
					"int"
				}
			},
			PropertyCallbacks = {
				changed = {
					["invQuickSlotBall.*"] = {
						"number",
						"on_invQuickSlot_changed"
					},
					["invEliteSlotBall.*"] = {
						"number",
						"on_invEliteSlot_changed"
					},
					invQuickSlotItem = {
						"customList",
						"on_invConsumeSlot_changed"
					},
					["commonMoneyNums.*"] = {
						"number",
						"on_commonMoneyNums_changed"
					},
					["moneyNegativeNums.*"] = {
						"number",
						"on_moneyNegativeNums_changed"
					},
					["commonEnergyNums.*"] = {
						"number",
						"on_commonEnergyNums_changed"
					},
					["useLimitMap.*"] = {
						"customDict",
						"on_useLimitMap_changed"
					},
					["useLimitMap.nextRefreshTs"] = {
						"number",
						"on_useLimitMap_nextRefreshTs_changed"
					},
					playerItemBag = {
						"customDict",
						"onPlayerItemBagChanged"
					},
					["playerItemBag.*.status"] = {
						"number",
						"onPlayerItemStatusChanged"
					},
					["playerItemBag.*.count"] = {
						"number",
						"onPlayerItemCountChanged"
					},
					["playerItemBag.*.props.*.*"] = {
						"string",
						"onPlayerItemPropsChanged"
					},
					petItemBag = {
						"customDict",
						"onPetItemBagChanged"
					},
					["petItemBag.*.status"] = {
						"number",
						"onPetItemStatusChanged"
					},
					["petItemBag.*.count"] = {
						"number",
						"onPetItemCountChanged"
					},
					["petItemBag.*.props.*.*"] = {
						"string",
						"onPetItemPropsChanged"
					},
					ballItemBag = {
						"customDict",
						"onBallItemBagChanged"
					},
					["ballItemBag.*.status"] = {
						"number",
						"onBallItemStatusChanged"
					},
					["ballItemBag.*.count"] = {
						"number",
						"onBallItemCountChanged"
					},
					["ballItemBag.*.props.*.*"] = {
						"string",
						"onBallItemPropsChanged"
					},
					commonItemBag = {
						"customDict",
						"onCommonItemBagChanged"
					},
					["commonItemBag.*.status"] = {
						"number",
						"onCommonItemStatusChanged"
					},
					["commonItemBag.*.count"] = {
						"number",
						"onCommonItemCountChanged"
					},
					["commonItemBag.*.props.*.*"] = {
						"string",
						"onCommonItemPropsChanged"
					},
					taskItemBag = {
						"customDict",
						"onTaskItemBagChanged"
					},
					["taskItemBag.*.status"] = {
						"number",
						"onTaskItemStatusChanged"
					},
					["taskItemBag.*.count"] = {
						"number",
						"onTaskItemCountChanged"
					},
					["taskItemBag.*.props.*.*"] = {
						"string",
						"onTaskItemPropsChanged"
					},
					petJewelryItemBag = {
						"customDict",
						"onPetJewelryItemBagChanged"
					},
					["petJewelryItemBag.*.status"] = {
						"number",
						"onPetJewelryItemStatusChanged"
					},
					["petJewelryItemBag.*.count"] = {
						"number",
						"onPetJewelryItemCountChanged"
					},
					["petJewelryItemBag.*.props.*.*"] = {
						"string",
						"onPetJewelryItemPropsChanged"
					},
					homelandItemBag = {
						"customDict",
						"onHomelandItemBagChanged"
					},
					["homelandItemBag.*.status"] = {
						"number",
						"onHomelandItemStatusChanged"
					},
					["homelandItemBag.*.count"] = {
						"number",
						"onHomelandItemCountChanged"
					},
					["homelandItemBag.*.props.*.*"] = {
						"string",
						"onHomelandItemPropsChanged"
					},
					homelandFurnitureItemBag = {
						"customDict",
						"onHomelandFurnitureItemBagChanged"
					},
					["homelandFurnitureItemBag.*.status"] = {
						"number",
						"onHomelandFurnitureItemStatusChanged"
					},
					["homelandFurnitureItemBag.*.count"] = {
						"number",
						"onHomelandFurnitureItemCountChanged"
					},
					["homelandFurnitureItemBag.*.props.*.*"] = {
						"string",
						"onHomelandFurnitureItemPropsChanged"
					},
					robEggItemBag = {
						"customDict",
						"onRobEggItemBagChanged"
					},
					["robEggItemBag.*.status"] = {
						"number",
						"onRobEggItemStatusChanged"
					},
					["robEggItemBag.*.count"] = {
						"number",
						"onRobEggItemCountChanged"
					},
					["robEggItemBag.*.props.*.*"] = {
						"string",
						"onRobEggItemPropsChanged"
					},
					robEggWarehouseItemBag = {
						"customDict",
						"onRobEggWarehouseItemBagChanged"
					},
					["robEggWarehouseItemBag.*.status"] = {
						"number",
						"onRobEggWarehouseItemStatusChanged"
					},
					["robEggWarehouseItemBag.*.count"] = {
						"number",
						"onRobEggWarehouseItemCountChanged"
					},
					["robEggWarehouseItemBag.*.props.*.*"] = {
						"string",
						"onRobEggWarehouseItemPropsChanged"
					},
					equipSlotsItemBag = {
						"customDict",
						"onEquipSlotsItemBagChanged"
					},
					["equipSlotsItemBag.*.status"] = {
						"number",
						"onEquipSlotsItemStatusChanged"
					},
					["equipSlotsItemBag.*.count"] = {
						"number",
						"onEquipSlotsItemCountChanged"
					},
					["equipSlotsItemBag.*.props.*.*"] = {
						"string",
						"onEquipSlotsItemPropsChanged"
					},
					reservedItemBag = {
						"customDict",
						"onReservedItemBagChanged"
					},
					["reservedItemBag.*.status"] = {
						"number",
						"onReservedItemStatusChanged"
					},
					["reservedItemBag.*.count"] = {
						"number",
						"onReservedItemCountChanged"
					},
					["reservedItemBag.*.props.*.*"] = {
						"string",
						"onReservedItemPropsChanged"
					},
					fragmentItemBag = {
						"customDict",
						"onFragmentItemBagChanged"
					},
					["fragmentItemBag.*.status"] = {
						"number",
						"onFragmentItemStatusChanged"
					},
					["fragmentItemBag.*.count"] = {
						"number",
						"onFragmentItemCountChanged"
					},
					["fragmentItemBag.*.props.*.*"] = {
						"string",
						"onFragmentItemPropsChanged"
					},
					unboundMoney = {
						"number",
						"on_unboundMoney_changed"
					},
					["itemCountBindMap.*"] = {
						"customDict",
						"on_itemCountMap_change"
					}
				},
				itemInserted = {
					invQuickSlotBall = {
						"customList",
						"on_invQuickSlot_itemInserted"
					},
					invEliteSlotBall = {
						"customList",
						"on_invEliteSlot_itemInserted"
					}
				},
				itemRemoved = {
					invQuickSlotBall = {
						"customList",
						"on_invQuickSlot_itemRemoved"
					},
					invEliteSlotBall = {
						"customList",
						"on_invEliteSlot_itemRemoved"
					}
				},
				entryAdded = {
					useLimitMap = {
						"customDict",
						"on_useLimitMap_added"
					},
					playerItemBag = {
						"customDict",
						"onPlayerItemAdded"
					},
					petItemBag = {
						"customDict",
						"onPetItemAdded"
					},
					ballItemBag = {
						"customDict",
						"onBallItemAdded"
					},
					commonItemBag = {
						"customDict",
						"onCommonItemAdded"
					},
					taskItemBag = {
						"customDict",
						"onTaskItemAdded"
					},
					petJewelryItemBag = {
						"customDict",
						"onPetJewelryItemAdded"
					},
					homelandItemBag = {
						"customDict",
						"onHomelandItemAdded"
					},
					homelandFurnitureItemBag = {
						"customDict",
						"onHomelandFurnitureItemAdded"
					},
					robEggItemBag = {
						"customDict",
						"onRobEggItemAdded"
					},
					robEggWarehouseItemBag = {
						"customDict",
						"onRobEggWarehouseItemAdded"
					},
					equipSlotsItemBag = {
						"customDict",
						"onEquipSlotsItemAdded"
					},
					reservedItemBag = {
						"customDict",
						"onReservedItemAdded"
					},
					fragmentItemBag = {
						"customDict",
						"onFragmentItemAdded"
					}
				},
				entryDeleted = {
					useLimitMap = {
						"customDict",
						"on_useLimitMap_deleted"
					},
					playerItemBag = {
						"customDict",
						"onPlayerItemDeleted"
					},
					petItemBag = {
						"customDict",
						"onPetItemDeleted"
					},
					ballItemBag = {
						"customDict",
						"onBallItemDeleted"
					},
					commonItemBag = {
						"customDict",
						"onCommonItemDeleted"
					},
					taskItemBag = {
						"customDict",
						"onTaskItemDeleted"
					},
					petJewelryItemBag = {
						"customDict",
						"onPetJewelryItemDeleted"
					},
					homelandItemBag = {
						"customDict",
						"onHomelandItemDeleted"
					},
					homelandFurnitureItemBag = {
						"customDict",
						"onHomelandFurnitureItemDeleted"
					},
					robEggItemBag = {
						"customDict",
						"onRobEggItemDeleted"
					},
					robEggWarehouseItemBag = {
						"customDict",
						"onRobEggWarehouseItemDeleted"
					},
					equipSlotsItemBag = {
						"customDict",
						"onEquipSlotsItemDeleted"
					},
					reservedItemBag = {
						"customDict",
						"onReservedItemDeleted"
					},
					fragmentItemBag = {
						"customDict",
						"onFragmentItemDeleted"
					}
				}
			}
		},
		ClientKnowledgeComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientKnowledgeComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OpenKnowledgeUI = {
					"int"
				}
			},
			PropertyCallbacks = {
				entryAdded = {
					unlockedKnowledgeMap = {
						"customDict",
						"onUnlockedKnowledgeAdded"
					}
				},
				changed = {
					["unlockedKnowledgeMap.*"] = {
						"boolean",
						"onKnowledgeReadStateChanged"
					}
				},
				entryDeleted = {
					unlockedKnowledgeMap = {
						"customDict",
						"onUnlockedKnowledgeDeleted"
					}
				}
			}
		},
		ClientLeylineFlowerComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientLeylineFlowerComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_LeylineRainbowPresent = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					["leylineFlowerInfoMap.*.flowerState"] = {
						"number",
						"onLeylineFlowerInfoMapFlowerState_changed"
					},
					["leylineFlowerInfoMap.*.rainbowStage"] = {
						"number",
						"onLeylineFlowerInfoMapRainbowStage_changed"
					},
					["leylineFlowerInfoMap.*.captureProgressCount"] = {
						"number",
						"onLeylineFlowerInfoMapCaptureProgressCount_changed"
					},
					["leylineFlowerInfoMap.*.pendingCaptureBloomCount"] = {
						"number",
						"onLeylineFlowerInfoMapPendingCaptureBloomCount_changed"
					},
					rbPetsCahce = {
						"customDict",
						"onCachedMapRainbowPetsChanged"
					}
				}
			}
		},
		ClientLeylineTreeComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientLeylineTreeComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnLeylineTreeActivated = {
					"int"
				},
				RPC_SC_OnLeylineTreeUpdated = {
					"int"
				},
				RPC_SC_UnlockFreelance = {
					"int"
				},
				RPC_SC_OnLeylineTreeRewardUpdated = {
					"int",
					"int"
				},
				RPC_SC_LeylineMarkCreate = {
					"int",
					"table"
				},
				RPC_SC_LeylineMarkClear = {
					"int",
					"int",
					"int"
				}
			},
			PropertyCallbacks = {
				changed = {
					["leylineTreeInfoMap.*.createPlentyCount"] = {
						"number",
						"onLeylineTreeInfoMapCreatePlentyCount_changed"
					},
					["leylineTreeInfoMap.*.changeMeteorologyCount"] = {
						"number",
						"onChangeMeteorologyCount_changed"
					},
					["leylineTreeInfoMap.*.changeMeteorologyCD"] = {
						"number",
						"onChangeMeteorologyCD_changed"
					},
					["leylineTreeInfoMap.*.pendMeteo"] = {
						"customDict",
						"onPendingMapMeteorologyChanged"
					}
				}
			}
		},
		ClientMagnesisComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientMagnesisComponent",
			Properties = {},
			ComponentMethod = {
				onLeaveSpace = true
			}
		},
		ClientMailComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientMailComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ReceiveMailGift = {
					"table"
				},
				RPC_SC_DeleteMail = {
					"boolean",
					"string",
					"table"
				},
				RPC_SC_DeleteReadedMail = {
					"boolean",
					"string",
					"table"
				},
				RPC_SC_NotifyPullMail = {},
				RPC_SC_ShowMarqueeText = {
					"string",
					"number"
				}
			}
		},
		ClientMatchComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientMatchComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_PvpBattleInviteResult = {
					"string",
					"int",
					"int"
				},
				RPC_SC_RecivePvpBattleInvite = {
					"string",
					"int"
				},
				RPC_SC_RecivePvpBattleInviteResult = {
					"string"
				},
				RPC_SC_ReciveAcceptPvpBattle = {
					"string",
					"int"
				},
				RPC_SC_ReciveCancelPvpBattleResult = {
					"string",
					"boolean"
				},
				RPC_SC_ReciveRivalPvpAgain = {
					"table"
				},
				RPC_SC_EnterRoomSucc = {
					"table"
				},
				RPC_SC_SwitchMasterPet = {}
			},
			PropertyCallbacks = {
				changed = {
					matchStatus = {
						"number",
						"on_matchStatus_changed"
					}
				}
			}
		},
		ClientMediaMarkerComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientMediaMarkerComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_AddMediaMarkerRet = {
					"string",
					"int",
					"string",
					"int"
				},
				RPC_SC_RemoveMediaMarkerRet = {
					"string"
				},
				RPC_SC_LikeMediaMarkerRet = {
					"string",
					"int",
					"int",
					"int",
					"int"
				},
				RPC_SC_DislikeMediaMarkerRet = {
					"string",
					"int",
					"int"
				}
			}
		},
		ClientMonthCardComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientMonthCardComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_NotifyOpenMonthCardSuccess = {
					"int"
				}
			},
			PropertyCallbacks = {
				changed = {
					mcStoreDailyAwards = {
						"number",
						"on_mcStoreDailyAwards_changed"
					}
				}
			}
		},
		ClientOfflineCaptureComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientOfflineCaptureComponent",
			Properties = {}
		},
		ClientPayComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPayComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_NotifyCreatePayOrder = {
					"boolean",
					"string",
					"string",
					"string",
					"string",
					"string"
				},
				RPC_SC_NotifyPaySuccess = {
					"table"
				},
				RPC_SC_NotifyPayCoinSuccess = {
					"string",
					"number",
					"table",
					"table",
					"table"
				},
				RPC_SC_NotifyRechargeRebateRewardGuide = {
					"number"
				},
				RPC_SC_NotifyPayMonthCardSuccess = {
					"string",
					"number",
					"table",
					"table",
					"table",
					"table"
				},
				RPC_SC_NotifyPayBattlePassSuccess = {
					"string",
					"number"
				}
			}
		},
		ClientPersonalDisplayComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPersonalDisplayComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_DisplayShelvesUpdate = {
					"number",
					"table"
				}
			}
		},
		ClientPetBallComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPetBallComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					actionPoint = {
						"number",
						"onActionPoint_changed"
					},
					["hatchSlotMap.*.status"] = {
						"number",
						"onPetBallHatchSlotMapStatus_changed"
					}
				}
			}
		},
		ClientPetHandbookComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPetHandbookComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnChangeDisplayPetForm = {
					"int",
					"int",
					"int",
					"int",
					"int"
				},
				RPC_SC_ChangeDisplayPetLabel = {
					"int",
					"int",
					"int",
					"int"
				},
				RPC_SC_HandBookDataChanged = {
					"table"
				},
				RPC_SC_ClearPetHandbookData = {},
				RPC_SC_PetUnlockTraitResearch = {
					"int",
					"int"
				},
				RPC_SC_PetUnlockEvolveResearch = {
					"int",
					"int"
				},
				RPC_SC_PetUnlockSingleResearch = {
					"int",
					"int",
					"int"
				},
				RPC_SC_OnPetHandbookAddResearchExp = {
					"int",
					"int",
					"int",
					"int",
					"int"
				},
				RPC_SC_UnlockBattleResearchEvent = {
					"int",
					"int"
				}
			},
			PropertyCallbacks = {
				changed = {
					blockCatchRewardStatus = {
						"customDict",
						"onBlockCatchRewardStatus_changed"
					},
					blockCatchedPetMap = {
						"customDict",
						"onBlockCatchedPetMap_changed"
					},
					["petHandbookMap.*.levelRewardStatus.*"] = {
						"number",
						"onPetHandbookLevelRewardStatus_changed"
					},
					["petHandbookMap.petCountryMap.*.collectLevelRewardStatus"] = {
						"customDict",
						"onPetHandbookCollectLevelRewardStatus_changed"
					},
					["petHandbookMap.*.completedTargetMap.*.*"] = {
						"boolean",
						"onPetHandbookCompletedTarget_changed"
					},
					["petHandbookMap.*.exp"] = {
						"number",
						"onPetHandbookExp_changed"
					},
					["petHandbookMap.*.stateMask"] = {
						"number",
						"onPetHandbookStateMask_changed"
					},
					["petHandbookMap.petCountryMap.*"] = {
						"customDict",
						"onPetCountryMap_changed"
					},
					["petHandbookMap.petCountryMap.*.unlocked"] = {
						"boolean",
						"onAreaActiveChanged"
					},
					["petHandbookMap.*.rewardedTargetMap.*.*"] = {
						"boolean",
						"onRewardTargetMapChanged"
					}
				},
				entryAdded = {
					["petHandbookMap.*.completedTargetMap.*"] = {
						"customDict",
						"onPetHandbookCompletedTarget_entryAdded"
					}
				}
			}
		},
		ClientPetTransmogComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPetTransmogComponent",
			Properties = {}
		},
		ClientPetsBreedComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPetsBreedComponent",
			Properties = {}
		},
		ClientPetsComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPetsComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnControlExplorePet = {
					"boolean",
					"int",
					"boolean",
					"int",
					"string"
				},
				RPC_SC_OnLeaveExplorePet = {
					"boolean",
					"int",
					"boolean",
					"int",
					"string"
				},
				RPC_SC_SyncPreparePets = {},
				RPC_SC_SetCombatPetIdAndIndex = {
					"string",
					"int"
				},
				RPC_SC_OnRefreshCanEvolveStatus = {
					"string"
				},
				RPC_SC_refreshBasePropertyList = {
					"string"
				},
				RPC_SC_OnPetChangeTemplate = {
					"string",
					"table",
					"boolean",
					"number"
				},
				RPC_SC_OnChangeControlEndCD = {
					"number"
				},
				RPC_SC_OnChangeSwitchEndCD = {
					"number",
					"number",
					"number"
				},
				RPC_SC_OnControlToFollow = {
					"int",
					"table",
					"int",
					"string",
					"string"
				},
				RPC_SC_OnSwithToSingle = {
					"int",
					"table",
					"string"
				},
				RPC_SC_OnSwitchToControll = {
					"int",
					"table",
					"string",
					"string"
				},
				RPC_SC_OnControlToControl = {
					"int",
					"table",
					"int",
					"int",
					"string",
					"string"
				},
				RPC_SC_OnSingleToFollow = {
					"int",
					"table",
					"string"
				},
				RPC_SC_OnFollowToSingle = {
					"int",
					"table",
					"string"
				},
				RPC_SC_OnFollowToFollow = {
					"int",
					"table",
					"int",
					"int",
					"string",
					"string"
				},
				RPC_SC_OnSummonPet = {
					"string",
					"int",
					"table"
				},
				RPC_SC_OnUnSummonPet = {
					"string"
				},
				RPC_SC_SummonStandInPet = {
					"string"
				},
				RPC_SC_OnAddPet = {
					"string",
					"table",
					"int"
				},
				RPC_SC_ChangePetLabel = {
					"string",
					"int",
					"int"
				},
				RPC_SC_ChangePetBodySizeType = {
					"string",
					"int"
				},
				RPC_SC_OnRecyclePet = {
					"table"
				},
				RPC_SC_OnAddPetExp = {
					"string",
					"int",
					"int",
					"int",
					"int",
					"table",
					"int"
				},
				RPC_SC_OnPetInfoSwitchAbility = {
					"string",
					"int"
				},
				RPC_SC_OnMasterExploreStateChange = {
					"boolean"
				},
				RPC_SC_OnAddBehatred = {
					"int"
				},
				RPC_SC_OnSocialRemoveHatred = {
					"int"
				},
				RPC_SC_OnAddHatred = {
					"int"
				},
				RPC_SC_OnPetBoxAutoAdjust = {
					"int"
				},
				RPC_SC_OnItemAddPet = {
					"table",
					"int"
				},
				RPC_SC_OnItemDelPet = {
					"int",
					"int",
					"int"
				},
				RPC_SC_OnEggHatched = {
					"string",
					"int"
				},
				RPC_SC_OnPetBehaviorStart = {
					"string",
					"int",
					"int"
				},
				RPC_SC_OnPetMove = {
					"int",
					"int",
					"int",
					"int",
					"boolean"
				},
				RPC_SC_GivePetToSpaceFollowerRet = {
					"table"
				}
			},
			ComponentMethod = {
				EVENT_EnterScene = true,
				EVENT_OnCharacterStateChange = true,
				onQuickCapture = true,
				OnPetEat = true,
				OnPetProud = true,
				EVENT_OnTeleport = true,
				onEnterSpace = true,
				onSkeletonLoaded = true,
				EVENT_LoseControlled = true,
				EVENT_AddEComponent = true,
				EVENT_ResetAllStateByEscape = true,
				EVENT_ResetScene = true
			},
			PropertyCallbacks = {
				changed = {
					petVariantFriendMap = {
						"customDict",
						"on_petVariantFriendMap_changed"
					},
					["pets.*.customName"] = {
						"string",
						"on_customNameChanged"
					},
					["pets.*.controlCharacter"] = {
						"number",
						"on_controlCharacter_changed"
					},
					["pets.*.followCharacter"] = {
						"number",
						"on_followCharacter_changed"
					},
					["pets.*.label"] = {
						"number",
						"onPetInfoLabelChange"
					},
					["pets.*.talentList"] = {
						"customList",
						"onPetTalentListChanged"
					},
					curPetVisible = {
						"boolean",
						"on_curPetVisible_changed"
					},
					["petBoxMap.*"] = {
						"customDict",
						"onPetBoxMapValueChanged"
					},
					["petBoxMap.sequence"] = {
						"customList",
						"onPetBoxMapSequenceChanged"
					},
					["petBoxMap.*.customName"] = {
						"string",
						"onPetBoxMapCustomNameChanged"
					},
					inExploreState = {
						"boolean",
						"onPetInExploreStateChanged"
					},
					["petBoxMap.*.isNew"] = {
						"boolean",
						"onPetBoxMapIsNewChanged"
					},
					petActionMode = {
						"number",
						"onPetActionModeChanged"
					},
					curSocialId = {
						"string",
						"on_curSocialId_changed"
					},
					["pets.*.isFavorite"] = {
						"boolean",
						"onPetFavoriteChanged"
					},
					["pets.*.favoriteType"] = {
						"number",
						"onPetFavoriteTypeChanged"
					},
					["pets.*.curAbilityPreset"] = {
						"number",
						"on_petCurAbilityPresetChanged"
					},
					["petTransmogInfoMap.*.selectTransmogScheme"] = {
						"customDict",
						"on_petSelectTransmogScheme_changed"
					},
					switchPetForceCount = {
						"number",
						"onSwitchPetForceCountChange"
					},
					curCombatPetId = {
						"string",
						"onCurCombatPetIdChange"
					},
					controlState = {
						"number",
						"onControlStateChange"
					},
					exploreAbilityIndex = {
						"number",
						"onExploreAbilityIndexChange"
					},
					enableForceChangeCombatPet = {
						"boolean",
						"on_enableForceChangeCombatPet_changed"
					},
					isUsingExtraTempPet = {
						"boolean",
						"onIsUsingExtraTempPet"
					},
					forceControl = {
						"boolean",
						"onForceControlChanged"
					},
					petTeamType = {
						"number",
						"onPetTeamTypeChanged"
					},
					carryObjId = {
						"string",
						"onCarryObjIdChanged"
					},
					petPrepareList = {
						"customList",
						"onPetPrepareListChanged"
					}
				},
				entryDeleted = {
					petBoxMap = {
						"customDict",
						"onPetBoxMapEntryDeleted"
					}
				},
				entryAdded = {
					petBoxMap = {
						"customDict",
						"onPetBoxMapEntryAdded"
					},
					petTransmogInfoMap = {
						"customDict",
						"on_petTransmogInfoMap_entry_added"
					}
				},
				itemInserted = {
					petPrepareList = {
						"customList",
						"onPetPrepareListAdd"
					}
				}
			}
		},
		ClientPetsEducationComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPetsEducationComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnUnequipCoreCarry = {
					"string",
					"int",
					"int"
				},
				RPC_SC_OnEquipCoreCarry = {
					"string",
					"int",
					"int"
				},
				RPC_SC_OnAssistCarryChange = {
					"string"
				},
				RPC_SC_OnUpgradeCoreCarry = {
					"int",
					"int",
					"int"
				}
			},
			ClientOnlyMsg = {
				clientAddAssistCarry = {
					"int",
					"int",
					"int",
					"int",
					"int"
				},
				RPC_CS_RemoveAssistCarry = {
					"int",
					"int",
					"int"
				},
				RPC_CS_ComposeAssistCarry = {
					"table"
				}
			}
		},
		ClientPetsExchangeComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPetsExchangeComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_CommonSwitchStateChanged = true
			}
		},
		ClientPetsFormationComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPetsFormationComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnChangePrepareFormation = {
					"int",
					"table"
				},
				RPC_SC_OnRenamePrepareFormation = {
					"int",
					"string"
				}
			},
			PropertyCallbacks = {
				changed = {
					["prepareFormationList.*.formation"] = {
						"customList",
						"on_formation_changed"
					},
					["prepareFormationList.*.exploreFormation"] = {
						"customList",
						"on_exploreFormation_changed"
					},
					curPetFormationIndex = {
						"number",
						"on_curPetFormationIndex_changed"
					}
				}
			}
		},
		ClientPetsVariantInteractComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPetsVariantInteractComponent",
			Properties = {}
		},
		ClientPhotoStudioComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPhotoStudioComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_NotifyPhotoStudioMsg = {
					"table"
				},
				RPC_SC_SendMainPhotoStudioMsg = {
					"table"
				},
				RPC_SC_SendSpecifyPhotoStudioMsg = {
					"table"
				}
			},
			ComponentMethod = {
				onEnterSpace = true,
				onLeaveSpace = true
			},
			PropertyCallbacks = {
				changed = {
					photoStudioUnlockMap = {
						"customDict",
						"on_photoStudioUnlockMap_changed"
					}
				}
			}
		},
		ClientPhotographyStudioComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPhotographyStudioComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SyncPhotographyStudios = {
					"table"
				},
				RPC_SC_SyncPhotographyStudio = {
					"string",
					"table"
				},
				RPC_SC_RemovePhotographyStudio = {
					"string"
				},
				RPC_SC_UpdatePhotographyStudioName = {
					"string",
					"string"
				},
				RPC_SC_SyncPhotographyStudioInvitaions = {
					"table",
					"table"
				},
				RPC_SC_EnterPhotographyStudio = {
					"string",
					"string"
				},
				RPC_SC_LeavePhotographyStudio = {
					"string",
					"string"
				},
				RPC_SC_AcceptInvitePhotographyStudio = {
					"string"
				},
				RPC_SC_UpdatePhotographyStudioContent = {
					"string",
					"string",
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					profilePhotographyStudioUid = {
						"string",
						"on_profilePhotographyStudioUid_changed"
					}
				}
			}
		},
		ClientPlayerActivityComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerActivityComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_NotifyActivityStageInfo = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					activityBattlePass = {
						"customDict",
						"on_activityBattlePass_changed"
					},
					activityLittleFirePerson = {
						"customDict",
						"on_activityLittleFirePerson_changed"
					},
					fishingCaptureCurPhase = {
						"number",
						"on_fishingCaptureCurPhase_changed"
					},
					["activityFishingCapture.activityBase"] = {
						"customDict",
						"on_activityFishingCapture_activityBase_changed"
					},
					activityFishingCapture = {
						"customDict",
						"on_activityFishingCapture_changed"
					},
					["activityFishingCapture.irisRewardReceived"] = {
						"boolean",
						"on_activityFishingCapture_irisRewardReceived_changed"
					},
					["sparkStreakDaysMap.*"] = {
						"number",
						"on_sparkStreakDaysMap_changed"
					},
					["sparkLastLightDayMap.*"] = {
						"number",
						"on_sparkLastLightDayMap_changed"
					}
				},
				entryAdded = {
					sparkStreakDaysMap = {
						"customDict",
						"on_sparkStreakDaysMap_entry_added"
					},
					sparkLastLightDayMap = {
						"customDict",
						"on_sparkLastLightDayMap_entry_added"
					}
				}
			}
		},
		ClientPlayerActivityPlatformComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerActivityPlatformComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_NotifyActivityDayUpdated = {},
				RPC_SC_TapTapStoreEvaluate = {},
				RPC_SC_EnergyMatchScore = {
					"int"
				},
				RPC_SC_NotifyActivityTaskFinished = {
					"int",
					"int"
				},
				RPC_SC_ExchangeGiftCodeResult = {
					"string",
					"int",
					"int",
					"string"
				},
				RPC_SC_NtfShopCidList = {
					"table"
				},
				RPC_SC_GetGuideMiniProgramCode = {
					"string"
				},
				RPC_SC_ReportFirebaseLog = {
					"string",
					"table"
				},
				RPC_SC_ReportWeGameLog = {
					"string",
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					["cafeGatheringDailyAcquired.*"] = {
						"number",
						"on_cafeGatheringDailyAcquired_changed"
					},
					["luckyPetIdFinish.*"] = {
						"boolean",
						"on_luckyPetIdFinish_changed"
					},
					["luckyPetIdSubmit.*"] = {
						"boolean",
						"on_luckyPetIdSubmit_changed"
					},
					["formResearchFinish.*"] = {
						"boolean",
						"on_formResearchFinish_changed"
					},
					["formResearchRewarded.*"] = {
						"boolean",
						"on_formResearchRewarded_changed"
					},
					["energyMatchAwardFlag.*"] = {
						"number",
						"on_energyMatchAwardFlag_changed"
					},
					["activityEcoTrace.ecoTraceSearchMarkId"] = {
						"number",
						"onGetTraceSearchMarkIdCallback"
					},
					ecoTraceFinishRewardFlag = {
						"boolean",
						"onEcoTraceFinishRewardFlagChange"
					},
					arkCarnVotePet = {
						"customDict",
						"onArkCarnVotePetChanged"
					},
					["arkCarnTasks.*.state"] = {
						"number",
						"onArkCarnTaskStateChanged"
					},
					["arkCarnStageState.*"] = {
						"number",
						"onArkCarnStageStateChanged"
					},
					areaActPetResearchOpen = {
						"customDict",
						"onAreaActPetResearchOpenChanged"
					},
					["activityRechargeRebate.rechargeSum"] = {
						"number",
						"on_rechargeSum_changed"
					},
					["activityPetHatch.totalAccelHatchTime"] = {
						"number",
						"on_totalAccelHatchTime_changed"
					}
				},
				entryAdded = {
					formResearchClueMap = {
						"customDict",
						"on_formResearchClueMap_value_entryAdded"
					},
					energyMatchAwardFlag = {
						"customDict",
						"on_energyMatchAwardFlag_entryAdded"
					},
					arkCarnVotePet = {
						"customDict",
						"on_arkCarnVotePet_entryAdded"
					},
					arkCarnStageState = {
						"customDict",
						"on_arkCarnStageState_entryAdded"
					}
				},
				itemInserted = {
					arkCarnPhotoTakedPets = {
						"customList",
						"onAddPhotoTakedPet"
					}
				}
			}
		},
		ClientPlayerBadgeCollectionComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerBadgeCollectionComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_UpQuality = {
					"table"
				},
				RPC_SC_TaskComplete = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					["badgeCollection.moneySum"] = {
						"number",
						"onBadgeCollectionMoney_changed"
					},
					badgeCollection = {
						"customDict",
						"onBadgeCollection_changed"
					},
					isAwaitingOpenReward = {
						"boolean",
						"onIsAwaitingOpenReward_changed"
					},
					badgeCollectionPeriod = {
						"number",
						"onBadgeCollectionPeriod_changed"
					}
				}
			}
		},
		ClientPlayerBadgeComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerBadgeComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					["badgeStatusMap.*"] = {
						"number",
						"onBadgeState_changed"
					},
					badgeShowMap = {
						"customDict",
						"on_badgeShowMap_changed"
					}
				},
				entryAdded = {
					badgeStatusMap = {
						"customDict",
						"onBadgeState_add"
					}
				}
			}
		},
		ClientPlayerBossRushComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerBossRushComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_BossRushPlayerReconnect = {
					"table"
				},
				RPC_SC_BossRushGotoGuanka = {
					"int"
				},
				RPC_SC_BossRushNtfOpenChangeBoss = {
					"int"
				},
				RPC_SC_BossRushNtfCancelOpen = {},
				RPC_SC_BossRushSettle = {
					"table"
				},
				RPC_SC_BossRushAssistInfo = {
					"table"
				},
				RPC_SC_BossRushQuitAndSettle = {
					"int"
				},
				RPC_SC_BossRushSetBatPetList = {
					"int"
				},
				RPC_SC_OnResult = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					curBossRushSeasonId = {
						"number",
						"onCurBossRushSeasonIdChanged"
					},
					bossRushSeasonRewardRecved = {
						"customDict",
						"onBossRushSeasonRewardMapChanged"
					},
					["curBossRushSeasonData.*.bossBestGrade"] = {
						"customDict",
						"onBossRushSeasonBestGradeMapChanged"
					}
				}
			}
		},
		ClientPlayerCarryComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerCarryComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_CarryOp = {
					"int",
					"table"
				}
			},
			ComponentMethod = {
				EVENT_OnCharacterStateChange = true,
				onLeaveSpace = true,
				EVENT_OnMoveInputStateChanged = true
			}
		},
		ClientPlayerCatchRogueComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerCatchRogueComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_CatchRogueNotify = {
					"int",
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					["catchRogueInfo.floorId"] = {
						"number",
						"on_floorId_changed"
					},
					["catchRogueInfo.ballList"] = {
						"customList",
						"on_catchRogue_ballList_changed"
					},
					["catchRogueInfo.ballCountMap"] = {
						"customDict",
						"on_catchRogue_ballCountMap_changed"
					},
					["catchRogueInfo.savedPuppetMap"] = {
						"customDict",
						"on_catchRogue_savedPuppetMap_changed"
					}
				}
			}
		},
		ClientPlayerCommonExchangeComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerCommonExchangeComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnCommonExchangeFail = {
					"int",
					"int"
				}
			}
		},
		ClientPlayerFishingCaptureComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerFishingCaptureComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_FishingCaptureNotify = {
					"int",
					"table"
				}
			},
			ComponentMethod = {
				onEnterSpace = true,
				onLeaveSpace = true
			}
		},
		ClientPlayerHomeCampComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeCampComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_HomeCampOp = {
					"int",
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					campDispatchInfo = {
						"customDict",
						"on_campDispatchInfo_changed"
					},
					["homeBasicInfo.upgradeEndTs"] = {
						"number",
						"on_homeBasicInfo_upgradeEndTs_changed"
					},
					["homeBasicInfo.level"] = {
						"number",
						"on_homeBasicInfo_level_changed"
					},
					campSpaceKeyMap = {
						"customDict",
						"on_campSpaceKeyMap_changed"
					},
					curCampStaticId = {
						"number",
						"on_curCampStaticId_changed"
					},
					statHomeCarOrnament = {
						"customDict",
						"on_statHomeCarOrnament_changed"
					}
				},
				entryAdded = {
					campSpaceKeyMap = {
						"customDict",
						"on_campSpaceKeyMap_added"
					}
				},
				entryDeleted = {
					campSpaceKeyMap = {
						"customDict",
						"on_campSpaceKeyMap_delete"
					}
				}
			}
		},
		ClientPlayerHomeHandbookComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeHandbookComponent",
			Properties = {},
			PropertyCallbacks = {
				entryAdded = {
					homeHandbookMap = {
						"customDict",
						"onHomeHandbookItem_added"
					},
					["homeHandbookMap.homeHandbookCategoryCount"] = {
						"customDict",
						"onHomeHandbookCategoryCount_added"
					},
					["homeHandbookMap.homeHandbookSeasonCount"] = {
						"customDict",
						"onHomeHandbookSeasonCount_added"
					},
					receivedCategoryRewards = {
						"customDict",
						"onHomeHandbookReceivedCategoryReward_added"
					}
				},
				entryDeleted = {
					homeHandbookMap = {
						"customDict",
						"onHomeHandbookItem_deleted"
					}
				},
				changed = {
					["homeHandbookMap.*"] = {
						"customDict",
						"onHomeHandbookItem_changed"
					},
					["homeHandbookMap.*.count"] = {
						"number",
						"onHomeHandbookItemCount_changed"
					},
					["homeHandbookMap.homeHandbookScore"] = {
						"number",
						"onHomeHandbookScore_changed"
					},
					["homeHandbookMap.homeHandbookCategoryCount.*"] = {
						"number",
						"onHomeHandbookCategoryCount_changed"
					},
					["homeHandbookMap.homeHandbookSeasonCount.*"] = {
						"number",
						"onHomeHandbookSeasonCount_changed"
					},
					["receivedCategoryRewards.*"] = {
						"number",
						"onHomeHandbookReceivedCategoryReward_changed"
					},
					lastReceivedGrade = {
						"number",
						"onHomeHandbookLastReceivedGrade_changed"
					},
					lastViewedGrade = {
						"number",
						"onHomeHandbookLastViewedGrade_changed"
					}
				}
			}
		},
		ClientPlayerHomeOrderComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeOrderComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_NotifyHomeOrderTimedRefresh = {
					"int"
				}
			},
			PropertyCallbacks = {
				changed = {
					showList = {
						"customList",
						"onHomeOrderList_changed"
					},
					orderRefreshCount = {
						"number",
						"onHomeOrderUsed_changed"
					},
					nextRefreshTime = {
						"number",
						"onHomeOrderTime_changed"
					}
				}
			}
		},
		ClientPlayerHomeSeasonComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeSeasonComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					homeSeasonId = {
						"number",
						"onHomeSeasonId_changed"
					},
					homeSeasonUnlockTs = {
						"number",
						"onHomeSeasonUnlockTs_changed"
					},
					homeSeasonStageId = {
						"number",
						"onHomeSeasonStageId_changed"
					},
					homeSeasonOrderList = {
						"customList",
						"onHomeSeasonOrderList_changed"
					},
					homeSeasonCollectionScore = {
						"number",
						"onHomeSeasonCollectionScore_changed"
					},
					homeSeasonCollectionRewardStateMap = {
						"customDict",
						"onHomeSeasonCollectionRewardStateMap_changed"
					},
					["homeSeasonCollectionRewardStateMap.*"] = {
						"number",
						"onHomeSeasonCollectionRewardState_changed"
					},
					homeSeasonTaskStateMap = {
						"customDict",
						"onHomeSeasonTaskStateMap_changed"
					},
					["homeSeasonTaskStateMap.*"] = {
						"number",
						"onHomeSeasonTaskState_changed"
					},
					homeSeasonTaskPendingRewardMap = {
						"customDict",
						"onHomeSeasonTaskPendingRewardMap_changed"
					},
					["homeSeasonTaskPendingRewardMap.*"] = {
						"number",
						"onHomeSeasonTaskPendingReward_changed"
					}
				},
				entryAdded = {
					homeSeasonCollectionRewardStateMap = {
						"customDict",
						"onHomeSeasonCollectionRewardState_added"
					},
					homeSeasonTaskStateMap = {
						"customDict",
						"onHomeSeasonTaskState_added"
					},
					homeSeasonTaskPendingRewardMap = {
						"customDict",
						"onHomeSeasonTaskPendingReward_added"
					}
				},
				entryDeleted = {
					homeSeasonCollectionRewardStateMap = {
						"customDict",
						"onHomeSeasonCollectionRewardState_deleted"
					},
					homeSeasonTaskStateMap = {
						"customDict",
						"onHomeSeasonTaskState_deleted"
					},
					homeSeasonTaskPendingRewardMap = {
						"customDict",
						"onHomeSeasonTaskPendingReward_deleted"
					}
				}
			}
		},
		ClientPlayerHomeSeasonMutationComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerHomeSeasonMutationComponent",
			Properties = {}
		},
		ClientPlayerHomelandComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerHomelandComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_HomeVoucherSnapshot = {
					"double",
					"double",
					"double",
					"double",
					"boolean",
					"table"
				},
				RPC_SC_NotifyMutationUnlock = {
					"table"
				},
				RPC_SC_SyncFullHomelandHatchInfo = {
					"table"
				},
				RPC_SC_HomelandFoodOp = {
					"int",
					"table"
				},
				RPC_SC_HomelandDemoReset = {},
				RPC_SC_HomeBlueprintOp = {
					"string",
					"table"
				}
			},
			ComponentMethod = {
				onEnterSpace = true
			},
			PropertyCallbacks = {
				entryAdded = {
					petPutInHomelandMap = {
						"customDict",
						"on_petPutInHomelandMap_entry_added"
					},
					statUnlockHomelandZone = {
						"customDict",
						"on_unlockHomelandZone_added"
					},
					unlockedHomelandFormulaMap = {
						"customDict",
						"on_unlockedHomelandFormulaMap_entry_added"
					},
					unlockedHomelandFurnitureMap = {
						"customDict",
						"on_unlockedHomelandFurnitureMap_entry_added"
					}
				},
				entryDeleted = {
					petPutInHomelandMap = {
						"customDict",
						"on_petPutInHomelandMap_entry_deleted"
					},
					unlockedHomelandFormulaMap = {
						"customDict",
						"on_unlockedHomelandFormulaMap_entry_deleted"
					},
					unlockedHomelandFurnitureMap = {
						"customDict",
						"on_unlockedHomelandFurnitureMap_entry_deleted"
					}
				},
				changed = {
					statHomelandOrnament = {
						"customDict",
						"on_statHomelandOrnament_changed"
					},
					singlePlantReward = {
						"customDict",
						"onHomePlantSinglePlantReward_changed"
					},
					plantBookRewardMap = {
						"customDict",
						"onHomePlantProcessReward_changed"
					},
					["plantBook.*"] = {
						"customDict",
						"onHomePlantCollection_changed"
					},
					pinnedFormulaList = {
						"customList",
						"onPinnedFormulaList_changed"
					}
				}
			}
		},
		ClientPlayerInteractComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerInteractComponent",
			Properties = {},
			ComponentMethod = {
				onEnterSpace = true
			},
			PropertyCallbacks = {
				entryAdded = {
					interactRecord = {
						"customDict",
						"onInteractRecord_add"
					},
					npcDialogueBubbleId = {
						"customDict",
						"on_npcDialogueBubbleId_added"
					}
				},
				entryDeleted = {
					interactRecord = {
						"customDict",
						"onInteractRecord_deleted"
					},
					npcDialogueBubbleId = {
						"customDict",
						"on_npcDialogueBubbleId_deleted"
					}
				},
				changed = {
					["npcDialogueBubbleId.*"] = {
						"number",
						"on_npcDialogueBubbleId_changed"
					}
				}
			}
		},
		ClientPlayerInteractNpcComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerInteractNpcComponent",
			Properties = {}
		},
		ClientPlayerMmoItemComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerMmoItemComponent",
			Properties = {
				mmoItemCoolDownMap = {
					"MmoItemCoolDownMap",
					{},
					"OwnClient",
					"PER"
				}
			},
			PropertyCallbacks = {
				changed = {
					["mmoItemCoolDownMap.*.*"] = {
						"number",
						"on_mmoItemCoolDownMap_cdTime_changed"
					}
				},
				entryAdded = {
					["mmoItemCoolDownMap.*"] = {
						"customDict",
						"on_mmoItemCoolDownMap_cdTime_added"
					}
				}
			}
		},
		ClientPlayerNpcDuelComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerNpcDuelComponent",
			Properties = {
				curNpcDuelId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				curNpcDuelVariantId = {
					"int",
					0,
					"OwnClient",
					"PER"
				},
				npcDuelState = {
					"IntIntMap",
					{},
					"OwnClient",
					"PER"
				},
				npcDuelBasicInfo = {
					"NpcDuelBasicInfo",
					{},
					"OwnClient",
					"PER"
				},
				npcDuelBotInfo = {
					"NpcDuelBotInfo",
					{},
					"OwnClient",
					"PER"
				},
				npcDuelShowedPetList = {
					"NpcDuelShowedPetList",
					{},
					"OwnClient",
					"PER"
				}
			},
			ServerOnlyMsg = {
				RPC_SC_PrepareForNpcDuel = {
					"table"
				},
				RPC_SC_OnNpcDuelAllUnitEnterCombat = {},
				RPC_SC_OnStartNpcDuelDialogue = {
					"table"
				},
				RPC_SC_OnStartNpcDuelClearDialogue = {
					"table"
				},
				RPC_SC_OnNpcDuelPlayEndStateDialogue = {
					"table"
				},
				RPC_SC_OnNpcDuelPetDeath = {
					"string",
					"string"
				},
				RPC_SC_OnNpcDuelAllPetDeath = {
					"boolean"
				},
				RPC_SC_NpcDuelEnd = {
					"boolean"
				},
				RPC_SC_NpcDuelInitFailed = {}
			},
			PropertyCallbacks = {
				changed = {
					["npcDuelState.*"] = {
						"number",
						"onNpcDuelStateChanged"
					}
				},
				entryAdded = {
					npcDuelState = {
						"customDict",
						"onNpcDuelStateAdded"
					}
				}
			}
		},
		ClientPlayerPipelineComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerPipelineComponent",
			Properties = {},
			PropertyCallbacks = {
				entryAdded = {
					hideVegetationMap = {
						"customDict",
						"on_hideVegetationMapentry_added"
					}
				},
				entryDeleted = {
					hideVegetationMap = {
						"customDict",
						"on_hideVegetationMapentry_deleted"
					}
				},
				changed = {
					["hideVegetationMap.*"] = {
						"customList",
						"on_hideVegetationMap_item_changed"
					}
				}
			}
		},
		ClientPlayerQuizComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerQuizComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SendQuizResult = {
					"boolean",
					"int",
					"boolean"
				},
				RPC_SC_SendQuizQuestion = {
					"int",
					"table",
					"boolean"
				},
				RPC_SC_SendLastQuestion = {
					"int",
					"table"
				},
				RPC_SC_SendQuizSubmitted = {
					"boolean"
				},
				RPC_SC_QuizPanelActive = {
					"int"
				}
			}
		},
		ClientPlayerRiftComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerRiftComponent",
			Properties = {}
		},
		ClientPlayerRobEggComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerRobEggComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_NotifyEntityVisibleChangeInHighGrass = {
					"table",
					"boolean"
				},
				RPC_SC_RobEggLimitTimeEvent = {
					"string",
					"table"
				}
			},
			ComponentMethod = {
				notifyBuffTagChange = true
			},
			PropertyCallbacks = {
				changed = {
					lastFallenAidActorId = {
						"number",
						"onLastFallenAidActorIdChange"
					},
					forceControlEgg = {
						"boolean",
						"onForceControlEggChanged"
					}
				}
			}
		},
		ClientPlayerRogueComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerRogueComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_StartRogue = {},
				RPC_SC_AddRogueUltimateAbility = {
					"int"
				},
				RPC_SC_UpgradeRogueUltimateAbility = {
					"int",
					"int",
					"table"
				},
				RPC_SC_BeforeRogueDiceReward = {},
				RPC_SC_SyncRogueDiceReward = {
					"int",
					"table",
					"int"
				},
				RPC_SC_ReqRogueExchangeRewardResult = {
					"int",
					"table",
					"table",
					"table",
					"table"
				}
			},
			ComponentMethod = {
				EVNET_OnMoneyChange = true
			},
			PropertyCallbacks = {
				changed = {
					rogueTalentLevelUnlock = {
						"customDict",
						"onRogueTalentLevelUnlockChanged"
					},
					rogueTalentNodeLvMap = {
						"customDict",
						"onRogueTalentNodeLvMapChanged"
					},
					rogueTalentExp = {
						"number",
						"onRogueTalentExpChanged"
					},
					rogueWeeklyBossKillCount = {
						"number",
						"onRogueWeeklyBossKillCountChanged"
					},
					rogueWeeklyBossRewardInfo = {
						"customDict",
						"onRogueWeeklyBossRewardInfoChanged"
					},
					rogueSeasonId = {
						"number",
						"onRogueSeasonIdChanged"
					},
					rogueSeasonLevelPassInfo = {
						"customDict",
						"onRogueSeasonLevelPassInfoChanged"
					},
					rogueWeeklyLevelPassInfo = {
						"customDict",
						"onRogueWeeklyLevelPassInfoChanged"
					},
					rogueWeeklyLevelRewardInfo = {
						"customDict",
						"onRogueWeeklyLevelRewardInfoChanged"
					},
					curRogueLayer = {
						"number",
						"onCurRogueLayerChanged"
					},
					curRogueLevel = {
						"number",
						"onCurRogueLevelChanged"
					},
					["rogueCombatData.*"] = {
						"number",
						"onRogueDataValueChange"
					},
					["rogueBuffs.*"] = {
						"number",
						"onRogueBuffsValueChanged"
					},
					curOptionList = {
						"customList",
						"onCurOptionListChanged"
					},
					rogueHarvestPendingRewards = {
						"customList",
						"onRogueHarvestPendingRewardsChanged"
					}
				},
				entryAdded = {
					rogueCombatData = {
						"customDict",
						"onRogueDataValueAdd"
					},
					rogueBuffs = {
						"customDict",
						"onRogueBuffsValueAdd"
					}
				},
				entryDeleted = {
					entityTag = {
						"customDict",
						"onRogueDataValueRemove"
					},
					rogueBuffs = {
						"customDict",
						"onRogueBuffsValueRemove"
					}
				}
			}
		},
		ClientPlayerSandboxComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerSandboxComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_PlayChestRewardAttract = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					interactLevelItemPrototypeId = {
						"number",
						"on_interactLevelItemPrototypeId_changed"
					}
				}
			}
		},
		ClientPlayerSlotMachineComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerSlotMachineComponent",
			Properties = {}
		},
		ClientPlayerTargetComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerTargetComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ShowTarget = {
					"int"
				},
				RPC_SC_UpdateTarget = {
					"int",
					"int"
				},
				RPC_SC_CompleteSubTarget = {
					"int",
					"table"
				},
				RPC_SC_FlushSubTarget = {
					"int",
					"int",
					"int",
					"int"
				},
				RPC_SC_DelTarget = {
					"int"
				},
				RPC_SC_timerStart = {
					"int"
				},
				RPC_SC_timerClose = {
					"int",
					"int"
				},
				RPC_SC_setTimerTxt = {
					"string"
				},
				RPC_SC_resetTimerTxt = {},
				RPC_SC_SynTimer = {
					"int",
					"int"
				}
			}
		},
		ClientPlayerTradeComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerTradeComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_TradeListResult = {
					"int",
					"string"
				},
				RPC_SC_TradeListingsResult = {
					"table",
					"string",
					"int",
					"int",
					"table",
					"int"
				},
				RPC_SC_TradeListingsByPriceResult = {
					"string",
					"string",
					"int",
					"int",
					"table",
					"int"
				},
				RPC_SC_TradeMyListingsResult = {
					"table"
				},
				RPC_SC_TradeRecordsResult = {
					"int",
					"int",
					"int",
					"table",
					"int"
				},
				RPC_SC_TradeOverviewResult = {
					"int",
					"int",
					"table"
				},
				RPC_SC_TradeBuyResult = {
					"int",
					"int",
					"string",
					"int"
				},
				RPC_SC_TradeBuyByPriceResult = {
					"string",
					"int",
					"int",
					"int"
				}
			},
			PropertyCallbacks = {
				entryAdded = {
					tradeWatchList = {
						"customDict",
						"onTradeWatchAdded"
					}
				},
				entryDeleted = {
					tradeWatchList = {
						"customDict",
						"onTradeWatchDeleted"
					}
				}
			}
		},
		ClientPlayerVehicleComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientPlayerVehicleComponent",
			Properties = {}
		},
		ClientQuestComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientQuestComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SendQuestObjectiveChange = {
					"int",
					"int",
					"boolean"
				},
				RPC_SC_SendQuestComActionObjectiveChange = {
					"int"
				},
				RPC_SC_SendQuestRunStateChange = {
					"int",
					"boolean"
				},
				RPC_SC_SendQuestStateInfo = {
					"int",
					"int"
				},
				RPC_SC_openNpcPhoneUI = {
					"int",
					"int",
					"int"
				},
				RPC_SC_ClueQuestRevealFlagChanged = {
					"int",
					"boolean"
				},
				RPC_SC_ClearSideQuestAiTip = {},
				RPC_SC_ToFillQuestFirstTrace = {
					"int"
				},
				RPC_SC_TimeTokenReached = {
					"int"
				}
			},
			PropertyCallbacks = {
				changed = {
					curTraceQuest = {
						"number",
						"on_curTraceQuest_changed"
					},
					curTraceStoryQuest = {
						"number",
						"on_curTraceStoryQuest_changed"
					},
					curTraceTempQuest = {
						"number",
						"on_curTraceTempQuest_changed"
					},
					curTraceSecondQuest = {
						"number",
						"on_curTraceSecondQuest_changed"
					}
				}
			}
		},
		ClientRankComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientRankComponent",
			Properties = {}
		},
		ClientRoomComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientRoomComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_RoomAbnormalExit = {
					"table"
				}
			}
		},
		ClientScentTrackingComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientScentTrackingComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_onControlPetSwitchToPlayer = true,
				EVENT_OnPetDestroy = true,
				EVENT_onControlPlayerSwitchToPet = true,
				onLeaveCombat = true,
				onEnterCombat = true,
				EVENT_OnPetLifeDead = true,
				EVENT_onControlPetSwitchToAnotherPet = true
			}
		},
		ClientScreenComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientScreenComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SyncArkScreenInfo = {
					"table"
				}
			}
		},
		ClientShopComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientShopComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_ShopMallGiveCommodity = {
					"number"
				}
			},
			PropertyCallbacks = {
				changed = {
					shopLimitCounts = {
						"customDict",
						"on_shopLimitCounts_changed"
					},
					shopLevelCounts = {
						"customDict",
						"on_shopLevelCounts_changed"
					}
				}
			}
		},
		ClientSocialComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientSocialComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SocialQueryReply = {
					"int",
					"string",
					"table"
				},
				RPC_SC_SocialInvite = {
					"int",
					"string",
					"table"
				},
				RPC_SC_SocialInviteReply = {
					"int",
					"string",
					"table"
				},
				RPC_SC_OnSocialStart = {
					"string",
					"table"
				},
				RPC_SC_SocialClientNotify = {
					"string",
					"int",
					"table"
				},
				RPC_SC_OnSocialEnd = {
					"string"
				},
				RPC_SC_PsnAuthCodeRequired = {
					"table"
				}
			},
			ComponentMethod = {
				onEnterSpace = true
			}
		},
		ClientSpaceSeamlessComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientSpaceSeamlessComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_CheckSeamlessConditionFail = {
					"boolean"
				},
				RPC_SC_EnterPhase = {}
			},
			ComponentMethod = {
				EVENT_EnterScene = true,
				EVENT_LeaveScene = true
			},
			PropertyCallbacks = {
				changed = {
					regionId = {
						"number",
						"on_regionId_changed"
					}
				}
			}
		},
		ClientSpaceSpawnerEntityComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientSpaceSpawnerEntityComponent",
			Properties = {},
			ComponentMethod = {
				onEnterSpace = true,
				tick = true
			},
			PropertyCallbacks = {
				entryAdded = {
					hideShowEntityDict = {
						"customDict",
						"on_hideShowEntityDict_entry_added"
					},
					hideShowEntityInfo = {
						"customDict",
						"on_hideShowEntityInfo_entry_added"
					},
					specialNpcDict = {
						"customDict",
						"on_specialNpcDict_entry_added"
					},
					hideShowTitleDict = {
						"customDict",
						"on_hideShowTitleDict_entry_added"
					},
					specialContentDict = {
						"customDict",
						"on_specialContentDict_entry_added"
					}
				},
				entryDeleted = {
					hideShowEntityDict = {
						"customDict",
						"on_hideShowEntityDict_entry_deleted"
					},
					hideShowEntityInfo = {
						"customDict",
						"on_hideShowEntityInfo_entry_deleted"
					},
					specialNpcDict = {
						"customDict",
						"on_specialNpcDict_entry_deleted"
					},
					specialContentDict = {
						"customDict",
						"on_specialContentDict_entry_deleted"
					}
				},
				changed = {
					["hideShowEntityDict.*"] = {
						"number",
						"on_hideShowEntityDict_item_changed"
					},
					["hideShowEntityInfo.*"] = {
						"customDict",
						"on_hideShowEntityInfo_item_changed"
					},
					["hideShowTitleDict.*"] = {
						"boolean",
						"on_hideShowTitleDict_item_changed"
					},
					["specialContentDict.*"] = {
						"number",
						"on_specialContentDict_item_changed"
					}
				}
			}
		},
		ClientSpecialTrainComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientSpecialTrainComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_StartSpecialTrainSystem = {},
				RPC_SC_UnlockSpecialTrainType = {
					"int"
				},
				RPC_SC_UnlockSpecialTrainChapter = {
					"int"
				}
			}
		},
		ClientTeamComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientTeamComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_QueryTeamMemberCount = {
					"string",
					"int"
				},
				RPC_SC_TeamNoticeId = {
					"table",
					"int"
				},
				RPC_SC_SyncTeamInfo = {
					"table"
				},
				RPC_SC_TeamInvited = {
					"string",
					"table",
					"table"
				},
				RPC_SC_DeleteInviterInfo = {
					"string"
				},
				RPC_SC_RequestJoinTeam = {
					"string",
					"table"
				},
				RPC_SC_DeleteJoinInfo = {
					"string"
				},
				RPC_SC_ReceiveEnterWorldRequest = {
					"string",
					"table"
				},
				RPC_SC_ReceiveEnterWorldInvite = {
					"string",
					"table",
					"table"
				},
				RPC_SC_SyncDungeonTeamInfo = {
					"table"
				},
				RPC_SC_SyncDungeonMatchConfirms = {
					"table"
				},
				RPC_SC_DungeonEnterTips = {
					"int",
					"int",
					"table"
				},
				RPC_SC_NewTeamInfo = {},
				RPC_SC_SyncTeamDungeonConfirm = {
					"int",
					"table"
				},
				RPC_SC_GatherTeammate = {
					"string",
					"table"
				},
				RPC_SC_SendBossChallengeReward = {
					"table",
					"table"
				},
				RPC_SC_QuickInviteTeamSpaceFollowRet = {
					"string",
					"int",
					"table"
				},
				RPC_SC_NotifyReqSpaceFollow = {
					"string"
				},
				RPC_SC_NotifyReqSpaceFollowRet = {
					"string",
					"int",
					"table"
				},
				RPC_SC_NotifyInviteSpaceFollowRet = {
					"string",
					"int",
					"table"
				},
				RPC_SC_NotifyInviteSpaceFollow = {
					"string"
				},
				RPC_SC_NotifyRefuseSpaceFollow = {
					"string",
					"int"
				},
				RPC_SC_NotifySpaceFollow = {
					"table"
				},
				RPC_SC_NotifyOtherSpaceFollowInfo = {
					"table"
				},
				RPC_SC_NotifyExitSpaceFollowNotTeamLeader = {},
				RPC_SC_PushTeammateInfo = {
					"string",
					"int",
					"int",
					"boolean",
					"number",
					"number"
				},
				RPC_SC_SyncGenerateUserSig = {
					"string",
					"int"
				}
			},
			ComponentMethod = {
				EVENT_EnterScene = true,
				onSkeletonLoaded = true
			},
			PropertyCallbacks = {
				changed = {
					matchState = {
						"number",
						"on_matchState_changed"
					},
					matchStartTime = {
						"number",
						"on_matchStartTime_changed"
					},
					matchDungeonPlayId = {
						"string",
						"on_matchDungeonPlayId_changed"
					},
					inLeaderWorld = {
						"boolean",
						"on_inLeaderWorld_changed"
					}
				}
			}
		},
		ClientTotemComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientTotemComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnAddTotemExp = {
					"int",
					"table"
				},
				RPC_SC_OnAddTotemAbility = {
					"int",
					"int"
				}
			}
		},
		ClientTriggerComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientTriggerComponent",
			Properties = {},
			ComponentMethod = {
				onEnterSpace = true
			},
			PropertyCallbacks = {
				entryAdded = {
					["triggerMap.questObjectivesTriggers.*.*"] = {
						"customDict",
						"onPositionQuestObjectivesTriggerAdded"
					},
					["triggerMap.questClaimTriggers.*.*"] = {
						"customDict",
						"onPositionQuestClaimTriggerAdded"
					},
					["triggerMap.questRunTriggers.*.*"] = {
						"customDict",
						"onPositionQuestRunTriggerAdded"
					},
					["triggerMap.questComActionObjTriggers.*.*"] = {
						"customDict",
						"onPositionQuestComActionObjTriggerAdded"
					},
					["triggerMap.questCloseTriggers.*.*"] = {
						"customDict",
						"onPositionQuestCloseTriggerAdded"
					},
					["triggerMap.customVariables"] = {
						"customDict",
						"on_triggerMap_customVariables_entry_added"
					}
				},
				entryDeleted = {
					["triggerMap.customVariables"] = {
						"customDict",
						"on_triggerMap_customVariables_entry_deleted"
					}
				},
				changed = {
					["triggerMap.customVariables.*"] = {
						"number",
						"on_triggerMap_customVariables_item_changed"
					},
					["triggerMap.npcBehaviorStatus.*"] = {
						"customDict",
						"on_triggerMap_npcBehaviorStatus_item_changed"
					}
				}
			}
		},
		ClientWeatherComponent = {
			NameSpace = "Entities.SpaceEntities.PlayerComponent.ClientWeatherComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_MeteorologyChanged = {
					"int"
				},
				RPC_SC_ResetMeteor = {}
			},
			PropertyCallbacks = {
				changed = {
					["meteorDict.*"] = {
						"number",
						"onMeteorDict_valueChanged"
					},
					["weatherInfoForecast.*.*.endTime"] = {
						"number",
						"on_weatherInfoForecast_endTime_changed"
					},
					["weatherInfoForecast.*.*.weatherId"] = {
						"number",
						"on_weatherInfoForecast_weatherId_changed"
					},
					["meteorologyInfoMap.*"] = {
						"customDict",
						"on_meteorologyInfoMap_changed"
					}
				},
				entryAdded = {
					meteorDict = {
						"customDict",
						"on_meteorDict_entry_added"
					},
					meteorologyInfoMap = {
						"customDict",
						"on_meteorologyInfoMap_entry_added"
					}
				},
				itemInserted = {
					["weatherInfoForecast.*"] = {
						"customList",
						"on_weatherInfoForecast_entry_added"
					}
				},
				itemRemoved = {
					["weatherInfoForecast.*"] = {
						"customList",
						"on_weatherInfoForecast_delete"
					}
				},
				entryDeleted = {
					meteorologyInfoMap = {
						"customDict",
						"on_meteorologyInfoMap_entry_deleted"
					}
				}
			}
		},
		ClientSimpleMoveComponent = {
			NameSpace = "Entities.SpaceEntities.SimpleMoveComponent.ClientSimpleMoveComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_StartRouteById = {
					"number",
					"number"
				}
			},
			ComponentMethod = {
				EVENT_AddEComponent = true,
				EVENT_OnAnimatorReady = true,
				onEnterSpace = true,
				onTriggerEnter = true
			}
		},
		ClientSpaceAreaComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceAreaComponent",
			Properties = {}
		},
		ClientSpaceArkScreenComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceArkScreenComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SyncArkScreenInfo = {
					"table"
				}
			},
			PropertyCallbacks = {
				changed = {
					["arkScreenInfoMap.*"] = {
						"customDict",
						"on_arkScreenInfoMap_changed"
					}
				}
			}
		},
		ClientSpaceBattleModeComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceBattleModeComponent",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					supportPetMode = {
						"number",
						"on_supportPetMode_changed"
					},
					battleMode = {
						"number",
						"on_battleMode_changed"
					}
				}
			}
		},
		ClientSpaceFollowComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceFollowComponent",
			Properties = {}
		},
		ClientSpaceGraphComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceGraphComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_DebugCallPort = {
					"int",
					"int",
					"string",
					"int",
					"string"
				},
				RPC_SC_DebugPortIn = {
					"int",
					"int",
					"string",
					"int",
					"string"
				},
				RPC_SC_GraphRunningNode = {
					"int",
					"int",
					"boolean"
				},
				RPC_SC_GraphDebugInfo = {
					"int",
					"table",
					"table",
					"table",
					"table",
					"table"
				}
			}
		},
		ClientSpaceLeylineFlowerComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceLeylineFlowerComponent",
			Properties = {},
			PropertyCallbacks = {
				entryAdded = {
					rainbowPetPosFlags = {
						"customDict",
						"on_rainbowPetPosFlags_entry_added"
					},
					["rainbowPetPosFlags.*"] = {
						"customDict",
						"on_rainbowPetPosFlags_point_added"
					}
				},
				entryDeleted = {
					rainbowPetPosFlags = {
						"customDict",
						"on_rainbowPetPosFlags_entry_deleted"
					},
					["rainbowPetPosFlags.*"] = {
						"customDict",
						"on_rainbowPetPosFlags_point_deleted"
					}
				},
				changed = {
					["rainbowPetPosFlags.*.*"] = {
						"number",
						"on_rainbowPetPosFlags_point_changed"
					}
				}
			}
		},
		ClientSpaceLeylineTreeComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceLeylineTreeComponent",
			Properties = {}
		},
		ClientSpaceLogicTimeComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceLogicTimeComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_OnTimePeriodChange = {
					"int",
					"int",
					"int",
					"boolean",
					"boolean"
				},
				RPC_SC_TideChange = {}
			}
		},
		ClientSpaceMediaMarkerComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceMediaMarkerComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_RemoveMediaMarker = {
					"string",
					"string"
				},
				RPC_SC_AddMediaMarker = {
					"string",
					"string",
					"table"
				},
				RPC_SC_UpdateMediaMarker = {
					"string",
					"string",
					"int",
					"int",
					"int",
					"int"
				}
			}
		},
		ClientSpaceSandboxComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceSandboxComponent",
			Properties = {},
			ServerOnlyMsg = {
				RPC_SC_SyncSandboxInfo = {
					"table",
					"table"
				},
				RPC_SC_ResetSandboxInfo = {
					"table"
				},
				RPC_SC_SwitchSandboxAuthority = {
					"int",
					"string"
				},
				RPC_SC_LevelItemChangeFields = {
					"int",
					"int",
					"table"
				},
				RPC_SC_LevelItemClientMsg = {
					"int",
					"int",
					"string",
					"table"
				},
				RPC_SC_SandboxPhaseChange = {
					"int",
					"int"
				},
				RPC_SC_DebugSandboxInfo = {
					"table"
				},
				RPC_SC_ShowStage = {
					"int",
					"int"
				}
			},
			ComponentMethod = {
				onChunkLoadEvent = true
			},
			PropertyCallbacks = {
				changed = {
					ownerPlayerId = {
						"string",
						"on_ownerPlayerId_changed"
					}
				}
			}
		},
		ClientSpaceTileComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceTileComponent",
			Properties = {}
		},
		ClientSpaceWeatherComponent = {
			NameSpace = "Entities.SpaceEntities.SpaceComponent.ClientSpaceWeatherComponent",
			Properties = {},
			PropertyCallbacks = {
				entryAdded = {
					spaceWeatherInfoMap = {
						"customDict",
						"on_spaceWeatherInfoMap_entry_added"
					},
					meteorologyInfoMap = {
						"customDict",
						"on_meteorologyInfoMap_entry_added"
					}
				},
				changed = {
					["spaceWeatherInfoMap.*"] = {
						"customDict",
						"on_spaceWeatherInfoMap_changed"
					},
					["spaceWeatherInfoMap.*.weatherId"] = {
						"number",
						"on_spaceWeatherInfoMap_weatherId_changed"
					},
					["meteorologyInfoMap.*"] = {
						"customDict",
						"on_meteorologyInfoMap_changed"
					}
				},
				entryDeleted = {
					meteorologyInfoMap = {
						"customDict",
						"on_meteorologyInfoMap_entry_deleted"
					}
				}
			}
		},
		ClientVehicleBodyAnimationComponent = {
			NameSpace = "Entities.SpaceEntities.VehicleEntities.ClientVehicleBodyAnimationComponent",
			Properties = {},
			ComponentMethod = {
				EVENT_OnVehiclePassengerExitFinished = true,
				EVENT_OnVehiclePassengerEnterFinished = true,
				EVENT_onModelLoaded = true
			},
			PropertyCallbacks = {
				changed = {
					vehicleBodyAnimationPassengerCount = {
						"number",
						"on_vehicleBodyAnimationPassengerCount_changed"
					}
				}
			}
		}
	},
	Universal = {
		BeePollenFeature = {
			NameSpace = "Entities.SpaceEntities.DynamicFeature.BeePollenFeature",
			Properties = {}
		},
		FlowScriptNpcFeature = {
			NameSpace = "Entities.SpaceEntities.DynamicFeature.FlowScriptNpcFeature",
			Properties = {}
		},
		LevelFruitFeature = {
			NameSpace = "Entities.SpaceEntities.DynamicFeature.LevelFruitFeature",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					isInTree = {
						"boolean",
						"on_isInTree_Changed"
					}
				}
			}
		},
		LifeFeature = {
			NameSpace = "Entities.SpaceEntities.DynamicFeature.LifeFeature",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					lifeBoolTest = {
						"boolean",
						"on_lifeBoolTest_changed"
					}
				}
			}
		},
		MechanismBallFeature = {
			NameSpace = "Entities.SpaceEntities.DynamicFeature.MechanismBallFeature",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					isTriggered = {
						"boolean",
						"on_isTriggered_Changed"
					}
				}
			}
		},
		ShiningItemFeature = {
			NameSpace = "Entities.SpaceEntities.DynamicFeature.ShiningItemFeature",
			Properties = {},
			PropertyCallbacks = {
				changed = {
					isShining = {
						"boolean",
						"on_isShining_Changed"
					}
				}
			}
		},
		StickerFeature = {
			NameSpace = "Entities.SpaceEntities.DynamicFeature.StickerFeature",
			Properties = {},
			PropertyCallbacks = {
				entryAdded = {
					stickEntities = {
						"customDict",
						"on_stickEntities_entry_added"
					}
				},
				entryDeleted = {
					stickEntities = {
						"customDict",
						"on_stickEntities_entry_deleted"
					}
				}
			}
		},
		TotemWorshipFeature = {
			NameSpace = "Entities.SpaceEntities.DynamicFeature.TotemWorshipFeature",
			Properties = {}
		}
	}
}

return Config
