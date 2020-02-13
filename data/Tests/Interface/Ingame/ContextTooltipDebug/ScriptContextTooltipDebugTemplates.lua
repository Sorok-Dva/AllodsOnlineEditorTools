-- ScriptContextTooltipDebugTemplates.lua
-- Core tooltip template functions for ContextTooltipDebug add-on.
-- 11:55 17.11.2008
--------------------------------------------------------------------------------
-- CONSTANTS
Global( "sysItemQualityStyle", {
	[ ITEM_QUALITY_JUNK ] = "Junk",
	[ ITEM_QUALITY_GOODS ] = "Goods",
	[ ITEM_QUALITY_COMMON ] = "Common",
	[ ITEM_QUALITY_UNCOMMON ] = "Uncommon",
	[ ITEM_QUALITY_RARE ] = "Rare",
	[ ITEM_QUALITY_EPIC ] = "Epic"
} )
Global( "sysUnitQuality", {
	[ UNIT_QUALITY_COMMON ] = "Common",
	[ UNIT_QUALITY_ELITE ] = "Elite",
	[ UNIT_QUALITY_FLAVOR_ELITE ] = "Flavor Elite",
	[ UNIT_QUALITY_MINI_BOSS ] = "Mini Boss",
	[ UNIT_QUALITY_BOSS ] = "Boss",
} )
Global( "sysSpellTargetType", {
	[ SPELL_TYPE_SELF ] = "Self",
	[ SPELL_TYPE_CURRENT_TARGET ] = "Selected",
	[ SPELL_TYPE_POINT ] = "Ground",
	[ SPELL_TYPE_CURRENT_TARGET_NOT_SELF ] = "Not Self"
} )
Global( "sysVendorTypeId", {
	[ VENDOR_NO_VENDOR ] = "VENDOR_NO_VENDOR",
	[ VENDOR_GENERAL ] = "VENDOR_GENERAL",
	[ VENDOR_WEAPON_ARMOR ] = "VENDOR_WEAPON_ARMOR",
	[ VENDOR_CRAFTING_COMPONENTS ] = "VENDOR_CRAFTING_COMPONENTS",
	[ VENDOR_USABLE_ITEMS ] = "VENDOR_USABLE_ITEMS",
	[ VENDOR_GUILD ] = "VENDOR_GUILD",
	[ VENDOR_MYRRH ] = "VENDOR_MYRRH"
} )
Global( "sysQuestMarkId", {
	[ QUEST_MARK_READY_TO_ACCEPT ] = "QUEST_MARK_READY_TO_ACCEPT",
	[ QUEST_MARK_SOON_TO_ACCEPT ] = "QUEST_MARK_SOON_TO_ACCEPT",
	[ QUEST_MARK_READY_TO_GIVE ] = "QUEST_MARK_READY_TO_GIVE",
	[ QUEST_MARK_SOON_TO_GIVE ] = "QUEST_MARK_SOON_TO_GIVE"
} )
Global( "sysInteractorId", {
	[ INTERACTION_BINDING_STONE ] = "INTERACTION_BINDING_STONE",
	[ INTERACTION_HERALD ] = "INTERACTION_HERALD"
} )
Global( "sysReputationClass", {
	[ REPUTATION_LEVEL_HOSTILITY ] = "RepHostility",
	[ REPUTATION_LEVEL_ENEMY ] = "RepEnemy",
	[ REPUTATION_LEVEL_UNFRIENDLY ] = "RepUnfriendly",
	[ REPUTATION_LEVEL_NEUTRAL ] = "RepNeutral",
	[ REPUTATION_LEVEL_KINDLY ] = "RepKindly",
	[ REPUTATION_LEVEL_FRIENDLY ] = "RepFriendly",
	[ REPUTATION_LEVEL_CONFIDENTIAL ] = "RepConfidential"
} )
--------------------------------------------------------------------------------
-- DIGGING DATA FOR TEMPLATE
--------------------------------------------------------------------------------
function GetSplittedTimeString( milliseconds )
	local split = SplitTime( milliseconds )
	return tostring( math.floor( split.hours ) )
		.. ":" .. string.format( "%02d", math.floor( split.minutes ) )
		.. "." .. string.format( "%02d", math.floor( split.seconds ) )
		.. "`" .. string.sub( tostring( milliseconds ), - 3 ) .. "``"
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
templates[ TOOLTIP_NONE ].GetDataFrom = function( self, params )
	return nil
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_SIMPLE ].GetDataFrom = function( self, params )
	return nil
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_SIMPLEDESC ].GetDataFrom = function( self, params )
	return nil
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_MAPMARK ].GetDataFrom = function( self, params )
	local data = nil
	local avatarId = avatar.GetId()
	
	if not avatarId then
		return data
	end

	data = {}
	local avatarPos = avatar.GetPosNew()
	data.pos = {
		value = ToWs( "Pos X: " .. Round( avatarPos.posX, 3 ) ),
		value2 = ToWs( "; Y: " .. Round( avatarPos.posY, 3 ) ),
		value3 = ToWs( "; Z: " .. Round( avatarPos.posZ, 3 ) ),
		style = "tip_golden"
	}
	
	data.id = { value = ToWs( "avatarId: " .. avatarId ), style = "tip_green" }

	return data
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_UNIT ].GetDataFrom = function( self, params )
	local data = nil
	
	if not params.unitId then
		return data
	end
	
	local avatarId = avatar.GetId()
	local avatarLevel = nil
	if avatarId then
		avatarLevel = unit.GetLevel( avatarId )
	else
		avatarLevel = 0
	end
	
	data = {}
	data.unitId = params.unitId
	data.id = { value = ToWs( "unitId: " .. params.unitId ), style = "tip_white" }
	
	local health = unit.GetHealth( params.unitId )
	local mana = unit.GetMana( params.unitId )
	
	data.health = { value = ToWs( "Health: " .. tostring( health.health ) .. "/" .. tostring( health.maxHealth ) .. ", " .. tostring( health.percents ) .. "%" ), style = "tip_green" }
	data.mana = { value = ToWs( "Mana: " .. tostring( mana.mana ) .. "/" .. tostring( mana.maxMana ) .. ", " .. tostring( mana.percents ) .. "%" ), style = "tip_blue", format = GetText( "DefaultRight" ) }
	data.level = { value = ToWs( "Level: " .. unit.GetLevel( params.unitId ) ) }
	
	local transportId = unit.GetTransport( params.unitId )
	data.transportId = transportId and { value = ToWs( "transportId: " .. transportId ), style = "tip_white" } or nil
	
	local markId = object.GetQuestMark( params.unitId )
	data.questMark = markId and { value = ToWs( sysQuestMarkId[ markId ] ), style = "tip_white" } or nil
	
	local isPlayer = unit.IsPlayer( params.unitId )--returns: boolean
	local isAbleToAttack = unit.IsAbleToAttack( params.unitId )--returns: boolean
	local isAggressive = unit.IsAggressive( params.unitId )--returns: boolean
	local isDead = unit.IsDead( params.unitId )--returns: boolean
	local isEnemy = unit.IsEnemy( params.unitId )--returns: boolean
	local isFriend = unit.IsFriend( params.unitId )--returns: boolean
	local isUsable = unit.IsUsable( params.unitId )--returns: boolean
	local quality = unit.GetQuality( params.unitId ) --UNIT_QUALITY_COMMON, UNIT_QUALITY_ELITE, UNIT_QUALITY_FLAVOR_ELITE, UNIT_QUALITY_MINI_BOSS
	local PVPFlag = isPlayer and unit.GetPvPFlag( params.unitId )
	local canUse = unit.CanUse( params.unitId ) --boolean
	
	local unitPos = protectedMission.InteractiveObjectGetPos( params.unitId )
	unitPos.posX = unitPos.localX + 32 * unitPos.globalX
	unitPos.posY = unitPos.localY + 32 * unitPos.globalY
	unitPos.posZ = unitPos.localZ + 32 * unitPos.globalZ

	data.posX = { value = ToWs( "PosX: " .. string.format( "%+.2f", unitPos.posX ) ), style = "log" }
	data.posY = { value = ToWs( "PosY: " .. string.format( "%+.2f", unitPos.posY ) ), style = "log" }
	data.posZ = { value = ToWs( "PosZ: " .. string.format( "%+.2f", unitPos.posZ ) ), style = "log" }
	
	local interactor = object.GetInteractorInfo( params.unitId )
	--trace( "interactor = ", tabletolog( interactor ) )
	local isTrainer = interactor and interactor.isTrainer or unit.IsTrainer( params.unitId )
	local trainerClass = isTrainer and unit.GetTrainerClass( params.unitId ) --className: string, manaType: number, name: WString
	local isVendor = interactor and interactor.isVendor or object.IsVendor( params.unitId )
	local vendorType = interactor and interactor.vendorType
	local isQuestGiver = interactor and interactor.isQuestGiver
	local isMailBox = interactor and interactor.isMailBox
	local isAuction = interactor and interactor.isAuction
	local isTeleportMaster = interactor and interactor.isTeleportMaster
	local hasCues = interactor and interactor.hasCues
	local isHonorVendor = interactor and interactor.isHonorVendor
	local isReputationVendor = interactor and interactor.isReputationVendor
	local isDepositeBoxAccessor = interactor and interactor.isDepositeBoxAccessor
	local isSecretRelated = interactor and interactor.isSecretRelated
	local isSecretFinisher = interactor and interactor.isSecretFinisher
	local hasInteraction = interactor and interactor.hasInteraction
	
	local reputation = unit.GetReputationLevel( params.unitId )

	data.trainer = isTrainer and { value = ToWs( "Is Trainer: " .. tostring( isTrainer ) ), style = "tip_white" } or nil
	data.trainerClass = trainerClass and { value = ToWs( "Trainer class: " .. trainerClass.className ), style = "tip_white" } or nil
	data.vendor = isVendor and { value = ToWs( "Is Vendor: " .. tostring( isVendor ) ), style = "tip_white" } or nil
	data.vendorType = isVendor and { value = ToWs( sysVendorTypeId[ vendorType ] or tostring( vendorType ) ), style = "tip_golden" } or nil
	data.isMailBox = isMailBox and { value = ToWs( "Is MailBox: " .. tostring( isMailBox ) ), style = "tip_white" } or nil
	data.isQuestGiver = isQuestGiver and { value = ToWs( "Is Quest Giver: " .. tostring( isQuestGiver ) ), style = "tip_white" } or nil
	data.isAuction = isAuction and { value = ToWs( "Is Auction: " .. tostring( isAuction ) ), style = "tip_white" } or nil
	data.isTeleportMaster = isTeleportMaster and { value = ToWs( "Is Teleport Master: " .. tostring( isTeleportMaster ) ), style = "tip_white" } or nil
	data.isHonorVendor = isHonorVendor and { value = ToWs( "Is Honor Vendor: " .. tostring( isHonorVendor ) ), style = "tip_white" } or nil
	data.isReputationVendor = isReputationVendor and { value = ToWs( "Is Reputation Vendor: " .. tostring( isReputationVendor ) ), style = "tip_white" } or nil
	data.isSecretRelated = isSecretRelated and { value = ToWs( "SecretRelated: " .. tostring( isSecretRelated ) ), style = "tip_white" } or nil
	data.isSecretFinisher = isSecretFinisher and { value = ToWs( "SecretFinisher: " .. tostring( isSecretFinisher ) ), style = "tip_white" } or nil
	data.hasInteraction = hasInteraction and { value = ToWs( "Has Interaction: " .. tostring( hasInteraction ) ), style = "tip_white" } or nil
	data.hasCues = hasCues and { value = ToWs( "Has Cues: " .. tostring( hasCues ) ), style = "tip_white" } or nil
	
	data.player = { value = ToWs( "Is Player: " .. tostring( isPlayer ) ), style = "tip_white" }
	data.Mainhand = { value = ToWs( "Is Able To Attack Mainhand: " .. tostring( isAbleToAttack.Mainhand ) ), style = "tip_white" }
	data.Offhand = { value = ToWs( "Is Able To Attack Offhand: " .. tostring( isAbleToAttack.Offhand ) ), style = "tip_white" }
	data.Ranged = { value = ToWs( "Is Able To Attack Ranged: " .. tostring( isAbleToAttack.Ranged ) ), style = "tip_white" }
	data.aggressive = { value = ToWs( "Is Aggressive: " .. tostring( isAggressive ) ), style = isAggressive and "Aggressive" or "Neutral" }
	data.dead = { value = ToWs( "Is Dead: " .. tostring( isDead ) ), style = "Dead" }
	data.enemy = { value = ToWs( "Is Enemy: " .. tostring( isEnemy ) ), style = "Neutral" }
	data.friend = { value = ToWs( "Is Friend: " .. tostring( isFriend ) ), style = "Friendly" }
	data.usable = { value = ToWs( "Is Usable: " .. tostring( isUsable ) ), style = "tip_green" }
	data.quality = { value = ToWs( "Quality: " .. sysUnitQuality[ quality ] or tostring( quality ) ), style = "tip_white" }
	data.reputation = { value = ToWs( "Reputation level: " .. ( sysReputationLevelId[ reputation ] or tostring( reputation ) ) ), style = sysReputationClass[ reputation ] }
	
	data.pvp = { value = ToWs( "PvP Flag : " .. tostring( PVPFlag ) ), style = "tip_white" }
	
	if interactor and interactor.extended then
		local extended = {}
		if table.getsize( interactor.extended ) > 0 then
			for k = table.minn( interactor.extended ), table.maxn( interactor.extended ) do
				local v = interactor.extended[ k ]
				table.insert( extended, "<br>[ " .. ( sysInteractorId[ k ] or tostring( k ) ) .. " ]: <tip_golden>\"" .. tostring( v ) .. "\"</tip_golden></br>" )
			end
		end
		table.insert( extended, 1, "<tip_white>extended:" )
		table.insert( extended, "</tip_white>" )
	
		data.extended = { value = ToWs( table.concat( extended ) ), class = "tip_white" }
	end

	local serverInfo = debugMission.UnitGetServerInfo( params.unitId )
	if serverInfo then
		data.serverAddress = { value = ToWs( "Server address: " .. serverInfo.sysServerAddress ), style = "log" }
	end
	
	return data
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_ITEM ].GetDataFrom = function( self, params )
	local itemInfo = params.itemId and avatar.GetItemInfo( params.itemId )
	--trace( "itemInfo = ", itemInfo )
	if not itemInfo then return end
	--------------------------------------
	local avatarId = avatar.GetId()
	local data = { itemId = params.itemId }
	data.id = { value = ToWs( "itemId: " .. itemInfo.itemId ), style = "tip_white" }
	data.sysName = { value = ToWs( "sysName: " .. itemInfo.sysName ), style = "tip_white" }
	data.sellPrice = { value = ToWs( "Sell price: " .. tostring( itemInfo.sellPrice ) ), style = "tip_golden" }
	data.buyPrice = { value = ToWs( "Buy price: " .. tostring( itemInfo.buyPrice ) ), style = "tip_golden" }
	data.quality = {
		value = ToWs( "Quality: " .. ( sysItemQualityStyle[ itemInfo.quality ] or tostring( itemInfo.quality ) ) ),
		style = sysItemQualityStyle[ itemInfo.quality ] or "tip_white"
	}
	data.level = { value = ToWs( "Level: " .. tostring( itemInfo.level ) ) }
	data.categoryId = {
		value = ToWs( "categoryId: " ),
		value2 = ValidateTextValue( avatar.GetItemCategoryInfo( itemInfo.categoryId ).name ),
		style = "tip_white"
	}
	--------------------------------------
	data.requiredLevel = { value = ToWs( "Required level: " .. tostring( itemInfo.requiredLevel ) ), style = "tip_white" }
	
	local tryEquip = avatar.GetItemDressConditions( params.itemId )
	--trace( "tryEquip = ", tryEquip )

	if tryEquip.sysFirstCondition ~= "ENUM_DressResult_Success"
	and tryEquip.failedConditions[ "ENUM_DressResult_WrongCreatureLevel" ] then
		data.requiredLevel.style = "Aggressive"
	end
	--------------------------------------
	if tryEquip.sysFirstCondition ~= "ENUM_DressResult_Success" and itemInfo.dressSlot ~= DRESS_SLOT_UNDRESSABLE then
		local text = "Equip failed : "
		for key, val in tryEquip.failedConditions do
			text = text .. key .. ", "
		end
	
		data.equipFailed = { value = ToWs( text ), style = "Aggressive" }
	end
	--------------------------------------
	local reqlvl = itemInfo.requiredReputationLevel
	data.requiredReputation = {
		value = ToWs( "Required reputation level: " .. ( sysReputationLevelId[ reqlvl ] or tostring( reqlvl ) ) ),
		style = "tip_grey"
	}
	
	local vendorId = avatar.GetInterlocutor()
	--trace( "vendorId = ", vendorId )
	if vendorId and object.IsUnit( vendorId ) then
		local sysFactionName = unit.GetFaction( vendorId ).sysName
		--trace( "sysFactionName = ", sysFactionName )
		local reputationInfo = avatar.GetReputationInfo( sysFactionName )
		local reputation = reputationInfo and reputationInfo.level
		--trace( "reputation = ", sysReputationLevelId[ reputation ] )
		
		if itemInfo.requiredReputationLevel ~= 0 and reputation then
			data.requiredReputation.style = itemInfo.requiredReputationLevel > reputation and "Aggressive" or "Friendly"
		end
	end
	--------------------------------------
	data.requiredHonor = { value = ToWs( "Required honor rank: " .. sysHonorRankId[ itemInfo.requiredHonorRank ] ), style = "tip_grey" }
	local honor = unit.GetHonorInfo( avatarId ).rank
	--trace( "honor = ", sysHonorRankId[ honor ] )
	
	if itemInfo.requiredHonorRank ~= 0 then
		data.requiredHonor.style = itemInfo.requiredHonorRank > honor and "Aggressive" or "Friendly"
	end
	--------------------------------------
	data.canDrop = { value = ToWs( "Can drop: " .. tostring( itemInfo.canDrop ) ), style = "tip_white" }
	data.isItemMallSellable = { value = ToWs( "Is itemMall sellable: " .. tostring( itemInfo.isItemMallSellable ) ), style = "tip_white" }
	data.canCreateAuction = { value = ToWs( "Can create auction: " .. tostring( itemInfo.canCreateAuction ) ), style = "tip_white" }
	--------------------------------------
	data.usable = { value = ToWs( "Is usable: " .. tostring( itemInfo.isUsable ) ), style = itemInfo.isUsable and "Friendly" or "Aggressive" }
	data.pointed = { value = ToWs( "Is pointed: " .. tostring( itemInfo.isPointed ) ) }
	data.questOp = { value = ToWs( "Is quest operator: " .. tostring( itemInfo.isQuestOperator ) ) }
	data.questRel = { value = ToWs( "Is quest related: " .. tostring( itemInfo.isQuestRelated ) ) }
	data.guildCreator = { value = ToWs( "Is guild creator: " .. tostring( itemInfo.isGuildCreator ) ) }
	data.isDepositeBoxAccessor = { value = ToWs( "Is deposite box accessor: " .. tostring( itemInfo.isDepositeBoxAccessor ) ) }
	data.isWeapon = { value = ToWs( "Is weapon: " .. tostring( itemInfo.isWeapon ) ) }
	data.armorPierce = { value = ToWs( "isArmorPiercing: " .. tostring( itemInfo.isArmorPiercing ) ) }
	data.canInsertRune = { value = ToWs( "Can insert rune: " .. tostring( itemInfo.canInsertRune ) ) }
	--------------------------------------
	if itemInfo.spellId then
		local spellInfo = avatar.GetSpellInfo( itemInfo.spellId )
		local spellstyle = spellInfo.canRunAvatar and "tip_green" or "tip_red"
		data.spell = { value = ToWs( "Binded spell: " ), value2 = ValidateTextValue( spellInfo.name ), style = spellstyle }
		data.spellFile = { value = ToWs( "Spell file: " .. spellInfo.debugName ) , style = spellstyle }
	end
	--------------------------------------
	data.stack = { value = ToWs( "Stack: " .. itemInfo.stackCount .. "/" .. itemInfo.overallStackCount ) }
	data.charges = { value = ToWs( "Charges: " .. itemInfo.counterCount .. "/" .. itemInfo.counterLimit ) }
	--------------------------------------
	if itemInfo.craftingSkillIds then
		data.craftSkills = {}
		for id, skillId in itemInfo.craftingSkillIds do
			local skillInfo = avatar.GetSkillInfo( skillId )
			
			data.craftSkills[ id ] = skillInfo and {
				value = ToWs( "Related skill [ " .. tostring( id ) .. " ] - " .. FromWs( skillInfo.name ) ),
				style = "tip_white"
			}
		end
	end
	--------------------------------------
	if itemInfo.craftingComponents
	and not IsEmptyTable( itemInfo.craftingComponents ) then
		local comps = "Alchemy components: "
		
		for id = 0, GetTableSize( itemInfo.craftingComponents ) - 1 do
			local compInfo = avatar.GetComponentInfo( itemInfo.craftingComponents[ id ] )
			comps = comps .. id .. ": " .. FromWs( compInfo.name ) .. ", "
		end
		data.components = { value = ToWs( comps ) }
	end
	--------------------------------------
	if itemInfo.runeId then
		data.runeId = { value = ToWs( "RuneId: " .. tostring( itemInfo.runeId ) ), style = "tip_green" }
		itemInfo.insertedRuneInfo = avatar.GetItemInfo( itemInfo.runeId ).runeInfo
	end
	--------------------------------------
	local info = itemInfo.runeInfo or itemInfo.insertedRuneInfo
	
	if info then
		if info.runeLevel then
			data.runeLevel = { value = ToWs( "Rune level: " .. tostring( info.runeLevel ) ), style = "tip_green" }
		end
		
		data.zodiacSignName = info.zodiacSignName and {
			value = ToWs( "zodiacSignName: " ),
			value2 = ValidateTextValue( info.zodiacSignName ),
			style = "tip_green"
		}
		
		data.zodiacSignDescription = info.zodiacSignDescription and {
			value = ToWs( "zodiacSignDescription: " ),
			value2 = ValidateTextValue( info.zodiacSignDescription ),
			style = "tip_green"
		}
		
		data.offensiveBonus = {
			value = ToWs( "Offensive bonus: " .. tostring( math.round( info.offensiveBonus, 3 ) ) ),
			style = "tip_green"
		}
		
		data.defensiveBonus = {
			value = ToWs( "Defensive bonus: " .. tostring( math.round( info.defensiveBonus, 3 ) ) ),
			style = "tip_green"
		}
	end
	--------------------------------------
	if itemInfo.runeInstrumentInfo then
		local info = itemInfo.runeInstrumentInfo
		if info then
			data.isCombiner = { value = ToWs( "Is Combiner: " .. tostring( info.isCombiner ) ), style = "tip_green" }
			data.isExtractor = { value = ToWs( "Is Extractor: " .. tostring( info.isExtractor ) ), style = "tip_green" }
		end
	end
	--------------------------------------
	if itemInfo.foragingInfo then
		local info = itemInfo.foragingInfo
		local skillInfo = avatar.GetSkillInfo( info.skillId )

		data.foraging = { value = ToWs( "Foraging Skill: " .. FromWs( skillInfo.name ) ) }
		data.isForagingInstrument = { value = ToWs( "Is Foraging Instrument: " .. tostring( skillInfo.isInstrument ) ) }
	end
	--------------------------------------
	if itemInfo.disassemblerInfo then
		local info = itemInfo.disassemblerInfo

		if not IsEmptyTable( info.slots ) then
			local slots = "Disassemblin' slots: "
			for id, dressSlot in info.slots do
				slots = slots .. "[ " .. id .. " ] = " .. FromWs( GetDressSlotName( dressSlot ) ) .. "; "
			end
			data.disassemblerSlots = { value = ToWs( slots ), multiline = true }
		end
		
		if not IsEmptyTable( info.classes ) then
			local classes = "Disassembin' classes: "
			for id, class in info.classes do
				classes = classes .. "[ " .. id .. " ] = " .. FromWs( class ) .. "; "
			end
			data.disassemblerClasses = { value = ToWs( classes ), multiline = true }
		end
	end
	--------------------------------------
	data.isBound = { value = ToWs( "Is bound: " .. tostring( itemInfo.isBound ) ), style = "tip_golden" }
	data.binding = { value = ToWs( "Binding: " .. sysItemBindingId[ itemInfo.binding ] ), style = "tip_golden" }
	data.bindDescription = { value = ToWs( "Bind description: " ), value2 = ValidateTextValue( itemInfo.bindDescription ), style = "tip_golden" }
	--------------------------------------
	if itemInfo.isBoxKey then
		data.isBoxKey = { value = ToWs( "IsBoxKey: " .. tostring( itemInfo.isBoxKey ) ), style = "tip_white" }
	end
	--------------------------------------
	if itemInfo.boxInfo then
		data.isBoxLocked = { value = ToWs( "isBoxLocked: " .. tostring( itemInfo.boxInfo.isBoxLocked ) ), style = "tip_white" }
	end
	--------------------------------------
	local misc = itemInfo.bonus.misc
	data.armor = { value = ToWs( "Armour: " .. misc.armor ), style = "tip_white" }
	data.armorBonus = { value = ToWs( "Armour Bonus: " .. misc.armorBonus ), style = "tip_white" }
	data.weaponSpeed = { value = ToWs( "Weapon speed: " .. Round( misc.weaponSpeed, 3 ) ), style = "tip_white" }
	data.damage = {
		value = ToWs( "Damage: " .. tostring( misc.minDamage ) .. " - " .. tostring( misc.maxDamage ) ),
		style = "tip_white"
	}
	data.spellPower = { value = ToWs( "Spell power: " .. tostring( misc.spellPower ) ), style = "tip_white" }
	--------------------------------------
	data.debugInstance = { value = ToWs( "File: " .. itemInfo.debugInstanceFileName ) }
	data.debugClass = { value = ToWs( "Class: " .. itemInfo.debugClassFileName ) }
	data.dressSlot = { value = ToWs( "dressSlot: " .. strDressSlotId[ itemInfo.dressSlot ] ), style = "tip_white" }
	--------------------------------------
	return data
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_ITEM_VENDOR ].GetDataFrom  = templates[ TOOLTIP_ITEM ].GetDataFrom
--------------------------------------------------------------------------------
templates[ TOOLTIP_SPELL ].GetDataFrom = function( self, params )
	local data = nil
	
	if not params.spellId then
		return data
	end
	
	local spellInfo = avatar.GetSpellInfo( params.spellId )
	--trace( "spellInfo = ", spellInfo )
	if not spellInfo then
		return data
	end
	
	data = {}
	data.spellId = params.spellId
	data.id = { value = ToWs( "Spell: " .. spellInfo.debugName ), style = "tip_white" }
	data.level = { value = ToWs( "Level required: " .. spellInfo.level ), style = "tip_golden" }
	data.rank = { value = ToWs( "Rank: " .. spellInfo.rank ), style = "tip_golden" }
	
	if spellInfo.objectId then
		data.objectId = { value = ToWs( "objectId: " .. spellInfo.objectId ), style = "tip_blue" }
	end
	
	data.prepareDuration = { value = ToWs( "Prepare duration: " .. spellInfo.prepareDuration ), style = "tip_white" }
	data.element = { value = ToWs( "SubElement: " .. tostring( spellInfo.sysSubElement ) ), style = "tip_white" }
	data.enabled = { value = ToWs( "Enabled: " .. tostring( spellInfo.enabled ) ), style = spellInfo.enabled and "Friendly" or "Aggressive" }
	data.prepared = { value = ToWs( "Prepared: " .. tostring( spellInfo.prepared ) ), style = spellInfo.prepared and "Friendly" or "Aggressive" }
	data.autocast = { value = ToWs( "Autocast: " .. tostring( spellInfo.autocastOn ) ), style = spellInfo.autocastOn and "Friendly" or "Aggressive" }
	data.launchWhenReady = { value = ToWs( "Launch w ready: " .. tostring( spellInfo.launchWhenReady ) ), style = spellInfo.launchWhenReady and "Friendly" or "Aggressive" }
	
	data.cooldown = { value = ToWs( "Cooldown: " .. spellInfo.cooldownDurationMs ), style = "tip_blue" }
	data.cooldownRemains = { value = ToWs( "remains: " .. spellInfo.cooldownRemainingMs ), style = "tip_blue" }

	data.range = { value = ToWs( "Range: " .. Round( spellInfo.range, 3 ) ), style = "tip_white" }
	data.radius = { value = ToWs( "Radius: " .. Round( spellInfo.radius, 3 ) ), style = "tip_white" }
	
	data.targetType = { value = ToWs( "Target: " .. tostring( sysSpellTargetType[ spellInfo.targetType ] ) ), style = "tip_golden" }
	
	data.isHelpful = { value = ToWs( "isHelpful: " .. tostring( spellInfo.isHelpful ) ), style = "Friendly" }
	data.isHarmful = { value = ToWs( "isHarmful: " .. tostring( spellInfo.isHarmful ) ), style = "Aggressive" }
	
	data.manaCostCur = { value = ToWs( "Cur mana cost: " .. spellInfo.currentValues.manaCost ), style = "tip_white" }
	data.prepareDurationCur = { value = ToWs( "Cur prepare dur: " .. spellInfo.currentValues.prepareDuration ), style = "tip_white" }
	data.rangeCur = { value = ToWs( "Current range: " .. spellInfo.currentValues.range ), style = "tip_white" }
	data.radiusCur = { value = ToWs( "Current radius: " .. spellInfo.currentValues.radius ), style = "tip_white" }
	data.predictedCooldown = { value = ToWs( "Predicted cooldown: " .. spellInfo.currentValues.predictedCooldown ), style = "tip_white" }

	return data
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_BUFF ].GetDataFrom = function( self, params )
	local data
	
	local buff = unit.GetBuff( params.unitId, params.index )
	if not buff then
		return data
	end
	data = { unitId = params.unitId, index = params.index }
	data.id = { value = ToWs( "unitId: " .. tostring( data.unitId ) .. ", index: " .. tostring( data.index ) ), style = "tip_white" }
	data.name = { value = ToWs( "name: " .. FromWs( buff.name ) ), style = buff.isPositive and "tip_green" or "tip_red" }
	data.desc = { value = ToWs( "description: " .. FromWs( buff.description ) ), style = "tip_golden" }
	data.debugName = { value = ToWs( "debugName: " .. buff.debugName ), style = "tip_golden" }
	data.sysName = { value = ToWs( "sysName: \"" .. buff.sysName .. "\"" ), style = "tip_white" }
	data.remaining = { value = ToWs( "remains: " .. GetSplittedTimeString( buff.remainingMs ) ), style = "tip_white" }
	data.duration = { value = ToWs( "duration " .. GetSplittedTimeString( buff.durationMs ) ), style = "tip_white" }
	data.isStackable = { value = ToWs( "isStackable: " .. tostring( buff.isStackable ) ), style = buff.isStackable and "tip_green" or "tip_red" }
	data.stackCount = { value = ToWs( "stackCount: " .. tostring( buff.stackCount ) ), style = "tip_white" }
	data.stackLimit = { value = ToWs( "stackLimit: " .. tostring( buff.stackLimit ) ), style = "tip_white" }
	data.isPositive = { value = ToWs( "isPositive: " .. tostring( buff.isPositive ) ), style = buff.isPositive and "tip_green" or "tip_red" }
	data.isGradual = { value = ToWs( "isGradual: " .. tostring( buff.isGradual ) ), style = buff.isGradual and "tip_green" or "tip_red" }
	data.isNeedVisualizeDuration = {
		value = ToWs( "isNeedVisualizeDuration: " .. tostring( buff.isNeedVisualizeDuration ) ),
		style = buff.isNeedVisualizeDuration and "tip_green" or "tip_red"
	}
	local groupsText = {}
	if table.getsize( buff.groups ) > 0 then
		for k = table.minn( buff.groups ), table.maxn( buff.groups ) do
			local v = buff.groups[ k ]
			table.insert( groupsText, "<br>[ " .. tostring( k ) .. " ]: <tip_golden>\"" .. tostring( v ) .. "\"</tip_golden></br>" )
		end
	end
	table.insert( groupsText, 1, "<tip_white>groups:" )
	table.insert( groupsText, "</tip_white>" )
	
	data.groups = { value = ToWs( table.concat( groupsText ) ), class = "tip_white" }
	
	groupsText = {}
	if table.getsize( buff.debugGroups ) > 0 then
		for k = table.minn( buff.debugGroups ), table.maxn( buff.debugGroups ) do
			local v = buff.debugGroups[ k ]
			table.insert( groupsText, "<br>[ " .. tostring( k ) .. " ]: <tip_golden>" .. tostring( v ) .. "</tip_golden></br>" )
		end
	end
	table.insert( groupsText, 1, "<tip_white>debugGroups:" )
	table.insert( groupsText, "</tip_white>" )
	
	data.debugGroups = { value = ToWs( table.concat( groupsText ) ), class = "tip_white" }
	
	return data
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_ABILITY ].GetDataFrom = function( self, params )
	local data = nil
	if not params.abilityId then
		return data
	end
	
	local abilityInfo = avatar.GetAbilityInfo( params.abilityId )
	--trace( "abilityInfo = ", abilityInfo )
	if not abilityInfo then
		return params
	end
	
	data = {}
	data.id = { value = ToWs( "Ability: " .. abilityInfo.sysInfo ), style = "tip_white" }
	data.level = { value = ToWs( "Level required: " .. abilityInfo.level ), style = "tip_golden" }
	data.rank = { value = ToWs( "Rank: " .. abilityInfo.rank ), style = "tip_golden" }
	
	return data
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_COMPONENT ].GetDataFrom = function( self, params )
	return nil
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_RECIPE ].GetDataFrom = function( self, params )
	if not params.recipeId then
		return params
	end
	
	local recipeInfo = avatar.GetRecipeInfo( params.recipeId )
	--trace( "recipeInfo = ", recipeInfo )
	if not recipeInfo then
		return params
	end
	
	params.score = { value = ToWs( "Recipe score: " .. tostring( recipeInfo.score ) ), style = "tip_blue" }
	
	local comps = "components: "
	for id, component in recipeInfo.components do
    local compInfo = nil
	  if params.armorCraft then
			compInfo = avatar.GetItemInfo( component )
		else
			compInfo = avatar.GetComponentInfo( component )
		end
		comps = comps .. id .. ": " .. FromWs( compInfo.name ) .. ", "
	end
	params.components = { value = ToWs( comps ) }
	
	return params
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_USABLE_DEVICE ].GetDataFrom = templates[ TOOLTIP_SIMPLE ].GetDataFrom
--------------------------------------------------------------------------------
templates[ TOOLTIP_ASTRAL_UNIT ].GetDataFrom = function( self, params )
	return nil
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_FAIRY ].GetDataFrom = function( self, params )
	local data = nil
	local fairyInfo = unit.GetFairyInfo( params.unitId )
	--trace( "fairyInfo = ", tabletolog( fairyInfo ) )
	
	if not fairyInfo then
		return data
	end

	data = { unitId = params.unitId }
	data.name = { value = ValidateWs( fairyInfo.name ), style = "header" }
	data.desc = { value = ToWs( "Description: " .. FromWs( ValidateWs( fairyInfo.description ) ) ) }
	data.level = { value = ToWs( "Level: " .. fairyInfo.level ) }
	
	data.isHungry = { value = ToWs( "IsHungry: " .. tostring( fairyInfo.isHungry ) ), style = fairyInfo.isHungry and "Aggressive" or "Friendly" }
	data.remainingMs = fairyInfo.remainingMs and { value = ToWs( "Will be hungry in " .. fairyInfo.remainingMs / 1000 .. " s" ) }
	
	data.healthBonus = { value = ToWs( "Health bonus: +" .. fairyInfo.healthBonus ), style = "Friendly" }
	data.manaBonus = { value = ToWs( "Mana bonus: +" .. fairyInfo.manaBonus ), style = "tip_golden" }
	
	local fairyZodiacSignInfo = unit.GetFairyZodiacSignInfo( params.unitId )
	
	data.zodiacName = { value = ToWs( "Zodiac: " .. FromWs( fairyZodiacSignInfo.name ) ), style = "tip_white" }
	data.zodiacDesc = { value = ToWs( "Zodiac description: " .. FromWs( ValidateWs( fairyZodiacSignInfo.description ) ) ), style = "tip_golden" }
	
	return data
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_TALENT ].GetDataFrom = function( self, params )
	local data
	local talentInfo
	
	if params.field then
		talentInfo = avatar.GetFieldTalentInfo( params.field, params.row, params.column )
		
	else
		talentInfo = avatar.GetBaseTalentInfo( params.row, params.column )
	end
	--trace( "talentInfo = ", talentInfo )
	
	if not talentInfo then
		return data
	end

	data = { field = params.field, row = params.row, column = params.column }
	if talentInfo.current then
		local current = talentInfo.current
		
		data.currentRank = { value = ToWs( "Current Rank: " .. tostring( current.rank ) ), style = "tip_white" }
		data.currentName = { value = ValidateWs( current.name ), style = "tip_white" }
		data.currentDesc = { value = ValidateWs( current.desc ), style = "tip_golden" }
		
		local spellInfo = current.spellId and avatar.GetSpellInfo( current.spellId )
		data.currentSpellId = spellInfo and 
		{
			value = ToWs( "spellId: " .. spellInfo.debugName ),
			style = "tip_golden"
		}
		
		local abilityInfo = current.abilityId and avatar.GetAbilityInfo( current.abilityId )
		data.currentAbilityId = abilityInfo and 
		{ 
			value = ToWs( "abilityId: " .. abilityInfo.sysInfo ),
			style = "tip_golden"
		}
	end
	
	if talentInfo.next then
		local next = talentInfo.next
		
		data.nextRank = { value = ToWs( "Next Rank: " .. tostring( next.rank ) ), style = "tip_white" }
		data.nextName = { value = ValidateWs( next.name ), style = "tip_white" }
		data.nextDesc = { value = ValidateWs( next.desc ), style = "tip_golden" }
		
		local spellInfo = next.spellId and avatar.GetSpellInfo( next.spellId )
		data.nextSpellId = spellInfo and 
		{
			value = ToWs( "spellId: " .. spellInfo.debugName ),
			style = "tip_golden"
		}
		
		local abilityInfo = next.abilityId and avatar.GetAbilityInfo( next.abilityId )
		data.nextAbilityId = abilityInfo and 
		{ 
			value = ToWs( "abilityId: " .. abilityInfo.sysInfo ),
			style = "tip_golden"
		}
	end
	
	data.requiredSpentTP = not params.field and { value = ToWs( "requiredSpentTP: " .. tostring( talentInfo.requiredSpentTP ) ) } or nil
	data.canUpdate = { value = ToWs( "Can update: " .. tostring( talentInfo.canUpdate ) ), style = talentInfo.canUpdate and "Friendly" or "Aggressive" }
	data.isEmpty = { value = ToWs( "Is empty: " .. tostring( talentInfo.isEmpty ) ), style = talentInfo.isEmpty and "Friendly" or "Aggressive" }
	data.isLearned = { value = ToWs( "Is learned: " .. tostring( talentInfo.isLearned ) ), style = talentInfo.isLearned and "Friendly" or "Aggressive" }

	return data
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_REPUTATION ].GetDataFrom = function( self, params )
	local data
	local repInfo = avatar.GetReputationInfo( params.faction )

	if not repInfo then
		return data
	end

	data = { faction = params.faction }
	data.name = { value = ToWs( "sysFactionName: " .. params.faction ), style = "tip_golden" }
	data.level = { value = ToWs( "Level: " .. sysReputationLevelId[ repInfo.level ] ), style = sysReputationClass[ repInfo.level ] }
	data.rep = { value = ToWs( "Reputation: " .. tostring( repInfo.repCurrLevel ) .. " / " .. tostring( repInfo.rep ) .. " / " .. tostring( repInfo.repNextLevel ) ) }
	return data
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_HEARTHSTONE ].GetDataFrom = function( self, params )
	local data

	if not avatar.HasHearthStone() then
		return data
	end

	local cooldown = avatar.GetHearthStoneCooldown() -- remainingMs, durationMs: number( int )
	local locatorInfo = avatar.GetHearthStoneLocator() -- map, zone, locator: WString
	data = { inactive = cooldown.remainingMs > 0 or nil }
	data.cooldown = { value = ToWs( "Cooldown: " .. cooldown.remainingMs .. " / " .. cooldown.durationMs .. " ms" ), style = "tip_golden" }
	data.locator = {
		value = ToWs( "Locator: " .. FromWs( locatorInfo.map ) .. ", " .. FromWs( locatorInfo.zone ) .. ", " .. FromWs( locatorInfo.locator ) ),
		style = "header"
	}

	return data
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- SHOW TOOLTIP BY TEMPLATE FUNCTIONALITY
--------------------------------------------------------------------------------
templates[ TOOLTIP_NONE ].AssembleContentFrom = function ( self, data )
	return nil
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_SIMPLE ].AssembleContentFrom = templates[ TOOLTIP_NONE ].AssembleContentFrom
--------------------------------------------------------------------------------
templates[ TOOLTIP_SIMPLEDESC ].AssembleContentFrom = templates[ TOOLTIP_NONE ].AssembleContentFrom
--------------------------------------------------------------------------------
templates[ TOOLTIP_MAPMARK ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.id },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.pos }
	}
	return content
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_UNIT ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.id, data.quality },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.health, data.mana },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.player, data.pvp },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.friend, data.enemy },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.reputation },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.transportId },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.trainer, data.trainerClass },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.vendor },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.vendorType },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isQuestGiver },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.isSecretRelated, data.isSecretFinisher },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.questMark },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isMailBox },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isAuction },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isTeleportMaster },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isHonorVendor },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isReputationVendor },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.hasCues },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.usable },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.extended },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.hasInteraction },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.aggressive, data.dead },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.Mainhand },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.Offhand },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.Ranged },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.posX },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.posY },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.posZ },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.serverAddress },
		update = {
			[ "EVENT_SECOND_TIMER" ] = function( params )
				return true
			end
			}
	}
	return content
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_ITEM ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.id, data.quality },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.sysName },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.categoryId },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.debugInstance },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.debugClass },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.dressSlot },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.level },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.buyPrice, data.sellPrice },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.canDrop, data.isItemMallSellable },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.requiredLevel, data.canCreateAuction },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.requiredReputation },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.requiredHonor },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.equipFailed },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.player },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.isWeapon, data.armorPierce },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.stack, data.charges },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.usable, data.pointed },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.questOp, data.questRel },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.guildCreator },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isDepositeBoxAccessor },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.spell },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.spellFile },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.components },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.canInsertRune },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.runeId },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.runeLevel },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.offensiveBonus, data.defensiveBonus },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.isCombiner, data.isExtractor },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.foraging },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isForagingInstrument },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isBoxKey },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isBoxLocked },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.armor, data.armorBonus },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.spellPower, data.weaponSpeed },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.damage },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isBound },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.binding },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.bindDescription },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.disassemblerSlots },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.disassemblerClasses }
	}

	for id, skill in data.craftSkills do
		table.insert( content, 21, { type = TOOLTIP_CONTENT.SMART_LINE, skill } )
	end
	return content
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_ITEM_VENDOR ].AssembleContentFrom = templates[ TOOLTIP_ITEM ].AssembleContentFrom
--------------------------------------------------------------------------------
templates[ TOOLTIP_SPELL ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.id },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.level, data.rank },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.range, data.radius },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.enabled, data.prepared },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.objectId },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.element },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.cooldown, data.cooldownRemains,
			update = {
				[ "EVENT_SECOND_TIMER" ] = function( params )
					local spellInfo = avatar.GetSpellInfo( data.spellId )
					local cooldown = { value = ToWs( "Cooldown: " .. spellInfo.cooldownDurationMs ), style = "tip_blue" }
					local cooldownRemains = { value = ToWs( "remains: " .. spellInfo.cooldownRemainingMs ), style = "tip_blue", format = GetText( "DefaultRight" ) }
					return cooldown, cooldownRemains
				end
			}
		},
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.prepareDuration, data.targetType },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.autocast, data.launchWhenReady },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.manaCostCur, data.prepareDurationCur },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.rangeCur, data.radiusCur },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.predictedCooldown },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.isHelpful, data.isHarmful },
		update = {
			[ "EVENT_SPELLBOOK_ELEMENT_EFFECT" ] = function( params )
				return data.spellId:IsEqual( params.id )
			end,
			[ "EVENT_SPELLBOOK_ELEMENT_CHANGED" ] = function( params )
				return data.spellId:IsEqual( params.id )
			end
		}
	}
	return content
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_BUFF ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.name },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.desc },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.id },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.sysName },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.debugName },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.remaining, data.duration },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.stackCount, data.stackLimit },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.isStackable, data.isGradual },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isPositive },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isNeedVisualizeDuration },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.groups },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.debugGroups },
		update = {
			[ "EVENT_UNIT_BUFFS_ELEMENT_CHANGED" ] = function( event )
				return data.unitId == event.unitId and data.index == event.index
			end
		}
	}
	return content
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_ABILITY ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.id },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.level, data.rank }
	}
	return content
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_COMPONENT ].AssembleContentFrom = templates[ TOOLTIP_NONE ].AssembleContentFrom
--------------------------------------------------------------------------------
templates[ TOOLTIP_RECIPE ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.score },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.components }
	}
	return content
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_USABLE_DEVICE ].AssembleContentFrom = templates[ TOOLTIP_SIMPLE ].AssembleContentFrom
--------------------------------------------------------------------------------
templates[ TOOLTIP_ASTRAL_UNIT ].AssembleContentFrom = function ( self, data )
	return nil
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_FAIRY ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.name },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.level },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.desc },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.isHungry },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.remainingMs,
			update = {
				[ "EVENT_SECOND_TIMER" ] = function( params )
					local fairyInfo = unit.GetFairyInfo( data.unitId )
					local remainingMs = fairyInfo and fairyInfo.remainingMs or 0
					return { value = ToWs( "Will be hungry in " .. Round( remainingMs / 1000, 3 ) .. " s" ) }
				end
			}
		},
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.healthBonus },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.manaBonus },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.zodiacName },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.zodiacDesc },
		update = {
			[ "EVENT_UNIT_FAIRY_CHANGED" ] = function( params )
				return params.unitId == data.unitId
			end
		}
	}
	return content
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_TALENT ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.currentRank },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.currentSpellId },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.currentAbilityId },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.nextRank },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.nextSpellId },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.nextAbilityId },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.isLearned, data.requiredSpentTP },
		{ type = TOOLTIP_CONTENT.DOUBLE_LINE, data.canUpdate, data.isEmpty },
		update = {
			[ "EVENT_TALENTS_CHANGED" ] = function( params )
				return true
			end
		}
	}
	return content
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_REPUTATION ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.name },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.level },
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.rep },
		update = {
			[ "EVENT_REPUTATION_LEVEL_CHANGED" ] = function( params )
				return params.sysFactionName == data.faction
			end
		}
	}
	return content
end
--------------------------------------------------------------------------------
templates[ TOOLTIP_HEARTHSTONE ].AssembleContentFrom = function ( self, data )
	local content = {
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.locator, 
			update = {
				[ "EVENT_HEARTSTONE_LOCATOR_CHANGED" ] = function( params )
					local locatorInfo = avatar.GetHearthStoneLocator()
					return {
						value = ToWs( "Locator: " .. FromWs( locatorInfo.map ) .. ", " .. FromWs( locatorInfo.zone ) .. ", " .. FromWs( locatorInfo.locator ) ),
						style = "header"
					}
				end
			}
		},
		{ type = TOOLTIP_CONTENT.SMART_LINE, data.cooldown, 
			update = data.inactive and {
				[ "EVENT_SECOND_TIMER" ] = function( params )
					local cooldown = avatar.GetHearthStoneCooldown()
					return { value = ToWs( "Cooldown: " .. cooldown.remainingMs .. " / " .. cooldown.durationMs .. " ms" ), style = "tip_golden" }
				end
			}
		},
		update = {
			[ "EVENT_HEARTHSTONE_COOLDOWN_STARTED" ] = function( params )
				return true
			end,
			[ "EVENT_HEARTHSTONE_COOLDOWN_FINISHED" ] = function( params )
				return true
			end
		}
	}
	return content
end
--------------------------------------------------------------------------------
