array_map (Void_Type, &set_struct_field, COLOR, get_struct_field_names (COLOR),
    array_map (Integer_Type, &srv->get_color, get_struct_field_names (COLOR)));

