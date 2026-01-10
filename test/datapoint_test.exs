defmodule Bagg.DatapointTest do
  use ExUnit.Case, async: true

  alias Bagg.Datapoint

  describe "new/1" do
    test "creates a datapoint with valid input" do
      input = %{
        "comment" => "test comment",
        "daystamp" => "20230115",
        "value" => 42
      }

      result = Datapoint.new(input)

      assert %Datapoint{} = result
      assert result.date == ~D[2023-01-15]
      assert result.value == 42
      assert result.hashtags == MapSet.new()
    end

    test "extracts single hashtag from comment" do
      input = %{
        "comment" => "working on #project today",
        "daystamp" => "20230115",
        "value" => 1
      }

      result = Datapoint.new(input)

      assert MapSet.member?(result.hashtags, "#project")
      assert MapSet.size(result.hashtags) == 1
    end

    test "extracts multiple hashtags from comment" do
      input = %{
        "comment" => "#fitness #health morning run",
        "daystamp" => "20230115",
        "value" => 5
      }

      result = Datapoint.new(input)

      assert MapSet.member?(result.hashtags, "#fitness")
      assert MapSet.member?(result.hashtags, "#health")
      assert MapSet.size(result.hashtags) == 2
    end

    test "handles hashtag at end of comment" do
      input = %{
        "comment" => "completed task #done",
        "daystamp" => "20230115",
        "value" => 1
      }

      result = Datapoint.new(input)

      assert MapSet.member?(result.hashtags, "#done")
    end

    test "handles hashtag at start of comment" do
      input = %{
        "comment" => "#morning exercise routine",
        "daystamp" => "20230115",
        "value" => 30
      }

      result = Datapoint.new(input)

      assert MapSet.member?(result.hashtags, "#morning")
    end

    test "handles hashtag with numbers after first letter" do
      input = %{
        "comment" => "#goal2023 achieved",
        "daystamp" => "20230115",
        "value" => 1
      }

      result = Datapoint.new(input)

      assert MapSet.member?(result.hashtags, "#goal2023")
    end

    test "handles hashtag with underscores" do
      input = %{
        "comment" => "tracking #work_hours today",
        "daystamp" => "20230115",
        "value" => 8
      }

      result = Datapoint.new(input)

      assert MapSet.member?(result.hashtags, "#work_hours")
    end

    test "ignores hashtags starting with numbers" do
      input = %{
        "comment" => "test #123abc not valid",
        "daystamp" => "20230115",
        "value" => 1
      }

      result = Datapoint.new(input)

      assert MapSet.size(result.hashtags) == 0
    end

    test "handles empty comment" do
      input = %{
        "comment" => "",
        "daystamp" => "20230115",
        "value" => 0
      }

      result = Datapoint.new(input)

      assert result.hashtags == MapSet.new()
    end

    test "handles floating point values" do
      input = %{
        "comment" => "weight measurement",
        "daystamp" => "20230115",
        "value" => 72.5
      }

      result = Datapoint.new(input)

      assert result.value == 72.5
    end

    test "handles negative values" do
      input = %{
        "comment" => "temperature reading",
        "daystamp" => "20230115",
        "value" => -5
      }

      result = Datapoint.new(input)

      assert result.value == -5
    end

    test "handles zero value" do
      input = %{
        "comment" => "no progress",
        "daystamp" => "20230115",
        "value" => 0
      }

      result = Datapoint.new(input)

      assert result.value == 0
    end

    test "parses daystamp with single digit month and day" do
      input = %{
        "comment" => "test",
        "daystamp" => "20230101",
        "value" => 1
      }

      result = Datapoint.new(input)

      assert result.date == ~D[2023-01-01]
    end

    test "parses daystamp for end of year" do
      input = %{
        "comment" => "test",
        "daystamp" => "20231231",
        "value" => 1
      }

      result = Datapoint.new(input)

      assert result.date == ~D[2023-12-31]
    end

    test "parses leap year date" do
      input = %{
        "comment" => "leap day",
        "daystamp" => "20240229",
        "value" => 1
      }

      result = Datapoint.new(input)

      assert result.date == ~D[2024-02-29]
    end

    test "handles comment with only hashtag" do
      input = %{
        "comment" => "#solo",
        "daystamp" => "20230115",
        "value" => 1
      }

      result = Datapoint.new(input)

      assert MapSet.member?(result.hashtags, "#solo")
      assert MapSet.size(result.hashtags) == 1
    end

    test "ignores duplicate hashtags in comment" do
      input = %{
        "comment" => "#repeat #repeat #repeat",
        "daystamp" => "20230115",
        "value" => 3
      }

      result = Datapoint.new(input)

      assert MapSet.member?(result.hashtags, "#repeat")
      assert MapSet.size(result.hashtags) == 1
    end

    test "handles mixed case hashtags" do
      input = %{
        "comment" => "#CamelCase #lowercase #UPPERCASE",
        "daystamp" => "20230115",
        "value" => 1
      }

      result = Datapoint.new(input)

      assert MapSet.member?(result.hashtags, "#CamelCase")
      assert MapSet.member?(result.hashtags, "#lowercase")
      assert MapSet.member?(result.hashtags, "#UPPERCASE")
      assert MapSet.size(result.hashtags) == 3
    end
  end
end
