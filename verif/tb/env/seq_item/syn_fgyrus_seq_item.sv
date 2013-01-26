`ifndef __SYN_FGYRUS_SEQ_ITEM
`define __SYN_FGYRUS_SEQ_ITEM

  `include  "syn_fgyrus_fft_seq_item.sv"


  class syn_fgyrus_pcm_seq_item extends ovm_sequence_item;

    //fields
    rand  int       pcm_data[];

    //registering with factory
    `ovm_object_utils_begin(syn_fgyrus_pcm_seq_item)
      `ovm_field_array_int(pcm_data,  OVM_ALL_ON | OVM_DEC);
    `ovm_object_utils_end

    function new(string name = "syn_fgyrus_pcm_seq_item");
      super.new(name);
    endfunction : new


    /*  Constraint  Block */
    //constraint  c_size_lim      { pcm_data.size inside  {[1:128]};}
    constraint  c_size_lim      { pcm_data.size ==  128;}

    function  string  get_wave();
      string  res="";
      longint thresh  = 1<<28;

      for(int i=0; i<8; i++,  thresh=thresh>>4, res={res,"\n"})  //above x-axis
      begin
        for(int j=0; j<this.pcm_data.size; j++)
        begin
          //$printf("%d",this.pcm_data[j]);

          if(this.pcm_data[j] > thresh)
          begin
            res = {res,"|"};
          end
          else
          begin
            res = {res," "};
          end
        end
      end

      for(int i=0; i<pcm_data.size; i++)
      begin
        res = {res,"-"};
      end

      res = {res,"\n"};

      thresh  = 1;

      for(int i=0; i<8; i++,  thresh=thresh<<4, res={res,"\n"})  //below x-axis
      begin
        for(int j=0; j<this.pcm_data.size; j++)
        begin
          //$printf("%d",this.pcm_data[j]);

          if(this.pcm_data[j]  < 0)
          begin
            if(this.pcm_data[j] > (-1*thresh))
            begin
              res = {res," "};
            end
            else
            begin
              res = {res,"|"};
            end
          end
          else
          begin
            res = {res," "};
          end
        end
      end


      return  res;

    endfunction : get_wave

  endclass  : syn_fgyrus_pcm_seq_item


  class syn_fgyrus_fft_ram_seq_item extends ovm_sequence_item;

    //fields
    rand  syn_complex_seq_item  fft_data[];

    //registering with factory
    `ovm_object_utils_begin(syn_fgyrus_fft_ram_seq_item)
      `ovm_field_array_object(fft_data,  OVM_ALL_ON  | OVM_DEC);
    `ovm_object_utils_end

    function new(string name = "syn_fgyrus_fft_ram_seq_item");
      super.new(name);

      fft_data  = new[128];

      foreach(fft_data[i])
      begin
        fft_data[i] = new();
      end
    endfunction : new

    constraint  c_size_lim      { fft_data.size ==  128;}

    function int compare_fft(input syn_fgyrus_fft_ram_seq_item item, real dev);
      int item_real_max, item_im_max, item_real_min, item_im_min;

      //  $display({"this.pkt - \n",this.sprint(),"\n\n"});
      //  $display({"item.pkt - \n",item.sprint(),"\n\n"});

      foreach(this.fft_data[i])
      begin
        if((item.fft_data[i].data_real < 128) &&  (item.fft_data[i].data_im < 128)  &&  (item.fft_data[i].data_real > -128) &&  (item.fft_data[i].data_im > -128))
        begin
          continue;
        end

        if(item.fft_data[i].data_real < 0)
        begin
          $cast(item_real_max,  item.fft_data[i].data_real  - (item.fft_data[i].data_real * dev));
          $cast(item_real_min,  item.fft_data[i].data_real  + (item.fft_data[i].data_real * dev));
        end
        else
        begin
          $cast(item_real_max,  item.fft_data[i].data_real  + (item.fft_data[i].data_real * dev));
          $cast(item_real_min,  item.fft_data[i].data_real  - (item.fft_data[i].data_real * dev));
        end

        if(item.fft_data[i].data_im < 0)
        begin
          $cast(item_im_max,    item.fft_data[i].data_im    - (item.fft_data[i].data_im   * dev));
          $cast(item_im_min,    item.fft_data[i].data_im    + (item.fft_data[i].data_im   * dev));
        end
        else
        begin
          $cast(item_im_max,    item.fft_data[i].data_im    + (item.fft_data[i].data_im   * dev));
          $cast(item_im_min,    item.fft_data[i].data_im    - (item.fft_data[i].data_im   * dev));
        end


        if((item.fft_data[i].data_real > 16) ||  (item.fft_data[i].data_real < -16))
        begin
          if(!((this.fft_data[i].data_real >=  item_real_min - 1)  &&  (this.fft_data[i].data_real  <=  item_real_max + 1)))
          begin
            $display($psprintf("i : %d\tthis.data_real : %d\titem.data_real_min : %d\t item.data_real_max : %d",i,this.fft_data[i].data_real,item_real_min,item_real_max));
            return  0;
          end
        end

        if((item.fft_data[i].data_im > 16) ||  (item.fft_data[i].data_im < -16))
        begin
          if(!((this.fft_data[i].data_im >=  item_im_min - 1)  &&  (this.fft_data[i].data_im  <=  item_im_max + 1)))
          begin
            $display($psprintf("i : %d\tthis.data_im : %d\titem.data_im_min : %d\t item.data_im_max : %d",i,this.fft_data[i].data_im,item_im_min,item_im_max));
            return  0;
          end
        end
      end

      return  1;
    endfunction : compare_fft

  endclass  : syn_fgyrus_fft_ram_seq_item


`endif
