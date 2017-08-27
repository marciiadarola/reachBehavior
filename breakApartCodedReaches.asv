function [part1,part2]=breakApartCodedReaches(savehandles,breakAtIndex)

f=fieldnames(savehandles);
for i=1:length(f)
    part1.(f{i})=savehandles.(f{i});
    part2.(f{i})=savehandles.(f{i});
end

part1.reachStarts=part1.reachStarts(part1.reachStarts<=breakAtIndex+savehandles.discardFirstNFrames);
part1.pelletTouched=part1.pelletTouched(part1.pelletTime<=breakAtIndex+savehandles.discardFirstNFrames);
part1.pelletTime=part1.pelletTime(part1.pelletTime<=breakAtIndex+savehandles.discardFirstNFrames);
part1.atePellet=part1.atePellet(part1.eatTime<=breakAtIndex+savehandles.discardFirstNFrames);
part1.eatTime=part1.eatTime(part1.eatTime<=breakAtIndex+savehandles.discardFirstNFrames);
part1.pelletMissing=part1.pelletMissing(part1.reachStarts<=breakAtIndex+savehandles.discardFirstNFrames);
part1.pawStartsOnWheel=part1.pawStartsOnWheel(part1.reachStarts<=breakAtIndex+savehandles.discardFirstNFrames);
part1.logReachN=part1.logReachN(part1.reachStarts<=breakAtIndex+savehandles.discardFirstNFrames);

part1.LEDvals=part1.LEDvals(1:breakAtIndex);
part1.changeBetweenFrames=part1.changeBetweenFrames(1:breakAtIndex);
part1.eatRegimeVals=part1.eatRegimeVals(1:breakAtIndex);
part1.perchRegimeVals=part1.perchRegimeVals(1:breakAtIndex);
part1.pelletRegimeVals=part1.pelletRegimeVals(1:breakAtIndex);
part1.pelletStopVals=part1.pelletStopVals(1:breakAtIndex);

part2.reachStarts=part2.reachStarts(part2.reachStarts>breakAtIndex+savehandles.discardFirstNFrames);
part2.pelletTouched=part2.pelletTouched(part2.pelletTime>breakAtIndex+savehandles.discardFirstNFrames);
part2.pelletTime=part2.pelletTime(part2.pelletTime>breakAtIndex+savehandles.discardFirstNFrames);
part2.atePellet=part2.atePellet(part2.eatTime>breakAtIndex+savehandles.discardFirstNFrames);
part2.eatTime=part2.eatTime(part2.eatTime>breakAtIndex+savehandles.discardFirstNFrames);
part2.pelletMissing=part2.pelletMissing(part2.reachStarts>breakAtIndex+savehandles.discardFirstNFrames);
part2.pawStartsOnWheel=part2.pawStartsOnWheel(part2.reachStarts>breakAtIndex+savehandles.discardFirstNFrames);
part2.logReachN=part2.logReachN(part2.reachStarts>breakAtIndex+savehandles.discardFirstNFrames);

% part2.LEDvals=[ones(1,breakAtIndex-1).*nanmean(part2.LEDvals(breakAtIndex:end)) part2.LEDvals(breakAtIndex:end)];
% part2.changeBetweenFrames=[ones(1,breakAtIndex-1).*nanmean(part2.changeBetweenFrames(breakAtIndex:end)) part2.changeBetweenFrames(breakAtIndex:end)];
% part2.eatRegimeVals=[ones(1,breakAtIndex-1).*nanmean(part2.eatRegimeVals(breakAtIndex:end)) part2.eatRegimeVals(breakAtIndex:end)];
% part2.perchRegimeVals=[ones(1,breakAtIndex-1).*nanmean(part2.perchRegimeVals(breakAtIndex:end)) part2.perchRegimeVals(breakAtIndex:end)];
% part2.pelletRegimeVals=[ones(1,breakAtIndex-1).*nanmean(part2.pelletRegimeVals(breakAtIndex:end)) part2.pelletRegimeVals(breakAtIndex:end)];
% part2.pelletStopVals=[ones(1,breakAtIndex-1).*nanmean(part2.pelletStopVals(breakAtIndex:end)) part2.pelletStopVals(breakAtIndex:end)];

part2.LEDvals=part2.LEDvals(breakAtIndex:end);
part2.changeBetweenFrames=part2.changeBetweenFrames(breakAtIndex:end);
part2.eatRegimeVals=part2.eatRegimeVals(breakAtIndex:end);
part2.perchRegimeVals=part2.perchRegimeVals(breakAtIndex:end);
part2.pelletRegimeVals=part2.pelletRegimeVals(breakAtIndex:end);
part2.pelletStopVals=part2.pelletStopVals(breakAtIndex:end);

part2.discardFirstNFrames=+savehandles.discardFirstNFrames+breakAtIndex-1;