#include "..\macros.hpp"

GVAR(fnc_drawPolyline) = {
	params ["_points", "_color", "_markerName", "_drawLocally"];

	if (count _points < 2) exitWith {};

	private _polyline = [_x] call GVAR(fnc_pointsToPolyline);
	assert (count _polyline >= 4 && count _polyline mod 2 == 0);

	if (_drawLocally) then {
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

GVAR(fnc_pointsToPolyline) = {
	params ["_normalizedPoints"];

	private _polyline = [];

	{
		_polyline pushBack (_x select 0);
		_polyline pushBack (_x select 1);
	} forEach _normalizedPoints;

	_polyline
};
