local mod = {}

-- this is local variable that keeps a list of window IDs to cycle thru
local _windows = {}

function focusIfExist (id, index)
    win = hs.window.find(id)
    if win then
        win:focus()
    else
        if index ~= nil then
            table.remove(_windows, index)
            mod.focusNext()
        end
    end
end

function mod.focusNext ()
    local currentId = hs.window.focusedWindow():id()
    local found = false

    -- if there are no windows to cycle thru, don't do anything
    if #_windows > 0 then
        -- if there is only 1 window in the list, focus it
        if #_windows == 1 then
            focusIfExist(_windows[1])
        else
            -- there are more than 1 window in the list
            -- loop thru the list and find the currently focused window
            -- and focus the next one in the line
            for i, v in ipairs(_windows) do
                -- trying to match current window
                if v == currentId then
                    -- we are at the last element so we need
                    -- to focus the first window
                    if i == #_windows then
                        focusIfExist(_windows[1], i)
                    -- or we just focus the next window in the list
                    else
                        focusIfExist(_windows[i+1], i)
                    end
                    found = true
                end
            end
            -- currently focused window is not in the list so just
            -- focus the first window in the list
            if not found then
                hs.window.find(_windows[1]):focus()
            end
        end
    end
end

function mod.toggleWindow ()
    local currentId = hs.window.focusedWindow():id()
    local removed = false

    for i, v in ipairs(_windows) do
        if v == currentId then
            table.remove(_windows, i)
            removed = true
        end
    end
    if not removed then
        table.insert(_windows, currentId)
        hs.console.printStyledtext(currentId)
    end
end

function mod.debug ()
    for i, v in ipairs(_windows) do
        local win = hs.window.find(v)
        if win then
            local title = win:id() .. ' ' .. win:title() ..
                ' (' .. win:application():name() .. ')'
            hs.console.printStyledtext(title)
        else
            table.remove(_windows, i)
        end
    end
end

function mod.registerDefaultBindings (key)
    hs.hotkey.bind({"cmd"}, key, mod.focusNext)
    hs.hotkey.bind({"cmd", "alt"}, key, mod.toggleWindow)
    hs.hotkey.bind({"cmd", "ctrl", "alt"}, key, mod.debug)
end

return mod
