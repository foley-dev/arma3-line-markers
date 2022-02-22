#include "..\macros.hpp"

// Utils

GVAR(fnc_buildSegmentsFromPoints) = {
	params ["_normalizedPoints", "_maxSegmentLength"];

	assert (count _normalizedPoints >= 2);
	assert (_maxSegmentLength > 0);

	private _segments = [];
	private _remainingDistance = _maxSegmentLength;
	private _nextPointIndex = 1;
	private _segment = [_normalizedPoints select 0];

	while {_nextPointIndex < count _normalizedPoints} do {
		private _lastPointInSegment = _segment select (count _segment - 1);
		private _nextPoint = _normalizedPoints select _nextPointIndex;

		if (_remainingDistance - (_lastPointInSegment distance _nextPoint) > 0) then {
			_remainingDistance = _remainingDistance - (_lastPointInSegment distance _nextPoint);
			_segment pushBack _nextPoint;
			_nextPointIndex = _nextPointIndex + 1;
		} else {
			private _unit = _lastPointInSegment vectorFromTo _nextPoint;
			systemChat str [_lastPointInSegment, _unit, _remainingDistance];
			private _inbetween = _lastPointInSegment vectorAdd (_unit vectorMultiply _remainingDistance);
			_remainingDistance = _maxSegmentLength;
			_segment pushBack _inbetween;
			_segments pushBack _segment;
			_segment = [_inbetween];
		};
	};

	if (count _segment >= 2) then {
		_segments pushBack _segment;
	};

	_segments
};

GVAR(fnc_normalizePoints) = {
	params ["_points"];

	private _normalizedPoints = _points apply {
		switch true do {
			case (_x isEqualTypeParams [0, 0] || _x isEqualTypeParams [0, 0, 0]): {
				[_x select 0, _x select 1, 0]
			};

			case (_x isEqualType objNull && !isNull _x): {
				[(getPos _x) select 0, (getPos _x) select 1, 0]
			};

			default {
				objNull
			};
		};
	};
	
	_normalizedPoints select {_x isEqualTypeParams [0, 0, 0]}
};

// Segmented Bezier

GVAR(fnc_generateSegmentedBezier) = {
	params ["_normalizedPoints", "_curvature", "_curveDirection", "_tweensCount"];

	private _allControlPoints = [
		_normalizedPoints,
		_curvature,
		_curveDirection
	] call GVAR(fnc_generateBezierSegmentControlPoints);
	private _points = [];

	{
		private _controlPoints = _x;
		private _step = 1 / _tweensCount;

		for "_t" from 0.0 to 1.0 + 0.25 * _step step _step do {
			_points pushBack (_t bezierInterpolation _controlPoints);
		};
	} forEach _allControlPoints;

	_points
};

GVAR(fnc_generateBezierSegmentControlPoints) = {
	params ["_normalizedPoints", "_curvature", "_curveDirection"];

	private _allControlPoints = [];
	private _isCurvingLeft = _curveDirection isEqualTo "LEFT";

	for "_i" from 1 to (count _normalizedPoints) - 1 step 1 do {
		private _previous = _normalizedPoints select (_i - 1);
		private _current = _normalizedPoints select _i;

		private _midpoint = (_previous vectorAdd _current) vectorMultiply 0.5;
		private _unit = _current vectorFromTo _previous;
		private _normalVector = [
			[-(_unit select 1), _unit select 0],
			[_unit select 1, -(_unit select 0)]
		] select _isCurvingLeft;
		private _offsetMagnitude = _curvature * (_previous distance _current);
		private _offsetMidpoint = _midpoint vectorAdd (_normalVector vectorMultiply _offsetMagnitude);

		private _controlPoints = [_previous, _offsetMidpoint, _current];
		_allControlPoints pushBack _controlPoints;

		if (_curveDirection isEqualTo "ALTERNATING") then {
			_isCurvingLeft = !_isCurvingLeft;
		};
	};

	_allControlPoints
};

// Spliced Bezier
// http://web.archive.org/web/20131027060328/http://www.antigrain.com/research/bezier_interpolation/index.html#PAGE_BEZIER_INTERPOLATION

GVAR(fnc_generateSplicedBezier) = {
	params ["_normalizedPoints", "_curvature", "_tweensCount"];

	private _as = [];

	for "_i" from 0 to (count _normalizedPoints) - 2 step 1 do {
		private _pCurrent = _normalizedPoints select _i;
		private _pNext = _normalizedPoints select (_i + 1);
		private _a = (_pCurrent vectorAdd _pNext) vectorMultiply 0.5;

		_as pushBack _a;
	};

	private _bs = [];

	for "_i" from 0 to (count _normalizedPoints) - 3 step 1 do {
		private _aCurrent = _as select _i;
		private _aNext = _as select (_i + 1);
		private _l1 = (_normalizedPoints select _i) distance (_normalizedPoints select (_i + 1));
		private _l2 = (_normalizedPoints select (_i + 1)) distance (_normalizedPoints select (_i + 2));
		private _b = vectorLinearConversion [0.0, 1.0, _l1 / (_l1 + _l2), _aCurrent, _aNext];
		_bs pushBack _b;
	};

	private _cs = [];

	for "_i" from 0 to (count _normalizedPoints) - 3 step 1 do {
		private _b = _bs select _i;
		private _prevA = _as select _i;
		private _nextA = _as select (_i + 1);
		private _prevOffset = _prevA vectorDiff _b;
		private _nextOffset = _nextA vectorDiff _b;
		private _anchor = _normalizedPoints select (_i + 1);
		_cs pushBack [_anchor, _prevOffset, _nextOffset];
	};

	private _allControlPoints = [];

	for "_i" from 0 to (count _normalizedPoints) - 2 step 1 do {
		private _pCurrent = _normalizedPoints select _i;
		private _pNext = _normalizedPoints select (_i + 1);
		private _control1 = _pCurrent;

		if (_i > 0) then {
			private _cPrev = _cs select (_i - 1);
			_cPrev params ["_anchor", "_prevOffset", "_nextOffset"];
			_control1 = _anchor vectorAdd (_nextOffset vectorMultiply _curvature);
		};
		
		private _control2 = _pNext;

		if (_i < count _cs) then {
			private _cCurrent = _cs select _i;
			_cCurrent params ["_anchor", "_prevOffset", "_nextOffset"];
			_control2 = _anchor vectorAdd (_prevOffset vectorMultiply _curvature);
		};

		_allControlPoints pushBack [_pCurrent, _control1, _control2, _pNext];
	};

	private _points = [];

	{
		private _controlPoints = _x;
		private _step = 1 / _tweensCount;

		for "_t" from 0.0 to 1.0 + 0.25 * _step step _step do {
			_points pushBack (_t bezierInterpolation _controlPoints);
		};
	} forEach _allControlPoints;

	_points
};