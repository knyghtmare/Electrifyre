local brazier_coords = {
    {18, 8}, {20, 9}, {20, 11},
    {18, 12}, {16, 9}, {16, 11}
} 
-- lock view
wesnoth.interface.lock(true)

for i = 1, #brazier_coords do

    local brazier = brazier_coords[i]
    local x_val = brazier[1]
    local y_val = brazier[2]

    wesnoth.interface.scroll_to_hex(
        brazier[1], brazier[2], false, true)

    -- explosion animation
    wesnoth.interface.add_hex_overlay(
        x_val, y_val, 
        {
            halo = "projectiles/fire-burst-small-[1~8].png:100"
        })
    wesnoth.interface.delay(500)
    -- explosion sound
    wesnoth.audio.play("fire.wav")
    wesnoth.interface.delay(500)
    wesnoth.interface.remove_hex_overlay(
        x_val, y_val,
        "projectiles/fire-burst-small-[1~8].png:100")
    -- ignite brazier
    wesnoth.current.map[brazier] = "Cud^Ebn"

    -- redraw the display
    wesnoth.wml_actions.redraw{}
    wesnoth.interface.delay(500)
end
-- unlock view
wesnoth.interface.lock(false)