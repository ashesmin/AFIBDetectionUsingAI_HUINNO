function [] = fMoveAfibData(src_dir, dst_dir, filename)
    src_file = strcat(src_dir, filename);

    save_dir = strcat(dst_dir,'afib\');
    dst_file = strcat(save_dir, filename);
    
    movefile(src_file, dst_file);
end

