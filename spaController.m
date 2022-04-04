classdef spaController < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        current_folder;  % current user-selected directory
        current_files;   % all SET files in current directory
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
        end

        function [selectedFolder, obj] = openFolder(obj)
            %SELECTFOLDER
            selectedFolder = uigetdir;
            obj.current_folder = selectedFolder;
            
            a=dir(fullfile(selectedFolder,'*.set'));                         % Obtains the contents of the selected path.
            b={a(:).name}';                      % Gets the name of the files/folders of the contents and stores them appropriately in a cell array
            b(ismember(b,{'.','..'})) = [];      % Removes unnecessary '.' and '..' results from the display.
            
            obj.current_files = b;
        end
    end
    
end

