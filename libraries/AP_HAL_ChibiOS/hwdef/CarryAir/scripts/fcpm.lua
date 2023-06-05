gcs:send_text(6,"Start FCPM LUA script")

local PARAM_TABLE_KEY = 26
assert(param:add_table(PARAM_TABLE_KEY, "FCPM_", 10), 'could not add param table')

assert(param:add_param(PARAM_TABLE_KEY, 1,  'ENABLE', 0.0), 'could not add ENABLE')
assert(param:add_param(PARAM_TABLE_KEY, 2,  'SLAVE_ID', 1.0), 'could not add SLAVE_ID')
assert(param:add_param(PARAM_TABLE_KEY, 3,  'LOGGING', 1.0), 'could not add LOGGING')
assert(param:add_param(PARAM_TABLE_KEY, 4,  'GCS', 1.0), 'could not add GCS')


local FCPM_ENABLE = Parameter()
FCPM_ENABLE:init('FCPM_ENABLE')

local FCPM_SLAVE_ID = Parameter()
FCPM_SLAVE_ID:init('FCPM_SLAVE_ID')

local FCPM_LOGGING = Parameter()
FCPM_LOGGING:init('FCPM_LOGGING')

local FCPM_GCS = Parameter()
FCPM_GCS:init('FCPM_GCS')

if FCPM_ENABLE:get() < 0.5 then
    gcs:send_text(6,"FCPM LUA script disabled")
    return
end

local driver = CAN.get_device(20)

local cyclic_counter = 0
local fcpm_state = 0
local tank_level = 0.0
local battery_volltage = 0.0
local output_power = 0
local spm_input_power = 0
local battery_power = 0

local gcs_counter = 0

local log_data = {}

if not driver then
    gcs:send_text(0,"No FCPM CAN interface found")
    return
end

function log()
    log_data = { cyclic_counter, fcpm_state, tank_level, battery_volltage, output_power, spm_input_power, battery_power}
    logger:write("FCPM",'Count,State,Tank,BattV,OutputP,InputP,BattP','fffffff',table.unpack(log_data))
end

function gcs_send()
    gcs:send_text(6, string.format("TL: %0.1f, BV: %0.1f, OP: %0.0f, IP: %0.0f, BP: %0.0f", tank_level, battery_volltage, output_power, spm_input_power, battery_power))
end

function update()
    if driver then
        frame = driver:read_frame()
        if frame then
            if frame:id() == uint32_t(0x400 + math.floor(FCPM_SLAVE_ID:get())) then
                cyclic_counter = frame:data(0) & 0xF
                fcpm_state = (frame:data(0) >> 4) & 0xF
                tank_level = (frame:data(1) | ((frame:data(2) & 0x3) << 8)) * 0.5
                battery_volltage = ((frame:data(2) >> 2) & 0x3F | (frame:data(3) & 0xF) << 6) * 0.1
                output_power = (frame:data(3) >> 4 & 0xF | (frame:data(4) & 0x3F) << 4) * 10
                spm_input_power = (frame:data(4) >> 6 & 0x3 | frame:data(5) << 2) * 2
                battery_power = (frame:data(6) & 0xFF | (frame:data(7) & 0x3) << 8) * 10
            end
        end
        if FCPM_LOGGING:get() > 0.5 then
            log()
        end
        if FCPM_GCS:get() > 0.5 then
            if gcs_counter > 150 then
                gcs_counter = 0
                gcs_send()
            else
                gcs_counter = gcs_counter + 1
            end
        end
        return update, 10
    end
    gcs:send_text(0,"Stop FCPM LUA script")
end

return update, 500

--[[
frame = CANFrame()
frame:id(uint32_t(0x400 + math.floor(FCPM_SLAVE_ID:get())))
local byte = 0
byte = (1 & 0xF) -- Cyclic Counter 4 bit
byte = byte + (0xF << 4) -- FCPM State 4 bit
frame:data(0, byte & 0xFF)
local tl = 200 -- tank level 10 bit * 0,5
byte = 0
byte = (tl & 0xFF)
frame:data(1, byte & 0xFF)
byte = 0
local bv = 200 -- battery voltage 10 bit * 0.1
byte = (tl >> 8 & 0x03) | ((bv << 2) & 0xFC)
frame:data(2, byte & 0xFF)
frame:data(3, (bv >> 6) & 0xF)
local op = 50 -- output power 10 bit * 10
byte = 0
byte = op << 4 & 0xF0
frame:data(3, frame:data(3) | byte)
frame:data(4, op >> 4 & 0x3F)
local ip = 250 -- input power 10 bit * 2
byte = 0
byte = ip << 6 & 0xC0
frame:data(4, frame:data(4) | byte)
frame:data(5, ip >> 2 & 0xFF)
local bp = 300 -- battery power 10 bit * 10
frame:data(6, bp & 0xFF)
frame:data(7, bp >> 8 & 0x3)
--]]
