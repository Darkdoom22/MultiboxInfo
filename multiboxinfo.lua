_addon.name = "MultiboxInfo"
_addon.author = "Uwu/Darkdoom"
_addon.version = "1.0"

local texts = require('texts')
local packets = require('packets')
local currencyDisplay = require 'CurrencyDisplay'
require('tables')
require('DefaultSettings')

local multiboxInfo = {

    ["PlayerCount"] = 0,
    ["BoxCount"] = 0,
    ["Boxes"] = T{},
    ["Currencies"] = {
        ["Gil"] = 0,
        ["Inventory"] = 0,
        ["Sparks"] = 0,
        ["Accolades"] = 0,
    },
    ["Timers"] = {
        ["General"] = os.clock(),
        ["Inject"] = os.clock(),
        ["Delay"] = 1,
        ["CurrencyDelay"] = 60,
    },
    ["OtherInstances"] = T{},--[[{
        ["Boxes"] = {
            this is where windower text objects get put 
        },
        ["Name"] = "",
        ["Currencies"] = {
            ["Gil"] = 0,
            ["Inventory"] = 0,
            ["Sparks"] = 0,
            ["Accolades"] = 0,
        },
    },]]
}

local function insertCommas(string)
    local formatted = string
    while true do  
      formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
      if (k==0) then
        break 
      end
    end
    return formatted
end

function multiboxInfo:SendIPC()

    local name = windower.ffxi.get_player().name
    local ipcStringHeader = string.format("%s:", name)
    local ipcString = ipcStringHeader

    for k,v in pairs(self["Currencies"]) do

        ipcString = ipcString .. k .. ":" .. v .. ":"
        
    end

    --print(ipcString)
    windower.send_ipc_message(ipcString)
end

function multiboxInfo:HandlePacketCurrencies(data)

    if data then

        local currenciesUpdate = packets.parse('incoming', data)
        --if we make the table names match can replace this with a for loop 
        --and just replace the full names with shorthand later, easier to add more currencies
        self["Currencies"]["Sparks"] = currenciesUpdate["Sparks of Eminence"]
        self["Currencies"]["Accolades"] = currenciesUpdate["Unity Accolades"]

    end

end

function multiboxInfo:UpdateLocalCurrencies()

    self["Currencies"]["Inventory"] = windower.ffxi.get_items().inventory.count .. "/" .. windower.ffxi.get_items().inventory.max
    self["Currencies"]["Gil"] = insertCommas(tostring(windower.ffxi.get_items().gil))
    self["Timers"]["General"] = os.clock()
    
    if(os.clock() - self["Timers"]["Inject"] > self["Timers"]["CurrencyDelay"])then

        windower.packets.inject_outgoing(0x10f,'0000')

        self["Timers"]["Inject"] = os.clock()

    end

end

function multiboxInfo:UpdateBoxes()

    local lightBlue = {red=74,green=246,blue=223}
    local offWhite = {red=243,green=255,blue=254}

    for k,v in pairs(self["Boxes"]) do
        if(self["Boxes"][k]["origin"] == "Local")then
            
            if(self["Boxes"][k]["type"] == "Name")then
                self["Boxes"][k]["obj"]:SetText(offWhite, windower.ffxi.get_player().name, _, _, 0)
            
            elseif(self["Boxes"][k]["type"] == "Sparks")then
                self["Boxes"][k]["obj"]:SetText(lightBlue, "Sparks", offWhite, multiboxInfo["Currencies"]["Sparks"], 10)
            
            elseif(self["Boxes"][k]["type"] == "Accolades")then
                self["Boxes"][k]["obj"]:SetText(lightBlue, "Accolades", offWhite, multiboxInfo["Currencies"]["Accolades"], 10)

            elseif(self["Boxes"][k]["type"] == "Gil")then
                self["Boxes"][k]["obj"]:SetText(lightBlue, "Gil", offWhite, multiboxInfo["Currencies"]["Gil"], 10)

            elseif(self["Boxes"][k]["type"] == "Inv")then
                self["Boxes"][k]["obj"]:SetText(lightBlue, "Inventory", offWhite, multiboxInfo["Currencies"]["Inventory"], 1)
                
            end

        end
        --print(self["Boxes"][k]["obj"]["Value"])
    end

    for k,v in pairs(self["OtherInstances"]) do

        local instance = v

        for k,v in pairs(self["OtherInstances"][k]["Boxes"]) do

            if(v["type"] == "Name")then
                v["obj"]:SetText(offWhite, instance["Name"], _, _, 1)
                
            elseif(v["type"] == "Sparks")then
                v["obj"]:SetText(lightBlue, "Sparks", offWhite, instance["Currencies"]["Sparks"], 10)
            
            elseif(v["type"] == "Accolades")then
                v["obj"]:SetText(lightBlue, "Accolades", offWhite, instance["Currencies"]["Accolades"], 10)

            elseif(v["type"] == "Gil")then
                v["obj"]:SetText(lightBlue, "Gil", offWhite, instance["Currencies"]["Gil"], 10)

            elseif(v["type"] == "Inv")then
                v["obj"]:SetText(lightBlue, "Inventory", offWhite, instance["Currencies"]["Inventory"], 1)

            end

        end
       
    end

end


function multiboxInfo:InitLocalBoxes()

    local name = windower.ffxi.get_player().name
    local lightBlue = {red=74,green=246,blue=223}
    local offWhite = {red=243,green=255,blue=254}
    local localName = currencyDisplay.Constructor(DefaultSettings, name)
    localName:Show()
    self["Boxes"]:insert({obj=localName, type="Name", origin="Local"})

    local instanceSparks = currencyDisplay.Constructor(DefaultSettings, "Sparks")
    instanceSparks:Offset({x=DefaultSettings.pos.x, y=DefaultSettings.pos.y+25})
    instanceSparks:SetText(lightBlue, "Sparks", offWhite, multiboxInfo["Currencies"]["Sparks"], 10)
    instanceSparks:Show()
    self["Boxes"]:insert({obj=instanceSparks, type="Sparks", origin="Local"})

    local instanceAccolades = currencyDisplay.Constructor(DefaultSettings, "Accolades")
    instanceAccolades:Offset({x=DefaultSettings.pos.x, y=DefaultSettings.pos.y+25})
    instanceAccolades:SetText(lightBlue, "Accolades", offWhite, multiboxInfo["Currencies"]["Accolades"], 10)
    instanceAccolades:Show()
    self["Boxes"]:insert({obj=instanceAccolades, type="Accolades", origin="Local"})

    local instanceGil = currencyDisplay.Constructor(DefaultSettings, "Gil")
    instanceGil:Offset({x=DefaultSettings.pos.x, y=DefaultSettings.pos.y+25})
    instanceGil:SetText(lightBlue, "Gil", offWhite, multiboxInfo["Currencies"]["Gil"], 10)
    instanceGil:Show()
    self["Boxes"]:insert({obj=instanceGil, type="Gil", origin="Local"})

    local instanceInv = currencyDisplay.Constructor(DefaultSettings, "Inv")
    instanceInv:Offset({x=DefaultSettings.pos.x, y=DefaultSettings.pos.y+25})
    instanceInv:SetText(lightBlue, "Inventory", offWhite, multiboxInfo["Currencies"]["Inventory"], 1)
    instanceInv:Show()
    self["Boxes"]:insert({obj=instanceInv, type="Inv", origin="Local"})

end

--ty stack overflow
local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function multiboxInfo:ReceiveIPC(msg)

    local needCreate = true

    if(msg)then

        local splitMsg = split(msg, ":")

        for k,v in pairs(splitMsg) do
          --  print(k,v)
        end

        for k,v in pairs(self["OtherInstances"]) do
            --print(v["Name"])
            if v["Name"] == splitMsg[1] then
                needCreate = false
                v["Currencies"]["Gil"] = splitMsg[3]
                v["Currencies"]["Inventory"] = splitMsg[9]
                v["Currencies"]["Sparks"] = splitMsg[7]
                v["Currencies"]["Accolades"] = splitMsg[5]
            end

        end

        if(needCreate == true) then

            local buildInstance = T{

                ["Name"] = splitMsg[1],
                ["Currencies"] = {
                    ["Gil"] = splitMsg[3],
                    ["Inventory"] = splitMsg[9],
                    ["Sparks"] = splitMsg[7],
                    ["Accolades"] = splitMsg[5],
                },
                ["Boxes"] = T{},

            }

            local lightBlue = {red=74,green=246,blue=223}
            local offWhite = {red=243,green=255,blue=254}
        

            local instanceName = currencyDisplay.Constructor(DefaultSettings, buildInstance["Name"])
            instanceName:Offset({x=DefaultSettings.pos.x+150, y=DefaultSettings.pos.y-100})
            instanceName:Show()
            buildInstance["Boxes"]:insert({obj=instanceName, type="Name", origin="Remote"})
        
            local instanceSparks = currencyDisplay.Constructor(DefaultSettings, "Sparks")
            instanceSparks:Offset({x=DefaultSettings.pos.x, y=DefaultSettings.pos.y+25})
            instanceSparks:SetText(lightBlue, "Sparks", offWhite, buildInstance["Currencies"]["Sparks"], 10)
            instanceSparks:Show()
            buildInstance["Boxes"]:insert({obj=instanceSparks, type="Sparks", origin="Remote"})
        
            local instanceAccolades = currencyDisplay.Constructor(DefaultSettings, "Accolades")
            instanceAccolades:Offset({x=DefaultSettings.pos.x, y=DefaultSettings.pos.y+25})
            instanceAccolades:SetText(lightBlue, "Accolades", offWhite, buildInstance["Currencies"]["Accolades"], 10)
            instanceAccolades:Show()
            buildInstance["Boxes"]:insert({obj=instanceAccolades, type="Accolades", origin="Remote"})
        
            local instanceGil = currencyDisplay.Constructor(DefaultSettings, "Gil")
            instanceGil:Offset({x=DefaultSettings.pos.x, y=DefaultSettings.pos.y+25})
            instanceGil:SetText(lightBlue, "Gil", offWhite, buildInstance["Currencies"]["Gil"], 10)
            instanceGil:Show()
            buildInstance["Boxes"]:insert({obj=instanceGil, type="Gil", origin="Remote"})
        
            local instanceInv = currencyDisplay.Constructor(DefaultSettings, "Inv")
            instanceInv:Offset({x=DefaultSettings.pos.x, y=DefaultSettings.pos.y+25})
            instanceInv:SetText(lightBlue, "Inventory", offWhite, buildInstance["Currencies"]["Inventory"], 1)
            instanceInv:Show()
            buildInstance["Boxes"]:insert({obj=instanceInv, type="Inv", origin="Remote"})

            self["OtherInstances"]:insert(buildInstance)

        end

    end

end

windower.register_event('ipc message', function(msg)

    multiboxInfo:ReceiveIPC(msg)

end)

windower.register_event('incoming chunk', function(id, data)

    if id == 0x113 then

        multiboxInfo:HandlePacketCurrencies(data)

    end

end)

windower.register_event('load', function()

    multiboxInfo:SendIPC()
    multiboxInfo:InitLocalBoxes()
    multiboxInfo:UpdateLocalCurrencies()
    windower.packets.inject_outgoing(0x10f,'0000')

end)

windower.register_event('prerender', function()

    if(os.clock() - multiboxInfo["Timers"]["General"] > multiboxInfo["Timers"]["Delay"])then

        multiboxInfo:UpdateLocalCurrencies()
        multiboxInfo:UpdateBoxes()
        multiboxInfo:SendIPC()

        multiboxInfo["Timers"]["General"] = os.clock()

    end

end)