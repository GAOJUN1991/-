
function ImageProcessingGUI4
clear; clc; close all;
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
        'String', '线性变换', ...
        'Position', [10 (startY-2*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @linearEnhancement);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '非线性变换', ...
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
        axes(findobj(gcf, 'Position', [0.25 0.55 0.35 0.4]));
        imshow(rgb2gray(handles.originalImage));
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
    handles.originalImage = rgb2gray(handles.originalImage);
    histgram=zeros(256);
    [h, w]= size(handles.originalImage);
    for x=1:w
        for y= 1:h
            histgram(handles.originalImage(y,x)+1)= histgram(handles.originalImage(y,x)+1)+ 1;
        end
    end
    axes(findobj(gcf, 'Position', [0.25 0.05 0.35 0.4]));
    stem(histgram(),'.');
    title('灰度直方图');
    axis tight;
end
end

% 直方图均衡化
function histEqualization(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        handles.originalImage = rgb2gray(handles.originalImage);
        histgram =imhist(handles.originalImage);
        [h, w]= size(handles.originalImage);
        handles.processedImage = zeros(h,w);
        s=zeros(256);
        s(1)= histgram(1);
        for t=2:256
            s(t)=s(t-1)+ histgram(t);
        end
        for x=1:w
            for y= 1:h
                handles.processedImage(y,x)= s(handles.originalImage(y,x) + 1)/(w * h);
            end
        end
        
        % 显示处理后的直方图
        axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
        imhist(handles.originalImage);
        title('原图的直方图');
        axis tight;

        % 显示处理后的图像
        axes(findobj(gcf, 'Position', [0.25 0.05 0.35 0.4]));
        imshow(handles.processedImage);
        title('直方图均衡化结果');

        % 显示处理后的直方图
        axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
        imhist(handles.processedImage);
        title('均衡化后的直方图');
        axis tight;
        guidata(hObject, handles);
    end
end

% 线性变换
function linearEnhancement(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        handles.originalImage = im2double(rgb2gray(handles.originalImage));
        [h,w]=size(handles.originalImage);   %获取图像尺寸
        handles.processedImage=zeros(h,w);
        a=30/256; b=100/256; c=75/256; d=200/256;  %参数设置
        for x=1:w
            for y=1:h
                if handles.originalImage(y,x)<a
                    handles.processedImage(y,x)=handles.originalImage(y,x)*c/a;
                elseif handles.originalImage(y,x)<b
                    handles.processedImage(y,x)=(handles.originalImage(y,x)-a)*(d-c)/(b-a)+c;%分段线性变换
                else
                    handles.processedImage(y,x)=(handles.originalImage(y,x)-b)*(1-d)/(1-b)+d;
                end
            end
        end
            % 显示结果
            axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
            imshow(handles.processedImage);
            title('线性变换后的图像');
            guidata(hObject, handles);
        
    end
end

% 非线性变换
function logTransform(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        handles.originalImage = rgb2gray(handles.originalImage);
        handles.originalImage = double(handles.originalImage);

        NewImage1=46*log(handles.originalImage+1);     %对数函数非线性灰度级变换
        NewImage2=185*exp(0.325*(handles.originalImage-225)/30)+1;%指数函数非线性灰度级变换


        % 显示结果
        axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
        imshow(NewImage1,[]);
        title('对数变换结果');
        axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
        imshow(NewImage2,[]);
        title('指数变换结果');

        guidata(hObject, handles);
        
    end
end

% 图像缩放
function imageResize(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        handles.originalImage = rgb2gray(handles.originalImage);
        prompt = {'水平缩放比例 (0.1-5):', '垂直缩放比例 (0.1-5):'};
        dlgtitle = '图像缩放';
        dims = [1 35];
        definput = {'0.5', '0.5'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        
        if ~isempty(answer)
            scaleX = str2double(answer{1});
            scaleY = str2double(answer{2});
            
            % 限制缩放范围
            scaleX = max(0.1, min(5, scaleX));
            scaleY = max(0.1, min(5, scaleY));
            % 计算新尺寸
            [rows, cols] = size(handles.originalImage);

            disp([rows, cols])
            newSize = [round(rows * scaleY), round(cols * scaleX)];
            disp(newSize)
            % 执行缩放
            handles.processedImage = imresize(handles.originalImage, newSize, 'bilinear');
         resultAxes = findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]);
            
            % 清空axes并重置属性
            cla(resultAxes);
            % 设置axes的单位为像素
            set(resultAxes, 'Units', 'pixels');
            % 获取axes的位置和大小
            axesPos = get(resultAxes, 'Position');
            
            % 在axes中显示图像，关闭自适应缩放
            imshow(handles.processedImage, 'Parent', resultAxes, 'InitialMagnification', 'fit');
            
            % 添加标题
            title(resultAxes, sprintf('缩放结果 (%.1fx%.1f)\n原始尺寸: %dx%d\n缩放后尺寸: %dx%d', ...
                scaleX, scaleY, rows, cols, newSize(1), newSize(2)));
            
            % 在信息显示区域显示详细信息
            infoAxes = findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]);
            cla(infoAxes);
            text(infoAxes, 0.1, 0.8, sprintf('原始图像尺寸: %d x %d', rows, cols), 'FontSize', 12);
            text(infoAxes, 0.1, 0.6, sprintf('缩放后尺寸: %d x %d', newSize(1), newSize(2)), 'FontSize', 12);
            text(infoAxes, 0.1, 0.4, sprintf('缩放比例: %.2f x %.2f', scaleX, scaleY), 'FontSize', 12);
            if scaleX < 1 || scaleY < 1
                text(infoAxes, 0.1, 0.2, '缩小操作', 'FontSize', 12, 'Color', 'blue');
            else
                text(infoAxes, 0.1, 0.2, '放大操作', 'FontSize', 12, 'Color', 'red');
            end
            axis(infoAxes, 'off');
      
            
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
        handles.originalImage = rgb2gray(handles.originalImage);
        % 创建噪声类型选择对话框
        noiseTypes = {'gaussian', 'salt & pepper', 'speckle'};
        [indx,tf] = listdlg('ListString',noiseTypes,'SelectionMode','single','PromptString','选择噪声类型:');
        
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

                guidata(hObject, handles);
            end
        end
    end
end
% 空域滤波函数
function spatialFilter(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        
        % 创建滤波器类型选择对话框
        filterTypes = {'均值滤波', '中值滤波', '高斯滤波'};
        [indx,tf] = listdlg('ListString',filterTypes,...
            'SelectionMode','single',...
            'PromptString','选择滤波器类型:');
        
        if tf
            switch indx
                case 1 % 均值滤波
                    handles.processedImage = imfilter(handles.originalImage, fspecial('average', [3 3]));
                case 2 % 中值滤波
                    handles.processedImage = medfilt2(handles.originalImage);
                case 3 % 高斯滤波
                    handles.processedImage = imgaussfilt(handles.originalImage, 1);
            end
            
            axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
            imshow(handles.processedImage);
            title([filterTypes{indx} '结果']);
            guidata(hObject, handles);
        end
    end
end

% 频域滤波函数
function frequencyFilter(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        % 创建滤波器类型选择对话框
        filterTypes = {'低通滤波', '高通滤波'};
        [indx,tf] = listdlg('ListString',filterTypes,...
            'SelectionMode','single',...
            'PromptString','选择滤波器类型:');
        
        if tf
            % 转换到频域
            F = fft2(double(handles.originalImage));
            F = fftshift(F);
            [M, N] = size(F);
            
            % 创建滤波器
            u = 0:M-1;
            v = 0:N-1;
            idx = find(u > M/2);
            u(idx) = u(idx) - M;
            idy = find(v > N/2);
            v(idy) = v(idy) - N;
            [V, U] = meshgrid(v, u);
            D = sqrt(U.^2 + V.^2);
            
            % 设置截止频率
            D0 = 30;
            
            switch indx
                case 1 % 低通滤波
                    H = double(D <= D0);
                case 2 % 高通滤波
                    H = double(D > D0);
            end
            
            % 应用滤波器
            G = H.*F;
            G = ifftshift(G);
            handles.processedImage = uint8(real(ifft2(G)));
            
            axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
            imshow(handles.processedImage);
            title([filterTypes{indx} '结果']);
            guidata(hObject, handles);
        end
    end
end

% 边缘检测函数
function edgeDetection(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        % 创建边缘检测算子选择对话框
        operators = {'Roberts', 'Prewitt', 'Sobel', 'Laplacian'};
        [indx,tf] = listdlg('ListString',operators,...
            'SelectionMode','single',...
            'PromptString','选择边缘检测算子:');
        
        if tf
            switch indx
                case 1 % Roberts
                    handles.processedImage = edge(handles.originalImage, 'roberts');
                case 2 % Prewitt
                    handles.processedImage = edge(handles.originalImage, 'prewitt');
                case 3 % Sobel
                    handles.processedImage = edge(handles.originalImage, 'sobel');
                case 4 % Laplacian
                    handles.processedImage = edge(handles.originalImage, 'log');
            end
            
            axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
            imshow(handles.processedImage);
            title([operators{indx} '边缘检测结果']);
            guidata(hObject, handles);
        end
    end
end

% HOG特征提取函数
function extractHOG(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        % 计算HOG特征
        [featureVector, hogVisualization] = extractHOGFeatures(handles.originalImage);
        
        % 显示HOG特征可视化结果
        axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
        plot(hogVisualization);
        title('HOG特征可视化');
        
        % 显示特征向量直方图
        axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
        bar(featureVector);
        title('HOG特征向量');
        xlabel('特征维度');
        ylabel('特征值');
        
        guidata(hObject, handles);
    end
end