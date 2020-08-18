
local addonName, GM2_DBB = ...

SLASH_GATHERMATE2_DBBROWSER1 = '/gm2dbb'
SlashCmdList['GATHERMATE2_DBBROWSER'] = function(msg)
    GM2_DbBrowser.Window.Frame:Show()
end

GM2_DbBrowser = {}
GM2_DbBrowser.__index = GM2_DbBrowser

-- use this to check gathermate2 is loaded and usable
local GatherMate = false
local contextMenuSep = "|TInterface/COMMON/UI-TooltipDivider:8:150|t"

-- set up addon
function GM2_DbBrowser:Initialize()
    -- context menu stuff
    self.ContextMenu_DropDown = CreateFrame("Frame", "SimpleCooldownsSpellButtonContextMenu", UIParent, "UIDropDownMenuTemplate")
    self.ContextMenu = {}

    -- create tables for gm2 db data
    self.SelectedDatabaseInfo = {}
    self.DataSet = {}
    self.DataSet_Filtered = {}

    -- create ui table
    self.Window = {}

    -- create ui
    self.Window.Frame = CreateFrame('FRAME', 'GatherMate2_DbBrowser', UIParent, "UIPanelDialogTemplate")
    self.Window.Frame:SetSize(800, 525)
    self.Window.Frame:SetPoint('CENTER', 0, 0)
    self.Window.Frame:SetScript('OnShow', function(self)
        if next(GM2_DbBrowser.DataSet) then
            if next(GM2_DbBrowser.SelectedDatabaseInfo) then
                GM2_DbBrowser:LoadDatabase(GM2_DbBrowser.SelectedDatabaseInfo.DB, GM2_DbBrowser.SelectedDatabaseInfo.Name)
            end
            GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
        else
            GM2_DbBrowser:ClearListView()
        end
    end)
    self.Window.Title = self.Window.Frame:CreateFontString('$parentTitle', 'OVERLAY', 'GameFontNormal')
    self.Window.Title:SetPoint('TOP', 0, -9)
    self.Window.Title:SetText('GatherMate2 Database Viewer')

    self.Window.Header = self.Window.Frame:CreateFontString('$parentTitle', 'OVERLAY', 'GameFontNormal')
    self.Window.Header:SetPoint('TOPLEFT', 8, -34)
    self.Window.Header:SetPoint('TOPRIGHT', -8, -34)
    self.Window.Header:SetSize(GM2_DbBrowser.Window.Frame:GetWidth() - 16, 30)
    self.Window.Header:SetText('To view GatherMate2 data select a database using the dropdown menu. To search for gathering information within a database, right click a column button for filter options or enter a search term.')
    self.Window.Header:SetTextColor(1,1,1,1)

    -- ** keeping this here for now, as features grow a better ui will be needed for database tools etc
    -- self.Window.SearchFrame = CreateFrame('FRAME', 'GatherMate2_DbBrowserSearchFrame', self.Window.Frame)
    -- self.Window.SearchFrame:SetPoint('TOPLEFT', 18, -75)
    -- self.Window.SearchFrame:SetSize(380, 65)
    -- --self.Window.SearchFrame:SetPoint('BOTTOMRIGHT', self.Window.Frame, 'TOPRIGHT', -18, -145)
    -- self.Window.SearchFrame:SetBackdrop({ --bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    --     edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
    --     tile = true, tileSize = 16, edgeSize = 16, 
    --     insets = { left = 4, right = 4, top = 4, bottom = 4 }
    -- })
    -- self.Window.SearchFrameHeader = self.Window.Frame:CreateFontString('$parentSearchFrameHeader', 'OVERLAY', 'GameFontNormal')
    -- self.Window.SearchFrameHeader:SetPoint('BOTTOMLEFT', self.Window.SearchFrame, 'TOPLEFT', 4, 0)
    -- self.Window.SearchFrameHeader:SetWidth(100)
    -- self.Window.SearchFrameHeader:SetJustifyH('LEFT')
    -- self.Window.SearchFrameHeader:SetText('Search')


    -- map zone sort button asc/desc
    self.Window.MapZoneButton = CreateFrame('BUTTON', 'GatherMate2_DbBrowserMapZoneButton', self.Window.Frame, "UIPanelButtonTemplate")
    self.Window.MapZoneButton:SetPoint('TOPLEFT', self.Window.Frame, 'TOPLEFT', 10, -70)
    self.Window.MapZoneButton:SetSize(250, 22)
    self.Window.MapZoneButton:SetText('Map Zone')
    self.Window.MapZoneButton.sort = 0
    self.Window.MapZoneButton:RegisterForClicks('AnyUp')
    self.Window.MapZoneButton:SetScript('OnClick', function(self, button)
        if button == 'RightButton' then
            GM2_DbBrowser:OpenMapZoneContextMenu()
        else
            if self.sort == 0 then
                if not next(GM2_DbBrowser.DataSet_Filtered) then
                    table.sort(GM2_DbBrowser.DataSet, function(a, b)
                        if a.MapZoneName == b.MapZoneName then
                            return a.Source < b.Source
                        else
                            return a.MapZoneName > b.MapZoneName
                        end
                    end)
                    GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
                else
                    table.sort(GM2_DbBrowser.DataSet_Filtered, function(a, b)
                        if a.MapZoneName == b.MapZoneName then
                            return a.Source < b.Source
                        else
                            return a.MapZoneName > b.MapZoneName
                        end
                    end)
                    GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet_Filtered)
                end
                self.sort = 1
            else
                if not next(GM2_DbBrowser.DataSet_Filtered) then
                    table.sort(GM2_DbBrowser.DataSet, function(a, b)
                        if a.MapZoneName == b.MapZoneName then
                            return a.Source < b.Source
                        else
                            return a.MapZoneName < b.MapZoneName
                        end
                    end)
                    GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
                else
                    table.sort(GM2_DbBrowser.DataSet_Filtered, function(a, b)
                        if a.MapZoneName == b.MapZoneName then
                            return a.Source < b.Source
                        else
                            return a.MapZoneName < b.MapZoneName
                        end
                    end)
                    GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet_Filtered)
                end
                self.sort = 0
            end
        end
    end)
    -- source button asc/desc
    self.Window.SourceButton = CreateFrame('BUTTON', 'GatherMate2_DbBrowserSourceButton', self.Window.Frame, "UIPanelButtonTemplate")
    self.Window.SourceButton:SetPoint('LEFT', self.Window.MapZoneButton, 'RIGHT', 0, 0)
    self.Window.SourceButton:SetSize(250, 22)
    self.Window.SourceButton:SetText('Source')
    self.Window.SourceButton.sort = 0
    self.Window.SourceButton:RegisterForClicks('AnyUp')
    self.Window.SourceButton:SetScript('OnClick', function(self, button)
        if button == 'RightButton' then
            GM2_DbBrowser:OpenSourceContextMenu()
        else
            if self.sort == 0 then
                if not next(GM2_DbBrowser.DataSet_Filtered) then
                    table.sort(GM2_DbBrowser.DataSet, function(a, b)
                        if a.Source == b.Source then
                            return a.MapZoneName < b.MapZoneName
                        else
                            return a.Source > b.Source
                        end
                    end)
                    GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
                else
                    table.sort(GM2_DbBrowser.DataSet_Filtered, function(a, b)
                        if a.Source == b.Source then
                            return a.MapZoneName < b.MapZoneName
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
                            return a.MapZoneName < b.MapZoneName
                        else
                            return a.Source < b.Source
                        end
                    end)
                    GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
                else
                    table.sort(GM2_DbBrowser.DataSet_Filtered, function(a, b)
                        if a.Source == b.Source then
                            return a.MapZoneName < b.MapZoneName
                        else
                            return a.Source < b.Source
                        end
                    end)
                    GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet_Filtered)
                end
                self.sort = 0
            end
        end
    end)

    self.Window.SearchBox = CreateFrame('EditBox', 'GatherMate2_DbBrowserSearchBox', self.Window.Frame, "InputBoxTemplate")
    self.Window.SearchBox:SetPoint('LEFT', self.Window.SourceButton, 'RIGHT', 6, 0)
    self.Window.SearchBox:SetFontObject('GameFontNormal')
    self.Window.SearchBox:SetSize(134, 20)
    self.Window.SearchBox:SetAutoFocus(false)
    self.Window.SearchBox:Insert('Search term')
    self.Window.SearchBox:SetScript('OnTextChanged', function(self)
        if self:GetText():len() > 0 and next(GM2_DbBrowser.DataSet) then
            GM2_DbBrowser:FilterDatabaseResults(self:GetText())
        else
            GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
        end
    end)

    -- drop down menu to select gm2 db
    self.Window.DatabaseSelectionDropDown = CreateFrame('FRAME', 'GatherMate2_DbBrowserDatabaseSelectionDropDown', self.Window.Frame, "UIDropDownMenuTemplate")
    self.Window.DatabaseSelectionDropDown:SetPoint('LEFT', self.Window.SearchBox, 'RIGHT', -15, 0)
    UIDropDownMenu_SetWidth(self.Window.DatabaseSelectionDropDown, 125)
    UIDropDownMenu_SetText(self.Window.DatabaseSelectionDropDown, 'Select database')
    UIDropDownMenu_Initialize(self.Window.DatabaseSelectionDropDown, function()
        local info = UIDropDownMenu_CreateInfo()
        for name, db in pairs(GatherMate.gmdbs) do
            info.text = name
            info.isTitle = false
            info.notCheckable = true
            info.func = function(self)
                --GM2_DbBrowser.Window.SearchBox:SetText('Search term')
                GM2_DbBrowser.SelectedDatabaseInfo = {Name=name, DB=db}
                GM2_DbBrowser.DataSet = wipe(GM2_DbBrowser.DataSet)
                GM2_DbBrowser.DataSet_Filtered = wipe(GM2_DbBrowser.DataSet_Filtered)
                GM2_DbBrowser:LoadDatabase(db, name)
                GM2_DbBrowser:RefreshListView(GM2_DbBrowser.DataSet)
                UIDropDownMenu_SetText(GM2_DbBrowser.Window.DatabaseSelectionDropDown, name)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)


    -- listview table
    self.Window.ListView = {
        NumRows = 20.0,
        RowHeight = 21.0,
        RowOffsetY = 19.0,
        Rows = {},
        HoverColour = {0.1,0.6,0.3,0.2},
        SelectedColour = {0.4,0.73,1.0,0.2},
        BackgroundColour_Odd = {0.2,0.2,0.2,0.3},
        BackgroundColour_Even = {0.2,0.2,0.2,0.1},
    }
    -- create listview frame/area
    self.Window.ListView.Frame = CreateFrame('FRAME', 'GatherMate2_DbBrowserListView', self.Window.Frame)
    self.Window.ListView.Frame:SetPoint('TOPLEFT', self.Window.Frame, 'TOPLEFT', 12, -93)
    self.Window.ListView.Frame:SetPoint('BOTTOMRIGHT', self.Window.Frame, 'BOTTOMRIGHT', -8, 12)
    self.Window.ListView.Frame:EnableMouse(true)
    -- listview scroll bar, needs artwork?
    self.Window.ListView.ScrollBar = CreateFrame('SLIDER', 'GatherMate2_DbBrowserListViewScrollBar', self.Window.ListView.Frame, "UIPanelScrollBarTemplate")
    self.Window.ListView.ScrollBar:SetPoint('TOPLEFT', self.Window.ListView.Frame, 'TOPRIGHT', -16, -16)
    self.Window.ListView.ScrollBar:SetPoint('BOTTOMRIGHT', self.Window.ListView.Frame, 'BOTTOMRIGHT', 0, 16)
    self.Window.ListView.ScrollBar:EnableMouse(true)
    self.Window.ListView.ScrollBar:SetScript('OnShow', function(self)
        if next(GM2_DbBrowser.DataSet) then
            local len = #GM2_DbBrowser.DataSet
            if tonumber(len) <= 20.0 then
                self:SetMinMaxValues(1, 1)
            else
                self:SetMinMaxValues(1, (len - (GM2_DbBrowser.Window.ListView.NumRows - 1)))
            end
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
    -- no clue why but this works for getting values set, OnLoad didnt seem to fire (i know it must do but.....) and OnShow required hiding and re-showing ?
    self.Window.ListView.ScrollBar:Hide()
    self.Window.ListView.ScrollBar:Show()
    -- set up mouse scroll script
    self.Window.ListView.Frame:SetScript('OnMouseWheel', function(self, delta)
        local x = GM2_DbBrowser.Window.ListView.ScrollBar:GetValue()
        GM2_DbBrowser.Window.ListView.ScrollBar:SetValue(x - delta)
    end)
    -- draw listview rows
    for i = 1, self.Window.ListView.NumRows do
        local row = CreateFrame('FRAME', tostring('GatherMate2_DbBrowserListViewRow'..i), self.Window.ListView.Frame)
        row:SetPoint('TOPLEFT', self.Window.ListView.Frame, 'TOPLEFT', 0, ((i - 1) * self.Window.ListView.RowHeight) * -1)
        row:SetPoint('BOTTOMRIGHT', self.Window.ListView.Frame, 'TOPRIGHT', -16, (((i - 1) * self.Window.ListView.RowHeight) + self.Window.ListView.RowOffsetY) * -1)
        row.Background = row:CreateTexture('$parentBackgorund', 'BACKGROUND')
        row.Background:SetAllPoints(row)

        row.id = i

        if row.id % 2 == 0 then
            row.Background:SetColorTexture(unpack(GM2_DbBrowser.Window.ListView.BackgroundColour_Even))
        else
            row.Background:SetColorTexture(unpack(GM2_DbBrowser.Window.ListView.BackgroundColour_Odd))
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

        row.data = {}

        row:SetScript('OnShow', function(self)
            if self.data then
                self.MapZoneText:SetText(self.data.MapZoneName)
                self.SourceIcon:SetTexture(self.data.Texture)
                self.SourceText:SetText(self.data.Source)
                local x = string.format("%.4f", self.data.PosX)
                local y = string.format("%.4f", self.data.PosY)
                self.LocationText:SetText(string.format('x %s : y %s', x, y))
            else
                self.MapZoneText:SetText(' ')
                self.SourceIcon:SetTexture(nil)
                self.SourceText:SetText(' ')
                self.LocationText:SetText(' ')
            end
            GM2_DbBrowser:UpdateRowBackground(self)
        end)

        row:SetScript('OnHide', function(self)
            self.MapZoneText:SetText(' ')
            self.SourceIcon:SetTexture(nil)
            self.SourceText:SetText(' ')
            self.LocationText:SetText(' ')
        end)

        row:SetScript('OnMouseUp', function(self, button)
            if self.data then
                if button == 'LeftButton' then
                    self.data.Selected = not self.data.Selected
                    GM2_DbBrowser:UpdateRowBackground(self)
                elseif button == 'RightButton' then
                    GM2_DbBrowser:OpenRowContextMenu(self)
                    --print('deleted', self.data.NodeType, self.data.MapZoneID, self.data.Coords)
                    --GatherMate:RemoveNodeByID(self.data.MapZoneID, self.data.NodeType, self.data.Coords)
                end
            end
        end)

        row:SetScript('OnEnter', function(self)
            self.Background:SetColorTexture(unpack(GM2_DbBrowser.Window.ListView.HoverColour))
            for k, fontString in pairs({ self.MapZoneText, self.SourceText, self.LocationText }) do
                if self.data and self.data.Selected then
                    --fontString:SetTextColor(1,1,1,1)
                    fontString:SetTextColor(1.0, 0.82, 0.0, 1.0)
                else
                    --fontString:SetTextColor(1.0, 0.82, 0.0, 1.0)
                    fontString:SetTextColor(1,1,1,1)
                end
            end
        end)

        row:SetScript('OnLeave', function(self)
            GM2_DbBrowser:UpdateRowBackground(self)
        end)

        self.Window.ListView.Rows[i] = row
    end

    self:SetMovable()
end

--GatherMate:RemoveNodeByID(zone, nodeType, coord) zone=map id, nodeType=internal db name('Mining' or 'Fishing' etc), coord=encoded position

function GM2_DbBrowser:UpdateRowBackground(row)
    if row.data then
        if row.data.Selected then
            row.Background:SetColorTexture(unpack(self.Window.ListView.SelectedColour))
            for k, fontString in pairs({ row.MapZoneText, row.SourceText, row.LocationText }) do
                --fontString:SetTextColor(1,1,1,1)
                fontString:SetTextColor(1.0, 0.82, 0.0, 1.0)
            end
        else
            for k, fontString in pairs({ row.MapZoneText, row.SourceText, row.LocationText }) do
                --fontString:SetTextColor(1.0, 0.82, 0.0, 1.0)
                fontString:SetTextColor(1,1,1,1)
            end
            if row.id % 2 == 0 then
                row.Background:SetColorTexture(unpack(self.Window.ListView.BackgroundColour_Even))
            else
                row.Background:SetColorTexture(unpack(self.Window.ListView.BackgroundColour_Odd))
            end
        end
    else
        if row.id % 2 == 0 then
            row.Background:SetColorTexture(unpack(self.Window.ListView.BackgroundColour_Even))
        else
            row.Background:SetColorTexture(unpack(self.Window.ListView.BackgroundColour_Odd))
        end
    end
end

function GM2_DbBrowser:OpenMapZoneContextMenu()
    if next(self.DataSet) then
        local expansions = {}
        local expansionsAdded = {}
        local zonesAdded = {}
        GM2_DbBrowser.ContextMenu = {
            { text = 'Select zone', isTitle=true, notCheckable=true, },
        }
        table.sort(self.DataSet, function(a, b)
            if a.ExpansionID == b.ExpansionID then
                return a.MapZoneName < b.MapZoneName
            else
                return a.ExpansionID < b.ExpansionID
            end
        end)
        for k, node in ipairs(self.DataSet) do
            if not expansionsAdded[node.ExpansionName] then
                expansionsAdded[node.ExpansionName] = true
                table.insert(expansions, {
                    ID = node.ExpansionID,
                    Name = node.ExpansionName
                })
            end
        end
        for k, v in ipairs(expansions) do
            local zones = {
                { text = v.Name, isTitle=true, notCheckable=true },
            }
            for k, node in ipairs(self.DataSet) do
                if tonumber(node.ExpansionID) == tonumber(v.ID) then
                    if not zonesAdded[node.MapZoneName] then
                        zonesAdded[node.MapZoneName] = true
                        table.insert(zones, {
                            text = node.MapZoneName,
                            notCheckable = true,
                            func = function(self)
                                GM2_DbBrowser:FilterDatabaseResults(node.MapZoneName, true)
                            end,
                        })
                    end
                end
            end
            table.insert(GM2_DbBrowser.ContextMenu, {
                text = v.Name,
                isTitle = false,
                notCheckable = true,
                func = function(self)
                    GM2_DbBrowser:FilterDatabaseResults(v.Name, true)
                end,
                hasArrow = true,
                menuList = zones,
            })
        end
        EasyMenu(GM2_DbBrowser.ContextMenu, GM2_DbBrowser.ContextMenu_DropDown, "cursor", 0 , 0, "MENU")
    end
end

function GM2_DbBrowser:OpenSourceContextMenu()
    if next(self.DataSet) then
        local expansions = {}
        local expansionsAdded = {}
        local sourcesAdded = {}
        GM2_DbBrowser.ContextMenu = {
            { text = 'Select source', isTitle=true, notCheckable=true, },
        }
        table.sort(self.DataSet, function(a, b)
            if a.ExpansionID == b.ExpansionID then
                return a.Source < b.Source
            else
                return a.ExpansionID < b.ExpansionID
            end
        end)
        for k, node in ipairs(self.DataSet) do
            if not expansionsAdded[node.ExpansionName] then
                expansionsAdded[node.ExpansionName] = true
                table.insert(expansions, {
                    ID = node.ExpansionID,
                    Name = node.ExpansionName
                })
            end
        end
        for k, v in ipairs(expansions) do
            local sources = {
                { text = v.Name, isTitle=true, notCheckable=true },
            }
            for k, node in ipairs(self.DataSet) do
                if tonumber(node.ExpansionID) == tonumber(v.ID) then
                    if not sourcesAdded[node.Source] then
                        sourcesAdded[node.Source] = true
                        table.insert(sources, {
                            text = node.Source,
                            icon = node.Texture,
                            notCheckable = true,
                            func = function(self)
                                GM2_DbBrowser:FilterDatabaseResults(node.Source, true)
                            end,
                        })
                    end
                end
            end
            table.insert(GM2_DbBrowser.ContextMenu, {
                text = v.Name,
                isTitle = false,
                notCheckable = true,
                func = function(self)
                    GM2_DbBrowser:FilterDatabaseResults(v.Name, true)
                end,
                hasArrow = true,
                menuList = sources,
            })
        end
        EasyMenu(GM2_DbBrowser.ContextMenu, GM2_DbBrowser.ContextMenu_DropDown, "cursor", 0 , 0, "MENU")
    end
end

function GM2_DbBrowser:OpenRowContextMenu(row)
    self.ContextMenu = {
        { text = 'Options', isTitle=true, notCheckable=true, },
        { text = row.data.Source, notCheckable=true, icon = row.data.Texture, },
    }
    EasyMenu(self.ContextMenu, self.ContextMenu_DropDown, "cursor", 0 , 16, "MENU")
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
    for i = 1, 20 do
        if self.Window.ListView.Rows[i] then
            self.Window.ListView.Rows[i]:Hide()
            self.Window.ListView.Rows[i].data = nil
            self.Window.ListView.Rows[i]:Show()
        end
    end
end

-- this works for now but there is probably a better way to do instead of creating a new table for each keypress in the search box
-- also has a bonus side effect of return a full data set in search box is empty
function GM2_DbBrowser:FilterDatabaseResults(filter, exact)
    filter = filter:lower()
    if next(self.DataSet) then
        --self.DataSet_Filtered = {} -- make a better wipe/delete func
        wipe(GM2_DbBrowser.DataSet_Filtered)
        if not exact then
            for k, node in ipairs(self.DataSet) do
                if node.source:find(filter) or node.mapZoneName:find(filter) or node.expansionName:find(filter) then
                    table.insert(self.DataSet_Filtered, node)
                end
            end
        else
            for k, node in ipairs(self.DataSet) do
                if node.source == filter or node.mapZoneName == filter or node.expansionName == filter then
                    table.insert(self.DataSet_Filtered, node)
                end
            end
        end
        local len = #self.DataSet_Filtered
        if tonumber(len) <= 20.0 then
            self.Window.ListView.ScrollBar:SetMinMaxValues(1, 1)
        else
            self.Window.ListView.ScrollBar:SetMinMaxValues(1, (len - (GM2_DbBrowser.Window.ListView.NumRows - 1)))
        end
        self:RefreshListView(self.DataSet_Filtered)
    end
end

function GM2_DbBrowser:RefreshListView(data)
    self:ClearListView()
    if data and next(data) then
        local scrollPos = math.floor(self.Window.ListView.ScrollBar:GetValue())
        for i = 1, 20 do
            if data[(i - 1) + scrollPos] then
                self.Window.ListView.Rows[i]:Hide()
                self.Window.ListView.Rows[i].data = data[(i - 1) + scrollPos]
                self.Window.ListView.Rows[i]:Show()
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
                local expID = GatherMate.nodeExpansion[nodeType][id] - 1 --blizz start with tbc as expansion 1
                local expName = _G['EXPANSION_NAME'..expID]
                local expInfo = GetExpansionDisplayInfo(expID)
                local texture = GatherMate.nodeTextures[nodeType][id]
                table.insert(self.DataSet, {
                    -- node fields
                    NodeType = nodeType,
                    MapZoneName = map,
                    MapZoneID = zone,
                    Coords = coords,
                    Source = node,
                    PosX = x,
                    PosY = y,
                    Texture = texture,
                    ExpansionName = expName,
                    ExpansionID = expID,
                    -- listview fields
                    Selected = false,
                    -- filter fields
                    mapZoneName = map:lower(),
                    source = node:lower(),
                    expansionName = expName:lower(),
                })
            end
        end
        table.sort(self.DataSet, function(a, b)
            if a.MapZoneName == b.MapZoneName then
                return a.Source < b.Source
            else
                return a.MapZoneName < b.MapZoneName
            end
        end)
        local len = #self.DataSet
        if tonumber(len) <= 20.0 then
            self.Window.ListView.ScrollBar:SetMinMaxValues(1, 1)
        else
            self.Window.ListView.ScrollBar:SetMinMaxValues(1, (len - (GM2_DbBrowser.Window.ListView.NumRows - 1)))
        end
        print(string.format('returned %s results from db', len))
    else
        self.DataSet = {}
    end
end

GM2_DbBrowser.EventsFrame = CreateFrame('FRAME', 'GM2_DbBrowser_EventsFrame', UIParent)
GM2_DbBrowser.EventsFrame:RegisterEvent('ADDON_LOADED')
GM2_DbBrowser.EventsFrame:SetScript('OnEvent', function(self, event, addon)
    if event == 'ADDON_LOADED' and addon:lower() == 'gathermate2_dbbrowser' then
        GatherMate = _G["GatherMate2"]
        if GatherMate then
            GM2_DbBrowser:Initialize()
        end
    end
end)