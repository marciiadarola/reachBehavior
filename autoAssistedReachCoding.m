function autoAssistedReachCoding(filename)

videoFReader = vision.VideoFileReader(filename);
videoPlayer = vision.VideoPlayer;
allframes=nan([480,640,3,10]);
for i=1:10
    frame = step(videoFReader);
    allframes(:,:,:,i)=frame;
    step(videoPlayer,frame);
end

figure();
h=axes();
axes(h);
fig=implay(allframes);
pause;
CurrentFrameNumber = fig.data.Controls.CurrentFrame;

% Display first image
% Get user to indicate perch (paw) zone

% Then look for changes in paw zone to identify potential reach

% Have user indicate start of reach, time when paw contacts pellet, and
% whether reach was succesful

release(videoFReader);
release(videoPlayer);

end