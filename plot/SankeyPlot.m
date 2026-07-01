function chart = SankeyPlot(varargin)
%SankeyPlot Create a chord-style Sankey plot with Gleamoe ChartContainer.
%   chart = SankeyPlot(links) creates a Sankey chord plot from an N-by-3
%   cell array: source, target, and value.
%
%   chart = SankeyPlot(source, target, value) creates the plot from separate
%   source, target, and value vectors.
%
%   chart = SankeyPlot(adjMat, 'Label', labels) creates the plot from an
%   adjacency matrix where adjMat(i,j) is the flow from labels{i} to labels{j}.
%
%   Name-value pairs control appearance, including CData, Arrow, ShowTicks,
%   ShowTickLabels, TickRadius, LabelRadius, FontName, LabelFontSize,
%   TickFontSize, Title, RibbonAlpha, Sep, InnerRadius, SquareRadius, and AxesLimit.

    [dataArgs, chartArgs] = parseSankeyInputs(varargin{:});
    chart = gleamoe.chart.SankeyPlotChart(dataArgs{:}, chartArgs{:});
end

function [dataArgs, chartArgs] = parseSankeyInputs(varargin)
    if nargin == 0
        error('gleamoe:plot:SankeyPlot:Input', ...
            'SankeyPlot requires links, source/target/value vectors, or an adjacency matrix.');
    end

    parentArgs = {};
    if isAxesLike(varargin{1})
        parentArgs = {'Parent', varargin{1}};
        varargin(1) = [];
    end

    if isempty(varargin)
        error('gleamoe:plot:SankeyPlot:Input', 'Missing Sankey plot data.');
    end

    if isnumeric(varargin{1}) && ismatrix(varargin{1}) && size(varargin{1}, 1) == size(varargin{1}, 2)
        dataArgs = {'AdjMat', varargin{1}};
        chartArgs = varargin(2:end);
    elseif iscell(varargin{1}) && size(varargin{1}, 2) == 3
        links = varargin{1};
        dataArgs = {'Source', links(:, 1), 'Target', links(:, 2), 'Value', links(:, 3)};
        chartArgs = varargin(2:end);
    elseif numel(varargin) >= 3 && ~isNameToken(varargin{1})
        dataArgs = {'Source', varargin{1}, 'Target', varargin{2}, 'Value', varargin{3}};
        chartArgs = varargin(4:end);
    else
        dataArgs = {};
        chartArgs = varargin;
    end

    chartArgs = normalizeNameValueAliases(chartArgs);
    dataArgs = [parentArgs, dataArgs];
    if isempty(dataArgs) && ~containsName(chartArgs, {'Source','Target','Value','AdjMat'})
        error('gleamoe:plot:SankeyPlot:Input', ...
            'SankeyPlot requires links, source/target/value vectors, or an adjacency matrix.');
    end
end

function tf = isAxesLike(value)
    tf = false;
    try
        tf = isgraphics(value, 'axes');
    catch
        try
            tf = strcmp(get(value, 'Type'), 'axes');
        catch
        end
    end
end

function tf = isNameToken(value)
    tf = ischar(value) || (isstring(value) && isscalar(value));
end

function args = normalizeNameValueAliases(args)
    for idx = 1:2:numel(args)
        if idx > numel(args) || ~isNameToken(args{idx})
            continue
        end

        name = char(args{idx});
        switch lower(name)
            case {'labels','nodelist','nodes'}
                args{idx} = 'Label';
            case {'color','colors','colordata'}
                args{idx} = 'CData';
            case {'ticklabels','showticklabel'}
                args{idx} = 'ShowTickLabels';
            case {'tickstate'}
                args{idx} = 'ShowTicks';
        end
    end
end

function tf = containsName(args, names)
    tf = false;
    for idx = 1:2:numel(args)
        if isNameToken(args{idx}) && any(strcmpi(char(args{idx}), names))
            tf = true;
            return
        end
    end
end
