#include "..\macros.hpp"

// Generate straight lines
GVAR(fnc_noInterpolation) = {
	params ["_normalizedPoints", "_parameters"];
	
	_normalizedPoints
};

// Generate curved "hops" or links between distinct points
GVAR(fnc_hopsInterpolation) = {
	params ["_normalizedPoints", "_parameters"];
	_parameters params [["_curvature", 0.2], ["_tweensCount", 10], ["_curveDirection", "RIGHT"]];

	private _allControlPoints = [];
	private _isCurvingLeft = _curveDirection isEqualTo "LEFT";

	for "_i" from 1 to (count _normalizedPoints) - 1 do {
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

	[_allControlPoints, _tweensCount] call GVAR(fnc_generateInterpolatedPoints);
};

// Generate a smooth, continuous path
// Adapted from: http://web.archive.org/web/20131027060328/http://www.antigrain.com/research/bezier_interpolation/index.html#PAGE_BEZIER_INTERPOLATION
GVAR(fnc_splicedBezierInterpolation) = {
	params ["_normalizedPoints", "_parameters"];
	_parameters params [["_curvature", 1.0], ["_tweensCount", 10]];

	// Step 1
	private _as = [];

	for "_i" from 0 to (count _normalizedPoints) - 2 do {
		private _pCurrent = _normalizedPoints select _i;
		private _pNext = _normalizedPoints select (_i + 1);
		private _a = (_pCurrent vectorAdd _pNext) vectorMultiply 0.5;

		_as pushBack _a;
	};

	// Step 2
	private _bs = [];

	for "_i" from 0 to (count _normalizedPoints) - 3 do {
		private _aCurrent = _as select _i;
		private _aNext = _as select (_i + 1);
		private _l1 = (_normalizedPoints select _i) distance (_normalizedPoints select (_i + 1));
		private _l2 = (_normalizedPoints select (_i + 1)) distance (_normalizedPoints select (_i + 2));
		private _b = vectorLinearConversion [0.0, 1.0, _l1 / (_l1 + _l2), _aCurrent, _aNext];
		_bs pushBack _b;
	};

	private _cs = [];

	for "_i" from 0 to (count _normalizedPoints) - 3 do {
		private _b = _bs select _i;
		private _prevA = _as select _i;
		private _nextA = _as select (_i + 1);
		private _prevOffset = _prevA vectorDiff _b;
		private _nextOffset = _nextA vectorDiff _b;
		private _anchor = _normalizedPoints select (_i + 1);
		_cs pushBack [_anchor, _prevOffset, _nextOffset];
	};

	// Step 3 & 4
	private _allControlPoints = [];

	for "_i" from 0 to (count _normalizedPoints) - 2 do {
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

	[_allControlPoints, _tweensCount] call GVAR(fnc_generateInterpolatedPoints);
};

// Generate random, irregular waves imitating hand-drawing
GVAR(fnc_waveInterpolation) = {
	params ["_normalizedPoints", "_parameters"];
	_parameters params [["_strengthDistribution", [0.3, 0.4, 0.5]], ["_curvesCount", 3], ["_tweensCount", 10]];

	private _allControlPoints = [];

	for "_i" from 1 to (count _normalizedPoints) - 1 do {
		private _previous = _normalizedPoints select (_i - 1);
		private _current = _normalizedPoints select _i;
		private _unit = _previous vectorFromTo _current;
		private _normals = [
			[-(_unit select 1), _unit select 0],
			[_unit select 1, -(_unit select 0)]
		];
		private _segmentLength = (_previous distance _current) / (_curvesCount + 1);
		
		private _controlPoints = [_previous];

		for "_j" from 1 to _curvesCount do {
			private _pointOnLine = _previous vectorAdd (_unit vectorMultiply (_segmentLength * _j));
			private _offsetMagnitude = _segmentLength * random _strengthDistribution;
			private _offsetVector = (_normals select ((_i * _curvesCount + _j) % 2)) vectorMultiply _offsetMagnitude;
			_controlPoints pushBack (_pointOnLine vectorAdd _offsetVector);
		};

		_controlPoints pushBack _current;
		_allControlPoints pushBack _controlPoints;
	};
	
	[_allControlPoints, _tweensCount] call GVAR(fnc_generateInterpolatedPoints);
};


// Helper function used to generate points from Bezier controls
GVAR(fnc_generateInterpolatedPoints) = {
	params ["_allControlPoints", "_tweensCount"];

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
