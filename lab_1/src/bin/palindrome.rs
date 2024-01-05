
fn main() {
    println!("Hello, world!");
    assert!(is_palindrome("racecar"));
    assert!(is_palindrome("My gym"));
    assert!(is_palindrome("step on no pets"));
    assert!(is_palindrome("Was it a car or a cat I saw?"));
    assert!(is_palindrome("KayAk"));
    assert!(is_palindrome("A9c9a"));
    assert!(is_palindrome("bb"));

    assert!(!is_palindrome("First level"));
    assert!(!is_palindrome("cat"));
    assert!(!is_palindrome("Palindrome"));
    assert!(!is_palindrome("a"));
}

/// Returns true if the string is a palindrome, false otherwise. Ignores case and spaces. The string must be at least 2 characters long.
fn is_palindrome(string: &str) -> bool {
    if string.len() < 2 {
        return false;
    }

    let mut left_pointer = 0;
    let mut right_pointer = string.len() as i32 - 1;

    while left_pointer < right_pointer {

        let left_char = string.chars().nth(left_pointer as usize).unwrap();
        let right_char = string.chars().nth(right_pointer as usize).unwrap();

        if !left_char.is_alphanumeric() {
            left_pointer += 1;
            continue;
        }
        if !right_char.is_alphanumeric() {
            right_pointer -= 1;
            continue;
        }

        if left_char.to_lowercase().to_string() != right_char.to_lowercase().to_string() {
            return false;
        }

        left_pointer += 1;
        right_pointer -= 1;
    }

    return true;
}
