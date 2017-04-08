function myEncrypt(inputFileName, outputFileName)
[y, fs]=audioread(inputFileName);
z=y;
for i = 1:length(y)
    if y(i)>0
        z(i)=1-y(i);
    elseif y(i)<0
        z(i)=-1-y(i);
    end
end
z=flipud(z);
audiowrite(outputFileName, z, fs);
end

