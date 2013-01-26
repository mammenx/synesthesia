`ifndef __SYN_WAV_SEQ_ITEM
`define __SYN_WAV_SEQ_ITEM

  import  math_pkg::*;
  import  fileio_pkg::*;

  //`define VCS 1

  class syn_wav_seq_item extends ovm_sequence_item;

    /*  Have a look at the link [https://ccrma.stanford.edu/courses/422/projects/WaveFormat/] */

    //fields
    rand  int       no_samples;

          int       unsigned  chunkID   = 'h52494646; //"RIFF" pattern [big endian]
    rand  int       unsigned  chunkSize;
          int       unsigned  chunkFmt  = 'h57415645; //"WAVE" pattern [big endian]

          int       unsigned  subchunk1ID   = 'h666d7420; //"fmt " pattern [big endian]
          int       unsigned  subchunk1Size = 16; //PCM has 16!
          shortint  unsigned  subchunk1AudFmt = 1;  //1->PCM
    rand  shortint  unsigned  subchunk1NoChnls;
    rand  int       unsigned  subchunk1SampleRate;
    rand  int       unsigned  subchunk1ByteRate;
    rand  shortint  unsigned  subchunk1BlockAlign;
    rand  shortint  unsigned  subchunk1BitsPerSample;

          int       unsigned  subchunk2ID = 'h64617461; //"data" pattern [big endian]
    rand  int       unsigned  subchunk2Size;
    rand  int                 data[]; //PCM data; even locs are left channel, odd are right channel


    //registering with factory
    `ovm_object_utils_begin(syn_wav_seq_item)
      `ovm_field_int(no_samples,  OVM_ALL_ON | OVM_UNSIGNED);

      `ovm_field_int(chunkID,  OVM_ALL_ON | OVM_STRING);
      `ovm_field_int(chunkSize,  OVM_ALL_ON | OVM_UNSIGNED);
      `ovm_field_int(chunkFmt,  OVM_ALL_ON | OVM_STRING);

      `ovm_field_int(subchunk1ID, OVM_ALL_ON  | OVM_STRING);
      `ovm_field_int(subchunk1Size, OVM_ALL_ON  | OVM_UNSIGNED);
      `ovm_field_int(subchunk1AudFmt, OVM_ALL_ON  | OVM_UNSIGNED);
      `ovm_field_int(subchunk1NoChnls,  OVM_ALL_ON  | OVM_UNSIGNED);
      `ovm_field_int(subchunk1SampleRate, OVM_ALL_ON  | OVM_UNSIGNED);
      `ovm_field_int(subchunk1ByteRate, OVM_ALL_ON  | OVM_UNSIGNED);
      `ovm_field_int(subchunk1BlockAlign, OVM_ALL_ON  | OVM_UNSIGNED);
      `ovm_field_int(subchunk1BitsPerSample,  OVM_ALL_ON  | OVM_UNSIGNED);

      `ovm_field_int(subchunk2ID, OVM_ALL_ON  | OVM_STRING);
      `ovm_field_int(subchunk2Size, OVM_ALL_ON  | OVM_UNSIGNED);
      `ovm_field_array_int(data,  OVM_ALL_ON | OVM_HEX);

    `ovm_object_utils_end

    function new(string name = "syn_wav_seq_item");
      super.new(name);
    endfunction : new


    /*  Function to byte swap field */
    function  int unsigned  byte_swap_32(input int unsigned data);
      int unsigned res = 0;

      res +=  (data & 'hff)       <<  24;
      res +=  (data & 'hff00)     <<  8;
      res +=  (data & 'hff0000)   >>  8;
      res +=  (data & 'hff000000) >>  24;

      return res;

    endfunction : byte_swap_32

    function  shortint unsigned byte_swap_16(input shortint unsigned  data);
      shortint unsigned  res = 0;

      res +=  (data & 'hff)       <<  8;
      res +=  (data & 'hff00)     >>  8;

      return res;

    endfunction : byte_swap_16



    /*  Function to parse .wav file & build object */
    function void parse_wav(input string filename, int no_of_samples);
      //OVM_FILE  f;
      integer f;
      int bytes_read;
      int unsigned bffr_32b;
      shortint unsigned bffr_16b;

      f = $fopen(filename, "r");

      if(!f)
      begin
        ovm_report_fatal({get_name(),"[parse_wav]"},$psprintf("Could not open <%s>",filename),OVM_LOW);
        global_stop_request();
      end
      else
      begin
        ovm_report_info({get_name(),"[parse_wav]"},$psprintf("Success in opening file <%s>",filename),OVM_LOW);
      end

      /*
      * Parsing as per WAV format
      * little endian fields need to be byte swapped ...
      */

      fread_32(f, chunkID, bytes_read);

      fread_32(f, chunkSize, bytes_read);
      chunkSize   =   byte_swap_32(chunkSize);

      fread_32(f, chunkFmt, bytes_read);

      fread_32(f, subchunk1ID, bytes_read);

      fread_32(f, subchunk1Size, bytes_read);
      subchunk1Size = byte_swap_32(subchunk1Size);

      fread_16(f, subchunk1AudFmt, bytes_read);
      `ifndef VCS 
      subchunk1AudFmt = byte_swap_16(subchunk1AudFmt);
      `endif

      fread_16(f, subchunk1NoChnls, bytes_read);
      `ifndef VCS
      subchunk1NoChnls  = byte_swap_16(subchunk1NoChnls);
      `endif
      
      fread_32(f, subchunk1SampleRate, bytes_read);
      subchunk1SampleRate = byte_swap_32(subchunk1SampleRate);

      fread_32(f, subchunk1ByteRate, bytes_read);
      subchunk1ByteRate = byte_swap_32(subchunk1ByteRate);

      fread_16(f, subchunk1BlockAlign, bytes_read);
      `ifndef VCS 
      subchunk1BlockAlign = byte_swap_16(subchunk1BlockAlign);
      `endif

      fread_16(f, subchunk1BitsPerSample, bytes_read);
      `ifndef VCS 
      subchunk1BitsPerSample  = byte_swap_16(subchunk1BitsPerSample);
      `endif


      if(subchunk1Size > 'd16)
      begin
       for(int i=0; i<(subchunk1Size - 16); i++)
       begin
         bffr_32b = $fgetc(f); //read out dummy byte character
         bytes_read++;
       end
      end

      fread_32(f, subchunk2ID, bytes_read);

      fread_32(f, subchunk2Size, bytes_read);
      subchunk2Size = byte_swap_32(subchunk2Size);

      ovm_report_info({get_name(),"[parse_wav]"},$psprintf("Wave Header - %s",print_hdr()),OVM_LOW);


      /*  Check chunkSize */
      if(chunkSize  !=  (4 + (8 + subchunk1Size) + (8 + subchunk2Size)))
      begin
        ovm_report_warning({get_name(),"[parse_wav]"},$psprintf("Mismatch in chunkSize detected; expecting 0x%x", (4 + (8 + subchunk1Size) + (8 + subchunk2Size))),OVM_LOW);
      end

      //calculate how much samples are there in the file
      no_samples  = (subchunk2Size  * 8)  / (subchunk1BitsPerSample * subchunk1NoChnls);

      if(no_of_samples  < no_samples)
      begin
        no_samples  = no_of_samples;  //remodify based on user demands
        ovm_report_info({get_name(),"[parse_wav]"},$psprintf("subchunk2Size modified from 0x%x to 0x%x",subchunk2Size,((no_samples * subchunk1BitsPerSample  * subchunk1NoChnls) / 8)),OVM_LOW);
        subchunk2Size = (no_samples * subchunk1BitsPerSample  * subchunk1NoChnls) / 8;
      end

      this.data = new[no_samples  * subchunk1NoChnls];

      for(int i=0; i<no_samples; i++)
      begin
        if(subchunk1BitsPerSample ==  'd16)
        begin
          fread_16(f, bffr_16b, bytes_read);
          bffr_16b  = byte_swap_16(bffr_16b);
          $cast(this.data[i*2], bffr_16b);

          fread_16(f, bffr_16b, bytes_read);
          bffr_16b  = byte_swap_16(bffr_16b);
          $cast(this.data[(i*2)+1], bffr_16b);
        end
        else if(subchunk1BitsPerSample ==  'd32)
        begin
          fread_32(f, bffr_32b, bytes_read);
          $cast(this.data[i*2], bffr_32b);

          fread_32(f, bffr_32b, bytes_read);
          $cast(this.data[(i*2)+1], bffr_32b);
        end

        /*
        if((i>190) && (i<210))
        begin
          ovm_report_info({get_name(),"[parse_wav]"},$psprintf("Sample no %d = 0x%x",(i*2),this.data[i*2]),OVM_LOW);
          ovm_report_info({get_name(),"[parse_wav]"},$psprintf("Sample no %d = 0x%x",((i*2)+1),this.data[(i*2)+1]),OVM_LOW);
        end
        */

        if($feof(f))
        begin
          ovm_report_info({get_name(),"[parse_wav]"},$psprintf("EOF reached @%d bytes; %d samples read",bytes_read,i),OVM_LOW);
          break;
        end
      end

      $fclose(f);

      ovm_report_info({get_name(),"[parse_wav]"},$psprintf("End of parsing"),OVM_LOW);

    endfunction : parse_wav


    /*  Function to printf wav header */
    function string print_hdr();

      string res = "\n";

      res = {res,$psprintf("chunkID\t-\t%s\n",chunkID)};
      res = {res,$psprintf("chunkSize\t-\t0x%x\n",chunkSize)};
      res = {res,$psprintf("chunkFmt\t-\t%s\n",chunkFmt)};
      res = {res,$psprintf("subchunk1ID\t-\t%s\n",subchunk1ID)};
      res = {res,$psprintf("subchunk1Size\t-\t0x%x\n",subchunk1Size)};
      res = {res,$psprintf("subchunk1AudFmt\t-\t0x%x\n",subchunk1AudFmt)};
      res = {res,$psprintf("subchunk1NoChnls\t-\t0x%x\n",subchunk1NoChnls)};
      res = {res,$psprintf("subchunk1SampleRate\t-\t0x%x\n",subchunk1SampleRate)};
      res = {res,$psprintf("subchunk1ByteRate\t-\t0x%x\n",subchunk1ByteRate)};
      res = {res,$psprintf("subchunk1BlockAlign\t-\t0x%x\n",subchunk1BlockAlign)};
      res = {res,$psprintf("subchunk1BitsPerSample\t-\t0x%x\n",subchunk1BitsPerSample)};
      res = {res,$psprintf("subchunk2ID\t-\t%s\n",subchunk2ID)};
      res = {res,$psprintf("subchunk2Size\t-\t0x%x\n\n",subchunk2Size)};

      return res;

    endfunction : print_hdr

    /*  Function to get wav packet in raw format  */
    function  void  get_raw(ref shortint unsigned arry[]);
      int offst = (subchunk1Size  ==  'd18) ? 1 : 0;

      //arry  = new[(chunkSize/2)+4]; //allocate buffer
      arry  = new[((4 + (8 + subchunk1Size) + (8 + subchunk2Size))/2)+4]; //allocate buffer

      foreach(arry[i])
      begin
        if(i  ==  0)
        begin
          arry[i]   = (chunkID  & 'hffff0000) >>  16;
        end
        else if(i ==  1)
        begin
          arry[i]   = chunkID & 'hffff;
        end
        else  if(i  ==  2)
        begin
          arry[i]   = ((chunkSize & 'hff) <<  8)  + ((chunkSize & 'hff00) >>  8);
        end
        else if(i ==  3)
        begin
          arry[i]   = ((chunkSize & 'hff0000) >>  8)  + ((chunkSize & 'hff000000) >>  24);
        end
        else  if(i  ==  4)
        begin
          arry[i]   = (chunkFmt & 'hffff0000) >>  16;
        end
        else  if(i  ==  5)
        begin
          arry[i]   = chunkFmt  & 'hffff;
        end
        else  if(i  ==  6)
        begin
          arry[i]   = (subchunk1ID  & 'hffff0000) >>  16;
        end
        else  if(i  ==  7)
        begin
          arry[i]   = subchunk1ID & 'hffff;
        end
        else  if(i  ==  8)
        begin
          arry[i]   = ((subchunk1Size & 'hff) <<  8)  + ((subchunk1Size & 'hff00) >>  8);
        end
        else  if(i  ==  9)
        begin
          arry[i]   = ((subchunk1Size & 'hff0000) >>  8)  + ((subchunk1Size & 'hff000000) >>  24);
        end
        else  if(i  ==  10)
        begin
          arry[i]   = subchunk1AudFmt;
        end
        else  if(i  ==  11)
        begin
          arry[i]   = subchunk1NoChnls;
        end
        else  if(i  ==  12)
        begin
          arry[i]   = (subchunk1SampleRate  & 'hffff0000) >>  16;
        end
        else  if(i  ==  13)
        begin
          arry[i]   = subchunk1SampleRate & 'hffff;
        end
        else  if(i  ==  14)
        begin
          arry[i]   = (subchunk1ByteRate  & 'hffff0000) >>  16;
        end
        else  if(i  ==  15)
        begin
          arry[i]   = subchunk1ByteRate & 'hffff;
        end
        else  if(i  ==  16)
        begin
          arry[i]   = subchunk1BlockAlign;
        end
        else  if(i  ==  17)
        begin
          arry[i]   = subchunk1BitsPerSample;
        end
        else  if(i  ==  (18 + offst))
        begin
          arry[i]   = (subchunk2ID  & 'hffff0000) >>  16;
        end
        else  if(i  ==  (19 + offst))
        begin
          arry[i]   = subchunk2ID & 'hffff;
        end
        else  if(i  ==  (20 + offst))
        begin
          arry[i]   = ((subchunk2Size & 'hff00) >>  8)  + ((subchunk2Size & 'hff) <<8);
        end
        else  if(i  ==  (21 + offst))
        begin
          arry[i]   = ((subchunk2Size & 'hff0000) >>  8)  + ((subchunk2Size & 'hff000000) >>  24);
        end
        else if(i > (21 + offst))
        begin
          if(subchunk1BitsPerSample ==  16)
          begin
            arry[i] = data[i- (22 + offst)]  & 'hffff;
          end
          else  //bps = 32
          begin
            if(((i-offst) % 2)  ==  0)
            begin
              arry[i] = (data[(i-22-offst)/2] & 'hffff0000) >>  16; //upper 16b
            end
            else
            begin
              arry[i] = data[(i-23-offst)/2]  & 'hffff; //lower 16b
            end
          end
        end

        if((i>420) && (i<430))
        begin
          ovm_report_info({get_name(),"[get_raw]"},$psprintf("data[%d] = 0x%x",i,arry[i]),OVM_LOW);
        end
      end //foreach

    endfunction : get_raw


    /*  Function  to populate the pcm data fields with a sine wave  */
    function  void  fill_sin(int  chnl_no=0,  int freq, int mag);

      foreach(data[n])
      begin
        if(((n % 2) ==  chnl_no)  ||  (subchunk1NoChnls ==  1))
        begin
          $cast(data[n],  mag*syn_sin((2*pi*freq*n)/subchunk1SampleRate));
        end
      end

    endfunction : fill_sin

    /*  Function  to mix data fields with a sine wave  */
    function  void  mix_sin(int  chnl_no=0,  int freq, int mag);
      int temp;

      foreach(data[n])
      begin
        if(((n % 2) ==  chnl_no)  ||  (subchunk1NoChnls ==  1))
        begin
          $cast(temp,  mag*syn_sin((2*pi*freq*n)/subchunk1SampleRate));
          data[n] +=  temp;
        end
      end

    endfunction : mix_sin


    /*  Function to fill with random data */
    function  void  fill_random(int chnl_no=0);

      foreach(data[n])
      begin
        if(((n % 2) ==  chnl_no)  ||  (subchunk1NoChnls ==  1))
        begin
          data[n]   = $random;
        end
      end

    endfunction : fill_random

    /*  Function to build wave packet from basic inputs */
    function  void  build_pkt(shortint no_chnls=1, shortint bps=16, int fs=44100, shortint num_samples);

      this.no_samples             = num_samples;

      this.data                   = new[no_samples  * no_chnls];

      this.subchunk2Size          = (num_samples  * no_chnls  * bps)/8;

      this.subchunk1BitsPerSample = bps;

      this.subchunk1BlockAlign    = (no_chnls * bps)/8;

      this.subchunk1ByteRate      = (fs * no_chnls  * bps)/8;

      this.subchunk1SampleRate    = fs;

      this.subchunk1NoChnls       = no_chnls;

      this.chunkSize              = 36  + this.subchunk2Size;

    endfunction : build_pkt


    /*  Constraint  Block */
    constraint  c_chunk_size      {chunkSize  ==  36  + subchunk2Size;}

    constraint  c_num_chnnls_lim  {subchunk1NoChnls inside  {1,2};}

    constraint  c_sample_rate_lim {subchunk1SampleRate  inside  {48000, 32000,  96000,  44100};}

    constraint  c_byte_rate       {subchunk1ByteRate  ==  (subchunk1SampleRate  * subchunk1NoChnls  * subchunk1BitsPerSample)/8;}

    constraint  c_block_align     {subchunk1BlockAlign  ==  (subchunk1NoChnls * subchunk1BitsPerSample)/8;}

    constraint  c_bps_lim         {subchunk1BitsPerSample inside  {16,  32};}

    constraint  c_subchunk2_size  {subchunk2Size  ==  (no_samples * subchunk1NoChnls  * subchunk1BitsPerSample)/8;}

    constraint  c_no_samples      {data.size  ==  no_samples  * subchunk1NoChnls;}

    constraint  c_data_lim        {
                                    subchunk1BitsPerSample  ==  16  ->  foreach (data[i]) data[i] inside  {[-32767:32767]};
                                    subchunk1BitsPerSample  ==  32  ->  foreach (data[i]) data[i] inside  {[-2147483647:2147483647]};
                                  }



  endclass  : syn_wav_seq_item

`endif
