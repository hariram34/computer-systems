// Author: Nat Tuck
// CS3650 starter code

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <assert.h>
#include <pthread.h>
#include "barrier.h"

barrier*
make_barrier(int nn)
{
    int rv;
    barrier* bb = malloc(sizeof(barrier));
    assert(bb != 0);
    rv = pthread_mutex_init(&(bb->barrier), NULL);
    if (rv == -1) {
        perror("barrier make");
        abort();
    }

    rv = pthread_mutex_init(&(bb->mutex), NULL);
    if (rv == -1) {
        perror("mutex init");
        abort();
    }
    rv = pthread_cond_init(&(bb->cond), NULL);
    if (rv == -1) {
        perror("condn");
        abort();
    }
    bb->seen = nn;
    return bb;
}

void
barrier_wait(barrier* bb)
{
   int rv;
   rv = pthread_mutex_lock(&(bb->mutex));
   if(rv!=0){
       perror("mutex lock");
   }
    bb->seen--;
    int seen = bb->seen;
    pthread_mutex_unlock(&(bb->mutex));
    if(rv!=0){
       perror("mutex unlock");
    }
    pthread_mutex_lock(&(bb->barrier));
    if(rv!=0){
       perror("mutex unlock");
    }
    if(seen == 0){
        pthread_cond_broadcast(&(bb->cond));
    }
    else{
        pthread_cond_wait(&(bb->cond), &(bb->barrier));
    }
    pthread_mutex_unlock(&(bb->barrier));
}

void
free_barrier(barrier* bb)
{
   pthread_mutex_destroy(&(bb->mutex)); 
   pthread_mutex_destroy(&(bb->barrier)); 
   free(bb);
}

