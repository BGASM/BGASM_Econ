local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
    typedef uint64_t TradeID;
    typedef uint64_t UniverseID;
    typedef struct {
        const char* name;
        float hull;
        float shield;
        bool hasShield;
    } ComponentDetails;
    typedef struct {
        const char* factionName;
        const char* factionIcon;
    } FactionDetails;
    typedef struct {
        const char* wareid;
        bool isSellOffer;
        UITradeOfferStatData* data;
        uint32_t numdata;
    } UITradeOfferStat;
    typedef struct {
        const char* wareid;
        uint32_t amount;
    } UIWareAmount;
    typedef struct {
        const char* ClusterName;
        const char* SectorName;
        const char* ZoneName;
        bool isLocalHighway;
        bool isSuperHighway;
    } ZoneDetails;
    bool GetContainerWareIsBuyable(UniverseID containerid, const char* wareid);
    bool GetContainerWareIsSellable(UniverseID containerid, const char* wareid);
    bool IsBuyOffer(UniverseID tradeofferdockid);
    bool IsKnownToPlayer(UniverseID componentid);
    bool IsSellOffer(UniverseID componentid);
    bool IsShip(const UniverseID componentid);
    bool IsStation(const UniverseID componentid);
    ComponentDetails GetComponentDetails(const UniverseID componentid);
    const char* GetComponentClass(UniverseID componentid);
    const char* GetComponentName(UniverseID componentid);
    const char* GetFactionName(const UniverseID componentid);
    double GetCurrentGameTime();
    FactionDetails GetOwnerDetails(UniverseID componentid);
    uint32_t GetNumWares(const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
    uint32_t GetTradeWares(const char** result, uint32_t resultlen);
    uint32_t GetWares(const char** result, uint32_t resultlen, const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
    UniverseID GetContextByClass(UniverseID componentid, const char* classname, bool includeself);
    UniverseID GetPlayerID(void);
    UniverseID GetPlayerObjectID(void);
    UniverseID GetPlayerOccupiedShipID(void);
    UniverseID GetPlayerZoneID();
]]
local Lib = require ("extensions.sn_mod_support_apis.lua_interface").Library
local inspect = require ("extensions.BGASM_Econ.lua.inspect")
local json = require ("extensions.BGASM_Econ.lua.json.lunajson")
local BG = {}
local L = {}
local dbg = "BGASM>Scan_Econ: "

local function Init()
    BG.player_id = ConvertStringTo64Bit(tostring(C.GetPlayerID()))

    -- DebugError(dbg..jstr)

    -- Lib.Print_Table(BG.station_directory, dbg.."Station Directory!")
    -- Lib.Print_Table(BG.stationtable, dbg.." Station ID List")

    RegisterEvent("Scan_Econ.Get_Sample", L.Get_Sample)
    RegisterEvent("Scan_Econ.Get_HB", L.Get_HB)
end

function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end

function BG.getStationDirectory(stations)
    local directory = {}
    for _, station in ipairs(stations) do
        local a, b, c, d, e = GetComponentData(station, "name", "ownername", "sector", "cluster", "isplayerowned")
        if (e==true) then goto continue end
        local tradedata = GetTradeList(station, true)
        if (getTableSize(tradedata) <= 0) then goto continue end
        local data = {
            ["id"]          = station,
            ["name"]        = a,
            ["ownername"]   = b,
            ["sector"]      = c,
            ["cluster"]     = d,
            ["trade"]       = {}
        }
        for k,v in pairs(tradedata) do
            if (v['isplayer']==true or v["ismissionoffer"]==true) then goto tcontinue end

            local trade = {
                ["ware"]        = v["name"],
                ["amount"]      = v["amount"],
                ["desire"]      = v["desiredamount"],
                ["buy"]         = v["isbuyoffer"],
                ["sell"]        = v["isselloffer"],
                ["price"]       = v['price'],
                ["total"]       = v['total price']
            }
            -- Lib.Print_Table(trade, dbg.."Station Directory!")
            table.insert(data["trade"], trade)
            ::tcontinue::
        end
        Lib.Print_Table(data, dbg.."Station Directory!")
        directory[#directory+1] = data
        ::continue::
    end
    return directory
end

function BG.getWareData()
    local economyWares = {}
    local n = C.GetNumWares("economy", false, "", "")
    local buf = ffi.new("const char*[?]", n)
    n = C.GetWares(buf, n, "economy", false, "", "")
    for i = 0, n - 1 do
        local ware = ffi.string(buf[i])
        local e, f, g, h = GetWareData(ware, "name", "avgprice", "minprice", "maxprice")
        local t_ware = {
            ["name"]        = e,
            ["average"]     = f,
            ["minprice"]    = g,
            ["maxprice"]    = h
        }
        economyWares[#economyWares+1] = t_ware
    end
    return economyWares
end

function BG.getStationTable(sectors)
    local results, flat_sec = {}, {}
    for _, sec in ipairs(sectors) do
        results[#results+1] = GetContainedStations(sec, false, false)
    end

    local function stationFlatten(stations)
        for _, station in ipairs(stations) do
            if type(station) == "table" then
                stationFlatten(station)
            else
                local stat = ConvertIDTo64Bit(station)
                local known = C.IsKnownToPlayer(stat)
                if (known) then flat_sec[#flat_sec+1] = stat end

            end
        end
    end

    stationFlatten(results)
    return flat_sec
end

function BG.getSectorId(clusters)
    DebugError(dbg.."In getSectorId()")
    local results, flat_sec = {}, {}
    for _, cluster in ipairs(clusters) do
        results[#results+1] = GetSectors(cluster)
    end

    local function sectorFlatten(sectors)
        for _, sec in ipairs(sectors) do
            if type(sec) == "table" then
                sectorFlatten(sec)
            else
                flat_sec[#flat_sec+1] = ConvertIDTo64Bit(sec)
            end
        end
    end

    sectorFlatten(results)
    return flat_sec
end

function BG.getClusterId()
    DebugError(dbg.." In getClusterId()")
    local clusters = {}
    for _, cluster in pairs(GetClusters()) do
        clusters[#clusters+1] = ConvertIDTo64Bit(cluster)
    end
    return clusters
end

function BG.fire()
    BG.stationtable = BG.getStationTable(BG.getSectorId(BG.getClusterId()))
    local to_json = {
        ["gametime"]    = C.GetCurrentGameTime(),
        ["warelist"]    = BG.getWareData(),
        ["stations"]    = BG.getStationDirectory(BG.stationtable)
    }
    -- local out = inspect.inspect(to_json)
    local jstr = json.encode(to_json)
    return jstr
end
-- Simple sampler, returning framerate and gametime.

function L.Get_Sample()
    AddUITriggeredEvent("Scan_Econ", "Sample", {
        trade           = BG.fire(),
        -- nut             = "Test2"
    })
    DebugError(dbg.."Fired Sample Call")
end

-- Simple sampler, returning framerate and gametime.
function L.Get_HB()
    AddUITriggeredEvent("Scan_Econ", "Sample", {
        trade           = "HB",
        nut             = "HB2"
    })
end


Init()

return