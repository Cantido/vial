# Vial

A library for staged processing and event handling.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `vial` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vial, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/vial>.

## Usage

Vial helps you encapulsate data changes into Vials, which are units of processing.
Vials operate on Cauldrons, which encapsulate your data and the state of your pipeline.

This snippet shows how to create a Vial.

```elixir
defmodule MyVial do
  import Vial.Cauldron

  def init(optons) do
    # Initialize options
    options
  end

  def call(cauldron, options) do
    update_data(fn data ->
      data + 1
    end)
  end
end
```

Then build and execute this in a pipeline with `Vial.run/4`.

```
iex> cauldron = Vial.run(1, [{MyVial, []}], [])
iex> cauldron.data
2
```

### Events

That empty list third argument is for the Reagents, which are event handlers.
Define a Vial that emits an event like this.

```elixir
defmodule MyEventEmitterVial do
  import Vial.Cauldron

  def init(_), do: []

  def call(cauldron, _options) do
    emit_event(cauldron, "world")
  end
end
```

Then create a Reagent that reacts to it.

```elixir
defmodule MyReagent do
  def init(_), do: []

  def handle_event(event) do
    IO.puts("Hello #{event}!")
  end
end
```

Reagents run after all Vials, and each Reagent gets each event, in the order they were emitted

```
iex> cauldron = Vial.run(1, [{MyEventEmitterVial, []}], [{MyReagent, []}])
Hello world!
```

## License

MIT License

Copyright 2022 Rosa Richter

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[mailing list]: https://lists.sr.ht/~cosmicrose/hex_licenses

