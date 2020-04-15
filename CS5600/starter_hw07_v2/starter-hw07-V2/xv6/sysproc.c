#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "stat.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return myproc()->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

int
sys_halt()
{
  // Incantation from Redox OS
  outw(0x604, 0x2000);
  while(1);
  return 0;
}

void* sys_spalloc(){
  return spalloc();
}

void sys_spfree(void){
  void* ptr;
  if(argptr(0,(void*)&ptr,sizeof(void*))<0){
    exit();
  }
  //return 
  spfree(ptr);

}

//
//int
//sys_mutex_init()
//{
//  mutex_t* ptr;
//  if(argptr(0, (void*)&ptr, sizeof(void*))<0)
//    return -1;
//  
//  return mutex_init(ptr);
//}
//
//int
//sys_mutex_lock()
//{
//  mutex_t* ptr;
//  if(argptr(0, (void*)&ptr, sizeof(void*))<0)
//    return -1;
//
//  return mutex_lock(ptr);
//}
//
//int
//sys_mutex_unlock()
//{
//  mutex_t *ptr;
//  if(argptr(0, (void*)&ptr, sizeof(void*))<0)
//    return -1;
//
//  return mutex_unlock(ptr);
//}