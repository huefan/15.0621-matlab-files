for k=2 : 51
    for i=2 : 756
        A=strcmp(alldata,stockprice(i,1))+strcmp(alldata,stockprice(1,k));
        for j=1 : 11401
            if sum(A(j,:))>=2
                stockprice(i,k)=alldata(j,2);
            end 
        end
    end
end
                
fileID = fopen('celldata.txt','w'); 
formatSpec = '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t \t';
[nrows,ncols] = size(stockprice);
for row = 1:nrows
    fprintf(fileID,formatSpec,stockprice{row,:});
end
fclose(fileID);
type celldata.dat


