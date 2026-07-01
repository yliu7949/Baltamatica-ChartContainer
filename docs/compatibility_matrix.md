# gleamoe.graphics.chartcontainer Compatibility Matrix

This matrix tracks the intended v1 behavior against MATLAB R2026a ChartContainer APIs.

| Area | Status | Notes |
| --- | --- | --- |
| `gleamoe.graphics.chartcontainer.ChartContainer` package path | implemented | Mirrors `matlab.graphics.chartcontainer.ChartContainer` naming style with the `gleamoe` root namespace. |
| `handle` inheritance | implemented | All chart objects use reference semantics; implementation variable names use `this`. |
| `setup(this)` / `update(this)` protected hooks | implemented | Abstract hooks are called by the base constructor, with name-value application followed by one update. |
| Name-value constructor arguments | implemented | Supports case-insensitive property names and early `Parent` extraction. |
| Leading parent argument | implemented | Recognizes MATLAB/Baltamatica graphics-like handles before name-value pairs. |
| `Parent`, `Visible`, `HandleVisibility` | implemented | Stored on the chart and best-effort synced to managed axes. |
| `Units`, `Position`, `InnerPosition`, `OuterPosition`, `PositionConstraint`, `Layout` | implemented | `Position` drives the fallback layout; MATLAB hidden layout internals are not reproduced. |
| `getAxes(this)` | implemented | Creates one managed axes on demand. |
| `createAxes(this, ...)` | implemented | Adds internal options for `Tile` and `Type` to support examples. |
| `getLayout(this)` | degraded | Returns `LightweightLayout`, not MATLAB `TiledChartLayout`, because Baltamatica lacks full tiled layout support. |
| `getTheme(this)` | implemented | Returns a simple theme struct with MATLAB-like color defaults and axes-derived overrides when available. |
| `mixin.Legend` | implemented | Provides `LegendVisible` and protected `getLegend(this)` with best-effort graphics creation. |
| `mixin.Colorbar` | implemented | Provides `ColorbarVisible` and protected `getColorbar(this)` with best-effort graphics creation. |
| Mixin class deletion in Baltamatica | degraded | Baltamatica reports ambiguous `delete` with multiple handle superclasses unless concrete mixin charts define `delete(this)`. |
| Automatic update on arbitrary subclass properties | degraded | Subclasses should define property setters that call `requestUpdate(this)`. MATLAB's hidden listener machinery is not reproduced. |
| Save/load reconstruction | blocked-by-baltamatica | Not implemented in v1; MATLAB internal serialization hooks are private and platform-specific. |
| Toolbars/interactivity/layout containers | blocked-by-baltamatica | Baltamatica `scripts/graph` shows `Toolbar`, some `Parent`, and `Clipping` gaps. |
| GUI rendering | partial | MATLAB can render the bundled Sankey example. Baltamatica graphics examples should be run in the desktop application because `-nodesktop` sessions do not expose the required `axes` graphics path. |

Primary references:

- https://www.mathworks.com/help/matlab/ref/matlab.graphics.chartcontainer.chartcontainer-class.html
- https://www.mathworks.com/help/matlab/ref/matlab.graphics.chartcontainer.mixin.legend-class.html
- https://www.mathworks.com/help/matlab/ref/matlab.graphics.chartcontainer.mixin.colorbar-class.html
- https://www.mathworks.com/help/matlab/creating_plots/chart-development-overview.html
