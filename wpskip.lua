local switch_off = 0
local scripting_rc1 = rc:find_channel_for_option(300)

function update()
    if scripting_rc1:get_aux_switch_pos() == 2 then
        if switch_off == 1  then
            switch_off = 0
            if vehicle:get_mode() == 3 and arming:is_armed() then
                local mission_index = mission:get_current_nav_index()
                local mission_length = mission:num_commands() - 1
                if mission_length > 1 and mission_index < mission_length then
                    if mission:set_current_cmd(mission_index + 1) then
                        gcs:send_text(6, string.format("LUA: jumped to mission item %d", mission_index + 1))
                    else
                        gcs:send_text(6, "LUA: mission item jump failed")
                    end
                end
            end
        end
    else
        switch_off = 1
    end
  return update, 100
end

return update()