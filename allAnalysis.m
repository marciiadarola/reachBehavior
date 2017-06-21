function allAnalysis(savehandles)


out=parseSerialOut('C:\Users\Kim\Documents\MATLAB\20170322\MicroSD_Output.txt','C:\Users\Kim\Documents\MATLAB\20170322\parsedOutput.mat');
aligned=getAlignment(out,30,savehandles);
finaldata=integrateSDoutWithReaches(savehandles,out,30,aligned,'C:\Users\Kim\Documents\MATLAB\20170322\good processed data');
