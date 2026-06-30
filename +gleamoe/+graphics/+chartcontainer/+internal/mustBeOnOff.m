function value = mustBeOnOff(value, propName)
%mustBeOnOff Validate on/off text.
    value = gleamoe.graphics.chartcontainer.internal.mustBeChoice(value, {'on','off'}, propName);
end
