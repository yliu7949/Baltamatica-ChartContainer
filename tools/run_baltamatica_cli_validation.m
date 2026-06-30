function run_baltamatica_cli_validation()
%run_baltamatica_cli_validation Run non-GUI tests in Baltamatica nodesktop mode.
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(rootDir);
    addpath(fullfile(rootDir, 'tests'));
    addpath(fullfile(rootDir, 'tests', 'fixtures'));
    run_unit_tests();
end
