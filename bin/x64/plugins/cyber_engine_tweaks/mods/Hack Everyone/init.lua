
IProps = {
	enableDebug = false,
	deltaTime = 0,
	isUploadingQHCOmmands = false,
	qhNameList = {
		{
			hash = 3116789880,
			name = "Ping"
		},
		{
			hash = 612394680,
			name = "Reboot Optics"
		},
		{
			hash = 523263573,
			name = "Contagion"
		},
		{
			hash = 190881063,
			name = "Sonic Shock"
		},
		{
			hash = 2537897906,
			name = "Suicide"
		},
		{
			hash = 988968086,
			name = "Cyberpsychosis"
		},
		{
			hash = 4273202386,
			name = "Weapon Glitch"
		},
		{
			hash = 2534130900,
			name = "Detonate Grenade"
		},
		{
			hash = 953801423,
			name = "Cyberware Malfunction"
		},
		{
			hash = 880772118,
			name = "Synapse Burnout"
		},
		{
			hash = 520988073,
			name = "System Reset"
		},
		{
			hash = 249499564,
			name = "Memory Wipe"
		},
		{
			hash = 3396834708,
			name = "Cripple Movement"
		},
		{
			hash = 3189733290,
			name = "Whistle"
		},
		{
			hash = 2582207146,
			name = "Overheat"
		},
	}
}

local CheckPrereqs = Game['gameRPGManager::CheckPrereqs;array<IPrereq_Record>GameObject']
local CalculateStatModifiers = Game['gameRPGManager::CalculateStatModifiers;FloatFloatFloatarray<StatModifier_Record>GameInstanceGameObjectStatsObjectIDStatsObjectIDStatsObjectID']
local GetPlayerQuickHackListWithPenetration = Game['gameRPGManager::GetPlayerQuickHackListWithPenetration;PlayerPuppet']

registerForEvent("onInit", function()
	print("[Hack Everyone] Initialized | Version: 1.0.0")
end)

function Log(message)
	if IProps.enableDebug then
		print("[Hack Everyone] "..message)
	end
end

function RefreshHUD(npc, player)
	-- npc:RegisterToHUDManager(true)

	updateData = NewObject("handle:HUDActorUpdateData")
	updateData.updateVisibility = true
	updateData.updateIsRevealed = true
	updateData.isRevealedValue = true
	updateData.updateIsTagged = true
	updateData.isTaggedValue = true
	updateData.updateClueData = true
	updateData.updateIsRemotelyAccessed = true
	updateData.isRemotelyAccessedValue = true
	updateData.updateCanOpenScannerInfo = true
	updateData.canOpenScannerInfoValue = true
	updateData.updateIsInIconForcedVisibilityRange = true
	updateData.isInIconForcedVisibilityRangeValue = true
	updateData.updateIsIconForcedVisibleThroughWalls = true
	updateData.isIconForcedVisibleThroughWallsValue = true

	actor = NewObject("handle:gameHudActor")
	actor:UpdateActorData(updateData)
	actor.entityID = npc:GetEntityID()
	actor.status = "REGISTERED"
	actor.type = "PUPPET"

	npc:GetHudManager():SetNewTarget(actor)
end

function RevealQuickHacks(npc, player)
	if IProps.isUploadingQHCOmmands then return end

	IProps.isUploadingQHCOmmands = true
	local playerQHacksList = GetPlayerQuickHackListWithPenetration(player)
	
	local commands = {}

	local context = npc:GetPS():GenerateContext("Remote", NewObject("handle:gamedeviceClearance"), Game.GetPlayerSystem():GetLocalPlayerControlledGameObject(), npc:GetEntityID())

	local i = 0
	for _, actionData in pairs(playerQHacksList) do 

		local action = npc:GetPS():GetAction(actionData.actionTweak)
		action:SetObjectActionID(actionData.actionTweak)
		actionRecord = action:GetObjectActionRecord()

		if actionRecord:ObjectActionType():Type().value == "PuppetQuickHack" then

			local newCommand = NewObject("handle:QuickhackData")
			
			newCommand.actionOwnerName = npc:GetTweakDBFullDisplayName(true)
			
			-- newCommand.title = actionRecord:ObjectActionUI():Caption()
			
			-- newCommand.description = actionRecord:ObjectActionUI():Description()
			newCommand.icon = actionRecord:ObjectActionUI():CaptionIcon():TexturePartID():GetID()
			newCommand.type = actionRecord:ObjectActionType():Type()
			newCommand.actionOwner = npc:GetEntityID()
			newCommand.isInstant = false
			newCommand.ICELevel = npc:GetICELevel()
			newCommand.ICELevelVisible = true
			newCommand.quality = actionData.quality
			newCommand.networkBreached = npc:IsBreached()
			newCommand.category = actionRecord:HackCategory()
			newCommand.actionCompletionEffects = actionRecord:CompletionEffects()
			
			-- QuickHack Names
			-- Handle Custom Titles
			newCommand.title = "QuickHack "..i
			newCommand.description = "QuickHack "..i
			for _, QHData in pairs(IProps.qhNameList) do 

				if QHData.hash == newCommand.icon.hash then
					newCommand.title = QHData.name
					newCommand.description = QHData.name
				end
				
			end

			-- Work Cooldowns
			actionStartEffects = actionRecord:StartEffects()
			for _, effect in pairs(actionStartEffects) do 

				if effect:StatusEffect() and effect:StatusEffect():StatusEffectType():Type().value == "PlayerCooldown" then
					statModifiers = effect:StatusEffect():Duration():StatModifiers()
					newCommand.cooldown = CalculateStatModifiers(0, 0, 0, statModifiers, context, npc, npc:GetEntityID())
					newCommand.cooldownTweak = effect:StatusEffect():GetID()
				end
				
			end

			newCommand.duration = npc:GetQuickHackDuration(actionData.actionTweak, npc, npc:GetEntityID(), Game.GetPlayer():GetEntityID())

			local puppetAction = npc:GetPS():GetAction(actionData.actionTweak)
			puppetAction:SetExecutor(context.processInitiatorObject)
			puppetAction:RegisterAsRequester(npc:GetPS():GetID():ExtractEntityID(npc:GetPS():GetID()))
			puppetAction:SetObjectActionID(actionData.actionTweak)
			puppetAction:SetUp(npc:GetPS())
			
			newCommand.uploadTime = puppetAction:GetActivationTime()
			newCommand.costRaw = puppetAction:GetBaseCost()
			newCommand.cost = puppetAction:GetCost();

			
			-- newCommand.title = puppetAction.actionName.value
			-- newCommand.description = puppetAction.actionName.value

			newCommand.actionMatchesTarget = true

			if puppetAction:IsInactive() then
				newCommand.isLocked = true
				newCommand.inactiveReason = puppetAction.GetInactiveReason()
			elseif Game.GetStatPoolsSystem():IsStatPoolAdded(npc:GetEntityID(), "QuickHackUpload") then
				newCommand.isLocked = true
				newCommand.inactiveReason = "LocKey#7020"
			elseif not puppetAction:CanPayCost() then
				newCommand.isLocked = true
				newCommand.actionState = "OutOfMemory"
				newCommand.inactiveReason = "LocKey#27398"
			else
				newCommand.action = puppetAction
			end

			if actionRecord:GetTargetActivePrereqsCount() > 0 then
				targetActivePrereqs = actionRecord:TargetActivePrereqs()
				for _, activePrereqs in pairs(targetActivePrereqs) do 

					prereqsToCheck = activePrereqs:FailureConditionPrereq()
					if not CheckPrereqs(prereqsToCheck, npc) then
						newCommand.isLocked = true;
                        newCommand.inactiveReason = activePrereqs:FailureExplanation()
					end
				end

			end


			-- if newCommand.cooldown and newCommand.cooldown ~= 0 then
			-- 	newCommand.isLocked = true;
            --     newCommand.inactiveReason = "LocKey#10943";
			-- 	newCommand.actionState = "Locked";
			-- else
			-- 	newCommand.action = puppetAction
			-- end
		
			commands[i] = newCommand
			i = i + 1
		end
		
	end

	quickSlotsManagerNotification = NewObject("handle:RevealInteractionWheel")
	quickSlotsManagerNotification.lookAtObject = npc
	quickSlotsManagerNotification.shouldReveal = true
	quickSlotsManagerNotification.commands = commands

	Game.GetUISystem():QueueEvent(quickSlotsManagerNotification)
	IProps.isUploadingQHCOmmands = false
	Log("QuickHacks Uploaded")
end

function runUpdates()

	player = Game.GetPlayer()

	if not player then return end

	npc = Game.GetTargetingSystem():GetLookAtObject(player, false, false)
	
	if npc and npc:ToString() == "NPCPuppet" and npc:GetHudManager().uiScannerVisible then

		if npc:GetHudManager():IsRegistered(npc:GetEntityID()) and npc:GetHudManager():GetCurrentTarget() ~= nil and (not npc:GetHudManager():IsQuickHackPanelOpened()) then
			RevealQuickHacks(npc, player)
		end

		if not npc:GetHudManager():IsRegistered(npc:GetEntityID()) then
			npc:RegisterToHUDManager(true)
			Log("NPC QH Registered")
		end
	
	end

end

registerForEvent("onUpdate", function(deltaTime)
	
	IProps.deltaTime = IProps.deltaTime + deltaTime

    if IProps.deltaTime > 1 then
        runUpdates()
        IProps.deltaTime = IProps.deltaTime - 1
    end

end)
