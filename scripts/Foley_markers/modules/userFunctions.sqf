#include "..\macros.hpp"

GVAR(fnc_drawStraightPath) = {
	params ["_points", ["_color", "ColorRed"], ["_segmentMaxLength", 100], ["_drawLocally", true]];

	private _normalizedPoints = [_points] call GVAR(fnc_normalizePoints);
	private _id = [_normalizedPoints, _color, _segmentMaxLength, _drawLocally] call GVAR(fnc_createPathMarker);

	_id
};

GVAR(fnc_drawSmoothPath) = {
	params ["_points", ["_color", "ColorRed"], ["_segmentMaxLength", 100], ["_drawLocally", true], ["_tweensCount", 10], ["_curvature", 1.0]];

	private _normalizedPoints = [_points] call GVAR(fnc_normalizePoints);
	private _generatedPoints = [
		_normalizedPoints,
		_curvature,
		_tweensCount
	] call GVAR(fnc_generateSplicedBezier);
	private _id = [_generatedPoints, _color, _segmentMaxLength, _drawLocally] call GVAR(fnc_createPathMarker);

	_id
};

GVAR(fnc_drawSegmentedSmoothPath) = {
	params ["_points", ["_color", "ColorRed"], ["_segmentMaxLength", 100], ["_drawLocally", true], ["_tweensCount", 10], ["_curvature", 0.2], ["_curveDirection", "LEFT"]];

	private _normalizedPoints = [_points] call GVAR(fnc_normalizePoints);
	private _generatedPoints = [
		_normalizedPoints,
		_curvature,
		_curveDirection,
		_tweensCount
	] call GVAR(fnc_generateSegmentedBezier);
	private _id = [_generatedPoints, _color, _segmentMaxLength, _drawLocally] call GVAR(fnc_createPathMarker);

	_id
};
