# Validation Report

Date: 2026-06-30

## MATLAB R2026a

Command:

```powershell
& 'E:\Program Files\MATLAB\R2026a\bin\matlab.exe' -batch "addpath(pwd); addpath(fullfile(pwd,'tools')); run_matlab_validation();"
```

Result:

- `run_unit_tests: passed`
- `confidence_chart: passed`
- `smooth_legend_plot: passed`
- `surf_image_plot: passed`
- `cart_polar_plot: passed`
- `local_extrema_chart: passed`
- `two_axes_chart: passed`

Generated screenshots:

- `artifacts/matlab-screenshots/confidence_chart.png`
- `artifacts/matlab-screenshots/smooth_legend_plot.png`
- `artifacts/matlab-screenshots/surf_image_plot.png`
- `artifacts/matlab-screenshots/cart_polar_plot.png`
- `artifacts/matlab-screenshots/local_extrema_chart.png`
- `artifacts/matlab-screenshots/two_axes_chart.png`

## Baltamatica CLI

Command:

```powershell
& 'E:\Program Files\baltamatica\lib\baltamaticaCLI.exe' -nodesktop -s "addpath(pwd); addpath(fullfile(pwd,'tools')); run_baltamatica_cli_validation();"
```

Result:

- Community edition warning due local license check.
- `run_unit_tests: passed`

## Baltamatica Desktop

GUI command entered in the Baltamatica desktop command window:

```matlab
cd('C:\Users\lenovo\Documents\Baltamatica ChartContainer')
addpath(pwd)
addpath(fullfile(pwd,'tools'))
run_baltamatica_gui_validation()
```

Result:

- `confidence_chart: rendered`
- `smooth_legend_plot: rendered`
- `surf_image_plot: rendered`
- `cart_polar_plot: rendered`
- `local_extrema_chart: rendered`
- `two_axes_chart: rendered`

The Baltamatica desktop can render the figures, but this build does not provide MATLAB's `drawnow`, `exportgraphics`, `saveas`, or `print` APIs. PNG artifacts were captured from live figure windows with computer-use/Windows Graphics Capture.

Captured screenshots:

- `artifacts/baltamatica-window-screenshots/confidence_chart.png`
- `artifacts/baltamatica-window-screenshots/smooth_legend_plot.png`
- `artifacts/baltamatica-window-screenshots/surf_image_plot.png`
- `artifacts/baltamatica-window-screenshots/cart_polar_plot.png`
- `artifacts/baltamatica-window-screenshots/local_extrema_chart.png`
- `artifacts/baltamatica-window-screenshots/two_axes_chart.png`

Notes:

- `run_all_examples` remains the MATLAB screenshot export path.
- `run_baltamatica_gui_validation` is the Baltamatica live-render path and writes `artifacts/baltamatica-screenshots/results.txt`.
- `tools/show_baltamatica_example.m` opens one live Baltamatica figure at a time for desktop screenshot capture.
