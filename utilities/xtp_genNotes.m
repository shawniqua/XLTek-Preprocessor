function notes = xtp_genNotes(parameterStruct)
% Generates a cell array listing the contents of each field of a structure.
%
% EXAMPLE: notes = xtp_genNotes(parameterStruct)
%
% CHANGE CONTROL
% Ver   Date        Person          Change
% ----- ----------- --------------- ---------------------------------------
% 1.0   4//09       S. Williams     Created

notes = fieldnames(parameterStruct);
for f=1:length(notes)
    if isnumeric(parameterStruct.(notes{f}))
        notes{f} = [notes{f} ': ' num2str(parameterStruct.(notes{f}))];
    else
        notes{f} = [notes{f} ': ' parameterStruct.(notes{f})];
    end 
end