local LMP = LibMediaProvider

IIfA.LastActiveRowControl = nil

local function p(...) IIfA:DebugOut(...) end

function IIfA:addStatsPopupTooltip(...)
  d("IIFA - Popup tooltip OnUpdate hit")
  d(...)
end

-- 2018-3-22 AM - duplicate ZO_Tooltip_AddDivider so we can set the color of our divider to match whatever is popped up (stolen or not)
function IIfA:Tooltip_AddDivider(tooltipControl)
  ZO_Tooltip_AddDivider(tooltipControl)

  --[[
    if not tooltipControl.dividerPool then
      tooltipControl.dividerPool = ZO_ControlPool:New("ZO_BaseTooltipDivider", tooltipControl, "Divider")
    end

    local divider = tooltipControl.dividerPool:AcquireObject()

    if divider then
      -- AM - new code
      local div1
      div1 = tooltipControl:GetNamedChild("Divider1")
      if div1 then
  --			d(div1:GetTextureFileName() .. " / " .. divider:GetTextureFileName())
        divider:SetTexture(div1:GetTextureFileName())
      end
      -- AM - end new code
      tooltipControl:AddControl(divider)
      divider:SetAnchor(CENTER)
    end
   ]]
end

function IIfA:CreateTooltips()
  WINDOW_MANAGER:CreateControlFromVirtual("IIFA_ITEM_TOOLTIP", ItemTooltipTopLevel, "IIFA_ITEM_TOOLTIP")
  WINDOW_MANAGER:CreateControlFromVirtual("IIFA_POPUP_TOOLTIP", ItemTooltipTopLevel, "IIFA_POPUP_TOOLTIP")

  --	zo_callLater(function() ZO_PreHookHandler(PopupTooltip, 'OnAddGameData', IIfA_TooltipOnTwitch) end , 7000)
  --	ZO_PreHookHandler(PopupTooltip, 'OnUpdate', function() self:addStatsPopupTooltip() end)
  ZO_PreHookHandler(PopupTooltip, 'OnAddGameData', IIfA_TooltipOnTwitch)
  ZO_PreHookHandler(PopupTooltip, 'OnHide', IIfA_HideTooltip)

  ZO_PreHookHandler(ItemTooltip, 'OnAddGameData', IIfA_TooltipOnTwitch)
  ZO_PreHookHandler(ItemTooltip, 'OnHide', IIfA_HideTooltip)

  ZO_PreHook("ZO_PopupTooltip_SetLink", function(itemLink) IIfA.TooltipLink = itemLink end)

  IIfA:SetTooltipFont()
end

-- /script d(_G["ZoFontGame"]:GetFontInfo())
function IIfA:SetTooltipFont()
  local settings = IIfA:GetSettings()
  local fontFace = settings.TooltipFontFace
  local fontSize = tonumber(settings.TooltipFontSize)
  local fontEffect = string.lower(settings.TooltipFontEffect)
  local fontString = "%s|%s|%s"
  local font = LMP:Fetch('font', fontFace)
  if not font then font = IIfA.defaults.TooltipFontFace end
  IIfA.TooltipFont = string.format(fontString, font, fontSize, fontEffect)
end

local function getTex(name)
  return ("IIfA/assets/icons/" .. name .. ".dds")
end

IIfA.racialTextures = {
  [0] = { styleName = IIfA.EMPTY_STRING, styleTexture = IIfA.EMPTY_STRING },
  [1] = { styleName = zo_strformat("<<1>>", GetItemStyleName(1)), styleTexture = getTex("breton") }, -- Breton
  [2] = { styleName = zo_strformat("<<1>>", GetItemStyleName(2)), styleTexture = getTex("redguard") }, -- Redguard
  [3] = { styleName = zo_strformat("<<1>>", GetItemStyleName(3)), styleTexture = getTex("orsimer") }, -- Orc
  [4] = { styleName = zo_strformat("<<1>>", GetItemStyleName(4)), styleTexture = getTex("dunmer") }, -- Dark Elf
  [5] = { styleName = zo_strformat("<<1>>", GetItemStyleName(5)), styleTexture = getTex("nord") }, -- Nord
  [6] = { styleName = zo_strformat("<<1>>", GetItemStyleName(6)), styleTexture = getTex("argonian") }, -- Argonian
  [7] = { styleName = zo_strformat("<<1>>", GetItemStyleName(7)), styleTexture = getTex("altmer") }, -- High Elf
  [8] = { styleName = zo_strformat("<<1>>", GetItemStyleName(8)), styleTexture = getTex("bosmer") }, -- Wood Elf
  [9] = { styleName = zo_strformat("<<1>>", GetItemStyleName(9)), styleTexture = getTex("khajit") }, -- Khajiit
  [10] = { styleName = zo_strformat("<<1>>", GetItemStyleName(10)), styleTexture = getTex("telvanni") }, -- Unique
  [11] = { styleName = zo_strformat("<<1>>", GetItemStyleName(11)), styleTexture = getTex("thief") }, -- Thieves Guild
  [12] = { styleName = zo_strformat("<<1>>", GetItemStyleName(12)), styleTexture = getTex("darkbrotherhood") }, -- Dark Brotherhood
  [13] = { styleName = zo_strformat("<<1>>", GetItemStyleName(13)), styleTexture = getTex("malacath") }, -- Malacath
  [14] = { styleName = zo_strformat("<<1>>", GetItemStyleName(14)), styleTexture = getTex("dwemer") }, -- Dwemer
  [15] = { styleName = zo_strformat("<<1>>", GetItemStyleName(15)), styleTexture = getTex("ancient") }, -- Ancient Elf
  [16] = { styleName = zo_strformat("<<1>>", GetItemStyleName(16)), styleTexture = getTex("akatosh") }, -- Akatosh
  [17] = { styleName = zo_strformat("<<1>>", GetItemStyleName(17)), styleTexture = getTex("reach") }, -- Reach
  [18] = { styleName = zo_strformat("<<1>>", GetItemStyleName(18)), styleTexture = getTex("bandit") }, -- Bandit
  [19] = { styleName = zo_strformat("<<1>>", GetItemStyleName(19)), styleTexture = getTex("primitive") }, -- Primitive
  [20] = { styleName = zo_strformat("<<1>>", GetItemStyleName(20)), styleTexture = getTex("daedric") }, -- Daedric
  [21] = { styleName = zo_strformat("<<1>>", GetItemStyleName(21)), styleTexture = getTex("trinimac") }, -- Trinimac
  [22] = { styleName = zo_strformat("<<1>>", GetItemStyleName(22)), styleTexture = getTex("orsimer") }, -- Ancient Orc
  [23] = { styleName = zo_strformat("<<1>>", GetItemStyleName(23)), styleTexture = getTex("daggerfall") }, -- Daggerfall Covenant - "Ding-a-ling Smurf"
  [24] = { styleName = zo_strformat("<<1>>", GetItemStyleName(24)), styleTexture = getTex("ebonheart") }, -- Ebonheart Pact - "Funny Tomato"
  [25] = { styleName = zo_strformat("<<1>>", GetItemStyleName(25)), styleTexture = getTex("ancient") }, -- Aldmeri Dominion - "chiquita banana"
  [26] = { styleName = zo_strformat("<<1>>", GetItemStyleName(26)), styleTexture = getTex("laurel") }, -- Undaunted
  [27] = { styleName = zo_strformat("<<1>>", GetItemStyleName(27)), styleTexture = getTex("dragonknight") }, -- Craglorn
  [28] = { styleName = zo_strformat("<<1>>", GetItemStyleName(28)), styleTexture = getTex("templar") }, -- Glass
  [29] = { styleName = zo_strformat("<<1>>", GetItemStyleName(29)), styleTexture = getTex("nightblade") }, -- Xivkyn
  [30] = { styleName = zo_strformat("<<1>>", GetItemStyleName(30)), styleTexture = getTex("soulshriven") }, -- Soul Shriven
  [31] = { styleName = zo_strformat("<<1>>", GetItemStyleName(31)), styleTexture = getTex("skull") }, -- Draugr
  [32] = { styleName = zo_strformat("<<1>>", GetItemStyleName(32)), styleTexture = getTex("maormer") }, -- Maormer
  [33] = { styleName = zo_strformat("<<1>>", GetItemStyleName(33)), styleTexture = getTex("akaviri") }, -- Akaviri
  [34] = { styleName = zo_strformat("<<1>>", GetItemStyleName(34)), styleTexture = getTex("imperial") }, -- Imperial
  [35] = { styleName = zo_strformat("<<1>>", GetItemStyleName(35)), styleTexture = getTex("akaviri") }, -- Yokudan
  [36] = { styleName = zo_strformat("<<1>>", GetItemStyleName(36)), styleTexture = getTex("imperial") }, -- "Universal" ???
  [37] = { styleName = zo_strformat("<<1>>", GetItemStyleName(37)), styleTexture = getTex("reach") }, -- Reach Winter
  [38] = { styleName = zo_strformat("<<1>>", GetItemStyleName(38)), styleTexture = getTex("tsaesci") }, -- Tsaesci
  [39] = { styleName = zo_strformat("<<1>>", GetItemStyleName(39)), styleTexture = getTex("minotaur") }, -- Minotaur
  [40] = { styleName = zo_strformat("<<1>>", GetItemStyleName(40)), styleTexture = getTex("ebony") }, -- Ebony
  [41] = { styleName = zo_strformat("<<1>>", GetItemStyleName(41)), styleTexture = getTex("abahswatch") }, -- Abah's Watch
  [42] = { styleName = zo_strformat("<<1>>", GetItemStyleName(42)), styleTexture = getTex("skinchanger") }, -- Skinchanger
  [43] = { styleName = zo_strformat("<<1>>", GetItemStyleName(43)), styleTexture = getTex("moragtong") }, -- Morag Tong
  [44] = { styleName = zo_strformat("<<1>>", GetItemStyleName(44)), styleTexture = getTex("ragada") }, -- Ra Gada
  [45] = { styleName = zo_strformat("<<1>>", GetItemStyleName(45)), styleTexture = getTex("dromathra") }, -- Dro-m'Athra
  [46] = { styleName = zo_strformat("<<1>>", GetItemStyleName(46)), styleTexture = getTex("assassin") }, -- Assassins League
  [47] = { styleName = zo_strformat("<<1>>", GetItemStyleName(47)), styleTexture = getTex("outlaw") }, -- Outlaw
  [48] = { styleName = zo_strformat("<<1>>", GetItemStyleName(48)), styleTexture = getTex("redoran") }, -- Redoran
  [49] = { styleName = zo_strformat("<<1>>", GetItemStyleName(49)), styleTexture = getTex("hlaalu") }, -- Hlaalu
  [50] = { styleName = zo_strformat("<<1>>", GetItemStyleName(50)), styleTexture = getTex("ordinator") }, -- Militant Ordinator
  [51] = { styleName = zo_strformat("<<1>>", GetItemStyleName(51)), styleTexture = getTex("telvanni") }, -- Telvanni
  [52] = { styleName = zo_strformat("<<1>>", GetItemStyleName(52)), styleTexture = getTex("buoyantarmiger") }, -- Buoyant Armiger
  [53] = { styleName = zo_strformat("<<1>>", GetItemStyleName(53)), styleTexture = getTex("frostcaster") }, -- Frostcaster
  [54] = { styleName = zo_strformat("<<1>>", GetItemStyleName(54)), styleTexture = getTex("cliffracer") }, -- Ashlander
  [55] = { styleName = zo_strformat("<<1>>", GetItemStyleName(55)), styleTexture = getTex("skull_nice") }, -- Worm Cult
  [56] = { styleName = zo_strformat("<<1>>", GetItemStyleName(56)), styleTexture = getTex("kothringi") }, -- Silken Ring
  [57] = { styleName = zo_strformat("<<1>>", GetItemStyleName(57)), styleTexture = getTex("lizard") }, -- Mazzatun
  [58] = { styleName = zo_strformat("<<1>>", GetItemStyleName(58)), styleTexture = getTex("harlequin") }, -- Grim Harlequin
  [59] = { styleName = zo_strformat("<<1>>", GetItemStyleName(59)), styleTexture = getTex("hollowjack") }, -- Hollowjack
  [60] = { styleName = zo_strformat("<<1>>", GetItemStyleName(60)), styleTexture = getTex("clockwork") }, -- Refabricated (Clockwork)
  [61] = { styleName = zo_strformat("<<1>>", GetItemStyleName(61)), styleTexture = getTex("bloodforge") }, -- Bloodforge
  [62] = { styleName = zo_strformat("<<1>>", GetItemStyleName(62)), styleTexture = getTex("dreadhorn") }, -- Dreadhorn
  [63] = { styleName = zo_strformat("<<1>>", GetItemStyleName(63)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Unused
  [64] = { styleName = zo_strformat("<<1>>", GetItemStyleName(64)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Unused
  [65] = { styleName = zo_strformat("<<1>>", GetItemStyleName(65)), styleTexture = getTex("apostle") }, -- Apostle
  [66] = { styleName = zo_strformat("<<1>>", GetItemStyleName(66)), styleTexture = getTex("ebonshadow") }, -- Ebonshadow
  [67] = { styleName = zo_strformat("<<1>>", GetItemStyleName(67)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Undaunted
  [68] = { styleName = zo_strformat("<<1>>", GetItemStyleName(68)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Unused
  [69] = { styleName = zo_strformat("<<1>>", GetItemStyleName(69)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Fang Lair
  [70] = { styleName = zo_strformat("<<1>>", GetItemStyleName(70)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Scalecaller (dragon priest)
  [71] = { styleName = zo_strformat("<<1>>", GetItemStyleName(71)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Psijic Order
  [72] = { styleName = zo_strformat("<<1>>", GetItemStyleName(72)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Sapiarch
  [73] = { styleName = zo_strformat("<<1>>", GetItemStyleName(73)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Welkynar
  [74] = { styleName = zo_strformat("<<1>>", GetItemStyleName(74)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Dremora
  [75] = { styleName = zo_strformat("<<1>>", GetItemStyleName(75)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Pyandonean
  [76] = { styleName = zo_strformat("<<1>>", GetItemStyleName(76)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Divine Prosecution
  [77] = { styleName = zo_strformat("<<1>>", GetItemStyleName(77)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Huntsman
  [78] = { styleName = zo_strformat("<<1>>", GetItemStyleName(78)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Silver Dawn
  [79] = { styleName = zo_strformat("<<1>>", GetItemStyleName(79)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Dead-Water
  [80] = { styleName = zo_strformat("<<1>>", GetItemStyleName(80)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Honor Guard
  [81] = { styleName = zo_strformat("<<1>>", GetItemStyleName(81)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Elder Argonian
  [82] = { styleName = zo_strformat("<<1>>", GetItemStyleName(82)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Coldsnap
  [83] = { styleName = zo_strformat("<<1>>", GetItemStyleName(83)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Meridian
  [84] = { styleName = zo_strformat("<<1>>", GetItemStyleName(84)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Anequina
  [85] = { styleName = zo_strformat("<<1>>", GetItemStyleName(85)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Pellitine
  [86] = { styleName = zo_strformat("<<1>>", GetItemStyleName(86)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Sunspire
  [87] = { styleName = zo_strformat("<<1>>", GetItemStyleName(87)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Dragon Bone
  [88] = { styleName = zo_strformat("<<1>>", GetItemStyleName(88)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Moongrave
  [89] = { styleName = zo_strformat("<<1>>", GetItemStyleName(89)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Stags of Z'en
  [90] = { styleName = zo_strformat("<<1>>", GetItemStyleName(90)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Witches Festival 2019 ???
  [91] = { styleName = zo_strformat("<<1>>", GetItemStyleName(91)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Unused
  [92] = { styleName = zo_strformat("<<1>>", GetItemStyleName(92)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Dragonguard
  [93] = { styleName = zo_strformat("<<1>>", GetItemStyleName(93)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Moongrave Fane
  [94] = { styleName = zo_strformat("<<1>>", GetItemStyleName(94)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- New Moon
  [95] = { styleName = zo_strformat("<<1>>", GetItemStyleName(95)), styleTexture = getTex(IIfA.EMPTY_STRING) }, -- Shields of Senchal
}

-- /script local i for i=80,100 do d(i .. " " .. GetItemStyleName(i)) end

local controlTooltips = {
  ["LineShare"] = "Doubleclick an item to add link to chat.",
  ["close"] = "close",
  ["toggle"] = "toggle",
  ["Search"] = "Search item name..."
}

local function getStyleIntel(itemLink)
  if not itemLink then
    return nil
  end
  if IIfA:GetSettings().showStyleInfo == false then
    return nil
  end

  local data = itemLink:match("|H.:item:(.-)|h.-|h")
  -- d(data)
  -- d(zo_strsplit(':', data))
  local itemID,
  _,
  itemLevel,
  itemEnchantmentType,
  itemEnchantmentStrength1,
  itemEnchantmentStrength2,
  _, _, _, _, _, _, _, _, _,
  itemStyle,
  _,
  itemIsBound,
  itemChargeStatus = zo_strsplit(':', data)

  itemStyle = tonumber(itemStyle)

  if itemStyle == ITEMSTYLE_UNIVERSAL then
    return nil
  else
    return IIfA.racialTextures[itemStyle]
  end
end

function IIfA:AnchorFrame(frame, parentTooltip)
  local frameHeight = frame:GetHeight() -- height of IIFA tooltip
  local uiWidth, uiHeight = GuiRoot:GetDimensions() -- Screen Resolution
  local bottom = parentTooltip:GetBottom() -- Bottom of ZO tooltip
  local difference = zo_abs(uiHeight - bottom)
  local tooltipAtBottom = difference >= frameHeight
  if tooltipAtBottom then
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, parentTooltip, BOTTOMLEFT, 0, 0)
    frame:SetAnchor(TOPRIGHT, parentTooltip, BOTTOMRIGHT, 0, 0)
  else
    frame:ClearAnchors()
    frame:SetAnchor(BOTTOMLEFT, parentTooltip, TOPLEFT, 0, 0)
    frame:SetAnchor(BOTTOMRIGHT, parentTooltip, TOPRIGHT, 0, 0)
  end
end

-- do NOT local this function
function IIfA_HideTooltip(control, ...)
  if IIfA:GetSettings().bInSeparateFrame then
    if control == ItemTooltip then
      IIFA_ITEM_TOOLTIP:SetHidden(true)
    elseif control == PopupTooltip then
      IIFA_POPUP_TOOLTIP:SetHidden(true)
    end
  else
    if control.IIfA_TT_Ext then
      control.IIfAPool:ReleaseAllObjects()
      control.IIfA_TT_Ext = nil
    end
  end
end

-- do NOT local this function
function IIfA_TooltipOnTwitch(control, eventNum)
  if IIfA:GetSettings().bInSeparateFrame then
    if eventNum == TOOLTIP_GAME_DATA_ITEM_ICON then
      --7
      if control == ItemTooltip then
        -- item tooltips appear where mouse is
        return IIfA:UpdateTooltip(IIFA_ITEM_TOOLTIP)
      elseif control == PopupTooltip then
        return IIfA:UpdateTooltip(IIFA_POPUP_TOOLTIP)
      end
    end
  else

    if control == PopupTooltip and control.IIfA_TT_Ext then
      return
    end
    -- this is called whenever there's any data added to the ingame tooltip
    --if eventNum == TOOLTIP_GAME_DATA_MAX_VALUE then		-- hopefully always called on last data add
    --[[
    For people who have configured the tooltip information to show in the tooltip and not in a separate frame, you can fix the issue introduced in Update 29 this way:

Open IIfATooltip.lua
Go to line 297
Change TOOLTIP_GAME_DATA_MAX_VALUE to TOOLTIP_GAME_DATA_STOLEN


What changed in Update 29 is that they introduced a new enumeration: TOOLTIP_GAME_DATA_CHAMPION_PROGRESSION. So in the previous patch, when OnAddGameData was called with TOOLTIP_GAME_DATA_STOLEN (the previous max value), it would trigger the tooltip update. But in Update 29, the max value is now TOOLTIP_GAME_DATA_CHAMPION_PROGRESSION, and OnAddGameData is never called with TOOLTIP_GAME_DATA_CHAMPION_PROGRESSION for an item tooltip.

TL;DR: IIfA assumed that TOOLTIP_GAME_DATA_MAX_VALUE would always be valid for an item tooltip, but ZOS broke that assumption by adding a data type for CP 2.0 that doesn't appear in item tooltips.
Last edited by code65536 : 03/10/21 at 02:09 PM.
    ]]
    --Current max value 9 2021-10-31 is TOOLTIP_GAME_DATA_CHAMPION_PROGRESSION
    if eventNum == TOOLTIP_GAME_DATA_MYTHIC_OR_STOLEN then
      --p("Tooltip On Twitch - " .. control:GetName() .. ", " .. eventNum)
      IIfA:UpdateTooltip(control)
    end
  end
end

-- /script d(IIfA:SetCrafted("|H1:item:43542:366:50:0:0:0:0:0:0:0:0:0:0:0:0:5:0:0:0:10000:0|h|h"))
function IIfA:SetCrafted(itemLink)
  local linkParse = { ZO_LinkHandler_ParseLink(itemLink) }
  local craftedlink = string.format("|H1:item:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s|h|h", linkParse[4],
    linkParse[5], linkParse[6], linkParse[7], linkParse[8], linkParse[9], linkParse[10], linkParse[11],
    linkParse[12], linkParse[13], linkParse[14], linkParse[15], linkParse[16], linkParse[17], linkParse[18],
    linkParse[19], "1", linkParse[21], linkParse[22], linkParse[23], linkParse[24])
  return craftedlink
end

function IIfA:SetLevelAndQuality(itemLink)
  local linkParse = { ZO_LinkHandler_ParseLink(itemLink) }
  local itemLevel = GetItemLinkDisplayQuality(itemLink) + 1
  local craftedlink = string.format("|H1:item:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s:%s|h|h", linkParse[4],
    itemLevel, "1", linkParse[7], linkParse[8], linkParse[9], linkParse[10], linkParse[11],
    linkParse[12], linkParse[13], linkParse[14], linkParse[15], linkParse[16], linkParse[17], linkParse[18],
    linkParse[19], linkParse[20], linkParse[21], linkParse[22], linkParse[23], linkParse[24])
  return craftedlink
end

function IIfA:CheckLevelAndQuality(itemLink)
  local linkParse = { ZO_LinkHandler_ParseLink(itemLink) }
  local noLevelAndQuality = tonumber(linkParse[5]) == 0 and tonumber(linkParse[6]) == 0
  if noLevelAndQuality then return IIfA:SetLevelAndQuality(itemLink) else
  return itemLink end
end

function IIfA:SetItemLinkBrackets(itemLink)
  return string.gsub(itemLink, '|H0', '|H1')
end

function IIfA:getMouseoverLink()
  local mouseOverControl = moc()
  if not mouseOverControl then return end
  local mouseOverControlParent
  local mouseOverControlGrandparent
  local mocOwner

  if mouseOverControl.GetParent then mouseOverControlParent = mouseOverControl:GetParent() end
  if mouseOverControlParent and mouseOverControlParent.GetParent then mouseOverControlGrandparent = mouseOverControlParent:GetParent() end
  if mouseOverControl and mouseOverControl.GetOwningWindow then mocOwner = mouseOverControl:GetOwningWindow() end

  local mocName = mouseOverControl:GetName()
  local mocParentName
  local mocGPName
  local mocOwnerName

  if mouseOverControlParent then mocParentName = mouseOverControlParent:GetName() end
  if mouseOverControlGrandparent then mocGPName = mouseOverControlGrandparent:GetName() end
  if mocOwner then mocOwnerName = mocOwner:GetName() end

  -- do we show IIfA info?
  if IIfA:GetSettings().showToolTipWhen == GetString(IIFA_MANAGE_TOOLTIP_SHOW_NEVER) or
    (IIfA:GetSettings().showToolTipWhen == GetString(IIFA_MANAGE_TOOLTIP_SHOW_IIFA) and mocParentName ~= "IIFA_GUI_ListHolder") then
    return nil
  end

  local hasDataEntryData = mouseOverControl and mouseOverControl.dataEntry and mouseOverControl.dataEntry.data
  local hasParentData = mouseOverControlParent and mouseOverControlParent.data
  local hasMocData = mouseOverControl and mouseOverControl.data

  if mocParentName == 'ZO_CraftBagListContents' or
    mocParentName == 'ZO_PlayerInventoryListContents' or
    mocParentName == 'ZO_EnchantingTopLevelInventoryBackpackContents' or
    mocParentName == 'ZO_SmithingTopLevelRefinementPanelInventoryBackpackContents' or
    mocParentName == 'ZO_SmithingTopLevelDeconstructionPanelInventoryBackpackContents' or
    mocParentName == 'ZO_SmithingTopLevelImprovementPanelInventoryBackpackContents' or
    mocParentName == 'ZO_QuickSlot_Keyboard_TopLevelListContents' or
    mocParentName == 'ZO_PlayerBankBackpackContents' or
    mocParentName == 'ZO_GuildBankBackpackContents' or
    mocParentName == 'ZO_HouseBankBackpackContents' or
    mocParentName == 'ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpackContents' or
    mocParentName == "ZO_CompanionEquipment_Panel_KeyboardListContents" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    return GetItemLink(rowData.bagId, rowData.slotIndex, LINK_STYLE_BRACKETS)

  elseif mocOwnerName == "ZO_HousingFurniturePlacementPanel_KeyboardTopLevel" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    return GetItemLink(rowData.bagId, rowData.slotIndex, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_Character" then
    -- is worn item
    return GetItemLink(mouseOverControl.bagId, mouseOverControl.slotIndex, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_CompanionCharacterWindow_Keyboard_TopLevel" then
    -- is worn item
    return GetItemLink(mouseOverControl.bagId, mouseOverControl.slotIndex, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_LootAlphaContainerListContents" then
    -- is loot item
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    return GetLootItemLink(rowData.lootId, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_BuyBackListContents" then
    -- is buyback item
    return GetBuybackItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

  elseif mocParentName == "ZO_StoreWindowListContents" then
    -- is store item
    local itemLink = GetStoreItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)
    return IIfA:CheckLevelAndQuality(itemLink)

  elseif mocParentName == 'ZO_MailInboxMessageAttachments' then
    -- MAIL_INBOX:GetOpenMailId() is the id64 of the mail
    return GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), mouseOverControl.id, LINK_STYLE_DEFAULT)

  elseif mocParentName == 'ZO_MailSendAttachments' then
    return GetMailQueuedAttachmentLink(mouseOverControl.id, LINK_STYLE_DEFAULT)

    -- following 4 if's derived directly from MasterMerchant
  elseif mocOwnerName == 'MasterMerchantWindow' or
    mocOwnerName == 'MasterMerchantGuildWindow' or
    mocOwnerName == 'MasterMerchantPurchaseWindow' or
    mocOwnerName == 'MasterMerchantListingWindow' or
    mocOwnerName == 'MasterMerchantFilterByNameWindow' or
    mocOwnerName == 'MasterMerchantReportsWindow' then
    if mouseOverControl.GetText then
      return mouseOverControl:GetText()
    end

  elseif mocParentName == "IIFA_GUI_ListHolder" then
    --[[TODO this returns default current link but there are
    easier ways to get the itemLink for this window or other
    windows]]--

  elseif mocOwnerName == "IIFA_GUI" then
    --[[TODO update 12-13-2022 I do not believe this occurs even though
     it could because of the previous IIFA_GUI_ListHolder]]--
    --[[TODO verify the link type stored in IIFA because some links
    lack the level and quality and therefore don't return the IIFA
    inventory count]]--
    return mouseOverControl.itemLink

  elseif mocOwnerName == "FurCGui" then
    return IIfA:SetLevelAndQuality(mouseOverControl.itemLink)

  elseif mocParentName == "ZO_TradingHouseBrowseItemsRightPaneSearchResultsContents" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    if not rowData or rowData.timeRemaining == 0 then return end
    return GetTradingHouseSearchResultItemLink(rowData.slotIndex)

  elseif mocParentName == "ZO_TradingHousePostedItemsListContents" then
    if not hasDataEntryData then return end
    local rowData = mouseOverControl.dataEntry.data
    if not rowData or rowData.timeRemaining == 0 then return end
    return GetTradingHouseListingItemLink(rowData.slotIndex)

  elseif mocParentName == 'DolgubonSetCrafterWindowMaterialListListContents' then
    if not hasMocData then return end
    local rowData = mouseOverControl.data[1]
    if not rowData then return end
    return rowData.Name

  elseif mocGPName == "CraftingQueueScrollListContents" then
    if not hasParentData then return end
    local rowData = mouseOverControlParent.data[1]
    local rowDataLink = rowData.Link
    if not rowDataLink then return end
    return IIfA:SetCrafted(rowDataLink)

  elseif mocParentName == "ZO_InteractWindowRewardArea" then
    -- is reward item
    return GetQuestRewardItemLink(mouseOverControl.index, LINK_STYLE_BRACKETS)

  elseif mocOwnerName == 'CraftStoreFixed_Cook' or
    mocOwnerName == 'CraftStoreFixed_Rune' or
    mocOwnerName == 'CraftStoreFixed_Blueprint_Window' then
    if not hasMocData then return end
    local rowData = mouseOverControl.data
    return rowData.link

  elseif mocOwnerName == 'ZO_ClaimLevelUpRewardsScreen_Keyboard' then
    if not hasMocData then return end
    local rowData = mouseOverControl.data
    return rowData.itemLink

    --[[TODO verified to here ]]--
  else
    --		d(mouseOverControl:GetName(), mouseOverControl)
    if mocParentName then p("Tooltip not processed - '" .. mocParentName .. "'") end

    if IIfA.TooltipLink then
      p("Current Link - " .. IIfA.TooltipLink)
    end

    return nil
  end

  return IIfA.TooltipLink
end

function IIfA:getLastLink(tooltip)
  local ret = nil
  if IIfA:GetSettings().bInSeparateFrame then
    if tooltip == IIFA_POPUP_TOOLTIP then
      ret = IIfA.TooltipLink
    elseif tooltip == IIFA_ITEM_TOOLTIP then
      ret = self:getMouseoverLink()
    end
  else
    if tooltip == PopupTooltip then
      ret = IIfA.TooltipLink    -- this gets set on the prehook of PopupTooltip:SetLink
    elseif tooltip == ItemTooltip then
      ret = self:getMouseoverLink()
      IIfA.TooltipLink = ret    -- make sure it's set right always
    end
  end

  if (not ret) then
    if not IIfA.LastActiveRowControl then return ret end
    ret = IIfA.LastActiveRowControl:GetText()
  end

  return ret
end

function IIfA:UpdateTooltip(tooltip)
  --d("[IIfA]UpdateTooltip")
  -- do we show IIfA info?
  local mocParent = moc():GetParent()
  if IIfA:GetSettings().showToolTipWhen == GetString(IIFA_MANAGE_TOOLTIP_SHOW_NEVER) or
    (IIfA:GetSettings().showToolTipWhen == GetString(IIFA_MANAGE_TOOLTIP_SHOW_IIFA) and mocParent and mocParent:GetName() ~= "IIFA_GUI_ListHolder") then
    return
  end

  local itemLink, itemData
  itemLink = self:getLastLink(tooltip)

  --d(">item: " ..itemLink)

  local queryResults = IIfA:QueryAccountInventory(itemLink)
  local itemStyleTexArray = getStyleIntel(itemLink)

  if not itemStyleTexArray then itemStyleTexArray = { ["styleTexture"] = IIfA.EMPTY_STRING, ["styleName"] = IIfA.EMPTY_STRING } end
  if itemStyleTexArray.styleName == nil then itemStyleTexArray = { ["styleTexture"] = IIfA.EMPTY_STRING, ["styleName"] = IIfA.EMPTY_STRING } end

  if IIfA:GetSettings().bInSeparateFrame then
    local parentTooltip = nil
    if tooltip == IIFA_POPUP_TOOLTIP then parentTooltip = PopupTooltip end
    if tooltip == IIFA_ITEM_TOOLTIP then parentTooltip = ItemTooltip end

    IIfA:DebugOut(tooltip:GetName())
    IIfA:DebugOut(itemLink)
    --		/script d("|H0:item:28666:25:1:0:0:0:0:0:0:0:0:0:0:0:16:0:0:0:1:0:0|h|h")

    if (not itemLink) or ((#queryResults.locations == 0) and (itemStyleTexArray.styleName == IIfA.EMPTY_STRING)) then
      tooltip:SetHidden(true)
      return
    end

    tooltip:ClearLines()
    tooltip:SetHidden(false)

    tooltip:SetHeight(0)
    tooltip:SetWidth(parentTooltip:GetWidth())

    if itemStyleTexArray.styleName ~= IIfA.EMPTY_STRING then
      tooltip:AddLine(" ");
    end

    if (queryResults) then
      if #queryResults.locations > 0 then
        IIfA:DebugOut(queryResults)
        if itemStyleTexArray.styleName ~= IIfA.EMPTY_STRING then
          IIfA:Tooltip_AddDivider(tooltip)
        end
        for _, location in pairs(queryResults.locations) do
          local textOut
          if location.name == nil or location.itemsFound == nil then
            textOut = 'Error occurred'
          else
            textOut = zo_strformat("<<1>> x <<2>>", location.name, location.itemsFound)
          end
          if location.worn then
            textOut = string.format("%s *", textOut)
          end
          if location.bagLoc == BAG_BACKPACK then
            -- all of the bagLocs are distilled down to single locations (bag_worn or bag_backpack are all bag_backpack for this table element)
            textOut = IIfA.colorHandlerToon:Colorize(textOut)
          elseif location.bagLoc == BAG_BANK then
            textOut = IIfA.colorHandlerBank:Colorize(textOut)
          elseif location.bagLoc == BAG_GUILDBANK then
            textOut = IIfA.colorHandlerGBank:Colorize(textOut)
          elseif location.bagLoc == BAG_HOUSE_BANK_ONE then
            textOut = IIfA.colorHandlerHouseChest:Colorize(textOut)
          elseif location.bagLoc == 99 then
            textOut = IIfA.colorHandlerHouse:Colorize(textOut)
          elseif location.bagLoc == BAG_VIRTUAL then
            textOut = IIfA.colorHandlerCraftBag:Colorize(textOut)
          end
          tooltip:AddLine(textOut, IIfA.TooltipFont)
        end
      end
    end

    local styleIcon = tooltip:GetNamedChild("_StyleIcon")
    local styleLabel = tooltip:GetNamedChild("_StyleLabel")

    -- update the style icon
    styleIcon:SetTexture(itemStyleTexArray.styleTexture)
    styleLabel:SetText(itemStyleTexArray.styleName)

    styleLabel:SetHidden(itemStyleTexArray.styleName == IIfA.EMPTY_STRING)
    styleIcon:SetHidden(itemStyleTexArray.styleName == IIfA.EMPTY_STRING)
    IIfA:AnchorFrame(tooltip, parentTooltip)
  else
    if (not itemLink) or ((#queryResults.locations == 0) and (itemStyleTexArray.styleName == IIfA.EMPTY_STRING)) then
      IIfA_HideTooltip(tooltip)
      return
    end

    local bHasStyle
    bHasStyle = not (itemStyleTexArray.styleName == nil or itemStyleTexArray.styleName == IIfA.EMPTY_STRING)

    -- only add/show the style info if it's got style
    if bHasStyle then
      if tooltip.IIfAPool == nil then
        tooltip.IIfAPool = ZO_ControlPool:New("IIFA_TT_Template", tooltip, "IIFA_TT_Ext")
      end

      if tooltip.IIfAPool then
        tooltip.IIfA_TT_Ext = tooltip.IIfAPool:AcquireObject()
        tooltip.IIfA_TT_Ext:SetWidth(tooltip:GetWidth())
      end

      if tooltip.IIfA_TT_Ext then
        IIfA:Tooltip_AddDivider(tooltip)
        tooltip:AddControl(tooltip.IIfA_TT_Ext)
        tooltip.IIfA_TT_Ext:SetAnchor(TOP)

        local styleIcon = tooltip.IIfA_TT_Ext:GetNamedChild("_StyleIcon")
        local styleLabel = tooltip.IIfA_TT_Ext:GetNamedChild("_StyleLabel")
        -- update the style icon
        styleIcon:SetTexture(itemStyleTexArray.styleTexture)
        styleLabel:SetText(itemStyleTexArray.styleName)
      end
    end

    if (queryResults) then
      if #queryResults.locations > 0 then
        IIfA:Tooltip_AddDivider(tooltip)
        for _, location in pairs(queryResults.locations) do
          local textOut
          if location.name == nil or location.itemsFound == nil then
            textOut = 'Error occurred'
          else
            textOut = zo_strformat("<<1>> x <<2>>", location.name, location.itemsFound)
          end
          if location.worn then
            textOut = string.format("%s *", textOut)
          end
          if location.bagLoc == BAG_BACKPACK then
            -- all of the bagLocs are distilled down to single locations (bag_worn or bag_backpack are all bag_backpack for this table element)
            textOut = IIfA.colorHandlerToon:Colorize(textOut)
          elseif location.bagLoc == BAG_BANK then
            textOut = IIfA.colorHandlerBank:Colorize(textOut)
          elseif location.bagLoc == BAG_GUILDBANK then
            textOut = IIfA.colorHandlerGBank:Colorize(textOut)
          elseif location.bagLoc == BAG_HOUSE_BANK_ONE then
            textOut = IIfA.colorHandlerHouseChest:Colorize(textOut)
          elseif location.bagLoc == 99 then
            textOut = IIfA.colorHandlerHouse:Colorize(textOut)
          elseif location.bagLoc == BAG_VIRTUAL then
            textOut = IIfA.colorHandlerCraftBag:Colorize(textOut)
          end
          tooltip:AddLine(textOut, IIfA.TooltipFont)
        end
      end
    end
  end
end
