#include "..\macros.hpp"

// Public

GVAR(drawStraightPath) = {
	params ["_points", ["_color", "ColorRed"], ["_segmentMaxLength", 100], ["_isLocal", true], ["_tweensCount", 10]];

	private _normalizedPoints = [_points] call GVAR(normalizePoints);
	private _polyline = [_normalizedPoints] call GVAR(pointsToPolyline);
	private _id = [_polyline, _color, _segmentMaxLength, _isLocal] call GVAR(createPathMarker);

	_id
};

GVAR(drawSmoothPath) = {
	params ["_points", ["_color", "ColorRed"], ["_segmentMaxLength", 100], ["_isLocal", true], ["_tweensCount", 10], ["_curvature", 1.0]];

	private _normalizedPoints = [_points] call GVAR(normalizePoints);
	private _polyline = [
		_normalizedPoints,
		_curvature,
		_tweensCount
	] call GVAR(pointsToCombinedBezierPolyline);
	private _id = [_polyline, _color, _segmentMaxLength, _isLocal] call GVAR(createPathMarker);

	_id
};

GVAR(drawSegmentedSmoothPath) = {
	params ["_points", ["_color", "ColorRed"], ["_segmentMaxLength", 100], ["_isLocal", true], ["_tweensCount", 10], ["_curvature", 1.0], ["_curveDirection", "LEFT"]];

	private _normalizedPoints = [_points] call GVAR(normalizePoints);
	private _polyline = [
		_normalizedPoints,
		_curvature,
		_curveDirection,
		_tweensCount
	] call GVAR(pointsToBezierPolyline);
	private _id = [_polyline, _color, _segmentMaxLength, _isLocal] call GVAR(createPathMarker);

	_id
};

// Private - marker management

GVAR(allPathMarkers) = createHashMap;

GVAR(createPathMarker) = {
	params ["_polyline", "_color", "_segmentMaxLength", "_isLocal"];

	private _id = [_polyline] call GVAR(generateId);
	private _polylineSegments = [_polyline, _segmentMaxLength] call GVAR(segmentPolyline);
	private _markerNames = [];

	{
		private _markerName = _id + "_" + str _forEachIndex;
		[
			_x,
			_color,
			_markerName,
			_isLocal
		] call GVAR(drawPolyline);
		_markerNames pushBack _markerName;
	} forEach _polylineSegments;

	GVAR(allPathMarkers) set [_id, [_isLocal, _markerNames]];

	_id
};

GVAR(deletePathMarker) = {
	params ["_id"];

	private _pathMarker = GVAR(allPathMarkers) get _id;

	if (isNil "_markerNames") exitWith {};

	_pathMarker params ["_isLocal", "_markerNames"];

	GVAR(allPathMarkers) deleteAt _id;

	{
		if (_isLocal) then {
			deleteMarkerLocal _x;
		} else {
			deleteMarker _x;
		};
	} forEach _markerNames;
};

GVAR(generateId) = {
	params ["_points"];
	
	(hashValue _points) + str random 1000000
};

GVAR(normalizePoints) = {
	params ["_points"];

	private _normalizedPoints = _points apply {
		switch true do {
			case (_x isEqualTypeParams [0, 0] || _x isEqualTypeParams [0, 0, 0]): {[_x select 0, _x select 1, 0]};
			case (_x isEqualType objNull && !isNull _x): {[(getPos _x) select 0, (getPos _x) select 1, 0]};
			default {objNull};
		};
	};
	
	_normalizedPoints select {_x isEqualTypeParams [0, 0]}
};

// Private - path processing

GVAR(pointsToPolyline) = {
	params ["_normalizedPoints"];

	private _polyline = [];

	{
		_polyline pushBack (_x select 0);
		_polyline pushBack (_x select 1);
	} forEach _normalizedPoints;

	_polyline
};

GVAR(pointsToBezierPolyline) = {
	params ["_normalizedPoints", "_curvature", "_curveDirection", "_tweensCount"];

	private _bezierCurves = [_normalizedPoints, _curvature, _curveDirection] call GVAR(generateBezierCurves);
	private _polyline = [];

	{
		_x params ["_previous", "_control", "_current"];

		private _step = 1 / _tweensCount;

		for "_t" from 0.0 to 1.0 + 0.25 * _step step _step do {
			private _point = _t bezierInterpolation _x;

			_polyline pushBack (_point select 0);
			_polyline pushBack (_point select 1);
		};
	} forEach _bezierCurves;

	_polyline
};

// http://web.archive.org/web/20131027060328/http://www.antigrain.com/research/bezier_interpolation/index.html#PAGE_BEZIER_INTERPOLATION
GVAR(pointsToCombinedBezierPolyline) = {
	params ["_normalizedPoints", "_curvature", "_tweensCount"];

	if (DEBUG_BEZIER) then {
		{
			private _marker = createMarker [str random 1000000, _x];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_dot";
			_marker setMarkerSize [0.5, 0.5];
			_marker setMarkerText ("P_" + str _forEachIndex);
		} forEach _normalizedPoints;
	};

	private _pointsA = [];

	for "_i" from 0 to (count _normalizedPoints) - 2 step 1 do {
		private _pFrom = _normalizedPoints select _i;
		private _pTo = _normalizedPoints select (_i + 1);
		private _pointA = (_pFrom vectorAdd _pTo) vectorMultiply 0.5;
		_pointsA pushBack _pointA;
		
		if (DEBUG_BEZIER) then {
			private _marker = createMarker [str random 1000000, _pointA];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_dot";
			_marker setMarkerColor "ColorYellow";
			_marker setMarkerSize [0.5, 0.5];
			_marker setMarkerText ("A_" + str _i);
		};
	};

	private _pointsB = [];

	for "_i" from 0 to (count _normalizedPoints) - 3 step 1 do {
		private _aFrom = _pointsA select _i;
		private _aTo = _pointsA select (_i + 1);
		private _l1 = (_normalizedPoints select _i) distance (_normalizedPoints select (_i + 1));
		private _l2 = (_normalizedPoints select (_i + 1)) distance (_normalizedPoints select (_i + 2));
		private _pointB = vectorLinearConversion [0.0, 1.0, _l1 / (_l1 + _l2), _aFrom, _aTo];
		_pointsB pushBack _pointB;

		if (DEBUG_BEZIER) then {
			private _marker = createMarker [str random 1000000, _pointB];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_dot";
			_marker setMarkerColor "ColorOrange";
			_marker setMarkerSize [0.5, 0.5];
			_marker setMarkerText ("B_" + str _i);
		}
	};

	private _segmentsC = [];

	for "_i" from 0 to (count _normalizedPoints) - 3 step 1 do {
		private _pointB = _pointsB select _i;
		private _prevA = _pointsA select _i;
		private _nextA = _pointsA select (_i + 1);
		private _prevOffset = _prevA vectorDiff _pointB;
		private _nextOffset = _nextA vectorDiff _pointB;
		private _anchor = _normalizedPoints select (_i + 1);
		_segmentsC pushBack [_anchor, _prevOffset, _nextOffset];
	};

	private _bezierCurves = [];

	for "_i" from 0 to (count _normalizedPoints) - 2 step 1 do {
		private _pFrom = _normalizedPoints select _i;
		private _pTo = _normalizedPoints select (_i + 1);

		private _control1 = _pFrom;

		if (_i > 0) then {
			private _segmentFrom = _segmentsC select (_i - 1);
			_segmentFrom params ["_anchor", "_prevOffset", "_nextOffset"];
			_control1 = _anchor vectorAdd (_nextOffset vectorMultiply _curvature);
		};
		
		private _control2 = _pTo;

		if (_i < count _segmentsC) then {
			private _segmentTo = _segmentsC select _i;
			_segmentTo params ["_anchor", "_prevOffset", "_nextOffset"];
			_control2 = _anchor vectorAdd (_prevOffset vectorMultiply _curvature);
		};

		if (DEBUG_BEZIER) then {
			private _marker = createMarker [str random 1000000, _control1];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_dot";
			_marker setMarkerColor "ColorRed";
			_marker setMarkerSize [0.5, 0.5];
			_marker setMarkerText ("C_" + (str _i) + "_1");

			private _marker = createMarker [str random 1000000, _control2];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_dot";
			_marker setMarkerColor "ColorRed";
			_marker setMarkerSize [0.5, 0.5];
			_marker setMarkerText ("C_" + (str _i) + "_2");
		};

		_bezierCurves pushBack [_pFrom, _control1, _control2, _pTo];
	};

	private _polyline = [];

	{
		_x params ["_previous", "_control", "_current"];

		private _step = 1 / _tweensCount;

		for "_t" from 0.0 to 1.0 + 0.25 * _step step _step do {
			private _point = _t bezierInterpolation _x;

			_polyline pushBack (_point select 0);
			_polyline pushBack (_point select 1);
		};
	} forEach _bezierCurves;

	_polyline
};

GVAR(generateBezierCurves) = {
	params ["_normalizedPoints", "_curvature", "_curveDirection"];

	private _bezierCurves = [];
	private _curveLeft = _curveDirection in ["LEFT", "ALTERNATING"];

	for "_i" from 1 to (count _normalizedPoints) - 1 step 1 do {
		private _previous = _normalizedPoints select (_i - 1);
		private _current = _normalizedPoints select _i;

		private _midpoint = (_previous vectorAdd _current) vectorMultiply 0.5;
		private _unit = _current vectorFromTo _previous;
		private _normalVector = [
			[-(_unit select 1), _unit select 0],
			[_unit select 1, -(_unit select 0)]
		] select _curveLeft;
		private _offsetMagnitude = _curvature * (_previous distance _current);

		private _control = _midpoint vectorAdd (_normalVector vectorMultiply _offsetMagnitude);
		private _bezierCurve = [_previous, _control, _current];
		_bezierCurves pushBack _bezierCurve;

		if (DEBUG_BEZIER) then {
			private _marker = createMarker [str random 1000000, _previous];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_start";
			_marker setMarkerSize [0.5, 0.5];

			private _marker = createMarker [str random 1000000, _midpoint];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_dot";
			_marker setMarkerSize [0.5, 0.5];

			private _marker = createMarker [str random 1000000, _control];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_pickup";
			_marker setMarkerSize [0.5, 0.5];

			private _marker = createMarker [str random 1000000, _current];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_end";
			_marker setMarkerSize [0.5, 0.5];
		};

		if (_curveDirection isEqualTo "ALTERNATING") then {
			_curveLeft = !_curveLeft;
		};
	};

	_bezierCurves
};

GVAR(segmentPolyline) = {
	params ["_polyline", "_maxSegmentLength"];

	private _segments = [];
	private _accumulatedDistance = 0;
	private _segmentStartIndex = 0;

	for "_i" from 3 to count _polyline - 1 step 2 do {
		private _previousPoint = [_polyline select _i - 3, _polyline select _i - 2];
		private _currentPoint = [_polyline select _i - 1, _polyline select _i];

		if (_accumulatedDistance + (_previousPoint distance _currentPoint) > _maxSegmentLength && _i - _segmentStartIndex + 3 >= 4) then {
			_segments pushBack (_polyline select [_segmentStartIndex, _i - _segmentStartIndex + 3]);
			_accumulatedDistance = 0;
			_segmentStartIndex = _i + 1;
		} else {
			_accumulatedDistance = _accumulatedDistance + (_previousPoint distance _currentPoint);
		};
	};

	if (_segmentStartIndex != count _polyline) then {
		private _startOffset = [0, 2] select (count _polyline - _segmentStartIndex <= 4);
		systemChat str [_startOffset, count _polyline, _segmentStartIndex];
		private _finalSegment = _polyline select [
			_segmentStartIndex - _startOffset,
			count _polyline - _segmentStartIndex + _startOffset
		];
		_segments pushBack _finalSegment;
	};

	_segments
};

// Private - marker drawing

GVAR(drawPolyline) = {
	params ["_polyline", "_color", "_markerName", "_isLocal"];

	assert (count _polyline >= 4 && count _polyline mod 2 == 0);

	if (_isLocal) then {
		_marker = createMarkerLocal [_markerName, [0, 0, 0]];
		_marker setMarkerShapeLocal "POLYLINE";
		_marker setMarkerPolylineLocal _polyline;
		_marker setMarkerColorLocal _color;
	} else {
		_marker = createMarker [_markerName, [0, 0, 0]];
		_marker setMarkerShape "POLYLINE";
		_marker setMarkerPolyline _polyline;
		_marker setMarkerColor _color;
	};

	_marker
};
