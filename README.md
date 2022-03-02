# arma3-line-markers

Smooth line markers script for Arma 3

## Features

## Quick start

1. Copy the `Foley_markers` folder to your scenario: `scripts\Foley_markers\`
2. Add to your scenario's `init.sqf`:
    ```sqf
    execVM "scripts\Foley_markers\init.sqf";
    ```
3. Try drawing some paths! You can use examples below in your `init.sqf` or in debug console.


### Straight path

```sqf
[
    call Foley_markers_fnc_generateExamplePoints,
    "ColorBlack"
] call Foley_markers_fnc_drawStraightPath;
```

### Curved hops

```sqf
[
	call Foley_markers_fnc_generateExamplePoints,
	"ColorGreen"
] call Foley_markers_fnc_drawHops; 
```

### Smooth path
```sqf
[
	call Foley_markers_fnc_generateExamplePoints,
	"ColorBlue"
] call Foley_markers_fnc_drawSmoothPath;
```

### Wavy path
```sqf
[
	call Foley_markers_fnc_generateExamplePoints,
	"ColorRed"
] call Foley_markers_fnc_drawWavyPath;
```

### Track player's position along the path
```sqf
[
	call Foley_markers_fnc_generateExamplePoints,
	"ColorBlack",
	"ColorRed",
	player
] call Foley_markers_fnc_drawPathAndTrackProgress;
```

## Advanced usage

### Marker management

### Path interpolation

### Path segmentation

### Marker selection
