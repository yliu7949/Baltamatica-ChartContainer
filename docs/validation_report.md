# Validation Notes

Date: 2026-07-01

## MATLAB R2026a

Smoke test command:

```powershell
matlab.exe -batch "addpath(pwd); addpath(fullfile(pwd,'plot')); addpath(fullfile(pwd,'examples')); chart=SankeyPlotExample(); disp(class(chart));"
```

Expected result:

- Creates the Sankey/chord example figure.
- Prints `gleamoe.chart.SankeyPlotChart`.

## Baltamatica

Graphics examples should be run in the Baltamatica desktop application.

`baltamaticaCLI.exe -nodesktop` is still useful for non-graphics checks, but it
does not provide the `axes` function required by the chart container graphics
path in this example.

## Historical Notes

Older automation commands and screenshot listings were removed because they no
longer match the current repository layout.
