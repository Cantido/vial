defmodule Vial do
  @moduledoc """
  `Vial` is a library for staged processing and event handling.

  ## Hello world

      defmodule MyVial do
        import Vial.Cauldron

        def init(options)
          # Initialize options
          options
        end

        def call(cauldron, options) do
          update_data(cauldron, fn data ->
            data + 1
          end)
        end
      end

  The snippet above shows a very simple vial that adds 1 to the data passed to it.
  Build and execute this in a pipeline with `Vial.run/4`.

  ```bash
  $ iex -S mix
  iex> "path/to/file.ex"
  [MyVial]
  iex> cauldron = Vial.run(1, [{MyVial, []}], [])
  iex> cauldron.data
  2
  ```

  If this looks a lot like `Plug`, that's because this library aims to replicate `Plug`'s pipeline style of processing in a more general-purpose library.
  Let's dive into Vial's concepts and see how they compare to `Plug`.

  ## The `Vial.Cauldron` struct

  A vial encapsulates an operation performed on data, and can be made two ways.

  Function vials accept data and options as arguments, and returns the encapsulated data.

      def hello_world_vial(cauldron, _opts) do
        update_data(cauldron, fn _data ->
          "Hello world"
        end)
      end

  Module vials have an `init/1` and `call/2` function, just like a module Plug.

      defmodule MyVial do
        def init([]), do: false
        def call(cauldron, _opts), do: cauldron
      end

  Data is wrapped by a `Vial.Cauldron` struct.
  It's where all your vials mix together.
  Isn't that whimsical?

      %Vial.Cauldron{
        data: "Hello world",
        ...
      }

  Manipulate the cauldron with the `Vial.Cauldron` module.
  In the above examples, the `update_data/2` function is defined in `Vial.Cauldron`.

  Remember that Elixir data is immutable, so every manipulation returns a new copy of that cauldron.

  ## Event handing using Reagents

  A more original feature in `Vial` is the ability to add event handlers to your cauldron, and trigger them from vials.
  First, a vial needs to use `emit_event/2` and pass some data.

      defmodule MyEventEmitterVial do
        import Vial.Cauldron

        def init(_), do: []

        def call(cauldron, _opts) do
          emit_event(cauldron, cauldron.data)
        end
      end

  Then, a reagent will be given that data at the end of the pipeline.

      defmodule MyReagent do
        def init(_), do: []

        def handle_event(event) do
          IO.puts("Hello, " <> event <> "!")
        end
      end

  Then use `Vial.run/3` to run the pipeline, providing reagents as the third argument.

      cauldron = Vial.run("Rosa", [{MyEventEmitterVial, []}], [{MyReagent, []}])
      Hello, Rosa!

  Reagents run once the cauldron pipeline is halted, and each reagent gets every event, in the order they were emitted.
  Use pattern matching to let an event reject data it doesn't care about.
  """

  alias Vial.Cauldron

  @callback init(any()) :: any()
  @callback call(Cauldron.t(), any()) :: Vial.Cauldron.t()

  def run(cauldron, vials, reagents, opts \\ [])

  def run(%Cauldron{halted: true} = cauldron, _vials, reagents, _opts) do
    do_events(cauldron, reagents)
  end

  def run(%Cauldron{} = cauldron, vials, reagents, _opts) do
    do_run(cauldron, vials)
    |> do_events(reagents)
  end

  defp do_run(%Cauldron{} = cauldron, [{vial_mod, vial_opts} | vials]) do
    case vial_mod.call(cauldron, vial_mod.init(vial_opts)) do
      %Cauldron{halted: true} = cauldron ->
        cauldron

      %Cauldron{} = cauldron ->
        do_run(cauldron, vials)

      other ->
        raise "expected #{inspect(vial_mod)} to return Vial.Cauldron, got: #{inspect(other)}"
    end
  end

  defp do_run(%Cauldron{} = cauldron, [fun | vials]) when is_function(fun, 1) do
    case fun.(cauldron) do
      %Cauldron{halted: true} = cauldron ->
        cauldron

      %Cauldron{} = cauldron ->
        do_run(cauldron, vials)

      other ->
        raise "expected #{inspect(fun)} to return Vial.Cauldron, got: #{inspect(other)}"
    end
  end

  defp do_run(%Cauldron{} = cauldron, []) do
    cauldron
  end

  defp do_events(%Cauldron{} = cauldron, [reagent_fun | reagents]) when is_function(reagent_fun, 1) do
    events = Enum.reverse(cauldron.events)

    Enum.each(events, reagent_fun)

    do_events(cauldron, reagents)
  end

  defp do_events(%Cauldron{} = cauldron, [{reagent_mod, reagent_opts} | reagents]) do
    events = Enum.reverse(cauldron.events)

    processed_reagent_opts = reagent_mod.init(reagent_opts)

    Enum.each(events, &reagent_mod.handle(&1, processed_reagent_opts))

    do_events(cauldron, reagents)
  end

  defp do_events(%Cauldron{} = cauldron, []) do
    cauldron
  end
end
