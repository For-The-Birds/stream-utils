#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

typedef struct
{
   signed char x_vector;
   signed char y_vector;
   short sad;
} motion_vector;

int main(int argc, char **argv)
{
    int fdin;
    int result;
    motion_vector *map;  /* mmapped array of structs */
    struct stat statbuf;

    if ((fdin = open (argv[1], O_RDONLY)) < 0)
    {
        printf("can't open %s for reading", argv[1]);
        return 0;
    }

    if (fstat (fdin, &statbuf) < 0)
    {
        printf ("fstat error");
        return 0;
    }

    if ((map = (motion_vector *)mmap (0, statbuf.st_size, PROT_READ, MAP_SHARED, fdin, 0)) == -1)
    {
        printf ("mmap error for input");
        return 0;
    }

    motion_vector * v = map;
    for (int i = 0; i<statbuf.st_size/sizeof(motion_vector); i++)
    {
        printf("%d %d %d\n", v[i].x_vector, v[i].y_vector, v[i].sad);
    }

    if (munmap(map, statbuf.st_size) == -1)
    {
        perror("Error un-mmapping the file");
    }

    close(fdin);
}
