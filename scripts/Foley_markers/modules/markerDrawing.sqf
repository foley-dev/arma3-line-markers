#include "..\macros.hpp"

GVAR(fnc_drawPolyline) = {
	params ["_normalizedPoints", "_markerName", "_color", "_drawLocally"];

	if (count _normalizedPoints < 2) exitWith {};
	
	private _markerPos = [_normalizedPoints] call GVAR(fnc_calculateMiddle);
	private _polyline = [_normalizedPoints] call GVAR(fnc_convertPointsToPolyline);
	assert (count _polyline >= 4 && count _polyline mod 2 == 0);

	if (_drawLocally) then {
		_marker = createMarkerLocal [_markerName, _markerPos];
		_marker setMarkerShapeLocal "POLYLINE";
		_marker setMarkerColorLocal _color;
		_marker setMarkerPolylineLocal _polyline;
	} else {
		_marker = createMarker [_markerName, _markerPos];
		_marker setMarkerShape "POLYLINE";
		_marker setMarkerColor _color;
		_marker setMarkerPolyline _polyline;
	};

	_marker
};

GVAR(fnc_calculateMiddle) = {
	params ["_normalizedPoints"];

	if (count _normalizedPoints == 0) exitWith {
		[0, 0]
	};

	private _sum = [0, 0, 0];

	{
		_sum = _sum vectorAdd _x;
	} forEach _normalizedPoints;

	_sum vectorMultiply (1 / count _normalizedPoints)
};

GVAR(fnc_convertPointsToPolyline) = {
	params ["_normalizedPoints"];

	private _polyline = [];

	{
		_polyline pushBack (_x select 0);
		_polyline pushBack (_x select 1);
	} forEach _normalizedPoints;

	_polyline
};
