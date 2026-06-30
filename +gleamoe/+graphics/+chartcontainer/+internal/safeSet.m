function safeSet(target, varargin)
%safeSet Best-effort set for graphics handles and helper handle classes.
    if isempty(target)
        return
    end

    try
        if isa(target, 'handle')
            set(target, varargin{:});
        elseif gleamoe.graphics.chartcontainer.internal.isLiveGraphics(target)
            set(target, varargin{:});
        end
    catch
    end
end
