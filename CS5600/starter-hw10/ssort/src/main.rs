
extern crate rand;
use rand::Rng;

extern crate bytes;
use bytes::Buf;

use std::env;
use std::io::{Cursor, Read, Seek, SeekFrom, Write};
use std::fs::{File, OpenOptions};
use std::f32;
use std::thread;
use std::sync::{Arc, Barrier, Mutex};



fn main() {
    let args : Vec<String> = env::args().collect();
    if args.len() != 4 {
        println!("Usage: {} <threads> input output", args[0]);
    }

    let threads =  args[1].parse::<usize>().unwrap();
    let inp_path = &args[2];
    let out_path = &args[3];

    // Sample
    // Calculate pivots
    //println!("Geting file size\n");
    let mut inpf = File::open(inp_path).unwrap();
    let size = read_size(&mut inpf);
    //println!("Got the size,{}\n",size);
    let pivots = find_pivots(&mut inpf, threads);

    // Create output file
    {
        let mut outf = File::create(out_path).unwrap();
        let tmp = size.to_ne_bytes();
        outf.write_all(&tmp).unwrap();
        outf.set_len(size).unwrap();
    }

    let mut workers = vec![];

    // Spawn worker threads
    let sizes = Arc::new(Mutex::new(vec![0u64; threads]));
    let barrier = Arc::new(Barrier::new(threads));

    for ii in 0..threads {
        let inp = inp_path.clone();
        let out = out_path.clone();
        let piv = pivots.clone();
        let szs = sizes.clone();
        let bar = barrier.clone();

        let tt = thread::spawn(move || {
            worker(ii, inp, out, piv, szs, bar);
        });
        workers.push(tt);
    }

    // Join worker threads
    for tt in workers {
        tt.join().unwrap();
    }
}

fn read_size(file: &mut File) -> u64 {
    // TODO: Read size field from data file
    file.seek(SeekFrom::Start(0)).unwrap();
    //println!("extracting file size\n");
    let mut size = [0u8;8];
    file.read_exact(&mut size).unwrap();
    let xx = Cursor::new(size).get_u64_le();
  
    //let xx = size[0] as u64;
    //println!("size = {}",xx);
    xx
}

fn read_item(file: &mut File, ii: u64) -> f32 {
    // TODO: Read the ii'th float from data file
    //file.seek(SeekFrom::Start(8)).unwrap();
    file.seek(SeekFrom::Start(0)).unwrap();
    let mut value = [0u8;4];
    let  index = 4*ii;
    file.seek(SeekFrom::Start(8+index)).unwrap();
    file.read_exact(&mut value).unwrap();
    let xx = Cursor::new(value).get_f32_le();
    xx
}

fn sample(file: &mut File, count: usize, size: u64) -> Vec<f32> {
    let mut rng = rand::thread_rng();
    let mut ys = vec![];

    // TODO: Sample 'count' random items from the
    // provided file
    for _i in 0..count {
        let index = rng.gen_range(0,size);
        let ind = index as u64;
        ys.push(read_item(file,ind));
    }

    ys
}

fn find_pivots(file: &mut File, threads: usize) -> Vec<f32> {
    // TODO: Sample 3*(threads-1) items from the file
    // TODO: Sort the sampled list
    let mut pivots = vec![0f32];
    let _index = 0;
    let count = 3*(threads-1);
    let size = read_size(file);
    let mut medians = sample(file,count,size);

    medians.sort_by(|a,b| a.partial_cmp(b).unwrap());

    // TODO: push the pivots into the array

    for i in (1..medians.len()).step_by (3) {
        
        pivots.push(medians[i]);
    }
    pivots.push(f32::INFINITY);
    pivots
}

fn worker(tid: usize, inp_path: String, out_path: String, pivots: Vec<f32>,
          sizes: Arc<Mutex<Vec<u64>>>, bb: Arc<Barrier>) {
 // TODO: Open input as local fh
 let mut inpf = File::open(inp_path).unwrap();
 let size = read_size(&mut inpf);
 // TODO: Scan to collect local data
 let mut data = vec![];
 for i in 0..size
 {
     let n = read_item(&mut inpf,i);
     if (n>pivots[tid]) && (n<=pivots[tid+1]){
             data.push(n);
             //println!("pushed");
     }
 }
 // TODO: Write local size to shared sizes
 {
     let mut size = sizes.lock().unwrap();
     size[tid] = data.len() as u64;
     // curly braces to scope our lock guard
 }

 // TODO: Sort local data
 data.sort_by(|a,b| a.partial_cmp(b).unwrap());
 // Here's our printout
 println!("{}: start {}, count {}", tid, &data[0], data.len());
 bb.wait();
 // TODO: Write data to local buffer
 
 let mut cur = Cursor::new(vec![]);
 for xx in &data {
     let tmp = xx.to_ne_bytes();
     cur.write_all(&tmp).unwrap();
 }
 
 //// TODO: Get position for output file
 let prev_count = {
     let mut begin = 0u64;
     let sizep = sizes.lock().unwrap();
      for i in 0..tid
      {
          begin = begin+sizep[i];
      }
     // curly braces to scope our lock guard
     begin
 };

 
 let mut outf = OpenOptions::new()
     .read(true)
     .write(true)
     .open(out_path).unwrap();
 
 // TODO: Seek and write local buffer.
 outf.seek(SeekFrom::Start(8+(prev_count*4))).unwrap();
 // TODO: Figure out where the barrier goes.
 outf.write_all(cur.get_ref()).unwrap();
 
}
