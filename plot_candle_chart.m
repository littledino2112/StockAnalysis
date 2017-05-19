function plot_candle_chart( axis, tsobj )
%   This function plots candle chart of input object and simple moving
%   average of input data depends on its length
hold on;
dates = tsobj.dates;
close_price = fts2mat(tsobj.CLOSE);
candle(tsobj);
p = [];
legend_desc = {};
if (length(tsobj) >= 5)
    sma5 = tsmovavg(close_price,'s',5,1);
    p1 = plot(dates,sma5,'DisplayName','SMA5');
    p = [p p1];
    legend_desc = [legend_desc,{'SMA5'}];
end
if (length(tsobj) >= 20)
    sma20 = tsmovavg(close_price,'s',20,1);
    p2 = plot(dates,sma20,'DisplayName','SMA20');
    p = [p p2];
    legend_desc = [legend_desc,{'SMA20'}];
end
legend(p,legend_desc,'Location','northwest');
title(axis,'Candle chart');
hold off;
end

