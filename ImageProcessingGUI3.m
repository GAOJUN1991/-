function ImageProcessingGUI2
    % 创建主窗口
    fig = figure('Name', '图像处理系统', 'Position', [100 100 1200 800],'NumberTitle', 'off', 'MenuBar', 'none');
    
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
% 线性增强
function linearEnhancement(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        prompt = {'对比度增益(1-3):','亮度调整(-50到50):'};
        dlgtitle = '线性增强参数';
        dims = [1 35];
        definput = {'1.5','0'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        
        if ~isempty(answer)
            contrast = str2double(answer{1});
            brightness = str2double(answer{2});
            
            % 限制参数范围
            contrast = max(1, min(3, contrast));
            brightness = max(-50, min(50, brightness));
            
            % 线性变换
            handles.processedImage = uint8(contrast * double(handles.originalImage) + brightness);
            
            % 显示结果
            axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
            imshow(handles.processedImage);
            title(sprintf('线性增强结果 (对比度:%.1f, 亮度:%d)', contrast, brightness));
            
            % 显示处理后的直方图
            axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
            imhist(handles.processedImage);
            title('增强后的直方图');
            
            guidata(hObject, handles);
        end
    end
end

% 对数变换
function logTransform(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        prompt = {'对数变换参数 c (0.1-2):'};
        dlgtitle = '对数变换';
        dims = [1 35];
        definput = {'1'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        
        if ~isempty(answer)
            c = str2double(answer{1});
            c = max(0.1, min(2, c));
            
            % 对数变换
            handles.processedImage = uint8(c * log(1 + double(handles.originalImage)));
            
            % 显示结果
            axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
            imshow(handles.processedImage);
            title(['对数变换结果 (c = ' num2str(c) ')']);
            
            % 显示处理后的直方图
            axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
            imhist(handles.processedImage);
            title('变换后的直方图');
            
            guidata(hObject, handles);
        end
    end
end

% 图像缩放
function imageResize(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        prompt = {'水平缩放比例 (0.1-5):', '垂直缩放比例 (0.1-5):'};
        dlgtitle = '图像缩放';
        dims = [1 35];
        definput = {'1.5', '1.5'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        
        if ~isempty(answer)
            scaleX = str2double(answer{1});
            scaleY = str2double(answer{2});
            
            % 限制缩放范围
            scaleX = max(0.1, min(5, scaleX));
            scaleY = max(0.1, min(5, scaleY));
            
            % 计算新尺寸
            [rows, cols] = size(handles.originalImage);
            newSize = [round(rows * scaleY), round(cols * scaleX)];
            
            % 执行缩放
            handles.processedImage = imresize(handles.originalImage, newSize, 'bicubic');
            
            % 显示结果
            axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
            imshow(handles.processedImage);
            title(sprintf('缩放结果 (%.1fx%.1f)', scaleX, scaleY));
            
            % 显示尺寸信息
            axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
            cla;
            text(0.1, 0.5, sprintf('原始尺寸: %dx%d\n新尺寸: %dx%d', ...
                rows, cols, newSize(1), newSize(2)), 'FontSize', 12);
            axis off;
            
            guidata(hObject, handles);
        end
    end
end

% 图像旋转
function imageRotate(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        prompt = {'旋转角度 (-360到360):', '是否裁剪(1:是, 0:否):'};
        dlgtitle = '图像旋转';
        dims = [1 35];
        definput = {'45', '1'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        
        if ~isempty(answer)
            angle = str2double(answer{1});
            doCrop = str2double(answer{2});
            
            % 限制角度范围
            angle = mod(angle, 360);
            
            % 执行旋转
            if doCrop
                handles.processedImage = imrotate(handles.originalImage, angle, 'bilinear', 'crop');
            else
                handles.processedImage = imrotate(handles.originalImage, angle, 'bilinear', 'loose');
            end
            
            % 显示结果
            axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
            imshow(handles.processedImage);
            title(sprintf('旋转结果 (角度: %.1f°)', angle));
            
            % 显示尺寸信息
            [origRows, origCols] = size(handles.originalImage);
            [newRows, newCols] = size(handles.processedImage);
            axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
            cla;
            text(0.1, 0.5, sprintf('原始尺寸: %dx%d\n旋转后尺寸: %dx%d', ...
                origRows, origCols, newRows, newCols), 'FontSize', 12);
            axis off;
            
            guidata(hObject, handles);
        end
    end
end

% 添加噪声
function addNoise(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        % 创建噪声类型选择对话框
        noiseTypes = {'gaussian', 'salt & pepper', 'speckle'};
        [indx,tf] = listdlg('ListString',noiseTypes,...
            'SelectionMode','single',...
            'PromptString','选择噪声类型:');
        
        if tf
            switch indx
                case 1 % 高斯噪声
                    prompt = {'均值:', '方差:'};
                    dlgtitle = '高斯噪声参数';
                    dims = [1 35];
                    definput = {'0', '0.01'};
                    answer = inputdlg(prompt,dlgtitle,dims,definput);
                    
                    if ~isempty(answer)
                        mean = str2double(answer{1});
                        variance = str2double(answer{2});
                        handles.processedImage = imnoise(handles.originalImage, 'gaussian', mean, variance);
                    end
                    
                case 2 % 椒盐噪声
                    prompt = {'噪声密度 (0-1):'};
                    dlgtitle = '椒盐噪声参数';
                    dims = [1 35];
                    definput = {'0.05'};
                    answer = inputdlg(prompt,dlgtitle,dims,definput);
                    
                    if ~isempty(answer)
                        density = str2double(answer{1});
                        handles.processedImage = imnoise(handles.originalImage, 'salt & pepper', density);
                    end
                    
                case 3 % 斑点噪声
                    prompt = {'噪声方差 (0-1):'};
                    dlgtitle = '斑点噪声参数';
                    dims = [1 35];
                    definput = {'0.04'};
                    answer = inputdlg(prompt,dlgtitle,dims,definput);
                    
                    if ~isempty(answer)
                        variance = str2double(answer{1});
                        handles.processedImage = imnoise(handles.originalImage, 'speckle', variance);
                    end
            end
            
            if ~isempty(answer)
                % 显示结果
                axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
                imshow(handles.processedImage);
                title(['添加' noiseTypes{indx} '噪声结果']);
                
                % 显示噪声图像的直方图
                axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
                imhist(handles.processedImage);
                title('噪声图像直方图');
                
                guidata(hObject, handles);
            end
        end
    end
end