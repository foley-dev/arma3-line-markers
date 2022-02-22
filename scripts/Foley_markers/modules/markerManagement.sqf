#include "..\macros.hpp"

GVAR(allPathMarkers) = createHashMap;

GVAR(fnc_createPathMarker) = {
	params ["_normalizedPoints", "_color", "_segmentMaxLength", "_drawLocally"];

	private _id = [_normalizedPoints] call GVAR(fnc_generateId);
	private _segments = [_normalizedPoints, _segmentMaxLength] call GVAR(fnc_buildSegmentsFromPoints);
	private _markerNames = [];

	{
		private _points = _x;
		private _markerName = _id + "_" + str _forEachIndex;

		[
			_points,
			_color,
			_markerName,
			_drawLocally
		] call GVAR(fnc_drawPolyline);

		_markerNames pushBack _markerName;
	} forEach _segments;

	GVAR(allPathMarkers) set [_id, [_drawLocally, _markerNames]];

	_id
};

GVAR(fnc_deletePathMarker) = {
	params ["_id"];

	private _pathMarker = GVAR(allPathMarkers) get _id;

	if (isNil "_pathMarker") exitWith {};

	_pathMarker params ["_drawLocally", "_markerNames"];

	GVAR(allPathMarkers) deleteAt _id;

	{
		if (_drawLocally) then {
			deleteMarkerLocal _x;
		} else {
			deleteMarker _x;
		};
	} forEach _markerNames;
};

GVAR(fnc_generateId) = {
	params ["_points"];
	
	QUOTE(NAMESPACE) + "_" + ((hashValue _points) regexReplace ["[/]", "-"]) + str random 1000000
};
