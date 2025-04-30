---
title: Go — Any type comparability between functions and generics
date: 2025-03-31 00:26:15 
categories: [Tech, Golang]
tags: [golang, learning-go-book]
---

## Let's see tha problem
When you're using `any` type in Go with functions and you try to compare between them, if the types pass are comparable types, Go will allow you to compare them. But if the types are not comparable, Go will throw an error.

```go main.go
package main

import (
    "fmt"
)

func compare(a, b any) bool {
    return a == b
}
func main() {
    fmt.Println(compare(1, 1))
    fmt.Println(compare("hello", "hello"))
    fmt.Println(compare([]int{1, 2}, []int{1, 2}))
}
```
```bash output
true
true
error: invalid operation: a == b (operator == not defined on []int)
```

Which completely makes sense. ✅

Now, let's see the same code but using generics.

```go main.go
package main

import (
    "fmt"
)

func compare[T any](a, b T) bool {
    return a == b
}
func main() {
    fmt.Println(compare(1, 1))
    fmt.Println(compare("hello", "hello"))
    fmt.Println(compare([]int{1, 2}, []int{1, 2}))
}
```
```bash output
invalid operation: a == b (incomparable types in type set)
```

Now, you'll start asking yourself, why is this happening? Why Go allows you to compare `any` types but not generics?

## The reason
`any` is a type that can hold any value, including values of types that are not comparable. but when you use it with `functions`, Go will allow you to compare them if the types are comparable. This is because Go evaluates them at **`runtime`**. In `runtime`, Go uses reflection to determine the type of the value stored in the `any` variable, and if the types are comparable, it will allow you to compare them.

In contrast, `generics` are evaluated at **`compile time`**. This means that the compiler needs to know the types of the values being passed to the function at `compile time`. Also there's no using of the `reflection`. And since `any` doesn't give any information about the types of the values being passed, the compiler panics and throws an error.

## The Solution
Use `comparable` constraint to allow only comparable types to be passed to the function.

```go main.go
package main

import (
    "fmt"
)

func compare[T comparable](a, b T) bool {
    return a == b
}

func main() {
    fmt.Println(compare(1, 1))
    fmt.Println(compare("hello", "hello"))
    fmt.Println(compare([]int{1, 2}, []int{1, 2}))
}
```
```bash output
true
true
[]int does not satisfy comparable
```
