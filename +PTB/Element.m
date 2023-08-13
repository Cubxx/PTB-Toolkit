classdef Element

    properties (SetAccess = immutable)
        app
    end

    methods

        function obj = Element(app)
            obj.app = app;
        end

        function text(obj, content, size, offset, color, varargin)

            if ~exist('size', "var") || isempty(size)
                size = obj.app.textSize;
            end

            if ~exist('offset', "var") || isempty(offset)
                offset = [0, 0];
            end

            if ~exist('color', "var") || isempty(color)
                color = obj.app.textColor;
            end

            position = offset + obj.app.Graphic.getTextCenter(content, size);
            win = obj.app.win;
            Screen('TextSize', win, size);
            Screen('DrawText', win, double(content), position(1), position(2), color, varargin{:});
        end

        function multiText(obj, content, line_height, size, offset, varargin)

            if ~exist('line_height', "var") || isempty(line_height)
                line_height = 30;
            end

            if ~exist('size', "var") || isempty(size)
                size = obj.app.textSize;
            end

            if ~exist('offset', "var") || isempty(offset)
                offset = [0, 0];
            end

            rows = split(content, '\n');
            n = length(rows);
            y_offset_arr = calc(n);
            textRect = obj.app.Graphic.getTextRect(content, size);

            for i = 1:n
                obj.text(rows{i}, size, offset + [0, y_offset_arr(i) * (textRect(4) + line_height)], varargin{:});
            end

            function arr = calc(n)
                arr = zeros(1, n);

                arr(1) = (n - 1) / 2;
                arr(end) = -arr(1);

                if mod(n, 2) == 0
                    arr(n / 2) = 0.5;
                    arr(n / 2 + 1) = -arr(n / 2);
                else
                    arr((n + 1) / 2) = 0;
                end

                for o = 2:(n - 1) / 2
                    arr(o) = (arr(1) + arr((n + 1) / 2)) / 2;
                    arr(n - o + 1) = -arr(o);
                end

                arr = -arr;
            end

        end

        function pic_rect = pic(obj, filepath, degree, angle, offset, varargin)

            if ~exist('offset', "var") || isempty(offset)
                offset = [0, 0];
            end

            if ~exist('angle', "var") || isempty(angle)
                angle = 0;
            end

            if ~exist('degree', "var") || isempty(degree) % 宽度
                degree = 5;
            end

            win = obj.app.win;
            orig_pic_arr = imread(filepath);
            [pic_arr, pic_hw_pix] = resize(orig_pic_arr, degree); % 控制大小
            pic_rect = centerRect(offset); % 控制位置
            texture = Screen('MakeTexture', win, pic_arr);
            Screen('DrawTexture', win, texture, [], pic_rect, angle, varargin{:});

            function pic_rect = centerRect(offset)
                [center_x, center_y] = RectCenter(obj.app.winRect); % win中心点
                anchor_point = num2cell([center_x, center_y] + offset); % 图片锚点位置
                pic_rect = CenterRectOnPoint([0, 0, pic_hw_pix([2, 1])], anchor_point{:});
            end

            function [pic_arr, pic_hw_pix] = resize(orig_pic_arr, degree)
                orig_pic_hw_pix = size(orig_pic_arr); % 图片原始尺寸
                hw_ratio = orig_pic_hw_pix(1) / orig_pic_hw_pix(2); % 图片高宽比
                pic_hw_pix = deg2pix(degree .* [hw_ratio, 1]);
                pic_arr = imresize(orig_pic_arr, pic_hw_pix, 'bicubic'); % 改变orig_pic_arr大小
            end

            function pic_pix = deg2pix(pic_deg)
                pic_cm = 2 * obj.app.distance * tand(pic_deg ./ 2);
                screen_cm = obj.app.screenSize;
                screen_pix = get(0, 'ScreenSize') .* obj.app.screenZoom;
                pic_pix = round(pic_cm ./ screen_cm .* screen_pix(3:4));
            end

        end

        function fixation(obj, duration, varargin)
            obj.text('+', varargin{:});
            obj.render(duration);
        end

        function blank(obj, duration)
            Screen('FillRect', obj.app.win, obj.app.backgroundColor);
            obj.render(duration);
        end

        function realDuration = beep(obj, duration, volume, freq)

            if ~exist('duration', "var") || isempty(duration)
                duration = 1;
            end

            if ~exist('volume', "var") || isempty(volume)
                volume = 0.5;
            end

            if ~exist('freq', "var") || isempty(freq)
                freq = 440;
            end

            handle = obj.app.portAudio;
            PsychPortAudio('Volume', handle, volume);
            beepArr = MakeBeep(freq, duration, obj.app.sampleRate);
            PsychPortAudio('FillBuffer', handle, repmat(beepArr, obj.app.channels, 1));
            PsychPortAudio('Start', handle, 1, 1, 1); % 重复次数
            [realStartTime, ~, ~, realStopTime] = PsychPortAudio('Stop', handle, 1); % 1等音频放完，2强制停止
            realDuration = realStopTime - realStartTime;
        end

        % display
        function render(obj, varargin)
            Screen('Flip', obj.app.win);
            obj.listen(varargin{:});
        end

        function listen(obj, duration, type, callback)

            if ~exist('type', "var") || isempty(type)
                type = 'keydown';
            end

            if ~exist('callback', "var") || isempty(callback)

                if duration == inf
                    callback = @(~, keyName)strcmp(keyName, obj.app.continueKey); % 单次监听
                else
                    callback = @(varargin)false; % 持续监听
                end

            end

            win = obj.app.win;
            frameTime = 1 / Screen('FrameRate', win);
            startTime = GetSecs;

            while 1

                if GetSecs - startTime >= duration - frameTime / 2 % 超时退出 减半帧
                    callback(NaN, []);
                    break;
                end

                if isequal('esc', obj.app.kbCheck()) % esc 强制退出
                    obj.app.exit();
                end

                switch type
                    case 'keydown'
                        [keyIsDown, ~, keyCode] = KbCheck;
                        keyName = KbName(keyCode);

                        if ~keyIsDown
                            continue;
                        end

                        if isempty(keyName)
                            continue;
                        elseif iscell(keyName) % alt键返回cell数组
                            % keyName(cellfun(@isempty, keyName)) = []; % cell数组去[]
                            keyName = keyName{:}; % 只保留第一个元素
                        end

                        if callback(GetSecs - startTime, keyName)
                            break;
                        end

                    case 'mousedown'
                        [x, y, buttons] = GetMouse(win);

                        if any(buttons) && callback(GetSecs - startTime, buttons, [x, y])
                            break;
                        end

                    otherwise
                        error(['事件类型错误 ', type]);
                end

            end

        end

    end

end
