function patchColor = xtp_definePatchColors(lineColor)
switch lineColor
    case 'r'
        patchColor = [1 .9 .9];
    case 'g'
        patchColor = [.8 1 .8];
    case 'b'
        patchColor = [.6 .8 1];
    case 'y'
        patchColor = [1 1 .4];
    case 'm'
        patchColor = [1 .8 1];
    case 'c'
        patchColor = [.8 1 1];
    case 'k'
        patchColor = [.5 .5 .5];
    otherwise
        patchColor = [.9 .9 .9]; 
end
end

