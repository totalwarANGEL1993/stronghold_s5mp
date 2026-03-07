---
--- Mod loader for Stronghold.
---

StrongholdModLoader = {
    -- Current live version
    CURRENT_VERSION = "0_7_0",
    -- Name of key were version is stored in game informations
    CURRENT_VERSION_NAME = "STRONGHOLD_S5MP_VERSION",

    -- Called when the player selects a map (multiplayer).
    OnMapSelected = function()
        if CNetwork then
            local String = XNetwork.EXTENDED_GameInformation_GetCustomString();
            local Data = CustomStringHelper.FromString(String);
            CustomStringHelper.SetKeyValue(
                Data,
                StrongholdModLoader.CURRENT_VERSION_NAME,
                StrongholdModLoader.CURRENT_VERSION
            );
            local Converted = CustomStringHelper.ToString(Data);
            XNetwork.EXTENDED_GameInformation_SetCustomString(Converted);
        end
    end,

    -- Called when the player selects another map (multiplayer).
    OnMapDeselected = function()
        if CNetwork then
            local String = XNetwork.EXTENDED_GameInformation_GetCustomString();
            local Data = CustomStringHelper.FromString(String);
            CustomStringHelper.ResetKey(
                Data,
                StrongholdModLoader.CURRENT_VERSION_NAME
            );
            local Converted = CustomStringHelper.ToString(Data);
            XNetwork.EXTENDED_GameInformation_SetCustomString(Converted);
        end
    end,

    -- Called when the player starts the game.
    OnMapStart = function()
        local SavedVersion;
        if CNetwork then
            local String = XNetwork.EXTENDED_GameInformation_GetCustomString();
            local Data = CustomStringHelper.FromString(String);
            SavedVersion = CustomStringHelper.GetValue(
                Data,
                StrongholdModLoader.CURRENT_VERSION_NAME
            );
        end
        local Version = SavedVersion or StrongholdModLoader.CURRENT_VERSION;

        if LuaDebugger and LuaDebugger.Log then
            LuaDebugger.Log("Loading Stronghold version: ".. string.gsub(Version, "_", "."));
        end
        CMod.PushArchive("stronghold_s5mp\\version\\".. Version .."\\sh_textureslow.bba");
        CMod.PushArchive("stronghold_s5mp\\version\\".. Version .."\\sh_texturesmed.bba");
        CMod.PushArchive("stronghold_s5mp\\version\\".. Version .."\\sh_textures.bba");
        CMod.PushArchive("stronghold_s5mp\\version\\".. Version .."\\sh_sounds.bba");
        CMod.PushArchive("stronghold_s5mp\\version\\".. Version .."\\sh_system.bba");

        local ArchiveFound = false;
        local Archives = CMod.GetAllArchives();
        Archives = type(Archives) ~= "table" and {Archives} or Archives;
        for i= 1, table.getn(Archives) do
            if string.find(Archives[i], "sh_system.bba") then
                ArchiveFound = true;
                break;
            end
        end

        assert(ArchiveFound, "Unable to find Stronghold!");
        if ArchiveFound and LuaDebugger and LuaDebugger.Log then
            LuaDebugger.Log("Stronghold loaded!");
        end
    end,
}

-- Add new sounds
CUtil.AddSound("animal\\so_bear_attack_rnd_1");
CUtil.AddSound("animal\\so_bear_attack_rnd_2");
CUtil.AddSound("animal\\so_dog_attack_rnd_1");
CUtil.AddSound("animal\\so_dog_attack_rnd_2");
CUtil.AddSound("animal\\so_lion_attack_rnd_1");
CUtil.AddSound("animal\\so_lion_attack_rnd_2");
CUtil.AddSound("animal\\so_wolf_attack_rnd_1");
CUtil.AddSound("animal\\so_wolf_attack_rnd_2");

return StrongholdModLoader;

