#include "..\macros.hpp"

// No segmentation
// Keep entire path as a single segment

GVAR(fnc_noSegmentation) = {
	params ["_normalizedPoints", "_parameters"];

	[_normalizedPoints]
};

// Max length segmentation
// Divide path into segments no longer than specified length (in meters)

GVAR(fnc_maxLengthSegmentation) = {
	params ["_normalizedPoints", "_parameters"];
	_parameters params ["_maxLength"];

	assert (count _normalizedPoints >= 2);
	assert (_maxLength > 0);

	private _segments = [];
	private _remainingDistance = _maxLength;
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
			private _inbetween = _lastPointInSegment vectorAdd (_unit vectorMultiply _remainingDistance);
			_remainingDistance = _maxLength;
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
