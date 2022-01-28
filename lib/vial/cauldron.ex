defmodule Vial.Cauldron do
  @moduledoc """
  The container for data and events that Vials operate on.
  """

  @type t() :: %__MODULE__{
    data: any(),
    events: list(),
    assigns: Map.t(),
    halted: boolean(),
    events_handled: boolean()
  }

  defstruct [
    data: nil,
    events: [],
    handlers: [],
    assigns: %{},
    halted: false,
    events_handled: false
  ]

  def new do
    %__MODULE__{}
  end

  def new(data) do
    set_data(new(), data)
  end

  def update_data(cauldron, fun) do
    %__MODULE__{cauldron | data: fun.(cauldron.data)}
  end

  def set_data(cauldron, data) do
    %__MODULE__{cauldron | data: data}
  end

  def assign(cauldron, key, value) do
    %__MODULE__{cauldron | assigns: Map.put(cauldron.assigns, key, value)}
  end

  def add_event(cauldron, event) do
    %__MODULE__{cauldron | events: [event | cauldron.events]}
  end

  def halt(cauldron) do
    %__MODULE__{cauldron | halted: true}
  end
end
