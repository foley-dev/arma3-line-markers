# Advanced usage

## Create path

### Description

This function is used to create path markers. In contrast to [basic usage](./basic-usage.md) functions, it allows you to specify details such as:
* whether to draw the marker locally or globally,
* how to generate additional points (i.e. to curve the path),
* how to group points into line segments.

If a path marker with the provided `id` already exists, it is deleted and redrawn.

Created paths are stored in `Foley_markers_allPathMarkers` hashmap and they can be referenced by `id` (see: [marker selection](#select-markers)).

### Syntax

[id, points, color, drawLocally, interpolationFnc, interpolationParams, segmentationFnc, segmentationParams] call **Foley_markers_fnc_create**

### Parameters

* id: String - unique identifier of the path marker, used to reference the created path

* points: Array - an array containing 2D/3D positions, marker names or objects

* color: String - marker color according to [CfgMarkerColors](https://community.bistudio.com/wiki/Arma_3:_CfgMarkerColors)

* drawLocally: Boolean - if true, map markers will be created locally

* interpolationFnc: Code - (Optional, default `Foley_markers_fnc_noInterpolation`) a function that generates additional points.
    * A path interpolation function should take 2 arguments:
        * normalizedPoints: Array - provided points, normalized to 3D positions with z = 0
        * parameters: Array - provided parameters
    * It should return an array with generated points. 
    * Built-in interpolations are defined in: `scripts\Foley_markers\pathInterpolation.sqf`.

* interpolationParams: Array - (Optional, default `[]`) parameters provided to the interpolationFnc

* segmentationFnc: Code - (Optional, default `Foley_markers_fnc_noSegmentation` a function that groups points into segments.
    * A path segmentation function should take 2 arguments:
        * normalizedPoints: Array - provided points, normalized to 3D positions with z = 0,
        * parameters: Array - parameters specific to the function.
    * This function should return an array of segments. Each segment is an array of points that will become a single polyline marker.
    * Built-in segmentation functions are located in: `scripts\Foley_markers\pathSegmentation.sqf`.

* segmentationParams: Array - (Optional, default `[]`) parameters provided to the segmentationFnc

### Return value

String - path marker ID (may differ from provided id if it contains reserved characters)

### Example

```sqf
private _id = [
    "my_line_marker",
    call Foley_markers_fnc_generateExamplePoints,
    "ColorRed",
    true,
    Foley_markers_fnc_splicedBezierInterpolation,
    [1.0, 25],
    Foley_markers_fnc_maxLengthSegmentation,
    [100]
] call Foley_markers_fnc_create;
```

## Delete path

### Syntax

[id] call **Foley_markers_fnc_delete**

### Parameters

* id: String - path marker identifier

### Return value

Nothing

### Example

```sqf
private _id = [
    "my_line_marker",
    call Foley_markers_fnc_generateExamplePoints,
    "ColorRed",
    true
] call Foley_markers_fnc_create;

[_id] call Foley_markers_fnc_delete;
// Equivalent to ["my_line_marker"] call Foley_markers_fnc_delete;
```

## Select markers

There are several methods to access marker names from a given path. These markers can be modified directly i.e. using `setMarkerColor` / `setMarkerColorLocal`. 

### Get all markers

```sqf
// All path segments
private _markers = [_id] call Foley_markers_fnc_getAllPolylines;
```

### Get markers in area

```sqf
// All segments in 1000x1000m square centered at the player
private _markers = [
    _id,
    [getPos player, 500, 500, 0, true, -1]
] call Foley_markers_fnc_getPolylinesInArea;
```

### Get the nearest marker

```sqf
// The closest segment to the player
private _marker = [_id, getPos player] call Foley_markers_fnc_getNearestPolyline;
```

### Get nearest markers

```sqf
// 5 segments closest to the player
private _markers = [_id, getPos player, 5] call Foley_markers_fnc_getNearestPolylines;
```

### Get a slice of markers

```sqf
// First 10 segments, skipping every other segment
private _markers = [_id, 0, 10, 2] call Foley_markers_fnc_getPolylinesSlice;
```

### Direct access

It is possible to access created markers directly in the `Foley_markers_allPathMarkers` hashmap. Each path stored as an array `[drawLocally, markerNames, normalizedPoints]`
* drawLocally: Boolean - indicates whether the markers were created locally
* markerNames: Array - marker names of the individual line segments
* normalizedPoints: Array - all path points, normalized to 3D positions with z = 0

`Foley_markers_allPathMarkers` hashmap is meant to be read-only. Modifying it directly may cause undefined behaviour.

## See also

* [Quick start](../README.md)
* [Basic usage](./basic-usage.md)
