#include "macros.hpp"

if (isNil QGVAR(initiated)) then {
	GVAR(initiated) = false;

	{
		call compile preprocessFileLineNumbers (BASE_DIR + _x);
	} forEach [
		"modules\markerDrawing.sqf",
		"modules\markerManagement.sqf",
		"modules\pathGeneration.sqf",
		"modules\userFunctions.sqf"
	];

	GVAR(initiated) = true;
};
