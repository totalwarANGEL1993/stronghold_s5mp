--- 
--- Quick Dialog Script
--- 

Stronghold = Stronghold or {};

Stronghold.QuickDialog = Stronghold.QuickDialog or {
    Data = {},
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- API



-- -------------------------------------------------------------------------- --
-- Callbacks



-- -------------------------------------------------------------------------- --
-- Main

function Stronghold.QuickDialog:Install()
    for PlayerID = 1, GetMaxPlayers() do
        self.Data[PlayerID] = {};
    end
end

function Stronghold.QuickDialog:OnSaveGameLoaded()
end

-- -------------------------------------------------------------------------- --
-- GUI Functions

function GUIUpdate_GabWindowUpdate()

end

function GUIAction_GabWindowClose(_Index)

end

