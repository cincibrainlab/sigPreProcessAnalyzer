classdef spaController < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        current_folder;  % current user-selected directory
        current_files;   % all SET files in current directory
        current_scriptFolder;
        current_details;
        
        current_detailTable;
        
        saved_settings;
        saved_filename;
        panel_config_filename;
        panel_detail_filename;
        
        panel_config = table();
        panel_detail = table();
        
        % running pipeline
        selected_file;
        selected_EEG;
        EEG_array;
        
        % pipeline pane
        pipeOrderArr;

    end
    
    methods
        function obj = spaController()
            %SPACONTROLLER Construct an instance of this class
            %   Controller class for Signal Preprocess Analyzer
            
            % check if eeglab is running
            if ~exist('eeg_checkset.m','file') == 2
                try
                    eeglab nogui;
                catch
                    error("Please add eeglab to MATLAB path.")
                end
            end 

            [ obj.current_scriptFolder,~,~] = fileparts( matlab.desktop.editor.getActiveFilename );
            
            obj.saved_filename = fullfile(obj.current_scriptFolder, 'spaController_savedSettings.mat');
            obj.panel_config_filename = fullfile(obj.current_scriptFolder, 'spaControllerPanelConfig.csv');
            obj.panel_detail_filename = fullfile(obj.current_scriptFolder, 'spaControllerPanelDetail.csv');
            
            % load "database"
            obj.readConfigCsv('PanelConfig');
            obj.readConfigCsv('PanelDetail');

        end
        function obj = selectFolder(obj)
            %SELECTFOLDER - user selects folder
            selectedFolder = uigetdir;
            obj.current_folder = selectedFolder;
        end
        function [selectedFolder, obj] = openFolder(obj) 
            % OPENFOLDER - List files for pane
            selectedFolder = obj.current_folder;
            a=dir(fullfile(selectedFolder,'*.set'));                         % Obtains the contents of the selected path.
            b={a(:).name}';                      % Gets the name of the files/folders of the contents and stores them appropriately in a cell array
            b(ismember(b,{'.','..'})) = [];      % Removes unnecessary '.' and '..' results from the display.

            obj.current_files = b;
        end
        function obj = showSetStructure( obj, filename )
            
            EEG = pop_loadset(  'filename', filename, ...
                'filepath', obj.current_folder, ...
                'loadmode','info');
            
            vEEG.setname =  EEG.setname;
            vEEG.subject = EEG.subject;
            vEEG.group = EEG.group;
            vEEG.condition = EEG.condition;
            vEEG.ref = EEG.ref;
            vEEG.nbchan = EEG.nbchan;
            vEEG.trials = EEG.trials;
            vEEG.pnts = EEG.pnts;
            vEEG.srate = EEG.srate;
            vEEG.xmin = EEG.xmin;
            vEEG.xmax = EEG.xmax;
            vEEG.times = EEG.times(1:3);
            try
                vEEG.events = char(unique({EEG.event.type}));
            catch
                vEEG.events = 'N/A';
            end
            
            obj.current_details = printstruct(vEEG,'nindent',0,'nlevels',1, 'SORTFIELDS',0);           
        end
        function obj = getDetailTableByFunName( obj, key)
            % get detail table for specific function
            detailTbl = obj.panel_detail;
            functionColumn = categorical(detailTbl.FUNCTION);
            
            fxnIdx = functionColumn == key;
            obj.current_detailTable = detailTbl(fxnIdx,:);
        end
    end
    
    methods % running pipeline
        function obj = loadEEG( obj )
           
            obj.selected_EEG = pop_loadset( obj.selected_file, obj.current_folder );
             
        end
    end
    
    methods % persistance functions
        function isPresent = saveSettingsExists( obj )
           if exist(obj.saved_filename,'file') == 2
               isPresent = true;
           else
               isPresent = false;
           end
        end
        function obj = saveSettings( obj )
            filename = obj.saved_filename;
            obj.saved_settings.current_folder = ...
                obj.current_folder;
            
            saved_settings_local = obj.saved_settings;
            save(filename, 'saved_settings_local');
            
        end   
        function obj = loadSettings( obj )
            filename = 'spaController_savedSettings.mat';
            load(filename, 'saved_settings_local');
            
            obj.current_folder = ...
                saved_settings_local.current_folder;
        end
        
        % CSV Functions
        function obj = updateConfigCsv( obj, key )
            switch key
                case 'updateOrder'
                    % retreive pipeline order
                    ppTbl = obj.panel_config;
                    searchIndex =  ppTbl.PANEL == "PREPROCESS" & ppTbl.SUBPANEL == "PIPELINE";
                    
                    % modify datatable
                    obj.panel_config.ORDER(searchIndex) = obj.pipeOrderArr;
                    obj.panel_config = sortrows(obj.panel_config,{'ORDER'});
                    obj.saveConfigCsv('PanelConfig');
                otherwise     
            end
            
        end
        function obj = storeNewPipeOrder( obj, arr)            
            obj.pipeOrderArr = arr;
        end
        
        function obj = readConfigCsv( obj, key)
            switch key
                case 'PanelConfig'
                    obj.panel_config = readtable(obj.panel_config_filename);
                case 'PanelDetail'
                    obj.panel_detail = readtable(obj.panel_detail_filename);
            end
        end
    
        function obj = saveConfigCsv( obj, key )
           
            switch key
                case 'PanelConfig'
                    if ~isempty(obj.panel_config)
                        writetable(obj.panel_config, obj.panel_config_filename, 'WriteMode', 'overwrite');
                        obj.readConfigCsv('panel_config');
                    end
                case 'PanelDetail'
                    if ~isempty(obj.panel_config)
                        writetable(obj.panel_detail, obj.panel_detail_filename);
                    end
            end
        end
        
    end
    
end