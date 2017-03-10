function fix_asc_type2(file_input,file_output)
% Check this condition:
% This code is valid if the data contains UTIM as the first line
% This code is valid if the second and third line are DATE and TIME
% This code will not fix the unit of the date and time. Make sure to check
% the unit of date and time with the data!!

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

% Find the number of mnemonics available and the position
FirstLine = textscan(tlines{1},'%s','delimiter',' ');
FirstMnem = FirstLine{1}{1};
MnemPos = find(~cellfun(@isempty,regexpi(tlines,FirstMnem)));
NMnem = MnemPos(end)-1;

% Get the units
Unit = cell(1,NMnem);
for i=1:NMnem
    dummy = textscan(tlines{i},'%s','delimiter',' ');
    Unit(i)=upper(dummy{1}(end));
end
Unit = strjoin(Unit(2:end),',');

% Fix mnemonic format
Mnem=textscan(tlines{MnemPos(end)},'%s','delimiter',' ');
Mnem=Mnem{:};
NewMnem = ['"',strjoin(Mnem(2:end),'","'),'"'];

% Fixing header (mnemonics and units)
NewLines = cell(length(tlines)-NMnem+1,1);
NewLines{1} = NewMnem;
NewLines{2} = Unit;

% Fix time and date in the data
j = 3;
for i=NMnem+2 : length(tlines)
    dummy = textscan(tlines{i},'%s','delimiter',' ');
    dummy = dummy{:};
    NewLines{j} = ['"',dummy{2},'","',dummy{3},'",',strjoin(dummy(4:end),',')];
    j = j+1;
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


