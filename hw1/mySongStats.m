function [out1, out2] = mySongStats(songList)
%out1 is a structure array which list the top-10 most productive artists (with field name "name") and their song counts (with field name "songCount"), sorted by "songCount" in a descending order). Note that you should not take artist names of "??", "unknown", and "??" into consideration.
%out2 is a cell string array which list the artists which has both Chinese and Taiwanese songs (sorted by the artist names).
[~,ord] = sort({songList.artist});
artList = songList(ord);
sz=size(artList, 1);
count=0;
curart=artList(1).artist;
CH = 0;
TW = 0;
i = 1;
myList=struct('artist', '', 'songs', 0, 'CH', 0, 'TW', 0);
idx=1;
while i <= sz
    artist = artList(i).artist;
    if strcmp(artist,  '²»Ô”') || strcmp(artist, 'unknown') || strcmp(artist, 'ÀÏ¸è')
        i = i + 1;
        continue
    end
    if strcmp(artist, curart)
        count = count + 1;
        if strcmp(artList(i).language, 'Chinese')
            CH = 1;
        end
        if strcmp(artList(i).language, 'Taiwanese')
            TW = 1;
        end
        i = i + 1;
    else
        %record last curart info
        myList(idx).artist = curart;
        myList(idx).songs = count;
        myList(idx).CH = CH;
        myList(idx).TW = TW;
        idx = idx + 1;
        %reset
        curart = artist;
        count = 0;
        CH = 0;
        TW = 0;
    end
end

[~,ord] = sort([myList.songs],'descend');
songCount = myList(ord);
scz = size(songCount, 2);
out1 = struct('name','','songCount','');
for i=1:10
    out1(i).name = songCount(i).artist;
    out1(i).songCount = songCount(i).songs;
end

out2 = cell(1);
idx=1;
for i=1:scz
    if myList(i).CH == 1 && myList(i).TW == 1
        out2(idx) = {myList(i).artist};
        idx = idx + 1;
    end
end
out2 = sort(out2);
end