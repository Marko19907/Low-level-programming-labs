
fn main() {
    let mut x = 0;

    while x < 100 {
        // println!("x is {}", x);
        format_print(x);
        x += 1;
    }
}

/// Needed because assembly can't print numbers with more than 1 digit but can print ASCII characters.
fn format_print(value: i32) {
    if value < 10 {
        println!("{}", value);
        return;
    }

    let mut index = 0;
    let mut temp = value;

    while temp >= 10 {
        temp = temp - 10;
        index = index + 1;
    }

    println!("{}{}", index, temp);
}
