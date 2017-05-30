function integrateSDoutWithReaches(reaches,out,moviefps,alignment)

% Will need to fix some file alignments by lining up cue onsets and offsets
if isempty(alignment)
    alignment=getAlignment([],out,[],[],moviefps,[],reaches);
end

