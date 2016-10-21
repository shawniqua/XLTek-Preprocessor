function chNum = xtp_getChannel(spec, chName)
% identifies the channel number associated with the specified channel name
% for a given XTP datastructure (such as a spectrogram)

chNum = find(strcmpi(spec.info.channelNames, chName));