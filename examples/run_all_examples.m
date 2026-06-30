function results = run_all_examples(outputDir)
%run_all_examples Render all ChartContainer examples and save screenshots.
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(rootDir);
    addpath(fullfile(rootDir, 'plot'));
    addpath(fullfile(rootDir, 'examples'));
    addpath(fullfile(rootDir, 'tools'));

    if nargin < 1 || isempty(outputDir)
        outputDir = fullfile(rootDir, 'artifacts', 'screenshots');
    end
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    specs = { ...
        'confidence_chart', @() ConfidenceChart('XData', linspace(0, 4*pi, 120), 'YData', sin(linspace(0, 4*pi, 120)), 'ConfidenceMargin', 0.18); ...
        'smooth_legend_plot', @() SmoothLegendPlot('LegendVisible', 'on'); ...
        'surf_image_plot', @() SurfImagePlot('ColorbarVisible', 'on'); ...
        'cart_polar_plot', @() CartPolarPlot(); ...
        'local_extrema_chart', @() LocalExtremaChart(); ...
        'two_axes_chart', @() TwoAxesChart(); ...
        'sankey_demo6_chord_chart', @() SankeyDemo6ChordChart() ...
        };

    results = repmat(struct('Name', '', 'File', '', 'Status', '', 'Message', ''), 1, size(specs, 1));

    for idx = 1:size(specs, 1)
        name = specs{idx, 1};
        factory = specs{idx, 2};
        fileName = fullfile(outputDir, [name '.png']);
        try
            fig = figure('Visible', 'on', 'Color', 'w');
            factory();
            safeDrawnow();
            capture_current_figure(fileName);
            results(idx) = struct('Name', name, 'File', fileName, 'Status', 'passed', 'Message', '');
            try
                close(fig);
            catch
            end
        catch err
            results(idx) = struct('Name', name, 'File', fileName, 'Status', 'failed', 'Message', localErrorMessage(err));
            try
                close(gcf);
            catch
            end
        end
    end

    displayResults(results);
    writeResults(outputDir, results);
end

function safeDrawnow()
    if exist('drawnow', 'file') || exist('drawnow', 'builtin')
        try
            drawnow;
        catch
        end
    end
end

function displayResults(results)
    for idx = 1:numel(results)
        fprintf('%s: %s', results(idx).Name, results(idx).Status);
        if ~isempty(results(idx).Message)
            fprintf(' - %s', results(idx).Message);
        end
        fprintf('\n');
    end
end

function writeResults(outputDir, results)
    logFile = fullfile(outputDir, 'results.txt');
    fid = fopen(logFile, 'w');
    if fid < 0
        return
    end
    for idx = 1:numel(results)
        fprintf(fid, '%s: %s', results(idx).Name, results(idx).Status);
        if ~isempty(results(idx).Message)
            fprintf(fid, ' - %s', results(idx).Message);
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end

function messageText = localErrorMessage(err)
    messageText = '';
    try
        messageText = err.message;
    catch
    end

    if isempty(messageText)
        try
            messageText = lasterr; %#ok<LERR>
        catch
        end
    end

    if isempty(messageText)
        try
            messageText = char(err);
        catch
            messageText = 'Unknown error';
        end
    end
end
