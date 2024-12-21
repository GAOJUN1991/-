function ImageProcessingGUI
    % 创建主窗口
    fig = figure('Name', '图像处理系统', 'Position', [100 100 1200 800], ...
        'NumberTitle', 'off', 'MenuBar', 'none');
    
    % 创建菜单栏
    fileMenu = uimenu(fig, 'Label', '文件');
    uimenu(fileMenu, 'Label', '打开图像', 'Callback', @openImage);
    uimenu(fileMenu, 'Label', '保存图像', 'Callback', @saveImage);
    
    % 创建功能面板
    controlPanel = uipanel('Title', '功能区', 'Position', [0.01 0.01 0.2 0.98]);
    
    % 创建显示区域
    axes('Parent', fig, 'Position', [0.25 0.55 0.35 0.4]);
    title('原始图像');
    axes('Parent', fig, 'Position', [0.65 0.55 0.35 0.4]);
    title('处理结果');
    axes('Parent', fig, 'Position', [0.25 0.05 0.35 0.4]);
    title('直方图/特征');
    axes('Parent', fig, 'Position', [0.65 0.05 0.35 0.4]);
    title('其他信息');
    
    % 创建功能按钮
    btnHeight = 0.05;
    btnGap = 0.01;
    btnWidth = 0.18;
    startY = 0.9;
     % 直方图相关
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '显示直方图', ...
        'Position', [10 startY*400 150 30], ...
        'Callback', @showHistogram);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '直方图均衡化', ...
        'Position', [10 (startY-btnHeight-btnGap)*400 150 30], ...
        'Callback', @histEqualization);
    
    % 图像增强
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '线性增强', ...
        'Position', [10 (startY-2*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @linearEnhancement);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '对数变换', ...
        'Position', [10 (startY-3*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @logTransform);
    
    % 几何变换
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '图像缩放', ...
        'Position', [10 (startY-4*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @imageResize);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '图像旋转', ...
        'Position', [10 (startY-5*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @imageRotate);
    
    % 噪声与滤波
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '添加噪声', ...
        'Position', [10 (startY-6*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @addNoise);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '空域滤波', ...
        'Position', [10 (startY-7*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @spatialFilter);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '频域滤波', ...
        'Position', [10 (startY-8*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @frequencyFilter);
    
    % 边缘检测
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '边缘检测', ...
        'Position', [10 (startY-9*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @edgeDetection);
    
    % 特征提取
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', 'LBP特征', ...
        'Position', [10 (startY-10*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @extractLBP);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', 'HOG特征', ...
        'Position', [10 (startY-11*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @extractHOG);
    
    % 存储全局变量
    handles = guihandles(fig);
    handles.originalImage = [];
    handles.processedImage = [];
    guidata(fig, handles);
end
% 基础函数：打开图像
function openImage(hObject, ~)
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', '图像文件 (*.jpg, *.png, *.bmp)'});
    if filename ~= 0
        handles = guidata(hObject);
        handles.originalImage = imread(fullfile(pathname, filename));
        if size(handles.originalImage, 3) == 3
            handles.originalImage = rgb2gray(handles.originalImage);
        end
        axes(findobj(gcf, 'Position', [0.25 0.55 0.35 0.4]));
        imshow(handles.originalImage);
        title('原始图像');
        guidata(hObject, handles);
    end
end

% 保存图像
function saveImage(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.processedImage)
        [filename, pathname] = uiputfile({'*.jpg;*.png;*.bmp','图像文件 (*.jpg, *.png, *.bmp)'});
        if filename ~= 0
            imwrite(handles.processedImage, fullfile(pathname, filename));
            msgbox('图像保存成功！', '提示');
        end
    end
end
% 显示直方图
function showHistogram(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        axes(findobj(gcf, 'Position', [0.25 0.05 0.35 0.4]));
        imhist(handles.originalImage);
        title('灰度直方图');
    end
end

% 直方图均衡化
function histEqualization(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        handles.processedImage = histeq(handles.originalImage);
        axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
        imshow(handles.processedImage);
        title('直方图均衡化结果');
        
        % 显示处理后的直方图
        axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
        imhist(handles.processedImage);
        title('均衡化后的直方图');
        
        guidata(hObject, handles);
    end
end
