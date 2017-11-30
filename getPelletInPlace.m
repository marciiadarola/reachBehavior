function out=getPelletInPlace(pelletData)

out.rawData=pelletData;

% use the data as an indicator of how well-positioned the
% pellet is at each time

definitePelletThresh=60; % percentile above which pellet is definitely well-positioned

out.pelletPercRank=(tiedrank(pelletData)-1)./(length(pelletData)-1);

pelletPresent=single(pelletData>prctile(pelletData,definitePelletThresh));
pelletPresent(isnan(pelletData)==1)=nan;
out.pelletPresent=pelletPresent;
