#include "..\macros.hpp"

// Convenience functions for basic usage

GVAR(fnc_drawStraightPath) = {
	params ["_points", "_color"];

	[str random 1000000, _points, _color, true] call GVAR(fnc_create);
};

GVAR(fnc_drawHops) = {
	params ["_points", "_color", ["_curvature", 0.2], ["_tweensCount", 10], ["_curveDirection", "LEFT"]];

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
	params ["_points", "_color", ["_strengthDistribution", [0.2, 0.3, 0.4]], ["_curvesCount", 3], ["_tweensCount", 10]];

	[
		str random 1000000,
		_points,
		_color,
		true,
		GVAR(fnc_waveInterpolation),
		[_strengthDistribution, _curvesCount, _tweensCount]
	] call GVAR(fnc_create);
};
