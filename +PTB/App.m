classdef App < handle

    properties
        win
        winRect
        winSize = [];
        backgroundColor = [0 0 0];
        textColor = [255 255 255];
        textSize = 30;
        textStyle = 0; % 0=normal,1=bold,2=italic,4=underline,8=outline,32=condense,64=extend
        textFont = 'Microsoft YaHei UI'; % SimSun宋体,KaiTi楷体,Microsoft JhengHei黑体
        screenZoom = 1; % 系统屏幕缩放
        screenSize = [34.4, 19.5]; % 屏幕尺寸, 单位cm
        distance = 57; % 眼睛到屏幕的距离, 单位cm
    end

    properties (SetAccess = immutable) % 只能由constructor设置
        Element
        Graphic
        Math
    end

    methods

        function obj = App()
            HideCursor;
            rng('shuffle'); % 改变随机种子
            Screen('Preference', 'SkipSyncTests', 1);
            obj.Element = PTB.Element(obj);
            obj.Graphic = PTB.Graphic(obj);
            obj.Math = PTB.Math(obj);
        end

        % base
        function debug(obj)
            % dbstop if error;
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
            ScreenNum = max(Screen('Screens'));
            [obj.win, obj.winRect] = Screen('OpenWindow', ScreenNum, obj.backgroundColor, obj.winSize);

            Screen('TextSize', obj.win, obj.textSize);
            Screen('TextStyle', obj.win, obj.textStyle);
            Screen('TextFont', obj.win, obj.textFont);
        end

        function finish(obj)
            ShowCursor;
            Screen('Close', obj.win);
            % Screen('CloseAll');
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
