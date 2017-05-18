function integrateSDoutWithReaches(reaches,out,alignment)

% Will need to fix some file alignments by lining up cue onsets and offsets
if isempty(alignment)
    alignment=getAlignment();
end

