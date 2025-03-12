---
title: Go — Accept Interfaces, Return Structs
date: 2025-03-12 03:03:34
categories: [Tech, Golang]
tags: [golang, learning-go-book]
---

> The primary reason your functions should return concrete types is they make it easier to gradually update a function’s return values in new versions of your code. When a concrete type is returned by a function, new methods and fields can be added without breaking existing code that calls the function, because the new fields and methods are ignored. The same is not true for an interface. Adding a new method to an interface means that all existing implementations of that interface must be updated, or your code breaks.
>
> – Learning Go (2nd edition), Chapter 7, "Accept Interfaces, Return Structs"

When a function returns a `concrete type`, it provides direct access to that type's methods and fields. This makes it easier to extend or modify the type in the future.
When a function returns an `interface`, changing the interface (e.g., adding a new method) forces all implementations of that interface to update, which can break existing code.

## Adding Fields and Methods to Concrete Types Is Safe
When you return a concrete type from a function, you can add new fields and methods to that type without breaking existing code. The new fields and methods are ignored by the existing code that calls the function.

```go main.go
package main

type User struct {
    Name string
}

func (u User) Greet() string {
    return "Hello, " + u.Name
}

// Function returning a concrete type
func GetUser() User {
    return User{Name: "Alice"}
}

func main() {
    user := GetUser()
    fmt.Println(user.Greet())
}
```
```bash output
Hello, Alice
```

Now, we decide to add a new field and a new method:

```go main.go
package main

type User struct {
    Name string
    Age  int
}

func (u User) Greet() string {
    return "Hello, " + u.Name
}

func (u User) IsAdult() bool {
    return u.Age >= 18
}

// Function returning a concrete type
func GetUser() User {
    return User{Name: "Alice"}
}

func main() {
    user := GetUser()
    fmt.Println(user.Greet())
}
```
```bash output
Hello, Alice
```
The existing code that uses `User` **doesn't break**, because methods are just additional functionality.

## Interfaces Break When Modified
When you return an interface from a function, adding a new method to that interface forces all implementations of that interface to update. This can break existing code that calls the function.

```go main.go
package main

type Greeter interface {
    Greet() string
}

type User struct {
    Name string
}

func (u User) Greet() string {
    return "Hello, " + u.Name
}

// Function returning an interface
func GetGreeter() Greeter {
    return User{Name: "Alice"}
}

func main() {
    greeter := GetGreeter()
    fmt.Println(greeter.Greet())
}
```
```bash output
Hello, Alice
```
Later, we decide to extend the interface:

```go main.go
package main

type Greeter interface {
    Greet() string
    IsAdult() bool
}

type User struct {
    Name string
}

func (u User) Greet() string {
    return "Hello, " + u.Name
}

// Function returning an interface
func GetGreeter() Greeter {
    return User{Name: "Alice"}
}

func main() {
    greeter := GetGreeter()
    fmt.Println(greeter.Greet())
}
```
```bash output
cannot use User{…} (value of struct type User) as Greeter value in return statement...
```
The existing code that uses `Greeter` **breaks**, because the interface has changed.

## When to Use Interfaces in Return Values
- Use interfaces when multiple types can be returned from the function.
- Use interfaces when you need flexibility and don't expect frequent modifications.
- Prefer concrete types when returning specific objects that might evolve over time.
- `Errors` are an exception to this rule. Go functions and methods can declare a return parameter of the error `interface` type.
