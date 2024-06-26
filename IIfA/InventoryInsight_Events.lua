local LCM = LibCustomMenu
-- 2016-7-26 AM - added global funcs for events
-- the following functions are all globals, not tied to the IIfA class, but call the IIfA class member functions for event processing

-- 2015-3-7 AssemblerManiac - added code to collect inventory data at char disconnect
local function IIfA_EventOnPlayerUnloaded()
  -- update the stored inventory every time character logs out, will assure it's always right when viewing from other chars
  IIfA:CollectAll(false)    -- don't call async lib

  IIfA.CharCurrencyFrame:UpdateAssets()
  IIfA.CharBagFrame:UpdateAssets()
end


-- used by an event function
function IIfA:InventorySlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
  if nil == bagId or nil == slotIndex then return end

  local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
  if not itemLink then itemLink = IIfA.EMPTY_STRING end
  local itemKey = IIfA:GetItemKey(itemLink, nil)    -- yes, the nil can be left off, but this way we know it's supposed to take a 2nd arg)
  if not itemKey then itemKey = IIfA.EMPTY_STRING end
  IIfA:DebugOut("[InventorySlotUpdate] - raw bag/slot=<<1>> / <<2>>, Item='<<3>>', itemId=<<4>>, stackCountChange=<<5>>", bagId, slotIndex, itemLink, itemKey, stackCountChange)
  if #itemLink == 0 and IIfA.BagSlotInfo[bagId] ~= nil and IIfA.BagSlotInfo[bagId][slotIndex] then
    itemKey = IIfA.BagSlotInfo[bagId][slotIndex]
    if #itemKey < 10 and IIfA.database[itemKey] then
      itemLink = IIfA.database[itemKey].itemLink
    elseif #itemKey >= 10 then
      itemLink = itemKey
    end
    --IIfA:DebugOut("no itemlink, lookup found key=<<1>>, link=<<2>>", itemKey, itemLink)
  elseif #itemLink > 0 and IIfA.BagSlotInfo[bagId] == nil then
    IIfA.BagSlotInfo[bagId] = {}
    IIfA.BagSlotInfo[bagId][slotIndex] = itemKey
    --IIfA:DebugOut("New bag, new slot, bag=<<1>, slot=<<2>, key=<<3>>, link=<<4>>", bagId, slotIndex, itemKey, itemLink)
  elseif #itemLink > 0 and IIfA.BagSlotInfo[bagId][slotIndex] == nil then
    IIfA.BagSlotInfo[bagId][slotIndex] = itemKey
    --IIfA:DebugOut("Existing bag, new slot=<<1>>, key=<<2>>, link=<<3>>", slotIndex, itemKey, itemLink)
  elseif #itemLink > 0 then
    -- item is still in it's slot, force EvalBagItem to pick up the proper stackCountChange from the slot
    IIfA:DebugOut("[InventorySlotUpdate] - nilling out stackCountChange")
    stackCountChange = nil
  end

  IIfA:DebugOut("Inv Slot Upd <<1>> - bag/slot <<2>>/<<3>> x<<4>>, new: <<5>>", itemLink, bagId, slotIndex, stackCountChange, tostring(isNewItem))

  -- (bagId, slotNum, fromXfer, itemCount, itemLink, itemName, locationID)
  local dbItem, itemKey = self:EvalBagItem(bagId, slotIndex, not isNewItem, stackCountChange, itemLink)


  -- once a bunch of items comes in, this will be created for each, but only the last one stays alive
  -- so once all the items are finished coming in, it'll only need to update the shown list one time
  local callbackName = "IIfA_RefreshInventoryScroll"
  local function Update()
    EVENT_MANAGER:UnregisterForUpdate(callbackName)
    if IIFA_GUI:IsControlHidden() then
      return
    else
      IIfA:RefreshInventoryScroll()
    end
  end

  --cancel previously scheduled update if any
  EVENT_MANAGER:UnregisterForUpdate(callbackName)
  --register a new one
  if not IIFA_GUI:IsControlHidden() then
    -- only update the frame if it's shown
    EVENT_MANAGER:RegisterForUpdate(callbackName, 250, Update)
  end
end

local function IIfA_InventorySlotUpdate(...)
  IIfA:InventorySlotUpdate(...)
end

local function IIfA_ScanHouse(eventCode, oldMode, newMode)
  IIfA:DebugOut("IIfA_ScanHouse(<<1>>, <<2>>, <<3>>)", eventCode, oldMode, newMode)
  if newMode == "showing" or newMode == "shown" then return end
  -- are we listening?
  if not IIfA:GetCollectingHouseData() then return end
  local collectibleId = GetCollectibleIdForHouse(GetCurrentZoneHouseId())
  IIfA:DebugOut(zo_strformat("Housing editor mode is now <<2>> - calling IIfA:RescanHouse(<<1>>)", collectibleId, newMode))
  IIfA:RescanHouse(collectibleId)
end

local function IIfA_HouseEntered(eventCode)
  if not IsOwnerOfCurrentHouse() then return end

  -- is the house registered?
  local houseCollectibleId = GetCollectibleIdForHouse(GetCurrentZoneHouseId())

  if nil == IIfA.data.collectHouseData[houseCollectibleId] then
    IIfA:SetTrackingForHouse(houseCollectibleId, IIfA:GetCollectingHouseData())
  end
  IIfA:GetTrackedBags()[houseCollectibleId] = IIfA:GetTrackedBags()[houseCollectibleId] or IIfA.data.collectHouseData[houseCollectibleId]
  if IIfA:GetTrackedBags()[houseCollectibleId] then
    IIfA:RescanHouse(houseCollectibleId)
  end
end

-- request from Baertram - add right click context menu "Search thru Inventory Insight" to item links
local function addItemLinkSearchContextMenuEntry(itemLink, rowControl)
  if rowControl then
    local slotType = ZO_InventorySlot_GetType(rowControl)
    if slotType == SLOT_TYPE_ITEM or slotType == SLOT_TYPE_EQUIPMENT or slotType == SLOT_TYPE_BANK_ITEM or slotType == SLOT_TYPE_GUILD_BANK_ITEM or
      slotType == SLOT_TYPE_TRADING_HOUSE_POST_ITEM or slotType == SLOT_TYPE_REPAIR or slotType == SLOT_TYPE_CRAFTING_COMPONENT or slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or
      slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or slotType == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or slotType == SLOT_TYPE_CRAFT_BAG_ITEM then
      local bag, index = ZO_Inventory_GetBagAndIndex(rowControl)
      itemLink = GetItemLink(bag, index)
    end
    if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
      itemLink = GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(rowControl), LINK_STYLE_DEFAULT)
    end
    if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
      itemLink = GetTradingHouseListingItemLink(ZO_Inventory_GetSlotIndex(rowControl), LINK_STYLE_DEFAULT)
    end
    local hasStoreIndexData = rowControl and rowControl.index and slotType == SLOT_TYPE_STORE_BUY
    if hasStoreIndexData then
      itemLink = GetStoreItemLink(rowControl.index, LINK_STYLE_DEFAULT)
    end
  end
  if not itemLink or itemLink == IIfA.EMPTY_STRING then return end
  --Get the item's name from the link
  local itemNameClean = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
  if not itemNameClean or itemNameClean == IIfA.EMPTY_STRING then return end
  --Change the dropdown box of IIfA to "All", GetString(IIFA_LOCATION_NAME_ALL)
  if IIFA_GUI_Header_Dropdown_Main then
    local comboBox = IIFA_GUI_Header_Dropdown_Main.m_comboBox
    comboBox:SetSelectedItem(comboBox.m_sortedItems[1].name)
  end
  --Put the name in the IIfA search box
  IIfA.GUI_SearchBox:SetText(itemNameClean)
  IIfA:ApplySearchText(itemNameClean)
  --Open the IIfA UI if not already shown
  if IIFA_GUI:IsControlHidden() then
    IIfA:ToggleInventoryFrame()
  end
end

--Contextmenu from chat/link handler
local function IIfA_linkContextRightClick(link, button, _, _, linkType, ...)
  if button == MOUSE_BUTTON_INDEX_RIGHT and linkType == ITEM_LINK_TYPE then
    --		d(debug.traceback())
    zo_callLater(function()
      AddCustomMenuItem("IIfA: Search inventories", function() addItemLinkSearchContextMenuEntry(link, nil) end, MENU_ADD_OPTION_LABEL)
      --Show the context menu entries at the itemlink handler now
      ShowMenu()
    end, 50)
  end
end

--Contextmenu from inventory row
local function ZO_InventorySlot_ShowContextMenu_For_IIfA(rowControl, slotActions)
  --Do not show if IIfA row is the parent
  if not rowControl or (rowControl.GetOwningWindow and rowControl:GetOwningWindow() == IIFA_GUI) then return end
  AddCustomMenuItem("IIfA: Search inventories", function() addItemLinkSearchContextMenuEntry(nil, rowControl) end, MENU_ADD_OPTION_LABEL)
  --Show the context menu entries at the inventory row now
  ShowMenu(rowControl)
end

local function IIfA_EventDump(...)
  --d(...)
  local l = { ... }
  local s = IIfA.EMPTY_STRING
  for name, data in pairs(l) do
    if type(data) ~= "table" then
      s = s .. name .. " = " .. tostring(data) .. "\r\n"
    else
      s = s .. name .. " = {" .. "\r\n"
      for name1, data1 in pairs(data) do
        if type(data1) ~= "table" then
          s = s .. "\t" .. name1 .. " = " .. tostring(data1) .. "\r\n"
        else
          s = s .. "\t" .. name1 .. " = {}" .. "\r\n"
        end
      end
      s = s .. "}\r\n"
    end
  end
  d(s)
end

local function finv1(...)
  d("inventory slot changed")
  IIfA_EventDump(...)
end
local function finv2(...)
  d("inventory item destroyed")
  IIfA_EventDump(...)
end
local function finv3(...)
  d("inventory slot update")
  IIfA_EventDump(...)
end
local function fgb1(...)
  d("gb item add")
  IIfA_EventDump(...)
end
local function fgb2(...)
  d("gb item remove")
  IIfA_EventDump(...)
end
local function fgb3(...)
  d("gb selected")
  IIfA_EventDump(...)
end
local function fgb4(...)
  d("gb deselected")
  IIfA_EventDump(...)
end
local function fgb5(...)
  d("inventory fragment state change")
  IIfA_EventDump(...)
end

local function pre1(obj, ...)
  d("tradinghouse:DetermineIfTransitionIsComplete")
  d("self.disallowEvaluateTransitionCompleteCount = " .. obj.disallowEvaluateTransitionCompleteCount)
  d("state = " .. obj.state)
  --	IIfA_EventDump(...)
end
function IIfA_EventOnPlayerActivated()
  IIfA:LibAddonInit()
  EVENT_MANAGER:UnregisterForEvent("IIFA_PLAYER_ACTIVATED_EVENTS", EVENT_PLAYER_ACTIVATED)
end

function IIfA:RegisterForEvents()
  -- 2016-6-24 AM - commented this out, doing nothing at the moment, revisit later
  EVENT_MANAGER:RegisterForEvent("IIFA_PLAYER_ACTIVATED_EVENTS", EVENT_PLAYER_ACTIVATED, IIfA_EventOnPlayerActivated)

  -- 2015-3-7 AssemblerManiac - added EVENT_PLAYER_DEACTIVATED event
  EVENT_MANAGER:RegisterForEvent("IIFA_PLAYER_UNLOADED_EVENTS", EVENT_PLAYER_DEACTIVATED, IIfA_EventOnPlayerUnloaded)

  -- when item comes into inventory
  EVENT_MANAGER:RegisterForEvent("IIFA_InventorySlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, IIfA_InventorySlotUpdate)
  EVENT_MANAGER:AddFilterForEvent("IIFA_InventorySlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

  --	EVENT_MANAGER:RegisterForEvent("IIFA_unknown", EVENT_ITEM_SLOT_CHANGED, finv1)
  --	EVENT_MANAGER:RegisterForEvent("IIFA_unknown", EVENT_INVENTORY_ITEM_USED, IIfA_EventDump)	-- arg 1 = event id, arg 2 = 27 (slot #?)
  --	EVENT_MANAGER:RegisterForEvent("IIFA_unknown", EVENT_INVENTORY_ITEM_DESTROYED, finv2)
  --	EVENT_MANAGER:RegisterForEvent("IIFA_unknown", EVENT_JUSTICE_FENCE_UPDATE, IIfA_EventDump) -- # sold, # laundered is sent to event handler

  -- not helpful, no link at all on this callback
  --	SHARED_INVENTORY:RegisterCallback("SlotRemoved", IIfA_EventDump)
  --	SHARED_INVENTORY:RegisterCallback("SingleSlotInventoryUpdate", IIfA_EventDump)


  -- Events for data collection
  --	EVENT_MANAGER:RegisterForEvent("IIFA_ALPUSH", 		EVENT_ACTION_LAYER_PUSHED, 	function() IIfA:ActionLayerInventoryUpdate() end)
  EVENT_MANAGER:RegisterForEvent("IIFA_BANK_OPEN", EVENT_OPEN_BANK, function() IIfA:ScanBank() end)

  -- on opening guild bank:
  EVENT_MANAGER:RegisterForEvent("IIFA_GUILDBANK_LOADED", EVENT_GUILD_BANK_ITEMS_READY, function() IIfA:GuildBankDelayReady() end)

  --	EVENT_MANAGER:RegisterForEvent("IIFA_gb1", EVENT_GUILD_BANK_OPEN_ERROR, fgb1)
  --	EVENT_MANAGER:RegisterForEvent("IIFA_gb2", EVENT_GUILD_BANK_UPDATED_QUANTITY, fgb2)
  --	EVENT_MANAGER:RegisterForEvent("IIFA_gb3", EVENT_GUILD_BANK_SELECTED, fgb3)
  --	EVENT_MANAGER:RegisterForEvent("IIFA_gb4", EVENT_GUILD_BANK_DESELECTED, fgb4)
  --	EVENT_MANAGER:RegisterForEvent("IIFA_gb5", EVENT_GUILD_BANK_ITEMS_READY, fgb5)


  -- on adding or removing an item from the guild bank:
  EVENT_MANAGER:RegisterForEvent("IIFA_GUILDBANK_ITEM_ADDED", EVENT_GUILD_BANK_ITEM_ADDED, function(...) IIfA:GuildBankAddRemove(...) end)
  EVENT_MANAGER:RegisterForEvent("IIFA_GUILDBANK_ITEM_REMOVED", EVENT_GUILD_BANK_ITEM_REMOVED, function(...) IIfA:GuildBankAddRemove(...) end)

  -- Housing
  EVENT_MANAGER:RegisterForEvent("IIFA_HOUSING_PLAYER_INFO_CHANGED", EVENT_PLAYER_ACTIVATED, IIfA_HouseEntered)
  EVENT_MANAGER:RegisterForEvent("IIfA_HOUSE_MANAGER_MODE_CHANGED", EVENT_HOUSING_EDITOR_MODE_CHANGED, IIfA_ScanHouse)

  EVENT_MANAGER:RegisterForEvent("IIFA_GuildJoin", EVENT_GUILD_SELF_JOINED_GUILD, function() IIfA:CreateOptionsMenu() end)
  EVENT_MANAGER:RegisterForEvent("IIFA_GuildLeave", EVENT_GUILD_SELF_LEFT_GUILD, function() IIfA:CreateOptionsMenu() end)

  --    ZO_QuickSlot:RegisterForEvent(EVENT_ABILITY_COOLDOWN_UPDATED, IIfA_EventDump)
  ZO_PreHook('ZO_InventorySlot_ShowContextMenu', function(rowControl) IIfA:ProcessRightClick(rowControl) end)

  -- handle right clicks on links
  --Add contextmenu entry to items to search for the item in the IIfA UI
  if IIfA:GetSettings().bAddContextMenuEntrySearchInIIfA == true then
    --The link handler context menu
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, IIfA_linkContextRightClick)
    --The inventory row context menu
    LCM:RegisterContextMenu(ZO_InventorySlot_ShowContextMenu_For_IIfA)
  end


  --	ZO_PreHook(TRADING_HOUSE_SCENE, "DetermineIfTransitionIsComplete", pre1)

end


--[[ registerfilter & events
define HOW to listen for events (minimize # of calls to event handler, less overhead of eso internals)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,  REGISTER_FILTER_BAG_ID, BAG_BACKPACK)
EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,  REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
--]]


--[[ event for SHARED_INVENTORY:RegisterCallback sends as follows, and has no itemlink :(
arg 1 = 5		-- bag id
arg 2 = 71198		-- slot number
arg 3 = {
  inventory = {}
  condition = 100
  age = 6702.2509765625
  isPlaceableFurniture = false
  searchData = {}
  requiredLevel = 1
  stackCount = 1426
  stolen = false
  isPlayerLocked = false
  brandNew = true
  sellPrice = 2
  itemInstanceId = 3340100312
  statValue = 0
  rawName = rubedite ore
  locked = false
  isJunk = false
  stackSellPrice = 2852
  slotIndex = 71198
  specializedItemType = 0
  isBoPTradeable = false
  meetsUsageRequirement = true
  quality = 1
  filterData = {}
  equipType = 0
  name = Rubedite Ore
  itemType = 35
  bagId = 5
  stackLaunderPrice = 0
  uniqueId = 3.5176485852605e-319
  iconFile = /esoui/art/icons/crafting_jewelry_base_ruby_r1.dds
  launderPrice = 0
  }

--]]
