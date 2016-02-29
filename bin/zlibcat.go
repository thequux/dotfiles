package main

import "compress/zlib"
import "os"
import "io"
import "fmt"

func main() {
	var input io.Reader = os.Stdin
	var err error
	if len(os.Args) > 1 {
		input, err = os.Open(os.Args[1])
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %s", err)
			os.Exit(1)
		}
	}
	reader, _ := zlib.NewReader(input)
	io.Copy(os.Stdout, reader)
}
