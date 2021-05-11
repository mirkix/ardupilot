#include "mode.h"
#include "Plane.h"

bool ModeLandn::_enter()
{
    plane.landn_state.locked_roll = false;
    plane.landn_state.locked_pitch = false;

    return true;
}

void ModeLandn::update()
{
    // handle locked/unlocked control
    if (plane.landn_state.locked_roll) {
        plane.nav_roll_cd = plane.landn_state.locked_roll_err;
    } else {
        plane.nav_roll_cd = plane.ahrs.roll_sensor;
    }
    if (plane.landn_state.locked_pitch) {
        plane.nav_pitch_cd = plane.landn_state.locked_pitch_cd;
    } else {
        plane.nav_pitch_cd = plane.ahrs.pitch_sensor;
    }

    // turn off motor
    SRV_Channels::set_output_scaled(SRV_Channel::k_throttle, 0);
}
