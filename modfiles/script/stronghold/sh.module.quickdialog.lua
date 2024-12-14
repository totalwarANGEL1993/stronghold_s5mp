--- 
--- Quick Dialog Script
--- 

QuickDialog = QuickDialog or {};

Stronghold = Stronghold or {};

Stronghold.QuickDialog = Stronghold.QuickDialog or {
    GabID = 0,
    SyncEvents = {},
    Data = {},
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- API

function QuickDialog.Start(_PlayerID, _DialogName, _Dialog)
    Stronghold.QuickDialog:StartDialog(_PlayerID, _DialogName, _Dialog);
end

function QuickDialog.AddPages(_Dialog)
    return Stronghold.QuickDialog:AddPages(_Dialog);
end

function QuickDialog.IsActive(_PlayerID)
    return Stronghold.QuickDialog:IsDialogActive(_PlayerID);
end

function AP(_Data)
    assert(false, "Must be initalized with BriefingSystem.AddPages!");
    return {};
end

-- -------------------------------------------------------------------------- --
-- Callbacks

function GameCallback_SH_Logic_DialogStarted(_PlayerID, _Dialog)
end

function GameCallback_SH_Logic_DialogFinished(_PlayerID, _Dialog, _Abort)
end

function GameCallback_SH_Logic_DialogNextPage(_PlayerID, _Dialog, _Page)
end

function GameCallback_SH_Logic_DeletePage(_PlayerID, _Dialog, _Gab, _Page)
end

-- -------------------------------------------------------------------------- --
-- Main

function Stronghold.QuickDialog:Install()
    Cinematic.Install();

    for PlayerID = 1, GetMaxPlayers() do
        self.Data[PlayerID] = {
            Book = nil,
            Queue = {},
        };
        self:CreateNetworkHandlers();

        self.Job = Job.Second(function()
            Stronghold.QuickDialog:ControlDialog();
        end);
    end
end

function Stronghold.QuickDialog:OnSaveGameLoaded()
end

function Stronghold.QuickDialog:CreateNetworkHandlers()
    self.SyncEvents = {
        DeletePage = 1,
    };

    self.NetworkCall = Syncer.CreateEvent(
        function(_PlayerID, _Action, ...)
            if _Action == Stronghold.Building.SyncEvents.DeletePage then
                Stronghold.QuickDialog:DeletePage(_PlayerID, arg[1]);
            end
        end
    );
end

function Stronghold.QuickDialog:IsDialogActive(_PlayerID)
    local PlayerID = _PlayerID or GUI.GetPlayerID();
    return self.Data[PlayerID].Book ~= nil;
end

function Stronghold.QuickDialog:IsDialogActiveForAnyPlayer()
    for PlayerID = 1, GetMaxPlayers() do
        if self:IsDialogActive(PlayerID) then
            return true;
        end
    end
    return false;
end

function Stronghold.QuickDialog:StartDialog(_PlayerID, _DialogName, _Dialog)
    -- Abort if event can not be created
    if not Cinematic.Define(_PlayerID, _DialogName) then
        return;
    end
    -- Start dialog if possible
    if Cinematic.IsAnyActive(_PlayerID) then
        table.insert(self.Data[_PlayerID].Queue, {_DialogName, CopyTable(_Dialog)});
        return;
    end
    table.insert(self.Data[_PlayerID].Queue, 1, {_DialogName, CopyTable(_Dialog)});
    self:NextDialog(_PlayerID);
    return true;
end

function Stronghold.QuickDialog:EndDialog(_PlayerID, _Abort)
    local Data = self.Data[_PlayerID].Book;
    -- Register briefing as finished
    local DialogName = Data.ID;
    Cinematic.Conclude(_PlayerID, DialogName);
    -- Call finished
    if Data.Finished then
        Data:Finished(_Abort);
    end
    -- Call game callback
    GameCallback_SH_Logic_DialogFinished(_PlayerID, Data, _Abort);
    -- Invalidate briefing
    self:ClearAllPages(_PlayerID);
    self.Data[_PlayerID].Book = nil;
    -- Dequeue next briefing
    if self.Data[_PlayerID].Queue and table.getn(self.Data[_PlayerID].Queue) > 0 then
        local NewDialog = table.remove(self.Data[_PlayerID].Queue, 1);
        self:StartDialog(_PlayerID, NewDialog[1], NewDialog[2]);
    end
end

function Stronghold.QuickDialog:NextDialog(_PlayerID)
    if not self.Data[_PlayerID].Queue then
        return;
    end
    local Dialog = table.remove(self.Data[_PlayerID].Queue, 1);

    self.Data[_PlayerID].Book             = CopyTable(Dialog[2]);
    self.Data[_PlayerID].Book.ID          = Dialog[1];
    self.Data[_PlayerID].Book.PlayerID    = _PlayerID;
    self.Data[_PlayerID].Book.Page        = 0;
    self.Data[_PlayerID].Book.Print       = {};

    local Data = self.Data[_PlayerID].Book;
    -- Register briefing as active
    Cinematic.Activate(_PlayerID, Data.ID);
    -- Call function on start
    if Data.Starting then
        Data:Starting();
    end
    -- Call game callback
    GameCallback_SH_Logic_DialogStarted(_PlayerID, Data);
    -- Show nex page
    self:NextPage(_PlayerID, true);
end

function Stronghold.QuickDialog:NextPage(_PlayerID, _FirstPage)
    -- Check briefing exists
    if not self.Data[_PlayerID].Book then
        return;
    end
    local Data = self.Data[_PlayerID].Book;
    -- Increment page
    self.Data[_PlayerID].Book.Page = Data.Page +1;
    -- End briefing if page does not exist
    local PageID = self.Data[_PlayerID].Book.Page;
    local Page   = self.Data[_PlayerID].Book[PageID];
    if not Page then
        self:EndDialog(_PlayerID);
        return;
    end
    -- Call page action for all players
    if Page.Action then
        Page:Action(Data);
    end
    -- Fill new print entry
    self.GabID = self.GabID + 1;
    local Print = {
        Data = Page,
        StartTime = Round(Logic.GetTime()),
        Duration = Page.Duration or 9,
        Title = Page.Title,
        Text = Page.Text,
        Portrait = Page.Portrait,
        Close = Page.Close,
        NoDelete = Page.NoDelete,
        ID = self.GabID,
    };
    self.Data[_PlayerID].Book[PageID].StartTime = Print.StartTime;
    self.Data[_PlayerID].Book[PageID].Duration = Print.Duration;
    table.insert(self.Data[_PlayerID].Book.Print, 1, Print);
    -- Invoke game callback
    GameCallback_SH_Logic_DialogNextPage(_PlayerID, Data, Page);
    -- Render pages
    for i= self.Config.Display.MaxGabMessages, 1, -1 do
        self:RenderPage(_PlayerID, i);
    end
end

function Stronghold.QuickDialog:DeletePage(_PlayerID, _ID)
    if self.Data[_PlayerID].Book then
        local Dialog = self.Data[_PlayerID].Book;
        local Data = self.Data[_PlayerID].Book.Print;
        for i= table.getn(Data), 1, -1 do
            if Data[i].ID == _ID and not Data[i].NoDelete then
                local Page = table.remove(self.Data[_PlayerID].Book.Print, i);
                if Page.Close then
                    Page.Close(Page.Data);
                end
                GameCallback_SH_Logic_DeletePage(_PlayerID, Dialog, Page, Page.Data);
                break;
            end
        end
        -- Render pages
        for i= self.Config.Display.MaxGabMessages, 1, -1 do
            self:RenderPage(_PlayerID, i);
        end
    end
end

function Stronghold.QuickDialog:ClearAllPages(_PlayerID)
    if self.Data[_PlayerID].Book then
        for i= table.getn(self.Data[_PlayerID].Book.Print), 1, -1 do
            table.remove(self.Data[_PlayerID].Book.Print, i);
            XGUIEng.ShowWidget("Gab0" ..i, 0);
        end
    end
end

function Stronghold.QuickDialog:ControlDialog()
    for PlayerID= 1, GetMaxPlayers() do
        if self.Data[PlayerID].Book then
            local Data = self.Data[PlayerID].Book;
            local PageID = Data.Page;
            -- Check page exists
            if not Data[PageID] then
                return false;
            end
            -- Stop dialog
            if type(Data[PageID]) == nil then
                self:EndDialog(PlayerID);
                return false;
            end
            -- Next page after duration is up
            local TimePassed = Logic.GetTime() - Data[PageID].StartTime;
            if TimePassed > self.Data[PlayerID].Book[PageID].Duration then
                self:NextPage(PlayerID, false);
            end
        end
    end
end

function Stronghold.QuickDialog:AddPages(_Dialog)
    local AP = function(_Page)
        assert(_Page ~= nil);
        table.insert(_Dialog, _Page);
        return _Page;
    end
    return AP;
end

function Stronghold.QuickDialog:RenderPage(_PlayerID, _Index)
    if _PlayerID ~= GUI.GetPlayerID()
    or not self.Data[_PlayerID]
    or not self.Data[_PlayerID].Book then
        return;
    end
    local Data = self.Data[_PlayerID].Book.Print;
    local Page = Data[_Index];
    if not Page then
        XGUIEng.ShowWidget("Gab0" .._Index, 0);
        return;
    end

    local TitleWidget = "Gab0" .._Index.. "Title";
    local TextWidget = "Gab0" .._Index.. "Text";
    XGUIEng.ShowWidget("Gab0" .._Index.. "Title", 1);
    XGUIEng.ShowWidget("Gab0" .._Index.. "PortraitTitle", 0);
    XGUIEng.ShowWidget("Gab0" .._Index.. "Text", 1);
    XGUIEng.ShowWidget("Gab0" .._Index.. "PortraitText", 0);
    XGUIEng.ShowWidget("Gab0" .._Index.. "Portrait", 0);
    XGUIEng.ShowWidget("Gab0" .._Index.. "Done", 0);
    if not Page.NoDelete then
        XGUIEng.ShowWidget("Gab0" .._Index.. "Done", 0);
    end
    if Page.Portrait then
        TitleWidget = "Gab0" .._Index.. "PortraitTitle";
        TextWidget = "Gab0" .._Index.. "PortraitText";
        XGUIEng.ShowWidget("Gab0" .._Index.. "Title", 0);
        XGUIEng.ShowWidget("Gab0" .._Index.. "PortraitTitle", 1);
        XGUIEng.ShowWidget("Gab0" .._Index.. "Text", 0);
        XGUIEng.ShowWidget("Gab0" .._Index.. "PortraitText", 1);
        XGUIEng.ShowWidget("Gab0" .._Index.. "Portrait", 1);
        XGUIEng.SetMaterialTexture("Gab0" .._Index.. "Portrait", 1, Page.Portrait);
    end
    XGUIEng.ShowWidget("Gab0" .._Index, 1);

    local Alpha = (_Index -1) * (1 / self.Config.Display.MaxGabMessages);
    XGUIEng.SetMaterialColor("Gab0" .._Index.. "Background", 0, 255, 255, 255, 255 * (1 - Alpha));

    local Title = Localize(Page.Title);
    Title = Placeholder.Replace(Title);
    if _Index > 1 then
        Title = " @color:80,80,80," ..(255 * (1 - Alpha)).. " " .. Title
    end
    XGUIEng.SetText(TitleWidget, Title);

    local Text = Localize(Page.Text);
    Text = Placeholder.Replace(Text);
    if _Index > 1 then
        Text = " @color:180,180,180," ..(255 * (1 - Alpha)).. " " .. Text
    end
    XGUIEng.SetText(TextWidget, Text);
end

-- -------------------------------------------------------------------------- --
-- GUI Functions

function GUIUpdate_GabWindowUpdate()
    -- Unused
end

function GUIAction_GabWindowClose(_Index)
    local PlayerID = GUI.GetPlayerID();
    if PlayerID == 17 then
        return;
    end
    if Stronghold.QuickDialog.Data[PlayerID].Book then
        return;
    end
    local Data = Stronghold.QuickDialog.Data[PlayerID].Book;
    local ID = Data.Print[_Index];
    Syncer.InvokeEvent(
        Stronghold.Building.SyncEvents.DeletePage,
        ID
    );
end

