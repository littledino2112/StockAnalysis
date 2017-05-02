% input_file = 'CafeF.RAW_HSX.03.04.2017.csv';
% input_data = load_data(input_file);
% symbol = input('Input Symbol to analyze: ','s');
% idx = find(input_data.Symbol == symbol);
% symbol_data = input_data(idx,:);
% symbol_data.Date = datenum(symbol_data.Date);
% symbol_time_series_obj = fints(symbol_data.Date, [symbol_data.Open symbol_data.High symbol_data.Low symbol_data.Close symbol_data.Volume],...
%                                 {'Open', 'High', 'Low', 'Close', 'Volume'});

%% Function to load data from csv file and prepare it in the right format
function [raw_data] = load_data(input_file)
    opts = detectImportOptions(input_file);
    opts.VariableNames = {'Symbol','Date','Open','High','Low','Close','Volume'};
  %  opts = opts.setvartype('Symbol','string');
    opts = opts.setvartype('Date','datetime');
    opts = opts.setvaropts('Date','InputFormat','yyyyMMdd');
    opts = opts.setvaropts('Date','DatetimeFormat','ddMMMyyyy');
    temp_data = readtable(input_file,opts);
    raw_data = temp_data;
end
%% 