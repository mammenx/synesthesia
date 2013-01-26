`ifndef __SYN_REG_MAP
`define __SYN_REG_MAP

  class syn_reg_map #(int REG_W = 16) extends ovm_component;

    /*  Register with factory */
    `ovm_component_param_utils(syn_reg_map#(REG_W));

    /*  Associative array holding the register bits */
    bit [REG_W-1:0] reg_arry[*];

    /*  Associative array to map between field name & register location */
    int string2addr_arry[string]; //returns idx to reg_arry
    int bit_start_arry[string];   //returns starting idx of field
    int bit_end_arry[string];     //returns end idx of field

    /*  Return  Codes */
    static int SUCCESS             = 0;
    static int FAIL_FIELD_N_EXIST  = -1; //field does not exist
    static int FAIL_REG_N_EXIST    = -2; //register does not exist
    static int FAIL_OUT_OF_BOUNDS  = -3; //index out of bounds?

    /*  Constructor */
    function  new(string name = "syn_reg_map",  ovm_component parent);
      super.new(name, parent);
    endfunction : new


    function void create_field(string name, int addr, int b_start, int b_end);
      if(!reg_arry.exists(addr))  reg_arry[addr]  = 'd0;

      string2addr_arry[name]  = addr;
      bit_start_arry[name]    = b_start;
      bit_end_arry[name]      = b_end;

    endfunction : create_field


    function  int set_field(string name, int val);
       bit[REG_W-1:0]  temp = 0;
       bit[REG_W-1:0]  val_b = 0;

      if(string2addr_arry.exists(name)  &&  bit_start_arry.exists(name) &&  bit_end_arry.exists(name))
      begin
        val_b = val <<  bit_start_arry[name];

        if(reg_arry.exists(string2addr_arry[name]))
        begin
          temp  = reg_arry[string2addr_arry[name]];
        end
        else
        begin
          return  FAIL_REG_N_EXIST;
        end

        for(int i=bit_start_arry[name]; i<=bit_end_arry[name]; i++)
        begin
          temp[i] = val_b[i];
        end

        reg_arry[string2addr_arry[name]]  = temp; //update register

        //ovm_report_info({get_name(),"[set_field]"},$psprintf("Field - %s [start : 0x%x, end : 0x%x] set to 0x%x",name,bit_start_arry[name],bit_end_arry[name],reg_arry[string2addr_arry[name]]),OVM_LOW);

        return  SUCCESS;
      end
      else
      begin
        return  FAIL_FIELD_N_EXIST;
      end
    endfunction : set_field


    function  int get_addr(string name);

      if(string2addr_arry.exists(name))
      begin
        return  string2addr_arry[name];
      end
      else
      begin
        return  FAIL_FIELD_N_EXIST;
      end

    endfunction : get_addr


    function  int get_field(string name);
      bit[REG_W-1:0]  temp = 0;
      int val  = 0;

      if(string2addr_arry.exists(name)  &&  bit_start_arry.exists(name) &&  bit_end_arry.exists(name))
      begin
        if(reg_arry.exists(string2addr_arry[name]))
        begin
          temp  = reg_arry[string2addr_arry[name]];
        end
        else
        begin
          return  FAIL_REG_N_EXIST;
        end

        //for(int i=bit_start_arry[name]; i<=bit_end_arry[name]; i++)
        for(int i=bit_end_arry[name]; i>=bit_start_arry[name]; i--)
        begin
          val = (val <<  1) | temp[i];  //extract field
        end

        //  $cast(val, temp[bit_end_arry[name]:bit_start_arry[name]]);

        //ovm_report_info({get_name(),"[get_field]"},$psprintf("Field - %s [start : 0x%x, end : 0x%x] is 0x%x, temp = 0x%x",name,bit_start_arry[name],bit_end_arry[name],val,temp),OVM_LOW);

        return  val;
      end
      else
      begin
        return  FAIL_FIELD_N_EXIST;
      end
    endfunction : get_field

    function  int set_reg(int addr, int data);
      if(!reg_arry.exists(addr))
      begin
        return  FAIL_REG_N_EXIST;
      end
      else
      begin
        reg_arry[addr]  = data;
        return  SUCCESS;
      end
    endfunction : set_reg

    function  int get_reg(string  name);

      if(string2addr_arry.exists(name)  &&  reg_arry.exists(string2addr_arry[name]))
      begin
        return  reg_arry[string2addr_arry[name]];
      end
      else
      begin
        return  FAIL_FIELD_N_EXIST;
      end

    endfunction : get_reg

    function  int chk_addr_exist(int addr);
      if(reg_arry.exists(addr))
        return  SUCCESS;
      else
        return  FAIL_REG_N_EXIST;
    endfunction : chk_addr_exist

  endclass  : syn_reg_map

`endif
