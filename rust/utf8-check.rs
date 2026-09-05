use std::env;
use std::fs;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();

    let file = match args.get(1) {
        Some(file) => file,
        None => {
            eprintln!("Usage: utf8-check <file>");
            process::exit(2);
        }
    };

    let data = match fs::read(file) {
        Ok(data) => data,
        Err(error) => {
            eprintln!("Error reading '{}': {}", file, error);
            process::exit(2);
        }
    };

    match std::str::from_utf8(&data) {
        Ok(_) => {
            println!("[  OK  ] '{}' is valid UTF-8", file);
        }

        Err(error) => {
            println!(
                "[FAILED] '{}' contains invalid UTF-8 at byte {}",
                file,
                error.valid_up_to()
            );

            process::exit(1);
        }
    }
}
