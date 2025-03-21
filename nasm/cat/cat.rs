use std::env;
use std::fs::File;
use std::io::{self, Read, Write};

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();

    // If no files are provided, read from standard input
    if args.len() < 2 {
        let mut buffer = String::new();
        io::stdin().read_to_string(&mut buffer)?;
        print!("{}", buffer);
    } else {
        // Iterate over each file provided as an argument
        for filename in &args[1..] {
            let mut file = match File::open(filename) {
                Ok(f) => f,
                Err(e) => {
                    eprintln!("Error opening {}: {}", filename, e);
                    continue;
                }
            };

            let mut contents = String::new();
            if let Err(e) = file.read_to_string(&mut contents) {
                eprintln!("Error reading {}: {}", filename, e);
                continue;
            }
            print!("{}", contents);
        }
    }
    io::stdout().flush()?;
    Ok(())
}
