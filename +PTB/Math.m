classdef Math

    methods (Static)

        function [output_arr, output_arr_length] = combine(varargin)

            if ~all(cellfun(@isvector, varargin))
                error('输入参数必须为向量');
            end

            input_arrs = varargin;
            input_arrs_num = length(varargin);
            input_arrs_lengths = zeros(1, input_arrs_num);

            for i = 1:input_arrs_num
                input_arrs_lengths(i) = numel(input_arrs{i});
            end

            output_arr_length = prod(input_arrs_lengths);
            output_arr = cell(output_arr_length, input_arrs_num);

            % 组合
            indices = ones(1, input_arrs_num); % 某一种组合对应input_arrs元素的index

            for i = 1:output_arr_length

                for j = 1:input_arrs_num
                    output_arr{i, j} = input_arrs{j}(indices(j));
                end

                % 计算下一组合，input_arrs元素的index
                for j = input_arrs_num:-1:1
                    indices(j) = indices(j) + 1;

                    if indices(j) > input_arrs_lengths(j)
                        indices(j) = 1;
                    else
                        break;
                    end

                end

            end

        end

        function res = randsample(arr, num)

            if ~isvector(arr)
                error('输入参数必须为向量');
            end

            if num > length(arr)
                error('采样量过大');
            end

            rand_arr = Shuffle(arr);
            res = rand_arr(1:num);
        end

    end

end
