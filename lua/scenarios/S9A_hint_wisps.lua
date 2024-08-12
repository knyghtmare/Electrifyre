local device_coords = {
    {25, 29}, {21, 36}, {10, 39},
    {5, 22}, {42, 21}, {41, 39}
}

for i = 1, #device_coords do
    local device = device_coords[i]
    local x_val = device[1]
    local y_val = device[2]

    -- scroll to the Seer
    -- wesnoth.interface.scroll_to_hex(
    --     28, 53, false, true)

    -- animate her
    seer_unit = wesnoth.units.find_on_map{ id = 'Vanleneada' }
    animation = wesnoth.units.create_animator() 

    animation:add(seer_unit[1], "attack", "miss")
    animation:run()

    animation:clear()

    wesnoth.interface.delay(400)

    -- scroll to hex
    wesnoth.interface.scroll_to_hex(
        device[1], device[2], false, true)

    -- play magic
    wesnoth.audio.play("magic-faeriefire-miss.ogg")

    wesnoth.sides.remove_shroud(1, {{device[1]-1,device[2]-1}})
    wesnoth.sides.remove_shroud(1, {{device[1]-1,device[2]+1}})
    wesnoth.sides.remove_shroud(1, {{device[1]-1,device[2]}})
    wesnoth.sides.remove_shroud(1, {{device[1],device[2]-1}})
    wesnoth.sides.remove_shroud(1, {{device[1],device[2]+1}})
    wesnoth.sides.remove_shroud(1, {{device[1]+1,device[2]-1}})
    wesnoth.sides.remove_shroud(1, {{device[1]+1,device[2]}})
    wesnoth.sides.remove_shroud(1, {{device[1]+1,device[2]+1}})
    wesnoth.sides.remove_shroud(1, {{device[1],device[2]}})

    wesnoth.wml_actions.redraw{}
    wesnoth.interface.delay(400)
end