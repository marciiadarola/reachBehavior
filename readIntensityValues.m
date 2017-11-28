function out=readIntensityValues(zonesFile, movieFile)

% Record the following from each movie
% Intensity in reach zone
% Intensity in pellet reach position
% Intensity in eating zone
% Change between frames

% Read file that specifies zones for current movie
a=load(zonesFile);
a=a.perch;
% Fields:
% isin              perch zone
% LEDisin           distractor LED zone
% pelletIsIn        reach zone
% isin5             pellet stopped zone
% isin4             eating zone

% Read movie file and get intensity values for each
% user-specified zone
videoFReader=vision.VideoFileReader(movieFile,'PlayCount',1,'ImageColorSpace','YCbCr 4:2:2');
maxFrames=50000;
out.perchZone=nan(1,maxFrames);
out.LEDZone=nan(1,maxFrames);
out.reachZone=nan(1,maxFrames);
out.pelletZone=nan(1,maxFrames);
out.eatZone=nan(1,maxFrames);
out.changeBetweenFrames=nan(1,maxFrames);
lastFrame=[];
for i=1:maxFrames
    if mod(i,500)==0
        disp(i);
    end
    [frame,~,~,EOF]=step(videoFReader);
    temp=reshape(frame,size(frame,1)*size(frame,2),1);
    out.perchZone(i)=sum(temp(a.isin,:),1);
    out.LEDZone(i)=sum(temp(a.LEDisin,:),1);
    out.reachZone(i)=sum(temp(a.pelletIsIn,:),1);
    out.pelletZone(i)=sum(temp(a.isin5,:),1);
    out.eatZone(i)=sum(temp(a.isin4,:),1);
    if i==1
        out.changeBetweenFrames(i)=0;
    else
        out.changeBetweenFrames(i)=nansum(nansum(abs(frame-lastFrame),1),2);
    end
    lastFrame=frame;
    if EOF==true
        break
    end
end
% Pad changeBetweenFrames
out.changeBetweenFrames(1)=out.changeBetweenFrames(2);