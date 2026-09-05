use std::env;
use std::fs;
use std::path::{Path, PathBuf};

fn collect_files(dir: &Path, files: &mut Vec<(u64, PathBuf)>) {
    let entries = match fs::read_dir(dir) {
        Ok(entries) => entries,
        Err(_) => return,
    };

    for entry in entries.flatten() {
        let path = entry.path();

        let metadata = match fs::symlink_metadata(&path) {
            Ok(metadata) => metadata,
            Err(_) => continue,
        };

        if metadata.file_type().is_symlink() {
            continue;
        }

        if metadata.is_dir() {
            collect_files(&path, files);
        } else if metadata.is_file() {
            files.push((metadata.len(), path));
        }
    }
}

fn human_size(bytes: u64) -> String {
    const UNITS: [&str; 5] = ["B", "KiB", "MiB", "GiB", "TiB"];

    let mut size = bytes as f64;
    let mut unit = 0;

    while size >= 1024.0 && unit < UNITS.len() - 1 {
        size /= 1024.0;
        unit += 1;
    }

    format!("{size:.2} {}", UNITS[unit])
}

fn main() {
    let cli_args: Vec<String> = env::args().collect();

    let directory = cli_args.get(1).map(String::as_str).unwrap_or(".");

    let count: usize = cli_args
        .get(2)
        .and_then(|value| value.parse().ok())
        .unwrap_or(10);

    let root = Path::new(directory);

    if !root.is_dir() {
        eprintln!("Error: '{}' is not a directory.", root.display());
        std::process::exit(1);
    }

    let mut files = Vec::new();

    collect_files(root, &mut files);

    files.sort_by(|a, b| b.0.cmp(&a.0));

    println!("Largest files in '{}':\n", root.display());

    for (size, path) in files.iter().take(count) {
        println!("{:>12}  {}", human_size(*size), path.display());
    }
}
