gcs:send_text(0,"Start GT33REU LUA script")

local driver = CAN.get_device(20)

local div = 1
local temp1 = 0
local power = 0
local current = 0
local rpm = 0

--logger.write('GT33','temp(deg),current(a),power(w)','iii',temp1,current,power)

function read_i16(b1, b2)
    assert (0 <= b1 and b1 <= 0xff)
    assert (0 <= b2 and b2 <= 0xff)
    local mask = (1 << 15)
    local res  = (b1 << 8) | (b2 << 0)
    return (res ~ mask) - mask
end

if not driver then
    gcs:send_text(0,"No scripting CAN interface found")
    return
end

function show_frame(dnum, frame)
    if frame:id() == uint32_t(0x80) then
        temp1 = read_i16(frame:data(4), frame:data(5))
        rpm = (frame:data(0) << 8) | frame:data(1)
    elseif frame:id() == uint32_t(0x81) then
        current = read_i16(frame:data(4), frame:data(5))
--    elseif frame:id() == uint32_t(0x82) then
    elseif frame:id() == uint32_t(0x83) then
        power = (frame:data(4) << 8) | frame:data(5)
    end

    if div < 2 then
        gcs:send_text(6,string.format("Temp1: %d C°  Current: %d A  Power: %d W  RPM: %d rpm", temp1, current, power, rpm))
        div = 1000
    else
        div = div - 1
    end
--    logger.write('GT33','temp(deg),current(a),power(w)','iii',temp1,current,power)
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

gcs:send_text(0, "GT33REU driver loaded")

return update()