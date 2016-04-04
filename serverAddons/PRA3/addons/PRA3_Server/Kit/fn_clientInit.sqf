#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: joko // Jonas, NetFusion

    Description:
    Init Kit Module

    Parameter(s):
    None

    Returns:
    None
*/
[QGVAR(KitGroups), missionConfigFile >> "PRA3" >> "KitGroups"] call CFUNC(loadSettings);
{
    [format [QGVAR(Kit_%1), configName _x], _x >> "Kits"] call CFUNC(loadSettings);
    nil
} count ("true" configClasses (missionConfigFile >> "PRA3" >> "Sides"));

["vehicleChanged", {
    (_this select 0) params ["_newVehicle", "_oldVehicle"];

    // Check restrictions if player entered a vehicle
    if (_newVehicle != PRA3_Player) then {
        call FUNC(checkVehicleRestrictions);
    };
}] call CFUNC(addEventHandler);

// SeatSwitchedMan ist not working because we need the old position
["assignedVehicleRoleChanged", {
    (_this select 0) params ["_newVehicleRole", "_oldVehicleRole"];

    // Check restriction if player switched the seat
    if (!(_oldVehicleRole isEqualTo [])) then {
        [_oldVehicleRole] call FUNC(checkVehicleRestrictions);
    };
}] call CFUNC(addEventHandler);