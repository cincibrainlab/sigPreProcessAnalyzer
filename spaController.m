classdef spaController < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        folder = struct();
    end
    
    methods
        function obj = spaController()
            %SPACONTROLLER Construct an instance of this class
            %   Controller class for Signal Preprocess Analyzer
        end

        function [selectedFolder, obj] = openFolder(obj)
            %SELECTFOLDER
             selectedFolder = uigetdir;
             obj.folder.currentdata = selectedFolder;
        end
    end
    
end

