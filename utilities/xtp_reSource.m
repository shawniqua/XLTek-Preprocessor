function varargout = xtp_reSource(oldstring, newstring, varargin)
% This function updates the source field of the given set of spectra. It
% should be used with caution because it breaks the audit trail. Should
% only be used if the corresponding data that was used to generate the
% spectra will also be renamed, as well as any other spectra that were
% generated from that same data.
%
% Can call it with any number of spectra you want.
%
% EXAMPLE: [newspec1 newspec2 newspec3 ...] = xtp_reSource(oldstring, newstring, spec1, spec2, spec3...)
%
% Change Control
% Ver Date          Person      Change
% --- ------------- ----------- -------------------------------------------
% 1.0 01/02/08      S. Williams Created
%

if nargout ~= length(varargin)
    message = 'Error: number of input spectra must match number of output spectra. \n See help xtp_reSource for guidance.';
    disp(message);
    return
end

for v = 1:nargout
    varargout{v} = varargin{v};
    varargout{v}.source = strrep(varargin{v}.source, oldstring, newstring);
end