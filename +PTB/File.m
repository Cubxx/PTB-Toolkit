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

        function writeKeyValuePair(obj, keys, values)

            if ~iscell(keys) || ~iscell(values)
                error('请输入cell数组')
            end

            if width(keys) ~= width(values)
                error('keys和values的长度应相等');
            end

            fid = obj.id;

            if obj.isWriteKeys
                obj.isWriteKeys = false;
                fprintf(fid, '%s\n', strjoin(keys, ','));
            end

            spec = repmat(',%s', 1, width(keys));
            values = cellfun(@num2str, values, 'UniformOutput', false);
            fprintf(fid, [spec(2:end), '\n'], values{:});
        end

        function writeMap(obj, Map)

            if ~isa(Map, 'containers.Map')
                error('请输入Map数据');
            end

            obj.writeKeyValuePair(Map.keys, Map.values);
        end

        function writeTable(obj, Table)

            if ~istable(Table)
                error('请输入table数据');
            end

            if height(Table) ~= 1
                error('只支持写入单行table数据');
            end

            obj.writeKeyValuePair(Table.Properties.VariableNames, table2cell(Table(1, :)));
        end

    end

end
