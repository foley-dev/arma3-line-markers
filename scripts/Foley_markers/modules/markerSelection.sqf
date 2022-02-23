#include "..\macros.hpp"

GVAR(fnc_getAllPolylines) = {
	params ["_id"];

	private _pathInfo = GVAR(allPathMarkers) get _id;
	_pathInfo params ["_drawLocally", "_markerNames", "_normalizedPoints"];

	if (isNil "_pathInfo") exitWith {
		[]
	};

	_markerNames
};

GVAR(fnc_getPolylinesInArea) = {
	params ["_id", "_area"];

	private _all = [_id] call GVAR(fnc_getAllPolylines);
	
	_all select {(getMarkerPos _x) inArea _area}
};

GVAR(fnc_getNearestPolylines) = {
	params ["_id", "_position", "_maxResults"];

	private _all = [_id] call GVAR(fnc_getAllPolylines);
	private _sorted = [
		_all,
		[
			[_position select 0, _position select 1]
		],
		{
			_input0 distanceSqr (getMarkerPos _x)
		},
		"ASCEND"
	] call BIS_fnc_sortBy;

	_sorted select [0, _maxResults]
};

GVAR(fnc_getNearestPolyline) = {
	params ["_id", "_position"];

	private _nearest = [_id, _position, 1] call GVAR(fnc_getNearestPolylines);

	if (count _nearest == 0) exitWith {
		nil
	};

	_nearest select 0
};

GVAR(fnc_getPolylinesSlice) = {
	params ["_id", "_start", "_end", ["_step", 1]];

	private _all = [_id] call GVAR(fnc_getAllPolylines);

	if (_start isEqualType "") then {
		_start = _all find _start;
	};

	if (_end isEqualType "") then {
		_end = _all find _end;
	};

	if (isNil "_start" || isNil "_end") exitWith {
		[]
	};

	private _slice = [];
	_start = _start max 0;
	_end = (_end - 1) min (count _all - 1);

	for "_i" from _start to _end step _step do {
		_slice pushBack (_all select _i);
	};

	_slice
};
