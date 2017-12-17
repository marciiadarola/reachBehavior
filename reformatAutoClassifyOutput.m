function savehandles=reformatAutoClassifyOutput(out,zoneVals,reaches,pellets,eat,paw,fidget,settings)

% Reformats the output of automated classification to match structure of
% output of manual classification

savehandles.discardFirstNFrames=settings.discardFirstNFrames;
savehandles.filename=settings.movieFile;
% savehandles.reachStarts=reaches.reachBegins;
savehandles.reachStarts=out.reachFidgetBegins;
savehandles.pelletTouched=(out.reachTypes==settings.grabType) | (out.reachTypes==settings.eatType) | (out.reachTypes==settings.dropType);
savehandles.pelletTime=find(reaches.reachPeaks==1);
savehandles.atePellet=out.reachTypes==settings.eatType;

% Find savehandles.eatTime as the time for each reach when mouse raises paw
% to mouth or drops pellet
for i=1:length(reaches.reachBegins)
    currBegin=reaches.reachBegins(i);
    nextPawAtMouth=find(paw.isPawAtMouth(currBegin:end)==1,1,'first');
    nextPawAtMouth=currBegin-1+nextPawAtMouth;
    nextPelletGone=find(pellets.pelletPresent(currBegin:end)==0,1,'first');
    nextPelletGone=currBegin-1+nextPelletGone;
    % If mouse eats pellet, log time when mouse raises paw to mouth
    if out.reachTypes(i)==settings.eatType
        savehandles.eatTime(i)=nextPawAtMouth;       
    else
        % Drop or miss
        % Time when pellet is gone or animal raises paw to mouth,
        % whichever comes first
        if isempty(nextPawAtMouth) && isempty(nextPelletGone)
            savehandles.eatTime(i)=nan;
        else
            savehandles.eatTime(i)=min([nextPawAtMouth nextPelletGone]);
        end
    end
end

savehandles.LEDvals=zoneVals.LEDZone;
savehandles.pelletMissing=out.pelletThere==0;
savehandles.pawStartsOnWheel=out.reachFromPerch==0; 

% Make frame numbers here match movie's frame numbers
% by adding back discardFirstNFrames
nreaches=length(savehandles.reachStarts);
exceptFields={};
savehandles=addNFramestoData(savehandles, nreaches, settings.discardFirstNFrames, exceptFields);

end

function data=addNFramestoData(data, n, addFrames, exceptFields)

f=fieldnames(data);
for i=1:length(f)
    if length(data.(f{i}))==n && nanmax(data.(f{i}))>1 && ~ismember(f{i},exceptFields)
        data.(f{i})=data.(f{i})+addFrames;
    end
end

end
    