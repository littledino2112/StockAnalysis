function [ diff_results ] = calculate_diff_data( input_stock_data, stock_symbol )
% Input time series object needs to contain following fields: DATE, OPEN, CLOSE
% and VOLUME
    [selected_stock_diff, selected_stock_percentage_change] = CalculatePercentageChangeOfStock(input_stock_data);
    
    % Extract data to a cell
    close_diff = fts2mat(selected_stock_diff.CLOSE,1);
    vol_diff = fts2mat(selected_stock_diff.VOLUME);
    close_diff_per = fts2mat(selected_stock_percentage_change.CLOSE);
    vol_diff_per = fts2mat(selected_stock_percentage_change.VOLUME);
    selected_stock = input_stock_data(2:end);
    open_close_diff = fts2mat(selected_stock.CLOSE) - fts2mat(selected_stock.OPEN);
    open_close_diff_percentage = open_close_diff./fts2mat(selected_stock.OPEN);
    vol_diff = round(vol_diff*100)/100;
    close_diff = round(close_diff*100)/100;
    vol_diff_per = round(vol_diff_per*1000)/10;
    close_diff_per = round(close_diff_per*1000)/10;
    open_close_diff = round(open_close_diff*100)/100;
    open_close_diff_percentage = round(open_close_diff_percentage*1000)/10;
    
    diff_results = cell([length(vol_diff) 9]); % 9 rows as created for the table above
    symbol_name = {stock_symbol};
    symbol_name = symbol_name(ones(length(vol_diff),1),:);
    diff_results(:,1) = symbol_name; % For SYMBOL
    diff_results(:,2) = num2cell(close_diff(:,1)); % For Date
    diff_results(:,3) = num2cell(close_diff(:,2)); % For Close_Diff
    diff_results(:,4) = num2cell(close_diff_per); % For Close_Diff in percentage
    diff_results(:,5) = num2cell(open_close_diff); % For Open_Close_Diff
    diff_results(:,6) = num2cell(open_close_diff_percentage); % For Open_Close_Diff in percentage
    diff_results(:,7) = num2cell(vol_diff);    % For Volume_Diff
    diff_results(:,8) = num2cell(vol_diff_per); % For Volume_Diff in percentage
    % For Symbol_Date column
    temp = num2str(close_diff(:,1));
    diff_results(:,9) = strcat(symbol_name,temp);
end


function [raw_diff, percentage_diff] = CalculatePercentageChangeOfStock(ts_obj)
    old_obj = ts_obj;
    raw_diff = diff(old_obj); % Compare differences of all items in TS obj (compared to the date before)
    old_obj = lagts(old_obj); % Delay one day since the new_obj do not have the first date
    percentage_diff = raw_diff./ old_obj(2:end);
end
