# ImgStore

Stores arbitrary files in a png! This tools takes binary data and saves a byte at a time into the R, G, and B channels of each pixel. Data can be extracted manually by reading the pixels left to right, top to bottom, and saving each byte back out to disk.

## Practical Application

Almost none! This tool was built as an exercise in image manipulation. I suppose you *could* use it to store data on image hosting sites, but there are already better ways of hiding data in a PNG that aren't nearly as obvious and don't require a square image.

## Usage

```ruby
require_relative 'ImgStore'

ImgStore.encode("hello world!", "foo.png")
ImgStore.decode(File.read("foo.png"), "decoded.txt")
```

## Examples

Here's an example ["hello world" audio file.](examples/example.wav)

And here's that same wave file embedded in a PNG:

![Encoded 'hello world' wav](examples/example.png)

Provided is a test script ([examples/test.rb](examples/test.rb)) that will generate the PNG, then decode the PNG and recover a working wave file.
