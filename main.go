package main

import (
	"fmt"

	"github.com/kyokomi/emoji"
)

func main() {
	pizzaMessage := emoji.Sprint(":pizza:")
	fmt.Println(pizzaMessage)
}
