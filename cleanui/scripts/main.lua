-- Clean UI v1.0.5
-- Lightweight HUD cleanup for RuneScape: Dragonwilds using UE4SS.
-- Settings are loaded once at startup. No Tick, watchdog, or continuous polling.

local cfg = {
    HideGameplayHotbar = true,
    HideInputLegend = true,
    HideRadialButtonPrompts = true,
    HideRadialIndicator = true,
    HideCompass = false,
    HideOtherPlayerMarkers = false
}

local quickBar = nil
local quickBarFullName = nil
local compassWidget = nil

local initialized = false
local sharedPanelHookRegistered = false
local opacityHookRegistered = false
local correctingQuickBar = false
local panelHotbarVisible = false

local function isValid(obj)
    if obj == nil then return false end
    local ok, result = pcall(function() return obj:IsValid() end)
    return ok and result == true
end

local function collapse(widget)
    if isValid(widget) then
        pcall(function() widget:SetVisibility(1) end)
    end
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
                if parsed ~= nil and cfg[key] ~= nil then
                    cfg[key] = parsed
                end
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

local function setQuickBarOpacity(targetOpacity)
    if not cfg.HideGameplayHotbar or not isValid(quickBar) then return end

    correctingQuickBar = true
    pcall(function() quickBar:SetRenderOpacity(targetOpacity) end)
    correctingQuickBar = false
end

local function registerSharedPanelHook()
    if sharedPanelHookRegistered or not cfg.HideGameplayHotbar then return end

    local ok = pcall(function()
        RegisterHook(
            "/Game/UI/Panels/WBP_Panel_Inventory.WBP_Panel_Inventory_C:SetPanelVisibility",
            function(Context, IsVisible)
                if not initialized then return end

                local okValue, visible = pcall(function()
                    return IsVisible:get()
                end)
                if not okValue then return end

                -- Copy only the primitive state out of the hook callback.
                -- Inventory, storage, crafting and processing-station panels all
                -- use this shared transition.
                panelHotbarVisible = visible == true
                local targetOpacity = panelHotbarVisible and 1.0 or 0.0

                -- Defer the UMG write so it does not run re-entrantly inside
                -- SetPanelVisibility. No hook parameters or temporary UObjects
                -- are retained by this callback.
                ExecuteWithDelay(1, function()
                    ExecuteInGameThread(function()
                        if initialized and cfg.HideGameplayHotbar and isValid(quickBar) then
                            setQuickBarOpacity(targetOpacity)
                        end
                    end)
                end)
            end,
            function(Context, IsVisible) end
        )
    end)

    if ok then sharedPanelHookRegistered = true end
end

local function registerOpacityHook()
    if opacityHookRegistered or not cfg.HideGameplayHotbar then return end
    local ok = pcall(function()
        RegisterHook("/Script/UMG.Widget:SetRenderOpacity",
            function(Context, InOpacity)
                if correctingQuickBar or not initialized or not isValid(quickBar) then return end
                if not isQuickBarObject(Context) then return end
                if panelHotbarVisible then return end

                ExecuteWithDelay(1, function()
                    ExecuteInGameThread(function()
                        if initialized and cfg.HideGameplayHotbar
                            and not panelHotbarVisible and isValid(quickBar) then
                            setQuickBarOpacity(0.0)
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
        if isValid(candidate) then
            compassWidget = candidate
            return true
        end
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

                    if okBar and okBody and okPrompt and okImage
                        and isValid(candidateBar) and isValid(candidateBody)
                        and isValid(candidatePrompt) and isValid(candidateImage) then
                        mainPanel, quickBar = candidate, candidateBar
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
                    if isValid(candidate) then
                        inputsLegend = candidate
                        break
                    end
                end
            end
            if not isValid(inputsLegend) then ExecuteWithDelay(1000, initialize); return end
        end

        if cfg.HideCompass and not acquireCompass() then
            ExecuteWithDelay(1000, initialize)
            return
        end

        if cfg.HideRadialButtonPrompts then
            pcall(function() radialPrompt:SetRenderOpacity(0.0) end)
            collapse(radialPrompt)
            collapse(radialKBM)
        end

        if cfg.HideRadialIndicator then
            collapse(radialImage)
        end

        if cfg.HideInputLegend then
            pcall(function() inputsLegend:SetRenderOpacity(0.0) end)
            collapse(inputsLegend)
        end

        if cfg.HideCompass and isValid(compassWidget) then
            pcall(function() compassWidget:SetRenderOpacity(0.0) end)
        end

        -- Gameplay starts with the hotbar hidden. Shared inventory/station
        -- panel transitions temporarily reveal it while those interfaces are open.
        setQuickBarOpacity(0.0)

        initialized = true
        registerSharedPanelHook()
        registerOpacityHook()
    end)
end

-- 1.0.5 beta other-player marker support -----------------------------------------------------------
-- Event-driven only: logs UMapIconComponent identity when components are
-- created, plus one startup snapshot of components that already exist.
-- Experimental: conservatively hides a map marker only when live metadata
-- explicitly identifies it as OtherPlayerCharacter. It also logs marker
-- metadata so community reports can improve map/compass coverage.
local diagnosticSeen = {}

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

local function logMapIcon(icon, reason)
    if not cfg.HideOtherPlayerMarkers or not isValid(icon) then return end
    hideMatchingMapIconWidgets(icon)

    local fullName = getFullName(icon)
    if fullName == "" then fullName = safeValue(function() return icon:GetName() end, "<unknown>") end

    local key = fullName
    if reason == "startup" and diagnosticSeen[key] then return end
    diagnosticSeen[key] = true

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
        "[CleanUI 1.0.5 Beta][MapIcon][%s] Category=%s | Label=%s | Tooltip=%s | Visible=%s | Owner=%s | Texture=%s | Object=%s\n",
        reason, category, label, tooltip, visible, owner, texture, fullName
    ))
end

local function dumpExistingMapIcons()
    if not cfg.HideOtherPlayerMarkers then return end
    local icons = FindAllOf("MapIconComponent")
    if icons == nil then
        print("[CleanUI 1.0.5 Beta] No existing MapIconComponent objects found during startup snapshot.\n")
        return
    end

    print(string.format("[CleanUI 1.0.5 Beta] Startup MapIconComponent snapshot: %d object(s)\n", #icons))
    for _, icon in ipairs(icons) do
        logMapIcon(icon, "startup")
    end
end

local function registerPlayerMarkerBeta()
    if not cfg.HideOtherPlayerMarkers then return end

    local ok, err = pcall(function()
        NotifyOnNewObject("/Script/MinimapPlugin.MapIconComponent", function(icon)
            ExecuteInGameThread(function()
                logMapIcon(icon, "created")
            end)
        end)
    end)

    if ok then
        print("[CleanUI 1.0.5 Beta] Beta other-player marker watcher registered.\n")
    else
        print("[CleanUI 1.0.5 Beta] Could not register beta other-player marker watcher: " .. tostring(err) .. "\n")
    end

    ExecuteWithDelay(7000, function()
        ExecuteInGameThread(dumpExistingMapIcons)
    end)
end
-- End 1.0.5 beta other-player marker support -------------------------------------------------------

ExecuteWithDelay(1000, function()
    ExecuteInGameThread(function()
        registerPlayerMarkerBeta()
    end)
end)

ExecuteWithDelay(5000, initialize)
