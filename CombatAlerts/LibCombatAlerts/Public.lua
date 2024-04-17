--------------------------------------------------------------------------------
-- DO NOT USE THIS LIBRARY. IT IS A WORK IN PROGRESS, ITS INTERFACES ARE NOT
-- STABLE AND IT IS NOT INTENDED FOR USE BY OTHERS AT THIS TIME. THIS MESSAGE
-- WILL BE REMOVED ONCE THIS LIBRARY IS DEEMED SUITABLE FOR GENERAL USE.
--------------------------------------------------------------------------------

local LCCC = LibCodesCommonCode
local Internal = LibCombatAlertsInternal
local Public = LibCombatAlerts


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Public Functions
--------------------------------------------------------------------------------

Public.UnpackRGBA = LCCC.Int32ToRGBA
Public.UnpackRGB = LCCC.Int24ToRGB
Public.PackRGBA = LCCC.RGBAToInt32
Public.PackRGB = LCCC.RGBToInt24
Public.HSLToRGB = LCCC.HSLToRGB
Public.RunAfterInitialLoadscreen = LCCC.RunAfterInitialLoadscreen
Public.CountTable = LCCC.CountTable

function Public.GetAbilityName( abilityId )
	local name = GetAbilityName(abilityId)
	return (name ~= "") and zo_strformat("<<t:1>>", name) or string.format("[#%d]", abilityId)
end

function Public.PlaySounds( soundId, amplification, delayForNext, ... )
	local sound = soundId and SOUNDS[soundId]
	if (sound) then
		for i = 1, amplification or 1 do
			PlaySound(sound)
		end
	end
	if (type(delayForNext) == "number") then
		local args = { ... }
		if (#args > 0) then
			zo_callLater(function() Public.PlaySounds(unpack(args)) end, delayForNext)
		end
	end
end

function Public.GetTexture( id )
	local path = type(id) == "string" and Internal.Textures[id]
	if (path) then
		return string.format("%sart/%s", Internal.GetRootPath(), path)
	else
		return ""
	end
end

do
	local HOTBARS = {
		[HOTBAR_CATEGORY_PRIMARY] = EQUIP_SLOT_MAIN_HAND,
		[HOTBAR_CATEGORY_BACKUP] = EQUIP_SLOT_BACKUP_MAIN,
	}

	local SKILL_TYPES = {
		[ 28306] = 1, -- Puncture
		[ 38250] = 1, -- Pierce Armor
		[ 38256] = 1, -- Ransack
		[ 38984] = 2, -- Destructive Clench
		[ 38985] = 2, -- Flame Clench
		[ 38989] = 2, -- Frost Clench
		[ 38993] = 2, -- Shock Clench
		[ 39475] = 1, -- Inner Fire
		[ 42056] = 1, -- Inner Rage
		[ 42060] = 1, -- Inner Beast
		[183165] = 1, -- Runic Jolt
		[183430] = 1, -- Runic Sunder
		[186531] = 1, -- Runic Embrace
	}

	function Public.DoesPlayerHaveTauntSlotted( )
		for hotbarCategory, equipSlot in pairs(HOTBARS) do
			for i = 3, 7 do
				local skillType = SKILL_TYPES[GetSlotBoundId(i, hotbarCategory)]
				if (skillType == 1 or (skillType == 2 and GetItemWeaponType(BAG_WORN, equipSlot) == WEAPONTYPE_FROST_STAFF)) then
					return true
				end
			end
		end
		return false
	end
end
