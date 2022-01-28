defmodule Vial do
  @moduledoc """
  `Vial` is a library for creating Vials, which are self-contained units of functionality that operate on data and create events.
  """

  alias Vial.Cauldron

  @callback init(any()) :: any()
  @callback call(Vial.Glass.t(), any()) :: Vial.Glass.t()

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
