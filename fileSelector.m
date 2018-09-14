function [fileList, excludedChannel] = fileSelector(startingDirectory)
    exit = 0;

    if nargin < 1 || exist(startingDirectory, 'dir') ~= 7
        startingDirectory = fileparts(mfilename('fullpath'));
    end
    fileList = {};
    excludedChannel = {};
    while ~exit
        if ~isempty(fileList)
            fprintf('\n');
            nFile = length(fileList);
            for iF = 1:nFile
                nS = length(fileList{iF});
                fprintf('%d: %60s   ', iF, fileList{iF}(max(nS-60, 1):end));
                fprintf('%5d', excludedChannel{iF});
                fprintf('\n');
            end
        end
        
        disp([newline, '[1] Add folder']);
        disp('[2] Add file');
        disp('[3] Delete file selection');
        disp('[4] Set channel to exclude');
        disp('[5] View raw data');
        disp('[r,y] Run Kilosort');
        disp(['[q,x,c] Exit', newline]);
        
        cmd = input('Select menu: ', 's');

        switch lower(cmd)
            case '1'
                path = uigetdir(startingDirectory, 'Select folder');
                if ischar(path)
                    files = dir(fullfile(path, '*.ap.bin'));
                    nFile = length(files);

                    if nFile==0; continue; end

                    filepath = cell(1, nFile);
                    for iF = 1:nFile
                        filepath{iF} = fullfile(path, files(iF).name);
                    end

                    excludedChannel = [excludedChannel, cell(1, nFile)];
                    [fileList, iA] = unique([fileList, filepath]);
                    excludedChannel = excludedChannel(iA);
                end
            case '2'
                [file, path] = uigetfile(fullfile(startingDirectory, '*.ap.bin'), ...
                    'Select one or more files', ...
                    'MultiSelect', 'on');
                if ischar(file)
                    filepath = {fullfile(path, file)};
                elseif iscell(file)
                    filepath = cellfun(@(x) fullfile(path, x), file, 'UniformOutput', false);
                else
                    continue;
                end
                
                excludedChannel = [excludedChannel, cell(1)];
                [fileList, iA] = unique([fileList, filepath]);
                excludedChannel = excludedChannel(iA);
            case '3'
                id = input('Choose file index to delete (ex. 1 or [1, 2, 3]. 0 to choose all. Enter to cancel): ');
                if isempty(id)
                    continue;
                elseif id(1) == 0
                    fileList = [];
                    excludedChannel = [];
                else
                    inIndex = ismember(id, 1:length(fileList));
                    id = id(inIndex);
                    fileList(id) = [];
                    excludedChannel(id) = [];
                end
            case '4'
                id = input('Choose file index to edit channel to exclude (0 to choose all. Enter to cancel): ');
                if isempty(id)
                    continue;
                elseif id(1) == 0
                    ch = input('Type channel to exclude (ex. [200, 375]. Enter to cancel): ');
                    if isempty(ch); continue; end
                    inChannel = ismember(ch, 1:384);
                    nFile = length(fileList);
                    excludedChannel = repmat({ch(inChannel)}, nFile, 1);
                else
                    inIndex = ismember(id, 1:length(fileList));
                    if sum(inIndex) > 0
                        ch = input('Type channel to exclude (ex. [200, 375]. Enter to cancel): ');
                        if isempty(ch); continue; end
                        inChannel = ismember(ch, 1:384);
                       
                        for iCh = id(inIndex)
                            excludedChannel{iCh} = ch(inChannel);
                        end
                    end
                end
            case '5'
                id = input('Choose file index to view raw data (Enter to cancel): ');
                if isempty(id); continue; end
                inIndex = ismember(id(1), 1:length(fileList));
                if inIndex
                    viewRaw(fileList{id(1)});
                end
            case 'r'
                exit = 1;
            case {'q', 'x', 'c'}
                fileList = {};
                excludedChannel = {};
                exit = 1;
        end
    end
end