---
title: Go — Tips And Tricks
date: 2025-03-09 15:53:02
categories: [Tech, Golang]
tags: [golang]
---

## Cutting Unicode character from a string
To cut a Unicode character from a string, you need first to convert string to an array of rune, then you can cut it
```go
message := "Hi 👩 and 👨"
runes := []rune(message)
fmt.Println(string(runes[3]))
```
if you cut it directly from the string it can return a garbage character because in this case you may cut bytes from the middle.

## Using Maps as Sets
```go
intSet := map[int]bool{}
vals := []int{5, 10, 2, 5, 8, 7, 3, 9, 1, 2, 10}

for _, v := range vals {
	intSet[v] = true
}

fmt.Println(len(vals), len(intSet)) // 11, 8
fmt.Println(intSet[5]) // true
fmt.Println(intSet[500]) // false

if intSet[100] { // false
	fmt.Println("100 is in the set")
}
```

Unless you have very large sets, you may use map of struct `map[int]struct{}{}`.

The advantage is that an empty struct uses **zero bytes**, while a boolean uses **one byte**. 

The disadvantage is that using a `struct{}` makes your code clumsier. You have a less obvious assignment, and you need to use the `comma ok idiom` to check if a value is in the `set`.
```go
intSet := map[int]struct{}{}
vals := []int{5, 10, 2, 5, 8, 7, 3, 9, 1, 2, 10}

for _, v := range vals {
	intSet[v] = struct{}{}
}

if _, ok := intSet[5]; ok {
	fmt.Println("5 is in the set")
}
```

## do-while in Go
Go has no equivalent of the `do` keyword in Java, C, and JavaScript. If you want to iterate at least once, the cleanest way is to use an infinite for loop that ends with an if statement. If you have some Java code, for example, that uses a `do/while` loop:
```java
do {
// things to do in the loop
} while (CONDITION);
```
the Go version looks like this:
```go
for {
	// things to do in the loop
	if !CONDITION {
		break
	}
}
```
Note that the condition has a leading `!` to `negate` the condition from the Java code. The Go code is specifying how to exit the loop, while the Java code specifies how to stay in it.

## Capture values within functions
If you would like to capture the value immediately regardless any changes will happen in the future, use `anonymous function`
```go
func main() {
	a := example()

	fmt.Println("main:", a)
}

func example() int {
	a := 10

	defer func(val int) {
		fmt.Println("first:", val)
	}(a)

	a = 30
	fmt.Println("exiting:", a)

	return a
}

// exiting: 30
// first: 10
// main: 30
```
but If you want to consider any changes in the future use `closures`
```go
func main() {
	a := example()

	fmt.Println("main:", a)
}

func example() int {
	a := 10

	defer func() {
		fmt.Println("first:", a)
	}()

	a = 30
	fmt.Println("exiting:", a)

	return a
}

// exiting: 30
// first: 30
// main: 30
```

## Improve Go Performance
- Returning a `struct` avoids a heap allocation, which is good. However, when invoking a function with parameters of `interface` types, a heap allocation occurs for each interface parameter.
- To store something on the stack, you have to know exactly how big it is at compile time. When you look at the value types in Go (primitive values, arrays, and structs), they all have one thing in common: you know exactly how much memory they take at compile time. 
- Using `buffers` is just one example of how you reduce the work done by the garbage collector. 
```go
// good example
file, err := os.Open(fileName)
if err != nil {
	return err
}
defer file.Close()

data := make([]byte, 100) // use buffers

for {
	count, err := file.Read(data)
	process(data[:count])
	if err != nil {
		if errors.Is(err, io.EOF) {
			return nil
		}
		return err
	}
}
```

```python
# bad example
r = open_resource()
while r.has_data() {
	# every time you iterate through that while loop, you allocate another data_chunk even though each one is used only once. 
	data_chunk = r.next_chunk() 
	process(data_chunk)
}
close(r)
```
- If the `pointer` variable is returned from a function, the memory that the pointer points to will no longer be valid when the function exits. When the compiler determines that the data can’t be stored on the stack, we say that the data the pointer points to `escapes` the stack, and the compiler stores the data on the heap.
