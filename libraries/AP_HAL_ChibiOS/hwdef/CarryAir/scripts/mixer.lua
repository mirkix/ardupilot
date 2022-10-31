local AP_MOTORS_MATRIX_YAW_FACTOR_CW = -1
local AP_MOTORS_MATRIX_YAW_FACTOR_CCW = 1

local AP_MOTORS_MOT_1 = 0
local AP_MOTORS_MOT_2 = 1
local AP_MOTORS_MOT_3 = 2
local AP_MOTORS_MOT_4 = 3
local AP_MOTORS_MOT_5 = 4
local AP_MOTORS_MOT_6 = 5

MotorsMatrix:add_motor_raw(AP_MOTORS_MOT_1, -1.0, -0.073, AP_MOTORS_MATRIX_YAW_FACTOR_CW, 1);
MotorsMatrix:add_motor_raw(AP_MOTORS_MOT_2, 1.0, -0.073, AP_MOTORS_MATRIX_YAW_FACTOR_CCW, 2);
MotorsMatrix:add_motor_raw(AP_MOTORS_MOT_3, 0.424, 0.533, AP_MOTORS_MATRIX_YAW_FACTOR_CW, 3);
MotorsMatrix:add_motor_raw(AP_MOTORS_MOT_4, -0.424, -0.667, AP_MOTORS_MATRIX_YAW_FACTOR_CCW, 4);
MotorsMatrix:add_motor_raw(AP_MOTORS_MOT_5, -0.424, 0.533, AP_MOTORS_MATRIX_YAW_FACTOR_CCW, 5);
MotorsMatrix:add_motor_raw(AP_MOTORS_MOT_6, 0.424, -0.667, AP_MOTORS_MATRIX_YAW_FACTOR_CW, 6);

assert(MotorsMatrix:init(6), "Failed to init CarryAir MotorsMatrix")

motors:set_frame_string("Scripting CarryAir")

gcs:send_text(6, "Scripting init CarryAir MotorsMatrix done")