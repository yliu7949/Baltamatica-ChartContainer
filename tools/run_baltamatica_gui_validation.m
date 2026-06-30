function results = run_baltamatica_gui_validation()
%run_baltamatica_gui_validation Render examples in Baltamatica desktop mode.
%   Baltamatica community builds used during validation do not expose
%   MATLAB's print/saveas/exportgraphics APIs. This desktop entry point
%   opens live figure windows and records render status. Use
%   tools/show_baltamatica_example with computer-use window capture to
%   create PNG artifacts.
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(rootDir);
    addpath(fullfile(rootDir, 'examples'));
    addpath(fullfile(rootDir, 'tools'));
    outDir = fullfile(rootDir, 'artifacts', 'baltamatica-screenshots');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    names = { ...
        'confidence_chart', ...
        'smooth_legend_plot', ...
        'surf_image_plot', ...
        'cart_polar_plot', ...
        'local_extrema_chart', ...
        'two_axes_chart' ...
        };
    results = repmat(struct('Name', '', 'Status', '', 'Message', ''), 1, numel(names));

    for idx = 1:numel(names)
        name = names{idx};
        try
            show_baltamatica_example(name);
            results(idx) = struct('Name', name, 'Status', 'rendered', 'Message', '');
        catch err
            results(idx) = struct('Name', name, 'Status', 'failed', 'Message', localErrorMessage(err));
        end
    end

    displayResults(results);
    writeResults(outDir, results);
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
