function ax = createAxes(parent, axesType, varargin)
%createAxes Create an axes object with fallback paths for Baltamatica.
    args = varargin;
    axesType = lower(char(axesType));

    switch axesType
        case {'cartesian','axes'}
            ax = createCartesian(parent, args);
        case {'polar','polaraxes'}
            ax = createPolar(parent, args);
        otherwise
            error('gleamoe:chartcontainer:AxesType', ...
                'Unsupported axes type "%s".', axesType);
    end
end

function ax = createCartesian(parent, args)
    if ~isempty(parent)
        try
            ax = axes('Parent', parent, args{:});
            return
        catch
        end
    end

    try
        ax = axes(args{:});
    catch err
        error(['Unable to create axes. In Baltamatica, run graphics examples in desktop mode. Original error: ' ...
            gleamoe.graphics.chartcontainer.internal.errorMessage(err)]);
    end
end

function ax = createPolar(parent, args)
    if exist('polaraxes', 'file') || exist('polaraxes', 'builtin')
        if ~isempty(parent)
            try
                ax = polaraxes('Parent', parent, args{:});
                return
            catch
            end
        end

        try
            ax = polaraxes(args{:});
            return
        catch
        end
    end

    ax = createCartesian(parent, args);
end
