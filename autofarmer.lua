script_name("Autofarmer")
script_authors("Laura A. Yamaguchi")
script_version("0.0.1")

require "moonloader"
require "sampfuncs"
local sampev = require "lib.samp.events"

local enabled = true
local mute = false

function cmd_autofarmer_toogle()
    enabled = not enabled
    if enabled then
        sampAddChatMessage("{FFFFFF}Auto farm: {008000}ON", -1)
    else
        sampAddChatMessage("{FFFFFF}Auto farm: {800000}OFF", -1)
    end
end

function cmd_autofarmer_mute_toogle()
    mute = not mute
    if mute then
        sampAddChatMessage("{FFFFFF}Auto farm mute command: {008000}ON", -1)
    else
        sampAddChatMessage("{FFFFFF}Auto farm mute command: {800000}OFF", -1)
    end
end

function main()
    repeat wait(50) until isSampAvailable()
    repeat wait(50) until string.find(sampGetCurrentServerName(), "Horizon Roleplay")

    sampAddChatMessage("{FFFFFF}Auto farm. {74B9FF}/autofarm {FFFFFF}to enable/disable", -1)

    sampRegisterChatCommand("af", cmd_autofarmer_toogle)
    sampRegisterChatCommand("afmute", cmd_autofarmer_mute_toogle)
end

function sampev.onServerMessage(colorid, text)
    if not enabled then
        return
    end

    if text:match("* You harvested 8 out of the 8 needed crops. Get inside your truck.") and colorid == 0x33CCFFAA then
        lua_thread.create(function()
            wait(300)
            setGameKeyState(15, 255)
            addOneOffSound(0.0, 0.0, 0.0, 1137)
        end)

        if mute then
            return false
        end
    end
    
    if text:find("* You received ") and text:find(" for delivering the harvest.") and colorid == 0x33CCFFAA then
        sampSendChat("/farm")

        if mute then
            return false
        end
    end
    
    if text:match("* You have arrived at your designated farming spot. Type /harvest to harvest some crops") then
        taskLeaveAnyCar(PLAYER_PED)
        lua_thread.create(function()
            repeat wait(50) until not isCharInAnyCar(PLAYER_PED)
            sampSendChat("/harvest")
        end)

        if mute then
            return false
        end
    end

    if string.find(text, "Type /harvest to harvest some more crops") and not isCharInAnyCar(PLAYER_PED) then
        sampSendChat("/harvest")

        if mute then
            return false
        end
    end

    if mute then
        if string.find(text, "You have harvested some crops. Return them to your truck.") then
            return false
        elseif string.find(text, "You are now in the progress of harvesting some crops.") then
            return false
        elseif string.find(text, "You have a truck full of harvested crops. Deliver the harvest at the barn.") then
            return false
        elseif string.find(text, "TIP: Drive to the barn") then
            return false
        elseif string.find(text, "TIP: Drive to your designated farming spot") then
            return false
        elseif string.find(text, "TIP: Stay close to this area. You are not allowed to harvest too far from here.") then
            return false
        elseif string.find(text, "You have now started farming. You must load up this vehicle with the harvest.") then
            return false
        end
    end
end
