#include "macros.hpp"

if (isNil QGVAR(initiated)) then {
	GVAR(initiated) = false;

	{
		call compile preprocessFileLineNumbers (BASE_DIR + _x);
	} forEach [
		"modules\markerDrawing.sqf",
		"modules\markerManagement.sqf",
		"modules\markerSelection.sqf",
		"modules\pathInterpolation.sqf",
		"modules\pathSegmentation.sqf",
		"modules\shortcuts.sqf"
	];

	GVAR(initiated) = true;
};
