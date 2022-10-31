local scr_user1_param = Parameter()
assert(scr_user1_param:init('SCR_USER1'), 'could not find SCR_USER1 parameter')

if scr_user1_param:get() == 0 then
    gcs:send_text(6,"GT33REU LUA script disabled")
    return
end

gcs:send_text(6,"Start GT33REU LUA script")

local driver = CAN.get_device(20)

local div = 1
local fuel = 0
local temp1 = 0
local power = 0
local current2 = 0
local rpm = 0

--logger.write('GT33','temp(deg),current2(a),power(w)','iii',temp1,current2,power)

function read_i16(b1, b2)
    assert (0 <= b1 and b1 <= 0xff)
    assert (0 <= b2 and b2 <= 0xff)
    local mask = (1 << 15)
    local res  = (b1 << 8) | (b2 << 0)
    return (res ~ mask) - mask
end

if not driver then
    gcs:send_text(0,"No GT33REU CAN interface found")
    return
end

function show_frame(dnum, frame)
    if frame:id() == uint32_t(0x80) then
        temp1 = read_i16(frame:data(4), frame:data(5))
        rpm = (frame:data(0) << 8) | frame:data(1)
    elseif frame:id() == uint32_t(0x81) then
        current2 = read_i16(frame:data(6), frame:data(7))
    elseif frame:id() == uint32_t(0x82) then
        fuel = (frame:data(0) << 8) | frame:data(1)
    elseif frame:id() == uint32_t(0x83) then
        power = (frame:data(4) << 8) | frame:data(5)
    end

    if div < 2 then
        gcs:send_text(6,string.format("T1: %d C°,C2: %d A,Pwr: %d W,RPM: %d,Fuel: %d %", temp1, current2, power, rpm, fuel))
        div = 1000
    else
        div = div - 1
    end
--    logger.write('GT33','temp(deg),current2(a),power(w)','iii',temp1,current2,power)
end

function update()
    if driver then
        frame = driver:read_frame()
        if frame then
            show_frame(1, frame)
        end
        return update, 10
    end
    gcs:send_text(0,"Stop GT33REU LUA script")
    return
end

gcs:send_text(6, "GT33REU driver loaded")

return update()