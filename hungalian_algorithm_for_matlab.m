clear;
%mat = [5, 4, 7, 6 ; 6, 7, 3, 2 ; 8, 11, 2, 5 ; 9, 8, 6, 7];
mat = magic(10)
optimal = compute(mat);
disp(optimal)
% mat = step1(mat)
% [flag, zero_coordinate] = step2(mat);
% line = step3(zero_coordinate);
%mat = step4(mat, line)

%output_mat = zeros(size(mat));

function mat = step1(mat)
    mat = mat - min(mat, [], 2);
    mat = mat - min(mat, [], 1);
end

function [flag, zero_coordinate] = step2(mat)
    zero_coordinate = [];
    for num_row_mat = 1:size(mat,1)
        row = mat(num_row_mat,:);
        for num_col_mat = 1:size(row,2)
           v = row(1, num_col_mat);
           if v == 0
              zero_coordinate = cat(1, zero_coordinate, [num_row_mat,num_col_mat]); 
           end
        end
    end
    check_row = [];
    check_col = [];
    for num_zero2 =  1:size(zero_coordinate,1)
        elem = zero_coordinate(num_zero2,:);
        if ~ismember(elem(1), check_row) && ~ismember(elem(2), check_col)
            check_row = cat(2,check_row,elem(1,1));
            check_col = cat(2,check_col,elem(1,2));
        end
    end
    if size(check_row,2) ~= size(mat,2)
        flag = 0;
    else
        flag = 1;
    end
    
end

function line = step3(zero_coordinate)
    zero_list = zero_coordinate;
    rc_container = [];
    zero_count = [];
    line = [];
    while size(zero_list,1) > 0
        for num_zero3 = 1:size(zero_list,1)
            zero = zero_list(num_zero3,:);
            r = "r_" + string(zero(1,1));
            c = "c_" + string(zero(1,2));
            if isempty(rc_container)
                rc_container = [rc_container r];
                rc_container = [rc_container c];
                zero_count = [zero_count 1 1];
            else
                if ~ismember(rc_container, r)
                    rc_container = [rc_container r];
                    zero_count = [zero_count 1];
                else
                    add = ismember(rc_container, r);
                    zero_count = zero_count + add;
                end
                if ~ismember(rc_container, c)
                    rc_container = [rc_container c];
                    zero_count = [zero_count 1];
                else
                    add = ismember(rc_container, c);
                    zero_count = zero_count + add;
                end
            end
            
        end
        [~, idx] = max(zero_count);
        max_zero_rc = rc_container(idx);
        line = cat(1, line, max_zero_rc);
        split_rc_container = strsplit(max_zero_rc,"_");
        rc = split_rc_container(1);
        num = double(split_rc_container(2));
        v1_1 = [];
        v1_2 = [];
        new_zero_list = [];
        if rc == "r"
            for num_v1_1 = 1:size(zero_list,1)
                v1_1 = zero_list(num_v1_1,:);
                if v1_1(1) ~= num
                    new_zero_list = cat(1, new_zero_list, v1_1);
                end
            end
        else
            for num_v1_2 = 1:size(zero_list,1)
                v1_2 = zero_list(num_v1_2,:);
                if v1_2(2) ~= num
                    new_zero_list = cat(1, new_zero_list, v1_2);
                end
            end
        end
        zero_list = new_zero_list;
        rc_container = [];
        zero_count = [];
    end
end

function mat = step4(mat, line)
    output_mat = zeros(size(mat));
    line_r = [];
    line_c = [];
    for L_num = 1:height(line)
        L = line(L_num);
        split_line = strsplit(L,"_");
        rc = split_line(1);
        num = str2double(split_line(2));
        if rc == "r"
            line_r = [line_r num];
        else
            line_c = [line_c num];
        end
    end
    line_cut_mat = mat;
    line_cut_mat(line_r,:) = [];
    line_cut_mat(:,line_c) = [];
    mini = min(line_cut_mat(:));
    cross_line_point = [];
    for num_line_r = 1:length(line_r)
        cp_x = line_r(num_line_r);
        for num_line_c = 1:length(line_c)
            cp_y = line_c(num_line_c);
            cp = [cp_x, cp_y];
            cross_line_point = cat(1, cross_line_point, cp);
        end
    end
    non_line_point = [];
    for num_r = 1:size(mat,1)
        for num_c = 1:size(mat,2)
            if ~ismember(num_r, line_r) && ~ismember(num_c, line_c)
                non_line_point = cat(1, non_line_point, [num_r, num_c]);
            end
        end
    end
    for co_num = 1:height(cross_line_point)
        co = cross_line_point(co_num, :);
        mat(co(1), co(2)) = mat(co(1), co(2)) + mini;
    end
    for nlo_num = 1:height(non_line_point)
        nlo = non_line_point(nlo_num, :);
        mat(nlo(1), nlo(2)) = mat(nlo(1), nlo(2)) - mini;
    end
end

function optimal = compute(mat)
    mat = step1(mat);
    mat = step1(mat.');
    while 1
        [flag, zero_coordinate] = step2(mat);
        if flag == 1
            break
        end
        line = step3(zero_coordinate);
        mat = step4(mat, line);
    end
    r = [];
    c = [];
    optimal = [];
    for num_optimal_zero = 1:height(zero_coordinate)
        optimal_zero = zero_coordinate(num_optimal_zero, :);
        if ~ismember(optimal_zero(1), r) && ~ismember(optimal_zero(2), c)
            optimal = cat(1, optimal, optimal_zero);
            r = [r optimal_zero(1)];
            c = [c optimal_zero(2)];
        end
    end
end


%田中先生が書いてくださったやつ
% function [flag, zero_coordinate] = step2(mat)
%     flag = true(1, size(mat, 2));
%     for i = 1:size(mat, 1)
%         [val, idx] = min(mat(i, :));
%         fprintf('%d %d %d\n', i, val, idx);
%         flag(idx) = false;
%         if val > 0
%             disp('failed');
%         end
%         mat(:, idx) = inf;
%     end
% end
% function [flag, zero_coordinate] = step2(mat)
%     zero_coordinate = [];
%     for i = 1:size(mat, 1);
%         row = output_mat(i, :);
%        for j = 1:size(row, 2);
%             v = row(1, j);
%             if v == 0;
%                 zero_coordinate = cat(zero_coordinate, [i, j]);
%             end
%        end
%        check_row = [];
%        check_column = [];
%     end
% end
