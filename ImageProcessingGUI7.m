
function ImageProcessingGUI7
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


     % 重置图像
     uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
         'String', '重置图像', ...
         'Position', [10 (startY+btnHeight+btnGap)*400 150 30], ...
         'Callback', @resetImage);

     % 直方图相关
     uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
         'String', '显示直方图', ...
         'Position', [10 startY*400 150 30], ...
         'Callback', @showHistogram);

     uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
         'String', '直方图均衡化', ...
         'Position', [10 (startY-btnHeight-btnGap)*400 150 30], ...
         'Callback', @histEqualization);

     uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
         'String', '直方图匹配', ...
         'Position', [10 (startY-2*(btnHeight+btnGap))*400 150 30], ...
         'Callback', @histogramMatching);

    
    % 图像增强
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '线性变换', ...
        'Position', [10 (startY-3*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @linearEnhancement);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '非线性变换', ...
        'Position', [10 (startY-4*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @logTransform);
    
    % 几何变换
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '图像缩放', ...
        'Position', [10 (startY-5*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @imageResize);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '图像旋转', ...
        'Position', [10 (startY-6*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @imageRotate);
    
    % 噪声与滤波
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '添加噪声', ...
        'Position', [10 (startY-7*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @addNoise);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '空域滤波', ...
        'Position', [10 (startY-8*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @spatialFilter);
    
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '频域滤波', ...
        'Position', [10 (startY-9*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @frequencyFilter);

    % 边缘检测
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '边缘检测', ...
        'Position', [10 (startY-10*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @edgeDetection);

    % 目标提取与特征分析
    uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '目标提取与特征分析', ...
        'Position', [10 (startY-11*(btnHeight+btnGap))*400 150 30], ...
        'Callback', @objectExtraction);
    
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
            % 彩色图像，转换为灰度图显示
            axes(findobj(gcf, 'Position', [0.25 0.55 0.35 0.4]));
            imshow(rgb2gray(handles.originalImage));
            title('原始图像（灰度化）');
        else
            % 灰度图像，直接显示
            axes(findobj(gcf, 'Position', [0.25 0.55 0.35 0.4]));
            imshow(handles.originalImage);
            title('原始图像');
        end
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


% 重置函数
function resetImage(hObject, ~)
fig = gcf;
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        % 恢复原始图像
        if ~isfield(handles, 'backupImage')
            handles.backupImage = handles.originalImage;
        end
        handles.originalImage = handles.backupImage;
        handles.processedImage = [];
         % 假设该坐标轴的位置为 [0.25 0.55 0.35 0.4]
ax = findobj(gcf, 'Position', [0.25 0.55 0.35 0.4]);

% 如果找到该坐标轴，删除它
if ~isempty(ax)
    delete(ax);
end

ax = findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]);

% 如果找到该坐标轴，删除它
if ~isempty(ax)
    delete(ax);
end
ax = findobj(gcf, 'Position', [0.25 0.05 0.35 0.4]);

% 如果找到该坐标轴，删除它
if ~isempty(ax)
    delete(ax);
end
ax = findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]);

% 如果找到该坐标轴，删除它
if ~isempty(ax)
    delete(ax);
end
    axes('Parent', fig, 'Position', [0.25 0.55 0.35 0.4]);
    imshow(rgb2gray(handles.originalImage));
    title('原始图像');
    axes('Parent', fig, 'Position', [0.65 0.55 0.35 0.4]);
    title('处理结果');
    axes('Parent', fig, 'Position', [0.25 0.05 0.35 0.4]);
    title('直方图/特征');
    axes('Parent', fig, 'Position', [0.65 0.05 0.35 0.4]);
    title('其他信息');
       
        
        guidata(hObject, handles);
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
    
end
end

% 直方图均衡化 
function histEqualization(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        handles.originalImage = rgb2gray(handles.originalImage);
        histgram = imhist(handles.originalImage);
        [h, w] = size(handles.originalImage);
        handles.processedImage = zeros(h, w);
        s = zeros(256, 1);
        s(1) = histgram(1);
        
        % 计算累积分布函数 (CDF)
        for t = 2:256
            s(t) = s(t-1) + histgram(t);
        end
        
        % 进行直方图均衡化
        for x = 1:w
            for y = 1:h
                handles.processedImage(y, x) = s(handles.originalImage(y, x) + 1) / (w * h);
            end
        end
        
        % 显示处理前的直方图（使用stem）
        axes(findobj(gcf, 'Position', [0.25 0.05 0.35 0.4]));
        stem(0:255, histgram, 'Marker', 'none'); % 使用 stem 绘制直方图
        title('原图的直方图');
        
        % 显示处理后的图像
        axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
        imshow(handles.processedImage);
        title('直方图均衡化结果');
        
        % 显示处理后的直方图（使用stem）
        axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
        processedHist = imhist(handles.processedImage);
        stem(0:255, processedHist, 'Marker', 'none'); % 使用 stem 绘制均衡化后的直方图
        title('均衡化后的直方图');
        
        guidata(hObject, handles);
    end
end

function histogramMatching(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
        % 选择目标直方图图像
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', '图像文件 (*.jpg, *.png, *.bmp)'}, '选择参考图像');
        if filename ~= 0
            % 读取参考图像
            refImage = imread(fullfile(pathname, filename));
            if size(refImage, 3) == 3
                refImage = rgb2gray(refImage);
            end
            
            % 确保原始图像为灰度图
            if size(handles.originalImage, 3) == 3
                handles.originalImage = rgb2gray(handles.originalImage);
            end
            
            % 计算原始图像直方图和累积分布函数
            [h_orig, cdf_orig] = calculateHistogramAndCDF(handles.originalImage);
            
            % 计算参考图像直方图和累积分布函数
            [h_ref, cdf_ref] = calculateHistogramAndCDF(refImage);
            
            % 执行直方图匹配
            handles.processedImage = performHistogramMatching(handles.originalImage, cdf_orig, cdf_ref);
            
            % 计算匹配后图像的直方图
            [h_matched, ~] = calculateHistogramAndCDF(handles.processedImage);
            
            % 显示原始图像
            axes(findobj(gcf, 'Position', [0.25 0.55 0.35 0.4]));
            imshow(handles.originalImage);
            title('原始图像');
            
            % 显示参考图像
            axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
            imshow(refImage);
            title('参考图像');
            
            % 显示匹配后的图像
            axes(findobj(gcf, 'Position', [0.25 0.05 0.35 0.4]));
            imshow(handles.processedImage);
            title('直方图匹配结果');
            
            % 显示三个直方图的对比
            axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
            plot(h_orig/sum(h_orig), 'b-', 'LineWidth', 1);
            hold on;
            plot(h_ref/sum(h_ref), 'r--', 'LineWidth', 1);
            plot(h_matched/sum(h_matched), 'g:', 'LineWidth', 1);
            legend('原始直方图', '参考直方图', '匹配后直方图');
            title('直方图对比');
            hold off;
            
            guidata(hObject, handles);
        end
    end
end

% 计算直方图和累积分布函数
function [histogram, cdf] = calculateHistogramAndCDF(image)
    % 初始化直方图数组
    histogram = zeros(256, 1);
    [rows, cols] = size(image);
    
    % 计算直方图
    for i = 1:rows
        for j = 1:cols
            intensity = image(i, j);
            histogram(intensity + 1) = histogram(intensity + 1) + 1;
        end
    end
    
    % 计算累积分布函数
    cdf = zeros(256, 1);
    cdf(1) = histogram(1);
    for i = 2:256
        cdf(i) = cdf(i-1) + histogram(i);
    end
    
    % 归一化CDF
    cdf = cdf / (rows * cols);
end

% 执行直方图匹配
function matchedImage = performHistogramMatching(inputImage, cdf_orig, cdf_ref)
    [rows, cols] = size(inputImage);
    matchedImage = zeros(rows, cols, 'uint8');
    
    % 创建灰度级映射表
    mapping = zeros(256, 1);
    for i = 1:256
        % 找到CDF最接近的灰度级
        [~, idx] = min(abs(cdf_ref - cdf_orig(i)));
        mapping(i) = idx - 1;
    end
    
    % 应用映射到原始图像
    for i = 1:rows
        for j = 1:cols
            intensity = inputImage(i, j);
            matchedImage(i, j) = mapping(intensity + 1);
        end
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
                handles.originalImage = handles.processedImage;


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
            
            axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
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
        if size(handles.originalImage, 3) == 3
            workingImage = rgb2gray(handles.originalImage);
        else
            workingImage = handles.originalImage;
        end
        % 创建滤波器类型选择对话框
        filterTypes = {'理想低通滤波', '巴特沃斯低通滤波', '指数低通滤波', '梯度低通滤波'};
        [indx,tf] = listdlg('ListString', filterTypes,...
            'SelectionMode', 'single',...
            'PromptString', '选择滤波器类型:');

        if tf
            % 进行傅里叶变换
            FImage = fftshift(fft2(double(workingImage)));
            [N, M] = size(FImage);
            r1 = floor(M/2);
            r2 = floor(N/2);
            
            switch indx
                case 1  % 理想低通滤波
                    prompt = {'输入截止频率 D0 (建议范围: 5-100):'};
                    dlgtitle = '理想低通滤波参数';
                    dims = [1 35];
                    definput = {'30'};
                    answer = inputdlg(prompt, dlgtitle, dims, definput);
                    
                    if ~isempty(answer)
                        d0 = str2double(answer{1});
                        g = zeros(N, M);
                        for x = 1:M
                            for y = 1:N
                                d = sqrt((x-r1)^2 + (y-r2)^2);
                                if d <= d0
                                    h = 1;
                                else
                                    h = 0;
                                end
                                g(y,x) = h * FImage(y,x);
                            end
                        end
                        handles.processedImage = real(ifft2(ifftshift(g)));
                    end
                    
                case 2  % 巴特沃斯低通滤波
                    prompt = {'输入截止频率 D0 (建议范围: 5-100):', '输入阶数 n (建议范围: 1-6):'};
                    dlgtitle = '巴特沃斯低通滤波参数';
                    dims = [1 35];
                    definput = {'30', '2'};
                    answer = inputdlg(prompt, dlgtitle, dims, definput);
                    
                    if ~isempty(answer)
                        d0 = str2double(answer{1});
                        n = str2double(answer{2});
                        g = zeros(N, M);
                        for x = 1:M
                            for y = 1:N
                                d = sqrt((x-r1)^2 + (y-r2)^2);
                                h = 1/(1 + (d/d0)^(2*n));
                                g(y,x) = h * FImage(y,x);
                            end
                        end
                        handles.processedImage = real(ifft2(ifftshift(g)));
                    end
                    
                case 3  % 指数低通滤波
                    prompt = {'输入截止频率 D0 (建议范围: 5-100):', '输入阶数 n (建议值: 2):'};
                    dlgtitle = '指数低通滤波参数';
                    dims = [1 35];
                    definput = {'30', '2'};
                    answer = inputdlg(prompt, dlgtitle, dims, definput);
                    
                    if ~isempty(answer)
                        d0 = str2double(answer{1});
                        n = str2double(answer{2});
                        g = zeros(N, M);
                        for x = 1:M
                            for y = 1:N
                                d = sqrt((x-r1)^2 + (y-r2)^2);
                                h = exp(-0.5 * (d/d0)^n);
                                g(y,x) = h * FImage(y,x);
                            end
                        end
                        handles.processedImage = real(ifft2(ifftshift(g)));
                    end
                    
                case 4  % 梯度低通滤波
                    prompt = {'输入内圈截止频率 D0 (建议范围: 5-50):', '输入外圈截止频率 D1 (建议范围: D0+20 到 D0+50):'};
                    dlgtitle = '梯度低通滤波参数';
                    dims = [1 35];
                    definput = {'30', '60'};
                    answer = inputdlg(prompt, dlgtitle, dims, definput);
                    
                    if ~isempty(answer)
                        d0 = str2double(answer{1});
                        d1 = str2double(answer{2});
                        g = zeros(N, M);
                        for x = 1:M
                            for y = 1:N
                                d = sqrt((x-r1)^2 + (y-r2)^2);
                                if d > d1
                                    h = 0;
                                else
                                    if d > d0
                                        h = (d1-d)/(d1-d0);
                                    else
                                        h = 1;
                                    end
                                end
                                g(y,x) = h * FImage(y,x);
                            end
                        end
                        handles.processedImage = real(ifft2(ifftshift(g)));
                    end
            end
            
            if ~isempty(answer)
                
                % 显示滤波后的图像
                axes(findobj(gcf, 'Position', [0.25 0.05 0.35 0.4]));
                imshow(uint8(handles.processedImage));
                switch indx
                    case 1
                        title(['理想低通滤波结果 (D0=', num2str(d0), ')']);
                    case 2
                        title(['巴特沃斯低通滤波结果 (D0=', num2str(d0), ', n=', num2str(n), ')']);
                    case 3
                        title(['指数低通滤波结果 (D0=', num2str(d0), ', n=', num2str(n), ')']);
                    case 4
                        title(['梯度低通滤波结果 (D0=', num2str(d0), ', D1=', num2str(d1), ')']);
                end
               
                
                guidata(hObject, handles);
            end
        end
    end
end
% 边缘检测函数
function edgeDetection(hObject, ~)
    handles = guidata(hObject);
    if ~isempty(handles.originalImage)
          handles.originalImage = im2double(rgb2gray(handles.originalImage));
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



function objectExtraction(hObject, ~)
    handles = guidata(hObject);
    
    if ~isempty(handles.originalImage)
        % 确保图像为灰度图
        if size(handles.originalImage, 3) == 3
            grayImage = rgb2gray(handles.originalImage);
        else
            grayImage = handles.originalImage;
        end
        
        % 1. 阈值分割
        level = graythresh(grayImage);
        bw = imbinarize(grayImage, level);
        
        % 2. 形态学处理
        % 先开运算去除小噪声
        se = strel('disk', 3);
        bw = imopen(bw, se);
        % 再闭运算填充小孔
        bw = imclose(bw, se);
        
        % 3. 提取最大连通区域作为目标
        cc = bwconncomp(bw);
        stats = regionprops(cc, 'Area');
        [~, idx] = max([stats.Area]);
        object = false(size(bw));
        object(cc.PixelIdxList{idx}) = true;
        
        % 4. 提取目标
        extractedObject = grayImage;
        extractedObject(~object) = 0;
        
        % 5. 创建选择对话框，让用户选择特征类型
        featureType = questdlg('请选择要使用的特征提取方法：', ...
                               '选择特征', ...
                               'LBP', 'HOG', 'LBP');  % 默认选LBP
        
        % 根据用户选择计算特征
        if strcmp(featureType, 'LBP')
            % 计算原始图像的LBP特征
            [N, M] = size(grayImage);
            lbp_orig = zeros(N, M);
            for j = 2:N-1
                for i = 2:M-1
                    neighbor = [j-1 i-1; j-1 i; j-1 i+1; j i+1; 
                              j+1 i+1; j+1 i; j+1 i-1; j i-1];
                    count = 0;
                    for k = 1:8
                        if grayImage(neighbor(k,1), neighbor(k,2)) > grayImage(j,i)
                            count = count + 2^(8-k);
                        end
                    end
                    lbp_orig(j,i) = count;
                end
            end
            lbp_orig = uint8(lbp_orig);
        
            % 计算提取目标的LBP特征
            lbp_obj = zeros(N, M);
            for j = 2:N-1
                for i = 2:M-1
                    if object(j,i)
                        neighbor = [j-1 i-1; j-1 i; j-1 i+1; j i+1; 
                                  j+1 i+1; j+1 i; j+1 i-1; j i-1];
                        count = 0;
                        for k = 1:8
                            if extractedObject(neighbor(k,1), neighbor(k,2)) > extractedObject(j,i)
                                count = count + 2^(8-k);
                            end
                        end
                        lbp_obj(j,i) = count;
                    end
                end
            end
            lbp_obj = uint8(lbp_obj);

            % 显示提取目标前的LBP特征图
            axes(findobj(gcf, 'Position', [0.25 0.05 0.35 0.4]));
            imshow(lbp_orig); title('提取目标后的LBP特征图');
             % 显示提取目标后的LBP特征图
            axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
            imshow(lbp_obj); title('提取目标后的LBP特征图');

        elseif strcmp(featureType, 'HOG')
            % 计算HOG特征
            % 原始图像的HOG
            [orig_featureVector, orig_hogVisualization] = extractHOGFeatures(grayImage);
            % 目标的HOG
            [obj_featureVector, obj_hogVisualization] = extractHOGFeatures(extractedObject);
            
            % 显示提取目标后的HOG特征图
            axes(findobj(gcf, 'Position', [0.65 0.05 0.35 0.4]));
            plot(obj_hogVisualization); title('提取目标后的HOG特征图');

            % 显示提取目标前的HOG特征图
            axes(findobj(gcf, 'Position', [0.25 0.05 0.35 0.4]));
            plot( orig_hogVisualization); title('目标前的HOG特征图');
        end
        
        % 显示提取的目标图像
        axes(findobj(gcf, 'Position', [0.65 0.55 0.35 0.4]));
        imshow(extractedObject); title('提取的目标');
        
        % 保存提取的目标和特征数据
        handles.processedImage = extractedObject;
        if strcmp(featureType, 'LBP')
            handles.lbp_orig = lbp_orig;
            handles.lbp_obj = lbp_obj;
        elseif strcmp(featureType, 'HOG')
            handles.hog_orig = orig_featureVector;
            handles.hog_obj = obj_featureVector;
        end
        guidata(hObject, handles);
    end
end
