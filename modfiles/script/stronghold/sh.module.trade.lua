--- 
--- Trade Script
--- 

Stronghold = Stronghold or {};

Stronghold.Trade = Stronghold.Trade or {
    Data = {},
    Config = {},
    Text = {},
}

-- -------------------------------------------------------------------------- --
-- API

--- Alters the purchase price of the resource.
--- @param _PlayerID integer ID of player
--- @param _Resource integer Resource type
--- @param _Price    number Price factor
function SetPurchasePrice(_PlayerID, _Resource, _Price)
    Stronghold.Trade:ManipulateGoodPurchasePrice(_PlayerID, _Resource, _Price);
end

--- Alters the selling price of the resource.
--- @param _PlayerID integer ID of player
--- @param _Resource integer Resource type
--- @param _Price    number Price factor
function SetSellingPrice(_PlayerID, _Resource, _Price)
    Stronghold.Trade:ManipulateGoodSellPrice(_PlayerID, _Resource, _Price);
end

-- -------------------------------------------------------------------------- --
-- Callbacks

--- Triggered when resources are traded.
--- @param _PlayerID integer ID of player
--- @param _EntityID integer ID of building
--- @param _BuyType integer Resource type to buy
--- @param _BuyAmount integer Amount of purchased resource
--- @param _SellType integer Resource type to sell
--- @param _SellAmount integer Amount of sold resource
function GameCallback_SH_GoodsTraded(_PlayerID, _EntityID, _BuyType, _BuyAmount, _SellType, _SellAmount)
end

--- Triggered when the price for purchasing resources is calculated.
--- @param _PlayerID integer ID of player
--- @param _Resource integer Resource type
--- @return number Factor Min factor
function GameCallback_SH_Calculate_PurchaseMinPriceFactor(_PlayerID, _Resource)
    return Stronghold.Trade.Config[_Resource][1] or 0.75;
end

--- Triggered when the price for purchasing resources is calculated.
--- @param _PlayerID integer ID of player
--- @param _Resource integer Resource type
--- @return number Factor Max factor
function GameCallback_SH_Calculate_PurchaseMaxPriceFactor(_PlayerID, _Resource)
    return Stronghold.Trade.Config[_Resource][2] or 1.25;
end

--- Triggered when the price for selling resources is calculated.
--- @param _PlayerID integer ID of player
--- @param _Resource integer Resource type
--- @return number Factor Min factor
function GameCallback_SH_Calculate_SellMinPriceFactor(_PlayerID, _Resource)
    return Stronghold.Trade.Config[_Resource][3] or 0.75;
end

--- Triggered when the price for selling resources is calculated.
--- @param _PlayerID integer ID of player
--- @param _Resource integer Resource type
--- @return number Factor Max factor
function GameCallback_SH_Calculate_SellMaxPriceFactor(_PlayerID, _Resource)
    return Stronghold.Trade.Config[_Resource][4] or 1.25;
end

-- -------------------------------------------------------------------------- --
-- Main

function Stronghold.Trade:Install()
    for PlayerID = 1, GetMaxPlayers() do
        self.Data[PlayerID] = {};
    end
end

function Stronghold.Trade:OnSaveGameLoaded()
end

function Stronghold.Trade:OnGoodsTraded()
    local BuyType = Event.GetBuyResource();
    local BuyAmount = Event.GetBuyAmount();
    local SellType = Event.GetSellResource();
    local SellAmount = Event.GetSellAmount();
    local EntityID = Event.GetEntityID();
    local PlayerID = Logic.EntityGetPlayer(EntityID);

    local PurchasePrice = Logic.GetCurrentPrice(PlayerID, BuyType);
    Stronghold.Trade:ManipulateGoodPurchasePrice(PlayerID, BuyType, PurchasePrice);
    local SellPrice = Logic.GetCurrentPrice(PlayerID, SellType);
    Stronghold.Trade:ManipulateGoodSellPrice(PlayerID, SellType, SellPrice);

    GameCallback_SH_GoodsTraded(PlayerID, EntityID, BuyType, BuyAmount, SellType, SellAmount);
end

function Stronghold.Trade:ManipulateGoodPurchasePrice(_PlayerID, _Resource, _Price)
    local MinBuyCap = GameCallback_SH_Calculate_PurchaseMinPriceFactor(_PlayerID, _Resource);
    local MaxBuyCap = GameCallback_SH_Calculate_PurchaseMaxPriceFactor(_PlayerID, _Resource);
    Logic.SetCurrentPrice(_PlayerID, _Resource, math.max(math.min(_Price, MaxBuyCap), MinBuyCap));
end

function Stronghold.Trade:ManipulateGoodSellPrice(_PlayerID, _Resource, _Price)
    local MinSellCap = GameCallback_SH_Calculate_SellMinPriceFactor(_PlayerID, _Resource);
    local MaxSellCap = GameCallback_SH_Calculate_SellMaxPriceFactor(_PlayerID, _Resource);
    Logic.SetCurrentPrice(_PlayerID, _Resource, math.max(math.min(_Price, MaxSellCap), MinSellCap));
end

-- -------------------------------------------------------------------------- --

-- Restore last shown merchant offers
function Stronghold.Trade:OnMerchantSelected(_EntityID)
    local LastSelectedID = gvStronghold_LastSelectedEntity or 0;
    if XGUIEng.IsWidgetShown(gvGUI_WidgetID.TroopMerchant) == 1 then
        if LastSelectedID == _EntityID and Logic.IsHero(_EntityID) == 1 then
            XGUIEng.ShowAllSubWidgets(gvGUI_WidgetID.SelectionView, 0);
            XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionGeneric, 1);
            XGUIEng.ShowWidget(gvGUI_WidgetID.BackgroundFull, 1);
            XGUIEng.ShowAllSubWidgets(gvGUI_WidgetID.SelectionBuilding, 0);
            XGUIEng.ShowWidget(gvGUI_WidgetID.SelectionBuilding, 1);
            XGUIEng.ShowWidget(gvGUI_WidgetID.TroopMerchant, 1);
        end
    end
end

