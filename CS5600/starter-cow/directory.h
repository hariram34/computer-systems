#ifndef DIRECTORY_H
#define DIRECTORY_H

#include <bsd/string.h>

#include "slist.h"
#include "pages.h"
#include "inode.h"

#define DIR_NAME 48

typedef struct dirent {
    char name[DIR_NAME];
    int  inum;
    char _reserved[12];
} dirent;

char* directory_get(int inum);
void directory_init();
char* curdir_get(const char* path);
int directory_lookup(const char* name);
int tree_lookup(const char* path);
char* curdir_par_get(const char* path, char* child);
int
directory_put(const char* name, int inum);
int directory_delete(const char* name);
slist* directory_list(const char* path);
void print_directory();

#endif

