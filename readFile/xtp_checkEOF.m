function xtp_checkEOF(filename, bytes)
% Returns the next two lines of the file specified by string filename,
% starting from the marker specified by integer bytes. This is called from
% xtp_readXLTfile and allows the user to verify that all data of interest
% were collected from the file to be read.
%
% EXAMPLE: status = xtp_checkEOF(filename, bytes)
%
% VER   DATE        PERSON          CHANGE
% 1.0   12/11/08    S. Williams     Created.

fid = fopen(filename);
fseek(fid, bytes, 'bof');
fprintf(1,'The next two lines of this file are:\n');
fgetl(fid)
fgetl(fid)
fclose(fid);