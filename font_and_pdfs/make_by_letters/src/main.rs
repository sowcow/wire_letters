use anyhow::Result;
use itertools::Itertools;
use std::collections::HashMap;

fn read_words() -> Result<Vec<String>> {
    let content = std::fs::read_to_string("../topwords/words.txt")?;
    let mut words: Vec<String> = content
        .lines()
        .map(String::from)
        .collect();

    use regex::Regex;
    let re = Regex::new("^[a-z]+$").unwrap();
    words.retain(|word| re.is_match(word));

    words.retain(|word| word.len() > 2);

    Ok(words)
}

use rayon::prelude::*;

fn best_combos(letter: &str, xs: Vec<String>) -> Vec<String> {
    let xs_ref = &xs; // Create a reference for use in the parallel iterator
    
    // Parallel generation of combinations using rayon
    let mut got: Vec<String> = (0..xs_ref.len())
        .into_par_iter()
        .flat_map(|i| {
            (i + 1..xs_ref.len())
                .into_par_iter()
                .map(move |j| format!("{} {}", xs_ref[i], xs_ref[j]))
        })
        .collect();

    // Process with group_by_pattern
    got = group_by_pattern(letter, got);

    // Parallel sort by key
    got.par_sort_unstable_by_key(|word| {
        std::cmp::Reverse(pair_pattern(letter, word).count_ones())
    });

    // Take the top results
    let scope = 5000;
    got.into_iter().take(scope).collect()
}

fn main() -> Result<()> {
    let scope = 5000; // early scope

    for char in 'a'..='z' {
        let letter = &char.to_string();

        let xs = read_words()?;
        let xs: Vec<String> = xs.into_iter().take(scope).collect();
        
        let xs: Vec<String> = xs.into_iter().filter(|x|
            x.contains(letter)
        ).collect();

        let mut xs = group_by_pattern(letter, xs);
        println!("{}", xs.len());

        // 64 just for overhaving stuff
        for _ in 1..=6 {
            xs = best_combos(letter, xs);
            println!("{}", xs.len());
        }
        let got = xs.first().unwrap();

        println!("{:?}", got);

        let name = format!("../by_letters/{letter}.txt");
        let mut items = got.split(' ').collect::<Vec<&str>>();
        items.sort();
        items.dedup();

        // target for best 15 items
        let target_count = 15;
        if items.len() > target_count {
            items = items
                .into_iter()
                .combinations(target_count)
                .max_by_key(|combo| {
                    let word = combo.join(" ");
                    pair_pattern(letter, &word).count_ones()
                }).unwrap();
        }

        let content = items.into_iter().join("\n");
        std::fs::write(name, content).unwrap();
    }

    Ok(())
}


// Even more optimized version that reduces locking
fn group_by_pattern(letter: &str, xs: Vec<String>) -> Vec<String> {
    // Create a vector of pattern-word pairs in parallel
    let pattern_word_pairs: Vec<(u64, String)> = xs
        .into_par_iter()
        .map(|word| (pair_pattern(letter, &word), word))
        .collect();
    
    // Sequentially build the groups (this part is fast since patterns are already computed)
    let mut groups: HashMap<u64, String> = HashMap::new();
    
    for (pattern, word) in pattern_word_pairs {
        groups
            .entry(pattern)
            .and_modify(|best_word| {
                if word.len() < best_word.len() {
                    *best_word = word.clone();
                }
            })
            .or_insert(word);
    }
    
    groups.into_values().collect()
}

fn pair_pattern(letter: &str, word: &str) -> u64 {
    let letter = letter.to_ascii_lowercase().as_bytes()[0];
    let word = word.to_ascii_lowercase();
    
    let mut bitmask: u64 = 0;
    
    for i in 0..word.len().saturating_sub(1) {
        let bytes = word.as_bytes();

        if bytes[i] == b' ' || bytes[i + 1] == b' ' {
            continue; // the truly edge case can be left for random appearance
        }

        if bytes[i] == letter || bytes[i + 1] == letter {
            let diff = (bytes[i] as i8).wrapping_sub(bytes[i + 1] as i8);
            // Map -25..=25 to 0..=50
            let index = (diff as i16 + 25) as u32;
            bitmask |= 1 << index;
        }
    }
    
    bitmask
}
