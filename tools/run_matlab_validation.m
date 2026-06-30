function run_matlab_validation()
%run_matlab_validation Run MATLAB tests and render example screenshots.
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(rootDir);
    addpath(fullfile(rootDir, 'examples'));
    addpath(fullfile(rootDir, 'tests'));
    addpath(fullfile(rootDir, 'tests', 'fixtures'));

    run_unit_tests();
    outDir = fullfile(rootDir, 'artifacts', 'matlab-screenshots');
    results = run_all_examples(outDir);
    assert(all(strcmp({results.Status}, 'passed')), 'One or more MATLAB example screenshots failed.');
end
