function newdate = xtp_convertDate(olddate)

datefmt = 'mm/dd/yyyy HH:MM:SS';
origin = '07/30/2007 00:00:00';

if isstr(olddate)
    newdate = (datenum(olddate, datefmt) - datenum(origin, datefmt))*3600*24;
    return
end
if isnumeric(olddate)
    newdate = datestr((olddate/(3600*24))+datenum(origin, datefmt),datefmt);
    return
end
