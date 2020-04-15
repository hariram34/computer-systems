
#include <stdio.h>
// based on cs3650 starter code

#include <string.h>
#include <stdlib.h>
//#include <alloca.h>

typedef struct slist {
    char* data;
    int   refs;
    struct slist* next;
} slist;

slist*
s_cons(const char* text, slist* rest)
{
    slist* xs = malloc(sizeof(slist));
    xs->data = strdup(text);
    xs->refs = 1;
    xs->next = rest;
    return xs;
}

void
s_free(slist* xs)
{
    if (xs == 0) {
        return;
    }

    xs->refs -= 1;

    if (xs->refs == 0) {
        s_free(xs->next);
        free(xs->data);
        free(xs);
    }
}


slist*
s_split(const char* text, char delim)
{
    if (*text == 0) {
        return 0;
    }

    int plen = 0;
    while (text[plen] != 0 && text[plen] != delim) {
        plen += 1;
    }

    int skip = 0;
    if (text[plen] == delim) {
        skip = 1;
    }
  
    slist* rest = s_split(text + plen + skip, delim);
    char*  part = alloca(plen + 2);
    memcpy(part, text, plen);
    part[plen] = 0;

    return s_cons(part, rest);
}


int main()
{
    slist* whatever = s_split("/a/b/c/d",'/');
    while(whatever){
        printf("%s ",whatever->data);
        whatever = whatever->next;
    }
    return 0;
}
