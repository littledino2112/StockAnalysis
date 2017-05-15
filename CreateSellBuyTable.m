load('config.mat');
path_to_database = path_to_db;
conn = database(path_to_database,'','','org.sqlite.JDBC',strcat('jdbc:sqlite:',path_to_database));
create_sell_buy_table(conn, 'HOSE_SELL_BUY_NATIONAL');
create_sell_buy_table(conn, 'HOSE_SELL_BUY_FOREIGNER');

col_names = {'Symbol','Date','Open','High','Low','Close','Buy','Sell'};
sell_buy_national = load_data('CafeF.CC_HSX.Upto12.05.2017.csv',col_names);
sell_buy_national.Date = datenum(sell_buy_national.Date);
date_temp = num2str(sell_buy_national.Date);
sell_buy_national.Symbol = cellfun(@(x) x(4:end),sell_buy_national.Symbol,'UniformOutput',false);
sell_buy_national.SymbolDate = strcat(sell_buy_national.Symbol,date_temp);
sell_buy_national(:,{'Open','High','Low','Close'}) = [];
writetable(sell_buy_national,'hose_sell_buy_national.csv','WriteVariableNames',0);

col_names = {'Symbol','Date','Buy','High','Low','Sell','Volume','OI'};
sell_buy_foreigners = load_data('CafeF.NN_HSX.Upto12.05.2017.csv',col_names);
sell_buy_foreigners.Date = datenum(sell_buy_foreigners.Date);
date_temp = num2str(sell_buy_foreigners.Date);
sell_buy_foreigners.Symbol = cellfun(@(x) x(4:end),sell_buy_foreigners.Symbol,'UniformOutput',false);
sell_buy_foreigners.SymbolDate = strcat(sell_buy_foreigners.Symbol,date_temp);
sell_buy_foreigners(:,{'Volume','High','Low','OI'}) = [];
writetable(sell_buy_foreigners,'hose_sell_buy_foreigners.csv','WriteVariableNames',0);

%% Function to load data from csv file and prepare it in the right format
function [raw_data] = load_data(input_file,colume_names)
    opts = detectImportOptions(input_file);
    opts.VariableNames = colume_names;
  %  opts = opts.setvartype('Symbol','string');
    opts = opts.setvartype('Date','datetime');
    opts = opts.setvaropts('Date','InputFormat','yyyyMMdd');
    opts = opts.setvaropts('Date','DatetimeFormat','ddMMMyyyy');
    temp_data = readtable(input_file,opts);
    raw_data = temp_data;
end

%% Function to create Sell-Buy stock table
function create_sell_buy_table(conn, table_name)
    sql_query = ['CREATE TABLE IF NOT EXISTS ' table_name ' ('...
                 'SYMBOL   TEXT,'...
                 'DATE     INTEGER,'...
                 'BUY     INTEGER,'...
                 'SELL      INTEGER,'...
                 'SYMBOL_DATE TEXT UNIQUE);'];
    curs = exec(conn,sql_query);
    close(curs);
end