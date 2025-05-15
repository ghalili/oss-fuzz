#include <stdio.h>
#include <stdlib.h>
#include <jpeglib.h>

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "Usage: %s <jpeg-file>\n", argv[0]);
    return 1;
  }

  FILE *infile = fopen(argv[1], "rb");
  if (!infile) {
    perror("fopen");
    return 1;
  }

  struct jpeg_decompress_struct cinfo;
  struct jpeg_error_mgr jerr;

  cinfo.err = jpeg_std_error(&jerr);
  jpeg_create_decompress(&cinfo);
  jpeg_stdio_src(&cinfo, infile);

  jpeg_read_header(&cinfo, TRUE);
  jpeg_start_decompress(&cinfo);
  jpeg_finish_decompress(&cinfo);
  jpeg_destroy_decompress(&cinfo);

  fclose(infile);
  return 0;
}

