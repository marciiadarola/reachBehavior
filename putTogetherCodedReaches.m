function aligned=putTogetherCodedReaches(aligned1,aligned2)

f=fieldnames(aligned1);
for i=1:length(f)
    aligned.(f{i})=[aligned1.(f{i}) aligned2.(f{i})];
end