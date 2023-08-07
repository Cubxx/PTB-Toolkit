classdef File < handle

    properties
        id % 文件句柄
        path % 文件路径
        isWriteKeys % 是否写入列名
    end

    methods

        function obj = File(path, mode, varargin)

            if nargin < 1
                path = 'untitled.csv';
            end

            if nargin < 2
                mode = 'w';
            end

            obj.isWriteKeys = true;
            obj.path = path;
            obj.id = fopen(path, mode, varargin{:});

            if obj.id == -1
                error('文件打开失败')
            end

        end

        function close(obj)
            fclose(obj.id);
        end

        function write(obj, varargin)
            fid = obj.id;
            n = length(varargin);
            ks = cell(1, n); % key
            ss = cell(1, n); % spec
            vs = cell(1, n); % value

            for i = 1:n
                [ks{i}, ss{i}, vs{i}] = varargin{:, i}{:};
            end

            if obj.isWriteKeys
                obj.isWriteKeys = false;
                fprintf(fid, '%s\n', strjoin(ks, ','));
            end

            fprintf(fid, [strjoin(ss, ','), '\n'], vs{:});
        end

    end

end
