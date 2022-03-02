#include "..\macros.hpp"

GVAR(allPathMarkers) = createHashMap;

GVAR(fnc_create) = {
	params [
		"_id",
		"_points",
		"_color",
		"_drawLocally",
		["_interpolationFunction", GVAR(fnc_noInterpolation)],
		["_interpolationParameters", []],
		["_segmentationFunction", GVAR(fnc_noSegmentation)],
		["_segmentationParameters", []]
	];

	// Strip slash which is a reserved character in marker names
	_id = _id regexReplace ["[/]", "-"];  

	// Ensure all points are in format [0, 0, 0]
	private _normalizedPoints = [_points] call GVAR(fnc_normalizePoints);

	// Generate additional points (i.e. to curve the path)
	private _interpolatedPoints = [
		_normalizedPoints,
		_interpolationParameters
	] call _interpolationFunction;

	// Group points into line segments
	private _segments = [
		_interpolatedPoints,
		_segmentationParameters
	] call _segmentationFunction;

	if (_id in GVAR(allPathMarkers)) then {
		[_id] call GVAR(fnc_delete);
	};

	private _markerNames = [];

	// Draw polylines
	{
		private _segmentPoints = _x;
		private _markerName = _id + "_" + str _forEachIndex;

		[
			_segmentPoints,
			_markerName,
			_color,
			_drawLocally
		] call GVAR(fnc_drawPolyline);

		_markerNames pushBack _markerName;
	} forEach _segments;

	// Store path info in hashmap
	GVAR(allPathMarkers) set [
		_id,
		[_drawLocally, _markerNames, _normalizedPoints]
	];

	_id
};

GVAR(fnc_delete) = {
	params ["_id"];
	_id = _id regexReplace ["[/]", "-"];

	private _markerNames = [_id] call GVAR(fnc_getAllPolylines);
	GVAR(allPathMarkers) deleteAt _id;

	{
		if (_drawLocally) then {
			deleteMarkerLocal _x;
		} else {
			deleteMarker _x;
		};
	} forEach _markerNames;
};

GVAR(fnc_normalizePoints) = {
	params ["_points"];

	private _fnc_normalize = {
		switch true do {
			case (_x isEqualTypeParams [0, 0] || _x isEqualTypeParams [0, 0, 0]): {
				[_x select 0, _x select 1, 0]
			};

			case (_x isEqualType objNull && !isNull _x): {
				[(getPos _x) select 0, (getPos _x) select 1, 0]
			};

			case (_x isEqualType "" && _x in allMapMarkers): {
				[(getMarkerPos _x) select 0, (getMarkerPos _x) select 1, 0]
			};

			default {
				objNull
			};
		};
	};

	private _normalizedPoints = _points apply _fnc_normalize;
	
	_normalizedPoints select {_x isEqualTypeParams [0, 0, 0]}
};
