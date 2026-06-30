function chart = show_baltamatica_example(exampleName)
%show_baltamatica_example Render one example and leave the figure open.
%   Baltamatica community builds used for validation do not provide
%   MATLAB's print/saveas/exportgraphics path. This helper lets desktop
%   automation capture the actual rendered figure window instead.
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(rootDir);
    addpath(fullfile(rootDir, 'plot'));
    addpath(fullfile(rootDir, 'examples'));
    addpath(fullfile(rootDir, 'tools'));

    if nargin < 1 || isempty(exampleName)
        exampleName = 'confidence_chart';
    end
    exampleName = lower(char(exampleName));

    figure('Visible', 'on', 'Color', 'w');
    switch exampleName
        case 'confidence_chart'
            chart = ConfidenceChart('XData', linspace(0, 4*pi, 120), ...
                'YData', sin(linspace(0, 4*pi, 120)), ...
                'ConfidenceMargin', 0.18);
        case 'smooth_legend_plot'
            chart = SmoothLegendPlot('LegendVisible', 'on');
        case 'surf_image_plot'
            chart = SurfImagePlot('ColorbarVisible', 'on');
        case 'cart_polar_plot'
            chart = CartPolarPlot();
        case 'local_extrema_chart'
            chart = LocalExtremaChart();
        case 'two_axes_chart'
            chart = TwoAxesChart();
        case 'sankey_demo6_chord_chart'
            chart = SankeyDemo6ChordChart();
        otherwise
            error(['Unknown example: ' exampleName]);
    end
    fprintf('%s: rendered\n', exampleName);
end
