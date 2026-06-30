function run_unit_tests()
%run_unit_tests Run non-GUI tests for gleamoe.graphics.chartcontainer.
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(rootDir);
    addpath(fullfile(rootDir, 'tests', 'fixtures'));

    testLifecycle();
    testNameValueErrors();
    testBasePropertyValidation();
    testMixinSyntax();
    fprintf('run_unit_tests: passed\n');
end

function testLifecycle()
    chart = CounterChart('Value', 42, 'Label', 'answer', 'Visible', 'off');
    localAssert(chart.SetupCount == 1, 'setup should run once during construction.');
    localAssert(chart.UpdateCount == 1, 'update should run once after construction name-values.');
    localAssert(chart.Value == 42, 'Value name-value was not applied.');
    localAssert(strcmp(chart.Label, 'answer'), 'Label name-value was not applied.');
    localAssert(strcmp(chart.Visible, 'off'), 'Visible name-value was not applied.');

    chart.Value = 7;
    localAssert(chart.UpdateCount == 2, 'property assignment should request update.');
end

function testNameValueErrors()
    didError = false;
    try
        CounterChart('NoSuchProperty', 1);
    catch
        didError = true;
    end
    localAssert(didError, 'unknown name-value property should error.');

    didError = false;
    try
        CounterChart('Value');
    catch
        didError = true;
    end
    localAssert(didError, 'odd name-value count should error.');
end

function testBasePropertyValidation()
    chart = CounterChart();

    didError = false;
    try
        chart.Position = [1 2 3];
    catch
        didError = true;
    end
    localAssert(didError, 'Position should require a four-element vector.');

    chart.HandleVisibility = 'callback';
    localAssert(strcmp(chart.HandleVisibility, 'callback'), 'HandleVisibility should accept callback.');
end

function testMixinSyntax()
    chart = MixinSyntaxChart('Value', 3, 'LegendVisible', 'off', 'ColorbarVisible', 'off');
    localAssert(chart.Value == 3, 'mixin syntax fixture should inherit CounterChart.');
    localAssert(strcmp(chart.LegendVisible, 'off'), 'LegendVisible should accept off.');
    localAssert(strcmp(chart.ColorbarVisible, 'off'), 'ColorbarVisible should accept off.');
end

function localAssert(condition, messageText)
    if ~condition
        error('gleamoe:tests:AssertionFailed', messageText);
    end
end
