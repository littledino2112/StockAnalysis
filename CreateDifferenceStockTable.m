load('config.mat');
path_to_database = path_to_db;
conn = database(path_to_database,'','','org.sqlite.JDBC',strcat('jdbc:sqlite:',path_to_database));
sql_query = 'SELECT DISTINCT SYMBOL FROM STOCK';
raw_data = fetch(conn, sql_query);
raw_data = table2array(raw_data);

% Create another table called HOSE_STOCK_DIFF
table_name = 'HOSE_STOCK_DIFF';
curs = exec(conn, ['CREATE TABLE IF NOT EXISTS ' table_name '('...
                  'SYMBOL                      TEXT,'...
                  'DATE                        INTEGER,'...
                  'CLOSE_DIFF                  REAL,'...
                  'CLOSE_DIFF_PERCENTAGE       REAL,'...
                  'OPEN_CLOSE_DIFF             REAL,'...
                  'OPEN_CLOSE_DIFF_PERCENTAGE  REAL,'...
                  'VOLUME_DIFF                 INTEGER,'...
                  'VOLUME_DIFF_PERCENTAGE      REAL);']);
close(curs);
final_data = [];
% For every stock in the list:
%   Get Symbol, Date, Close and Volume colume
%   Convert to Time Series object
%   Use Diff operation to compute the change from this day compared to the 
%                   day before
%   Extract info and save to new table
len = length(raw_data);
colnames = {'SYMBOL','DATE','CLOSE_DIFF','CLOSE_DIFF_PERCENTAGE',...
            'OPEN_CLOSE_DIFF','OPEN_CLOSE_DIFF_PERCENTAGE','VOLUME_DIFF','VOLUME_DIFF_PERCENTAGE'};
for idx = 1:len
    disp(idx/len*100); % Keep track of progress
    sql_query = ['SELECT SYMBOL, DATE, CLOSE, OPEN, VOLUME FROM STOCK WHERE SYMBOL = ''' raw_data{idx} ''''];
    symbol_data = fetch(conn, sql_query);
    if (height(symbol_data) == 1)   % If only one data point is available, can't compute diff in this case
       continue;     
    end
    selected_stock = fints(symbol_data.DATE, [symbol_data.OPEN symbol_data.CLOSE symbol_data.VOLUME],{'OPEN', 'CLOSE', 'VOLUME'});
    [selected_stock_diff, selected_stock_percentage_change] = CalculatePercentageChangeOfStock(selected_stock);
    
    % Extract data to a cell
    close_diff = fts2mat(selected_stock_diff.CLOSE,1);
    vol_diff = fts2mat(selected_stock_diff.VOLUME);
    close_diff_per = fts2mat(selected_stock_percentage_change.CLOSE);
    vol_diff_per = fts2mat(selected_stock_percentage_change.VOLUME);
    selected_stock = selected_stock(2:end);
    open_close_diff = fts2mat(selected_stock.CLOSE) - fts2mat(selected_stock.OPEN);
    open_close_diff_percentage = open_close_diff./fts2mat(selected_stock.OPEN)*100;
    
    temp_cell = cell([length(vol_diff) 8]); % 8 rows as created for the table above
    symbol_name = {raw_data{idx}};
    symbol_name = symbol_name(ones(length(vol_diff),1),:);
    temp_cell(:,1) = symbol_name; % For SYMBOL
    temp_cell(:,2) = num2cell(close_diff(:,1)); % For Date
    temp_cell(:,3) = num2cell(close_diff(:,2)); % For Close_Diff
    temp_cell(:,4) = num2cell(close_diff_per); % For Close_Diff in percentage
    temp_cell(:,5) = num2cell(open_close_diff); % For Open_Close_Diff
    temp_cell(:,6) = num2cell(open_close_diff_percentage); % For Open_Close_Diff in percentage
    temp_cell(:,7) = num2cell(vol_diff);    % For Volume_Diff
    temp_cell(:,8) = num2cell(vol_diff_per); % For Volume_Diff in percentage
    final_data = [final_data; temp_cell];
end
final_data = cell2table(final_data);
final_data.Properties.VariableNames = colnames;
writetable(final_data,'exported_hose_stock_diff_data.csv');

function [raw_diff, percentage_diff] = CalculatePercentageChangeOfStock(ts_obj)
    old_obj = ts_obj;
    raw_diff = diff(old_obj); % Compare differences of all items in TS obj (compared to the date before)
    old_obj = lagts(old_obj); % Delay one day since the new_obj do not have the first date
    percentage_diff = raw_diff ./ old_obj(2:end) * 100;
end