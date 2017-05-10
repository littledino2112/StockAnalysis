% This script does preparation steps to import stock data from csv into a
% database
% Database needs to be created first using sqlite3 command line tool
load config.mat
input_file = 'CafeF.INDEX.Upto09.05.2017.csv';
disp('Loading data');
input_data = load_data(input_file);
disp('Finish loading');
input_data.Date = datenum(input_data.Date);
temp = num2str(input_data.Date);
input_data.SymbolDate = strcat(input_data.Symbol,temp);
% input_data.
file_name = 'exported_stock_data.csv';
writetable(input_data,file_name,'WriteVariableNames',0);

% Create table
conn = database(path_to_db,'','','org.sqlite.JDBC',strcat('jdbc:sqlite:',path_to_db));
table_name = 'STOCK';
create_table(conn, table_name);
% User then need to use sqlite3 command line to manually import csv file
% using following commands:
% .separator ','
% .import [csv_file] [table_name]


function create_table( conn_to_database, table_name )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    curs = exec(conn_to_database, ['CREATE TABLE IF NOT EXISTS ' table_name '('...
                                  'SYMBOL TEXT,'...
                                  'DATE   INTEGER,'...
                                  'OPEN   REAL,'...
                                  'HIGH   REAL,'...
                                  'LOW    REAL,'...
                                  'CLOSE  REAL,'...
                                  'VOLUME INTEGER,'...
                                  'SYMBOL_DATE TEXT UNIQUE);']);
    close(curs);
end
