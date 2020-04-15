
#define _GNU_SOURCE
#include <string.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <assert.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>

#include "directory.h"
#include "pages.h"
#include "slist.h"
#include "util.h"
#include "inode.h"

#define ENT_SIZE 16

void
directory_init()
{
    inode* rn = get_inode(1);

    if (rn->mode == 0) {
        rn->size = 0;
        rn->mode = 040755;
    }
}
char* curdir_get(const char* path){
    slist* pwd = s_split(path,'/');

    while(pwd->next){
        pwd = pwd->next;
    }
    return pwd->data; // b
}
char* curdir_par_get(const char* path, char* child){
    slist* pwd = s_split(path,'/');
    char* parent = 0;
    while(pwd->next){
        if(streq(child,pwd->data)==0){
            return parent;
        }
        strcpy(parent,pwd->data);
        pwd = pwd->next;
    }
    return 0; // b
}

char*
directory_get(int ii)
{
    char* base = pages_get_page(1);
    return base + ii*ENT_SIZE;
}

int
directory_lookup(const char* name)
{
    printf("looking for %s\n",name);
    for (int ii = 0; ii < 256; ++ii) {
        char* ent = directory_get(ii);
        if (streq(ent, name)) {
            return ii;
        }
    }
    return -ENOENT;
}

int
tree_lookup(const char* path)
{
    assert(path[0] == '/');

    if (streq(path, "/")) {
        return 1;
    }
    char* new_path = curdir_get(path);

    return directory_lookup(new_path);
}

int
directory_put(const char* name, int inum)
{
    //printf();
    // / a/ b c
    char* ent = pages_get_page(1) + inum*ENT_SIZE;
    strlcpy(ent, name, ENT_SIZE);
    printf("+ dirent = '%s'\n", ent);

    inode* node = get_inode(inum);
    printf("+ directory_put(..., %s, %d) -> 0\n", name, inum);
    print_inode(node);
    printf("ending dirput\n");
    return 0;
}

int
directory_delete(const char* name)
{
    printf(" + directory_delete(%s)\n", name);

    int inum = directory_lookup(name);
    free_inode(inum);

    char* ent = pages_get_page(1) + inum*ENT_SIZE;
    ent[0] = 0;

    return 0;
}

slist*
directory_list(const char* path)
{

    printf("+ directory_list()\n");
    slist* ys = 0;
    printf("path in dirlist : %s\n",path);
   
    int res = streq(path, "/");
    printf("result of path=%d\n",res);
    if(res){
        printf("root\n");
    for (int ii = 0; ii < 256; ++ii) {
        char* ent = directory_get(ii);

        if (ent[0]) {
            int cinum =  directory_lookup(ent);
            inode* cnode = get_inode(cinum);
            print_inode(cnode);
            if(cnode->pinum == 1){
            printf(" - %d: %s [%d]\n", ii, ent, ii);
            ys = s_cons(ent, ys);
            }
        }
    }
    }else{
    char* curdir = curdir_get(path); 
    printf("current directory returned is %s\n",curdir);
    int inum =  directory_lookup(curdir);
    printf("current directory : %s, directory lookup:%d\n",curdir,inum);
    inode* node = get_inode(inum);
    print_inode(node);
    printf("inode printing finished\n");
    //if(node->count 0){
        
    if(node->count>0){
        int dupcount = node->count;
        for (int ii = 0; ii < 256; ++ii) {
            char* ent = directory_get(ii);
        if (ent[0]) {
            printf("ent = %s\n",ent);
            int cinum =  directory_lookup(ent);
            inode* cnode = get_inode(cinum);
            print_inode(cnode);
            printf("finished printing cnode\n");
            if(cnode->pinum == inum){
                dupcount--;
                printf(" - %d: %s [%d]\n", ii, ent, ii);
                ys = s_cons(ent, ys);
            }
        }
     }
        // use dirent structure
    }else{
        return ys;
    }
    }
    
    return ys;
}

void
print_directory(inode* dd)
{
    printf("Contents:\n");
    slist* items = directory_list(dd);
    for (slist* xs = items; xs != 0; xs = xs->next) {
        printf("- %s\n", xs->data);
    }
    printf("(end of contents)\n");
    s_free(items);
}
