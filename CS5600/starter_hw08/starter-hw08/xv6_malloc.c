/*
#include "types.h"
#include "stat.h"
#include "user.h"
#include "param.h"
*/
#include <pthread.h>
#include <sys/mman.h>
#include <string.h>
#include "xmalloc.h"

// Memory allocator by Kernighan and Ritchie,
// The C programming Language, 2nd ed.  Section 8.7.
//
// Then copied from xv6.

// TODO: Remove this stuff
typedef unsigned long uint;
//static char* sbrk(uint nn) { return 0; }
// TODO: end of stuff to remove
int min(int a,int b){
  return (a>b)?b:a;
}
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
typedef long Align;

union header {
  struct {
    union header *ptr;
    uint size;
  } s;
  Align x;
};

typedef union header Header;

// TODO: This is shared global data.
// You're going to want a mutex to protect this.
static Header base;
static Header *freep;

void
xfree(void *ap)
{
  Header *bp, *p;
  pthread_mutex_lock(&lock);
  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
  freep = p;
  pthread_mutex_unlock(&lock);
}

static Header*
morecore(uint nu)
{
  char *p;
  Header *hp;

  if(nu < 4096)
    nu = 4096;
  // TODO: Replace sbrk use with mmap
  //p = sbrk(nu * sizeof(Header));

  p = mmap(NULL, nu*sizeof(Header), PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
                  -1, 0);

  if(p == (char*)-1)
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
  xfree((void*)(hp + 1));
  return freep;
}

void*
xmalloc(uint nbytes)
{
  Header *p, *prevp;
  uint nunits;
  pthread_mutex_lock(&lock);
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep = prevp;
      pthread_mutex_unlock(&lock);
      return (void*)(p + 1);
    }
    if(p == freep){
      pthread_mutex_unlock(&lock);
      if((p = morecore(nunits)) == 0){
        return 0;
      }
    }
  }
}

void*
xrealloc(void* prev, size_t nn)
{
  // TODO: Actually build realloc.
  void* realloc = xmalloc(nn);
  Header *oldh = (Header*)prev;
  oldh = oldh - 1;
  size_t size = (oldh->s.size - 1)*sizeof(Header) - sizeof(Header) + 1;
  memcpy(realloc, prev, min(nn,size));
  xfree(oldh+1);
  return realloc;
}
