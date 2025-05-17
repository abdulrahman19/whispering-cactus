---
title: Go — Buffered vs Unbuffered Channels
date: 2025-04-30 23:49:30 
categories: [Tech, Golang]
tags: [golang, learning-go-book]
---

> By default, `channels` are unbuffered. Every write to an open, unbuffered channel causes the writing goroutine to pause until another goroutine reads from the same channel. Likewise, a read from an open, unbuffered channel causes the reading goroutine to pause until another goroutine writes to the same channel.
> ...
> Go also has buffered `channels`. These `channels` buffer a limited number of writes without blocking. If the buffer fills before there are any reads from the channel, a subsequent write to the channel pauses the writing goroutine until the channel is read. Just as writing to a channel with a full buffer blocks, reading from a channel with an empty buffer also blocks.
>
> <footer>Learning Go (2nd edition) — Chapter 8, "Reading, Writing, and Buffering"</footer>

Let's see how both buffered and unbuffered channels work in practice.

## Unbuffered Channels
Think of a unbuffered channel as a handoff lane at a relay race:
🏃‍♂️ → (message) → 🏃‍♀️
The baton can only be passed if both runners are there at the **same time**.

```go main.go
package main

import (
    "fmt"
    "time"
)

func main() {
    messages := make(chan string)

    go func() {
        fmt.Println("Sending message...")
        messages <- "hello" // This will block until a receiver is ready
        fmt.Println("Message sent!")
    }()

    // Add a small delay to illustrate blocking if the receiver isn't ready immediately
    time.Sleep(1 * time.Second)

    fmt.Println("Waiting to receive message...")
    msg := <-messages // This will block until a sender is ready
    fmt.Println("Received message:", msg)

    // If you uncomment the following lines, the second receiver would deadlock
    // because there's no second sender send a message.
    // msg2 := <-messages
    // fmt.Println("Received message 2:", msg2)
}
```
```bash output
Sending message...
Waiting to receive message...
Received message: hello
```

As you can see here, the `Message sent!` line will not be printed before the `waiting to receive message...` line, because the sending `goroutine` is blocked until the main `goroutine` receives the message.

>[!NOTE]
> The `Message sent!` may not be printed if the main `goroutine` exits before the sending `goroutine` finishes. To ensure that the sending `goroutine` completes, you can use a `sync.WaitGroup` or add a delay before exiting the main function.

>[!CAUTION]
> If you uncomment the second receiver block, the program will `deadlock` because there is no sender ready to send the second message.

## Buffered Channels
```go main.go
package main

import (
    "fmt"
    "time"
)

func main() {
    messages := make(chan string, 1) // Create a buffered channel with a capacity of 1

    go func() {
        fmt.Println("Sending message 1...")
        messages <- "hello" // This will not block
        fmt.Println("Message 1 sent!")
    }()

    time.Sleep(1 * time.Second) // Add a small delay to illustrate the buffer

    fmt.Println("Waiting to receive messages...")
    msg1 := <-messages // This receive will not block as the buffer is not empty
    fmt.Println("Received message:", msg1)

    // If you uncomment the following line, the program will `deadlock`
    // msg2 := <-messages
    // fmt.Println("Received message:", msg2)
}
```
```bash output
Sending message 1...
Message 1 sent!
Waiting to receive messages...
Received message: hello
```

In this example, the first message is sent without blocking because the channel has a buffer of size 1. The `Message 1 sent!` line is printed immediately after sending the message, even before the main `goroutine` receives it.

> [!CAUTION]
> Note that if you uncomment the second receiver block, the program will `deadlock` because the buffer is empty and there is no other `goroutine` sender to fill it and the the block will be forever.

Now let's see how `goroutine` is smart enough to not `deadlock` when there is a sender will fill the buffer even if it will take a while.

```go main.go
package main

import (
    "fmt"
    "time"
)

func main() {
    messages := make(chan string, 1) // Create a buffered channel with a capacity of 1

    go func() { // first goroutine
        fmt.Println("Sending message 1...")
        messages <- "hello" // This will not block
        fmt.Println("Message 1 sent!")
    }()

    go func() { // second goroutine
        time.Sleep(3 * time.Second)

        fmt.Println("Sending message 2...")
        messages <- "world" // This will not block
        fmt.Println("Message 2 sent!")
    }()

    sleep(1 * time.Second) // Add a small delay to illustrate the buffer

    fmt.Println("Waiting to receive messages...")
    msg1 := <-messages // This receive will not block as the buffer is not empty
    fmt.Println("Received message:", msg1)

    fmt.Println("Waiting to receive messages 2...")
    msg2 := <-messages // This receive will not block as the buffer is not empty
    fmt.Println("Received message:", msg2)
}
```
```bash output
Sending message 1...
Message 1 sent!
Waiting to receive messages...
Received message: hello
Waiting to receive messages 2...
Sending message 2...
Message 2 sent!
Received message: world
```

As you can see, the second message is sent after a delay of 3 seconds, but the second receiver will block in this case and not `deadlock` because Go know that the `goroutine 2` will fill the buffer and `msg2` will not be blocked forever. ✨

## Last thoughts about channels
Let's see this examle first:

```go main.go
package main

import (
    "fmt"
    "time"
)

func main() {
    messages := make(chan string)

    go func() {
        fmt.Println("Sending message...")
        messages <- "hello" // This will block until a receiver is ready
        fmt.Println("Message sent!")
    }()

    // Add a small delay to illustrate blocking if the receiver isn't ready immediately
    time.Sleep(1 * time.Second)

    fmt.Println("Waiting to receive message...")
    msg := <-messages // This will block until a sender is ready
    fmt.Println("Received message:", msg)

    go func() {
        fmt.Println("Sending message 2...")
        messages <- "world!" // what will happen here?!
        fmt.Println("Message 2 sent!")
    }()

    time.Sleep(1 * time.Second)
}
```
```bash output
Sending message...
Waiting to receive message...
Received message: hello
Sending message 2...
Message sent!
```

ok, if you looked at the output carefully you may wonder why the `Message 2 sent!` is not printed?
This is actually a good question and the answer will shock you!

The second `goroutine` is blocked because there is no receiver ready to receive the message. Remember, this is an unbuffered channel.
ok, but is this a `deadlock`? 🤔
The answer is **YES!!!**.

You may wonder one more time why the program is not showing us this `deadlock` error?!

The reason is that `deadlock` happens in onther/sub `goroutine` that is not the main `goroutine`, and any **not main** `goroutine` fails silently since the main `goroutine` is not aware of it. 🤯
In a short words, the second `goroutine` is blocked and it has error but since the main `goroutine` is not aware of it, the program will not show us any error and it will exit normally.

My advice here is to always make sure that each `goroutine` has a receiver ready to receive the message, otherwise you will end up with a `deadlock` and the program will exit silently without any error.
