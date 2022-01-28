defmodule VialTest do
  use ExUnit.Case, async: true
  alias Vial.Cauldron
  doctest Vial

  test "executes function vials in order" do
    cauldron =
      Vial.run(
        Cauldron.new([]),
        [
          fn c ->
            Cauldron.update_data(c, &[1 | &1])
          end,
          fn c ->
            Cauldron.update_data(c, &[2 | &1])
          end
        ],
        []
      )

    assert cauldron.data == [2, 1]
  end

  defmodule FirstVial do
    def init(_), do: []
    def call(c, _), do: Cauldron.update_data(c, &[1 | &1])
  end

  defmodule SecondVial do
    def init(_), do: []
    def call(c, _), do: Cauldron.update_data(c, &[2 | &1])
  end

  test "executes module vials in order" do
    cauldron =
      Vial.run(
        Cauldron.new([]),
        [
          {FirstVial, []},
          {SecondVial, []}
        ],
        []
      )

    assert cauldron.data == [2, 1]
  end

  defmodule PrependVial do
    def init(val), do: val
    def call(c, val), do: Cauldron.update_data(c, &[val | &1])
  end

  test "passes correct opts to each vial" do
    cauldron =
      Vial.run(
        Cauldron.new([]),
        [
          {PrependVial, 1},
          {PrependVial, 2}
        ],
        []
      )

    assert cauldron.data == [2, 1]
  end

  defmodule EventEmitterVial do
    def init(val), do: val
    def call(c, val), do: Cauldron.add_event(c, val)
  end

  test "passes events to function handlers" do
    {:ok, agent} = Agent.start(fn -> [] end)

    Vial.run(
      Cauldron.new([]),
      [
        {EventEmitterVial, 1},
        {EventEmitterVial, 2}
      ],
      [
        fn e -> Agent.update(agent, fn a -> [e | a] end) end
      ]
    )

    assert Agent.get(agent, fn x -> x end) == [2, 1]
  end

  test "passes events to module handlers, and passes them their opts" do
    {:ok, agent} = Agent.start(fn -> [] end)

    defmodule EventStoringReagent do
      def init(agent), do: agent
      def handle(e, agent), do: Agent.update(agent, fn a -> [e | a] end)
    end

    Vial.run(
      Cauldron.new([]),
      [
        {EventEmitterVial, 1},
        {EventEmitterVial, 2}
      ],
      [
        {EventStoringReagent, agent}
      ]
    )

    assert Agent.get(agent, fn x -> x end) == [2, 1]
  end
end
