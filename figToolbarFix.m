function [] = figToolbarFix(hFig)
%UNTITLED2 Summary of this function goes here
%   Customize the default figure toolbar
%   hFig = handle of figure to be customized
%
%   Example: figToolbarFix(gcf);
%   Example: hFig=figure; figToolbarFix(hFig);
% enable the old 'zoom', 'rotation', 'pan', 'data tips', etc., buttons 
%addToolbarExplorationButtons(hFig)
% load a pretty images to use for our buttons. Check MATLAB\release\toolbox\matlab\icons for other options, or
% make your own. Note the double conversion (rgb -> ind -> rgb) to normalize a png image.
[img1,map1] = rgb2ind(imread(fullfile(matlabroot,...
    'toolbox','matlab','icons','tool_plottools_show.png')),32);
[img2,map2] = imread(fullfile(matlabroot,...
    'toolbox','matlab','icons','pageicon.gif'));
% Convert image from indexed to truecolor (want true color RGB with values of 0 to 1)
icon1 = ind2rgb(img1,map1);
icon2 = ind2rgb(img2,map2);
% Get hiddenhandle of the toolbar we want to append to. By default the 'Figure Toolbar' is the only one active
% and should be listed last assuming a new, blank figure. Use 'figure; allchild(gcf)' to show all children
hToolbar=findall(gcf, 'type', 'uitoolbar');
% hToolbar=allchild(hFig)
% hToolbar=hToolbar(end)
%% for Seperate property editor and plot browser buttons
% % Add a new uipushtool to the end of the toolbar.
% uipushtool(hToolbar,'CData',icon1,...
%     'TooltipString','Property Editor',...
%     'ClickedCallback','propertyeditor',...
%     'Separator','on',...
%     'HandleVisibility','off');
% 
% % Add a new uipushtool to the end of the toolbar.
% uipushtool(hToolbar,'CData',icon2,...
%     'TooltipString','Plot Browser',...
%     'ClickedCallback','plotbrowser',...
%     'Separator','off',...
%     'HandleVisibility','off');
%% for a single toggle that opens/closes the previous state of the plot tools (use view menu to show/hide plot/browser/editor)
uitoggletool(hToolbar,'CData',icon2,...
    'TooltipString','saveallformat',...
    'OnCallBack',@saveallformat,...
    'Separator','on',...
    'HandleVisibility','off');

    function saveallformat(obj,event)
        aa=gcf;
        aa.Name
        export_fig([aa.Name,'.png'] ,'-transparent', '-png', '-native')
        %saveas(gcf,[aa.Name,'.png'],'png')
        saveas(gcf,[aa.Name,'.eps'],'epsc')
        savefig([aa.Name,'.fig'])
        
    end
end