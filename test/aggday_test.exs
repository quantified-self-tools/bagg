defmodule Bagg.AggdayTest do
  use ExUnit.Case, async: true

  alias Bagg.Aggday

  describe "sum/1" do
    test "sums a list of integers" do
      assert Aggday.sum([1, 2, 3, 4, 5]) == 15
    end

    test "sums a list with negative numbers" do
      assert Aggday.sum([1, -2, 3, -4, 5]) == 3
    end

    test "sums a single element list" do
      assert Aggday.sum([42]) == 42
    end

    test "sums floating point numbers" do
      assert Aggday.sum([1.5, 2.5, 3.0]) == 7.0
    end
  end

  describe "min/1" do
    test "returns minimum of integers" do
      assert Aggday.min([5, 2, 8, 1, 9]) == 1
    end

    test "returns minimum with negative numbers" do
      assert Aggday.min([5, -2, 8, 1, 9]) == -2
    end

    test "returns single element" do
      assert Aggday.min([42]) == 42
    end

    test "returns minimum of floats" do
      assert Aggday.min([1.5, 0.5, 2.0]) == 0.5
    end
  end

  describe "max/1" do
    test "returns maximum of integers" do
      assert Aggday.max([5, 2, 8, 1, 9]) == 9
    end

    test "returns maximum with negative numbers" do
      assert Aggday.max([-5, -2, -8, -1, -9]) == -1
    end

    test "returns single element" do
      assert Aggday.max([42]) == 42
    end

    test "returns maximum of floats" do
      assert Aggday.max([1.5, 3.5, 2.0]) == 3.5
    end
  end

  describe "first/1" do
    test "returns first element" do
      assert Aggday.first([1, 2, 3]) == 1
    end

    test "returns first of single element list" do
      assert Aggday.first([42]) == 42
    end
  end

  describe "last/1" do
    test "returns last element" do
      assert Aggday.last([1, 2, 3]) == 3
    end

    test "returns last of single element list" do
      assert Aggday.last([42]) == 42
    end
  end

  describe "truemean/1" do
    test "calculates mean of integers" do
      assert Aggday.truemean([2, 4, 6]) == 4.0
    end

    test "calculates mean with duplicates" do
      assert Aggday.truemean([2, 2, 2, 8]) == 3.5
    end

    test "calculates mean of single element" do
      assert Aggday.truemean([5]) == 5.0
    end

    test "calculates mean of floats" do
      assert Aggday.truemean([1.0, 2.0, 3.0]) == 2.0
    end
  end

  describe "uniqmean/1" do
    test "calculates mean of unique values only" do
      assert Aggday.uniqmean([2, 2, 2, 8]) == 5.0
    end

    test "same as truemean when no duplicates" do
      assert Aggday.uniqmean([2, 4, 6]) == 4.0
    end

    test "handles single element" do
      assert Aggday.uniqmean([5]) == 5.0
    end

    test "handles all duplicates" do
      assert Aggday.uniqmean([3, 3, 3, 3]) == 3.0
    end
  end

  describe "mean/1" do
    test "is alias for uniqmean" do
      assert Aggday.mean([2, 2, 2, 8]) == Aggday.uniqmean([2, 2, 2, 8])
    end
  end

  describe "median/1" do
    test "returns middle value for odd length list" do
      assert Aggday.median([1, 3, 5]) == 3
    end

    test "returns average of two middle values for even length list" do
      assert Aggday.median([1, 2, 3, 4]) == 2.5
    end

    test "sorts before finding median" do
      assert Aggday.median([5, 1, 3]) == 3
    end

    test "returns single element" do
      assert Aggday.median([42]) == 42
    end

    test "handles two elements" do
      assert Aggday.median([10, 20]) == 15.0
    end

    test "handles duplicates" do
      assert Aggday.median([1, 1, 1, 5, 5]) == 1
    end
  end

  describe "mode/1" do
    test "returns most frequent value" do
      assert Aggday.mode([1, 2, 2, 3]) == 2
    end

    test "handles ties by returning first to achieve max count" do
      # 1 reaches count 2 at index 2, 2 reaches count 2 at index 3
      assert Aggday.mode([1, 2, 1, 2, 3]) == 1
      # 2 reaches count 2 at index 2, 1 reaches count 2 at index 3
      assert Aggday.mode([1, 2, 2, 1]) == 2
      # 1 reaches count 2 at index 2, 2 reaches count 2 at index 3
      assert Aggday.mode([2, 1, 1, 2]) == 1
    end

    test "returns single element" do
      assert Aggday.mode([42]) == 42
    end

    test "handles all same values" do
      assert Aggday.mode([5, 5, 5]) == 5
    end

    test "handles all unique values" do
      # When all unique, returns first element (first to achieve count 1)
      assert Aggday.mode([3, 2, 1]) == 3
    end
  end

  describe "trimmean/1" do
    test "trims 10% from each end and calculates mean" do
      # 10 elements, trim 1 from each end (floor(10 * 0.1) = 1)
      # [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] -> trim 1 from each end -> [2, 3, 4, 5, 6, 7, 8, 9]
      assert Aggday.trimmean([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) == 5.5
    end

    test "handles small list where trim is 0" do
      # 5 elements, floor(5 * 0.1) = 0, so no trimming
      assert Aggday.trimmean([1, 2, 3, 4, 5]) == 3.0
    end

    test "handles single element" do
      assert Aggday.trimmean([42]) == 42.0
    end

    test "sorts before trimming" do
      assert Aggday.trimmean([10, 1, 5, 9, 2, 8, 3, 7, 4, 6]) == 5.5
    end
  end

  describe "binary/1" do
    test "returns 0 for empty list" do
      assert Aggday.binary([]) == 0
    end

    test "returns 1 for non-empty list" do
      assert Aggday.binary([1]) == 1
    end

    test "returns 1 for list with multiple elements" do
      assert Aggday.binary([1, 2, 3]) == 1
    end

    test "returns 1 for list with zero values" do
      assert Aggday.binary([0, 0, 0]) == 1
    end
  end

  describe "jolly/1" do
    test "is alias for binary" do
      assert Aggday.jolly([]) == Aggday.binary([])
      assert Aggday.jolly([1, 2]) == Aggday.binary([1, 2])
    end
  end

  describe "nonzero/1" do
    test "returns 1 if any non-zero value" do
      assert Aggday.nonzero([0, 0, 1, 0]) == 1
    end

    test "returns 0 if all zeros" do
      assert Aggday.nonzero([0, 0, 0]) == 0
    end

    test "returns 1 for single non-zero" do
      assert Aggday.nonzero([5]) == 1
    end

    test "returns 0 for single zero" do
      assert Aggday.nonzero([0]) == 0
    end

    test "handles negative numbers as non-zero" do
      assert Aggday.nonzero([0, -1, 0]) == 1
    end

    test "handles floating point zero" do
      assert Aggday.nonzero([0.0, 0.0]) == 0
    end
  end

  describe "triangle/1" do
    test "calculates triangular number from sum" do
      # sum([1, 2, 3]) = 6, triangle = 6 * 7 / 2 = 21
      assert Aggday.triangle([1, 2, 3]) == 21.0
    end

    test "handles single element" do
      # sum = 5, triangle = 5 * 6 / 2 = 15
      assert Aggday.triangle([5]) == 15.0
    end

    test "handles zero sum" do
      # sum = 0, triangle = 0 * 1 / 2 = 0
      assert Aggday.triangle([0]) == 0.0
    end

    test "handles sum of 1" do
      # sum = 1, triangle = 1 * 2 / 2 = 1
      assert Aggday.triangle([1]) == 1.0
    end
  end

  describe "square/1" do
    test "calculates square of sum" do
      # sum([1, 2, 3]) = 6, square = 36
      assert Aggday.square([1, 2, 3]) == 36.0
    end

    test "handles single element" do
      assert Aggday.square([5]) == 25.0
    end

    test "handles zero" do
      assert Aggday.square([0]) == 0.0
    end

    test "handles negative sum" do
      # sum([-5]) = -5, square = 25
      assert Aggday.square([-5]) == 25.0
    end
  end

  describe "clocky/1" do
    test "sums pairwise differences" do
      # Pairs: (1, 5) -> 4, (3, 7) -> 4, sum = 8
      assert Aggday.clocky([1, 5, 3, 7]) == 8
    end

    test "discards incomplete pair at end" do
      # Pairs: (1, 5) -> 4, (3 is discarded)
      assert Aggday.clocky([1, 5, 3]) == 4
    end

    test "returns 0 for single element" do
      assert Aggday.clocky([1]) == 0
    end

    test "handles two elements" do
      assert Aggday.clocky([10, 15]) == 5
    end

    test "handles negative differences" do
      # Pairs: (10, 5) -> -5
      assert Aggday.clocky([10, 5]) == -5
    end
  end

  describe "count/1" do
    test "returns length of list" do
      assert Aggday.count([1, 2, 3, 4, 5]) == 5
    end

    test "returns 1 for single element" do
      assert Aggday.count([42]) == 1
    end

    test "returns 0 for empty list" do
      assert Aggday.count([]) == 0
    end
  end

  describe "kyshoc/1" do
    test "returns sum when less than 2600" do
      assert Aggday.kyshoc([100, 200, 300]) == 600
    end

    test "returns 2600 when sum exceeds 2600" do
      assert Aggday.kyshoc([1000, 1000, 1000]) == 2600
    end

    test "returns sum when exactly 2600" do
      assert Aggday.kyshoc([1300, 1300]) == 2600
    end

    test "handles single element" do
      assert Aggday.kyshoc([100]) == 100
    end

    test "handles single element exceeding 2600" do
      assert Aggday.kyshoc([3000]) == 2600
    end
  end
end
