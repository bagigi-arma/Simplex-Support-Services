#include "script_component.hpp"

params [
	["_vehicle",objNull,[objNull]],
	["_callsign","",[""]],
	["_respawnTime",SSS_setting_respawnTimeDefault,[0]]
];

if (!SSS_postInitDone) exitWith {
	[{SSS_postInitDone},{
		_this remoteExecCall ["SSS_fnc_addCASHeli",_this # 0];
	},_this] call CBA_fnc_waitUntilAndExecute;
};

if (!local _vehicle) exitWith {_this remoteExecCall ["SSS_fnc_addCASHeli",_vehicle];};

// Validation
if (_callsign isEqualTo "") then {_callsign = getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName");};
private _side = side _vehicle;
if (_side == sideLogic || _side == sideEmpty || !(_vehicle isKindOf "Helicopter")) exitWith {SSS_ERROR_2("Invalid CAS vehicle: %1 (%2)",_callsign,_vehicle)};
if !((leader _vehicle) in _vehicle) exitWith {SSS_ERROR_2("Leader is not in CAS vehicle: %1 (%2)",_callsign,_vehicle)};
if (_vehicle in (missionNamespace getVariable [format ["SSS_CASHelis_%1",_side],[]])) exitWith {SSS_ERROR_2("Vehicle is already assigned: %1 (%2)",_callsign,_vehicle)};

// Basic setup
private _group = group _vehicle;
_group setVariable ["SSS_protectWaypoints",true,true];
private _base = createVehicle ["Land_HelipadEmpty_F",[0,0,0],[],0,"CAN_COLLIDE"];
_base setPosASL (getPosASL _vehicle);
SET_VEHICLE_TRAITS_PHYSICAL(_vehicle,_group,_base,_side,"CASHelis",_callsign,_respawnTime)
CREATE_TASK_MARKER(_vehicle,"mil_end","CAS",_callsign)

// Service specific setup
_vehicle setVariable ["SSS_awayFromBase",false,true];
_vehicle setVariable ["SSS_onTask",false,true];
_vehicle setVariable ["SSS_interrupt",false,true];
_vehicle setVariable ["SSS_combatMode",0,true];
_vehicle setVariable ["SSS_speedMode",1,true];
_vehicle setVariable ["SSS_flyingHeight",180,true];
_vehicle lockTurret [[0],true];
_vehicle lockCargo true;
_vehicle flyInHeight 180;
private _fries = _vehicle getVariable ["ace_fastroping_FRIES",objnull]; // FRIES makes AI pilots a nightmare
if (!isNull _fries) then {deleteVehicle _fries;};

// Assignment
ADD_SUPPORT_VEHICLE(_vehicle,_side,"CASHelis")
_vehicle addMPEventHandler ["MPKilled",{[_this # 0] call SSS_fnc_respawn;}];
(driver _vehicle) addMPEventHandler ["MPKilled",{[vehicle (_this # 0),true] call SSS_fnc_respawn;}];

// CBA Event
private _JIPID = ["SSS_supportVehicleAdded",_vehicle] call CBA_fnc_globalEventJIP;
[_JIPID,_vehicle] call CBA_fnc_removeGlobalEventJIP;
_vehicle setVariable ["SSS_addedJIPID",_JIPID,true];

