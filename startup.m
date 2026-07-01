function startup()
%startup Add Baltamatica ChartContainer project folders to the MATLAB path.
    rootDir = fileparts(mfilename('fullpath'));
    addpath(rootDir);
    addpath(fullfile(rootDir, 'plot'));
    addpath(fullfile(rootDir, 'examples'));
    addpath(fullfile(rootDir, 'tools'));
end
