#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  FILE *fi = fopen("run2.log", "r");
  char line[500];
  int MHZ = atoi(argv[1]);
  int index = 0;
  int val = 0;
  int ticks, iter, size;
  while(fgets(line, sizeof(line), fi) != NULL) {
    if (line[0] == '$') {
      sscanf(line, "$%d = %d", &index, &val);
      switch (index) {
        case 1: size=val; break;
        case 2: ticks=val; break;
        case 3: iter=val; break;
      }
    }
  }
  printf("CoreMark Size: %d\n", size);
  printf("Total ticks: %d\n", ticks);
  printf("Iterations: %d\n", iter);
  float time_secs = (float)(((float)ticks/1000000)/MHZ);
  float iter_secs = (float)(iter/time_secs);
  float cmark_secs = (float)(iter_secs/MHZ);
  printf("Total time (secs): %.6f\n", time_secs);
  printf("Iterations/Sec (CoreMark): %.6f\n", iter_secs);
  printf("Iterations/Sec/MHz (CoreMark/MHz): %.6f\n", cmark_secs);
  return 0;
}
