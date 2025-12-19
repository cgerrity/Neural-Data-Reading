function PlotHandle = cgg_setGraphicsLayer(PlotHandle,SendDirection)
%CGG_SETGRAPHICSLAYER Summary of this function goes here
%   Detailed explanation goes here


AllGraphics = PlotHandle.Parent.Children;
NumGraphics = length(AllGraphics);

MatchingIDX = false(size(AllGraphics));
for gidx = 1:NumGraphics
    this_Graphics = AllGraphics(gidx);
    % this_Layer = gidx;
    % try
    %     this_Graphics.ZData = ones(size(this_Graphics.XData))*this_Layer;
    % catch
    %     try
    %         this_Graphics.ZData = ones(size(this_Graphics.YData))*this_Layer;
    %     catch
    %     end
    % end
    MatchingIDX(gidx) = isequal(this_Graphics,PlotHandle);
end
MatchingIDX = find(MatchingIDX);
GraphicsOrder = 1:NumGraphics;
GraphicsNewOrder = GraphicsOrder;
GraphicsNewOrder(MatchingIDX) = [];
switch SendDirection
    case 'Back'
        GraphicsNewOrder = [GraphicsNewOrder,MatchingIDX];
    case 'Front'
        GraphicsNewOrder = [MatchingIDX,GraphicsNewOrder];
    otherwise
        GraphicsNewOrder = GraphicsOrder;
end
% test
PlotHandle.Parent.Children = PlotHandle.Parent.Children(GraphicsNewOrder);
end

