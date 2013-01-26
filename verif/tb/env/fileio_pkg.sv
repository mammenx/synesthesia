package fileio_pkg;

  function automatic void fread_32(ref integer fd, ref int unsigned bffr, ref int bytes_read);

    int unsigned temp;

    bytes_read += $fread(temp, fd);

    $cast(bffr, temp);

    return;

  endfunction : fread_32


  function automatic void fread_16(ref integer fd, ref shortint unsigned bffr, ref int bytes_read);

    shortint unsigned temp;

    bytes_read += $fread(temp, fd);

    $cast(bffr, temp);

    return;

  endfunction : fread_16


endpackage : fileio_pkg
