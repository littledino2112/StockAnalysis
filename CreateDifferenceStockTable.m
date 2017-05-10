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
    diff_results = calculate_diff_data(selected_stock, raw_data{idx});
    final_data = [final_data; diff_results];
end
final_data = cell2table(final_data);
final_data.Properties.VariableNames = colnames;
writetable(final_data,'exported_hose_stock_diff_data.csv','WriteVariableNames',0);
