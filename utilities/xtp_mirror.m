function outarray = xtp_mirror(inarray, dimension)
% converts a 2D array to its mirror image, reflected about the midline in
% the dimension specified (1 for rows, 2 for columns)
%
% EXAMPLE: outarray = xtp_mirrorc(inarray, dimension)
%
% Ver   Date     Person         Change
% 1.0   11/11/08 S.Williams     Created

if nargin == 1
    dimension = find(size(inarray)==length(inarray));
end

len = size(inarray, dimension);

if dimension == 2
    for idx = 1:len
        outarray(:,idx) = inarray(:,len-idx+1);
    end
else if dimension == 1
        for idx = 1:len
            outarray(idx,:) = inarray(len-idx+1,:);
        end
    else
    fprintf(1, 'ERROR: dimension must be either 1 or 2. (Given %d)\n', dimension);
    end
end
end