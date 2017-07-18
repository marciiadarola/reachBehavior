function allAnalysis(nameOfMicroSD,nameOfVideoFile)
           
endoffname=regexp(nameOfMicroSD,'\');            
out=parseSerialOut(nameOfMicroSD,[nameOfMicroSD(1:endoffname(end)) 'parsedOutput.mat']);

endoffname=regexp(nameOfVideoFile,'\.');          
a=load([nameOfVideoFile(1:endoffname(end)-1) '_savehandles.mat']);
savehandles=a.savehandles;

aligned=getAlignment(out,30,savehandles);

endoffname=regexp(nameOfMicroSD,'\');       
[status]=mkdir([nameOfMicroSD(1:endoffname(end)) '\processed_data']);
finaldata=integrateSDoutWithReaches(savehandles,out,30,aligned,[nameOfMicroSD(1:endoffname(end)) '\processed_data']);

tbt=plotCueTriggeredBehavior(finaldata,'cue',1);
