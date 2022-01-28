defmodule Vial.Reagent do
  @moduledoc """
  An event handler that reacts to the events created by Vials.
  """

  @type opts() :: any()
  @type event() :: any()

  @callback init(opts()) :: opts()
  @callback handle(event(), opts()) :: any()
end
