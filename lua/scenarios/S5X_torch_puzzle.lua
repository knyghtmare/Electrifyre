-- 05X_torch_puzzle.lua
-- Torch sequence puzzle for 05X_Ephemeral_Calm
--
-- Four braziers (^Eb = unlit, ^Ebi = lit) must be lit in a fixed order.
-- * Stepping on an unlit brazier lights it.
-- * If it is the next brazier in the sequence, it stays lit.
-- * If it is the wrong one, all braziers are extinguished and the puzzle resets.
-- * When the whole sequence is done, all braziers stay lit and the
--   "s5x_puzzle_open_gates" event is fired.
--
-- Progress is stored in WML variables, so it is save/load safe.

local _ = wesnoth.textdomain "wesnoth-Electrifyre"

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------

local UNLIT = "Exos^Eb"
local LIT   = "Exos^Ebn"

-- The four brazier hexes on the map (game coordinates).
local BRAZIERS = {
    { x =  6, y = 10 },
    { x = 10, y = 11 },
    { x =  6, y = 14 },
    { x = 10, y = 15 },
}

-- The correct lighting order, as { x, y } pairs.
local SEQUENCE = {
    {  6, 10 },
    { 10, 15 },
    { 10, 11 },
    {  6, 14 },
}

local SIDE_ALLOWED  = 1                         -- only the player's side can light torches
local VAR_PROGRESS  = "s5x_torch_progress"      -- how many torches are correctly lit so far
local VAR_SOLVED    = "s5x_torch_solved"        -- set to yes once solved
local EVENT_SOLVED  = "s5x_puzzle_open_gates"   -- already exists in the scenario

local SOUND_LIGHT   = "fire.wav"                -- swap for any sound you prefer
local SOUND_FAIL    = "water-blast.wav"         -- swap for any sound you prefer

----------------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------------

-- Position of (x, y) in SEQUENCE, or nil if it is not a puzzle brazier.
local function sequence_index(x, y)
    for i, pos in ipairs(SEQUENCE) do
        if pos[1] == x and pos[2] == y then
            return i
        end
    end
    return nil
end

-- Set a full terrain code on a hex (base + overlay).
local function set_overlay(x, y, terrain)
    wesnoth.wml_actions.terrain {
        x = x,
        y = y,
        terrain = terrain,
    }
end

local function set_all(overlay)
    for _, b in ipairs(BRAZIERS) do
        set_overlay(b.x, b.y, overlay)
    end
end

local function get_progress()
    return tonumber(wml.variables[VAR_PROGRESS]) or 0
end

local function set_progress(n)
    wml.variables[VAR_PROGRESS] = n
end

local function is_solved()
    return wml.variables[VAR_SOLVED] == true
        or wml.variables[VAR_SOLVED] == "yes"
end

local function play(name)
    wesnoth.wml_actions.sound { name = name }
end

----------------------------------------------------------------------
-- PUZZLE LOGIC
----------------------------------------------------------------------

local function reset_puzzle()
    play(SOUND_FAIL)
    wesnoth.interface.delay(400)
    set_all(UNLIT)
    set_progress(0)
    wesnoth.wml_actions.redraw {}

    wesnoth.wml_actions.message {
        speaker = "narrator",
        message = _"The flames sputter and die out. The torches must be lit in a different order.",
        image = "wesnoth-icon.png",
    }
end

local function solve_puzzle()
    set_progress(#SEQUENCE)
    wml.variables[VAR_SOLVED] = true   -- stored as "yes"

    wesnoth.wml_actions.redraw {}
    wesnoth.interface.delay(500)

    wesnoth.wml_actions.message {
        speaker = "narrator",
        message = _"All four torches burn steadily. Somewhere in the distance, a mechanism grinds into motion.",
        image = "wesnoth-icon.png",
    }

    -- equivalent to [fire_event] name="s5x_puzzle_open_gates" [/fire_event]
    -- (the event itself is defined in the scenario .cfg)
    wesnoth.wml_actions.fire_event { name = EVENT_SOLVED }
end

local function on_torch_stepped(x, y)
    local idx = sequence_index(x, y)
    if not idx then return end                 -- not a brazier

    local progress = get_progress()

    -- Already lit and part of the correct chain: ignore (e.g. unit standing on it)
    if idx <= progress then return end

    -- Light the torch the unit just stepped on
    set_overlay(x, y, LIT)
    play(SOUND_LIGHT)
    wesnoth.wml_actions.redraw {}

    if idx == progress + 1 then
        -- Correct torch
        progress = progress + 1
        set_progress(progress)

        if progress >= #SEQUENCE then
            solve_puzzle()
        end
    else
        -- Wrong torch: everything goes out
        reset_puzzle()
    end
end

----------------------------------------------------------------------
-- EVENT HOOK
----------------------------------------------------------------------

-- wesnoth.log("warning", "05X torch puzzle script loaded")

-- Called from a WML [event] name=moveto (see the scenario snippet).
-- Using a WML event instead of game_events.on_event, because the Lua-registered
-- handler never fired in this scenario.
function s5x_torch_moveto()
    local ctx = wesnoth.current.event_context
    local x, y = ctx.x1, ctx.y1
    -- wesnoth.log("warning", "torch moveto " .. tostring(x) .. "," .. tostring(y))

    if is_solved() then return end

    local unit = wesnoth.units.get(x, y)
    if not unit or unit.side ~= SIDE_ALLOWED then return end

    on_torch_stepped(x, y)
end
