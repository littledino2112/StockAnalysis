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
    debug = true;
    date_added = 0; % This keeps track of how many new date is added to 
                    % local db
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
       path_to_unzip = ['./' date_to_download];
       try
           if (debug)
              disp(url); 
           end
           unzip(url,path_to_unzip);
           
           % If gets here, there's valid data. Extrace data from file
           date_format = datestr(elm,'dd.mm.yyyy');
           filename = ['CafeF.RAW_HSX.' date_format '.csv'];
           path_to_file = [path_to_unzip '/' filename];
           raw_data = load_data(path_to_file);
           raw_data.Date = datenum(raw_data.Date);
           
           % Update data to local database
           colnames = {'SYMBOL','DATE','OPEN','HIGH','LOW','CLOSE', ...
                       'VOLUME'};
           raw_data = table2cell(raw_data);
           datainsert(db_conn,'TEMP',colnames,raw_data);
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
       msg = [ num2str(date_added) ' date(s) added to db'];
    else
       status = false;
       msg = 'No data available';
    end
    if (debug)
       disp(msg); 
    end
end

