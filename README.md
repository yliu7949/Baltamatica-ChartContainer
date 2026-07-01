# gleamoe.graphics.chartcontainer

MATLAB-style chart container classes for Baltamatica experiments.

The project mirrors the public `matlab.graphics.chartcontainer.*` authoring
model where Baltamatica provides compatible graphics behavior. Chart classes:

- subclass `gleamoe.graphics.chartcontainer.ChartContainer`;
- implement protected `setup(this)` and `update(this)` hooks;
- call `requestUpdate(this)` from custom property setters;
- optionally use `gleamoe.graphics.chartcontainer.mixin.Legend` or
  `gleamoe.graphics.chartcontainer.mixin.Colorbar`;
- call the superclass constructor from subclasses with `varargin`.

## Included Plot

The reusable plot entry point is `plot/SankeyPlot.m`. It accepts a link table,
separate source/target/value vectors, or an adjacency matrix:

```matlab
addpath(pwd)
addpath(fullfile(pwd, 'plot'))

links = {'a1','A',1.2; 'a2','A',1; 'A','AA',2};
chart = SankeyPlot(links, 'Arrow', 'on');
```

The bundled demo is:

```matlab
addpath(pwd)
addpath(fullfile(pwd, 'examples'))
SankeyPlotExample()
```

`SankeyPlotExample` recreates the `slandarer/MATLAB-sankey-plot` demo6 chord
diagram style, with Baltamatica-oriented rendering choices for transparent
ribbons, ticks, and labels.

## ChartContainer Sketch

```matlab
classdef MyChart < gleamoe.graphics.chartcontainer.ChartContainer
    properties
        YData = rand(1, 10)
    end

    properties (Access = private)
        Line
    end

    methods
        function this = MyChart(varargin)
            this@gleamoe.graphics.chartcontainer.ChartContainer(varargin{:});
        end

        function set.YData(this, value)
            this.YData = value;
            requestUpdate(this);
        end
    end

    methods (Access = protected)
        function setup(this)
            ax = getAxes(this);
            this.Line = plot(ax, nan, nan);
        end

        function update(this)
            set(this.Line, 'YData', this.YData, 'XData', 1:numel(this.YData));
        end
    end
end
```

## Validation

This repository currently does not include a standalone test harness or
screenshot export tooling. For a quick MATLAB smoke test, run:

```powershell
matlab.exe -batch "addpath(pwd); addpath(fullfile(pwd,'plot')); addpath(fullfile(pwd,'examples')); chart=SankeyPlotExample(); disp(class(chart));"
```

Baltamatica `-nodesktop` sessions do not provide full graphics support for this
example because `axes` is unavailable there. Run graphics examples in the
Baltamatica desktop application.

See `docs/compatibility_matrix.md` for the current implementation notes.
