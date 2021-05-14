function out=nonparamZscore(data)

% data is a vector

med=median(data,'omitnan');
mad=median(abs(data-med),'omitnan');
out=abs(data-med)./(1.4826*mad);