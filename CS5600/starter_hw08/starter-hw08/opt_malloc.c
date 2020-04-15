#include <stdlib.h>
#include <stdio.h>

#include "xmalloc.h"
#include <sys/mman.h>
#include <string.h>
#include <pthread.h>
#include <math.h>


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
static int bucket[10] = {2,5,9,17,33,65,129,257,513,1025};
static Header base[12];
static Header *freep[12];

int min(int a,int b){
  return (a>b)?b:a;
}

int indexcalc(long n){
    int ind = 0;
    while(ind < 10){
        if(bucket[ind]>=n){
          break;
        }
      ind++;  
    }
    //printf("i returned = %d\n",ind);
return ind;
}

void
freelist(void *ap, int i)
{
  pthread_mutex_lock(&lock);
  Header *bp, *p;
  bp = (Header*)ap - 1;
  for(p = freep[i]; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
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
  freep[i] = p;
  pthread_mutex_unlock(&lock);
}

void
xfree(void *addr)
{
    Header *prev = (Header*) addr;
    prev = prev - 1;
    unsigned long nunits = prev->s.size;
    int i = indexcalc(nunits);
    freelist(addr, i);
}

static Header*
morecore(unsigned long nu, int i)
{
  char *p;
  Header *hp;

  if(nu < 4096)
    nu = 4096;
  // TODO: Replace sbrk use with mmap

  p = mmap(NULL, nu*sizeof(Header), (PROT_READ|PROT_WRITE|PROT_EXEC), (MAP_PRIVATE|MAP_ANONYMOUS), -1, 0);
  if(p == (char*)-1)
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
  freelist((void*)(hp + 1), i);
  return freep[i];
}

void*
xvmalloc(unsigned long nbytes, int i)
{
  Header *p, *prevp;
  unsigned long nunits;
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  pthread_mutex_lock(&lock);
  if((prevp = freep[i]) == 0)
  {
    base[i].s.ptr = freep[i] = prevp = &base[i];
    base[i].s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr)
  {
    if(p->s.size >= nunits)
    {
      if(p->s.size == nunits)
        prevp->s.ptr = p->s.ptr;
      else 
      {
        p->s.size -= nunits;
        p += p->s.size;
        p->s.size = nunits;
      }
      freep[i] = prevp;
      pthread_mutex_unlock(&lock);
      return (void*)(p + 1);
    }
    if(p == freep[i])
    {
      pthread_mutex_unlock(&lock);
      if((p = morecore(nunits, i)) == 0)
      {
        return 0;
      }
      pthread_mutex_lock(&lock);
    }
  }
}

void*
xmalloc(unsigned long nbytes)
{
    unsigned long nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    int i = indexcalc(nunits);
    return (xvmalloc(nbytes, i));
}
void*
xrealloc(void* prev, size_t nn)
{
  void* new = xmalloc(nn);
  Header *prevh = (Header*)prev;
  prevh = prevh - 1;
  size_t size = (prevh->s.size - 1)*sizeof(Header) - sizeof(Header) + 1;
  memcpy(new, prev, min(nn,size));
  xfree(prevh+1);
  return new;
}
