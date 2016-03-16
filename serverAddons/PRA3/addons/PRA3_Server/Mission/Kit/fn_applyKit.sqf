#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: joko // Jonas, NetFusion

    Description:
    Apply Kit to player

    Parameter(s):
    0: Kit Name <String>

    Returns:
    None
*/
params ["_kitName"];

private _kitDetails = [_kitName, [
    ["uniform", ""], ["vest", ""], ["backpack", ""], ["headGear", ""],
    ["primaryWeapon", ""], ["primaryAttachments", []], ["primaryMagazine", ""], ["primaryMagazineCount", 0], ["primaryMagazineTracer", ""], ["primaryMagazineCount", 0],
    ["secondaryWeapon", ""], ["secondaryMagazine", ""], ["secondaryMagazineCount", 0],
    ["handgunWeapon", ""], ["handgunMagazine", ""], ["handgunMagazineCount", 0],
    ["assignedItems", []],
    ["items", []]
]] call FUNC(getKitDetails);
_kitDetails params [
    "_uniform", "_vest", "_backpack", "_headGear",
    "_primaryWeapon", "_primaryAttachments", "_primaryMagazine", "_primaryMagazineCount", "_primaryMagazineTracer", "_primaryMagazineTracerCount",
    "_secondaryWeapon", "_secondaryMagazine", "_secondaryMagazineCount",
    "_handgunWeapon", "_handgunMagazine", "_handgunMagazineCount",
    "_assignedItems",
    "_items"
];

// remove all Items
removeAllAssignedItems PRA3_Player;
removeAllWeapons PRA3_Player;
removeHeadgear PRA3_Player;
removeGoggles PRA3_Player;

// add container
[PRA3_Player, _uniform] call FUNC(addContainer);
[PRA3_Player, _vest] call FUNC(addContainer);
[PRA3_Player, _backpack] call FUNC(addContainer);
PRA3_Player addHeadgear _headGear;

// Primary Weapon
[_primaryWeapon, _primaryMagazine, _primaryMagazineCount] call DFUNC(addWeapon);
[_primaryMagazineTracer, _primaryMagazineTracerCount] call DFUNC(addMagazine);
{
    PRA3_Player addPrimaryWeaponItem _x;
    nil
} count (_primaryAttachments select {_x != ""});

// Secondary Weapon
[_secondaryWeapon, _secondaryMagazine, _secondaryMagazineCount] call DFUNC(addWeapon);

// Handgun Weapon
[_handgunWeapon, _handgunMagazine, _handgunMagazineCount] call DFUNC(addWeapon);

// Assigned items
{
    PRA3_Player linkItem _x;
    nil
} count _assignedItems;

// Items
{
    _x call DFUNC(addItem);
    nil
} count _items;

// reload Weapon
reload PRA3_Player;

PRA3_Player setVariable [QGVAR(Kit), _kitName];
