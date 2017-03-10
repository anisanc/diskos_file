function fix_asc_type5(file_input,file_output)
% Codes for fixing type 5 ASC file
% Example:
% fix_asc_type2('my_file.ASC') 
%    this command will replace the old file with the edited one
% fix_asc_type2('my_file.ASC','my_new_file.ASC')
%    this command will create a new file that has been edited


% Open file
fid      = fopen(file_input);
if fid < 0
    error('Cannot open file :');
    file_output = [];
    return
end
tlines=textscan(fid,'%s','delimiter','\n');
fclose(fid);
tlines=tlines{:};

% Fix tlines
dummy = find(cellfun(@isempty,tlines));
tlines(dummy) = [];

% Fix Mnemonic Name: adding DATE and TIME
Mnem=textscan(tlines{1},'%s','delimiter',',');
Mnem=Mnem{:};
NewMnem = ['"DATE","TIME",',strjoin(Mnem(2:end),',')];

% Fix Unit
Unit=textscan(tlines{2},'%s','delimiter',',');
Unit=Unit{:};
NewUnit = ['dd-mmm-yy,HH:MM:SS,',strjoin(Unit(2:end),',')];

% Fixing header (mnemonics and units)
NewLines = cell(length(tlines),1);
NewLines{1} = NewMnem;
NewLines{2} = NewUnit;

% Fix time and date in the data
for i=3 : length(tlines)
    dummy = textscan(tlines{i},'%s','delimiter',',');
    dummy = dummy{:};
    DateTime = datetime(str2num(dummy{1}),'convertfrom','posixtime');
    Date = datestr(DateTime,'dd-mmm-yy');
    Time = datestr(DateTime,'HH:MM:SS');
    NewLines{i} = ['"',Date,'","',Time,'",',strjoin(dummy(2:end),',')];
end

% Saving the file
if isequal(nargin,1)
    fid = fopen(file_input,'w');
    frewind(fid);
else
    fid = fopen(file_output,'w');
end
fprintf(fid,'%s \r\n',NewLines{:});
fclose(fid);
end

