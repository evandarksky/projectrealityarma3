#include "macros.hpp"
/*
    Project Reality ArmA 3

    Author: joko // Jonas

    Description:
    init for TicketBleed System

    Parameter(s):
    None

    Returns:
    None
*/

[{
    if (isServer) then {
        GVAR(playerTicketValue) = getNumber(missionConfigFile >> "PRA3" >> "playerTicketValue");
        GVAR(ticketBleed) = getArray(missionConfigFile >> "PRA3" >> "ticketBleed");

        private _startTickets = getNumber(missionConfigFile >> "PRA3" >> "tickets");
        {
            missionNamespace setVariable [format [QGVAR(sideTickets_%1), _x], _startTickets];
            publicVariable (format [QGVAR(sideTickets_%1), _x]);
            nil
        } count GVAR(competingSides);

        addMissionEventHandler ["EntityKilled", {
            params ["_killedEntity", "_killer"];
            hint format ["Entity Killed: %1",_killedEntity getVariable [QGVAR(ticketValue),0]];
            if (_killedEntity getVariable [QGVAR(ticketValue),0] > 0) exitWith {
                private _ticketValue = _killedEntity getVariable [QGVAR(ticketValue),0];
                private _currentSide = _killedEntity getVariable [QGVAR(side),"unknown"];
                private _tickets = missionNamespace getVariable format [QGVAR(sideTickets_%1), _currentSide];
                if !(isNil "_tickets") then {
                    _tickets = _tickets - _ticketValue;
                    missionNamespace setVariable [format [QGVAR(sideTickets_%1), _currentSide], _tickets];
                    publicVariable (format [QGVAR(sideTickets_%1), _currentSide]);
                    ["ticketsChanged"] call CFUNC(globalEvent);
                };
            };

            if (_killedEntity in allPlayers) exitWith {
                private _currentSide = side group _killedEntity;
                private _tickets = missionNamespace getVariable format [QGVAR(sideTickets_%1), str(_currentSide)];
                if !(isNil "_tickets") then {
                    _tickets = _tickets - GVAR(playerTicketValue);
                    missionNamespace setVariable [format [QGVAR(sideTickets_%1), str(_currentSide)], _tickets];
                    publicVariable (format [QGVAR(sideTickets_%1), str(_currentSide)]);
                    ["ticketsChanged"] call CFUNC(globalEvent);
                };
            };
        }];

        ["sector_side_changed", {
            (_this select 0) params ["_sector", "_oldSide", "_newSide"];
            private _tickets = missionNamespace getVariable format [QGVAR(sideTickets_%1), str(_oldSide)];
            if !(isNil "_tickets") then {
                _tickets = _tickets - (_sector getVariable "ticketBleed");
                missionNamespace setVariable [format [QGVAR(sideTickets_%1), str(_currentSide)], _tickets];
                publicVariable (format [QGVAR(sideTickets_%1), str(_currentSide)]);
                ["ticketsChanged"] call CFUNC(globalEvent);
            };

            private _looserSide = sideUnknown;
            private _nbrOwnedSectors = {
                private _condition = !((_x getVariable ["side",sideUnknown]) in [_newSide]);
                if (_condition) then {
                    _looserSide = _x getVariable ["side",sideUnknown];
                };
                _condition
            } count GVAR(allSectorsArray);



            if (_nbrOwnedSectors == 1) then {
                [{
                    (_this select 0) params ["_side"];
                    private _id = (_this select 0);
                    private _tickets = missionNamespace getVariable format [QGVAR(sideTickets_%1), str _side];
                    _tickets = _tickets - (GVAR(ticketBleed) select 1);
                    missionNamespace setVariable [format [QGVAR(sideTickets_%1), str _side], _tickets];
                    publicVariable (format [QGVAR(sideTickets_%1), str _side]);
                    ["ticketsChanged"] call CFUNC(globalEvent);

                    private _nbrOwnedSectors = {
                        !((_x getVariable ["side",sideUnknown]) in [_newSide]);
                    } count GVAR(allSectorsArray);

                    if (_nbrOwnedSectors > 1) then {
                        [_id] call CFUNC(removePerFrameHandler);
                    };
                }, GVAR(ticketBleed) select 0, [_looserSide]] call CFUNC(addPerFrameHandler);
            };
        }] call CFUNC(addEventhandler);
    };

    if (hasInterface) then {
        ([UIVAR(TicketStatus)] call BIS_fnc_rscLayer) cutRsc [UIVAR(TicketStatus),"PLAIN"];
        private _startTickets = getNumber(missionConfigFile >> "PRA3" >> "tickets");
        disableSerialization;
        private _dialog = uiNamespace getVariable UIVAR(TicketStatus);
        (_dialog displayCtrl 2001) ctrlSetText (missionNamespace getVariable [format [QGVAR(Flag_%1),GVAR(competingSides) select 0],"#(argb,8,8,3)color(0.5,0.5,0.5,1)"]);
        (_dialog displayCtrl 2002) ctrlSetText str (missionNamespace getVariable [format [QGVAR(sideTickets_%1),GVAR(competingSides) select 0],_startTickets]);
        (_dialog displayCtrl 2003) ctrlSetText (missionNamespace getVariable [format [QGVAR(Flag_%1),GVAR(competingSides) select 1],"#(argb,8,8,3)color(0.5,0.5,0.5,1)"]);
        (_dialog displayCtrl 2004) ctrlSetText str (missionNamespace getVariable [format [QGVAR(sideTickets_%1),GVAR(competingSides) select 1],_startTickets]);
        missionNamespace getVariable format [QGVAR(sideTickets_%1), str(_currentSide)];
        ["ticketsChanged", {
            disableSerialization;
            private _dialog = uiNamespace getVariable UIVAR(TicketStatus);
            (_dialog displayCtrl 2001) ctrlSetText (missionNamespace getVariable [format [QGVAR(Flag_%1),GVAR(competingSides) select 0],"#(argb,8,8,3)color(0.5,0.5,0.5,1)"]);
            (_dialog displayCtrl 2002) ctrlSetText str (missionNamespace getVariable [format [QGVAR(sideTickets_%1),GVAR(competingSides) select 0],0]);
            (_dialog displayCtrl 2003) ctrlSetText (missionNamespace getVariable [format [QGVAR(Flag_%1),GVAR(competingSides) select 1],"#(argb,8,8,3)color(0.5,0.5,0.5,1)"]);
            (_dialog displayCtrl 2004) ctrlSetText str (missionNamespace getVariable [format [QGVAR(sideTickets_%1),GVAR(competingSides) select 1],0]);
        }] call CFUNC(addEventHandler);

    };

},{!isNil QGVAR(competingSides) && {!(GVAR(competingSides) isEqualTo [])}}] call CFUNC(waitUntil);