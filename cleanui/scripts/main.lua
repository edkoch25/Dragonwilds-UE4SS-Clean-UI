-- Clean UI v1.0.4
-- Lightweight HUD cleanup for RuneScape: Dragonwilds using UE4SS.
-- Settings are loaded once at startup. No Tick, watchdog, or continuous polling.

local cfg = {
    HideGameplayHotbar = true,
    HideInputLegend = true,
    HideRadialButtonPrompts = true,
    HideRadialIndicator = true,
    HideCompass = false,
    ShowHotbarInInventory = true,
    ShowHotbarInStorage = true,
    HideOtherPlayerMarkers = false
}

local inventoryBody = nil
local quickBar = nil
local quickBarFullName = nil
local storageContent = nil
local compassWidget = nil

local initialized = false
local inventoryHookRegistered = false
local closeHookRegistered = false
local storageToggleHookRegistered = false
local storageCloseHookRegistered = false
local opacityHookRegistered = false
local correctingQuickBar = false

local function isValid(obj)
    if obj == nil then return false end
    local ok, result = pcall(function() return obj:IsValid() end)
    return ok and result == true
end

local function collapse(widget)
    if isValid(widget) then pcall(function() widget:SetVisibility(1) end) end
end

local function getFullName(obj)
    if obj == nil then return "" end
    local ok, result = pcall(function() return obj:GetFullName() end)
    if ok and result ~= nil then return tostring(result) end
    return ""
end

local function scriptDirectory()
    local source = debug.getinfo(1, "S").source or ""
    if string.sub(source, 1, 1) == "@" then source = string.sub(source, 2) end
    return source:match("^(.*)[/\\][^/\\]+$") or "."
end

local function modDirectory()
    local dir = scriptDirectory()
    return dir:gsub("[/\\]Scripts$", "")
end

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function parseBool(value)
    value = string.lower(trim(value or ""))
    if value == "true" or value == "1" or value == "yes" or value == "on" then return true end
    if value == "false" or value == "0" or value == "no" or value == "off" then return false end
    return nil
end

local function loadConfig()
    local path = modDirectory() .. "\\config.txt"
    local file = io.open(path, "r")
    if file == nil then return end
    for line in file:lines() do
        local clean = trim(line)
        if clean ~= "" and string.sub(clean, 1, 1) ~= "#" then
            local key, value = clean:match("^([^=]+)=(.+)$")
            if key ~= nil and value ~= nil then
                key = trim(key)
                local parsed = parseBool(value)
                if parsed ~= nil and cfg[key] ~= nil then cfg[key] = parsed end
            end
        end
    end
    file:close()
end

loadConfig()

local function isQuickBarObject(obj)
    if not isValid(obj) or quickBarFullName == nil or quickBarFullName == "" then return false end
    return getFullName(obj) == quickBarFullName
end

local function inventoryIsOpen()
    if not isValid(inventoryBody) then return false end
    local ok, visibility = pcall(function() return inventoryBody:GetVisibility() end)
    return ok and tonumber(visibility) == 0
end

local function acquireStorageContent()
    if isValid(storageContent) then return true end
    local widgets = FindAllOf("WBP_WorldActorInventory_VerticalNavigation_C")
    if widgets == nil then return false end
    for _, candidate in ipairs(widgets) do
        if isValid(candidate) then storageContent = candidate; return true end
    end
    return false
end

local function storageIsOpen()
    if not acquireStorageContent() then return false end
    local ok, visibility = pcall(function() return storageContent:GetVisibility() end)
    return ok and tonumber(visibility) == 0
end

local function desiredQuickBarOpacity()
    if not cfg.HideGameplayHotbar then return nil end
    if cfg.ShowHotbarInInventory and inventoryIsOpen() then return 1.0 end
    if cfg.ShowHotbarInStorage and storageIsOpen() then return 1.0 end
    return 0.0
end

local function updateQuickBar()
    if not cfg.HideGameplayHotbar or not isValid(quickBar) then return end
    local targetOpacity = desiredQuickBarOpacity()
    if targetOpacity == nil then return end
    correctingQuickBar = true
    pcall(function() quickBar:SetRenderOpacity(targetOpacity) end)
    correctingQuickBar = false
end

local function delayedQuickBarUpdate()
    ExecuteWithDelay(50, function() ExecuteInGameThread(updateQuickBar) end)
    ExecuteWithDelay(300, function() ExecuteInGameThread(updateQuickBar) end)
end

local function registerInventoryHook()
    if inventoryHookRegistered then return end
    local ok = pcall(function()
        RegisterHook("/Script/Dominion.InputManagerUIAPI:ToggleWidget",
            function(Context) end,
            function(Context) delayedQuickBarUpdate() end)
    end)
    if ok then inventoryHookRegistered = true end
end

local function registerCloseHook()
    if closeHookRegistered then return end
    local ok = pcall(function()
        RegisterHook("/Script/Dominion.InputManagerUIAPI:CloseWidgetIfOpen",
            function(Context) end,
            function(Context) delayedQuickBarUpdate() end)
    end)
    if ok then closeHookRegistered = true end
end

local function registerStorageHooks()
    if not storageToggleHookRegistered then
        local ok = pcall(function()
            RegisterHook("/Script/Dominion.WorldActorInventoryUIAPI:ToggleInventory",
                function(Context, WorldActorInventory) end,
                function(Context, WorldActorInventory)
                    storageContent = nil
                    delayedQuickBarUpdate()
                end)
        end)
        if ok then storageToggleHookRegistered = true end
    end
    if not storageCloseHookRegistered then
        local ok = pcall(function()
            RegisterHook("/Script/Dominion.WorldActorInventoryUIAPI:CloseCurrentInventory",
                function(Context) end,
                function(Context) delayedQuickBarUpdate() end)
        end)
        if ok then storageCloseHookRegistered = true end
    end
end

local function registerOpacityHook()
    if opacityHookRegistered or not cfg.HideGameplayHotbar then return end
    local ok = pcall(function()
        RegisterHook("/Script/UMG.Widget:SetRenderOpacity",
            function(Context, InOpacity)
                if correctingQuickBar or not initialized or not isValid(quickBar) then return end
                if not isQuickBarObject(Context) then return end
                local targetOpacity = desiredQuickBarOpacity()
                if targetOpacity == nil or targetOpacity == 1.0 then return end
                ExecuteWithDelay(1, function()
                    ExecuteInGameThread(function()
                        local target = desiredQuickBarOpacity()
                        if target == 0.0 and isValid(quickBar) then
                            correctingQuickBar = true
                            pcall(function() quickBar:SetRenderOpacity(0.0) end)
                            correctingQuickBar = false
                        end
                    end)
                end)
            end,
            function(Context, InOpacity) end)
    end)
    if ok then opacityHookRegistered = true end
end

local function acquireCompass()
    if isValid(compassWidget) then return true end
    local widgets = FindAllOf("WBP_HUD_Compass_C")
    if widgets == nil then return false end
    for _, candidate in ipairs(widgets) do
        if isValid(candidate) then compassWidget = candidate; return true end
    end
    return false
end

local function initialize()
    if initialized then return end
    ExecuteInGameThread(function()
        local panels = FindAllOf("WBP_Inventory_MainPanel_C")
        if panels == nil then ExecuteWithDelay(1000, initialize); return end
        local mainPanel, radialPrompt, radialImage = nil, nil, nil
        for _, candidate in ipairs(panels) do
            if isValid(candidate) then
                local okContent, content = pcall(function() return candidate.InventoryContent end)
                if okContent and isValid(content) then
                    local okBar, candidateBar = pcall(function() return content.QuickAccessBar end)
                    local okBody, candidateBody = pcall(function() return content.InventoryBody_Items end)
                    local okPrompt, candidatePrompt = pcall(function() return candidate.QuickAccessRadialPrompt end)
                    local okImage, candidateImage = pcall(function() return candidate.QuickAccessRadialImage end)
                    if okBar and okBody and okPrompt and okImage and isValid(candidateBar)
                        and isValid(candidateBody) and isValid(candidatePrompt) and isValid(candidateImage) then
                        mainPanel, quickBar, inventoryBody = candidate, candidateBar, candidateBody
                        radialPrompt, radialImage = candidatePrompt, candidateImage
                        break
                    end
                end
            end
        end
        if not isValid(mainPanel) then ExecuteWithDelay(1000, initialize); return end

        quickBarFullName = getFullName(quickBar)
        if quickBarFullName == "" then ExecuteWithDelay(1000, initialize); return end

        local radialKBM = nil
        if cfg.HideRadialButtonPrompts then
            local inputIcons = FindAllOf("WBP_DomInputIconWidget_C")
            if inputIcons ~= nil then
                for _, candidate in ipairs(inputIcons) do
                    if isValid(candidate) then
                        local fullName = getFullName(candidate)
                        if string.find(fullName, "/Engine/Transient.", 1, true)
                            and string.find(fullName, "WBP_Inventory_MainPanel_C_", 1, true)
                            and string.find(fullName, ".RadialKBM", 1, true) then
                            radialKBM = candidate
                            break
                        end
                    end
                end
            end
            if not isValid(radialKBM) then ExecuteWithDelay(1000, initialize); return end
        end

        local inputsLegend = nil
        if cfg.HideInputLegend then
            local legends = FindAllOf("WBP_HUD_InputsLegend_C")
            if legends ~= nil then
                for _, candidate in ipairs(legends) do
                    if isValid(candidate) then inputsLegend = candidate; break end
                end
            end
            if not isValid(inputsLegend) then ExecuteWithDelay(1000, initialize); return end
        end

        if cfg.HideCompass and not acquireCompass() then ExecuteWithDelay(1000, initialize); return end

        if cfg.HideRadialButtonPrompts then
            pcall(function() radialPrompt:SetRenderOpacity(0.0) end)
            collapse(radialPrompt)
            collapse(radialKBM)
        end
        if cfg.HideRadialIndicator then collapse(radialImage) end
        if cfg.HideInputLegend then
            pcall(function() inputsLegend:SetRenderOpacity(0.0) end)
            collapse(inputsLegend)
        end
        if cfg.HideCompass and isValid(compassWidget) then
            pcall(function() compassWidget:SetRenderOpacity(0.0) end)
        end

        updateQuickBar()
        initialized = true
        registerOpacityHook()
    end)
end



-- BETA: other-player map/compass marker community test -----------------------
-- OFF by default. Event-driven only. The SDK identifies OtherPlayerCharacter
-- as EMapIconType 2, but the generic UMapIconComponent does not expose that
-- Dominion enum directly. This conservative beta only hides a rendered map
-- icon when live metadata explicitly identifies it as another player, while
-- logging metadata so multiplayer/PvP reports can refine map/compass coverage.
local playerMarkerSeen = {}

local function safeValue(fn, fallback)
    local ok, value = pcall(fn)
    if ok and value ~= nil then return tostring(value) end
    return fallback or ""
end

local function isExplicitOtherPlayerIcon(icon)
    if not isValid(icon) then return false end
    local category = safeValue(function() return icon.IconCategory end, "")
    local owner = safeValue(function()
        local obj = icon:GetOwner()
        return isValid(obj) and obj:GetFullName() or ""
    end, "")
    local combined = string.lower(category .. " " .. owner)
    return string.find(combined, "otherplayercharacter", 1, true) ~= nil
        or string.find(combined, "other_player_character", 1, true) ~= nil
end

local function hideMatchingMapIconWidgets(icon)
    if not cfg.HideOtherPlayerMarkers or not isExplicitOtherPlayerIcon(icon) then return end
    local widgets = FindAllOf("WBP_Dominion_MinimapInternal_Icon_C")
    if widgets == nil then return end
    local iconName = getFullName(icon)
    for _, widget in ipairs(widgets) do
        if isValid(widget) then
            local okComp, comp = pcall(function() return widget.MapIconComp end)
            if okComp and isValid(comp) and getFullName(comp) == iconName then
                pcall(function() widget:SetRenderOpacity(0.0) end)
            end
        end
    end
end

local function inspectPlayerMarker(icon, reason)
    if not cfg.HideOtherPlayerMarkers or not isValid(icon) then return end
    hideMatchingMapIconWidgets(icon)

    local fullName = getFullName(icon)
    if fullName == "" then fullName = safeValue(function() return icon:GetName() end, "<unknown>") end
    if reason == "startup" and playerMarkerSeen[fullName] then return end
    playerMarkerSeen[fullName] = true

    local category = safeValue(function() return icon.IconCategory end, "<unreadable>")
    local label = safeValue(function() return icon:GetIconLabel() end, "")
    local tooltip = safeValue(function() return icon:GetIconTooltipText() end, "")
    local visible = safeValue(function() return icon:IsIconVisible() end, "")
    local texture = safeValue(function()
        local tex = icon:GetIconTexture()
        return isValid(tex) and tex:GetFullName() or "<none>"
    end, "<unreadable>")
    local owner = safeValue(function()
        local obj = icon:GetOwner()
        return isValid(obj) and obj:GetFullName() or "<none>"
    end, "<unreadable>")

    print(string.format(
        "[CleanUI 1.0.4 Beta][MapIcon][%s] Category=%s | Label=%s | Tooltip=%s | Visible=%s | Owner=%s | Texture=%s | Object=%s\n",
        reason, category, label, tooltip, visible, owner, texture, fullName
    ))
end

local function registerPlayerMarkerBeta()
    if not cfg.HideOtherPlayerMarkers then return end

    pcall(function()
        NotifyOnNewObject("/Script/MinimapPlugin.MapIconComponent", function(icon)
            ExecuteInGameThread(function() inspectPlayerMarker(icon, "created") end)
        end)
    end)

    ExecuteWithDelay(7000, function()
        ExecuteInGameThread(function()
            local icons = FindAllOf("MapIconComponent")
            if icons == nil then return end
            for _, icon in ipairs(icons) do inspectPlayerMarker(icon, "startup") end
        end)
    end)
end
-- End beta other-player marker community test --------------------------------

ExecuteWithDelay(1000, function()
    ExecuteInGameThread(function()
        registerInventoryHook()
        registerCloseHook()
        registerStorageHooks()
        registerPlayerMarkerBeta()
    end)
end)

ExecuteWithDelay(5000, initialize)
