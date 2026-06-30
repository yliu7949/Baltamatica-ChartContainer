function capture_current_figure(fileName)
%capture_current_figure Save the current figure as a PNG using available APIs.
    folder = fileparts(fileName);
    if ~isempty(folder) && ~exist(folder, 'dir')
        mkdir(folder);
    end

    fig = gcf;
    try
        exportgraphics(fig, fileName);
        return
    catch
    end

    try
        saveas(fig, fileName);
        return
    catch
    end

    try
        print(fig, fileName, '-dpng');
        return
    catch err
        error(['Unable to capture the current figure. Original error: ' ...
            gleamoe.graphics.chartcontainer.internal.errorMessage(err)]);
    end
end
