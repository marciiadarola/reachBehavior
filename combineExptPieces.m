function alltbt=combineExptPieces(expt_dir)

ls=dir(expt_dir);
j=1;
tbt=[];
alltbt=[];
for i=1:length(ls)
    thisname=ls(i).name;
    thisisdir=ls(i).isdir;
    if ~isempty(regexp(thisname,'processed_data')) && thisisdir==1
        a=load([expt_dir '\' thisname '\tbt_resampled.mat']);
        tbt{j}=a.tbt;
        j=j+1;
    end
end

if isempty(tbt)
    disp('No tbt data saved in this directory');
    return
end

f=fieldnames(tbt{1});
for i=1:length(f)
    alltbt.(f{i})=[];
end

for i=1:length(tbt)
    curr_tbt=tbt{i};
    if i==1
        % first tbt
        for j=1:length(f)
            alltbt.(f{j})=curr_tbt.(f{j});
        end
    else
        if size(alltbt.(f{1}),2)<size(curr_tbt.(f{1}),2)
            % expand size, fill with nans
            expandBy=size(curr_tbt.(f{1}),2)-size(alltbt.(f{1}),2);
            for j=1:length(f)
                alltbt.(f{j})=[alltbt.(f{j}) nan(size(alltbt.(f{j}),1),expandBy)];
            end
        elseif size(alltbt.(f{1}),2)>size(curr_tbt.(f{1}),2)
            expandBy=size(alltbt.(f{1}),2)-size(curr_tbt.(f{1}),2);
            for j=1:length(f)
                if isfield(curr_tbt,f{j})
                    curr_tbt.(f{j})=[curr_tbt.(f{j}) nan(size(curr_tbt.(f{j}),1),expandBy)];
                end
            end
        end
        % concat
        for j=1:length(f)
            if isfield(curr_tbt,f{j})
                alltbt.(f{j})=[alltbt.(f{j}); curr_tbt.(f{j})];
            end
        end
    end
end
            
        