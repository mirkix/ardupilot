local THR_SERVO_1 = 6 -- SERVO7
local THR_SERVO_2 = 7 -- SERVO8
local THR_SERVO = 70

local PARAM_TABLE_KEY = 25
assert(param:add_table(PARAM_TABLE_KEY, "CA_", 30), 'could not add param table')

assert(param:add_param(PARAM_TABLE_KEY, 1,  'VFWD_UP', 0.15), 'could not add param1')
assert(param:add_param(PARAM_TABLE_KEY, 2,  'VFWD_DOWN', 0.05), 'could not add param2')
assert(param:add_param(PARAM_TABLE_KEY, 3,  'VFWD_DEFAULT', 0.1), 'could not add param3')
assert(param:add_param(PARAM_TABLE_KEY, 4,  'DCRT_UP', 150.0), 'could not add param4')
assert(param:add_param(PARAM_TABLE_KEY, 5,  'DCRT_DOWN', -100.0), 'could not add param5')
assert(param:add_param(PARAM_TABLE_KEY, 6,  'DCRT_AUTO', 0.0), 'could not add param6')
assert(param:add_param(PARAM_TABLE_KEY, 7,  'BOOST_PCT', 0.0), 'could not add param7')
assert(param:add_param(PARAM_TABLE_KEY, 8,  'TRA_THR_PCT', 0.0), 'could not add param8')

local CA_VFWD_UP = Parameter()
CA_VFWD_UP:init('CA_VFWD_UP')

local CA_VFWD_DOWN = Parameter()
CA_VFWD_DOWN:init('CA_VFWD_DOWN')

local CA_VFWD_DEFAULT = Parameter()
CA_VFWD_DEFAULT:init('CA_VFWD_DEFAULT')

local CA_DCRT_UP = Parameter()
CA_DCRT_UP:init('CA_DCRT_UP')

local CA_DCRT_DOWN = Parameter()
CA_DCRT_DOWN:init('CA_DCRT_DOWN')

local CA_DCRT_AUTO = Parameter()
CA_DCRT_AUTO:init('CA_DCRT_AUTO')

local CA_BOOST_PCT = Parameter()
CA_BOOST_PCT:init('CA_BOOST_PCT')

local CA_TRA_THR_PCT = Parameter()
CA_TRA_THR_PCT:init('CA_TRA_THR_PCT')

local Q_VFWD_GAIN = Parameter()
Q_VFWD_GAIN:init('Q_VFWD_GAIN')

if((SRV_Channels:channel_function(THR_SERVO_1) == THR_SERVO) and (SRV_Channels:channel_function(THR_SERVO_2) == THR_SERVO)) then
    gcs:send_text(6, "THR_SERVO check ok")
else
    gcs:send_text(6, "THR_SERVO check NOT ok")
end

function transition_throttle()
    if vehicle:get_likely_flying() and quadplane:in_transition() and (CA_TRA_THR_PCT:get() > 0.1) and (vehicle:get_mode() ~= 21) then
        local pwm_value = math.floor(1000 + (CA_TRA_THR_PCT:get() * 10.0))
        if (SRV_Channels:channel_function(THR_SERVO_1) == THR_SERVO) and (SRV_Channels:channel_function(THR_SERVO_2) == THR_SERVO) then
            SRV_Channels:set_output_pwm_chan_timeout(THR_SERVO_1, pwm_value, 600)
            SRV_Channels:set_output_pwm_chan_timeout(THR_SERVO_2, pwm_value, 600)
        end
    end
    return dcrt_adjust, 500
end

function dcrt_adjust()
    if quadplane:in_vtol_mode() and vehicle:get_likely_flying() and CA_DCRT_AUTO:get() > 0.1 then
        local dcrt = quadplane:get_vel_target_z_cms()
--        gcs:send_text(0, "dCRT: " .. dcrt)
--        gcs:send_text(0, "Q_VFWD_GAIN: " .. Q_VFWD_GAIN:get())
        if dcrt > CA_DCRT_UP:get() then
            Q_VFWD_GAIN:set(CA_VFWD_UP:get())
            quadplane:set_boost_pct(CA_BOOST_PCT:get())
        elseif dcrt <  CA_DCRT_DOWN:get() then
            Q_VFWD_GAIN:set(CA_VFWD_DOWN:get())
            quadplane:set_boost_pct(0.0)

        else
            Q_VFWD_GAIN:set(CA_VFWD_DEFAULT:get())
            quadplane:set_boost_pct(0.0)
        end
    end
    return transition_throttle, 1
end

gcs:send_text(6, "Start CarryAir LUA Script")

return dcrt_adjust, 1000
