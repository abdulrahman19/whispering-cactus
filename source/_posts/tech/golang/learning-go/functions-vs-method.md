---
title: Go — Functions Versus Methods
date: 2025-03-12 00:31:34
categories: [Tech, Golang]
tags: [golang, learning-go-book]
---

> As I’ve covered several times, package-level state should be effectively immutable. Anytime your logic depends on values that are configured at startup or changed while your program is running, those values should be stored in a struct, and that logic should be implemented as a method. If your logic depends only on the input parameters, it should be a function.
>
> – Learning Go (2nd edition), Chapter 7, "Functions Versus Methods"

This paragraph emphasizes three key ideas:
1. Package-Level State Should Be **Immutable**
    - Avoid modifying global variables during runtime.
    - Instead, if a value changes dynamically, store it inside a struct and encapsulate the logic as a `method`.
2. Use Methods When State Is Involved
    - If a function needs to depend on changing values, it should be inside a struct as a `method`.
3. Use Functions When No State is Needed
    - If a function only depends on `input parameters` and not any persistent state, it should remain a standalone `function`.

## Example 1: Modify Package-Level
This is a **BAD approach** to modify the `Package-Level` state - Avoid This!
```go main.go
package main

import "fmt"

var configValue = 100 // Package-level mutable state (BAD)

func updateConfig(newValue int) {
	configValue = newValue // Modifying global state (AVOID THIS)
}

func main() {
	fmt.Println("Before:", configValue)
	updateConfig(200)
	fmt.Println("After:", configValue)
}
```
```bash output
Before: 100
After: 200
```

Why is this bad?
- `configValue` is **mutable** at the package level, which can lead to unexpected behavior in concurrent programs.
- Any function can modify `configValue`, making it hard to track and debug.

## Example 2: Use a Struct & Method
In this example you will see a **GOOD approach** on how to use a `struct` & `method` to manage state.
```go main.go
package main

import "fmt"

// Config struct to store state
type Config struct {
	value int
}

// Method to update state
func (c *Config) UpdateConfig(newValue int) {
	c.value = newValue
}

func main() {
	config := Config{value: 100} // Initialize config with value

	fmt.Println("Before:", config.value)
	config.UpdateConfig(200) // Use method to update
	fmt.Println("After:", config.value)
}
```
```bash output
Before: 100
After: 200
```

## Example 3: Function When No State Is Needed
This is the normal use when no state is needed and the function depends on `input parameters`.
```go main.go
package main

import "fmt"

// Pure function: Only depends on input, not internal state
func Add(x, y int) int {
	return x + y
}

func main() {
	fmt.Println(Add(10, 20))
}
```
```bash output
30
```
