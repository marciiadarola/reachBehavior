function displayPerchZone(isin,videoFile)

videoFReader = vision.VideoFileReader(videoFile,'PlayCount',1,'ImageColorSpace','YCbCr 4:2:2');
[frame,~,~,EOF]=step(videoFReader);

figure();
imagesc(frame);
colormap gray

zoneArray=zeros(size(frame));
temp=reshape(frame,size(frame,1)*size(frame,2),1);
temp_zoneArray=reshape(zoneArray,size(zoneArray,1)*size(zoneArray,2),1);
temp_zoneArray(isin)=1;
zoneArray=reshape(temp_zoneArray,size(frame,1),size(frame,2));

figure();
imagesc(zoneArray);