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
