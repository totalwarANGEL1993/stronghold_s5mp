--- 
--- Statistics Fix
--- 

Stronghold = Stronghold or {};

Stronghold.Statistic = {
    Data = {},
}

-- -------------------------------------------------------------------------- --

-- Used by the server to calculate absolute amount of Honor earned.
function ExtendedStatistics_Callback_HonorEarned(_PlayerID)
    if Stronghold.Statistic.Data[_PlayerID] then
        return Stronghold.Statistic.Data[_PlayerID].Resources.Honor[1];
    end
    return 0;
end

-- Used by the server to calculate Honor earned per minute.
function ExtendedStatistics_Callback_HonorEarnedPerMinute(_PlayerID)
    if Stronghold.Statistic.Data[_PlayerID] then
        local Actual = Stronghold.Statistic.Data[_PlayerID].Resources.Honor[1];
        local Before = Stronghold.Statistic.Data[_PlayerID].Resources.Honor[2];
        Stronghold.Statistic.Data[_PlayerID].Resources.Honor[2] = Actual
        return Actual - Before;
    end
    return 0;
end

-- Used by the server to calculate absolute amount of Reputation earned.
function ExtendedStatistics_Callback_ReputationEarned(_PlayerID)
    if Stronghold.Statistic.Data[_PlayerID] then
        return Stronghold.Statistic.Data[_PlayerID].Resources.Reputation[1];
    end
    return 0;
end

-- Used by the server to calculate Reputation earned per minute.
function ExtendedStatistics_Callback_ReputationEarnedPerMinute(_PlayerID)
    if Stronghold.Statistic.Data[_PlayerID] then
        local Actual = Stronghold.Statistic.Data[_PlayerID].Resources.Reputation[1];
        local Before = Stronghold.Statistic.Data[_PlayerID].Resources.Reputation[2];
        Stronghold.Statistic.Data[_PlayerID].Resources.Reputation[2] = Actual
        return Actual - Before;
    end
    return 0;
end

-- Used by the server to calculate absolute amount of knowledge earned.
function ExtendedStatistics_Callback_KnowledgeEarned(_PlayerID)
    if Stronghold.Statistic.Data[_PlayerID] then
        return Stronghold.Statistic.Data[_PlayerID].Resources.Knowledge[1];
    end
    return 0;
end

-- Used by the server to calculate Knowledge earned per minute.
function ExtendedStatistics_Callback_KnowledgePerMinute(_PlayerID)
    if Stronghold.Statistic.Data[_PlayerID] then
        local Actual = Stronghold.Statistic.Data[_PlayerID].Resources.Knowledge[1];
        local Before = Stronghold.Statistic.Data[_PlayerID].Resources.Knowledge[2];
        Stronghold.Statistic.Data[_PlayerID].Resources.Knowledge[2] = Actual
        return Actual - Before;
    end
    return 0;
end

-- Used by the server to calculate absolute amount of wood earned.
function ExtendedStatistics_Callback_WoodEarned(_PlayerID)
    if Stronghold.Statistic.Data[_PlayerID] then
        return Stronghold.Statistic.Data[_PlayerID].Resources.Wood[1];
    end
    return 0;
end

-- Used by the server to calculate wood earned per minute.
function ExtendedStatistics_Callback_WoodEarnedPerMinute(_PlayerID)
    if Stronghold.Statistic.Data[_PlayerID] then
        local Actual = Stronghold.Statistic.Data[_PlayerID].Resources.Wood[1];
        local Before = Stronghold.Statistic.Data[_PlayerID].Resources.Wood[2];
        Stronghold.Statistic.Data[_PlayerID].Resources.Wood[2] = Actual
        return Actual - Before;
    end
    return 0;
end

-- -------------------------------------------------------------------------- --

function Stronghold.Statistic:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Technologies = {};
            Resources = {
                ["Honor"] = {0, 0},
                ["Reputation"] = {0, 0},
                ["Knowledge"] = {0, 0},
                ["Wood"] = {0, 0},
            };
        };
    end
    Job.Second(function()
        Stronghold.Statistic:UpdateTechnologiesResearchedTooltip();
    end);

    self:OverwriteTechnologyResearched();
    self:InitGameEndscreenExtra();
end

function Stronghold.Statistic:OnSaveGameLoaded()
end

function Stronghold.Statistic:OnTechnologyResearched(_PlayerID, _TechnologyType)
    local Time = math.floor(Logic.GetTime());
    if _TechnologyType > 0 and Time > 0 and _PlayerID ~= 17 then
        -- Check for technology
        local IsInTable = false;
        for i= 1, table.getn(self.Data[_PlayerID].Technologies) do
            if self.Data[_PlayerID].Technologies[i].Technology == _TechnologyType then
                IsInTable = true;
            end
        end
        -- Add to statistic if not found
        if IsInTable == false then
            table.insert(self.Data[_PlayerID].Technologies, {
                Technology = _TechnologyType,
                Time = Time
            });
        end
    end
end

function Stronghold.Statistic:GetTechnologiesResearchedString(_PlayerID)
    local Text = {"", "", ""};
    if self.Data[_PlayerID] then
        for i= 1, table.getn(self.Data[_PlayerID].Technologies) do
            local TechName = KeyOf(self.Data[_PlayerID].Technologies[i].Technology, Technologies);
            if string.find(TechName, "^T_") then
                local Name = XGUIEng.GetStringTableText("Names/" ..TechName);
                if Name ~= nil and Name ~= "" then
                    local Screen = {GUI.GetScreenSize()}
                    local Time = ConvertSecondsToString(self.Data[_PlayerID].Technologies[i].Time);

                    local Comumn1 = (Screen[2] >= 1080 and 25) or 20;
                    local Comumn2 = (Screen[2] >= 1080 and 50) or 40;
                    local Comumn3 = (Screen[2] >= 1080 and 75) or 60;

                    if i < Comumn1+1 then
                        Text[1] = Text[1] .. Name .. " - " .. Time .. " @cr ";
                    elseif i > Comumn1 and i < Comumn2+1 then
                        Text[2] = Text[2] .. Name .. " - " .. Time .. " @cr ";
                    elseif i > Comumn2 and i < Comumn3+1 then
                        Text[3] = Text[3] .. Name .. " - " .. Time .. " @cr ";
                    else
                        break;
                    end
                end
            end
        end
    end
    return Text;
end

function Stronghold.Statistic:UpdateTechnologiesResearchedTooltip()
    if XGUIEng.IsWidgetShown("StatisticsWindow") == 1 then
        local PlayerID = GUI.GetPlayerID();
        if PlayerID == 17 then
            local Entity = GUI.GetSelectedEntity();
            PlayerID = Logic.EntityGetPlayer(Entity);
        end
        local Text = self:GetTechnologiesResearchedString(PlayerID);
        XGUIEng.SetText("StatisticsCustomTextWidget1", Text[1]);
        XGUIEng.SetText("StatisticsCustomTextWidget2", Text[2]);
        XGUIEng.SetText("StatisticsCustomTextWidget3", Text[3]);
    end
end

function Stronghold.Statistic:OverwriteTechnologyResearched()
    Overwrite.CreateOverwrite(
        "GameCallback_OnTechnologyResearched", function(_PlayerID, _TechnologyType)
            Overwrite.CallOriginal();
            Stronghold.Statistic:OnTechnologyResearched(_PlayerID, _TechnologyType);
        end
    );

    StatisticsWindow_SelectGroup_Orig_SH = StatisticsWindow_SelectGroup;
    StatisticsWindow_SelectGroup = function(_Group)
        StatisticsWindow_SelectGroup_Orig_SH(_Group);
        XGUIEng.ShowWidget("StatisticsRendererCustomWidget", (_Group ~= 4 and 1) or 0);
        XGUIEng.ShowWidget("StatisticsCustomTextWidget1", (_Group == 4 and 1) or 0);
        XGUIEng.ShowWidget("StatisticsCustomTextWidget2", (_Group == 4 and 1) or 0);
        XGUIEng.ShowWidget("StatisticsCustomTextWidget3", (_Group == 4 and 1) or 0);
        XGUIEng.ShowWidget("StatisticsCustomTextUpdater", (_Group == 4 and 1) or 0);
        if _Group == 4 then
            local Headline = XGUIEng.GetStringTableText("WindowStatistics/InfoTechnologies");
            XGUIEng.SetText("Statistics_Selected", Headline);
            XGUIEng.ShowWidget("StatisticsTopButtonContainer", 0);
        end
    end
end

function Stronghold.Statistic:InitGameEndscreenExtra()
    if not Syncer.IsMultiplayer() then
        return;
    end

    local IconMatrix = "data/graphics/textures/gui/sh_b_statisticsextra.png";
    local TextKnowledge = XGUIEng.GetStringTableText("sh_windowstatisticextra/KnowledgeEarned");
    local TextKPM = XGUIEng.GetStringTableText("sh_windowstatisticextra/KnowledgePerMinute");
    local TextHonor = XGUIEng.GetStringTableText("sh_windowstatisticextra/HonorEarned");
    local TextHPM = XGUIEng.GetStringTableText("sh_windowstatisticextra/HonorPerMinute");
    local TextReputation = XGUIEng.GetStringTableText("sh_windowstatisticextra/ReputationEarned");
    local TextRPM = XGUIEng.GetStringTableText("sh_windowstatisticextra/ReputationPerMinute");

    CUtilStatistics.AddStatisticWithPM(
        "HonorEarned", TextHonor, TextHPM, "EarnedResources",
        "ExtendedStatistics_Callback_HonorEarned", "ExtendedStatistics_Callback_HonorEarnedPerMinute"
    );
	CUtilStatistics.SetStatisticWidgetValues("normal",  "HonorEarned", IconMatrix, GetTextureCoordinatesAt(4, 32, 0, 23));
	CUtilStatistics.SetStatisticWidgetValues("hovered", "HonorEarned", IconMatrix, GetTextureCoordinatesAt(4, 32, 1, 23));
	CUtilStatistics.SetStatisticWidgetValues("pressed", "HonorEarned", IconMatrix, GetTextureCoordinatesAt(4, 32, 2, 23));

    CUtilStatistics.AddStatisticWithPM(
        "ReputationEarned", TextReputation, TextHPM, "EarnedResources",
        "ExtendedStatistics_Callback_ReputationEarned", "ExtendedStatistics_Callback_ReputationEarnedPerMinute"
    );
	CUtilStatistics.SetStatisticWidgetValues("normal",  "ReputationEarned", IconMatrix, GetTextureCoordinatesAt(4, 32, 0, 11));
	CUtilStatistics.SetStatisticWidgetValues("hovered", "ReputationEarned", IconMatrix, GetTextureCoordinatesAt(4, 32, 1, 11));
	CUtilStatistics.SetStatisticWidgetValues("pressed", "ReputationEarned", IconMatrix, GetTextureCoordinatesAt(4, 32, 2, 11));

    CUtilStatistics.AddStatisticWithPM(
        "KnowledgeEarned", TextKnowledge, TextKPM, "EarnedResources",
        "ExtendedStatistics_Callback_KnowledgeEarned", "ExtendedStatistics_Callback_KnowledgeEarnedPerMinute"
    );
	CUtilStatistics.SetStatisticWidgetValues("normal",  "KnowledgeEarned", IconMatrix, GetTextureCoordinatesAt(4, 32, 0, 24));
	CUtilStatistics.SetStatisticWidgetValues("hovered", "KnowledgeEarned", IconMatrix, GetTextureCoordinatesAt(4, 32, 1, 24));
	CUtilStatistics.SetStatisticWidgetValues("pressed", "KnowledgeEarned", IconMatrix, GetTextureCoordinatesAt(4, 32, 2, 24));

    Overwrite.CreateOverwrite("GameCallback_SH_Logic_HonorGained", function(_PlayerID, _Amount)
        Overwrite.CallOriginal();
        if Stronghold.Statistic.Data[_PlayerID] and _Amount > 0 then
            local Current = Stronghold.Statistic.Data[_PlayerID].Resources.Honor[1];
            Stronghold.Statistic.Data[_PlayerID].Resources.Honor[1] = Current + _Amount;
        end
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Logic_ReputationGained", function(_PlayerID, _Amount)
        Overwrite.CallOriginal();
        if Stronghold.Statistic.Data[_PlayerID] then
            local Current = Stronghold.Statistic.Data[_PlayerID].Resources.Reputation[1];
            Stronghold.Statistic.Data[_PlayerID].Resources.Reputation[1] = Current + _Amount;
        end
    end);

    Overwrite.CreateOverwrite("GameCallback_SH_Logic_KnowledgeGained", function(_PlayerID, _Amount)
        Overwrite.CallOriginal();
        if Stronghold.Statistic.Data[_PlayerID] and _Amount > 0 then
            local Current = Stronghold.Statistic.Data[_PlayerID].Resources.Knowledge[1];
            Stronghold.Statistic.Data[_PlayerID].Resources.Knowledge[1] = Current + _Amount;
        end
    end);
end

