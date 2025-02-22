#include "..\script_component.hpp"
#define EJECT_ID \
	private _id = GEN_STR(_task); \
	_group setVariable [_id,_item get "ejections",true]; \
	_item set ["ejectionsID",_id]

params ["_group","_item"];

private _task = toUpper (_item get "task");
private _taskArgs = [_item getOrDefault ["behaviors",nil],_item getOrDefault ["timeout",nil]];

_taskArgs append (switch _task do {
	case "RTB" : {[]};
	case "MOVE" : {[]};
	case "PATH" : {[]};
	case "FOLLOW" : {[]};
	case "HOLD" : {
		_taskArgs deleteAt 1;
		[]
	};
	case "LAND" : {["engine","endDir","approach"]};
	case "LANDSIGNAL" : {["engine","signalType","searchRadius","searchTimeout"]};
	case "HOVER" : {["hoverHeight","endDir","approach"]};
	case "FASTROPE" : {
		EJECT_ID;
		["hoverHeight","endDir","approach","ejectTypes","ejectionsID"]
	};
	case "HELOCAST" : {
		EJECT_ID;
		["hoverHeight","hoverSpeed","endDir","approach","ejectTypes","ejectionsID"]
	};
	case "LOITER" : {["loiterType","loiterRadius"]};
	case "SLINGLOADPICKUP" : {["searchRadius"]};
	case "SLINGLOADDROPOFF" : {[]};
	case "UNLOAD" : {
		EJECT_ID;
		["ejectTypes","ejectionsID","ejectInterval"]
	};
	case "PARADROP" : {
		EJECT_ID;
		["ejectTypes","ejectionsID","ejectInterval","openAltitude"]
	};
	case "SAD" : {[]};
	case "STRAFE" : {		
		private _pylon1 = _item getOrDefault ["pylon1",[]];
		private _pylon2 = _item getOrDefault ["pylon2",[]];
		private _quantity1 = _item getOrDefault ["quantity1",1];
		private _quantity2 = _item getOrDefault ["quantity2",1];
		private _distribution1 = _item getOrDefault ["distribution1",false];
		private _distribution2 = _item getOrDefault ["distribution2",false];
		private _interval1 = _item getOrDefault ["interval1",0];
		private _interval2 = _item getOrDefault ["interval2",0];

		_item set ["pylonConfig",[
			[_pylon1,[_quantity1,_distribution1],_interval1],
			[_pylon2,[_quantity2,_distribution2],_interval2]
		]];

		["pylonConfig","spread","target","searchRadius"]
	};
	case "FIRE" : {
		_item set ["burst",[
			_item getOrDefault ["burstDuration",3],
			_item getOrDefault ["burstInterval",2]
		]];

		["weapon","duration","burst","spread"]
	};
	case "RELOCATE" : {[]};
	default {[]};
} apply {_item getOrDefault [_x,nil]});

[_task,_item getOrDefault ["posASL",[0,0,0]],_item getOrDefault ["attachedObject",objNull],_taskArgs]
