classdef App < handle

    properties
        % 窗口
        win
        winRect
        winSize = [];
        backgroundColor = [0 0 0];
        % 文本
        textColor = [255 255 255];
        textSize = 30;
        textStyle = 0; % 0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend
        textFont = 'Microsoft YaHei UI'; % SimSun宋体,KaiTi楷体,Microsoft JhengHei黑体
        % 实验环境
        screenZoom = 1; % 系统屏幕缩放
        screenSize = [34.4, 19.5]; % 屏幕尺寸, 单位cm
        distance = 57; % 眼睛到屏幕的距离, 单位cm
        % 按键
        continueKey = 'space';
        % 音频
        portAudio; % 端口音频
        sampleRate; % 音频采样率
        channels = 2; % 声道数
    end

    properties (SetAccess = immutable) % 只能由constructor设置
        Element
        Graphic
    end

    methods

        function obj = App()
            HideCursor;
            rng('shuffle'); % 改变随机种子
            Screen('Preference', 'SkipSyncTests', 1);
            obj.Element = PTB.Element(obj);
            obj.Graphic = PTB.Graphic(obj);
        end

        % base
        function debug(obj)
            dbstop if error;
            ShowCursor;
            obj.winSize = [0, 0, 640, 360];
            % 检查按键
            keyName = obj.kbCheck();

            if ~isempty(keyName)
                disp(keyName);
                warning('有按键未释放');
            end

        end

        function begin(obj)
            %% 听觉刺激
            InitializePsychSound();
            % PsychPortAudio('GetDevices'); % 获取所有音频设备信息
            % PsychPortAudio('GetStatus', obj.portAudio); % 获取当前音频设备信息
            % 自动选择合适的采样率
            sampleRates = flip(unique([PsychPortAudio('GetDevices').DefaultSampleRate]));

            for sr = sampleRates

                try
                    obj.portAudio = PsychPortAudio('Open', [], 1, 1, sr, obj.channels); % 打开音频设备：设备id；模式：播放/录制；音频滞后
                    obj.sampleRate = sr;
                    fprintf('当前音频设备采样率为%d\n', sr);
                    break;
                catch

                    if sr == sampleRates(end)
                        error('音频设备启动失败\n不支持以下采样率\n%s', num2str(sampleRates));
                    end

                end

            end

            %% 视觉刺激
            Screen('Preference', 'DefaultFontSize', obj.textSize);
            Screen('Preference', 'DefaultFontStyle', obj.textStyle);
            Screen('Preference', 'DefaultFontName', obj.textFont);
            [obj.win, obj.winRect] = Screen('OpenWindow', 0, obj.backgroundColor, obj.winSize);
        end

        function finish(obj)
            ShowCursor;
            Screen('Close', obj.win);
            % Screen('CloseAll');
            PsychPortAudio('Close', obj.portAudio);
        end

        function exit(obj)
            fclose('all');
            obj.finish();
            error('强制退出');
        end

        % other
        function keyName = kbCheck(~)
            keyName = [];
            [keyIsDown, ~, keyCode] = KbCheck;

            if keyIsDown
                keyName = KbName(keyCode);
            end

            if iscell(keyName)
                keyName(cellfun('isempty', keyName)) = []; % 按alt键时 cell数组去除[]
            end

        end

    end

end
