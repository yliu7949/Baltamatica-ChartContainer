classdef SankeyDemo6ChordChart < gleamoe.graphics.chartcontainer.ChartContainer
    %SankeyDemo6ChordChart Chord-style Sankey demo adapted for ChartContainer.
    % Source demo: https://github.com/slandarer/MATLAB-sankey-plot/blob/main/sankeyDemo6.m

    properties
        Links = { ...
            'a1','A',1.2; 'a2','A',1; 'a1','B',0.6; 'a3','A',1; 'a3','C',0.5; ...
            'b1','B',0.4; 'b2','B',1; 'b3','B',1; 'c1','C',1; ...
            'c2','C',1; 'c3','C',1; 'A','AA',2; 'A','BB',1.2; ...
            'B','BB',1.5; 'B','AA',1.5; 'C','BB',2.3; 'C','AA',1.2}
        CData = [ ...
            65,140,240; 252,180,65; 224,64,10; 5,100,146; 191,191,191; ...
            26,59,105; 255,227,130; 18,156,221; 202,107,75; 0,92,219; ...
            243,210,136; 80,99,129; 241,185,168; 224,131,10; 120,147,190; ...
            127,91,93; 187,128,110; 197,173,143; 59,71,111; 104,95,126; ...
            76,103,86; 112,112,124; 72,39,24; 197,119,106; 160,126,88; ...
            238,208,146] ./ 255
        Arrow = 'on'
        ShowTicks = true
        ShowTickLabels = true
        TickRadius = 1.17
        LabelRadius = 1.38
        FontName = 'Cambria'
        LabelFontSize = 17
        TickFontSize = 11
    end

    properties (Access = private)
        ChartObjects = {}
    end

    methods
        function this = SankeyDemo6ChordChart(varargin)
            this@gleamoe.graphics.chartcontainer.ChartContainer(varargin{:});
        end

        function set.Links(this, value)
            this.Links = validateLinks(this, value);
            requestUpdate(this);
        end

        function set.CData(this, value)
            if ~isnumeric(value) || size(value, 2) ~= 3
                error('gleamoe:examples:CData', 'CData must be an N-by-3 RGB matrix.');
            end
            this.CData = max(0, min(1, double(value)));
            requestUpdate(this);
        end

        function set.Arrow(this, value)
            this.Arrow = gleamoe.graphics.chartcontainer.internal.mustBeOnOff(value, 'Arrow');
            requestUpdate(this);
        end

        function set.ShowTicks(this, value)
            this.ShowTicks = logicalScalar(this, value, 'ShowTicks');
            requestUpdate(this);
        end

        function set.ShowTickLabels(this, value)
            this.ShowTickLabels = logicalScalar(this, value, 'ShowTickLabels');
            requestUpdate(this);
        end

        function set.TickRadius(this, value)
            this.TickRadius = positiveScalar(this, value, 'TickRadius');
            requestUpdate(this);
        end

        function set.LabelRadius(this, value)
            this.LabelRadius = positiveScalar(this, value, 'LabelRadius');
            requestUpdate(this);
        end

        function set.FontName(this, value)
            this.FontName = gleamoe.graphics.chartcontainer.internal.mustBeText(value, 'FontName');
            requestUpdate(this);
        end

        function set.LabelFontSize(this, value)
            this.LabelFontSize = positiveScalar(this, value, 'LabelFontSize');
            requestUpdate(this);
        end

        function set.TickFontSize(this, value)
            this.TickFontSize = positiveScalar(this, value, 'TickFontSize');
            requestUpdate(this);
        end
    end

    methods (Access = protected)
        function setup(this)
            ax = getAxes(this);
            configureAxes(this, ax);
            redraw(this);
        end

        function update(this)
            redraw(this);
        end
    end

    methods (Access = private)
        function redraw(this)
            ax = getAxes(this);
            configureAxes(this, ax);
            clearChart(this);

            [labels, adj] = adjacencyFromLinks(this);
            geom = chordGeometry(this, adj);
            [outStart, outEnd, inStart, inEnd] = segmentAngles(this, adj, geom);

            for sourceIdx = 1:numel(labels)
                for targetIdx = 1:numel(labels)
                    if adj(sourceIdx, targetIdx) > 0
                        color = nodeColor(this, sourceIdx);
                        addRibbon(this, ax, outStart(sourceIdx, targetIdx), outEnd(sourceIdx, targetIdx), ...
                            inStart(sourceIdx, targetIdx), inEnd(sourceIdx, targetIdx), color);
                    end
                end
            end

            for nodeIdx = 1:numel(labels)
                color = nodeColor(this, nodeIdx);
                addNodeArc(this, ax, geom.Start(nodeIdx), geom.End(nodeIdx), color);
            end

            if this.ShowTicks
                addTicks(this, ax, geom, adj, outStart, outEnd, inStart, inEnd);
            end
            addLabels(this, ax, labels, geom);
        end

        function configureAxes(~, ax)
            cla(ax);
            hold(ax, 'on');
            axis(ax, 'equal');
            axis(ax, [-1.62 1.62 -1.62 1.62]);
            axis(ax, 'off');
            title(ax, 'sankey demo6');
        end

        function clearChart(this)
            for objIdx = 1:numel(this.ChartObjects)
                gleamoe.graphics.chartcontainer.internal.deleteGraphics(this.ChartObjects{objIdx});
            end
            this.ChartObjects = {};
        end

        function remember(this, graphicsObject)
            if ~isempty(graphicsObject)
                this.ChartObjects{end + 1} = graphicsObject;
            end
        end

        function [labels, adj] = adjacencyFromLinks(this)
            links = validateLinks(this, this.Links);
            labels = unique([links(:, 1); links(:, 2)], 'stable');

            adj = zeros(numel(labels));
            for linkIdx = 1:size(links, 1)
                sourceIdx = find(strcmp(labels, links{linkIdx, 1}), 1);
                targetIdx = find(strcmp(labels, links{linkIdx, 2}), 1);
                adj(sourceIdx, targetIdx) = links{linkIdx, 3};
            end
        end

        function geom = chordGeometry(~, adj)
            rowTotal = sum(adj, 2);
            colTotal = sum(adj, 1).';
            tickTotal = rowTotal + colTotal;
            spanWeight = tickTotal ./ 2;
            spanWeight(spanWeight <= 0) = eps;
            nodeCount = numel(spanWeight);
            gap = 2.4 * pi / 180;
            if nodeCount * gap > pi
                gap = pi / max(1, nodeCount * 2);
            end

            span = (2 * pi - nodeCount * gap) .* spanWeight ./ sum(spanWeight);
            startAngle = zeros(nodeCount, 1);
            endAngle = zeros(nodeCount, 1);
            splitAngle = zeros(nodeCount, 1);
            cursor = gap / 2;
            for nodeIdx = 1:nodeCount
                startAngle(nodeIdx) = cursor;
                endAngle(nodeIdx) = cursor + span(nodeIdx);
                if tickTotal(nodeIdx) > 0
                    splitAngle(nodeIdx) = startAngle(nodeIdx) + span(nodeIdx) .* colTotal(nodeIdx) ./ tickTotal(nodeIdx);
                else
                    splitAngle(nodeIdx) = (startAngle(nodeIdx) + endAngle(nodeIdx)) ./ 2;
                end
                cursor = endAngle(nodeIdx) + gap;
            end

            geom = struct('Start', startAngle, 'End', endAngle, 'Split', splitAngle, ...
                'Total', tickTotal, 'RowTotal', rowTotal, 'ColTotal', colTotal);
        end

        function [outStart, outEnd, inStart, inEnd] = segmentAngles(~, adj, geom)
            nodeCount = size(adj, 1);
            outStart = zeros(nodeCount);
            outEnd = zeros(nodeCount);
            inStart = zeros(nodeCount);
            inEnd = zeros(nodeCount);

            for nodeIdx = 1:nodeCount
                rowTotal = sum(adj(nodeIdx, :));
                if rowTotal > 0
                    cursor = geom.End(nodeIdx);
                    for targetIdx = 1:nodeCount
                        flowSpan = (geom.Split(nodeIdx) - geom.End(nodeIdx)) * adj(nodeIdx, targetIdx) / rowTotal;
                        outStart(nodeIdx, targetIdx) = cursor;
                        outEnd(nodeIdx, targetIdx) = cursor + flowSpan;
                        cursor = cursor + flowSpan;
                    end
                end

                colTotal = sum(adj(:, nodeIdx));
                if colTotal > 0
                    cursor = geom.Split(nodeIdx);
                    for sourceIdx = 1:nodeCount
                        flowSpan = (geom.Start(nodeIdx) - geom.Split(nodeIdx)) * adj(sourceIdx, nodeIdx) / colTotal;
                        inStart(sourceIdx, nodeIdx) = cursor;
                        inEnd(sourceIdx, nodeIdx) = cursor + flowSpan;
                        cursor = cursor + flowSpan;
                    end
                end
            end
        end

        function addRibbon(this, ax, sourceStart, sourceEnd, targetStart, targetEnd, color)
            innerRadius = 1.0;
            control = [0, 0];
            pointA = circlePoint(this, innerRadius, sourceStart);
            pointD = circlePoint(this, innerRadius, sourceEnd);

            if strcmp(this.Arrow, 'on')
                pointB = circlePoint(this, innerRadius * 0.96, targetEnd);
                pointC = circlePoint(this, innerRadius * 0.96, targetStart);
                targetMid = (targetStart + targetEnd) / 2;
                targetArc = [ ...
                    pointB; ...
                    circlePoint(this, innerRadius * 0.99, targetMid); ...
                    pointC];
            else
                pointB = circlePoint(this, innerRadius, targetEnd);
                pointC = circlePoint(this, innerRadius, targetStart);
                targetArc = arcPoints(this, innerRadius, targetEnd, targetStart, 60);
            end

            curveAB = quadraticBezier(this, pointA, control, pointB, 160);
            curveCD = quadraticBezier(this, pointC, control, pointD, 160);
            sourceArc = arcPoints(this, innerRadius, sourceEnd, sourceStart, 60);

            ribbon = [curveAB; targetArc; curveCD; sourceArc];
            h = patch(ax, ribbon(:, 1), ribbon(:, 2), color, 'EdgeColor', 'none');
            gleamoe.graphics.chartcontainer.internal.safeSet(h, 'FaceAlpha', 0.32);
            remember(this, h);
        end

        function addNodeArc(this, ax, startAngle, endAngle, color)
            innerRadius = 1.05;
            outerRadius = 1.15;
            theta = linspace(startAngle, endAngle, 100);
            x = [outerRadius .* cos(theta), innerRadius .* cos(fliplr(theta))];
            y = [outerRadius .* sin(theta), innerRadius .* sin(fliplr(theta))];
            h = patch(ax, x, y, color, 'EdgeColor', 'none');
            remember(this, h);
        end

        function addTicks(this, ax, geom, adj, outStart, outEnd, inStart, inEnd)
            tickColor = [0, 0, 0];
            for nodeIdx = 1:numel(geom.Total)
                thetaArc = linspace(geom.Start(nodeIdx), geom.End(nodeIdx), 100);
                h = line(ax, cos(thetaArc) .* this.TickRadius, sin(thetaArc) .* this.TickRadius, ...
                    'Color', tickColor, 'LineWidth', 0.8);
                remember(this, h);

                [tickAngles, tickValues] = nodeTickData(this, adj, nodeIdx, outStart, outEnd, inStart, inEnd);
                for tickIdx = 1:numel(tickAngles)
                    theta = tickAngles(tickIdx);
                    p0 = circlePoint(this, this.TickRadius, theta);
                    p1 = circlePoint(this, this.TickRadius + 0.02, theta);
                    h = line(ax, [p0(1), p1(1)], [p0(2), p1(2)], 'Color', tickColor, 'LineWidth', 0.8);
                    remember(this, h);

                    if this.ShowTickLabels
                        pt = circlePoint(this, this.TickRadius + 0.03, theta);
                        tickLabel = compactNumber(this, tickValues(tickIdx));
                        [rotation, align] = tickLabelPlacement(this, theta);
                        h = text(ax, pt(1), pt(2), tickLabel, 'Color', tickColor, ...
                            'FontName', this.FontName, 'FontSize', this.TickFontSize, ...
                            'Rotation', rotation, ...
                            'HorizontalAlignment', align, ...
                            'VerticalAlignment', 'middle');
                        remember(this, h);
                    end
                end
            end
        end

        function addLabels(this, ax, labels, geom)
            for nodeIdx = 1:numel(labels)
                theta = (geom.Start(nodeIdx) + geom.End(nodeIdx)) / 2;
                pt = circlePoint(this, this.LabelRadius, theta);
                rotation = labelRotation(this, theta);
                h = text(ax, pt(1), pt(2), labels{nodeIdx}, ...
                    'FontName', this.FontName, ...
                    'FontSize', this.LabelFontSize, ...
                    'FontWeight', 'bold', ...
                    'Color', [0.12, 0.13, 0.16], ...
                    'HorizontalAlignment', 'center', ...
                    'VerticalAlignment', 'middle', ...
                    'Rotation', rotation);
                remember(this, h);
            end
        end

        function [tickAngles, tickValues] = nodeTickData(~, adj, nodeIdx, outStart, outEnd, inStart, inEnd)
            tickAngles = [];
            tickValues = [];
            currentValue = 0;
            rowTargets = find(adj(nodeIdx, :) > 0);
            for idx = 1:numel(rowTargets)
                targetIdx = rowTargets(idx);
                if isempty(tickAngles)
                    tickAngles(end + 1) = outStart(nodeIdx, targetIdx); %#ok<AGROW>
                    tickValues(end + 1) = currentValue; %#ok<AGROW>
                end
                currentValue = currentValue + adj(nodeIdx, targetIdx);
                tickAngles(end + 1) = outEnd(nodeIdx, targetIdx); %#ok<AGROW>
                tickValues(end + 1) = currentValue; %#ok<AGROW>
            end

            colSources = find(adj(:, nodeIdx).' > 0);
            for idx = 1:numel(colSources)
                sourceIdx = colSources(idx);
                if isempty(tickAngles) || abs(tickAngles(end) - inStart(sourceIdx, nodeIdx)) > eps
                    tickAngles(end + 1) = inStart(sourceIdx, nodeIdx); %#ok<AGROW>
                    tickValues(end + 1) = currentValue; %#ok<AGROW>
                end
                currentValue = currentValue + adj(sourceIdx, nodeIdx);
                tickAngles(end + 1) = inEnd(sourceIdx, nodeIdx); %#ok<AGROW>
                tickValues(end + 1) = currentValue; %#ok<AGROW>
            end
        end

        function color = nodeColor(this, idx)
            colorCount = size(this.CData, 1);
            color = this.CData(mod(idx - 1, colorCount) + 1, :);
        end

        function points = quadraticBezier(~, pointA, pointB, pointC, count)
            t = linspace(0, 1, count).';
            points = (1 - t).^2 .* pointA + 2 .* (1 - t) .* t .* pointB + t.^2 .* pointC;
        end

        function points = arcPoints(this, radius, startAngle, endAngle, count)
            theta = linspace(startAngle, endAngle, count).';
            points = [radius .* cos(theta), radius .* sin(theta)];
        end

        function point = circlePoint(~, radius, theta)
            point = [radius .* cos(theta), radius .* sin(theta)];
        end

        function align = horizontalAlignment(~, theta)
            if cos(theta) >= 0
                align = 'left';
            else
                align = 'right';
            end
        end

        function [rotation, align] = tickLabelPlacement(~, theta)
            rotation = mod(theta ./ pi .* 180, 360);
            if rotation > 90 && rotation < 270
                rotation = rotation + 180;
                align = 'right';
            else
                align = 'left';
            end
        end

        function rotation = labelRotation(~, theta)
            theta = mod(theta, 2 * pi);
            if theta > 0 && theta < pi
                rotation = -(0.5 * pi - theta) ./ pi .* 180;
            else
                rotation = -(1.5 * pi - theta) ./ pi .* 180;
            end
        end

        function value = positiveScalar(~, value, propertyName)
            if ~isnumeric(value) || ~isscalar(value) || value <= 0
                error('gleamoe:examples:PositiveScalar', '%s must be a positive numeric scalar.', propertyName);
            end
            value = double(value);
        end

        function value = logicalScalar(~, value, propertyName)
            if ~(islogical(value) || isnumeric(value)) || ~isscalar(value)
                error('gleamoe:examples:LogicalScalar', '%s must be a logical scalar.', propertyName);
            end
            value = logical(value);
        end

        function label = compactNumber(~, value)
            if abs(value - round(value)) < 1e-10
                label = sprintf('%.0f', value);
            else
                label = sprintf('%.1f', value);
            end
        end

        function links = validateLinks(~, links)
            if ~iscell(links) || size(links, 2) ~= 3
                error('gleamoe:examples:Links', 'Links must be a cell array with source, target, and value columns.');
            end
            for linkIdx = 1:size(links, 1)
                if ~(ischar(links{linkIdx, 1}) || isstring(links{linkIdx, 1})) || ...
                        ~(ischar(links{linkIdx, 2}) || isstring(links{linkIdx, 2}))
                    error('gleamoe:examples:Links', 'Link source and target values must be text.');
                end
                if ~isnumeric(links{linkIdx, 3}) || ~isscalar(links{linkIdx, 3}) || links{linkIdx, 3} < 0
                    error('gleamoe:examples:Links', 'Link values must be nonnegative numeric scalars.');
                end
                links{linkIdx, 1} = char(links{linkIdx, 1});
                links{linkIdx, 2} = char(links{linkIdx, 2});
                links{linkIdx, 3} = double(links{linkIdx, 3});
            end
        end
    end
end
