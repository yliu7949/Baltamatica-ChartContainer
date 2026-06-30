function z = samplePeaks(n)
%samplePeaks Return MATLAB peaks-like sample data without toolbox plugins.
    if nargin < 1 || isempty(n)
        n = 49;
    end
    x = linspace(-3, 3, n);
    [xx, yy] = meshgrid(x, x);
    z = 3 * (1 - xx).^2 .* exp(-(xx.^2) - (yy + 1).^2) ...
        - 10 * (xx / 5 - xx.^3 - yy.^5) .* exp(-xx.^2 - yy.^2) ...
        - 1 / 3 * exp(-(xx + 1).^2 - yy.^2);
end
