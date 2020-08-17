
local addonName, addon = ...

GM2_DbBrowser = {}
GM2_DbBrowser.__index = GM2_DbBrowser

-- use this to check gathermate2 is loaded and usable
local GatherMate = false

-- set up addon
function GM2_DbBrowser:Initialize()
    -- create tables for gm2 db data
    self.DataSet = {}
    self.DataSet_Filtered = {}
    -- create ui table
    self.Window = {}
    -- create ui
    self.Window.Frame = CreateFrame('FRAME', 'GatherMate2DatabaseViewer', UIParent, "UIPanelDialogTemplate")
    self.Window.Frame:SetSize(800, 570)
    self.Window.Frame:SetPoint('CENTER', 0, 0)
    self.Window.Frame:SetScript('OnShow', function(self)
        if next(GM2_DbBrowser.DataSet) then
            GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
        else
            GM2_DbBrowser:ClearListView()
        end
    end)
    self.Window.Title = self.Window.Frame:CreateFontString('$parentTitle', 'OVERLAY', 'GameFontNormal')
    self.Window.Title:SetPoint('TOP', 0, -9)
    self.Window.Title:SetText('GatherMate2 Database Viewer')


    -- drop down menu to select gm2 db
    self.Window.DatabaseSelectionDropDown = CreateFrame('FRAME', 'GatherMate2DatabaseViewerDatabaseSelectionDropDown', self.Window.Frame, "UIDropDownMenuTemplate")
    self.Window.DatabaseSelectionDropDown:SetPoint('TOPRIGHT', -16, -48)
    UIDropDownMenu_SetWidth(self.Window.DatabaseSelectionDropDown, 125)
    UIDropDownMenu_SetText(self.Window.DatabaseSelectionDropDown, 'Select database')
    UIDropDownMenu_Initialize(self.Window.DatabaseSelectionDropDown, function()
        local info = UIDropDownMenu_CreateInfo()
        for name, db in pairs(GatherMate.gmdbs) do
            info.text = name
            info.isTitle = false
            info.notCheckable = true
            info.func = function(self)
                GM2_DbBrowser:ClearListView()
                GM2_DbBrowser:LoadDatabase(db, name)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
                UIDropDownMenu_SetText(GM2_DbBrowser.Window.DatabaseSelectionDropDown, name)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    -- map zone sort button asc/desc
    self.Window.MapZoneButton = CreateFrame('BUTTON', 'GatherMate2DatabaseViewerDatabaseMapZoneButton', self.Window.Frame, "UIPanelButtonTemplate")
    self.Window.MapZoneButton:SetPoint('TOPLEFT', self.Window.Frame, 'TOPLEFT', 10, -115)
    self.Window.MapZoneButton:SetSize(250, 22)
    self.Window.MapZoneButton:SetText('Map Zone')
    self.Window.MapZoneButton.sort = 0
    self.Window.MapZoneButton:SetScript('OnClick', function(self)
        if self.sort == 0 then
            if not next(GM2_DbBrowser.DataSet_Filtered) then
                table.sort(GM2_DbBrowser.DataSet, function(a, b)
                    if a.MapZone == b.MapZone then
                        return a.Source < b.Source
                    else
                        return a.MapZone > b.MapZone
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
            else
                table.sort(GM2_DbBrowser.DataSet_Filtered, function(a, b)
                    if a.MapZone == b.MapZone then
                        return a.Source < b.Source
                    else
                        return a.MapZone > b.MapZone
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet_Filtered)
            end
            self.sort = 1
        else
            if not next(GM2_DbBrowser.DataSet_Filtered) then
                table.sort(GM2_DbBrowser.DataSet, function(a, b)
                    if a.MapZone == b.MapZone then
                        return a.Source < b.Source
                    else
                        return a.MapZone < b.MapZone
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
            else
                table.sort(GM2_DbBrowser.DataSet_Filtered, function(a, b)
                    if a.MapZone == b.MapZone then
                        return a.Source < b.Source
                    else
                        return a.MapZone < b.MapZone
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet_Filtered)
            end
            self.sort = 0
        end
    end)
    -- source button asc/desc
    self.Window.SourceButton = CreateFrame('BUTTON', 'GatherMate2DatabaseViewerDatabaseSourceButton', self.Window.Frame, "UIPanelButtonTemplate")
    self.Window.SourceButton:SetPoint('LEFT', self.Window.MapZoneButton, 'RIGHT', 0, 0)
    self.Window.SourceButton:SetSize(250, 22)
    self.Window.SourceButton:SetText('Source')
    self.Window.SourceButton.sort = 0
    self.Window.SourceButton:SetScript('OnClick', function(self)
        if self.sort == 0 then
            if not next(GM2_DbBrowser.DataSet_Filtered) then
                table.sort(GM2_DbBrowser.DataSet, function(a, b)
                    if a.Source == b.Source then
                        return a.MapZone < b.MapZone
                    else
                        return a.Source > b.Source
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
            else
                table.sort(GM2_DbBrowser.DataSet_Filtered, function(a, b)
                    if a.Source == b.Source then
                        return a.MapZone < b.MapZone
                    else
                        return a.Source > b.Source
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet_Filtered)
            end
            self.sort = 1
        else
            if not next(GM2_DbBrowser.DataSet_Filtered) then
                table.sort(GM2_DbBrowser.DataSet, function(a, b)
                    if a.Source == b.Source then
                        return a.MapZone < b.MapZone
                    else
                        return a.Source < b.Source
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
            else
                table.sort(GM2_DbBrowser.DataSet_Filtered, function(a, b)
                    if a.Source == b.Source then
                        return a.MapZone < b.MapZone
                    else
                        return a.Source < b.Source
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet_Filtered)
            end
            self.sort = 0
        end
    end)
    -- location button asc/desc ? might remove feature
    self.Window.LocationButton = CreateFrame('BUTTON', 'GatherMate2DatabaseViewerDatabaseLocationButton', self.Window.Frame, "UIPanelButtonTemplate")
    self.Window.LocationButton:SetPoint('LEFT', self.Window.SourceButton, 'RIGHT', 0, 0)
    self.Window.LocationButton:SetSize(150, 22)
    self.Window.LocationButton:SetText('Location')
    self.Window.LocationButton.sort = 0
    self.Window.LocationButton:SetScript('OnClick', function(self)
        if self.sort == 0 then
            if not next(GM2_DbBrowser.DataSet_Filtered) then
                table.sort(GM2_DbBrowser.DataSet, function(a, b)
                    if a.PosY == b.PosY then
                        return a.PosX < b.PosX
                    else
                        return (a.PosY > b.PosY) -- and (a.PosX > b.PosX)
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
            else
                table.sort(GM2_DbBrowser.DataSet_Filtered, function(a, b)
                    if a.PosY == b.PosY then
                        return a.PosX < b.PosX
                    else
                        return (a.PosY > b.PosY) -- and (a.PosX > b.PosX)
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet_Filtered)
            end
            self.sort = 1
        else
            if not next(GM2_DbBrowser.DataSet_Filtered) then
                table.sort(GM2_DbBrowser.DataSet, function(a, b)
                    if a.PosY == b.PosY then
                        return a.PosX < b.PosX
                    else
                        return (a.PosY < b.PosY) -- and (a.PosX < b.PosX)
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
            else
                table.sort(GM2_DbBrowser.DataSet_Filtered, function(a, b)
                    if a.PosY == b.PosY then
                        return a.PosX < b.PosX
                    else
                        return (a.PosY < b.PosY) -- and (a.PosX < b.PosX)
                    end
                end)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet_Filtered)
            end
            self.sort = 0
        end
    end)
    -- listview table
    self.Window.ListView = {
        NumRows = 20.0,
        RowHeight = 21.0,
        RowOffsetY = 19.0,
        Rows = {},
    }
    -- create listview frame/area
    self.Window.ListView.Frame = CreateFrame('FRAME', 'GatherMate2DatabaseViewerListView', self.Window.Frame)
    self.Window.ListView.Frame:SetPoint('TOPLEFT', self.Window.Frame, 'TOPLEFT', 12, -138)
    self.Window.ListView.Frame:SetPoint('BOTTOMRIGHT', self.Window.Frame, 'BOTTOMRIGHT', -8, 12)
    self.Window.ListView.Frame:EnableMouse(true)
    -- listview scroll bar, needs artwork?
    self.Window.ListView.ScrollBar = CreateFrame('SLIDER', 'GatherMate2DatabaseViewerListViewScrollBar', self.Window.ListView.Frame, "UIPanelScrollBarTemplate")
    self.Window.ListView.ScrollBar:SetPoint('TOPLEFT', self.Window.ListView.Frame, 'TOPRIGHT', -16, -16)
    self.Window.ListView.ScrollBar:SetPoint('BOTTOMRIGHT', self.Window.ListView.Frame, 'BOTTOMRIGHT', 0, 16)
    self.Window.ListView.ScrollBar:EnableMouse(true)
    self.Window.ListView.ScrollBar:SetScript('OnShow', function(self)
        if next(GM2_DbBrowser.DataSet) then
            local len = #GM2_DbBrowser.DataSet
            self:SetMinMaxValues(1, (len - GM2_DbBrowser.Window.ListView.NumRows - 1))
        else
            self:SetMinMaxValues(1, GM2_DbBrowser.Window.ListView.NumRows)
        end
        self:SetValueStep(1)
        self:SetValue(1)
        self.scrollStep = 1
    end)
    self.Window.ListView.ScrollBar:SetScript('OnValueChanged', function(self)
        if not next(GM2_DbBrowser.DataSet_Filtered) then
            GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
        else
            GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet_Filtered)
        end
    end)
    -- no clue why but this works for getting values set, OnLoad didnt seem to fire and OnShow required hiding and re-showing ?
    self.Window.ListView.ScrollBar:Hide()
    self.Window.ListView.ScrollBar:Show()
    -- set up mouse scroll script
    self.Window.ListView.Frame:SetScript('OnMouseWheel', function(self, delta)
        local x = GM2_DbBrowser.Window.ListView.ScrollBar:GetValue()
        GM2_DbBrowser.Window.ListView.ScrollBar:SetValue(x - delta)
    end)
    -- draw listview rows
    for i = 1, self.Window.ListView.NumRows do
        local row = CreateFrame('FRAME', tostring('GatherMate2DatabaseViewerListViewRow'..i), self.Window.ListView.Frame)
        row:SetPoint('TOPLEFT', self.Window.ListView.Frame, 'TOPLEFT', 0, ((i - 1) * self.Window.ListView.RowHeight) * -1)
        row:SetPoint('BOTTOMRIGHT', self.Window.ListView.Frame, 'TOPRIGHT', -16, (((i - 1) * self.Window.ListView.RowHeight) + self.Window.ListView.RowOffsetY) * -1)
        row.Background = row:CreateTexture('$parentBackgorund', 'BACKGROUND')
        row.Background:SetAllPoints(row)
        if i % 2 == 0 then
            row.Background:SetColorTexture(0.2,0.2,0.2,0.1)
        else
            row.Background:SetColorTexture(0.2,0.2,0.2,0.3)
        end

        row.MapZoneText = row:CreateFontString('$parentMapZoneText', 'OVERLAY', 'GameFontNormal')
        row.MapZoneText:SetPoint('LEFT', 2, 0)

        row.SourceIcon = row:CreateTexture('$parentSourceIcon', 'ARTWORK')
        row.SourceIcon:SetPoint('LEFT', 251, 0)
        row.SourceIcon:SetSize(18, 18)

        row.SourceText = row:CreateFontString('$parentSourceText', 'OVERLAY', 'GameFontNormal')
        row.SourceText:SetPoint('LEFT', 276, 0)

        row.LocationText = row:CreateFontString('$parentLocationText', 'OVERLAY', 'GameFontNormal')
        row.LocationText:SetPoint('LEFT', 502, 0)

        --row.

        row:SetScript('OnEnter', function(self)
            row.Background:SetColorTexture(0.4,0.73,1.0,0.3)
            for k, fontString in pairs({ self.MapZoneText, self.SourceText, self.LocationText }) do
                fontString:SetTextColor(1,1,1,1)
            end
        end)
        row:SetScript('OnLeave', function(self)
            if i % 2 == 0 then
                row.Background:SetColorTexture(0.2,0.2,0.2,0.1)
            else
                row.Background:SetColorTexture(0.2,0.2,0.2,0.3)
            end
            for k, fontString in pairs({ self.MapZoneText, self.SourceText, self.LocationText }) do
                fontString:SetTextColor(1.0, 0.82, 0.0, 1.0)
            end
        end)


        self.Window.ListView.Rows[i] = row
    end

    self:SetMovable()
end


function GM2_DbBrowser:SetMovable()
    self.Window.Frame:SetMovable(true)
    self.Window.Frame:EnableMouse(true)
    self.Window.Frame:RegisterForDrag("LeftButton")
    self.Window.Frame:SetScript("OnDragStart", self.Window.Frame.StartMoving)
    self.Window.Frame:SetScript("OnDragStop", self.Window.Frame.StopMovingOrSizing)
end

function GM2_DbBrowser:LockPosition()
    self.Window:SetMovable(false)
end


function GM2_DbBrowser:ClearListView()
    for k, v in ipairs(self.Window.ListView.Rows) do
        v.MapZoneText:SetText('')
        v.SourceIcon:SetTexture('')
        v.SourceText:SetText('')
        v.LocationText:SetText('')
    end
end


function GM2_DbBrowser:RefreshListView(data)
    self:ClearListView()
    if data and next(data) then
        local scrollPos = math.floor(self.Window.ListView.ScrollBar:GetValue())
        for i = 1, 20 do
            if data[(i - 1) + scrollPos] then
                self.Window.ListView.Rows[i].MapZoneText:SetText(data[(i - 1) + scrollPos].MapZone)
                self.Window.ListView.Rows[i].SourceIcon:SetTexture(data[(i - 1) + scrollPos].Texture)
                self.Window.ListView.Rows[i].SourceText:SetText(data[(i - 1) + scrollPos].Source)
                local x = string.format("%.4f", data[(i - 1) + scrollPos].PosX)
                local y = string.format("%.4f", data[(i - 1) + scrollPos].PosY)
                self.Window.ListView.Rows[i].LocationText:SetText(string.format('x %s : y %s', x, y))
            end
        end
    end
end

function GM2_DbBrowser:LoadDatabase(database, nodeType)
    if database and next(database) then
        self.DataSet = {}
        for zone, data in pairs(database) do
            for coords, id in pairs(data) do
                local node = GatherMate:GetNameForNode(nodeType, id)
                local x, y = GatherMate:DecodeLoc(coords)
                local map = C_Map.GetMapInfo(zone).name
                local expansionID = GatherMate.nodeExpansion[nodeType][id] - 1
                local expansionInfo = GetExpansionDisplayInfo(expansionID)
                local texture = GatherMate.nodeTextures[nodeType][id]
                table.insert(self.DataSet, {
                    MapZone = map,
                    Source = node,
                    PosX = x,
                    PosY = y,
                    Texture = texture,
                    --ExpansionLogo = expansionInfo.logo,
                })
            end
        end
        table.sort(self.DataSet, function(a, b)
            if a.MapZone == b.MapZone then
                return a.Source < b.Source
            else
                return a.MapZone < b.MapZone
            end
        end)
        local len = #self.DataSet
        self.Window.ListView.ScrollBar:SetMinMaxValues(1, (len - (self.Window.ListView.NumRows - 1)))
    else
        self.DataSet = {}
    end
end

GM2_DbBrowser.EventsFrame = CreateFrame('FRAME', 'GM2_DbBrowser_EventsFrame', UIParent)
GM2_DbBrowser.EventsFrame:RegisterEvent('ADDON_LOADED')
GM2_DbBrowser.EventsFrame:SetScript('OnEvent', function(self, event, addon)
    if event == 'ADDON_LOADED' and addon:lower() == 'gathermate2_dbviewer' then
        GatherMate = _G["GatherMate2"]
        if GatherMate then
            GM2_DbBrowser:Initialize()
        end
    end
end)