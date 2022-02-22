#include "macros.hpp"

if (isNil QGVAR(initiated)) then {
	GVAR(initiated) = false;

	{
		call compile preprocessFileLineNumbers (BASE_DIR + _x);
	} forEach [
		"modules\markers.sqf"
	];

	GVAR(initiated) = true;
};
