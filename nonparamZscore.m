function out=nonparamZscore(data)

% data is a vector

med=nanmedian(data);
mad=nanmedian(abs(data-med));
out=abs(data-med)./(1.4826*mad);