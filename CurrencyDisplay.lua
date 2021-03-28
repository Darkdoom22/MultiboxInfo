local CurrencyDisplay = {}
local texts = require('texts')
require('strings')

function CurrencyDisplay.Constructor(settings, value)

    local currencyDisplay = {
        --wrap up windower text setting stuff for luls

        ["Settings"] = {
            ["pos"] = {--[[xy]]},
            ["text"] = {--[[font, size, alpha, red, green, blue, stroke{alpha, red, green, blue, width}, flags{bold}]]},
            ["bg"] = {--[[bg{alpha, red, green, blue}]]},
            ["flags"] = {--[[draggable]]},
        },

        ["Value"] = "",
        ["TextObject"] = {},
    }

    local function ColorText(color, text)
        if color then
            return string.format("\\cs(%s,%s,%s)%s", color.red, color.green, color.blue, text)
        end
    end

    function currencyDisplay:Show()
        self["TextObject"]:visible(true)       
    end
    --build and set full currency string with different colors for name and value
    --maybe this is easier? prob not lols
    function currencyDisplay:SetText(colorOne, textOne, colorTwo, textTwo, padding)

        if colorOne and textOne then
            local colorTwo = colorTwo or {red=243,green=255,blue=254}
            local textTwo = textTwo or ""

            local text = " " .. ColorText(colorOne, textOne) .. " " .. ColorText(colorTwo, textTwo):lpad(" ", padding)

            self["Value"] = text
            self["TextObject"]:text(text)

        end

    end

    function currencyDisplay:Offset(amount)

        self["Settings"]["pos"].x = amount.x
        self["Settings"]["pos"].y = amount.y
        self["TextObject"]:pos(amount.x, amount.y)

    end

    function currencyDisplay:Destroy()

        self = {}

    end

    local function Construct(settings, value)

        local this = currencyDisplay

        this["Settings"]["pos"] = settings.pos
        this["Settings"]["text"] = settings.text
        this["Settings"]["bg"] = settings.bg
        this["Settings"]["flags"] = settings.flags
        this["Value"] = value
        this["TextObject"] = texts.new(this["Settings"])
        this["TextObject"]:text(value)

        return this

    end

    return Construct(settings, value)

end

return CurrencyDisplay