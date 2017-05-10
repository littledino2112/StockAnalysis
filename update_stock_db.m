function [ status, msg ] = update_stock_db( db_conn )
% This function checks for any new daily update from the cafef database and
% updates them to my local stock database
% Flows:
%   - Get the last date available on the db and compare that with now
%   (using serial num format)
%   - Iterate thourgh the delta retrieved from the previous step
%   - Create a link and try to retrieve them from cafef
%   - Extract data (unzip, get correct file)
%   - Update to local db
%   - Delete downloaded file
    % Local define
    load config.mat
    debug = true;
    date_added = 0; % This keeps track of how many new date is added to 
                    % local db
    table_name = 'STOCK';
    % Get the last date available on local db
    sql_query = 'SELECT MAX(DATE) FROM STOCK';
    data = fetch(db_conn, sql_query);
    
    % Get the list of dates starting from this date + 1 till now
    start_date = data.MAX_DATE_ + 1;
    list = start_date:1:now;
    
    % Iterate through the list and construct the url to download
    for elm = list
       date_to_download = datestr(elm,'yyyymmdd');
       date_to_download_v2 = datestr(elm,'ddmmyyyy');
       url = ['http://images1.cafef.vn/data/' date_to_download ...
              '/CafeF.SolieuGD.Raw.' date_to_download_v2 '.zip'];
       url2 = ['http://images1.cafef.vn/data/' date_to_download ...
              '/CafeF.Index.' date_to_download_v2 '.zip'];          
       path_to_unzip = ['./' date_to_download];
       try
           if (debug)
              disp(url);
              disp(url2);
           end
           unzip(url,path_to_unzip);
           unzip(url2,path_to_unzip);
           
           % If gets here, there's valid data 
           % Extract HOSE stock data from file
           date_format = datestr(elm,'dd.mm.yyyy');
           filename = ['CafeF.RAW_HSX.' date_format '.csv'];
           path_to_file = [path_to_unzip '/' filename];
           raw_data = load_data(path_to_file);
           raw_data.Date = datenum(raw_data.Date);
           temp = num2str(raw_data.Date);
           raw_data.SymbolDate = strcat(raw_data.Symbol, temp);
           
           % Update data to local database
           colnames = {'SYMBOL','DATE','OPEN','HIGH','LOW','CLOSE', ...
                       'VOLUME','SYMBOL_DATE'};
           raw_data = table2cell(raw_data);
           datainsert(db_conn,table_name,colnames,raw_data);

           % Extract INDEX data
           % If gets here, there's valid data. Extract data from file
           filename = ['CafeF.INDEX.' date_format '.csv'];
           path_to_file = [path_to_unzip '/' filename];
           raw_data = load_data(path_to_file);
           raw_data.Date = datenum(raw_data.Date);
           temp = num2str(raw_data.Date);
           raw_data.SymbolDate = strcat(raw_data.Symbol, temp);
           
           % Update data to local database
           colnames = {'SYMBOL','DATE','OPEN','HIGH','LOW','CLOSE', ...
                       'VOLUME','SYMBOL_DATE'};
           raw_data = table2cell(raw_data);
           datainsert(db_conn,table_name,colnames,raw_data);
           date_added = date_added + 1;

           % Remove downloaded files
           rmdir(path_to_unzip,'s');
       catch
           if (debug)
              disp('Error occurs'); 
           end
       end
    end
    if (date_added > 0)
       status = true; 
       msg = [ num2str(date_added) ' date(s) added to Stock table'];
    else
       status = false;
       msg = 'No data added to Stock table';
    end
    
% Update database for HOSE_STOCK_DIFF table
% Flows:
%   - Check for last date available in Stock Diff table
%   - Get stock data from STOCK table starting from this date (>=)
%   - Compute necessary data (Close Diff, Close Diff (%), Open-Close Diff, 
%   Open-Close Diff (%), Vol Diff, Vol Diff (%)
%   - Insert data to Stock Diff table

    col_names = {'SYMBOL','DATE','CLOSE_DIFF','CLOSE_DIFF_PERCENTAGE',...
                'OPEN_CLOSE_DIFF','OPEN_CLOSE_DIFF_PERCENTAGE','VOLUME_DIFF','VOLUME_DIFF_PERCENTAGE','SYMBOL_DATE'};

    sql_query = 'SELECT MAX(DATE) FROM HOSE_STOCK_DIFF';
    data = fetch(db_conn, sql_query);
    last_date_stock_diff_table = data.MAX_DATE_;
    
    % Get last date available on Stock table
    sql_query = 'SELECT MAX(DATE) FROM STOCK';
    data = fetch(db_conn, sql_query);
    last_date_stock_table = data.MAX_DATE_;

    % If both tables are up-to-date then the last dates should be the same.
    % Otherwise, the STOCK_DIFF_TABLE is not up-to-date
    if (last_date_stock_table > last_date_stock_diff_table)
        sql_query = ['SELECT DISTINCT SYMBOL FROM ' table_names.STOCK ' WHERE DATE >= ' num2str(last_date_stock_diff_table)];
        data = fetch(db_conn, sql_query);
        symbol_list = table2array(data);
        len = length(symbol_list);
        data_point_added = 0;
        for idx = 1:len
            sql_query = ['SELECT SYMBOL, DATE, CLOSE, OPEN, VOLUME FROM '...
                          table_names.STOCK ... 
                          ' WHERE DATE >= ' num2str(last_date_stock_diff_table)...
                          ' AND SYMBOL = ''' symbol_list{idx} ''''];
            symbol_data = fetch(db_conn, sql_query);
            if (height(symbol_data) == 1)   % If only one data point is available, can't compute diff in this case
               continue;     
            end
            selected_stock = fints(symbol_data.DATE, [symbol_data.OPEN symbol_data.CLOSE symbol_data.VOLUME],{'OPEN', 'CLOSE', 'VOLUME'});
            diff_results = calculate_diff_data(selected_stock, symbol_list{idx});

            % Update date to HOSE_STOCK_DIFF table
            datainsert(db_conn,table_names.HOSE_STOCK_DIFF,col_names,diff_results);
            data_point_added = data_point_added + 1;
        end
        if (data_point_added)
            msg = [msg newline num2str(data_point_added) ' data points added for ' table_names.HOSE_STOCK_DIFF ' table'];
        end
    end
    
    if (debug)
       disp(msg); 
    end
end

