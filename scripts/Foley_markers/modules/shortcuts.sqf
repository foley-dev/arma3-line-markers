#include "..\macros.hpp"
#define EXAMPLE_POINTS [[0,0,0],[-815,594,0],[-1690,358,0],[-1944,1290,0],[-1684,1690,0],[-859,1745,0],[-372,2336,0],[-36,2837,0],[-251,3335,0],[-601,3696,0],[-1182,3471,0],[-1893,3330,0],[-2437,3609,0],[-2778,4040,0],[-3711,4142,0]]

// Convenience functions for basic usage

GVAR(fnc_drawStraightPath) = {
	params ["_points", "_color"];

	[str random 1000000, _points, _color, true] call GVAR(fnc_create);
};

GVAR(fnc_drawHops) = {
	params ["_points", "_color", ["_curvature", 0.2], ["_tweensCount", 10], ["_curveDirection", "RIGHT"]];

	[
		str random 1000000,
		_points,
		_color,
		true,
		GVAR(fnc_hopsInterpolation),
		[_curvature, _tweensCount, _curveDirection]
	] call GVAR(fnc_create);
};

GVAR(fnc_drawSmoothPath) = {
	params ["_points", "_color", ["_curvature", 1.0], ["_tweensCount", 10]];

	[
		str random 1000000,
		_points,
		_color,
		true,
		GVAR(fnc_splicedBezierInterpolation),
		[_curvature, _tweensCount]
	] call GVAR(fnc_create);
};

GVAR(fnc_drawWavyPath) = {
	params ["_points", "_color", ["_strengthDistribution", [0.3, 0.4, 0.5]], ["_curvesCount", 3], ["_tweensCount", 10]];

	[
		str random 1000000,
		_points,
		_color,
		true,
		GVAR(fnc_waveInterpolation),
		[_strengthDistribution, _curvesCount, _tweensCount]
	] call GVAR(fnc_create);
};

GVAR(fnc_drawPathAndTrackProgress) = {
	params ["_points", "_baseColor", "_highlightColor", "_trackedObject", ["_gridMode", false], ["_refreshInterval", 1], ["_accuracyInMeters", 100]];

	private _scriptHandle = _this spawn {
		params ["_points", "_baseColor", "_highlightColor", "_trackedObject", ["_gridMode", false], ["_refreshInterval", 1], ["_accuracyInMeters", 100]];

		private _id = [
			str random 1000000, 
			_points, 
			_baseColor, 
			true, 
			GVAR(fnc_splicedBezierInterpolation), 
			[1.0, 25],
			GVAR(fnc_maxLengthSegmentation),
			[_accuracyInMeters]
		] call GVAR(fnc_create);

		private _previouslyHighlighted = [];

		while {alive _trackedObject} do {
			private _nearestPolyline = [_id, getPos _trackedObject] call Foley_markers_fnc_getNearestPolyline;
			private _highlighted = [];

			if (_gridMode) then {
				private _gridCenter = (getPos _trackedObject) apply {
					500 + 1000 * floor (_x / 1000)
				};
				_highlighted = [_id, [_gridCenter, 500, 500, 0, true, -1]] call Foley_markers_fnc_getPolylinesInArea;
			} else {
				_highlighted = [_id, 0, _nearestPolyline] call Foley_markers_fnc_getPolylinesSlice;
			};
			
			{
				_x setMarkerColor _baseColor;
			} forEach _previouslyHighlighted;

			{
				_x setMarkerColor _highlightColor;
			} forEach _highlighted;

			_previouslyHighlighted = _highlighted;

			sleep _refreshInterval;
		};
	};

	_scriptHandle
};

GVAR(fnc_generateExamplePoints) = {
	EXAMPLE_POINTS apply {
		_x vectorAdd getPos player
	}
};
