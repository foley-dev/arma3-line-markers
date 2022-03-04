# arma3-line-markers

Smooth line markers script for Arma 3

## Features

* Draw complex line markers
* Generate [smooth](docs/basic-usage.md#draw-smooth-path), [curved](docs/basic-usage.md#draw-curved-hops) or [wavy](docs/basic-usage.md#draw-wavy-path) lines
* [Track position](docs/basic-usage.md#track-player-position-along-the-path) along a path
* Composable design (see: [Advanced Usage](docs/advanced-usage.md))

## Quick start

1. Copy the `Foley_markers` folder to your scenario: `scripts\Foley_markers\`
2. Add to your scenario's `init.sqf`:
    ```sqf
    execVM "scripts\Foley_markers\init.sqf";
    ```
3. Try drawing some paths! Copy examples below and paste them in the debug console.

## Basic usage

* [Draw straight path](docs/basic-usage.md#draw-straight-path)
* [Draw curved hops](docs/basic-usage.md#draw-curved-hops)
* [Draw smooth path](docs/basic-usage.md#draw-smooth-path)
* [Draw wavy path](docs/basic-usage.md#draw-wavy-path)
* [Track position along the path](docs/basic-usage.md#track-player-position-along-the-path)

## Advanced usage

* [Create path](docs/advanced-usage.md#create-path)
* [Delete path](docs/advanced-usage.md#delete-path)
* [Select markers](docs/advanced-usage.md#select-markers)
