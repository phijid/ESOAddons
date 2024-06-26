--[[textureData = {
    type = "texture",
    image = "file/path.dds",
    imageWidth = 64, -- max of 250 for half width, 510 for full
    imageHeight = 32, -- max of 100
    tooltip = "Image's tooltip text.", -- or string id or function returning a string (optional)
    width = "full", -- or "half" (optional)
    reference = "MyAddonTexture" -- unique global reference to control (optional)
} ]]

-- TODO: add texture coords support?

local widgetVersion = 11
local LAM = LibAddonMenu2
if not LAM:RegisterWidget("texture", widgetVersion) then return end

local wm = WINDOW_MANAGER

local MIN_HEIGHT = 26
function LAMCreateControl.texture(parent, textureData, controlName)
    local control = LAM.util.CreateBaseControl(parent, textureData, controlName)
    local width = control:GetWidth()
    control:SetResizeToFitDescendents(true)

    if control.isHalfWidth then --note these restrictions
        control:SetDimensionConstraints(width / 2, MIN_HEIGHT, width / 2, MIN_HEIGHT * 4)
        control:SetResizeToFitConstrains(ANCHOR_CONSTRAINS_Y)
    else
        control:SetDimensionConstraints(width, MIN_HEIGHT, width, MIN_HEIGHT * 4)
        control:SetResizeToFitConstrains(ANCHOR_CONSTRAINS_Y)
    end

    control.texture = wm:CreateControl(nil, control, CT_TEXTURE)
    local texture = control.texture
    texture:SetAnchor(CENTER)
    texture:SetDimensions(textureData.imageWidth, textureData.imageHeight)
    texture:SetTexture(textureData.image)
    LAM.util.SetUpTooltip(texture, textureData)

    return control
end
