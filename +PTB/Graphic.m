classdef Graphic

    properties (SetAccess = immutable)
        app
    end

    methods

        function obj = Graphic(app)
            obj.app = app;
        end

        function position = getTextCenter(obj, content, size)
            win = obj.app.win;
            [w, h] = Screen('WindowSize', win);
            textRect = obj.getTextRect(content, size);
            position = [w - textRect(3), h - textRect(4)] / 2;
        end

        function rect = getTextRect(obj, content, size)
            win = obj.app.win;
            Screen('TextSize', win, size);
            rect = Screen('TextBounds', win, double(content));
        end

        function res = isPointInRect(~, position, area)
            % area: [left top right bottom]
            res = position(1) >= area(1) && position(1) <= area(3) && position(2) >= area(2) && position(2) <= area(4);
        end

        function res = isPointInCircle(~, position, area)
            % area: [center_x center_y radius]
            res = (position(1) - area(1)) ^ 2 + (position(2) - area(2)) ^ 2 <= area(3) ^ 2;
        end

    end

end
