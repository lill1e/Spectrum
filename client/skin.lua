SkinMenu = RageUI.CreateMenu("Character", "~d~New Character")
local heritageMenu = RageUI.CreateSubMenu(SkinMenu, "Character", "~d~Heritage")
local featuresMenu = RageUI.CreateSubMenu(SkinMenu, "Character", "~d~Features")
local appearanceMenu = RageUI.CreateSubMenu(SkinMenu, "Character", "~d~Appearance")
local apparelMenu = RageUI.CreateSubMenu(SkinMenu, "Character", "~d~Apparel")

featuresMenu:ToggleMouse()
appearanceMenu:ToggleMouse()

--[
-- Feature ::= { [-1, 1] }
-- Overlay ::= { Number, [0.0, 1.0]?, Colour? }
-- Component ::= { Drawable, Texture }
-- Prop ::= { Drawable, Texture }
--]
function RandomSex()
    return math.random(2)
end

function RandomFeature()
    return (math.random(0, 20) - 10) / 10
end

local nTbl = {}
local noneTbl = {}

function nTable(n, none)
    if nTbl[n] then return (none and noneTbl[n] or nTbl[n]) end
    local t = (none and { "None" } or {})
    for i = 0, n - 1 do
        table.insert(t, i)
    end
    nTbl[n] = t
    return t
end

local hairs = { {}, {} }

for k, v in pairs(Config.Skin.Hair[1]) do
    table.insert(hairs[1], v)
end

for k, v in pairs(Config.Skin.Hair[2]) do
    table.insert(hairs[2], v)
end

local mothers = {}
local fathers = {}
local mothersRev = {}
local fathersRev = {}
local heritageMother = {}
local heritageFather = {}

for k, _ in pairs(Config.Skin.Parents.Mom) do
    table.insert(mothers, k)
end
for k, _ in pairs(Config.Skin.Parents.Dad) do
    table.insert(fathers, k)
end
for i, v in ipairs(mothers) do
    mothersRev[v] = i
end
for i, v in ipairs(fathers) do
    fathersRev[v] = i
end
for i, v in ipairs(Config.Skin.Parents.OrderMom) do
    heritageMother[v] = i
end
for i, v in ipairs(Config.Skin.Parents.OrderDad) do
    heritageFather[v] = i
end

local colCache = {
    hairOne = 1,
    hairTwo = 1,
}

function RandomizeSkin()
    local mom = mothers[math.random(#mothers)]
    local dad = fathers[math.random(#fathers)]
    Spectrum.PlayerData.skin = {
        Sex = Spectrum.PlayerData.skin.Sex,
        Parents = {
            Mother = Config.Skin.Parents.Mom[mom],
            MotherIndex = mothersRev[mom],
            Father = Config.Skin.Parents.Dad[dad],
            FatherIndex = fathersRev[dad],
            MixChar = math.random(0, 10) / 10,
            MixSkin = math.random(0, 10) / 10,
        },
        Features = {
            ["0"] = 0.5,
            ["1"] = 0.5,
            ["2"] = 0.5,
            ["3"] = 0.5,
            ["4"] = 0.5,
            ["5"] = 0.5,
            ["6"] = 0.5,
            ["7"] = 0.5,
            ["8"] = 0.5,
            ["9"] = 0.5,
            ["10"] = 0.5,
            ["11"] = 0.5,
            ["12"] = 0.5,
            ["13"] = 0.5,
            ["14"] = 0.5,
            ["15"] = 0.5,
            ["16"] = 0.5,
            ["17"] = 0.5,
            ["18"] = 0.5
        },
        Overlays = {
            Blemishes = {
                overlay = 0,
                opacity = 0
            },
            FacialHair = {
                overlay = 0,
                colour = { 0, 0 },
                opacity = 0
            },
            Eyebrows = {
                overlay = 0,
                colour = { 0, 0 },
                opacity = 0
            },
            Ageing = {
                overlay = 0,
                opacity = 0
            },
            Makeup = {
                overlay = 0,
                colour = { 0, 0 },
                opacity = 0
            },
            Blush = {
                overlay = 0,
                opacity = 0
            },
            Complexion = {
                overlay = 0,
                opacity = 0
            },
            SunDamage = {
                overlay = 0,
                opacity = 0
            },
            Lipstick = {
                overlay = 0,
                colour = { 0, 0 },
                opacity = 0
            },
            MolesFreckles = {
                overlay = 0,
                opacity = 0
            },
            ChestHair = {
                overlay = 0,
            },
            BodyBlemishes = {
                overlay = 0,
            },
            AddBodyBlemishes = {
                overlay = 0,
            }
        },
        Components = {
            ["2"] = { 1 }
        },
        Props = {},
        EyeColour = 1,
        HairColour = { 0, 0 }
    }
    for k, v in pairs(colCache) do
        if type(colCache[k]) == "table" then
            colCache[k] = { 1, 1 }
        else
            colCache[k] = 1
        end
    end
    for n, component in pairs(Config.Skin.Components) do
        Spectrum.PlayerData.skin.Components[tostring(component)] = {
            GetPedDrawableVariation(PlayerPedId(), component) + 2,
            GetPedTextureVariation(PlayerPedId(), component) + 1
        }
    end
    for _, prop in pairs(Config.Skin.Props) do
        Spectrum.PlayerData.skin.Props[tostring(prop)] = {
            GetPedPropIndex(PlayerPedId(), prop) + 2,
            GetPedPropTextureIndex(PlayerPedId(), prop) + 1
        }
    end
end

function ApplySkin()
    local model = Config.Skin.Models[Spectrum.PlayerData.skin.Sex]
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    SetPedDefaultComponentVariation(PlayerPedId())
    SetPedHeadBlendData(PlayerPedId(), Spectrum.PlayerData.skin.Parents.Mother, Spectrum.PlayerData.skin.Parents.Father,
        0,
        Spectrum.PlayerData.skin.Parents.Mother,
        Spectrum.PlayerData.skin.Parents.Father, 0, Spectrum.PlayerData.skin.Parents.MixChar,
        Spectrum.PlayerData.skin.Parents.MixSkin, 0, false)
    for feature, featureData in pairs(Config.Skin.Features) do
        for i, featureNum in ipairs(featureData.features) do
            SetPedFaceFeature(PlayerPedId(), featureNum,
                (Spectrum.PlayerData.skin.Features[tostring(featureNum)] * 2 - 1) *
                ((i == 1 and featureData.inverseX or featureData.inverseY) and -1 or 1))
        end
    end
    for n, component in pairs(Config.Skin.Components) do
        SetPedComponentVariation(PlayerPedId(), component,
            Spectrum.PlayerData.skin.Components[tostring(component)][1] - 2,
            Spectrum.PlayerData.skin.Components[tostring(component)][2] - 1, 0)
    end
    SetPedComponentVariation(PlayerPedId(), 2,
        Spectrum.PlayerData.skin.Components[tostring(2)]
        [1] - 1, 0, 0)
    for k, prop in pairs(Config.Skin.Props) do
        if Spectrum.PlayerData.skin.Props[tostring(prop)][1] - 2 ~= -1 then
            SetPedPropIndex(PlayerPedId(), prop, Spectrum.PlayerData.skin.Props[tostring(prop)][1] - 2,
                Spectrum.PlayerData.skin.Props[tostring(prop)][2], true)
        end
    end
    for k, v in pairs(Config.Skin.Overlays) do
        SetPedHeadOverlay(PlayerPedId(), v.overlay, Spectrum.PlayerData.skin.Overlays[k].overlay,
            v.opacity and
            ((k ~= "FacialHair" or Spectrum.PlayerData.skin.Sex == 1) and Spectrum.PlayerData.skin.Overlays[k].opacity or 0) or
            1)
        if k == "Blush" then
            SetPedHeadOverlayColor(PlayerPedId(), v.overlay, 2, 0, 0)
        end
        if v.colour then
            SetPedHeadOverlayColor(PlayerPedId(), v.overlay, 1, Spectrum.PlayerData.skin.Overlays[k].colour[1],
                Spectrum.PlayerData.skin.Overlays[k].colour[2])
        end
    end
    SetPedHairTint(PlayerPedId(), Spectrum.PlayerData.skin.HairColour[1], Spectrum.PlayerData.skin.HairColour[2])
    SetPedEyeColor(PlayerPedId(), Spectrum.PlayerData.skin.EyeColour)
end

function TableEmpty(tbl)
    for _, _ in pairs(tbl) do
        return false
    end
    return true
end

function GetFeatureValue(value, inverseHuh)
    return (value * 2 - 1) * (inverseHuh and -1 or 1)
end

function RageUI.PoolMenus:Skin()
    SkinMenu:IsVisible(function(Items)
        Items:AddList("Sex", { "Male", "Female" }, Spectrum.PlayerData.skin.Sex, "", {},
            function(Index, onSelected, onListChange)
                if onListChange then
                    Spectrum.PlayerData.skin.Sex = Index
                    RandomizeSkin()
                    ApplySkin()
                end
            end)
        Items:AddButton("Heritage", "", { RightLabel = "→→→" }, function(onSelected) end, heritageMenu)
        Items:AddButton("Features", "", { RightLabel = "→→→" }, function(onSelected) end, featuresMenu)
        Items:AddButton("Appearance", "", { RightLabel = "→→→" }, function(onSelected) end, appearanceMenu)
        Items:AddButton("Apparel", "", { RightLabel = "→→→" }, function(onSelected) end, apparelMenu)
        Items:AddButton("~b~Save & Continue", nil, {}, function(onSelected)
            if onSelected then
                print(json.encode(Spectrum.PlayerData.skin.Components[tostring(2)]))
                TriggerServerEvent("Spectrum:Skin", Spectrum.PlayerData.skin)
                Spectrum.skin.IsEditing = false
            end
        end)
    end, function(Panels)
    end)

    heritageMenu:IsVisible(function(Items)
        Items:Heritage(heritageMother[mothers[Spectrum.PlayerData.skin.Parents.MotherIndex]] - 1, heritageFather
            [fathers[Spectrum.PlayerData.skin.Parents.FatherIndex]] - 1)
        Items:AddList("Mom", mothers, Spectrum.PlayerData.skin.Parents.MotherIndex, "Select your Mom", {},
            function(Index, onSelected, onListChange)
                if onListChange then
                    Spectrum.PlayerData.skin.Parents.MotherIndex = Index
                    Spectrum.PlayerData.skin.Parents.Mother = Config.Skin.Parents.Mom
                        [mothers[Spectrum.PlayerData.skin.Parents.MotherIndex]]
                    SetPedHeadBlendData(PlayerPedId(), Spectrum.PlayerData.skin.Parents.Mother,
                        Spectrum.PlayerData.skin.Parents.Father, 0,
                        Spectrum.PlayerData.skin.Parents.Mother,
                        Spectrum.PlayerData.skin.Parents.Father, 0, Spectrum.PlayerData.skin.Parents.MixChar,
                        Spectrum.PlayerData.skin.Parents.MixSkin, 0,
                        false)
                end
            end)
        Items:AddList("Dad", fathers, Spectrum.PlayerData.skin.Parents.FatherIndex, "Select your Dad", {},
            function(Index, onSelected, onListChange)
                if onListChange then
                    Spectrum.PlayerData.skin.Parents.FatherIndex = Index
                    Spectrum.PlayerData.skin.Parents.Father = Config.Skin.Parents.Dad
                        [fathers[Spectrum.PlayerData.skin.Parents.FatherIndex]]
                    SetPedHeadBlendData(PlayerPedId(), Spectrum.PlayerData.skin.Parents.Mother,
                        Spectrum.PlayerData.skin.Parents.Father, 0,
                        Spectrum.PlayerData.skin.Parents.Mother,
                        Spectrum.PlayerData.skin.Parents.Father, 0, Spectrum.PlayerData.skin.Parents.MixChar,
                        Spectrum.PlayerData.skin.Parents.MixSkin, 0,
                        false)
                end
            end)
        Items:HeritageSlider("Resemblance", Spectrum.PlayerData.skin.Parents.MixChar * 10,
            "Select if your features are influenced more by your Mother or Father",
            function(Index, onSelected, onListChange)
                if onListChange then
                    Spectrum.PlayerData.skin.Parents.MixChar = Index / 10
                    SetPedHeadBlendData(PlayerPedId(), Spectrum.PlayerData.skin.Parents.Mother,
                        Spectrum.PlayerData.skin.Parents.Father, 0,
                        Spectrum.PlayerData.skin.Parents.Mother,
                        Spectrum.PlayerData.skin.Parents.Father, 0, Spectrum.PlayerData.skin.Parents.MixChar,
                        Spectrum.PlayerData.skin.Parents.MixSkin, 0,
                        false)
                end
            end)
        Items:HeritageSlider("Skin Tone", Spectrum.PlayerData.skin.Parents.MixSkin * 10,
            "Select if your skin tone is influenced more by your Mother or Father",
            function(Index, onSelected, onListChange)
                if onListChange then
                    Spectrum.PlayerData.skin.Parents.MixSkin = Index / 10
                    SetPedHeadBlendData(PlayerPedId(), Spectrum.PlayerData.skin.Parents.Mother,
                        Spectrum.PlayerData.skin.Parents.Father, 0,
                        Spectrum.PlayerData.skin.Parents.Mother,
                        Spectrum.PlayerData.skin.Parents.Father, 0, Spectrum.PlayerData.skin.Parents.MixChar,
                        Spectrum.PlayerData.skin.Parents.MixSkin, 0,
                        false)
                end
            end)
    end, function(Panels)
    end)

    featuresMenu:IsVisible(function(Items)
        for _, v in ipairs(Config.Skin.Menu.Features) do
            Items:AddButton(v.displayName, "Make changes to your Features", {}, function(_)

            end)
        end
    end, function(Panels)
        for i, v in ipairs(Config.Skin.Menu.Features) do
            local data = Config.Skin[v.type][v.name]
            if data.gridType == 0 then
                Panels:GridHorizontal(Spectrum.PlayerData.skin[v.type][tostring(data.features[1])],
                    Config.Skin[v.type][v.name].gridLabels[1],
                    Config.Skin[v.type][v.name].gridLabels[2], function(X, _, _, _)
                        Spectrum.PlayerData.skin.Features[tostring(data.features[1])] = X
                        SetPedFaceFeature(PlayerPedId(), data.features[1],
                            (Spectrum.PlayerData.skin.Features[tostring(data.features[1])] * 2 - 1) *
                            (data.inverseX and -1 or 1))
                    end, i)
            elseif data.gridType == 1 then
                Panels:Grid(Spectrum.PlayerData.skin[v.type][tostring(data.features[1])],
                    Spectrum.PlayerData.skin[v.type][tostring(data.features[2])],
                    Config.Skin[v.type][v.name].gridLabels[3], Config.Skin[v.type][v.name].gridLabels[4],
                    Config.Skin[v.type][v.name].gridLabels[1], Config.Skin[v.type][v.name].gridLabels[2],
                    function(X, Y, _, _)
                        Spectrum.PlayerData.skin.Features[tostring(data.features[1])] = X
                        Spectrum.PlayerData.skin.Features[tostring(data.features[2])] = Y
                        SetPedFaceFeature(PlayerPedId(), data.features[1],
                            (Spectrum.PlayerData.skin.Features[tostring(data.features[1])] * 2 - 1) *
                            (data.inverseX and -1 or 1))
                        SetPedFaceFeature(PlayerPedId(), data.features[2],
                            (Spectrum.PlayerData.skin.Features[tostring(data.features[2])] * 2 - 1) *
                            (data.inverseY and -1 or 1))
                    end, i)
            end
        end
    end)

    appearanceMenu:IsVisible(function(Items)
        for i, v in ipairs(Config.Skin.Menu.Appearance) do
            if v.type == "Component" then
                Items:AddList("Hair", Config.Skin.Hair[Spectrum.PlayerData.skin.Sex],
                    GetPedDrawableVariation(PlayerPedId(), v.name) + 1, nil, {},
                    function(Index, onSelected, onListChange)
                        if onListChange then
                            Spectrum.PlayerData.skin.Components[tostring(v.name)] = { Index }
                            SetPedComponentVariation(PlayerPedId(), v.name, Index - 1, 0, 0)
                        end
                    end)
            elseif v.type == "Overlays" then
                if v.name ~= "FacialHair" or Spectrum.PlayerData.skin.Sex == 1 then
                    Items:AddList(v.displayName,
                        nTable(GetPedHeadOverlayNum(Config.Skin.Overlays[v.name].overlay), false),
                        Spectrum.PlayerData.skin.Overlays[v.name].overlay + 1,
                        "Total: " .. GetPedHeadOverlayNum(Config.Skin.Overlays[v.name].overlay), {},
                        function(Index, onSelected, onListChange)
                            if onListChange then
                                Spectrum.PlayerData.skin.Overlays[v.name].overlay = Index - 1
                                SetPedHeadOverlay(PlayerPedId(), Config.Skin.Overlays[v.name].overlay,
                                    Spectrum.PlayerData.skin.Overlays[v.name].overlay,
                                    Spectrum.PlayerData.skin.Overlays[v.name].opacity)
                                if v.name == "Blush" then
                                    SetPedHeadOverlayColor(PlayerPedId(), Config.Skin.Overlays[v.name].overlay, 2, 0, 0)
                                end
                            end
                        end)
                else
                    Items:AddButton(v.displayName, "Make changes to your Appearance", { IsDisabled = true },
                        function(onSelected, onActive)

                        end)
                end
            elseif v.type == "EyeColour" then
                Items:AddList("Eye Color", Config.Skin.EyeColours, GetPedEyeColor(PlayerPedId()),
                    "Make changes to your Appearance", {}, function(Index, onSelected, onListChange)
                        if onListChange then
                            Spectrum.PlayerData.skin.EyeColour = Index
                            SetPedEyeColor(PlayerPedId(), Spectrum.PlayerData.skin.EyeColour)
                        end
                    end)
            end
        end
    end, function(Panels)
        for i, v in ipairs(Config.Skin.Menu.Appearance) do
            if v.type == "Component" then
                Panels:ColourPanel("Hair Color", RageUI.PanelColour.HairCut, colCache.hairOne,
                    GetPedHairColor(PlayerPedId()) + 1, function(Hovered, Selected, MinimumIndex, CurrentIndex)
                        if Selected then
                            colCache.hairOne = MinimumIndex
                            Spectrum.PlayerData.skin.HairColour[1] = CurrentIndex - 1
                            SetPedHairTint(PlayerPedId(), CurrentIndex - 1, Spectrum.PlayerData.skin.HairColour[2])
                        end
                    end, i)
                Panels:ColourPanel("Hair Color (Highlight)", RageUI.PanelColour.HairCut, colCache.hairTwo,
                    GetPedHairHighlightColor(PlayerPedId()) + 1,
                    function(Hovered, Selected, MinimumIndex, CurrentIndex)
                        if Selected then
                            colCache.hairTwo = MinimumIndex
                            Spectrum.PlayerData.skin.HairColour[2] = CurrentIndex - 1
                            SetPedHairTint(PlayerPedId(), Spectrum.PlayerData.skin.HairColour[1], CurrentIndex - 1)
                        end
                    end, i)
            elseif v.type == "Overlays" and (v.name ~= "FacialHair" or Spectrum.PlayerData.skin.Sex == 1) then
                if Config.Skin.Overlays[v.name].opacity then
                    Panels:PercentagePanel(Spectrum.PlayerData.skin.Overlays[v.name].opacity, nil, nil, nil,
                        function(Hovered, Selected, Percent)
                            if Selected then
                                Spectrum.PlayerData.skin.Overlays[v.name].opacity = Percent
                                SetPedHeadOverlay(PlayerPedId(), Config.Skin.Overlays[v.name].overlay,
                                    Spectrum.PlayerData.skin.Overlays[v.name].overlay,
                                    Spectrum.PlayerData.skin.Overlays[v.name].opacity)
                                if v.name == "Blush" then
                                    SetPedHeadOverlayColor(PlayerPedId(), Config.Skin.Overlays[v.name].overlay, 2, 0, 0)
                                end
                            end
                        end, i)
                end
                if Config.Skin.Overlays[v.name].colour then
                    if not colCache[i] then
                        colCache[i] = { 1, 1 }
                    end
                    Panels:ColourPanel(v.displayName .. " Color", RageUI.PanelColour.HairCut, colCache[i][1],
                        Spectrum.PlayerData.skin.Overlays[v.name].colour[1] + 1,
                        function(Hovered, Selected, MinimumIndex, CurrentIndex)
                            if Selected then
                                colCache[i][1] = MinimumIndex
                                Spectrum.PlayerData.skin.Overlays[v.name].colour[1] = CurrentIndex - 1
                                SetPedHeadOverlayColor(PlayerPedId(), Config.Skin.Overlays[v.name].overlay, 1,
                                    Spectrum.PlayerData.skin.Overlays[v.name].colour[1],
                                    Spectrum.PlayerData.skin.Overlays[v.name].colour
                                    [2])
                            end
                        end, i)
                    -- Panels:ColourPanel(v.displayName .. " Color (Highlight)", RageUI.PanelColour.HairCut, colCache[i][2],
                    --     Spectrum.PlayerData.skin.Overlays[v.name].colour[2] + 1, function(Hovered, Selected, MinimumIndex, CurrentIndex)
                    --         if Selected then
                    --             colCache[i][2] = MinimumIndex
                    --             Spectrum.PlayerData.skin.Overlays[v.name].colour[2] = CurrentIndex - 1
                    --             SetPedHeadOverlayColor(PlayerPedId(), Config.Skin.Overlays[v.name].overlay, 1,
                    --                 Spectrum.PlayerData.skin.Overlays[v.name].colour[1], state.Overlays[v.name].colour[2])
                    --         end
                    --     end, i)
                end
            end
        end
    end)

    apparelMenu:IsVisible(function(Items)
        for _, value in ipairs(Config.Skin.Menu.Apparel) do
            if value.type == "Component" then
                Items:AddList(value.displayName,
                    nTable(GetNumberOfPedDrawableVariations(PlayerPedId(), value.name), true),
                    GetPedDrawableVariation(PlayerPedId(), value.name) + 2,
                    "Total: " .. GetNumberOfPedDrawableVariations(PlayerPedId(), value.name), {},
                    function(Index, onSelected, onListChange)
                        if onListChange then
                            Spectrum.PlayerData.skin.Components[tostring(value.name)] = { Index, 1 }
                            SetPedComponentVariation(PlayerPedId(), value.name, Index - 2, 0, 0)
                        end
                    end)
                if GetNumberOfPedTextureVariations(PlayerPedId(), value.name, GetPedDrawableVariation(PlayerPedId(), value.name)) > 1 then
                    Items:AddList(value.displayName .. " (Style)",
                        nTable(
                            GetNumberOfPedTextureVariations(PlayerPedId(), value.name,
                                GetPedDrawableVariation(PlayerPedId(), value.name)), false),
                        GetPedTextureVariation(PlayerPedId(), value.name) + 1,
                        "Total: " ..
                        GetNumberOfPedTextureVariations(PlayerPedId(), value.name,
                            GetPedDrawableVariation(PlayerPedId(), value.name)), {},
                        function(Index, onSelected, onListChange)
                            if onListChange then
                                Spectrum.PlayerData.skin.Components[tostring(value.name)] = { Spectrum.PlayerData.skin
                                    .Components
                                    [tostring(value.name)][1],
                                    Index }
                                SetPedComponentVariation(PlayerPedId(), value.name,
                                    GetPedDrawableVariation(PlayerPedId(), value.name), Index - 1, 0)
                            end
                        end)
                end
            else
                Items:AddList(value.displayName,
                    nTable(GetNumberOfPedPropDrawableVariations(PlayerPedId(), value.name), true),
                    GetPedPropIndex(PlayerPedId(), value.name) + 2,
                    "Total: " .. GetNumberOfPedPropDrawableVariations(PlayerPedId(), value.name), {},
                    function(Index, onSelected, onListChange)
                        if onListChange then
                            if Index == 1 then
                                Spectrum.PlayerData.skin.Props[tostring(value.name)] = { -1, 0 }
                                ClearPedProp(PlayerPedId(), value.name)
                            else
                                Spectrum.PlayerData.skin.Props[tostring(value.name)] = { Index, 0 }
                                SetPedPropIndex(PlayerPedId(), value.name, Index - 2, 0, true)
                            end
                        end
                    end)
                if GetNumberOfPedPropTextureVariations(PlayerPedId(), value.name, GetPedPropIndex(PlayerPedId(), value.name)) > 1 then
                    Items:AddList(value.displayName .. " (Style)",
                        nTable(
                            GetNumberOfPedPropTextureVariations(PlayerPedId(), value.name,
                                GetPedPropIndex(PlayerPedId(), value.name)), false),
                        GetPedPropTextureIndex(PlayerPedId(), value.name) + 1,
                        "Total: " ..
                        GetNumberOfPedPropTextureVariations(PlayerPedId(), value.name,
                            GetPedPropIndex(PlayerPedId(), value.name)), {},
                        function(Index, onSelected, onListChange)
                            if onListChange then
                                Spectrum.PlayerData.skin.Props[tostring(value.name)] = { Spectrum.PlayerData.skin.Props
                                    [tostring(value.name)][1], Index }
                                SetPedPropIndex(PlayerPedId(), value.name, GetPedPropIndex(PlayerPedId(), value.name),
                                    Index - 1, true)
                            end
                        end)
                end
            end
        end
    end, function(Panels)

    end)
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local anyVisible = (RageUI.Visible(SkinMenu) or RageUI.Visible(heritageMenu) or RageUI.Visible(apparelMenu) or RageUI.Visible(appearanceMenu) or RageUI.Visible(featuresMenu))
        if Spectrum.Spawned and Spectrum.skin.IsEditing and not anyVisible then
            RageUI.Visible(SkinMenu, true)
        elseif Spectrum.Spawned and not Spectrum.skin.IsEditing and anyVisible then
            if RageUI.Visible(SkinMenu) then
                RageUI.Visible(SkinMenu, false)
            elseif RageUI.Visible(heritageMenu) then
                RageUI.Visible(heritageMenu, false)
            elseif RageUI.Visible(apparelMenu) then
                RageUI.Visible(apparelMenu, false)
            elseif RageUI.Visible(appearanceMenu) then
                RageUI.Visible(appearanceMenu, false)
            elseif RageUI.Visible(featuresMenu) then
                RageUI.Visible(featuresMenu, false)
            end
        end
    end
end)

RegisterKeyMapping("+skin", "Skin Menu", "keyboard", "f7")
RegisterCommand("+skin", function()
    if Spectrum.Loaded and (Spectrum.PlayerData.staff > 0 or Spectrum.debug or Spectrum.skin.IsEditing) then
        RageUI.Visible(SkinMenu, not RageUI.Visible(SkinMenu))
    end
end, false)
RegisterCommand("-skin", function() end, false)

RegisterCommand("c", function()
    print(json.encode(Spectrum.PlayerData.skin))
end, false)
