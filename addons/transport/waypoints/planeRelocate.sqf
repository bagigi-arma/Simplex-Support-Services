#include "..\script_component.hpp"
#define ORDER "RELOCATE"

params [
	"_group",
	"_wpPos",
	"_attachedObject",
	["_behaviors",[]],
	["_timeout",0]
];

private _entity = _group getVariable [QPVAR(entity),objNull];
private _vehicle = _entity getVariable [QPVAR(vehicle),objNull];

if (!alive _vehicle) exitWith {true};

[FUNC(waypointUpdate),[[_group,currentWaypoint _group],_entity,_vehicle,_behaviors,ORDER,_wpPos]] call CBA_fnc_directCall;

if (isTouchingGround _vehicle) then {
	[_entity,_vehicle] call EFUNC(common,planeTakeoff);
};

_vehicle doMove _wpPos;

waitUntil {
	if (unitReady _vehicle) then {
		_vehicle doMove _wpPos;
	};

	sleep WAYPOINT_SLEEP;

	!isTouchingGround _vehicle && unitReady _vehicle && _vehicle distance2D _wpPos < 200
};

waitUntil {
	sleep WAYPOINT_SLEEP;
	isTouchingGround _vehicle
};

// Begin relocation
private _relocationTick = (_entity getVariable [QPVAR(relocation),[false,60]]) # 1 + CBA_missionTime;

waitUntil {
	sleep WAYPOINT_SLEEP;
	!alive _vehicle || !isTouchingGround _vehicle || CBA_missionTime >= _relocationTick
};

if (!alive _vehicle || !isTouchingGround _vehicle) exitWith {
	NOTIFY(_entity,LSTRING(notifyRelocateFailed));
	true
};

_entity setVariable [QPVAR(base),getPosASL _vehicle,true];
_entity setVariable [QPVAR(baseNormal),[vectorDir _vehicle,vectorUp _vehicle],true];
NOTIFY(_entity,LSTRING(notifyRelocateComplete));

if (_timeout > 0) then {
	_vehicle call FUNC(landedStop);
	[_entity,ORDER,_timeout] call FUNC(notifyWaiting);
	sleep _timeout;
};

true
