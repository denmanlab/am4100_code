function retstr = getValueNames(valname,first,last)
returnsingle=false;
        if nargin == 2
            returnsingle=true;
            last=999;
        elseif nargin ==3
            returnarray=true;
        else
            first=1;
            last=1;
            returnarray=false;
        end
vals=ComConstants;
valstr=valname;
valstr(1)=lower(valname(1));
nostruct=0;
switch (valstr(1:4))
    case 'sync'
           tempstruct=vals.sync;
    case 'trai'
           tempstruct=vals.train.type;
    case 'even'
           tempstruct=vals.event.type;
    case 'libI'
           nostruct=1;
    otherwise
           tempstruct=vals.(genvarname([valstr]));
end
if nostruct == 1
    outstr='1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20';
    mysize=20;
    tempcells=cellstr(num2str([1:20]'));
else
    tempcells=fieldnames(tempstruct);
    mysize=max(size(tempcells,1),size(tempcells,2));
    outstr=cell2mat(tempcells(1));
    for i=2:mysize
        outstr=[outstr ' | ' cell2mat(tempcells(i))];
    end
    if strcmp(valstr(1:4),'moni')
        for i=1:mysize
            toutstr(i)={strrep(cell2mat(tempcells(i)),'scale_','')};
            toutstr(i)={strrep(cell2mat(toutstr(i)),'per','/')};
        end
        outstr=cell2mat(toutstr(1));
        for i=2:mysize
            outstr=[outstr ' | ' cell2mat(toutstr(i))];
        end
    end
end

if first < 1
    first=1;
end
last=min(last,mysize);
first=min(first,mysize);
if returnsingle
     retstr=num2str(cell2mat(tempcells(first)));
else
    if returnarray     
        retstr=tempcells(first:last);
    else
        retstr=tempcells(first:mysize);
%         retstr=outstr;
    end
end



end

