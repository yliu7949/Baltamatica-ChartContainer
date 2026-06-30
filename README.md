# gleamoe.graphics.chartcontainer

MATLAB-style chart container classes for Baltamatica experiments.

The implementation mirrors the public `matlab.graphics.chartcontainer.*` authoring model:

- subclass `gleamoe.graphics.chartcontainer.ChartContainer`;
- implement protected `setup(this)` and `update(this)`;
- call `requestUpdate(this)` from custom property setters;
- optionally mix in `gleamoe.graphics.chartcontainer.mixin.Legend` or `gleamoe.graphics.chartcontainer.mixin.Colorbar`;
- call the superclass constructor from subclasses with `varargin`.

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

Run tests and examples:

```matlab
addpath(pwd)
run('tests/run_unit_tests.m')
run('examples/run_all_examples.m')
```

Validation entry points:

- MATLAB: `tools/run_matlab_validation.m`
- Baltamatica CLI: `tools/run_baltamatica_cli_validation.m`
- Baltamatica desktop live render: `tools/run_baltamatica_gui_validation.m`
- Baltamatica single-window render for desktop capture: `tools/show_baltamatica_example.m`

See `docs/compatibility_matrix.md` for implemented, degraded, and blocked behavior.
