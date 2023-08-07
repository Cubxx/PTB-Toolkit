classdef File < handle

    properties
        id % 文件句柄
        path % 文件路径
        isWriteKeys % 是否写入列名
    end

    methods

        function obj = File(path, mode, varargin)

            if ~exist('path', 'var') || isempty(path)
                path = 'untitled.csv';
            end

            if ~exist('mode', 'var') || isempty(mode)
                mode = 'w';
            end

            obj.id = fopen(path, mode, varargin{:});
            obj.path = path;
            obj.isWriteKeys = true;

            if obj.id == -1
                error('文件打开失败')
            end

        end

        function close(obj)
            fclose(obj.id);
        end

        function write(obj, varargin)
            fid = obj.id;
            fprintf(fid, varargin{:});
        end

        function wirteMap(obj, Map)
            fid = obj.id;
            values = cellfun(@num2str, Map.values, 'UniformOutput', false);

            if obj.isWriteKeys
                obj.isWriteKeys = false;
                fprintf(fid, '%s\n', strjoin(Map.keys, ','));
            end

            spec = repmat(',%s', 1, Map.Count);
            fprintf(fid, [spec(2:end), '\n'], values{:});
        end

    end

end
