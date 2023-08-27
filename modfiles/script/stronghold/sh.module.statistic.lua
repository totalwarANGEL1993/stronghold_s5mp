--- 
--- Statistics Fix
--- 

Stronghold = Stronghold or {};

Stronghold.Statistic = {
    Data = {},
}

function Stronghold.Statistic:Install()
    for i= 1, GetMaxPlayers() do
        self.Data[i] = {
            Technologies = {};
        };
    end
    Job.Second(function()
        Stronghold.Statistic:UpdateTechnologiesResearchedTooltip();
    end);
    self:OverwriteTechnologyResearched();
end

function Stronghold.Statistic:OnSaveGameLoaded()
end

function Stronghold.Statistic:OnTechnologyResearched(_PlayerID, _TechnologyType)
    local Time = math.floor(Logic.GetTime());
    if _TechnologyType > 0 and Time > 0 and _PlayerID ~= 17 then
        table.insert(self.Data[_PlayerID].Technologies, {
            Technology = _TechnologyType,
            Time = Time
        });
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
                    local Time = ConvertSecondsToString(self.Data[_PlayerID].Technologies[i].Time);
                    if i < 26 then
                        Text[1] = Text[1] .. Name .. " - " .. Time .. " @cr ";
                    elseif i > 25 and i < 51 then
                        Text[2] = Text[2] .. Name .. " - " .. Time .. " @cr ";
                    elseif i > 50 and i < 76 then
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

