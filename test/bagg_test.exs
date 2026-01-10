defmodule BaggTest do
  use ExUnit.Case, async: true

  alias Bagg.Datapoint

  describe "aggregate/2" do
    test "returns error for empty list" do
      assert Bagg.aggregate([]) == {:error, :no_datapoints}
    end

    test "returns error for invalid aggday function" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()}
      ]

      assert Bagg.aggregate(datapoints, aggday: :invalid_function) ==
               {:error, {:invalid_aggday, "invalid_function"}}
    end

    test "returns error for invalid string aggday" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()}
      ]

      assert Bagg.aggregate(datapoints, aggday: "nonexistent") ==
               {:error, {:invalid_aggday, "nonexistent"}}
    end

    test "aggregates single datapoint with default options" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints)

      assert length(result) == 1
      assert hd(result).value == 10
      assert hd(result).date == ~D[2023-01-15]
    end

    test "uses :last as default aggday when kyoom is false" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 5, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints)

      assert length(result) == 1
      assert hd(result).value == 10
    end

    test "uses :sum as default aggday when kyoom is true" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 5, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, kyoom: true)

      assert length(result) == 1
      assert hd(result).value == 15
    end

    test "aggregates multiple datapoints on same day with sum" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 20, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 30, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, aggday: :sum)

      assert length(result) == 1
      assert hd(result).value == 60
    end

    test "aggregates with min" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 5, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 20, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, aggday: :min)

      assert hd(result).value == 5
    end

    test "aggregates with max" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 5, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 20, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, aggday: :max)

      assert hd(result).value == 20
    end

    test "aggregates with first" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 20, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, aggday: :first)

      assert hd(result).value == 10
    end

    test "aggregates with mean" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 20, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, aggday: :truemean)

      assert hd(result).value == 15.0
    end

    test "aggregates with median" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 1, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 5, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, aggday: :median)

      assert hd(result).value == 5
    end

    test "aggregates with count" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 1, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 5, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, aggday: :count)

      assert hd(result).value == 3
    end

    test "accepts string aggday parameter" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 20, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, aggday: "sum")

      assert hd(result).value == 30
    end

    test "groups datapoints by date and sorts result" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-17], value: 30, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-16], value: 20, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, aggday: :last)

      assert length(result) == 3
      assert Enum.at(result, 0).date == ~D[2023-01-15]
      assert Enum.at(result, 1).date == ~D[2023-01-16]
      assert Enum.at(result, 2).date == ~D[2023-01-17]
    end

    test "merges hashtags from multiple datapoints on same day" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new(["#fitness"])},
        %Datapoint{date: ~D[2023-01-15], value: 20, hashtags: MapSet.new(["#health"])}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, aggday: :sum)

      assert MapSet.member?(hd(result).hashtags, "#fitness")
      assert MapSet.member?(hd(result).hashtags, "#health")
    end

    test "preserves hashtags when single datapoint per day" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new(["#test"])}
      ]

      {:ok, result} = Bagg.aggregate(datapoints)

      assert MapSet.member?(hd(result).hashtags, "#test")
    end
  end

  describe "aggregate/2 with kyoom option" do
    test "cumulates values across days" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 10, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-16], value: 20, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-17], value: 5, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, kyoom: true)

      assert Enum.at(result, 0).value == 10
      assert Enum.at(result, 1).value == 30
      assert Enum.at(result, 2).value == 35
    end

    test "cumulates after daily aggregation" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 5, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-15], value: 5, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-16], value: 10, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, kyoom: true)

      # Day 1: 5 + 5 = 10
      # Day 2: 10 + 10 = 20 (cumulative)
      assert Enum.at(result, 0).value == 10
      assert Enum.at(result, 1).value == 20
    end
  end

  describe "aggregate/2 with odom option" do
    test "handles odometer reset (zero value)" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 100, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-16], value: 150, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-17], value: 0, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-18], value: 50, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, odom: true)

      # First: 100
      # Second: 150 (no reset)
      # Third: 0 triggers reset, curradd becomes 150
      # Fourth: 50 + 150 = 200
      assert Enum.at(result, 0).value == 100
      assert Enum.at(result, 1).value == 150
      assert Enum.at(result, 2).value == 150
      assert Enum.at(result, 3).value == 200
    end

    test "preserves values when no reset occurs" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 100, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-16], value: 150, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-17], value: 200, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, odom: true)

      assert Enum.at(result, 0).value == 100
      assert Enum.at(result, 1).value == 150
      assert Enum.at(result, 2).value == 200
    end
  end

  describe "aggregate/2 with combined kyoom and odom" do
    test "applies odom first then kyoom" do
      datapoints = [
        %Datapoint{date: ~D[2023-01-15], value: 100, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-16], value: 0, hashtags: MapSet.new()},
        %Datapoint{date: ~D[2023-01-17], value: 50, hashtags: MapSet.new()}
      ]

      {:ok, result} = Bagg.aggregate(datapoints, odom: true, kyoom: true)

      # Odom: [100, 100, 150] (0 triggers reset, 50 + 100 = 150)
      # Kyoom: [100, 200, 350] (cumulative)
      assert Enum.at(result, 0).value == 100
      assert Enum.at(result, 1).value == 200
      assert Enum.at(result, 2).value == 350
    end
  end

  describe "aggregate_goal/1" do
    test "processes raw goal data" do
      goal = %{
        "datapoints" => [
          %{"comment" => "test", "daystamp" => "20230115", "value" => 10, "timestamp" => 1},
          %{"comment" => "test", "daystamp" => "20230115", "value" => 20, "timestamp" => 2}
        ],
        "odom" => false,
        "kyoom" => false,
        "aggday" => "sum"
      }

      {:ok, result} = Bagg.aggregate_goal(goal)

      assert length(result) == 1
      assert hd(result).value == 30
    end

    test "returns error when datapoints key is missing" do
      goal = %{
        "odom" => false,
        "kyoom" => false,
        "aggday" => "sum"
      }

      assert Bagg.aggregate_goal(goal) == {:error, :no_datapoints}
    end

    test "sorts datapoints by daystamp and timestamp before aggregation" do
      goal = %{
        "datapoints" => [
          %{"comment" => "second", "daystamp" => "20230115", "value" => 20, "timestamp" => 2},
          %{"comment" => "first", "daystamp" => "20230115", "value" => 10, "timestamp" => 1}
        ],
        "odom" => false,
        "kyoom" => false,
        "aggday" => "first"
      }

      {:ok, result} = Bagg.aggregate_goal(goal)

      # Should pick the first by timestamp order
      assert hd(result).value == 10
    end

    test "handles empty datapoints list" do
      goal = %{
        "datapoints" => [],
        "odom" => false,
        "kyoom" => false,
        "aggday" => "sum"
      }

      assert Bagg.aggregate_goal(goal) == {:error, :no_datapoints}
    end

    test "extracts hashtags from comments" do
      goal = %{
        "datapoints" => [
          %{"comment" => "#workout morning run", "daystamp" => "20230115", "value" => 5, "timestamp" => 1}
        ],
        "odom" => false,
        "kyoom" => false,
        "aggday" => "sum"
      }

      {:ok, result} = Bagg.aggregate_goal(goal)

      assert MapSet.member?(hd(result).hashtags, "#workout")
    end

    test "applies kyoom when specified" do
      goal = %{
        "datapoints" => [
          %{"comment" => "", "daystamp" => "20230115", "value" => 10, "timestamp" => 1},
          %{"comment" => "", "daystamp" => "20230116", "value" => 20, "timestamp" => 2}
        ],
        "odom" => false,
        "kyoom" => true,
        "aggday" => "sum"
      }

      {:ok, result} = Bagg.aggregate_goal(goal)

      assert Enum.at(result, 0).value == 10
      assert Enum.at(result, 1).value == 30
    end

    test "applies odom when specified" do
      goal = %{
        "datapoints" => [
          %{"comment" => "", "daystamp" => "20230115", "value" => 100, "timestamp" => 1},
          %{"comment" => "", "daystamp" => "20230116", "value" => 0, "timestamp" => 2},
          %{"comment" => "", "daystamp" => "20230117", "value" => 50, "timestamp" => 3}
        ],
        "odom" => true,
        "kyoom" => false,
        "aggday" => "last"
      }

      {:ok, result} = Bagg.aggregate_goal(goal)

      assert Enum.at(result, 0).value == 100
      assert Enum.at(result, 1).value == 100
      assert Enum.at(result, 2).value == 150
    end

    test "returns error for invalid aggday" do
      goal = %{
        "datapoints" => [
          %{"comment" => "", "daystamp" => "20230115", "value" => 10, "timestamp" => 1}
        ],
        "odom" => false,
        "kyoom" => false,
        "aggday" => "invalid"
      }

      assert Bagg.aggregate_goal(goal) == {:error, {:invalid_aggday, "invalid"}}
    end
  end
end
