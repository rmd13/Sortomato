function [graphMSD, axesGraph] = sortomatomsdgraph(guiMSD, xObject, hSortomatoBase)
    % SORTOMATOMSDGRAPH Create and prepare an MSD figure window
    %   Detailed explanation goes here
    %
    %
    
    %% Set the figure and font colors.
    if all(get(guiMSD, 'Color') == [0 0 0])
        sortomatomsdgraphCData = load('sortomatomsdgraphK_cdata.mat');
        
        bColor = 'k';
        bColorJava = java.awt.Color.black;
        
        axColor = 0.75*ones(3, 1);
        
    else
        sortomatomsdgraphCData = load('sortomatomsdgraph_cdata.mat');
        bColor = 'w';
        bColorJava = java.awt.Color.white;
        
        axColor = 0.25*ones(3, 1);
        
    end % if
    
    %% Create the figure.
    parentPos = get(guiMSD, 'Position');
    
    guiWidth = 560;
    guiHeight = 420;
    guiPos = [...
        parentPos(1, 1) + 25, ...
        parentPos(1, 2) + parentPos(1, 4) - guiHeight - 50, ...
        guiWidth, ...
        guiHeight]; 
    
    graphMSD = figure(...
        'CloseRequestFcn', {@closerequestfcn, hSortomatoBase}, ...
        'Color', bColor, ...
        'DockControls', 'off', ...
        'InvertHardCopy', 'off', ...
        'MenuBar', 'None', ...
        'Name', [char(xObject.GetName) ' MSD'], ...
        'NumberTitle', 'off', ...
        'PaperPositionMode', 'auto', ...
        'Position', guiPos, ...
        'Renderer', 'ZBuffer', ...
        'Tag', 'graphMSD');
    
    axesGraph = axes(...
        'Color', 'None', ...
        'FontSize', 12, ...
        'Linewidth', 2, ...
        'Parent', graphMSD, ...
        'Tag', 'axesGraph', ...
        'TickDir', 'out', ...
        'XColor', axColor, ...
        'YColor', axColor, ...
        'ZColor', axColor);

    %% Create the toolbar and toolbar buttons.
    toolbarGraph = uitoolbar(graphMSD, ...
        'Tag', 'toolbarMSDGraph');

    % Create the toolbar buttons.
    uitoggletool(toolbarGraph, ...
        'CData', sortomatomsdgraphCData.DataCursor, ...
        'ClickedCallback', {@sortomatographtoggledatacursor, graphMSD}, ...
        'Tag', 'toggleDataCursor', ...
        'TooltipString', 'Activate the data cursor')
    
    uitoggletool(toolbarGraph, ...
        'CData', sortomatomsdgraphCData.Zoom, ...
        'ClickedCallback', {@sortomatographtogglezoom, graphMSD}, ...
        'Tag', 'toggleZoom', ...
        'TooltipString', 'Activate zooming')
    
    uitoggletool(toolbarGraph, ...
        'CData', sortomatomsdgraphCData.Pan, ...
        'ClickedCallback', {@sortomatographtogglepan, graphMSD}, ...
        'Tag', 'togglePan', ...
        'TooltipString', 'Activate panning')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatomsdgraphCData.ManualLimits, ...
        'ClickedCallback', {@sortomatomanuallimits, graphMSD}, ...
        'Tag', 'pushManualLimits', ...
        'TooltipString', 'Set automatic or manual axes limits')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatomsdgraphCData.GraphExport, ...
        'ClickedCallback', {@sortomatographpushgraphexport, graphMSD}, ...
        'Separator', 'on', ...
        'Tag', 'pushGraphExport', ...
        'TooltipString', 'Export the current graph')
    
    uipushtool(toolbarGraph, ...
        'CData', sortomatomsdgraphCData.GraphDataExport, ...
        'ClickedCallback', {@sortomatographpushdataexport, graphMSD}, ...
        'Tag', 'pushGraphDataExport', ...
        'TooltipString', 'Export the current graph data')
    
    %% Set the toobar and button backgrounds.
    % Get the underlying JToolBar component.
    drawnow
    jToolbar = get(get(toolbarGraph, 'JavaContainer'), 'ComponentPeer');
    
    % Set the toolbar background color.
    jToolbar.setBackground(bColorJava);
    jToolbar.getParent.getParent.setBackground(bColorJava);
    
    % Set the toolbar components' background color.
    jtbComponents = jToolbar.getComponents;
    for t = 1:length(jtbComponents)
        jtbComponents(t).setOpaque(false);
        jtbComponents(t).setBackground(bColorJava);
    end % for t
    
    % Set the toolbar more icon to a custom icon that matches the figure color.
    javaImage = im2java(sortomatomsdgraphCData.MoreToolbar);
    javaIcon = javax.swing.ImageIcon(javaImage);
    jtbComponents(1).setIcon(javaIcon)
    jtbComponents(1).setToolTipText('More tools')
                
    %% Add the figure to the base's graph children.
    graphChildren = getappdata(hSortomatoBase, 'graphChildren');
    graphChildren = [graphChildren; graphMSD];
    setappdata(hSortomatoBase, 'graphChildren', graphChildren)

    %% Store the XT objects and data associated with the figure.
    setappdata(graphMSD, 'hSortomatoBase', hSortomatoBase)
    setappdata(graphMSD, 'xObject', xObject)
    xImarisApp = getappdata(hSortomatoBase, 'xImarisApp');
    setappdata(graphMSD, 'xImarisApp', xImarisApp)
end % sortomatomsdgraph


function closerequestfcn(hObject, ~, hSortomatoBase)
    % Close sortomato sub-GUIs
    %
    %
    
    %% Close the limits window if it exists.
    hLimits = getappdata(hObject, 'hLimits');
    if ishandle(hLimits)
        delete(hLimits)
    end % if
        
    %% Remove the graph GUI handle from the base GUI appdata.
    % Get the graph GUI handles list from the base GUI.
    graphChildren = getappdata(hSortomatoBase, 'graphChildren');

    % Remove the current graph from the list.
    graphChildren(graphChildren == hObject) = [];

    % Replace the appdata.
    setappdata(hSortomatoBase, 'graphChildren', graphChildren)
        
    % Now delete the graph figure.
    delete(hObject);    
end % closerequestfcn