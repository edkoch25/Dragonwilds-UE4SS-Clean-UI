-- Clean UI v1.0.0
-- Lightweight HUD cleanup for RuneScape: Dragonwilds using UE4SS.
-- No Tick hook, watchdog, or continuous polling after initialization.

local inventoryBody = nil
local quickBar = nil

local initialized = false
local inventoryHookRegistered = false
local opacityHookRegistered = false
local correctingQuickBar = false

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

local function inventoryIsOpen()
    if not isValid(inventoryBody) then return false end
    local ok, visibility = pcall(function() return inventoryBody:GetVisibility() end)
    return ok and visibility == 0
end

local function updateQuickBar()
    if not isValid(inventoryBody) or not isValid(quickBar) then return end
    local targetOpacity = inventoryIsOpen() and 1.0 or 0.0

    correctingQuickBar = true
    pcall(function() quickBar:SetRenderOpacity(targetOpacity) end)
    correctingQuickBar = false
end

local function delayedQuickBarUpdate()
    ExecuteWithDelay(50, function()
        ExecuteInGameThread(updateQuickBar)
    end)
    ExecuteWithDelay(300, function()
        ExecuteInGameThread(updateQuickBar)
    end)
end

local function registerInventoryHook()
    if inventoryHookRegistered then return end

    local ok = pcall(function()
        RegisterHook(
            "/Script/Dominion.InputManagerUIAPI:ToggleWidget",
            function(Context) end,
            function(Context) delayedQuickBarUpdate() end
        )
    end)

    if ok then inventoryHookRegistered = true end
end

local function registerOpacityHook()
    if opacityHookRegistered then return end

    local ok = pcall(function()
        RegisterHook(
            "/Script/UMG.Widget:SetRenderOpacity",
            function(Context, InOpacity)
                if correctingQuickBar
                    or not initialized
                    or not isValid(quickBar)
                    or not isValid(inventoryBody) then
                    return
                end

                local widget = Context
                if not isValid(widget) or widget ~= quickBar or inventoryIsOpen() then
                    return
                end

                ExecuteWithDelay(1, function()
                    ExecuteInGameThread(function()
                        if not inventoryIsOpen() and isValid(quickBar) then
                            correctingQuickBar = true
                            pcall(function() quickBar:SetRenderOpacity(0.0) end)
                            correctingQuickBar = false
                        end
                    end)
                end)
            end,
            function(Context, InOpacity) end
        )
    end)

    if ok then opacityHookRegistered = true end
end

local function initialize()
    if initialized then return end

    ExecuteInGameThread(function()
        local panels = FindAllOf("WBP_Inventory_MainPanel_C")
        if panels == nil then
            ExecuteWithDelay(1000, initialize)
            return
        end

        local mainPanel = nil
        local radialPrompt = nil
        local radialImage = nil

        for _, candidate in ipairs(panels) do
            if isValid(candidate) then
                local okContent, content = pcall(function() return candidate.InventoryContent end)

                if okContent and isValid(content) then
                    local okBar, candidateBar = pcall(function() return content.QuickAccessBar end)
                    local okBody, candidateBody = pcall(function() return content.InventoryBody_Items end)
                    local okPrompt, candidatePrompt = pcall(function() return candidate.QuickAccessRadialPrompt end)
                    local okImage, candidateImage = pcall(function() return candidate.QuickAccessRadialImage end)

                    if okBar and okBody and okPrompt and okImage
                        and isValid(candidateBar)
                        and isValid(candidateBody)
                        and isValid(candidatePrompt)
                        and isValid(candidateImage) then
                        mainPanel = candidate
                        quickBar = candidateBar
                        inventoryBody = candidateBody
                        radialPrompt = candidatePrompt
                        radialImage = candidateImage
                        break
                    end
                end
            end
        end

        if not isValid(mainPanel) then
            ExecuteWithDelay(1000, initialize)
            return
        end

        local radialKBM = nil
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

        if not isValid(radialKBM) then
            ExecuteWithDelay(1000, initialize)
            return
        end

        local inputsLegend = nil
        local legends = FindAllOf("WBP_HUD_InputsLegend_C")

        if legends ~= nil then
            for _, candidate in ipairs(legends) do
                if isValid(candidate) then
                    inputsLegend = candidate
                    break
                end
            end
        end

        if not isValid(inputsLegend) then
            ExecuteWithDelay(1000, initialize)
            return
        end

        pcall(function() radialPrompt:SetRenderOpacity(0.0) end)
        collapse(radialPrompt)
        collapse(radialImage)
        collapse(radialKBM)
        collapse(inputsLegend)

        updateQuickBar()
        initialized = true
        registerOpacityHook()
    end)
end

ExecuteWithDelay(1000, function()
    ExecuteInGameThread(registerInventoryHook)
end)

ExecuteWithDelay(5000, initialize)
