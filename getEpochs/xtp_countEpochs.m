function numepochs = xtp_countEpochs(epochlist)
% counts the # of epochs for each condition, if they were saved a certain
% way
switch nargin
    case 0
for dose =1:5
    fprintf(1,'loading data for dose %d...\n', dose);
    dosename = ['Dose' num2str(dose)];
    evalstr = ['load ' dosename ';'];
    eval(evalstr);
    for bucket = 1:5
        ds = ['Dose' num2str(dose) 'Hour' num2str(bucket-1)];
        bucketexists = exist(ds, 'var');
        if bucketexists
            evalstr = ['numepochs(bucket,dose) = size(' ds '.metadata,2);'];
            eval(evalstr);
            fprintf(1,'%d epochs for bucket %d\n',numepochs(bucket,dose),bucket);
        else
            fprintf(1,'Skipping bucket %d\n',bucket);
        end
    end
    clear Dose*
end

    case 1
        [numbuckets numdoses] = size(epochlist);
        for d=1:numdoses
            for b=1:numbuckets
                numepochs(b,d) = size(epochlist{b,d}{1}, 1);
            end
        end
end
end

        