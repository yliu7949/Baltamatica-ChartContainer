function startup()
%startup Add Baltamatica ChartContainer project folders to the MATLAB path.
    rootDir = fileparts(mfilename('fullpath'));
    addpath(rootDir);
    addpath(fullfile(rootDir, 'plot'));
    addpath(fullfile(rootDir, 'examples'));
    addpath(fullfile(rootDir, 'tools'));
    rehash;

    % Clear MATLAB's loaded class cache when startup is rerun in an
    % existing session after example files have changed shape.
    try
        clear classes
    catch
    end
end
